package PSIBLAST::PSSM::Jnet;

use strict;
use warnings;
use Carp;

use base qw(PSIBLAST::PSSM);

sub read {
	my ($self, $fh) = @_;
	local $/ = "\n";

	while (<$fh>) {
		chomp;
		$self->add_pos(split);
	}
}

1;
