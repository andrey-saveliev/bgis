#!/usr/bin/perl
use DBI;
use CGI qw(:standard);
use CGI qw(param);
use utf8;
binmode(STDOUT, ":utf8");

my $P0=param('id');

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();

{ $SQLStr="DELETE FROM NEWS WHERE NID=$P0";
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
		document.location="/cgi-bin/news3.pl";
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


