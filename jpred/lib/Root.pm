package Root;

use strict;
use warnings;
use Carp;

# CC This lib path is unnecessary - commented out as supercedes the 'lib' use in jpred itself.
#use lib qw(/homes/jon/cvs/jon/jpred/src /homes/jon/usr/lib/perl5);

=head1 NAME 

Root - Base module for new classes to inherit from

=head1 DESCRIPTION

This modules provides a new method for other classes to use if they so wish.

=head1 METHODS

=head2 new(foo => "bar")

This constructs an object of the right class and returns it. Any arugments passed to the constructer 
will be parsed as a hash with the first argument from the pair acting as the method that should 
be called and the second being the argument for that method.

=cut

sub new {
  my ( $class, %args ) = @_;
  my $self = bless {}, ref($class) || $class;

  for ( keys %args ) {
    croak "No such method '$_'" unless $self->can($_);
    $self->$_( $args{$_} );
  }

  return $self;
}

sub trace {
  my ($self) = @_;

  my $i = 1;

  while ( my @caller = caller $i ) {

    #print join("#", map { defined $_ ? $_ : ""} @caller), "\n";
    print $caller[0], ":", $caller[2], " ", $caller[3], "\n";
    $i++;
  }
}

sub warn {
  my ( $self, @message ) = @_;
  print STDERR join( "\n", @message ), "\n";
  $self->trace;
}

1;
