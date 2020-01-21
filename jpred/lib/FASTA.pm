package FASTA;

use strict;
use warnings;
use Carp;

use base qw(Root Sequence);

sub id {
  my ( $self, $id ) = @_;

  if ( defined $id ) {

    #warn "'$1' detected in ID, changing to ';'\n" if $id =~ s/([:#])/;/
  }

  $self->SUPER::id($id);
}

sub seq {
  my ( $self, @entries ) = @_;

  for (@entries) {
    warn "'$1' detected in entry, changing to ';'\n" if s/([:#,])/;/;
  }

  $self->SUPER::seq(@entries);
}

1;
