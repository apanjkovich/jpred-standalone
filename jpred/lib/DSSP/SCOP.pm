package DSSP::SCOP;

use strict;
use warnings;
use Carp;
use Scalar::Util qw(looks_like_number);

use base qw(DSSP);
use Utils qw($split_resid sort_resid);

=head1 NAME

DSSP::SCOP - Module to select DSSP records from SCOP description

=head1 SYNOPSIS

  my $dssp = DSSP::SCOP->new(read_file => "foo.dssp");
  my @range = $dssp->get_range("A:33-416");
  
=head1 DESCRIPTION

A module that provides a method of selecting a range of residues from a DSSP file. The description of the range is in the format used by SCOP version 1.65 in the dir.des file.

=head1 METHODS

The module inherits all the methods from the DSSP module.

=head2 $dssp->get_range("A:1-200,B:1-30")

Returns the DSSP::Position objects from within the range given. These are in the same order as they are presented in the DSSP file. They are returned as an array of array's, with each range having it's own array.

=cut

sub get_range {
  my ( $self, $defn ) = @_;

  $defn =~ / / and croak "get_range('$defn') has a space in it, which isn't allowed";
  my @ranges = split /,/, $defn;

  my @data;
  for (@ranges) {
    my @range;

    # A:1-200 or A:
    if (/:/) {
      my ( $chain, $range ) = split /:/, $_;

      # A:1-200
      if ( $range =~ /([[:alnum:]]+)-([[:alnum:]]+)/ ) {
        push @data, [ $self->select_positions( $chain, $1, $2 ) ];
      }

      # Hmmmmm.
      elsif ($range) {
        confess "You shouldn't be here";
      }

      # A:
      else {
        push @data, [ $self->get_chain_defs($chain) ];
      }
    } else {

      # 297-368
      if (/([[:alnum:]]+)-([[:alnum:]]+)/) {
        my @chains = $self->chains;
        if ( @chains > 1 ) {
          die "Don't know which chain to select";
        }
        my ($chain) = @chains;

        push @data, [ $self->select_positions( $chain, $1, $2 ) ];
      }

      # -
      elsif (/^-$/) {
        for my $chain ( $self->chains ) {
          push @data, [ $self->get_chain_defs($chain) ];
        }
      }

      # Otherwise we don't know what it is
      else {
        confess "Missed particular '$_'";
      }
    }
  }

  return @data;
}

=head2 $self->select_positions($chain, $start, $end);

Passed a chain

# Select those, $chain, $start, $end;

=cut

sub select_positions {
  my ( $self, $chain, $start, $end ) = @_;

  confess "Not passed all arguments" if grep { not defined } $chain, $start, $end;
  confess "Not passed a valid chain" unless grep { $_ eq $chain } $self->chains;

  my ( $flag, @positions ) = 0;
  my $test = sub {
    my ( $off, $start, $end ) = @_;
    if ( 3 == grep { looks_like_number $_ } $off, $start, $end ) {
      return 1 if $off >= $start and $off <= $end;
    } else {
      return undef;
    }
  };

  for my $pos ( $self->get_chain_defs($chain) ) {
    if ( $pos->break ) {
      push @positions, $pos if $flag;
      next;
    }

    my $off = $pos->off;
    if (
      ( $off eq $start or $test->( $off, $start, $end ) ) .. ( $off eq $end or $test->( $off, $start, $end ) )

      #	$test($off, $start, $end) $off >= $start and $off <= $end)
      #($off eq $start or )
      )
    {
      push @positions, $pos;
      $flag = 1;
    } else {
      $flag = 0;
    }
  }
  return @positions;
}

1;
