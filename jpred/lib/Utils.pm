package Utils;

use strict;
use warnings;
use Carp;
use File::Temp qw(tempfile);
use File::Find qw(find);

use base qw(Exporter);

our @EXPORT_OK = qw(xsystem profile reduce_dssp conf jury find_jury read_file_list concise_record seq2int int2seq abs_solv_acc rel_solv_acc array_shuffle array_shuffle_in_place array_split $split_resid sort_resid find_files);
push @EXPORT_OK, map { "reduce_dssp_$_" } qw(a b c jpred);

# Reduce eight state DSSP definition to three states
sub reduce_dssp ($;&) {
	my ($seq, $code_ref) = @_;

	$code_ref ||= \&reduce_dssp_jpred;
	return $code_ref->($seq);
}

# reduce_dssp_[abc] are the methods mentioned in the Jpred
# paper
sub reduce_dssp_a ($) {
	my ($sec_string) = @_;

	$sec_string =~ tr/EBGH/EEHH/;

	$sec_string =~ tr/EH/-/c;
	return $sec_string;
}

sub reduce_dssp_b ($) {
	my ($sec_string) = @_;

	$sec_string =~ tr/EH/-/c;
	$sec_string =~ s/(?<!E)EE(?!E)/--/g;
	$sec_string =~ s/(?<!H)HHHH(?!H)/----/g;

	$sec_string =~ tr/EH/-/c;
	return $sec_string;
}

sub reduce_dssp_c ($) {
	my ($sec_string) = @_;

	$sec_string =~ s/GGGHHHH/HHHHHHH/g;
	$sec_string =~ tr/B/-/;
	$sec_string =~ s/GGG/---/g;

	$sec_string =~ tr/EH/-/c;
	return $sec_string;
}

=head2 reduce_dssp_jpred()

# This is the method actually used in the q3anal.version2
# program.
# q3anal{,_dev} convert G to H.

=cut

sub reduce_dssp_jpred ($) {
	my ($sec_string) = @_;

	$sec_string =~ tr/ST_bGIC? /-/;
	$sec_string =~ tr/B/E/;
	$sec_string =~ tr/EH/-/c;

	return $sec_string;
}

=head2 conf()

# Select the subset of a prediction where the confidence is greater than some
# limit.
# Pass at least three scalars:
# First is a string containing a list of integers between 0 and 9 which
# correspond to the confidence at that position.
# Second is a lower limit for the confidence.
# Other arguments are strings of the sequence to be selected.

=cut

sub conf ($$$;@) {
	my ($conf, $limit, @seqs) = @_;

	croak "Sequences of different length" if grep { length $_ ne length $conf } @seqs;

	for my $pos (reverse 0..length($conf) - 1) {
		if (substr($conf, $pos, 1) >= $limit) {
			for (@seqs, $conf) {
				$_ = substr($_, 0, $pos).substr($_, $pos)
			}
		}
	}

	return @seqs;
}

=head2 jury();

Find the positions where there is jury agreement
First argument is the jury sequence, the rest are sequences to be subselected.

=cut

