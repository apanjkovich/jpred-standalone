package Pairwise;

use strict;
use warnings;
use Carp;
use IPC::Open3;
#use UNIVERSAL qw(isa);
use File::Temp;
use base qw(Root Common);

use Run qw(check);

sub path {
  my ( $self, $path ) = @_;
  if ( defined $path ) { $self->{path} = $path }
  else {
    if   ( defined $self->{path} ) { return $self->{path} }
    else                           { croak "Path not defined" }
  }
}

sub run {
  my ( $self, $fasta ) = @_;

  #croak "Non FASTA::File object passed to Pairwise::run" unless isa $fasta, 'FASTA::File';

  local ( $/, $? ) = ( undef, 0 );

  my $f = File::Temp->new->filename;
  $fasta->write_file($f);

  my $pid = open my $fh, $self->path . " $f |" or die $!;

  my @output = join "\n", split "\n", <$fh>;

  waitpid $pid, 0;
  check( $self->path, $? ) or die "Pairwise was naughty\n";

  return @output;
}

1;
