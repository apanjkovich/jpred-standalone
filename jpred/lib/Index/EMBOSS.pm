package Index::EMBOSS;

use strict;
use warnings;
use Carp;

use POSIX qw(WIFEXITED WEXITSTATUS WIFSIGNALED WTERMSIG);
use IPC::Open3;

use base qw(Root);

use FASTA::File;

sub read_index { 1 }

sub get_sequence {
	my ($self, $key) = @_;
	croak "No value for get_sequence" unless $key;

	my @cmd = split / /, "seqret -filter $key";

	my $pid = open3(undef, \*RD, \*ERR, @cmd);

	my $seqs = FASTA::File->new(read => \*RD);
	my @err = <ERR>;

	pop @err;
	pop @err;

	close RD; close ERR;
	waitpid $pid, 0;
	
	# Everything was okay...
	if (WIFEXITED($?) and not WEXITSTATUS($?)) { return $seqs }
	# Non-zero exit
	elsif (WIFEXITED($?) and WEXITSTATUS($?)) {
		carp "seqret had a problem: $?; $!";
		carp @err;
	}
	# Was it stopped by an external program
	elsif (WIFSIGNALED($?)) {
		carp "seqret halted by external signal ".WTERMSIG($?)
	}
	else {
		carp "seqret suffered from a random pantwetting event"
	}

	return undef;
}

1;
