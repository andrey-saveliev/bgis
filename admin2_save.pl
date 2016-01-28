#!/usr/bin/perl
use DBI;
use CGI qw(:standard);
use CGI qw(param);
use utf8;
binmode(STDOUT, ":utf8");

#----------------------------------------------------------------------------------------
# СОЕДИЯНЕМСЯ С MYSQL
my $dbh=mysql_connect();
my $debug;
#----------------------------------------------------------------------------------------
my $GRPID=checkNumb(param('V00'));
my $SEMID;
{ my $SQLStr=  "SELECT max(SEMID) MAXSEMID FROM SEMESTR";
  my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute; 
  my $semestrInfo = $cursor->fetchrow_hashref;
  $SEMID = $semestrInfo->{MAXSEMID};
}

for my $day(1..6) {
  for my $lenta(1..7) {
     for my $week(1..2) {
	my $getCourse  = "C_" . $day . "_" . $lenta. "_" . $week;
	my $getTeacher = "T_" . $day . "_" . $lenta. "_" . $week;
	my $getRoom    = "A_" . $day . "_" . $lenta. "_" . $week;

        my $paramCourse  = param($getCourse);
	my $rowIsEmpty=0; $_=$paramCourse; if(!/\S+/) { $rowIsEmpty=1; }
	$paramCourse = checkStrn($paramCourse);

        my $paramTeacher = $_ = param($getTeacher);
	#$debug=$paramTeacher; goto BADSQL;
        if(/^(\d+)\s/) { $paramTeacher=$1; } else { $paramTeacher="NULL"; }

	my $paramRID;
      { my $paramRoom    = checkStrn(param($getRoom));
      	my $SQLStr=  "SELECT RID FROM AUDITORY WHERE ROOM=$paramRoom";
 	my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute;
  	my $roomInfo = $cursor->fetchrow_hashref;
	$_=$roomInfo->{RID}; 
	if(/\d+/) { $paramRID = $roomInfo->{RID}; }
	else	  { $paramRID = "NULL"; }
      }

        # Проверяем, есть ли такая запись
	my $thereInBase=0;
	my $rowID;
      {	my $SQLStr=  "SELECT ID FROM SHEDULE S
		 WHERE SEMID=$SEMID AND GRPID=$GRPID AND DAY=$day AND LENTA=$lenta AND week=$week ";
 	my $cursor = $dbh->prepare($SQLStr) or goto BADSQL; $cursor->execute;
  	my $sheduleInfo = $cursor->fetchrow_hashref;
	if($cursor->rows > 0) {
		$thereInBase = 1;
		$rowID = $sheduleInfo->{ID};
		}
      }
        # Удалить
        if($thereInBase && $rowIsEmpty) {
		my $SQLStr =  "DELETE FROM SHEDULE
			    WHERE SEMID=$SEMID AND GRPID=$GRPID AND DAY=$day AND LENTA=$lenta AND week=$week ";
		$cursor = $dbh->do($SQLStr) or goto BADSQL;
		}
	# Изменить	
        if($thereInBase && !$rowIsEmpty) {
		my $SQLStr =  "UPDATE SHEDULE SET COURSE=$paramCourse, TEACHER=$paramTeacher, ROOM=$paramRID
			    WHERE SEMID=$SEMID AND GRPID=$GRPID AND DAY=$day AND LENTA=$lenta AND week=$week ";
		$cursor = $dbh->do($SQLStr) or goto BADSQL;
		}
	# Добавить
        if(!$thereInBase && !$rowIsEmpty) {
		my $SQLStr =  "INSERT INTO SHEDULE (COURSE,GRPID,ROOM,SEMID,WEEK,DAY,LENTA,TEACHER) VALUES
				($paramCourse,$GRPID,$paramRID,$SEMID,$week,$day,$lenta,$paramTeacher) ";
		$cursor = $dbh->do($SQLStr) or goto BADSQL;
		}
	}
     }
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
		document.location="/cgi-bin/admin2.pl?g=$GRPID";
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
return;

BADSQL:
print "Content-type: text/html; charset=UTF-8\n\n";
print $debug;

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


