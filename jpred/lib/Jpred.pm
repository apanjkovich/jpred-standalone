package Jpred;

=head1 NAME

jpred.pm -- Jpred module to define all necessary global and environment variables

=cut

use warnings;
use strict;

BEGIN {
  use Exporter;
  our @ISA = ('Exporter');
  our @EXPORT = qw(
    $WEBSERVER 
    $WEBSERVERCGI 
    $SERVERROOT 
    $SRSSERVER 
    $CHKLOG 
    $RESULTS 
    $PDBLNK 
    $CSS 
    $IMAGES 
    $JNET 
    $TIMEOUT 
    $BATCHLIM 
    $DUNDEE 
    $JPREDUSER 
    $JPREDEMAIL 
    $MAILHOST 
    $JPREDROOT 
    $BINDIR 
    $LIBDIR 
    $JOBDIR 
    $PREFIX 
    $RESOURCE 
    $BLASTDB 
    $SWALL 
    $SWALLFILT 
    $PDB 
    $PDB_DAT 
    $JPREDHEAD
    $JPREDHEADTABLE
    $JPREDFOOT 
    $JPREDFOOTSIMPLE
    &xsystem
  );
  our @EXPORT_OK = @EXPORT;
}

# library path for Mail::CheckUser dependency for jpred_form.
# for some reason doesn't work if in PERL5LIB
use lib '/sw/lib/perl5.10.1/lib/perl5';

# URIs
our $WEBSERVER = 'http://www.compbio.dundee.ac.uk/jpred4';
#our $WEBSERVER    = 'http://gjb-www-1.cluster.lifesci.dundee.ac.uk:3209';

our $WEBSERVERCGI = "$WEBSERVER/cgi-bin";

#$SERVERROOT = "$WEBSERVER/~www-jpred";
our $SERVERROOT = "$WEBSERVER";
#our $SRSSERVER  = 'http://srs.ebi.ac.uk/srs6bin/cgi-bin';
our $SRSSERVER  = 'http://www.ebi.ac.uk/ebisearch/search.ebi';
our $CHKLOG     = "$WEBSERVERCGI/chklog?";
our $RESULTS    = "$SERVERROOT/results";
our $PDBLNK     = "http://www.ebi.ac.uk/pdbsum/";
#our $CSS        = "$SERVERROOT/jpred.css";
our $CSS        = "$SERVERROOT/jpredWeb.css";
our $IMAGES     = "$SERVERROOT/images";
our $JNET       = "$SERVERROOT/about.html#jnet";

# This is the time (in seconds) the job is allowed to take
our $TIMEOUT  = 60 * 180;    # now is 180mins
our $BATCHLIM = 200;

our $DUNDEE = "http://www.dundee.ac.uk";

# e-mail details
our $JPREDUSER  = 'www-jpred';
our $JPREDEMAIL = 'www-jpred@compbio.dundee.ac.uk';
our $MAILHOST   = 'smtp.lifesci.dundee.ac.uk';        # CC 19/05/06 - updated to current smtp host from weevil

# Server paths
our $JPREDROOT = '/homes/www-jpred/live4';
#our $JPREDROOT = '/homes/www-jpred/devel';

# Directory for binaries either on the cluster or on the www server
our $BINDIR = "$JPREDROOT/bin";

# path to perl modules
our $LIBDIR = "$JPREDROOT/lib";

# Cluster paths
our $JOBDIR = "$JPREDROOT/public_html/results";    # directory for output

# Cluster names
our $PREFIX   = "jp_";                             # Prefix for job submissions (qstat will only display 10 chars of job name)
our $RESOURCE = "www_service2";                    # Resource for the submission to use

# Variables for external programs
# psiblast
$ENV{BLASTMAT} = "$JPREDROOT/data/blast";
our $BLASTDB = $JPREDROOT . "/databases";
$ENV{BLASTDB} = $BLASTDB;
our $SWALL     = "$BLASTDB/uniref90";
our $SWALLFILT = "$SWALL.filt";
our $PDB       = '/db/blastdb/pdb';
our $PDB_DAT   = '/db/blastdb/DB.dat';

# ncoils matrix location
$ENV{COILSDIR} = "$JPREDROOT/data/coils";

