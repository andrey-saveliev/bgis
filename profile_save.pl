#!/usr/bin/perl
use DBI;
use CGI qw(:standard);
use CGI qw(param);
use utf8;
binmode(STDOUT, ":utf8");

$P0=checkNumb(param('V00'));
$P1=checkStrn(param('V01'));
$P2=checkStrn(param('V02'));
$P3=checkStrn(param('V03'));
$P4=checkDate(param('V04'));
$P5=checkStrn(param('V05'));
$P6=checkStrn(param('V06'));

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();
                     
#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ
$SQLStr="UPDATE USER SET
		FAMILY=$P1, NAME=$P3, OTCHESTVO=$P5, BIRTH=$P4, GENDER=$P2, EMAIL=$P6
	 WHERE USERID=$P0
	";
$cursor = $dbh->do($SQLStr) or goto BADSQL;

#----------------------------------------------------------------------------------------
# ФОРМИРУЕМ СТРАНИЦУ HTML
#----------------------------------------------------------------------------------------
print "Content-type: text/html; charset=UTF-8\n\n";
print <<PART1;
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript">
  function ChangeURL()
{ document.location="profile.pl";
}
</SCRIPT>
<HEAD>
<TITLE>Страница загружается .....</TITLE>
</HEAD>
<BODY TEXT="#000000" BGCOLOR="#FFFFFF" LINK="#0000FF" VLINK="#000080" 
      ALINK="#FF0000" BACKGROUND="$bg">
<SCRIPT>
ChangeURL();
</SCRIPT>
<BR><BR><BR><BR>
<CENTER>
<TABLE WIDTH="200" BGCOLOR="#000099"><TR><TD><CENTER>
<FONT COLOR="#FFFF00"><BR><B>   Пожалуйста, подождите!   </B><BR>.</FONT>
</CENTER></TD></TR></TABLE>
</CENTER><BR>
</BODY>
</HTML>
PART1


#------------------------------------------------------------------------------------------
  sub checkStrn { 
my($a)=@_; $_=$a;
if(!/\S+/)	{ $res="NULL"; }
else		{ $res="'$a'"; }
return($res);
}
  sub checkNumb { 
my($a)=@_; $a=~s/\,/\./; $_=$a;
if(!/\S+/)	{ $res="NULL"; }
else		{ $res=$a; }
return($res);
}
  sub checkDate { 
my($a)=@_; $_=$a;
if(!/\S+/)	{ $res="NULL"; }
else		{ $res="'$a'"; }
return($res);
}


