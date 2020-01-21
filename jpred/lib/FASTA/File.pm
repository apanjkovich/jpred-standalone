package FASTA::File;

use strict;
use warnings;
use Carp;

use base qw(Sequence::File);
use FASTA;

sub old_read {
  my ( $self, $fh ) = @_;

  my ( $id, $seq, @seqs );
  while (<$fh>) {
    chomp;
    next if /^\s+$/;

    if (s/^>//) {
      push @seqs, [ $id, $seq ] if $id and $seq;
      $seq = undef;
      $id  = $_;
    } else {
      $seq .= $_;
    }
  }
  push @seqs, [ $id, $seq ] if $id and $seq;

  for (@seqs) {
    my $new = FASTA->new( id => ${$_}[0] );
    $new->seq( split //, ${$_}[1] );
    $self->add_entries($new);
  }

  1;
}

sub read {
  my ( $self, $fh ) = @_;
  local $/ = "\n>";
  while (<$fh>) {
    s/^>//g;
    s/>$//g;

    my ( $id, @data ) = split /\n/, $_;
    my $entry = FASTA->new( id => $id );
    $entry->seq( split //, join( "", @data ) );

    $self->add_entries($entry);
  }

  1;
}

sub write {
  my ( $self, $fh ) = @_;

  local $| = 1;

  for ( $self->get_entries ) {
    my $id  = $_->id;
    my @seq = $_->seq;

    my $seq = join '', @seq;
    $seq =~ s/\s*//g;
    $seq =~ s/(.{72})/$1\n/g;

    print $fh ">$id\n$seq\n";
  }
}

1;
