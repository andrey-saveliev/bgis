#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $myGroupId; $_=param('g');
if(/^\d$/) { $myGroupId=$_; } else { $myGroupId=1; }

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
my @GENDER=("","","");
my $allGroups;
my $groupList;
my $groupDataList;
my $teacherDataList;

{ my $SQLStr=  "SELECT U.*, R.STUDENT, R.TEACHER, R.ADMIN 
		  FROM USER U JOIN V_ROLES R ON U.USERID=R.USERID
		 WHERE U.USERNAME='$cookieUserName' AND U.USERPASS='$cookieUserPass' ";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  if($cursor->rows > 0) { $userLoggedIn=1; } 
  $userInfo = $cursor->fetchrow_hashref;
  if($userInfo->{STUDENT} > 0) { $userRole .= "Студент "; }
  if($userInfo->{TEACHER} > 0) { $userRole .= "Преподаватель "; }
  if($userInfo->{ADMIN}   > 0) { $userRole .= "Администратор "; }
  if($userInfo->{GENDER} eq "М") 	{ @GENDER[0] = " checked "; }
  elsif($userInfo->{GENDER} eq "Ж") 	{ @GENDER[1] = " checked "; }
  else					{ @GENDER[2] = " checked "; }
}

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

$groupList="<select name=\"V01\" onChange=\"gotoGroup(this)\">";
{ for my $i(0..$#{$allGroups}) {
	my $selectedItem="";
	if($allGroups->[$i][0] eq $myGroupId)	{ $selectedItem = " SELECTED "; }
	$groupList.="<OPTION VALUE=\"$allGroups->[$i][0]\" $selectedItem>$allGroups->[$i][1]</OPTION>";
	$groupDataList.="<option value=\"$allGroups->[$i][1]\" />";
	}
}
$groupList.="</select>";

