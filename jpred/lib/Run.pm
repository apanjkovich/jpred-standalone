package Run;

use strict;
use warnings;
use Carp;

use Exporter;
use POSIX qw(WIFEXITED WEXITSTATUS WIFSIGNALED WTERMSIG);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(check);

sub check {
	my ($prog, $status) = @_;

	if ($status == 0) {
		return 1;
	}
	elsif ($status == -1) {
		croak "$prog executable not found\n";
	}
	elsif (WIFEXITED($status) and WEXITSTATUS($status)) {
		croak "$prog exited with status ".WEXITSTATUS($status)."\n";
	}
	elsif (WIFSIGNALED($status)) {
		croak "$prog halted by external signal ".WTERMSIG($status)."\n";
	}
	else {
		croak "$prog suffered from a random pantwetting event";
	}
}

1;
