package Profile::Scanps::Result;

use strict;
use warnings;
use Carp;
use base qw(Profile::Generic);
use Scanps::Result;

sub read {
	my ($self, $fh) = @_;
	my $scanps = Scanps::Result->new($fh);

	# Get third, or last iteration, which ever is smaller
	my $it = $scanps->iterations - 1;
	$it > 2 and $it = 2; # iterations is zero based
	my @positions = $scanps->profile($it);

	for (@positions) {
		my (undef, @data) = split /\s+/, $_;
		$self->add_pos(@data[0..22]);
	}
}

sub write {
	my ($self, $fh) = @_;

	while ((my @data = $self->get_pos) > 1) {
		print $fh map({ sprintf "%2.5f ", 1 / (1 + exp(-$_/100)) } @data), "\n";
		#print $fh join(" ", map  $_ / 100 } @data), "\n";
		#print $fh join(" ", @data), "\n";
	}
}

1;

__END__

=head1 NAME

Profile::Scanps::Result - Reads a profile from a Scanps result file

=head1 DESCRIPTION

Reads the profile that can be provided at the end of a Scanps file.

=head1 INHERITANCE

Inherits from Profile and Generic modules.

=head1 METHODS

=head2 read()

=cut
