package Sequence::File;

use strict;
use warnings;
use Carp;

use UNIVERSAL qw(isa);
use base qw(Root Read Write);

=head2 $file->get_entries

Returns all records so far found in the file.

=cut

sub get_entries {
  my ($self) = @_;

  if ( exists $self->{ __PACKAGE__ . "entries" } ) {
    return @{ $self->{ __PACKAGE__ . "entries" } };
  } else {
    return undef;
  }
}

=head2 $file->get_entry(@positions);

Retrieves the @position's'th record found in the file or undef if there is no such sequence.

=cut

sub get_entry {
  my ( $self, @offsets ) = @_;

  if ( exists $self->{ __PACKAGE__ . "entries" } and @offsets ) {
    return @{ $self->{ __PACKAGE__ . "entries" } }[@offsets];
  } else {
    return undef;
  }
}

=head2 $self->add_entries(@entries)

Adds more entries to the object. Returns the number of entries added to the object. This may be less than those passed if set_max_entries() has been called.

=cut

sub add_entries {
  my ( $self, @entries ) = @_;
  return unless @entries;

  for (@entries) {
    croak "Adding non Sequence object" unless isa $_, "Sequence";
    $self->_ids( $_->id );
    push @{ $self->{ __PACKAGE__ . "entries" } }, $_;
  }

  #	my $max = $self->get_max_entries;
  #	if (defined $max) {
  #		my $exist_size = @{ $self->{__PACKAGE__."entries"} };
  #		if ($exist_size > $max) { return 0 }
  #		elsif ($exist_size + @entries > $max) {
  #			return push @{ $self->{__PACKAGE__."entries"} }, @entries[0..$max - $exist_size];
  #		}
  #		else {
  #			return push @{ $self->{__PACKAGE__."entries"} }, @entries;
  #		}
  #	}
  #	else {
  #		return push @{ $self->{__PACKAGE__."entries"} }, @entries;
  #	}
}

=head2 $file->get_entry_by_id(/regex/);

Returns all of those entries which have id's that match the regex.

=cut

# Cache of sequence IDs for fast grepping
sub _ids {
  my ( $self, $id ) = @_;
  if ($id) { push @{ $self->{ __PACKAGE__ . "ids" } }, $id }
  else     { return @{ $self->{ __PACKAGE__ . "ids" } } }
}

sub get_entry_by_id {
  my ( $self, $id ) = @_;
  croak "No id passed" unless defined $id;

  #return grep { $_->id =~ /$id/ } $self->get_entries;

  {
    my @ids = $self->_ids;
    my @indices = grep { $ids[$_] =~ /$id/ } 0 .. $#ids;
    return $self->get_entry(@indices);
  }
}

=head2 $file->set_max_entries($size);

Limits the storing of $size records. Will prevent the addition of more records, 
but won't delete existing records in the object if there are already more than 
$size entries.

=cut

sub set_max_entries {
  my ( $self, $size ) = @_;

  $self->{ __PACKAGE__ . "max_size" } = $size;
  return $size;
}

=head2 $file->get_max_entries

Accessor for set_max_entries().

=cut

sub get_max_entries {
  my ($self) = @_;
  return $self->{ __PACKAGE__ . "max_size" };
}

=head2 

=cut

sub sub_seq {
  my ( $self, $start, $end ) = @_;

  croak "Not passed start and end arguments" unless 2 == grep { defined } $start, $end;

  # Produce a new version of myself, in the right namespace
  my ($new_self) = ( ref $self )->new;

  for ( $self->get_entries ) {
    my ($seq) = $_->sub_seq( $start, $end );
    $new_self->add_entries($seq);
  }

  return $new_self;
}

1;
