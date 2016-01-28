#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) 
my @LT = localtime();

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

#------------------------------------------------------------------------------------------------------------
# $maxChatMID<br>
# @LT[2] : @LT[1] : @LT[0]

print "Content-type: text/html\r\n\r\n";
print <<EOF;
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="content-language" content="ru" />
    <meta http-equiv="Refresh" content="10" />
</head>

<body>
<script>
window.parent.refreshChat($maxChatMID); 
</script>
</body>
</html>
EOF
