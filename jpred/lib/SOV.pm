package SOV;

=head1 NAME

SOV - Parses output for CASP SOV program.

=head1 DESCRIPTION

Class for parsing SOV output.

=head1 METHODS

Inherits from Read and Root.

=cut

use base qw(Root Read);

=head2 q3()

Access q3 information. Returns SOV::Types object.

=head2 sov(), sov_0(), sov_50()

As for q3()

=cut

sub q3 {
	if ($_[1]) { $_[0]->{q3} = $_[1] }
	else { return defined $_[0]->{q3} ? $_[0]->{q3} : undef }
}

sub sov_0 {
	if ($_[1]) { $_[0]->{sov_0} = $_[1] }
	else { return defined $_[0]->{sov_0} ? $_[0]->{sov_0} : undef }
}

sub sov_50 {
	if ($_[1]) { $_[0]->{sov_50} = $_[1] }
	else { return defined $_[0]->{sov_50} ? $_[0]->{sov_50} : undef }
}

sub sov {
	if ($_[1]) { $_[0]->{sov} = @_[1] }
	else { return defined $_[0]->{sov} ? $_[0]->{sov} : undef }
}

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";
	local $_;

	# Get to the SOV and Q3 results
	while (<$fh>) { last if /^\s-{22}/ }

	while (<$fh>) {
		chomp;
		if (s/^\s*Q3\s*:\s*//) {
			$self->q3(to_struct(split / +/, $_))
		}
		elsif (s/^\s*SOV\s*:\s*//) {
			$self->sov(to_struct(split / +/, $_))
		}
		elsif (s/^\s*SOV.*0].*:\s*//) {
			$self->sov_0(to_struct(split / +/, $_))
		}
		elsif (s/^\s*SOV.*50%.*:\s*//) {
			$self->sov_50(to_struct(split / +/, $_))
		}
	}

}

sub to_struct ($$$$) {
	map { $_ > 1 ? $_ /= 100 : $_ } @_;
	my $new = SOV::Types->new(
		all => +shift,
		helix => +shift,
		sheet => +shift,
		coil => +shift
	);
}

=head1 SOV::Types

Object that stores prediction information

=head1 METHODS

=head2 all(), helix(), sheet(), coil()

Accessors for accuracy of different types of secondary structure.

=cut

use Class::Struct SOV::Types => [
	all => '$', 
	helix => '$',
	sheet => '$',
	coil => '$'
];

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>

=cut

1;
