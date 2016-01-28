#!/usr/bin/perl

#use strict;
use CGI qw(:standard);
use CGI qw(param);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $P1=checkStrn(param('V01'));
my $P2=checkStrn(param('V02'));
my $P3=checkStrn(param('V03'));
my $P4=checkDate(param('V04'));
my $P5=checkStrn(param('V05'));
my $P6=checkStrn(param('V06'));
my $P7=checkNumb(param('V07'));
my $P8=checkStrn(param('V08'));
my $PA=checkStrn(param('V10'));

my $rememberUsr=param('V10');
my $rememberPwd=param('V08');

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();

my $SQLStr="INSERT INTO USER(FAMILY,NAME,OTCHESTVO,BIRTH,GENDER,USERNAME,USERPASS,ADMIN,EMAIL) 
		   VALUES($P1,$P3,$P5,$P4,$P2,$PA,$P8,0,$P6)";
my $cursor = $dbh->do($SQLStr) or goto BADSQL;

#----------------------------------------------------------------------------------------
# Проверка прав доступа 
my $cookieUserName=$rememberUsr;
my $cookieUserPass=$rememberPwd;
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
my $studentGroup="<SELECT NAME=\"V03\">";
{ my $SQLStr=  "SELECT S.GRPID, S.GRPNUMB
		  FROM SGROUP S
		 ORDER BY S.GRPID";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $rowlst = $cursor->fetchall_arrayref;
  for my $i(0..$#{$rowlst}) {
	my $selectedItem="";
	if($rowlst->[$i][0] eq $studentInfo->{GRPID})	{ $selectedItem = " SELECTED "; }
	$studentGroup.="<OPTION VALUE=\"$rowlst->[$i][0]\" $selectedItem>$rowlst->[$i][1]</OPTION>";
	}
  $studentGroup.="</SELECT>";
}

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

    <script language="JavaScript" src="/javascript/essentials.js"></script>

    <script language="JavaScript"> 
    function checkInput() { 
	var flag=0;
	if(document.forms[0].V01.value.length==0 && !flag) { alert("Введите фамилию!"); flag=1; }
	if(document.forms[0].V03.value.length==0 && !flag) { alert("Введите имя!"); 	flag=1; }
	if(document.forms[0].V08.value != document.forms[0].V09.value && !flag) { alert("Пароли не совпадают!"); flag=1; }
	if(!flag) { document.forms[0].submit(); }
	}
    function CreateCookie(name,value,expiredays) { 
	var todayDate = new Date();
	todayDate.setDate(todayDate.getDate()+expiredays);
	document.cookie=name+"="+value+"; expires="+todayDate.toGMTString()+"; path=/;";
	}
    </script>
    <script>
	CreateCookie("BGISTKUSERNAME","$rememberUsr",7);
	CreateCookie("BGISTKUSERPASS","$rememberPwd",7);    
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
EOF

if($P7==1) { print <<P1;
		<h4>Редактирование информации о студенте</h4>
		<form method="post" action="registr2s_save.pl"> 
		<input type="hidden" name="V00" VALUE="$userInfo->{USERID}">
		<table width=90%>
		   <tr>	<td><b>Номер зачетной книжки</b></td>
			<td><input type="text" name="V01" VALUE="" MAXLENGTH=30 SIZE=16></td>
		   </tr>
		   <tr>	<td><b>Номер студенческого билета</b></td>
			<td><input type="text" name="V02" VALUE="" MAXLENGTH=30 SIZE=16></td>
		   </tr>
		   <tr>	<td><b>Группа</b></td>
			<td>$studentGroup</td>
		   </tr>
		   <tr>	<td colspan=2 align="center">
			<br><input type="button" onClick="document.forms[0].submit();" value="Сохранить">
			<td>
		   </tr>
		</table>
		</form>
P1
}
else { print <<P2;
 		<h4>Редактирование информации о преподавателе</h4>
		<form method="post" action="registr2p_save.pl"> 
		<input type="hidden" name="V00" VALUE="$userInfo->{USERID}">
		<table width=90%>
		   <tr>	<td><b>Научная степень</b></td>
			<td><input type="text" name="V01" VALUE="" MAXLENGTH=16 SIZE=16></td>
		   </tr>
		   <tr>	<td><b>Ученое звание</b></td>
			<td><input type="text" name="V02" VALUE="" MAXLENGTH=16 SIZE=16></td>
		   </tr>
		   <tr>	<td><b>Занимаемая должность</b></td>
			<td><input type="text" name="V03" VALUE="" MAXLENGTH=64 SIZE=32></td>
		   </tr>
		   <tr>	<td colspan=2 align="center">
			<br><input type="button" onClick="document.forms[0].submit();" value="Сохранить">
			<td>
		   </tr>
		</table>
		</form>
P2
}


print <<EOF;
            </div> <!-- /content-in -->
        </div> <!-- /content -->

        <hr class="noscreen" />

        <!-- Sidebar --------------------------------------------------------->
        <div id="aside">

            <!-- News -->             
            <h4 id="aside-title">Шаг 2</h4>

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


