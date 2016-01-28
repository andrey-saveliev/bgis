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
my $maxChatMID;
{ my $SQLStr=  "SELECT MAX(MID) MAXID FROM CHAT";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $maxChatInfo = $cursor->fetchrow_hashref;
  $maxChatMID =  $maxChatInfo->{MAXID};
}

my $SQLStr=  "SELECT C.MDATE, C.MESSAGE, U.USERNAME FROM CHAT C LEFT OUTER JOIN USER U ON C.USERID=U.USERID ORDER BY C.MID DESC";
my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 

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

</head>

<body>
<script>
window.parent.document.getElementById('MID').value='$maxChatMID'; 
</script>
<table width=100% border=0 cellspacing=0 cellpadding=3 style="font-family: arial; font-size: 10pt;">

EOF
my $msgCnt=0;
while(my $chatInfo = $cursor->fetchrow_hashref) {
	print "<tr>";
	print "<td>$chatInfo->{MDATE}</td>";
	print "<td>$chatInfo->{USERNAME}</td>";
	print "<td width=\"65%\">$chatInfo->{MESSAGE}</td>";
	print "</tr>";
	$msgCnt++;
	}

print <<EOF;
</table>
</body>
</html>
EOF
