package HMMER::Profile::Jnet;

use strict;
use warnings;
use Carp;

use base qw(HMMER::Profile Write);

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";

	while (my $line = <$fh>) {
		chomp $line;
		my @data = split / /, $line;
		croak "HMMER::Profile::Jnet: Wrong number of data items in ".$self->path." at line $." if @data != 24;
		$self->add_line(@data);
	}
}

sub jnet {
	my ($self) = @_;
	my @data;
	for ($self->get_line) {
		# This provides the same output as for hmm2profile
		push @data, [
			map {
				sprintf "%2.5f", 1 / (1 + (exp(-($_ / 100))));
			} @{$_}
		];
	}
	@data;
}

sub write {
	my ($self, $fh) = @_;

	#die "Sorry, I don't think you mean to use this function. If you do, remove this line";

	for ($self->jnet) {
		print $fh join(" ", @{$_}), "\n";
	}
}

*seq = *jnet;

1;

__END__

=head1 NAME

HMMER::Profile::Jnet - Read in the data output from HMMER::Profile::jnet()

=head1 DESCRIPTION

Reads the output of the HMMER::Profile::jnet() function.

=head1 METHODS

=head2 my $prof = HMMER::Profile::Jnet->new;

Create a new object.

=head2 $prof->read_file($path_to_file);

Read in the data.

=head2 my @data = $prof->seq

Returns an AoA of the numbers.

=head1 SEE ALSO

Packages Root, Read, Sequence and HMMER::Profile.

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>
