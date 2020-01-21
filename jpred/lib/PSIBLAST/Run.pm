package PSIBLAST::Run;

use Carp;
use base qw(Root);
use Run qw(check);

sub new {
  my ( $class, %args ) = @_;
  my $self = {};
  bless $self, ref($class) || $class;

  # -a number of CPUs used (default 1)
  # -e e-value threshold for reporting sequences (default 10)
  # -h e-value threshold for including sequences in PSSM (default 0.002)
  # -m type of output
  # -b max number of alignments reported (default 250)
  # -v max number of sequences described (default 500)
  # -j max number of itterations (default 1)
  $self->args("-e0.05 -h0.01 -m6 -b10000 -v10000 -j3");

  #$self->args("-a2 -e0.05 -h0.01 -m6 -b20000 -v20000 -j15");
  #	$self->BLASTMAT("/software/jpred_bin/blast");
  #	$self->BLASTDB("/software/jpred_uniprot_all_filt");

  # Automatically run any arguments passed to the constructor
  for ( keys %args ) {
    croak "No such method '$_' of object $class" unless $self->can($_);
    $self->$_( $args{$_} );
  }

  return $self;
}

sub path     { defined $_[1] ? $_[0]->{path}   = $_[1]      : $_[0]->{path} }
sub args     { defined $_[1] ? $_[0]->{args}   = $_[1]      : $_[0]->{args} }
sub database { defined $_[1] ? $_[0]->{data}   = "-d $_[1]" : $_[0]->{data} }
sub input    { defined $_[1] ? $_[0]->{input}  = "-i $_[1]" : $_[0]->{input} }
sub multi    { defined $_[1] ? $_[0]->{multi}  = "-a $_[1]" : $_[0]->{multi} }
sub output   { defined $_[1] ? $_[0]->{output} = "-o $_[1]" : $_[0]->{output} }
sub matrix   { defined $_[1] ? $_[0]->{matrix} = "-Q $_[1]" : $_[0]->{matrix} }
sub debug    { defined $_[1] ? $_[0]->{debug}  = $_[1]      : $_[0]->{debug} }    # CC corrected - now works as expected. Before, debug was always on.
sub BLASTMAT { $ENV{BLASTMAT} = $_[1] }
sub BLASTDB  { $ENV{BLASTDB}  = $_[1] }

sub run {
  my ($self) = @_;

  # Required arguments
  for (qw(path output database input)) {
    croak "Method '$_' needs to be set" unless defined $self->$_;
  }

  # Construct the command line
  my @cmd;
  for (qw(path args database input matrix multi output)) {
    next unless $self->$_;
    push @cmd, $self->$_;
  }

  my $cmd = join " ", @cmd;

  # Execute PSIBLAST and check it ran okay
  if ( $self->debug ) {

    #for (keys %ENV) { warn "$_=$ENV{$_}\n" }
    warn "$cmd\n";
  }
  
  warn "About to execute: $cmd\n";

  system($cmd) == 0 or check( "blastpgp", $? ) and die "blastpgp was naughty";

  # Clean up the error.log file it produces
  if   ( -z "error.log" ) { unlink "error.log" }
  else                    { warn "blastpgp error.log file was not empty\n" }
}

1;
