package DSSP;

use strict;
use warnings;
use Carp;
use IO::String;
use UNIVERSAL qw(isa);

use base qw(Root Read);

=head1 DSSP

Object to hold some of the information found in a DSSP file.

=head2 my $dssp = DSSP->new;

Creates new object. Any accessor method is valid to use as an argument in a hash key/value set of pairs.

=head2 $dssp->read($string);

Reads in the DSSP file contained within the $string. Returns true if it there is information in the file, otherwise false.

=cut

sub read {
	my ($self, $data) = @_;

	defined $data or croak "No filehandle passed\n";
	local $/ = "\n";
	my $flag = 0; # Test to see if there's any information in the file

	while (<$data>) {
		if (/^  #  RESIDUE AA STRUCTURE/) {
			$flag = 1;
			my $chain;

			while (<$data>) {
				chomp;
				my $aa_pri = substr($_, 13, 1);

				# Chain break, has to come here in order to remember what the
				# chain was
				if ($aa_pri eq '!') {
					$self->add_position(
						DSSP::Position->new(
							chain => $chain,
							break => 1
						)
					);
					next;
				}

				# If there isn't a chain break, continue as normal
				my $aa_sec = substr($_, 16, 1);
				my $aa_acc = substr($_, 35, 3);
				$chain = substr($_, 11, 1);

				# Field is six wide to include alternatives, but I'm ignoring
				# those
				my $pos = substr($_, 5, 6);
				my $seq_pos = substr($_, 0, 5);

				# Replace empty chain defn with NULL
				$chain = 'NULL' if $chain eq ' ';

				# Replace lower case letters (cystine
				# bridge pairs) with 'c'
				$aa_pri =~ tr/[a-z]/c/;

				$aa_sec =~ tr/ /-/;

				# Remove any padding whitespace
				for ($aa_pri, $aa_sec, $aa_acc, $chain, $pos, $seq_pos) {
					s/ //g
				}

				$self->add_position(
					DSSP::Position->new(
						chain => $chain,
						pri => $aa_pri,
						sec => $aa_sec,
						acc => $aa_acc,
						off => $pos,
						seq_off => $seq_pos,
						break => undef
					)
				);
			}
		}
	}
	return $flag;
}

=head2 $dssp->add_position($DSSP::Position);

Adds a position object.

=cut

sub add_position {
	my ($self, $pos) = @_;

	unless (defined $pos and isa $pos, 'DSSP::Position') {
		croak "No object passed"
	}

	my ($chain, $offset);

	defined($chain = $pos->chain) or croak "Chain not set\n"; 
	unless ($pos->break) {
		defined($offset = $pos->off) or croak "Offset not set\n";
	}

	# Use a stack based system now
	push @{ $self->{__PACKAGE__."pos"}{$chain} }, $pos;

	# This is for backwards compatibility, shudder, also required changes in
	# get_position() and position()
	unless ($pos->break) {
		$self->{__PACKAGE__."offset_compat"}{offset}{$chain}{$offset} = \$self->{__PACKAGE__."pos"}{$chain}->[ -1 ];

		if (exists $self->{__PACKAGE__."pos"}{offset}{$chain}{$offset}) {
			my $out = "Overwriting DSSP position $offset in chain $chain";
			$out .= $self->path ? " for file ".$self->path."\n" : "\n";
			warn $out;
		}
	}

	# Add the chain if not already present
	my @chains = grep { defined } $self->chains;
	unless (grep { $chain eq $_ } @chains) {
		$self->chains(@chains, $chain);
	}
}

=head2 $DSSP::Position = $dssp->get_chain_defs($chain)

New method to replace get_position() and positions(). Returns all of the DSSP::Position objects for a particular chain in the order they are seen in the DSSP file. Then you have to decide what to do with them.

=cut

sub get_chain_defs {
	my ($self, $chain) = @_;

	croak "Chain not recognised" unless grep { $_ eq $chain } $self->chains;

	return @{ $self->{__PACKAGE__."pos"}{$chain} };
}

=head2 $DSSP::Position = $dssp->get_position($chain, $offset)

Depricated! Don't use this methods as it's broken, it's available for backwards compatibility.

Returns the position object for a particular location.

=cut

sub get_position {
	my ($self, $chain, $offset) = @_;

	unless (defined $chain) { croak "No chain given" }
	unless (defined $offset) { croak "No offset given" }

	confess("No such chain '$chain'") and return unless exists $self->{__PACKAGE__."pos"}{$chain};

	confess("No such offset $offset in chain $chain") and return
		#unless exists $self->{__PACKAGE__."pos"}{$chain};
		unless exists $self->{__PACKAGE__."offset_compat"}{offset}{$chain}{$offset};

	return ${ $self->{__PACKAGE__."offset_compat"}{offset}{$chain}{$offset} };
}

=head2 $DSSP::Position = $dssp->positions($chain);

Depricated! Don't use this methods as it's broken, it's available for backwards compatibility.

Returns all the offsets that are available for a particular chain, sorted by offset.

=cut

sub positions {
	my ($self, $chain) = @_;

	unless (defined $chain) { croak "No chain given" }

	croak "No such chain $chain" unless exists $self->{__PACKAGE__."pos"}{$chain};

	no warnings;
	return
		map { join "", @{$_} }
		sort { $a->[0] <=> $b->[0] || $a->[1] cmp $b->[1] }
		map { [ /^(-?\d+)(\D+)?$/ ] }
		#keys %{$self->{__PACKAGE__."pos"}{$chain}};
		keys %{$self->{__PACKAGE__."offset_compat"}{offset}{$chain}};
}

=head2 @chains = $dssp->chains;

Finds the chains in the structure, or alters them, but don't do that. Returns an empty list if no chains have been found.

=cut

sub chains {
	my ($self, @chains) = @_;
	if (@chains) { @{$self->{__PACKAGE__."chains"}} = @chains }
	elsif ($self->{__PACKAGE__."chains"}) {
		return @{ $self->{__PACKAGE__."chains"} };
	}
	else {
		return ();
	}
}

=head1 DSSP::Position

Object to hold information on each position of a DSSP output.

=head2 my $dssp_pos = DSSP::Position->new;

Create a new object.

=head2 Accessors

=over

=item * chain

Holds the chain ID.

=item * pri

Holds the primary structre.

=item * sec

Holds the secondary structre.

=item * acc

Holds the solvent structre.

=item * off

Holds the position in the PDB structure.

=back

=cut

use Class::Struct "DSSP::Position" => {
	chain => '$',
	pri => '$',
	sec => '$',
	acc => '$',
	off => '$',
	seq_off => '$',
	break => '$'
};

1;
