PROC DATASETS NOPRINT LIB=WORK KILL;
RUN;
QUIT;

DM ODSRESULTS 'CLEAR;';
DM LOG 'CLEAR;';



PROC IMPORT OUT = COVID1 DATAFILE= "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Txt\Output\Complete Data Set (2020-06-06).xlsx"
DBMS=XLSX REPLACE;
GETNAMES=YES;
DATAROW=2;
RUN;

%MACRO IMPORTER (DSET, FILE);
proc import OUT = &DSET DATAFILE="C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Census\&FILE"
DBMS=XLSX REPLACE;
GETNAMES=YES;
RUN;
%MEND;

%IMPORTER (INC, 

DATA COVID;
SET COVID1;
	ARRAY CONSOL AWAITING_TESTING AWAITING_BPHL_TESTING AWAITING_TESTING_1;
		DO OVER CONSOL;
		IF CONSOL NE . THEN AWAIT_TEST = CONSOL;
		END;
ARRAY CONSOL2 TOTAL_TESTED TOTAL;
	DO OVER CONSOL2;
	IF CONSOL2 NE . THEN TOT = CONSOL2;
	END;


IF AWAIT_TEST =. THEN AWAIT_TEST = 0;
IF INCONCLUSIVE =. THEN INCONCLUSIVE = 0;
IF COUNTY = "" THEN COUNTY = "UNKOWN";
DROP AWAITING_TESTING AWAITING_BPHL_TESTING AWAITING_TESTING_1 TOTAL_TESTED TOTAL;
RENAME AWAIT_TEST = AWAITING_TESTING TOT = TOTAL_TESTED;
RUN;

/*PROC EXPORT DATA = COVID OUTFILE = 'C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\FINAL COVID DATA SET (6-6-20)'*/
/*DBMS =XLSX REPLACE;*/
/*RUN;*/
/**/
/*PROC EXPORT DATA = COVID OUTFILE = 'C:\Users\Daniel chacreton\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\FINAL COVID DATA SET (6-6-20)'*/
/*DBMS =XLSX REPLACE;*/
/*RUN;*/

PROC MEANS DATA = COVID;
VAR NEW_CASES;
RUN;