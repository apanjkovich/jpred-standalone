package HPM;

use strict;
use warnings;
use Carp;

use base qw(Exporter);

our @EXPORT_OK = qw(hydrophobic_moment);

=head1 NAME

HPM - module to calculate hydrophobic moments of a peptide sequence

=head1 $moment = hydrophobic_moment($angle, @sequence)

Calculate the hydrophobic moment (Eisenberg et al.) of a series of amino acids in @sequence for angle $angle in degrees. This is 100 for alpha helices and between 160 and 180.

An example helix is: RIIRRIIRRIRRIIRRII which has a maximum at 100 degrees.
An example sheet is: ALALALALAL, with a maximum at between 160-180 degrees.

See Eisenberg et al., PNAS, 1984, v81, p140-144 for more details.

=cut

# Hydrophobic moments from Eisenberg et al., PNAS, 1984, v81, p140.
my %moments = (
	I => 0.73,
	F => 0.61,
	V => 0.54,
	L => 0.53,
	W => 0.37,
	M => 0.26,
	A => 0.25,
	G => 0.16,
	C => 0.04,
	Y => 0.02,
	P => -0.07,
	T => -0.18,
	S => -0.26,
	H => -0.40,
	E => -0.62,
	N => -0.64,
	Q => -0.69,
	D => -0.72,
	K => -1.10,
	R => -1.76
);

# Hydrophobic moments from EMBOSS 2.9.0 hmoment program. Gives similar graphs
# to the above moments.
my %e_moments = (
	A => 0.62,
	B => -100,
	C => 0.29,
	D => -0.90,
	E => -0.74,
	F => 1.19,
	G => 0.48,
	H => -0.4,
	I => 1.38,
	J => -100,
	K => -1.5,
	L => 1.06,
	M => 0.64,
	N => -0.78,
	O => -100,
	P => 0.12,
	Q => -0.85,
	R => -2.53,
	S => -0.18,
	T => -0.05,
	U => -100,
	V => 1.08,
	W => 0.81,
	X => -100,
	Y => 0.26,
	Z => -100,
);

sub deg2rad { $_[0] and return $_[0] * (3.141593 / 180) }

sub hydrophobic_moment {
	my ($angle, @seq) = @_;
	my $tangle = $angle;

	my ($sum_sin, $sum_cos) = (0, 0);
	for (@seq) {
		$sum_sin += ($moments{ $_ } * sin(deg2rad $tangle));
		$sum_cos += ($moments{ $_ } * cos(deg2rad $tangle));
		$tangle = ($tangle + $angle) % 360;
	}
	return sqrt($sum_sin * $sum_sin + $sum_cos * $sum_cos) / @seq;
}
