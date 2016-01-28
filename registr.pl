#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

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

#----------------------------------------------------------------------------------------
# ВЫПОЛНЯЕМ SQL-ЗАПРОСЫ
#------------------------------------------------------------------------------------------------------------
my  $page = "Главная";
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
    function checkInput() { 
	var flag=0;
	if(document.forms[0].V01.value.length==0 && !flag) { alert("Введите фамилию!"); flag=1; }
	if(document.forms[0].V03.value.length==0 && !flag) { alert("Введите имя!"); 	flag=1; }
	if(document.forms[0].V08.value.length <1 && !flag) { alert("Введите пароль!"); flag=1; }
	if(document.forms[0].V08.value != document.forms[0].V09.value && !flag) { alert("Пароли не совпадают!"); flag=1; }
	if(!flag) { document.forms[0].submit(); }
	}
    function isLoginOK(t) { 
	var userName=t.value; 
	var addr='/cgi-bin/chklogin.pl?name='+userName;
	document.getElementById('CHKLOGIN').src=addr;
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

		<h4>Регистрация нового пользователя</h4>
		<form method="post" action="registr2.pl"> 
		<input type="hidden" name="V00" VALUE="$userInfo->{USERID}">
		<table>
		   <tr>	<td><b>Фамилия</b></td>
			<td><input type="text" name="V01" VALUE="" MAXLENGTH=62></td>
		   	<td><b>Пол</b></td>
			<td>	<input type="radio" name="V02" VALUE="М" > - Мужской
				<input type="radio" name="V02" VALUE="Ж" > - Женский   
				<input type="radio" name="V02" VALUE="" CHECKED> - Нет 	   
			</td>
		   </tr>

		   <tr>	<td><b>Имя</b></td>
			<td><input type="text" name="V03" VALUE="" MAXLENGTH=62></td>
		   	<td><b>Дата рождения</b></td>
			<td><input type="text"  id="V04" name="V04" VALUE="" onFocus="this.blur()"></td>
		   </tr>

		   <tr>	<td><b>Отчество</b></td>
			<td><input type="text" name="V05" VALUE="" MAXLENGTH=62></td>
			<td><b>E-mail</b></td>
			<td><input type="text" name="V06" VALUE="" MAXLENGTH=62></td>
		   </tr>
		   <tr>
		  	<td><b>Пароль</b></td>
			<td><input type="password" name="V08" VALUE="" MAXLENGTH=15></td>
			<td><b>Тип</b></td>
			<td>
				<input type="radio" name="V07" VALUE="1" CHECKED> - Студент &nbsp;&nbsp;
				<input type="radio" name="V07" VALUE="2" > - Преподаватель   
			</td>
		   </tr>

		   <tr>	<td><b>Еще раз</b></td>
			<td><input type="password" name="V09" VALUE="" MAXLENGTH=15></td>
			<td><b>Логин</b></td>
			<td><input type="text" name="V10" VALUE="" MAXLENGTH=62 onChange="isLoginOK(this)">
			    <img id="loginokimg" src="/icons/site/select_no.jpg" /><br>
			    <input type="text" name="LOGINOK" id="loginok" VALUE="" MAXLENGTH=15 SIZE="34" STYLE="font-family: arial; font-size: 8pt; border: none;">
			</td>
		   </tr>

		   <tr>	<td colspan=4 align="center">
			<br><input type="button" onClick="checkInput()" value="Далее">
			<td>
		   </tr>
		</table>

		<iframe src="/cgi-bin/chklogin.pl" id="CHKLOGIN" 
			width="98%" height="10" SCROLLING=NO FRAMEBORDER=0>
		</iframe>
		</form>

            </div> <!-- /content-in -->
        </div> <!-- /content -->

        <hr class="noscreen" />

        <!-- Sidebar --------------------------------------------------------->
        <div id="aside">

            <!-- News -->             
            <h4 id="aside-title">Шаг 1</h4>

            
            <div class="aside-in">
                <div class="aside-box">
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
