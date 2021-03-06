#!/usr/bin/perl
use DBI;
use CGI qw(:standard);
use CGI qw(param);
use utf8;
binmode(STDOUT, ":utf8");

$P0=checkNumb(param('V00'));
$P1=checkStrn(param('V01'));
$P2=checkStrn(param('V02'));
$P3=checkNumb(param('V03'));

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();

{ my $SQLStr=  "SELECT count(*) CNT
		  FROM STUDENT S
		 WHERE USERID=$P0
	       ";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $studentInfo = $cursor->fetchrow_hashref;

  if($studentInfo->{CNT} > 0) {
	$SQLStr="UPDATE STUDENT SET ZACHETKA=$P1, STUDBILET=$P2, GRPID=$P3 WHERE USERID=$P0 ";
	}
  else  { $SQLStr="INSERT INTO STUDENT(USERID, GRPID, ZACHETKA, STUDBILET) VALUES($P0, $P3, $P1, $P2) ";
	}
  $cursor = $dbh->do($SQLStr) or goto BADSQL;
}

#----------------------------------------------------------------------------------------
# ФОРМИРУЕМ СТРАНИЦУ HTML
#----------------------------------------------------------------------------------------
print "Content-type: text/html; charset=UTF-8\n\n";
print <<PART1;
<HTML>
<HEAD>
	<script language="JavaScript">
	    function ChangeURL() { 
		document.location="profile3.pl";
	  	}
	    function CreateCookie(name,value,expiredays) { 
		var todayDate = new Date();
		todayDate.setDate(todayDate.getDate()+expiredays);
		document.cookie=name+"="+value+"; expires="+todayDate.toGMTString()+"; path=/;";
		}
	</script>
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


