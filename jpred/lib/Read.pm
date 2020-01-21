package Read;

use strict;
use warnings;
use Carp;

use base qw(Common);

use IO::String;
use File::Temp;

=head1 NAME

Read - Two base methods for reading information.

=head1 DESCRIPTION

This module contains three methods for reading information into a program. They allow the reading of information from a string or filename and expect the method read() to be defind by the class that inherits this module.

=head1 METHODS

=head2 read_file($path)

Opens a file at the given path and then calls the read method.

=head2 read_file_gzip($path)

Calls read_file after decompressing a gzip compressed file using the system gzip command.

=head2 path($path)

Accessor for finding where a file was located.

=head2 read_string($scalar)

Reads the data in the scalar and passes it to the read method.

=head2 read($filehandle)

This method will cause a fatal error unless it's overidden by the class that inherits this module.

=cut

sub read {
	confess "The inheriting package hasn't defined the read() method\n"
}

sub read_file {
	my ($self, $fn) = @_;

	open my $fh, $fn or confess "Can't open file $fn: $!";
	$self->path($fn);
	$self->read($fh);
}

=head2 read_gzip_file($scalar);

Like read_file($scalar), but ungzip's the file first.

=cut

sub read_gzip_file {
	my ($self, $fn) = @_;

	my $gzipd_fn = File::Temp->new->filename;

	system("gzip -dc $fn > $gzipd_fn");

	$self->read_file($gzipd_fn);
}

sub read_string {
	my ($self, $string) = @_;

	my $fh = IO::String->new($string);
	$self->read($fh);
}

1;
