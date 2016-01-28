#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $groupId; $_=param('g');
if(/^\d$/) { $groupId=$_; } else { $groupId=1; }

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();

#----------------------------------------------------------------------------------------

my $SQLStr=  "SELECT DAY,LENTA,WEEK,COURSE,ROOMNUMB,FAMILY,ROOM FROM V_GRPSHED 
		WHERE GRPID=$groupId ORDER BY DAY, LENTA, WEEK";
my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
my $shedInfo = $cursor->fetchall_arrayref;

#------------------------------------------------------------------------------------------------------------
print "Content-type: text/html\r\n\r\n";
print <<EOF;
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="content-language" content="ru" />
    <meta name="robots" content="all,follow" />

    <meta name="description" content="Геоинформационный портал Вуза" />
    <meta name="keywords" content="ГИС геоинформационный портал Вуза" />

    <title>Геоинформационный портал Вуза</title>

    <script language="JavaScript"> 
    function goPage(n) { 
	parent.document.location=n;
	}
    </script>

</head>

<body>
<table width=100% border=1 cellspacing=0 cellpadding=3 style="font-family: arial; font-size: 10pt;">



EOF

my @DAYS=("Дни недели","Пн","Вт","Ср","Чт","Пт","Сб","Вс");

my @LTIME=("Начало ленты","8:30-10:05","10:15-11:50","12:00-13:35",
	"13:50-15:25","15:40-17:15","17:25-19:00","19:10-20:45");

my @WEEKS=("Недели","чс","зн");

my $prevDay=""; my $prevTime="";
for my $i(0..$#{$shedInfo}) {
	my $trBackGround="#eeeeee";
	if($shedInfo->[$i][0] % 2) { $trBackGround="#eeeeff"; }
	print "<tr bgcolor=$trBackGround>";
	if($prevDay ne @DAYS[$shedInfo->[$i][0]]) {
		my $rowSpan=0;
		while($shedInfo->[$i+$rowSpan+1][0] eq $shedInfo->[$i][0]) {
			$rowSpan++;
			}
		$rowSpan++;
		print "<td rowspan=$rowSpan>", @DAYS[$shedInfo->[$i][0]], "</td>";
		$prevDay = @DAYS[$shedInfo->[$i][0]];
		$prevTime="";
		}

	if($prevTime ne $shedInfo->[$i][1]) {
		my $rowSpan=1;
		if($shedInfo->[$i][0] eq $shedInfo->[$i+1][0] &&
		   $shedInfo->[$i][1] eq $shedInfo->[$i+1][1]
		  ) 
		  { $rowSpan++; }
		print "<td rowspan=$rowSpan>", @LTIME[$shedInfo->[$i][1]], "</td>";
		$prevTime=$shedInfo->[$i][1];
		}

	print "<td>", @WEEKS[$shedInfo->[$i][2]], "</td>";

	my $rowSpanCourse=1;
	if( $shedInfo->[$i][0] eq $shedInfo->[$i+1][0] &&
	    $shedInfo->[$i][1] eq $shedInfo->[$i+1][1] &&
	    $shedInfo->[$i][3] eq $shedInfo->[$i+1][3])
	 	{ $rowSpanCourse++; }
	if(!($shedInfo->[$i][0] eq $shedInfo->[$i-1][0] &&
	     $shedInfo->[$i][1] eq $shedInfo->[$i-1][1] &&
	     $shedInfo->[$i][3] eq $shedInfo->[$i-1][3]))
		{ print "<td rowspan=$rowSpanCourse>", $shedInfo->[$i][3], "</td>"; }

	my $rowSpanAud=1;
	if( $shedInfo->[$i][0] eq $shedInfo->[$i+1][0] &&
	    $shedInfo->[$i][1] eq $shedInfo->[$i+1][1] &&
	    $shedInfo->[$i][3] eq $shedInfo->[$i+1][3] &&
	    $shedInfo->[$i][4] eq $shedInfo->[$i+1][4])
	 	{ $rowSpanAud++; }
	if(!($shedInfo->[$i][0] eq $shedInfo->[$i-1][0] &&
	     $shedInfo->[$i][1] eq $shedInfo->[$i-1][1] &&
	     $shedInfo->[$i][3] eq $shedInfo->[$i-1][3] &&
	     $shedInfo->[$i][4] eq $shedInfo->[$i-1][4]))
		{ my $roomInfo;
		  my $SQLStr=  "SELECT FLOOR,X,Y,SCALE FROM AUDITORY 
				WHERE RID=$shedInfo->[$i][6]";
		  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
		  my $placeInfo = $cursor->fetchrow_hashref;
		  $_=$placeInfo->{FLOOR}; if(/\d+/) {
			my $delta=$placeInfo->{SCALE}; 
			my $minX = $placeInfo->{X} - $delta;
			my $maxX = $placeInfo->{X} + $delta;
			my $minY = $placeInfo->{Y} - $delta;
			my $maxY = $placeInfo->{Y} + $delta;
			if(length($placeInfo->{FLOOR})<2) { $placeInfo->{FLOOR}="0".$placeInfo->{FLOOR}; }
			my $mapURL="/cgi-bin/mapserv.cgi?mode=browse&map=/var/lib/openshift/552760adfcf9332f530001fe/app-root/repo/gismap/".
				   $placeInfo->{FLOOR}."/floor.map&mapext=$minX+$minY+$maxX+$maxY&layer=ROOMS";
			$roomInfo = "<a href=\"javascript:goPage('$mapURL');\">$shedInfo->[$i][4]</a>";
		 	}
		  else  { $roomInfo=$shedInfo->[$i][4]; }
		  print "<td rowspan=$rowSpanAud>", $roomInfo , "</td>"; 
		}
	print "</tr>";
	}

print <<EOF;
</table>
</body>
</html>
EOF
