package Write;

use strict;
use warnings;
use Carp;

use base qw(Root);

use IO::String;
use File::Temp;

=head1 NAME

Write - Two base methods for writing information.

=head1 DESCRIPTION

This module contains three methods for writing information into a program. They allow the writing of information from a string or filename and expect the method write() to be defind by the class that inherits this module.

=head1 METHODS

=head2 write_file($path)

Opens a file at the given path and then calls the write method.

=head2 write_gzip_file($path)

Like write_file, but compresses the output using the system gzip command.

=head2 write_string($scalar)

Writes the data in the scalar and passes it to the write method.

=head2 write($filehandle)

This method will cause a fatal error unless it's overidden by the class that inherits this module.

=cut

sub write {
	confess "The inheriting package hasn't defined the write() method\n"
}

sub write_file {
	my ($self, $fn) = @_;

	open my $fh, ">$fn" or confess "Can't open file $fn: $!";
	$self->write($fh);
	close $fh;
}

sub write_gzip_file {
		my ($self, $fn) = @_;

		my $gzipd_fn = File::Temp->new->filename;

		$self->write_file($gzipd_fn);

		system "gzip -c $gzipd_fn > $fn";
}

sub write_string {
	my ($self) = @_;

	my $string;
	$self->write(IO::String->new($string));
	return $string;
}

1;
