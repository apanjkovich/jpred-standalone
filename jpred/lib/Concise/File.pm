package Concise::File;

use strict;
use warnings;
use Carp;

use base qw(Root Read Write Sequence::File);
use Concise;

# Pass a filehandle
sub read {
	my ($self, $fh) = @_;

	while (<$fh>) {
		chomp;

		next if /^\s*$/;	# Skip blank lines
		next if /^#/;		# skip comment lines
#		s/#.*//g;			# Clear comments
		
		my ($head, $field) = split /:/, $_, 2;

		unless (defined $field and defined $head) {
			carp "Line $. doesn't match concise file format, skipping";
			next;
		}

		$field =~ s/,$//g;
		my @fields = split /,/, $field;

		my $new = Concise->new(id => $head);
		$new->seq(@fields);
		$self->add_entries($new);
	}
}

sub write {
	my ($self, $fh) = @_;

	for ($self->get_entries) {
		my $id = $_->id;
		my @seq = $_->seq;

		my $seq = join ',', @seq;
		$seq =~ s/,$//;

		print $fh "$id:$seq\n";
	}
}

1;

__END__

=head1 NAME

Concise::File - Module to read Concise file

=head1 SYNOPSYS

  # Read a concise file and print the id's in the file
  $concise = Concise::File->new(read_file => "path_to_file");
  for ($concise->get_entries) {
    print $_->id, "\n";
  }

=head1 DESCRIPTION

This module allows you to read concise files and then get all the information held in the file or to select those entries you want by their IDs.

=head1 METHODS

This module inherits from the Root, Read and Write modules. See these for default methods.

=over

=item $concise->add_entries(@Concise)

Add a list of Concise objects to the Concise::File object.

=item $concise->get_entries

Returns a list of the entries held in the object. These are held as Concise objects.

=item $concise->get_entry_by_id( qr/foo/ )

Get entries dependant upon their IDs and a regex. The argument can either be a regex object or a string to be interpreted as a regex. A list of Concise objects is returned.

=back

=head1 AUTHOR

Jonathan Barber (jon@compbio.dundee.ac.uk)
