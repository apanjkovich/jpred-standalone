package Quality;

use strict;
use warnings;
use Carp;
#use Hash::Util qw(lock_keys);
use POSIX qw(floor);
use File::Temp qw(tempfile);

use Paths qw($sov);
use SOV;

use base qw(Exporter);
our @EXPORT_OK = qw(q3 sov sov_wrapper matthews);
our %EXPORT_TAGS = (all => [ @EXPORT_OK ]);

=head1 NAME 

Quality.pm - Module for assessing the quality of a secondary structure prediction.

=head1 SYNOPSIS

 use Quality.pm qw(:all)

 my $pred_seq = "HHHHEEEELLLL";
 my $obs_seq  = "HEHHEEEELELL";

 print q3($pred_seq, $obs_seq);  # Should print 0.8333

 print sov($pred_seq, $obs_seq); # Should print 

 print sov_wrapper($pred_seq, $obs_seq);

=head1 DESCRIPTION

A collection of functions for calculating the accuracy of a particular secondary structure predicion. Provided are functions for calculating Q3, Segment overlap and the Matthews correlation.

=head2 $q3_score = q3($predicted_sequence, $observed_sequence)

Both sequences should be scalars of equal length.

Passing an optional third argument (a single character) indicates that you don't want the Q3 score but the Q-index score for a particular state.

=cut

sub q3 ($$;$) {
	my ($pred, $obs, $i) = @_;

	croak "Undefined parameter" if grep { not defined $_ } $pred, $obs;

	my @pred = split //, $pred;
	my @obs = split //, $obs;

	croak "Predicted sequence and observed sequence are not the same length" unless @pred == @obs;
	croak "Sequences are of zero length" unless @pred;

	if ($i) {
		my $correct = grep { $pred[$_] eq $i and $pred[$_] eq $obs[$_]	} 0..$#pred;
		my $number = grep { $_ eq $i } @obs;
		return $number ? $correct / $number : 1;
	}
	else {
		my $correct = grep { $pred[$_] eq $obs[$_] } 0..$#pred;
		return $correct / @pred;
	}
}

=head1 $sov = sov($pred, $obs);

A pure perl implementation of the SOV algorithim as found in the C SOV program
from CASP. Not finished.

=cut

# Used in sov()
sub max_min {
	my ($one, $two) = @_;
	return $one > $two ? ($one, $two) : ($two, $one);
}

sub sov ($$;$) {
	my ($pred, $obs, $state) = @_;

	die "This function has not been error checked yet";

	croak "Undefined parameter" if grep { not defined $_ } $pred, $obs;

	my @pred = split //, $pred;
	my @obs = split //, $obs;

	croak "Predicted sequence and observed sequence are not the same length" unless @pred == @obs;
	croak "Sequences are of zero length" unless @pred;

	my (%seg_one, %seg_two);
	#lock_keys %seg_one, qw(start state end length);
	#lock_keys %seg_two, qw(start state end length);
	my ($sov_method, $sov_delta, $sov_delta_s) = (1, 1, 0.5);

	my $number = $state ? grep { $state eq $_ } 0..$#obs : @obs;
	return 1 unless $number;

	my ($s, $n, $i) = (0, 0, 0);
	while ($i < $#pred) {

		($seg_one{start}, $seg_one{state}) = ($i, $obs[$i]);
		$i++ while $obs[$i] eq $seg_one{state} and $i < $#pred;
		($seg_one{end}, $seg_one{length}) = ($i - 1, $i - $seg_one{start});

		my ($multiple, $k) = (0, 0);
		while ($k < $#pred) {

			($seg_two{start}, $seg_two{state}) = ($k, $pred[$k]);
			$k++ while $pred[$k] eq $seg_two{state} and $k < $#pred;
			($seg_two{end}, $seg_two{length}) = ($k - 1, $k - $seg_two{start});

			if ($state ? $seg_one{state} eq $state : 1) {
				if (
					$seg_one{state} eq $seg_two{state} and
					$seg_two{end}   >= $seg_one{start} and
					$seg_two{start} <= $seg_one{start}
				) {
					$n += $seg_one{length} if $multiple > 0 and $sov_method == 1;

					my ($j1, $j2) = max_min $seg_one{start}, $seg_two{start};
					my ($k1, $k2) = reverse max_min $seg_one{end}, $seg_two{end};

					my ($minov, $maxov) = ($k1 - $j1 + 1, $k2 - $j2 + 1);
					my ($d1, $d2) = map { floor $_ * $sov_delta_s } $seg_one{length}, $seg_two{length};

					my $d;
					if ($d1 > $d2) { $d = $d2 }
					elsif ($d1 <= $d2 or $sov_method == 0) { $d = $d1 }

					if ($d > $minov) { $d = $minov }
					if ($d > $maxov - $minov) { $d = $maxov - $minov }

					my $x = ($minov + $sov_delta * $d) * $seg_one{length};

					if ($maxov > 0) { $s += $x / $maxov }
					else { carp "Negative maxov\n" }
				}
			}
		}
	}

	return $s / $number;
}

=head1 $sov = sov_wrapper($aa, $pred, $obs);

This is a wrapper to the CASP SOV C program.

All three arguments are required, the first is the amino acid sequence, the
second is the predicted sequence, the third is the observed sequence.

A object of class SOV will be returned on success.

=cut

sub sov_wrapper ($$$) {
	my ($seq, $pred, $obs) = @_;

	croak "Sequences of different length" if grep { length $_ != length $seq } $obs, $pred;

	map { y/-/C/ } $obs, $pred;

	my $file = "AA  OSEC PSEC\n";
	$file .= join "\n", map {
		substr($obs, $_, 1).'   '.
		substr($obs, $_, 1).'    '.
		substr($pred, $_, 1)
	} 0..length $obs;

	my $sovres = SOV->new;
	{
		my ($fh, $fn) = tempfile;
		print $fh $file;
		close $fh;

		local $/ = undef;
		my $pid = open my $rdr, "$sov $fn|" or die $!;

		$sovres->read($rdr);
		close $rdr;
		unlink $fn;
	}

	return $sovres;
}

=head1 $matthews = matthews($pred, $obs)

Calculates the Matthews coffeicent of a predicted secondary structure.

=cut

sub matthews ($$;$) {
	my ($pred, $obs, $i) = @_;

	croak "Undefined parameter" if grep { not defined $_ } $pred, $obs, $i;

	my @pred = split //, $pred;
	my @obs = split //, $obs;

	croak "Predicted sequence and observed sequence are not the same length" unless @pred == @obs;
	croak "Sequences are of zero length" unless @pred;

	my ($p, $n, $o, $u) = (0, 0, 0, 0);
	for (0..$#pred) {

		# Correct prediction
		if ($pred[$_] eq $obs[$_]) {
			# True positive
			if ($pred[$_] eq $i) { $p++ }
			# True negative
			else { $n++ }
		}

		# Incorrect prediction
		else {
			# False positive
			if ($pred[$_] eq $i) { $o++ }
			# False negative
			else { $u++ }
		}
	}

	return ( ($p * $n) - ($u * $o) ) /
		sqrt( ($n + $u) * ($n + $o) * ($p + $u) * ($p + $o) );
}

=head1 SEE ALSO

http://predictioncenter.llnl.gov/casp3/results/ab-measures.html

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>

=cut

1;
