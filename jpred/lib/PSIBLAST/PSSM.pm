package PSIBLAST::PSSM;

use strict;
use warnings;
use Carp;

use base qw(Root Read Write);

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";

	my $xsum = 0;
	while (my $line = <$fh>) {
		if ($line =~ /^\s{11}A  R  N  D  C  Q  E/) {
			while ($line = <$fh>) {
				chomp;
				last if $line =~ /^\s*$/;

				my @pssm = split /\s+/, $line;

				my @data;
				for (@pssm[3..22]) {
					push @data, sprintf "%2.8f", 1 / (1 + (exp(- $_)));
					$xsum += $_;
				}

				$self->add_pos(@data);
			}
		}
	}

}

sub add_pos {
	my ($self, @data) = @_;

	@data == 20 or croak "add_pos passed wrong length array";

	push @{ $self->{__PACKAGE__."pos"} }, \@data;
}

{
	my $i = 0;

	sub get_pos {
		my ($self) = @_;

		if (defined (my $foo = $self->get_num_pos($i++))) {
			return $foo
		}
		else {
			$i = 0;
			return undef;
		}
	}
}

sub seq {
	my ($self, $data) = @_;

	if ($data) {
		confess "Not passed ARRAY" unless ref $data eq 'ARRAY';
		$self->add_pos(@{ $data });
	}
	else {
		my $size = $self->get_pos_size - 1;
		$size or return ();
		return map { $self->get_num_pos($_) } 0..$size;
	}
}

sub get_num_pos {
	my ($self, $pos) = @_;
	confess "No positions passed to get_num_pos" unless defined $pos;
	return undef unless exists $self->{__PACKAGE__."pos"};
	return ${ $self->{__PACKAGE__."pos"} }[$pos];
}

sub get_pos_size {
	my ($self) = @_;
	exists $self->{__PACKAGE__."pos"} ?
		return scalar @{ $self->{__PACKAGE__."pos"} } :
		0;
}

sub write {
	my ($self, $fh) = @_;
	while (my $pos = $self->get_pos) {
		print $fh join(" ", @{$pos}), "\n"
	}
}

1;

__END__

=head1 NAME

PSIBLAST::PSSM - Read PSIBLAST PSSM files

=head1 EXAMPLE

 my $pssm = PSIBLAST::PSSM->new;
 $pssm->read_file("data.pssm");

 for ($pssm->seq) {
 	print join(" ", @{$_}), "\n";
 }

=head1 DESCRIPTION

Class for reading PSIBLAST PSSM files, subclasses the Root, Read and Write classes.

=head1 METHODS

=head2 my $pssm = PSIBLAST::PSSM->new()

Create the object. See Root module for details.

=head2 $pssm->read_file("path_to_file");

Read in a PSIBLAST PSSM file. See Read module for other methods.

=head2 $pssm->add_pos(@data);

Adds data from PSIBLAST PSSM.

=head2 $pssm->get_pos;

Itterator for returning the data for each position loaded in the object.

=head2 $pssm->write;

Prints the PSSM file for use by Jnet.

=head2 $pssm->seq([ @data ] );
  $data = $pssm->seq;

Gah! Deprecated.

=head1 SEE ALSO

Root, Read and Write modules.

=head1 AUTHOR

Jonathan Barber <jon@compbio.dundee.ac.uk>