$groupDataList="<datalist id=\"auditoryList\">";
{ my $SQLStr=  "SELECT ROOM FROM AUDITORY ORDER BY ROOM";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $auds = $cursor->fetchall_arrayref;
  for my $i(0..$#{$auds}) { $groupDataList.="<option value=\"$auds->[$i][0]\" />"; }
}
$groupDataList.="</datalist>";

$teacherDataList="\n<datalist id=\"teacherList\">";
{ my $SQLStr=  "SELECT USERID, FAMILY, NAME, OTCHESTVO FROM V_TEACHERS ORDER BY FAMILY";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $teacherTab = $cursor->fetchall_arrayref;
  for my $i(0..$#{$teacherTab}) { 
	my $teacherName=substr($teacherTab->[$i][2],0,1);
	my $teacherOtch=substr($teacherTab->[$i][3],0,1);
	$teacherDataList.="\n<option value=\"$teacherTab->[$i][0] $teacherTab->[$i][1] $teacherName.$teacherOtch.\" />"; 
	}
}
$teacherDataList.="\n</datalist>";

#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ

#------------------------------------------------------------------------------------------------------------
my $topic="Расписание"; 
    my @TOPIC   = ("Описание и назначение сайта", "Контактная информация", "Правила сайта", "Расписание");    my @TOPICURLS = ("/cgi-bin/profile.pl", "/cgi-bin/profile2.pl");
    my @TOPICURLS = ("/cgi-bin/admin.pl?t=0", "/cgi-bin/admin.pl?t=1", 
		     "/cgi-bin/admin.pl?t=2", "/cgi-bin/admin2.pl");
    my $topicLinks="";
    for my $i (0..@TOPIC-1) {
	if(@TOPIC[$i] eq $topic) { @TOPIC[$i]="<b>".@TOPIC[$i]."</b>"; }
	$topicLinks .= "<dl id=\"news\"> <dd> <a href=\"@TOPICURLS[$i]\">@TOPIC[$i]</a> </dd> </dl>\n";
	}

#------------------------------------------------------------------------------------------------------------
my  $page = "Настройки";
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

    <link rel="stylesheet" type="text/css" href="/javascript/codebase/dhtmlxcalendar.css"/>
    <script src="/javascript/codebase/dhtmlxcalendar.js"></script>
    <style>
 	#V04
	 {
		border: 1px solid #909090;
		font-family: Tahoma;
		font-size: 12px;
	 }
    </style>
    <script>
	var myCalendar;
	function doOnLoad() {
		myCalendar = new dhtmlXCalendarObject(
		["V04"]
		);
		dhtmlXCalendarObject.prototype.langData["ru"] = {
			dateformat: '%d.%m.%Y',
			monthesFNames: ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"],
			monthesSNames: ["Янв","Фев","Мар","Апр","Май","Июн","Июл","Авг","Сен","Окт","Ноя","Дек"],
			daysFNames: ["Воскресенье","Понедельник","Вторник","Среда","Четверг","Пятница","Суббота"],
			daysSNames: ["Вс","Пн","Вт","Ср","Чт","Пт","Сб"],
			weekstart: 1,
			weekname: "н"
		        }
		myCalendar.loadUserLanguage('ru');
		myCalendar.setDateFormat("%Y-%m-%d");
	}
    </script>
   
    <script language="JavaScript" src="/javascript/essentials.js"></script>

    <script language="JavaScript"> 
      function gotoGroup() { 
	 var val=document.forms[0].V01.options[document.forms[0].V01.selectedIndex].value;
	 document.location="/cgi-bin/admin2.pl?g=" + val;
	}
    </script>

    <title>Геоинформационный портал Вуза</title>
</head>

<body onLoad="doOnLoad();">

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
		<form method="post" action="admin2_save.pl"> 
		<h4>Редактирование расписания группы </h4> $groupList
		<input type="hidden" name="V00" VALUE="$myGroupId">
		$groupDataList
		$teacherDataList
		<table width="100%" id="schedule_tab" style="border: 1px black;">
EOF

my @DAYS=("Дни недели","Пн","Вт","Ср","Чт","Пт","Сб","Вс");
my @LTIME=("Начало ленты","8:30-10:05","10:15-11:50","12:00-13:35",
	"13:50-15:25","15:40-17:15","17:25-19:00","19:10-20:45");
my @WEEKS=("Недели","чс","зн");

for my $day(1..6) {
  for my $lenta(1..7) {
     for my $week(1..2) {
	print "<tr valign=top>";
	if($lenta==1 && $week==1)
	 	{ print "<td rowspan=14>@DAYS[$day]</td>"; }
        if($week==1) 	
		{ print "<td rowspan=2>@LTIME[$lenta]</td>"; }
	print "<td>@WEEKS[$week]</td>"; 


	my $SQLStr=  "SELECT COURSE, ROOMNUMB, FAMILY, ROOM, USERID FROM V_GRPSHED 
		       WHERE GRPID=$myGroupId AND DAY=$day AND LENTA=$lenta AND WEEK=$week";
	my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
	my $scheduleInfo = $cursor->fetchrow_hashref;

	print "<td><input type=\"text\" name=\"C_",$day,"_",$lenta,"_",$week,"\" VALUE=\"$scheduleInfo->{COURSE}\" size=32 MAXLENGTH=64></td>"; 
	print "<td><input list=\"auditoryList\" name=\"A_", $day, "_", $lenta, "_", $week, "\" VALUE=\"$scheduleInfo->{ROOMNUMB}\" size=8 maxlength=16/></td>"; 
	print "<td><input list=\"teacherList\"  name=\"T_", $day, "_", $lenta, "_", $week, "\" VALUE=\"$scheduleInfo->{USERID} $scheduleInfo->{FAMILY}\"   size=8 maxlength=16/></td>"; 
	print "</tr>";
	}
     }
     print "<tr height=1><td colspan=6 bgcolor=\"#8888aa\"></td></tr>";
  }
		



print <<EOF;
		</table>
	        <br><input type="submit" value="Сохранить">
		</form>

            </div> <!-- /content-in -->
        </div> <!-- /content -->

        <hr class="noscreen" />

        <!-- Sidebar --------------------------------------------------------->
        <div id="aside">

            <!-- News -->             
            <h4 id="aside-title">Настройки</h4>

            
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
