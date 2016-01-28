#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

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
	    function deleteCookie(name) { 
		var todayDate = new Date();
		todayDate.setDate(todayDate.getDate()-1);
		value=ReadCookie(name);
		document.cookie = name+"="+value+"; expires="+todayDate.toGMTString()+";";
		}  
	</script>
	<script>
	    CreateCookie("BGISTKUSERNAME","noLogin",7);
	    CreateCookie("BGISTKUSERPASS","noLogin",7);    
	</script>
    </head>
        <title>Выход из портала</title>
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