# Error checking system call
sub xsystem {
  my ($command) = @_;
  my $rc = 0xffff & system $command;
  if ( $rc == 0 ) {
    return;
  } elsif ( $rc == 0xff00 ) {
    print "'$command' failed!\n";
    die "Jpred failed\n";
  } elsif ( ( $rc & 0xff ) == 0 ) {
    $rc >>= 8;
    die "'$command' did something else! (exited $rc)\n";
  } else {
    if ( $rc & 0x80 ) {
      $rc &= ~0x80;
      print "'$command' dumped core!\n";
      die "Jpred failed\n";
    }
  }
}

# The header and footer for any HTML produced dynamically
# The header and footer for any HTML produced dynamically
our $JPREDHEAD = "      
<script src=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery-1.11.1.js\"></script>
  <script type=\"text/javascript\" src=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery.qtip.min.js\"></script>
  <link type=\"text/css\" rel=\"stylesheet\" href=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery.qtip.min.css\">
  <link href=\"http://www.compbio.dundee.ac.uk/jpred4/bootstrap-3.2.0-dist/css/bootstrap.css\" rel=\"stylesheet\">
  <script src=\"http://www.compbio.dundee.ac.uk/jpred4/bootstrap-3.2.0-dist/js/bootstrap.min.js\"></script>
  <link type=\"text/css\" rel=\"stylesheet\" href=\"http://www.compbio.dundee.ac.uk/jpred4/jpredWeb.css\">
<link rel=\"shortcut icon\" href=\"http://www.compbio.dundee.ac.uk/jpred4/images/BG_intense2_small.ico\">

