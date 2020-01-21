package BLC;

use strict;
use warnings;
use Carp;

use constant {
	ID => 0,
	TITLE => 1,
	SEQ => 2
};

=head2 my $blc = new BLC;

=cut

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = { 
		_itteration => 0,
		_max_itteration => 0,
	};
	return bless $self, $class;
}

=head2 my $blc->read_file($file)

Read in a BLC file.

=cut

sub read_file {
	my @seqs;
	my $self = shift;
	my ($fn) = @_;

	open BLC, $fn or croak "$fn: $!\n";

	while (<BLC>) {
		chomp;
		if (s/^>//) {
			s/\s*$//g;
			my ($id, $title) = split /\s+/, $_, 2;
			$title = '' unless $title;
			push @seqs, [ $id, $title ];
		}

		# This regex copes with odd variations in the start of
		# the iterations line that marks the start of sequences
		if (/^\s*\*\s*[Ii]teration:?\s*(\d+)\s*$/) {
			# The start position of the sequences is the same
			# as the offset of the asterix from the start of
			# the line
			my $start = index $_, '*', 0;
			my $iter = $1;
			croak "Iteration not greater than 0 in BLC file $fn" unless $iter > 0;

			while (<BLC>) {
				chomp;
				last if /^\s{$start}\*\s*$/;
				my $line = substr $_, $start, @seqs;

				foreach (0..$#seqs) {
					# Not just $iter, as we need to
					# leave room for the title
					# and header
					$seqs[$_]->[SEQ + $iter - 1] .= substr($line, $_, 1);
				}
			}
		}
	}
	close BLC;
	croak "No sequences found in BLC file $fn" unless @seqs;

	foreach (@seqs) {
		my ($id, $title, @seqs) = @{$_};
		$title = '' unless defined $title;
		$id = '' unless defined $id;
		$self->set_sequence($id, $title, @seqs);
	}
}

=head2 $blc->set_sequence($id, $title, @seq)

Add a BLC file to the object of $id, $title and @sequence, one sequence per iteration.

=cut

sub set_sequence {
	my $self = shift;
	my ($id, $title, @data) = @_;
	push @{$self->{_seqs}}, [ $id, $title, @data ];
}

=head2 $blc->get_sequence($number)

Returns a list of the ($id, $title, @sequences) where each member of @sequences is from the itterations, from first to final. Defaults to the first sequences.

=cut

sub get_sequence {
	my ($self, $number) = @_;
	if (defined $number and $number > $self->get_num_seqs) {
		croak "You're trying to retrive a sequence past than the end of the BLC file in get_sequence($number)";
	}
	elsif (defined $number and $self->get_num_seqs + $number < 0) {
		croak "You're trying to retrive a sequence before the begining of the BLC file in get_sequence($number)";
	}
	$number = 0 unless defined $number;

	return @{${$self->{_seqs}}[$number]};
}

=head2 $blc->get_num_seqs()

Returns the number of sequences in the BLC file.

=cut

sub get_num_seqs {
	my ($self) = @_;
	return $#{$self->{_seqs}};
}

=head2 $blc->get_sequences($iteration)

Returns all of the sequences in a block file for a particular itteration, in the same order as they occured in the block file. If left undefined, it will return the sequences from the first itteration.

=cut

sub get_sequences {
	my ($self, $iteration) = @_;
	$iteration = 0 unless $iteration and $iteration > 0;
	return map { $_->[SEQ + $iteration] } @{$self->{_seqs}};
}

=head2 $blc->get_seq_ids($number)

Returns the ID for the $number sequence to occur in the file, if left undefined it'll return all of the IDs.

=cut

sub get_seq_ids {
	my ($self, $number) = @_;
	if (defined $number) {
		return ${$self->{_seqs}[$number]}[ID];
	}
	else {
		return map { $_->[ID] } @{$self->{_seqs}};
	}
}

=head2 $blc->get_seq_titles($number)

Returns the titles for the number sequence to occur in the file, if left undefined it'll return all of the titles.

=cut

sub get_seq_titles {
	my ($self, $number) = @_;
	if (defined $number) {
		return ${$self->{_seqs}[$number]}[TITLE];
	}
	else {
		return map { $_->[TITLE] } @{$self->{_seqs}};
	}
}

=head2 $blc->print_blc($fh);

This will print the BLC file object to the filehandle if given, otherwise to STDOUT.

=cut

sub print_blc {
	my ($self, $fh) = @_;

	if ($fh) { *OUT = $fh }
	else { *OUT = *STDOUT }

	# Print the IDs
	print OUT ">$_\n" foreach $self->get_seq_ids;

	# Get the sequences
	#my @sequences = $self->get_sequences
	my $i = 0;
	while (1) {
		my @sequences = $self->get_sequences($i);
		last unless defined $sequences[0];
		print OUT "* iteration ".($i + 1)."\n";
		foreach my $j (0..length($sequences[0]) -1) {
			foreach (@sequences) {
				print OUT substr $_, $j, 1;
			}
			print OUT "\n";
		}
		print OUT "*\n";
		$i++;
	} 
}

=head2 $blc->print_fasta($fh)

Prints the BLC file out in FASTA format, each sequence is 72 characters wide.

=cut

sub print_fasta {
	my ($self, $fh) = @_;

	if ($fh) { *OUT = $fh }
	else { *OUT = *STDOUT }

	my @ids = $self->get_seq_ids;
	my @sequences = $self->get_sequences;

	croak "Different number of sequences and IDs\n" unless @ids == @sequences;
	foreach (0..$#ids) {
		print OUT ">$ids[$_]\n";
		$sequences[$_] =~ s/(.{72})/$1\n/g;
		print OUT "$sequences[$_]\n";
	}
}

=head2 $blc->next_itteration;

=cut

sub next_itteration {
	my ($self) = @_;
	$self->itteration($self->itteration + 1);
}

=head2 $blc->next_itteration;

=cut

sub max_itteration {
	my ($self) = @_;
	return $self->{_max_itteration};
}

=head2 $blc->itteration($number)

If $number is defined, sets the itteration to $number, otherwise returns the number of itterations.

=cut

sub itteration {
	my ($self, $itteration) = @_;
	if (defined $itteration) {
		if ($itteration < 1) {
			return undef;
		}
		#if ($itteration > $self->{_max_itteration};
		#$self->{_itteration} = $itteration;
	}
	else {
		return $self->{_itteration};
	}
}

1;
