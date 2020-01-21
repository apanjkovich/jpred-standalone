package Profile;

use strict;
use warnings;
use Carp;

use base qw(Root Read Write);

=head1 NAME

Profile - Base object for various types of profile

=head1 SYNOPSIS

  use Profile;

  my $prof = Profile->new;

=head1 DESCRIPTION

Basic methods for storing information sequence profiles. The model of this object is for each sequence position to have an array of data associated with it.

=head1 METHODS

Inherits from Root, Read and Write.

=head2 $prof->add_pos(@data)

Add data to the end position of the profile.

=cut

sub add_pos {
	my $self = shift;
	@_ or croak "No data passed to ".__PACKAGE__."\n";
	push @{ $self->{__PACKAGE__."lines"} }, pack "d*", @_;
}

sub get_aoa {
	my ($self) = @_;
	map { [ $self->get_pos ] } 0.. $self->get_size - 1;
}

=head2 $prof->add_line(@data)

Alias for add_pos().

=cut

*add_line = *add_pos;

=head2 @data $prof->get_pos

Itterator for getting all the positions in a profile. Returns the same information as get_num_pos, or undef when it reaches the end of the profile. When this happens, a new call starts at the begining of the profile.

=cut

sub get_pos {
	my ($self) = @_;
	$self->{__PACKAGE__."counter"} ||= 0;

	if ((my @foo = $self->get_num_pos( $self->{__PACKAGE__."counter"}++ )) > 0) {
		return @foo;
	}
	else {
		$self->{__PACKAGE__."counter"} = 0;
		return undef;
	}
}

=head2 @data = $prof->get_num_pos($position)

Access the profile information for a particular position in the profile.

=cut

sub get_num_pos {
	my ($self, $pos) = @_;

	confess "get_num_pos didn't receive position" unless defined $pos;

	#use Data::Dumper;
	#print $pos, "\n";
	#print Dumper unpack "d*", @{ $self->{__PACKAGE__."lines"}->[$pos]};

	confess "No positions present" unless exists $self->{__PACKAGE__."lines"};
	return undef unless defined $self->{__PACKAGE__."lines"}->[$pos];
	return unpack "d*", $self->{__PACKAGE__."lines"}->[$pos];
}

=head2 $prof->get_size

Returns the number of positions in the profile.

=cut

sub get_size {
	my ($self) = @_;
	return @{ $self->{__PACKAGE__."lines"} };
}

=head2 $prof->get_line($position)

Alias for get_num_pos().

=cut

*get_line = *get_num_pos;

1;
