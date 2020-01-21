package Profile::Jnet;

use strict;
use warnings;
use Carp;
use UNIVERSAL qw(isa);

use base qw(Profile);
use Utils qw(profile);

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";

	while (<$fh>) {
		chomp;
		$self->add_pos(split);
	}
}

=head2 $prof->jpred_profile(@Sequence) 

Creates a PSIBLAST like profile for Jpred.

=cut

sub jpred_profile {
	my ($self, @seqs) = @_;
	croak "Not passed Sequence objects" if grep { not isa $_, 'Sequence' } @seqs;
	$self->_check_seq_length(@seqs) or croak "Not passed sequences of equal length\n";

	my @profile = profile( map { join "", $_->seqs } @seqs );

	for (@profile) {
		$self->add_pos(@{$_});
	}
}

=for private

=head2 _check_seq_length(@Sequence);

Checks that we've been passed PSISEQ objects and that they are the same length. Returns undef if their not and warns, otherwise returns the length of the sequence.

=cut

sub _check_seq_length {
	undef = shift @_;

	my %lengths;
	for (@_) {
		$lengths{ $_->seq } = 1;
	}

	if (keys %lengths != 1) {
		warn "The sequences are of different lengths";
		return undef;
	}

	return (keys %lengths)[0];
}

1;
