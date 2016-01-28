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
my $myGroupId;
my $allGroups;
my $groupList;
my $listItems;

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

{ my $SQLStr=  "SELECT G.GRPID, G.GRPNUMB FROM SGROUP G ORDER BY G.GRPID";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  $allGroups = $cursor->fetchall_arrayref;
}

{  if($userInfo->{STUDENT} > 0) {  
	my $SQLStr=  "SELECT S.GRPID FROM STUDENT S
		       WHERE S.USERID=$userInfo->{USERID}";
	my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
	my $groupInfo = $cursor->fetchrow_hashref;
	$myGroupId = $groupInfo->{GRPID};
	}
   else { $myGroupId = $allGroups->[0][0]; }
}

$listItems.="<table>";
{ my @CODES=("", "К", "Ч", "П" );
  my $code=@CODES[$topic];
  my $SQLStr=  "SELECT * FROM PLACES WHERE CODE='$code' ORDER BY FLOOR";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute;

  while(my $placeInfo = $cursor->fetchrow_hashref) {
	my $delta=$placeInfo->{SCALE}; 
	my $minX = $placeInfo->{X} - $delta;
	my $maxX = $placeInfo->{X} + $delta;
	my $minY = $placeInfo->{Y} - $delta;
	my $maxY = $placeInfo->{Y} + $delta;

	if(length($placeInfo->{FLOOR})<2) { $placeInfo->{FLOOR}="0".$placeInfo->{FLOOR}; }
	my $mapURL="/cgi-bin/mapserv.cgi?mode=browse&map=/var/lib/openshift/552760adfcf9332f530001fe/app-root/repo/gismap/".
		   $placeInfo->{FLOOR}."/floor.map&mapext=$minX+$minY+$maxX+$maxY&layer=OBJECT";
	$listItems.="<tr>";
	$listItems.="<td><a href=\"$mapURL\">$placeInfo->{NAME}</a></td>";
	$listItems.="</tr>";
	}
}
$listItems.="</table>";

#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ
#------------------------------------------------------------------------------------------------------------
    my @TOPIC   = ("Расписание групп", "Кафедры", "Библиотеки", "Буфеты и столовые");
    my $topic=@TOPIC[$topic]; 
    my @TOPICURLS = ("/cgi-bin/info.pl", "/cgi-bin/info2.pl?t=1", "/cgi-bin/info2.pl?t=2", "/cgi-bin/info2.pl?t=3");

    my $topicLinks="";
    for my $i (0..@TOPIC-1) {
	if(@TOPIC[$i] eq $topic) { @TOPIC[$i]="<b>".@TOPIC[$i]."</b>"; }
	$topicLinks .= "<dl id=\"news\"> <dd> <a href=\"@TOPICURLS[$i]\">@TOPIC[$i]</a> </dd> </dl>\n";
	}

#------------------------------------------------------------------------------------------------------------
my  $page = "Информация";
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
      function gotoGroup() { 
	 var val=document.forms[0].V01.options[document.forms[0].V01.selectedIndex].value;
	 document.getElementById("GROUPLIST").contentWindow.location="/cgi-bin/schedule_grp.pl?g=" + val;
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
        <form>
	<div id="content">
            <div id="content-in"  style="text-align:justify;">
 	
		<h4> $topic </h4>
                $listItems

            </div> <!-- /content-in -->
        </div> <!-- /content -->
	</form>

        <hr class="noscreen" />

        <!-- Sidebar --------------------------------------------------------->
        <div id="aside">

            <!-- News -->             
            <h4 id="aside-title">Информация</h4>

            
            <div class="aside-in">
                <div class="aside-box">
		    $topicLinks
                </div> <!-- /aside-box -->

<a href="http://meteoinfo.ru/forecasts5000/russia/moscow-area/moscow">
<img src="http://www.meteoinfo.ru/informer/informer.php?ind=27612&type=1&color=0" alt="Гидрометцентр России" border="0" height="100" width="100"></a>

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
