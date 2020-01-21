package Index;

use strict;
use warnings;
use Carp;

our @ISA;

=head1 NAME

Index.pm - Module for creating indexed databases and retrieving the sequences from them

=head1 SYNOPSIS

  my $index = Index->new("Index::EMBOSS")

=head1 DESCRIPTION

This module provides an interface into retriving sequences from an indexed database, or given a database creates an index. First you have to choose what the type of index you want to use. Then there are a set of common functions for do these things.

=head1 EXAMPLE

First run:
  my $index = Index->new("Index::EMBOSS")

Where Index::EMBOSS is a type of database/indexing system you want to use and there is a module available for. This makes a load of methods available which can be called. These are generic but should work on specific databases.

=head1 AVAILABLE METHODS

You should then be able to call various methods on the Index object.

=cut

sub new {
	my ($class, %args) = @_;

	my $type = $args{type};
	eval "use $type";
	push @ISA, $type;

	my $self = {};
	bless $self, ref($class) || $class;
	return $self;
}

=head1 SEE ALSO

Look at the various perldoc pages for Index::*

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>

=cut

1;
