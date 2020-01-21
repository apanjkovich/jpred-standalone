package Profile::Generic;

use strict;
use warnings;
use base qw(Profile);

=head1 NAME

Profile::Generic

=head1 DESCRIPTION

Reads in a generic profile, where each position is represented by a line, and each piece of information is white space deliminated.

=head1 INHERITS

Profile.

=head1 METHODS

=head2 $obj->read($filehandle)

Reads in the profile contained in the file.

=cut

sub read {
	my ($self, $fh) = @_;
	while (<$fh>) {
		chomp;
		$self->add_pos(split);
	}
}

=head2 $obj->write($filehandle);

Writes WS seperated profile, with each position on each line.

=cut

sub write {
	my ($self, $fh) = @_;

	while ((my @data = $self->get_pos) > 1) {
		print $fh " ".join("  ", @data), "\n";
	}
}

1;
