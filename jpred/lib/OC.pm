package OC;

use strict;
use warnings;
use Carp;
use IPC::Open3;

use base qw(Root Read Common);
use Run qw(check);

=head1 NAME

OC - Read OC output 

=head1 SYNOPSIS

  $oc = OC->new;
  $oc->read_file($path);

  $oc->get_group(1); # Returns information about cluster 1
  $oc->get_groups; # Returns all the groups

=head1 DESCRIPTION

This is a module to read OC output.

=head1 $oc->read($fh);

Reads an OC file from a filehandle.

=cut

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";

	while (<$fh>) {
		chomp;
		next if /^\s*$/;

		if (s/^##\s*//) {
			my ($num, $score, $size) = split;
			my $nl = <$fh>;
			$nl =~ s/^\s+//;
			my (@labels) = map { chomp; $_ } split / /, $nl;

			# Add to self
			$self->add_group($num, $score, $size, @labels);
		}
		elsif (/^UNCLUSTERED ENTITIES$/) {
			my (@labels) = map { chomp; $_ } <$fh>;
			$self->add_unclustered(@labels);
		}
	}
}

=head $oc->add_group($number, $score, $size, @labels)

Add information about a group.

=cut

sub add_group {
	my ($self, $num, $score, $size, @labels) = @_;

	for (qw(num score size)) {
		croak "No value for $_ passed to add_group" unless eval "defined \$$_"
	}

	croak "No labels passed to add_group" unless @labels;

	$self->{__PACKAGE__."score"}{$num} = $score;
	$self->{__PACKAGE__."size"}{$num} = $size;
	$self->{__PACKAGE__."labels"}{$num} = [ @labels ];
}

=head2 $oc->add_unclustered(@labels)

Adds those entities that are unclustered.

=cut

sub add_unclustered {
	my ($self, @labels) = @_;
	$self->{__PACKAGE__."unclust"} = \@labels;
}

=head2 $oc->get_unclustered

Returns those unclustered entities as a list.

=cut

sub get_unclustered {
	my ($self) = @_;
	return @{$self->{__PACKAGE__."unclust"}} if defined $self->{__PACKAGE__."unclust"};
}

=head2 ($score, $size, @labels) = $oc->get_group($n);

Returns information about a particular group. If the group doesn't exist you get a warning message and undef.

=cut

sub get_group {
	my ($self, $num) = @_;
	if (defined $num) {
		if (exists $self->{__PACKAGE__."score"}{$num}) {
			return 
				$self->{__PACKAGE__."score"}{$num},
				$self->{__PACKAGE__."size"}{$num},
				@{ $self->{__PACKAGE__."labels"}{$num} };
		}
		else {
			carp "No such group '$num'";
			return undef;
		}
	}
	else {
		croak "No value passed to get_group";
	}
}

=head1 @info = $oc->get_groups;

Returns information about all of the groups. This is an array of arrays, the second array holds group id and then the information returned by the get_group method.

=cut

sub get_groups {
	my ($self) = @_;

	map {
		[ $_, $self->get_group($_) ]
	} sort keys %{ $self->{__PACKAGE__."score"} };
}

=head1 $oc->run();

=cut

sub run {
	my ($self, $file) = @_;
	
	local $/ = undef;
	local $| = 1;

	my $pid = open3(\*WRT, \*RD, \*ERR, $self->path);

	print WRT $file;
	close WRT;

	my @output = join "\n", split "\n", <RD>;
	close RD;

	waitpid $pid, 0;
	check($self->path, $?) or die "OC was naughty";

	return @output;
}

1;
