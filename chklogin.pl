#!/usr/bin/perl
use DBI;
use CGI qw(:standard);
use CGI qw(param);
use utf8;
binmode(STDOUT, ":utf8");

my $loginOK="Введите логин 6 и более символов";
my $argName=param('name');
my $loginImg="select_no.jpg";

if(length($argName)>5) {
    #----------------------------------------------------------------------------------------
    # СОЕДИЯНЕМСЯ С MYSQL
      my $dbh=mysql_connect();
      my $SQLStr=  "SELECT * FROM USER WHERE USERNAME='$argName'";
      my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
      if($cursor->rows <= 0) { $loginOK="OK"; $loginImg="select_ok.jpg"; }
      else		     { $loginOK="Логин занят"; } 
    }                     
#----------------------------------------------------------------------------------------
# ФОРМИРУЕМ СТРАНИЦУ HTML
#----------------------------------------------------------------------------------------
print "Content-type: text/html; charset=UTF-8\n\n";
print <<PART1;
<HTML>
<HEAD>
<TITLE>Проверка логина</TITLE>
</HEAD>
<BODY>
<script>
window.parent.document.getElementById('loginok').value='$loginOK'; 
window.parent.document.getElementById('loginokimg').src='/icons/site/$loginImg'; 
</script>            
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


