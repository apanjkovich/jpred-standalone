package PSIBLAST;

use strict;
use warnings;
use Carp;
use IO::String;

use base qw(Root Read);

=head1 NAME

PSIBLAST - Yet Another PSIBLAST Parser

=head1 SYNOPSIS

  use PSIBLAST;

  $psi = PSIBLAST->new;
  $psi->read_file("psiblast.output");
  $psi->get_all;

=head1 DESCRIPTION

A module to parse PSIBLAST output. It only grabs the last itteration, and there are simple methods to retrieve the ids of the sequences, the aligments and the start positions of the alignments.

Now gets the scores for the last iteration as well.

=head1 METHODS

=head2 $psi->read(\*FH)

Reads a PSIBLAST file from a filehandle.

=cut

sub read {
	my ($self, $fh) = @_;

	croak "No filehandle passed to method read" unless ref $fh eq 'GLOB';

	# Make sure that $/ is a defined value
	local $/ = "\n";

	$self->_blastpgp_parse($fh);
}

sub _blastpgp_parse {
	my ($self, $fh) = @_;

	local $_;
	my $version = <$fh>;
	my $pos;

	#die "Wrong version of BLASTP" if $version !~ /BLASTP 2.2.6 \[Apr-09-2003\]/;

	# Find the position of the last itteration
	while (<$fh>) {
		<$fh>, $pos = tell $fh if /^Sequences used in model and found again:/
	}

	# and make sure we found it...
	unless ($pos) { $self->{psi} = undef, return }
	seek $fh, $pos, 0;

	# Now read in the last itteration
	# @alignments holds the lines containing the aligment
	# @order is a list of the IDs
	# $flag indicates that the ID's have been collected
	#
	# All of this has to be list based as there may be multiple local
	# alignments against the same sequence
	my (@alignments, @order, $flag);

	while (<$fh>) {
		# Have we reached the end of the alignment
		last if /^\s*Database: /;

		# Skip babble
		next if /^Sequences not found previously or not previously below threshold:/;
		#next if /^\s*$/;

		chomp;
		# Capture E scores and check to see if we've reached the start of the alignment
		unless (/^QUERY\s*/ or @alignments) {
			next if /^$/;
			my ($id, $bit, $e) = unpack "A70A3A*", $_;
			($id) = (split /\s+/, $id)[0];
			s/\s*//g for $bit, $e;

			# Store the scores
			$self->{$id}{bit} = $bit;
			$self->{$id}{evalue} = $e;
			next;
		}

		# Have we reached the end of the first block of the
		# alignment
		$flag = 1, next if /^$/;

		# Add IDs if we're still in the first block
		push @order, (split)[0] unless $flag;
		# Add alignment lines
		push @alignments, $_;
	}
	
	$self->size(scalar @order);

	# Add sequences and start positions to self 
	for (0..$#alignments) {
		my $i = $_ % @order;
		my @fields = split ' ', $alignments[$_], 4;

		# blastpgp output allways has a ID at the begining of the line, but can
		# have a variable number of fields after that. e.g.:
# $seqid $start $seq                                                         $end
# O24727        ------------------------------------------------------------
# O24727   0    ------------------------------------------------------------
# O24727   26   -Y--A---A-----L-----R----S-------L---------G-------P----V--- 35

		if (@fields == 4 or @fields == 3) {
			$self->{psi}{$i}{seq} .= $fields[2];
			$self->{psi}{$i}{start} = $fields[1]
				unless defined $self->{psi}{$i}{start};
		}
		elsif (@fields == 2) { $self->{psi}{$i}{seq} .= $fields[1] }
		else {
			croak "Fatal error! Wrong number of fields in BLAST alignment:\n$alignments[$_]\n"
		}
	}
	
	# Add IDs
	for (0..$#order) {
		$self->{psi}{$_}{id} = $order[$_];
	}

	1;
}

=head2 @ids = $psi->get_ids

The IDs that were in the last iteration in the order they appeared.

=cut

sub get_ids {
	my ($self) = @_;
	#return map { $self->{psi}{$_}{id} } sort { $a <=> $b } keys %{$self->{psi}}
	return map { $self->{psi}{$_}{id} } 0..$self->size - 1;
}

=head2 @alignments = $psi->get_alignments

The alignment from the last iteration in the same order as they appeared.

=cut

sub get_alignments {
	my ($self) = @_;
	#return map { $self->{psi}{$_}{seq} } sort { $a <=> $b } keys %{$self->{psi}};
	return map { $self->{psi}{$_}{seq} } 0..$self->size - 1;
}

=head2 @starts = $psi->get_starts

The start position of the first residue from the alignments, returned in the same order as they appeared.

=cut

sub get_starts {
	my ($self) = @_;
	return map { $self->{psi}{$_}{start} } sort { $a <=> $b } keys %{$self->{psi}};
}

=head2 @all = $psi->get_all

Returns an array of arrays containing the ID, start position and alignment from the PSIBLAST output in the order they appeared.

=cut

sub get_all {
	my ($self) = @_;

	my @ids = $self->get_ids;
	my @starts = $self->get_starts;
	my @alignments = $self->get_alignments;

	return map { [ $ids[$_], $starts[$_], $alignments[$_] ] } 0..$#ids
}

=head2 $psi->evalue($label)

=cut

sub evalue {
	my ($self, $label) = @_;
	defined $label or confess "No label passed\n";
	exists $self->{evalue}{$label} or warn "No such label '$label'\n" and return undef;
	return $self->{evalue}{$label};
}

=head2 $psi->bit($label)

=cut

sub bit {
	my ($self, $label) = @_;
	defined $label or confess "No label passed\n";
	exists $self->{bit}{$label} or warn "No such label '$label'\n" and return undef;
	return $self->{bit}{$label};
}

=head2 $psi->size

Returns the number of sequences in the alignments.

=cut

sub size {
	my ($self, $size) = @_;

	unless (defined $size) {
		exists $self->{size} and return $self->{size};
	}
	else {
		$self->{size} = $size;
	}
}

=head2 BUGS

Doesn't aquire any other information.

=head2 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>

=cut

1;
