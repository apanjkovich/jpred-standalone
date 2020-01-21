package Common;
use strict;
use warnings;
use Carp;

sub path {
	my ($self, $path) = @_;
	if (defined $path) { $self->{__PACKAGE__."path"} = $path }
	else {
		if (defined $self->{__PACKAGE__."path"}) {
			return $self->{__PACKAGE__."path"}
		}
		else { croak "path() is not defined" }
	}
}

1;
__END__

=head1 NAME

Common

=head1 DESCRIPTION

Methods that might be useful to any other object, but not nessecery.

=head1 METHODS

=head2 $obj->path($path)

Get/Setter for the path of a filename.
