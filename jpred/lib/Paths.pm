package Paths;

use strict;
use warnings;
use base qw(Exporter);
use Sys::Hostname ();

=head1 NAME

Paths - Sets paths for executable programs

=head1 DESCRIPTION

This module gathers together all of the little pieces of information that would other wise be floating around in all of the other modules that run external programs. Namely, the path to the executable and nessecery environment variables. 

Putting it all here should mean that this is the only file that needs updating when their location changes, or it's redeployed. Plus some degree of automagic can be used to try and detect changes.

=cut

our @EXPORT_OK = qw($ff_bignet $analyze $batchman $sov $pairwise $oc $jnet $fastacmd $hmmbuild $hmmconvert $psiblastbin);

my $HOME = $ENV{HOME};
# main production path
my $BINDIR = '/homes/www-jpred/live4/jpred/bin';
# development path
#my $BINDIR = '/homes/www-jpred/devel/jpred/bin';

our $pairwise  = "$BINDIR/pairwise";  # CC modified for correct path
our $oc        = "$BINDIR/oc";
our $jnet      = "$BINDIR/jnet";
our $fastacmd  = "$BINDIR/fastacmd";              # CC added to avoid failure on cluster
our $hmmbuild  = "$BINDIR/hmmbuild";
our $hmmconvert = "$BINDIR/hmmconvert";
our $psiblastbin  = "$BINDIR/blastpgp";

# required for training with SNNS, but unused currently
our $ff_bignet = "$HOME/projects/Jnet/bin/snns/ff_bignet";  # CC modified for new path (SNNS app)
our $analyze   = "$HOME/projects/Jnet/bin/snns/analyze";    # CC modified for new path (SNNS app)
our $batchman  = "$HOME/projects/Jnet/bin/snns/batchman";   # CC modified for new path (SNNS app)
our $sov       = "$HOME/projects/Jnet/bin/sov";


=head1 AUTOMATED CHANGES

Currently the paths are altered on the basis of per host rules.

=cut

#my $host = Sys::Hostname::hostname();
#if (grep { $host =~ $_ } qr/^(anshar|kinshar)/o, qr/^cluster-64-/o) {
#	for my $temp (@EXPORT_OK) {
#		eval "$temp =~ s#$HOME\/tmp#$HOME#g";
#	}
#}

1;
