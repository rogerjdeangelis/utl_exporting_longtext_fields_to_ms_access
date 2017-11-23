Exporting longtext fields(up to 2gb) to MS Access

 Steps

  1. SAS comes with a sample Acess database (SAS and R cannot create a MS access database?)
     C:\Program Files\sashome\SASFoundation\9.4\access\sasmisc\demo.accdb
     Copy this accdb to d:/mdb/longtext.accdb
  2. Create a MS Access table 'longtext' using sashelp.class.
  3. Use passthru 'ADD column 'txt' with 'memo' field (max 2gb?) (memo was changed to longtext after 2010)
  4. Use passthru and a macro variable(max length ~65k) to update the longtext table

SOAPBOX ON
I really do not understand this love of
'proc import/export'.
There must be a lot of non-programmers out there?
SOAPBOX OFF


INPUT Microsoft Access Table
============================

 d:/mdb/longtext.accdb

  Table longtext total obs=19

      NAME       SEX    AGE

      Alfred      M      14
      Alice       F      13
      Barbara     F      13
      Carol       F      14
      Henry       M      14
      James       M      12
      Jane        F      12
      Janet       F      15
      Jeffrey     M      13
      John        M      12
      Joyce       F      11
      Judy        F      14
      Louise      F      12
      Mary        F      15
      Philip      M      16
      Robert      M      12
      Ronald      M      15
      Thomas      M      11
      William     M      15

PROCESS
=======
   WORKING CDE

    * add memo field to acess table;

    connect to access as mydb (Path="d:\mdb\longtext.accdb");
    execute(
      alter table [longtext]
      add column txt memo) by mydb;

    * update the added 'txt' field;
    set sashelp.class;

    txt=repeat(substr(name,1,3),3000);
    call symputx('txt',quote(strip(txt)));
    call symputx('name',quote(strip(name)));

    * there are other faster ways using a temp table with the memo field
      and then doing a passthru join on name;

    cmd1=resolve('
       proc sql dquote=ansi;
       connect to access as mydb (Path="d:\mdb\longtext.accdb");
       execute(
         update [longtext]
         set txt=&txt
         where name=&name
       ) by mydb;
       disconnect from mydb;
    Quit;

    call execute(cmd1);

OUTPUT
======

 d:/mdb/longtext.accdb

  Table longtext total obs=19

      NAME       SEX    AGE   TXT (9003 length)

      Alfred      M      14   AlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlfAlf...
      Alice       F      13   AliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAliAli...
      Barbara     F      13   BarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBarBar...
      Carol       F      14   CarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCarCar...
      Henry       M      14   HenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHenHen...
      James       M      12   JamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJamJam...
      Jane        F      12   JanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJan...
      Janet       F      15   JanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJanJan...
      Jeffrey     M      13   JefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJefJef...
      John        M      12   JohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJohJoh...
      Joyce       F      11   JoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoyJoy...
      Judy        F      14   JudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJudJud...
      Louise      F      12   LouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLouLou...
      Mary        F      15   MarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMarMar...
      Philip      M      16   PhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhiPhi...
      Robert      M      12   RobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRobRob...
      Ronald      M      15   RonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRonRon...
      Thomas      M      11   ThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoThoTho...
      William     M      15   WilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWilWil...


CHECK THE LENGTH
================

   proc sql dquote=ansi;
      connect to access (Path="d:\mdb\longtext.accdb");
        select * from connection to access
            (
             Select
                  max(len(txt))  as txt_length
             from
                  [longtext]
            );
        disconnect from access;
    quit;

     txt_length
    -----------
           9003


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

libname mdb "d:/mdb/longtext.accdb";

proc sql; drop table mdb.longtext; quit; * just in case you have longtext;

data mdb.longtext;
 set sashelp.class(keep=name age sex);;
run;quit;
libname mdb clear;

*          _     _   _        _               _
  __ _  __| | __| | | |___  _| |_    ___ ___ | |_   _ _ __ ___  _ __
 / _` |/ _` |/ _` | | __\ \/ / __|  / __/ _ \| | | | | '_ ` _ \| '_ \
| (_| | (_| | (_| | | |_ >  <| |_  | (_| (_) | | |_| | | | | | | | | |
 \__,_|\__,_|\__,_|  \__/_/\_\\__|  \___\___/|_|\__,_|_| |_| |_|_| |_|

;

proc sql dquote=ansi;
  connect to access as mydb (Path="d:\mdb\longtext.accdb");
    execute(
      alter table [longtext]
      add column txt memo) by mydb;
  disconnect from mydb;
Quit;

*                _       _         _        _
 _   _ _ __   __| | __ _| |_ ___  | |___  _| |_
| | | | '_ \ / _` |/ _` | __/ _ \ | __\ \/ / __|
| |_| | |_) | (_| | (_| | ||  __/ | |_ >  <| |_
 \__,_| .__/ \__,_|\__,_|\__\___|  \__/_/\_\\__|
      |_|
;

data _null_;
 length cmd1 $16000;
 set sashelp.class;
 length txt $9003;
 txt=repeat(substr(name,1,3),3000);
 call symputx('txt',quote(strip(txt)));
 call symputx('name',quote(strip(name)));
 cmd1=resolve('
    proc sql dquote=ansi;
    connect to access as mydb (Path="d:\mdb\longtext.accdb");
    execute(
      update [longtext]
      set txt=&txt
      where name=&name
    ) by mydb;
    disconnect from mydb;
Quit;
');
call execute(cmd1);
run;quit;

*     _               _
  ___| |__   ___  ___| | __
 / __| '_ \ / _ \/ __| |/ /
| (__| | | |  __/ (__|   <
 \___|_| |_|\___|\___|_|\_\

;
proc sql dquote=ansi;
   connect to access (Path="d:\mdb\longtext.accdb");
     select * from connection to access
         (
          Select
               max(len(txt))  as txt_length
          from
               [longtext]
         );
     disconnect from access;
 quit;


