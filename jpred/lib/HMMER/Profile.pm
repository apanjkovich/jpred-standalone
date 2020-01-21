package HMMER::Profile;

use strict;
use warnings;
use Carp;
use base qw(Root Read Write);

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";

	my ($flag, @data) = 0;
	while (my $line = <$fh>) {
		$flag = 1, next if $line =~ /^Cons/;
		next unless $flag;
		next if $line =~ /^! \d+/;
		last if $line =~ /^ \*/;

		chomp $line;
		$line =~ s/^\s*//g;
		#$self->seq($self->seq, [ (split / +/, $line)[1..24] ]);

		$self->add_line((split /\s+/, $line)[1..24]);
	}
}

sub write {
	my ($self, $fh) = @_;
	for ($self->get_line) {
		print join(" ", @{ $_}) , "\n";
		exit;
		#print join(" ", map { @{ $_ }), "\n";
		print $fh join(" ", map { sprintf "%.5f", $_ } @{ $_ }), "\n";
	}
}

sub add_line {
	my $self = shift;
	@_ or croak "No data passed to HMMER::Profile::add_line";
	push @{ $self->{__PACKAGE__."lines"} }, pack "d*", @_;
}

sub get_line {
	my ($self, $line) = @_;

	if (defined $line) { return [ unpack "d*", ${$self->{__PACKAGE__."lines"}}[$line] ] }
	else {
		return map { [ unpack "d*", $_ ] } @{$self->{__PACKAGE__."lines"}}
	}
}

1;
__END__

=head1 NAME

HMMER::Profile - Convert the output of hmmconvert to a profile for Jnet

=head1 EXAMPLE

system("hmmconvert -p hmmer.model hmmer.prf");

my $prof = HMMER::Profile->new;
$prof->read_file("hmmer.prf");

my @data = $prof->jnet
print join(" ", @{$_}), "\n" for @data;

=head1 DESCRIPTION

Takes the output of the HMMER program hmmconvert with the -p option and calculates the profile used by Jpred to calculate secondary structure.

=head1 METHODS

=head2 my $prof = HMMER::Profile->new;

Create a new object.

=head2 $prof->read_file("path_to_hmmer_model_converted_to_prf");

Read a HMMER model that's been converted to PRF format via the HMMER hmmconvert program with the -p option.

=head2 my @data = $prof->seq

Returns an array of array refs of the HMMER numbers.

=head2 my @data = $prof->jnet

Returns an array of array refs of frequences for use in Jnet.

=head1 SEE ALSO

Packages Root, Read and Sequence.

=head1 BUGS

The whole set of profile modules is a bit of an abortion now, as there is no standard interface and the methods do different things for different objects. Converting the different representations is a nightmare because of this.

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>
