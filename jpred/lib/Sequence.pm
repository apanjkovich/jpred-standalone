package Sequence;

use strict;
use warnings;
use Carp;
use base qw(Root);

sub id {
  my ( $self, $id ) = @_;
  defined $id
    ? $self->{ __PACKAGE__ . "id" } = $id
    : return $self->{ __PACKAGE__ . "id" };
}

sub seq {
  my ( $self, @entries ) = @_;
  if (@entries) { $self->{ __PACKAGE__ . "seq" } = [@entries] }
  else {
    if (wantarray) {
      return defined $self->{ __PACKAGE__ . "seq" }
        ? @{ $self->{ __PACKAGE__ . "seq" } }
        : ();
    } else {
      return $self->{ __PACKAGE__ . "seq" };
    }
  }
}

sub length {
  my ($self) = @_;
  return scalar @{ [ $self->seq ] };
}

#sub numeric {
#	my ($self, $set) = @_;
#	return $set ?
#		$self->{__PACKAGE__."numeric"} = $set :
#		$self->{__PACKAGE__."numeric"};
#}
#
#use Scalar::Util qw(looks_like_number);
#sub seq_compress {
#	my ($self, @entries) = @_;
#	if (@entries) {
#		my $numeric = grep { looks_like_number $_ } @entries;
#		if ($numeric != 0 && $numeric != @entries) {
#			die "Can't compress both numeric and non-numeric data";
#		}
#
#		if ($numeric) {
#			$self->numeric(1);
#			$self->seq(pack "d*", @entries)
#		}
#		else { $self->seq(join '', @entries) }
#	}
#	else {
#		return $self->seq
#	}
#}

sub sub_seq {
  my ( $self, @segments ) = @_;

  my $package = ref $self;

  return $self->seq unless @segments;
  confess "Passed an uneven number of segments" unless @segments % 2 == 0;

  {
    my %segments = @segments;

    # Find out if there are overlapping segments
    for my $pri ( sort keys %segments ) {
      for my $test ( sort keys %segments ) {
        next if $pri == $test;
        croak "Overlapping segments" if $test < $segments{$pri};
      }
    }
  }

  my @sections;
  my ( $i, @seq ) = ( 0, $self->seq );
  do {
    my ( $start, $end ) = @segments[ $i, $i + 1 ];

    # Create a new sequence object in the correct package, and put the
    # segment into it
    my $new_seq = $package->new( id => $self->id );
    $new_seq->seq( @seq[ $start .. $end ] );
    push @sections, $new_seq;
    $i += 2;
  } while ( $i < @segments );

  return @sections;
}

1;

__END__

=head1 NAME

Sequence - Holds information about a sequence

=head1 EXAMPLE

  my $seq = Sequence->new;

  $seq->id("Big wobbly molecule");
  my @residues = split //, "ASEQENCE";
  $seq->seq(@residues);

=head1 INHERITANCE

Inherits from the Root class.

=head1 METHODS

=head2 id()

Accessor for the sequence ID.

=head2 seq(@sequence_data)

Accessor for the sequence. Pass the information in as an array, one piece per position.

Returns an array reference if called in a scalar context, otherwise an array of the information.

=head2 length()

Returns the length of the sequence.

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>

=cut
