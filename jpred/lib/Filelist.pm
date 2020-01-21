package Filelist;
use strict;
use warnings;
use base qw(Root Read Write);

sub read {
	my ($self, $fh) = @_;

	local $/ = "\n";
	while (<$fh>) {
		chomp;
		my @files = split /\s+/, $_;
		$self->add_files(@files);
	}
}

sub add_files {
	my ($self, @files) = @_;
	push @{ $self->{__PACKAGE__."files"} }, \@files;
}

sub get_files {
	my ($self, @list) = @_;
	if (@list) { return @{ $self->{__PACKAGE__."files"} }[@list] }
	else { return @{ $self->{__PACKAGE__."files"} } }
}

sub all_files {
	my ($self) = @_;
	$self->{__PACKAGE__."offset"} ||= 0;

	my $files = $self->get_files( $self->{__PACKAGE__."offset"}++ );
	defined $files or undef $self->{__PACKAGE__."offset"}, return;
	return @{$files};
}

1;

__END__

=head1 NAME

Filelist - Reads in a list of files.

=head1 SYNOPSIS

Reads in a file containing a list of files per line and allows you to retrieve them easily.

=head1 FILE EXAMPLE

  foo0 bar0
  foo1 bar1
  foo2 bar2 moo2

=head1 INHERITS

Root, Read and Write.

=head1 METHODS

=head2 $list->read($filehandle)

Reads in the filelist. Splits the lines in the file on whitespace to find the files.

=head2 $list->add_files(@paths);

Add your own files to an existing Filelist object.

=head2 $list->get_files(@offsets)

If @offsets is not an empty list, returns an AoA of the files. Otherwise returns all off the files as an AoA.

=head2 $list->all_files()

Itterator for retrieving all the files held by the object. Every call returns the files as from get_files() until all of the lines have been gone through, when it returns undef.