sub jury ($$;@) {
	my ($jury, @seqs) = @_;

	croak "Sequences of different length" if grep { length $_ != length $jury } @seqs;

	# All positions are jury
	if ($jury  =~ y/*// == length $jury) {
		return @seqs;
	}
	# Goes through sequences and removes those positions that are not jury positions.
	for my $pos (reverse 0..length($jury)- 1) {
		if (substr($jury, $pos, 1) eq '*') {
			$_ = substr($_, 0, $pos).substr($_, $pos + 1) for @seqs;
			$_ = substr($_, 0, $pos).substr($_, $pos + 1) for $jury;
		}
	}

	return @seqs;
}

=head2 find_jury(@seqs)

Find those positions in a prediction that are in a jury position (those positions where the predictions agree).

Pass an array of sequences (represented as strings). Returns a string with the jury position represented by a space and non-jury positions as "*".

=cut

sub find_jury (@) {
	my (@seqs) = @_;
	
	my $length = length $seqs[0];
	croak "Sequences of different length" if grep { $length != length $_ } @seqs;

	my $jury;
	for my $pos (0..$length - 1) {
		# Are all of the positions the same?
		if (keys %{ { map { substr($_, $pos, 1), undef } @seqs } } == 1) {
			$jury .= " "
		}
		else {
			$jury .= "*"
		}
	}

	return $jury;
}

=head2 @AoA = read_file_list($path)

Reads in a file from the $path of the format:

  file1a file2a
  file1b file2b
  file1c file2c
  file1d file2d
  file1e file2e

Returns an array of arrays of the list of files. For the above file, this would be:

  [
    [ "file1a", "file2a" ],
    [ "file1b", "file2b" ],
    [ "file1c", "file2c" ],
    [ "file1d", "file2d" ],
    [ "file1e", "file2e" ]
  ]

=cut

sub read_file_list ($) {
	my ($file) = @_;
	
	local ($/, $_) = "\n";

	open my $fh, $file or croak "Can't open file $file";

	my @files;
	while (<$fh>) {
		chomp;
		push @files, [ split ];
	}
	return @files
}

=head2 @AoA = profile(qw(PROTEIN MSA----))

Pass an array of proteins sequences represented as strings of one letter residues codes, returns an array of arrays of the frequences of each residue.

This is calculated using all of the sequences in the alignment, and doesn't count gaps, 'X' or 'Z'.

=cut

# Does a profile on a sequence
sub profile (@) {
	my (@seqs) = @_;
	my @results;

	# Check that all the sequences are the same length
	my $length = length $seqs[0];
	croak "Not all sequences are the same length" if grep { length $_ != $length } @seqs;

	# Convert residues to integers
	my @ar = map { [ seq2int(split //, $_) ] } @seqs;

	# Find out how many of each type of residue occur at a position and create
	# the profile
	for my $i (0..$length - 1) { # for each position
		# The number of elements should be one larger than the max size in
		# seq2int
		my @countup = (0) x 20;

		$ar[$_][$i] < 20 && $countup[ $ar[$_][$i] ]++ for 0..$#ar; # for each sequence

		for (0..$#ar) {
			$ar[$_][$i] < 20 && $countup[ $ar[$_][$i] ]++
		}

		my $total = 0;
		$total += $_ for @countup;
		#$total += $countup[$_] for 0..$#countup;

		push @results, [
			map {
				# Check $total for div/0
#				sprintf "%2.f", ($total ? $countup[$_] / $total * 10 : 0)
#			} 0..$#countup
				sprintf "%2.f", ($total ? $_ / $total * 10 : 0)
			} @countup
		];
	}

	return @results;
}

=head2 @integers = seq2int(@residues)

Converts a sequence into integer values. @residues should be an array of characters of the one letter amino acids codes.

=head2 @residues = int2seq(@integers)

Converts an array of integers into one letter amino acids codes produced by seq2int().

=cut

{
	# This values should be as seq2int() in jnet.c
	my (%seq2int, %int2seq);
	@seq2int{split //, 'ARNDCQEGHILKMFPSTWYVBZX.-'} = (0..23, 23);
	$seq2int{U} = $seq2int{C};
	%int2seq = reverse %seq2int;

	sub seq2int (@) {
		map {
			exists $seq2int{uc $_} ?
				$seq2int{uc $_} :
				croak "Residue '$_' not recognised"
		} @_
	}

	sub int2seq (@) {
		map {
			exists $int2seq{$_} ?
				$int2seq{$_} :
				croak "Residue '$_' not recognised"
		} @_
	}
}

=head2 xsystem($system)

Wraps the perl system() function. Returns undef if the command in $system doesn't work, perhaps, look at the code.

=cut

sub xsystem ($) {
	my $status = system(@_);
	if ($status == -1) {
		carp "Failed to run command '@_': $!";
		return;
	}
	elsif ($? & 127) {
		printf "child died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
		return;
	}
	else {
		#printf "child exited with value %d\n", $? >> 8
		return $? >> 8;
	}
}

=head2 $concise = concise_record($title, @data)

Simple function to give a line in a concise file. Pass the title of the concise file, and the data that you want in the record. Returns a string in the concise format with a newline.

=cut

sub concise_record ($@) {
	my ($title, @items) = @_;
	return "$title:".join(",", @items)."\n";
}

{
	my %data = (
		'A' => '118', 'B' => '162', 'C' => '146', 'D' => '159',
		'E' => '186', 'F' => '223', 'G' => '88', 'H' => '203',                          'I' => '181', 'K' => '226', 'L' => '193', 'M' => '204',
		'N' => '166', 'P' => '147', 'Q' => '193', 'R' => '256',
		'S' => '130', 'T' => '153', 'V' => '165', 'W' => '266',
		'X' => '200', 'Y' => '237', 'Z' => '189', 'c' => '146'
	);

=head2 $solv = rel_solv_acc($residue, $accesibility);

Pass the residue and the accessiblilty of the residue, and the relative solvent accesibility of the residue will be returned.

=cut

	sub rel_solv_acc ($$) {
		my ($residue, $acc) = @_;
		return unless $data{uc $residue};
		return $acc / $data{uc $residue};
	}

=head2 $solv = abs_solv_acc($residue, $accesibility);

Pass the residue and the accessiblilty of the residue, and the absolute solvent accesibility of the residue will be returned.

=cut

	sub abs_solv_acc ($$) {
		my ($residue, $acc) = @_;
		return unless $data{uc $residue};
		return $data{uc $residue} * $acc;
	}
}

=head2 @shuffled_data = array_shuffle(@data)

Randomly shuffles an array.

=cut

sub array_shuffle (@) {
	my (@data) = @_;
	for (0..$#data) { 
		my ($foo, $bar) = (int(rand $#data), int(rand $#data));
		@data[$foo, $bar] = @data[$bar, $foo];
	}
	return @data;
}

=head2 array_shuffle_in_place(@data)

Randomly shuffle an array in place.

=cut

sub array_shuffle_in_place (@) {
	for (0..$#_) {
		my ($foo, $bar) = (int(rand $#_), int(rand $#_));
		@_[$foo, $bar] = @_[$bar, $foo];
	}
}

=head2 @AoA = array_split($size, @data)

Splits an array into $size sets of data returned in an AoA.

=cut

sub array_split ($@) {
	my ($size, @array) = @_;
	my ($i, @temp) = 0;
	while (@array) { push @{ $temp[$i++ % $size] }, pop @array }
	return @temp;
}


=head2 $split_resid = qr/(-?\d+)([[:alpha:]])/;

Regular expression for dividing PDB residue offsets into the offset and letter components.

=cut

our $split_resid = qr/(-?\d+)([[:alpha:]])?/;

=head2 sort_resid

A subroutine for the sorting of PDB residue offsets, allows for the correct sorting of IDs such as "1A".

=cut

{
	no warnings;
	sub sort_resid {
		(my ($a_off, $a_id) = $a =~ $split_resid);
		(my ($b_off, $b_id) = $b =~ $split_resid);

		$a_off <=> $b_off || $a_id cmp $b_id;
	}
}

=head2 @files = find_files($dir)

Find all files under $dir.

=cut

sub find_files ($) {
    my ($dir) = @_;
    my @files;

    find(
        sub {
            push @files, $File::Find::dir."/".$_ if -e $_;
        },
        $dir
    );

    return @files;
}

1;