<div class=\"container\">

  <div class=\"row\">
    <a href=\"http://www.compbio.dundee.ac.uk/jpred4/\">
    <div class=\"col-md-12\">
      <ul id=headerTable>
        <li id=headerTable><a id=headerTable class=\"jpredLogo\" href=\"http://www.compbio.dundee.ac.uk/www-jpred/\">
        <script>
          var is_chrome = !!window.chrome;
          if (is_chrome) { var myOutput=\"<img id=headerTable type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/Jpred4_logo8_3.svg'></img>\"; \$( \"a.jpredLogo\" ).append(myOutput);}
          else { var myOutput=\"<embed id=headerTable type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/Jpred4_logo8_3.svg'></embed>\"; \$( \"a.jpredLogo\" ).append(myOutput);}
        </script></a></li>
      </ul>
    </div>
    </a>
  </div>

  <div class=\"row mytoppadding mybottompadding\">
    <div class=\"col-md-12\">
      <h1 id=headerTable>A Protein Secondary Structure Prediction Server</h1>
    </div>
  </div>

<div class=\"mybottompaddingL mytoppadding\">
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/index_up.html\" role=\"button\" class=\"btn btn-primary\">Home</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/api.shtml\" role=\"button\" class=\"btn btn-primary\">REST API</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/about.shtml\" role=\"button\" class=\"btn btn-primary\">About</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/news.shtml\" role=\"button\" class=\"btn btn-primary\">News</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/faq.shtml\" role=\"button\" class=\"btn btn-primary\">F.A.Q.</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/help.shtml\" role=\"button\" class=\"btn btn-primary\">Help & Tutorials</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/monitor.shtml\" role=\"button\" class=\"btn btn-primary\">Monitoring</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/contact.shtml\" role=\"button\" class=\"btn btn-primary\">Contact</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/refs.shtml\" role=\"button\" class=\"btn btn-primary\">Publications</a>
</div>
</div>

<div class=\"row mybottompaddingL mytoppadding\">
  <div class=\"col-md-2 text-left\"></div>
  <div class=\"col-md-8 text-left\">


";

our $JPREDHEADTABLE = "      
<script src=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery-1.11.1.js\"></script>
<script type = \"text/javascript\" src=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery.dataTables.js\"></script>
<script type = \"text/javascript\">
     \$(document).ready(function() {
        
           /* two functions for sorting p-value data sensibly */
         jQuery.fn.dataTableExt.oSort['allnumeric-asc']  = function(a,b) {
            var x = parseFloat(a);
            var y = parseFloat(b);
            return ((x < y) ? -1 : ((x > y) ?  1 : 0));
         };
       
         jQuery.fn.dataTableExt.oSort['allnumeric-desc']  = function(a,b) {
            var x = parseFloat(a);
            var y = parseFloat(b);
            return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
         };
              
    \$('#pdbTable').dataTable(
       {
         'aoColumnDefs': [
             { 'sType': 'allnumeric', 'aTargets': [ 3 ] }
         ],
         'aaSorting': [],
           'aLengthMenu': [[25, 50, 100, 200, -1], [25, 50, 100, 200, 'All']],
           'iDisplayLength': 25,
           'sPaginationType': 'full_numbers',
           'bFilter': false
       }

    );
});
  </script>
  <link rel=\"stylesheet\" type=\"text/css\" href=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/datatable.css\"/>

<script type = \"text/javascript\">
\$(document).ready(function() {
    \$(\".showPDBalign\").hide();
    \$(\"#showMore\").click(function(){
      console.log(\$(this));
      \$(\".showPDBalign\").toggle(200);
    });
});
</script>

  <script type=\"text/javascript\" src=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery.qtip.min.js\"></script>
  <link type=\"text/css\" rel=\"stylesheet\" href=\"http://www.compbio.dundee.ac.uk/jpred4/jquery/jquery.qtip.min.css\">
  <link href=\"http://www.compbio.dundee.ac.uk/jpred4/bootstrap-3.2.0-dist/css/bootstrap.css\" rel=\"stylesheet\">
  <script src=\"http://www.compbio.dundee.ac.uk/jpred4/bootstrap-3.2.0-dist/js/bootstrap.min.js\"></script>
  <link type=\"text/css\" rel=\"stylesheet\" href=\"http://www.compbio.dundee.ac.uk/jpred4/jpredWeb.css\">
<link rel=\"shortcut icon\" href=\"http://www.compbio.dundee.ac.uk/jpred4/images/BG_intense2_small.ico\">

<div class=\"container\">

  <div class=\"row\">
    <a href=\"http://www.compbio.dundee.ac.uk/jpred4/\">
    <div class=\"col-md-12\">
      <ul id=headerTable>
        <li id=headerTable><a id=headerTable class=\"jpredLogo\" href=\"http://www.compbio.dundee.ac.uk/www-jpred/\">
        <script>
          var is_chrome = !!window.chrome;
          if (is_chrome) { var myOutput=\"<img id=headerTable type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/Jpred4_logo8_3.svg'></img>\"; \$( \"a.jpredLogo\" ).append(myOutput);}
          else { var myOutput=\"<embed id=headerTable type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/Jpred4_logo8_3.svg'></embed>\"; \$( \"a.jpredLogo\" ).append(myOutput);}
        </script></a></li>
      </ul>
    </div>
    </a>
  </div>

  <div class=\"row mytoppadding mybottompadding\">
    <div class=\"col-md-12\">
      <h1 id=headerTable>A Protein Secondary Structure Prediction Server</h1>
    </div>
  </div>

<div class=\"mybottompaddingL mytoppadding\">
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/index_up.html\" role=\"button\" class=\"btn btn-primary\">Home</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/api.shtml\" role=\"button\" class=\"btn btn-primary\">REST API</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/about.shtml\" role=\"button\" class=\"btn btn-primary\">About</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/news.shtml\" role=\"button\" class=\"btn btn-primary\">News</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/faq.shtml\" role=\"button\" class=\"btn btn-primary\">F.A.Q.</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/help.shtml\" role=\"button\" class=\"btn btn-primary\">Help & Tutorials</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/monitor.shtml\" role=\"button\" class=\"btn btn-primary\">Monitoring</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/contact.shtml\" role=\"button\" class=\"btn btn-primary\">Contact</a>
</div>
<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"...\">
  <a href=\"http://www.compbio.dundee.ac.uk/jpred4/refs.shtml\" role=\"button\" class=\"btn btn-primary\">Publications</a>
</div>
</div>

<div class=\"row mybottompaddingL mytoppadding\">
  <div class=\"col-md-2 text-left\"></div>
  <div class=\"col-md-8 text-left\">


";

our $JPREDFOOT = "

  <div class=\"col-md-2 text-left\"></div>
  </div>
</div>

  <div class=\"row mytoppadding\">
    <div class=\"col-md-12\">
      <h6><b>Primary citation:</b> Drozdetskiy A, Cole C, Procter J &amp; Barton GJ. Nucl. Acids Res.<br>(first published online April 16, 2015) doi: 10.1093/nar/gkv332 [<a href=\"http://nar.oxfordjournals.org/content/early/2015/04/16/nar.gkv332\">link</a>]<br>
      <!--b>Previous:</b> Cole C, Barber JD &amp; Barton GJ. Nucleic Acids Res. 2008. 35 (suppl. 2) W197-W201 [<a href=\"http://nar.oxfordjournals.org/cgi/content/abstract/gkn238\">link</a>]<br-->
      More citations: <a href=\"http://www.compbio.dundee.ac.uk/jpred4/refs.shtml\">link</a>.</h6>
      <!--h6><a href=\"http://www.compbio.dundee.ac.uk/\">The Barton Group</a> :: <a href=\"http://www.dundee.ac.uk/\">The University of Dundee</a></h6-->
    </div>
  </div>


  <div class=\"row\">
    <div class=\"col-md-3\"><font color=\"#ffffff\">.</font>
    </div>
    <div class=\"col-md-2\">
        <a id=headerTable class=\"uniLogo\" href=\"http://www.dundee.ac.uk/\">
        <script>
          var is_chrome = !!window.chrome;
          if (is_chrome) { var myOutput=\"<img id=bottomLogos type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/University_white_logo0.svg'></img>\"; \$( \"a.uniLogo\" ).append(myOutput);}
          else { var myOutput=\"<embed id=bottomLogos type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/University_white_logo0.svg'></embed>\"; \$( \"a.uniLogo\" ).append(myOutput);}
        </script></a></div>
    <div class=\"col-md-2\">
<a id=headerTable class=\"compbioLogo\" href=\"http://www.compbio.dundee.ac.uk/\">
        <script>
          var is_chrome = !!window.chrome;
          if (is_chrome) { var myOutput=\"<img id=bottomLogos type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/BG_with_text.svg'></img>\"; \$( \"a.compbioLogo\" ).append(myOutput);}
          else { var myOutput=\"<embed id=bottomLogos type='image/svg+xml' src='http://www.compbio.dundee.ac.uk/jpred4/myimages/BG_with_text.svg'></embed>\"; \$( \"a.compbioLogo\" ).append(myOutput);}
        </script></a></div>
    <div class=\"col-md-2\">
        <li id=headerTable><a id=headerTable class=\"BBSRClogo\" href=\"http://www.bbsrc.ac.uk/\"><img id=bottomLogos src='http://www.compbio.dundee.ac.uk/jpred4/myimages/new-bbsrc-colour.gif'></img></a></div>
    <div class=\"col-md-3\">
    </div>
  </div>


</div> <!-- /container -->



      <script type=\"text/javascript\">
         var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");
         document.write(unescape(\"%3Cscript src=\'\" + gaJsHost + \"google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E\"));
      </script>
      <script type=\"text/javascript\">
         try{
            var pageTracker = _gat._getTracker(\"UA-5356328-1\");
            pageTracker._trackPageview();
         } catch(err) {}
      </script>
";

our $JPREDFOOTSIMPLE = "
      <script type=\"text/javascript\">
         var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");
         document.write(unescape(\"%3Cscript src=\'\" + gaJsHost + \"google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E\"));
      </script>
      <script type=\"text/javascript\">
         try{
            var pageTracker = _gat._getTracker(\"UA-5356328-1\");
            pageTracker._trackPageview();
         } catch(err) {}
      </script>
";
1;

=head1 DESCRIPTION

This module defines all the global and envirnmental variables required by the Jpred server scripts and binaries.

=head1 AUTHOR

I'm not sure who originally wrote this module, but I guess all of the following contributed:

James Cuff
Jon Barber
Chris Cole <christian@cole.name> 
Alexey Drozdetskiy <a.drozdetskiy@dundee.ac.uk> (current maintainer)

=cut

