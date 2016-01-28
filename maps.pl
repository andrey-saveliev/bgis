#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $mapnum; $_=param('m');
if(/\d+/) { $mapnum=$_; } else  { $mapnum=1; }
if(!($mapnum>=0 && $mapnum<=11)) { $mapnum=1; }
if(length($mapnum)<2)		 { $mapnum="0".$mapnum; }

my $mapURL="/cgi-bin/mapserv.cgi?mode=browse&zoomdir=1&zoomsize=2&map=/var/lib/openshift/552760adfcf9332f530001fe/app-root/repo/gismap/".$mapnum."/floor.map";

print "Content-type: text/html\r\n\r\n";
print <<EOF;
    <?xml version="1.0"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="ru">
	<head>
	    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
	    <meta http-equiv="content-language" content="ru" />
	    <meta name="robots" content="all,follow" />

	<script language="JavaScript">
	    function ChangeURL() { 
		document.location="$mapURL";
		}
	</script>
    </head>
        <title>Переход на карту</title>
    </head>

    <body>
	<script>
	    ChangeURL();
	</script>
	<div align=center>
	    <font style="color: #FFFF00;">
		<B> Пожалуйста, подождите! 
	    </font>
	</div>
    </body>
    </html>
EOF
