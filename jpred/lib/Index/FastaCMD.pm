package Index::FastaCMD;

our $VERSION = '0.2';

=head1 NAME

Index::FastaCMD - module to use the fastacmd program to read BLAST formatted databases

=head1 DESCRIPTION

This module was written as a replacement for Index::EMBOSS as EMBOSS needed to be statically linked to libgd, whcih wasn't a very sysadmin-friendly way of installing the software. As BLAST is pretty ubiquitous the fastacmd was deemed to be a better option. Copied heavily from Index::EMBOSS.

=head1 SYNOPSIS

=head1 CHANGES

=over 8

=item 0.2

Added 'use Path' module to ensure that the correct fastacmd binary is used. Previously on the cluster the wrong fastacmd was used, which resulted in a failure. Now is more robust although the path to fastacmd is hardcoded in Paths.pm

=head1 AUTHOR

Chris Cole <christian@cole.name>

=cut


use strict;
use warnings;


use Carp;
use POSIX qw(WIFEXITED WEXITSTATUS WIFSIGNALED WTERMSIG);
use IPC::Open3;

use base qw(Root);

use FASTA::File;
use Paths qw($fastacmd);

sub get_sequence {
   my ($self, $key, $db) = @_;
   
   my $appName = $fastacmd;
   
   croak "No sequence code given for get_sequence" unless $key;
   croak "No database given for get_sequence" unless $db;
   
   my @cmd = split / /, "$appName -s $key -d $db";

   my $pid = open3(undef, \*RD, \*ERR, @cmd);

   my $seq = FASTA::File->new(read => \*RD);
   my @err = <ERR>;

   pop @err;
   pop @err;

   close RD; close ERR;
   waitpid $pid, 0;
   
   # Everything was okay...
   if (WIFEXITED($?) and not WEXITSTATUS($?)) { return $seq }
   # Non-zero exit
   elsif (WIFEXITED($?) and WEXITSTATUS($?)) {
      carp "Command: '@cmd' had a problem: $?; $!";
      carp @err;
   }
   # Was it stopped by an external program
   elsif (WIFSIGNALED($?)) {
      carp "$appName halted by external signal ".WTERMSIG($?)
   }
   else {
      carp "$appName suffered from a random pantwetting event"
   }

   return undef;
}

1;
