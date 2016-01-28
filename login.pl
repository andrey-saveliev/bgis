#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $submitUserName=param('USERNAME');
my $submitUserPass=param('USERPASS');

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();
                     
#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ
my $SQLStr= "  SELECT COUNT(*) CNT FROM USER 
	 	WHERE USERNAME='$submitUserName' AND
		      USERPASS='$submitUserPass' 
	    ";
my $cursor = $dbh->prepare($SQLStr) or goto BADSQL;
   $cursor->execute; 
my $userFound = $cursor->fetchrow_hashref->{CNT};

#------------------------------------------------------------------------------------------------------------
if($userFound) {
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
		document.location="/cgi-bin/index.pl";
		}
	    function CreateCookie(name,value,expiredays) { 
		var todayDate = new Date();
		todayDate.setDate(todayDate.getDate()+expiredays);
		document.cookie=name+"="+value+"; expires="+todayDate.toGMTString()+"; path=/;";
		}
	</script>
	<script>
	    CreateCookie("BGISTKUSERNAME","$submitUserName",7);
	    CreateCookie("BGISTKUSERPASS","$submitUserPass",7);    
	</script>
    </head>
        <title>Аутентификация</title>
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
}

else {
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
		document.location="/cgi-bin/index.pl";
		}
	</script>
    </head>
        <title>Аутентификация</title>
    </head>

    <body>
	<div align=center>
	    <font style="color: #FF0000;">
		<B> Нет такого пользователя! 
	    </font>
	</div>
    </body>
    </html>
EOF
}
