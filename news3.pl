#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $topic; $_=param('t');
if(/^\d$/) { $topic=$_; } else { $topic=0; }

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();

#----------------------------------------------------------------------------------------
# Проверка прав доступа 
my $cookieUserName=cookie('BGISTKUSERNAME');
my $cookieUserPass=cookie('BGISTKUSERPASS');
my $userLoggedIn  =0;
my $userInfo;
my $userRole = "";
my $newsList = "";

{ my $SQLStr=  "SELECT U.*, R.STUDENT, R.TEACHER, R.ADMIN 
		  FROM USER U JOIN V_ROLES R ON U.USERID=R.USERID
		 WHERE U.USERNAME='$cookieUserName' AND U.USERPASS='$cookieUserPass' ";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  if($cursor->rows > 0) { $userLoggedIn=1; } 
  $userInfo = $cursor->fetchrow_hashref;
  if($userInfo->{STUDENT} > 0) { $userRole .= "Студент "; }
  if($userInfo->{TEACHER} > 0) { $userRole .= "Преподаватель "; }
  if($userInfo->{ADMIN}   > 0) { $userRole .= "Администратор "; }
}

{ my $SQLStr=  "SELECT N.*, U.FAMILY, U.NAME, U.ADMIN FROM NEWS N JOIN USER U ON N.USERID=U.USERID 
		WHERE N.USERID=$userInfo->{USERID} ORDER BY NEWSDAY DESC";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  while(my $newsInfo = $cursor->fetchrow_hashref) {
	my $isAdmin=""; if($newsInfo->{ADMIN}) { $isAdmin=" (админ.) "; }
	$newsList .= "<table width=\"100%\"><tr><td width=\"75%\"><h4>$newsInfo->{NEWSDAY}</h4></td>";
	$newsList .= "<td><a href=\"/cgi-bin/newsed.pl?id=$newsInfo->{NID}\">Исправить</a></td>";
	$newsList .= "<td><a href=\"javascript:deleteMe($newsInfo->{NID})\">Удалить</a></td>";
	$newsList .= "</tr></table>";
	$newsList .= "<div width=\"100%\">$newsInfo->{MESSAGE}</div>";
	$newsList .= "<i>$newsInfo->{FAMILY} $newsInfo->{NAME} $isAdmin</i>\n";
	}
}

#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ
#------------------------------------------------------------------------------------------------------------
my $ctopic = "Мои новости";
    my @TOPIC     = ("Новости МГТУ", );
    my @TOPICURLS = ("/cgi-bin/news.pl", );

    if($userInfo->{ADMIN} > 0 || $userInfo->{TEACHER} > 0)
      { push(@TOPIC,"Создать новость"); push(@TOPICURLS, "/cgi-bin/news2.pl"); }
    if($userInfo->{ADMIN} > 0 || $userInfo->{TEACHER} > 0)
      { push(@TOPIC,"Мои новости"); push(@TOPICURLS, "/cgi-bin/news3.pl"); }

    my $topicLinks="";
    for my $i (0..@TOPIC-1) {
	if(@TOPIC[$i] eq $ctopic) { @TOPIC[$i]="<b>".@TOPIC[$i]."</b>"; }
	$topicLinks .= "<dl id=\"news\"> <dd> <a href=\"@TOPICURLS[$i]\">@TOPIC[$i]</a> </dd> </dl>\n";
	}

#------------------------------------------------------------------------------------------------------------
my  $page = "Новости";
    my $mainMenuPoints = "";
    my @MAINMENU = ("Главная", "Информация", "Карта", "Новости" );
    my @MENUURLS = ("/cgi-bin/index.pl", "/cgi-bin/info.pl",  "/cgi-bin/maps.pl", "/cgi-bin/news.pl" );
    if($userLoggedIn)			{ push(@MAINMENU,"Обратная связь"); push(@MENUURLS, "/cgi-bin/chat.pl"); }
    if($userLoggedIn)			{ push(@MAINMENU,"Профиль"); push(@MENUURLS, "/cgi-bin/profile.pl"); }
    if($userInfo->{ADMIN} > 0) 		{ push(@MAINMENU,"Настройки"); push(@MENUURLS, "/cgi-bin/admin.pl"); }

    for my $i (0..@MAINMENU-1) {
	my $inactive=" "; 
	if(@MAINMENU[$i] eq $page) { 
		$inactive = " id=\"nav-active\" "; 
		@MENUURLS[$i] = "#";
		}
	$mainMenuPoints .= " <li $inactive> <a href=\"@MENUURLS[$i]\"> @MAINMENU[$i] </a></li> \n";
	}
#------------------------------------------------------------------------------------------------------------
print "Content-type: text/html\r\n\r\n";
print <<EOF;
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="content-language" content="ru" />
    <meta name="robots" content="all,follow" />

    <meta name="description" content="Геоинформационный портал Вуза" />
    <meta name="keywords" content="ГИС геоинформационный портал Вуза" />
    
    <link rel="stylesheet" media="screen,projection" type="text/css" href="/css/main.css" />
    <!--[if lte IE 6]><link rel="stylesheet" type="text/css" href="/css/main-msie.css" /><![endif]-->
    <link rel="stylesheet" media="screen,projection" type="text/css" href="/css/scheme.css" />
    <link rel="stylesheet" media="print" type="text/css" href="/css/print.css" />

    <script language="JavaScript" src="/javascript/essentials.js"></script>

    <script language="JavaScript">
      function deleteMe(n) { 
	document.location="/cgi-bin/newsdel.pl?id="+n;
	}
    </script>

    <title>Геоинформационный портал Вуза</title>
</head>

<body>

<div id="main">

    <!-- Заголовок ----------------------------------------------------------->
    <div id="header">
        <hr class="noscreen" />        
        <hr class="noscreen" />        
        <!-- Hidden navigation -->
        <p class="noscreen noprint">
		<em>Quick links: <a href="#content">content</a>, 
		    <a href="#nav">navigation</a>.
		</em>
	</p>
        <hr class="noscreen" />
    </div> 
    <!-- /Заголовок ---------------------------------------------------------->

    <div id="nav">
        <ul class="box">
	    $mainMenuPoints
        </ul>
    <hr class="noscreen" /> 
    </div> <!-- /nav -->

    <!-- 2 columns (content + sidebar) -->
    <div id="cols" class="box">

        <!-- Content -->
        <div id="content">
            <div id="content-in"  style="text-align:justify;">
		$newsList
            </div> <!-- /content-in -->
        </div> <!-- /content -->

        <hr class="noscreen" />

        <!-- Sidebar --------------------------------------------------------->
        <div id="aside">

            <!-- News -->             
            <h4 id="aside-title">Новости</h4>

            
            <div class="aside-in">
                <div class="aside-box">
		    $topicLinks
                </div> <!-- /aside-box -->
            </div> <!-- /aside-in -->
            
   
        </div> 
	<!-- /aside ---------------------------------------------------------->
    
    </div> <!-- /cols -->
    
    <div id="cols-bottom"></div>
    <hr class="noscreen" />
    
    <!-- Footer -->
    <div id="footer">
        <p>&copy;&nbsp;2015 <a href="http://www.bmstu.ru/">МГТУ им. Н. Э. Баумана</a></p>
    </div> 
    <!-- /footer -->

</div> <!-- /main -->

</body>
</html>
EOF
