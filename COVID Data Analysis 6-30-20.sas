
PROC DATASETS NOPRINT LIB=WORK KILL;
RUN;
QUIT;

DM LOG "CLEAR;";

*IMPORTING CENSUS DATA;
*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;

	%MACRO IMPORTER(DSET, FILE);
	PROC IMPORT OUT = &DSET DATAFILE= "C:\Users\chacr\OneDrive\Documents\Coding\Python\USF\COVID-19 Project\Data\&FILE"
	DBMS = XLSX REPLACE;
	GETNAMES= YES;
	DATAROW = 2;
	RUN;
	%MEND;



	%MACRO SORTI(DSET, VAR1, VAR2, VAR3);
	PROC SORT DATA =&DSET;
	BY &VAR1 &VAR2 &VAR3;
	RUN;
	%MEND;

	%MACRO EXPORTER (DSET, FILEPATH, SHEET);
	PROC EXPORT DATA = &DSET OUTFILE = &FILEPATH
	DBMS = XLSX REPLACE;
	SHEET= &SHEET;
	RUN;
	%MEND;

%IMPORTER(COVID ,Final Combined Dataset COVID & Census (6-6-20).XLSX);

*IMPORTING COVID DATA;
*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;
DM LOG "CLEAR;";
DM ODSRESULTS 'CLEAR;';
%SORTI(COVID, DATE);
*DATA ANALYSIS;
*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;

*CHECKING ASSUMPTIONS;
	*//////////////////////////////////////;
	PROC UNIVARIATE DATA = COVID NORMAL PLOTS;
	VAR NEW_CASES;
	HISTOGRAM NEW_CASES /NORMAL ;
	RUN;

*DESCRIPTIVE ANALYSIS;
	*//////////////////////////////////////;

PROC MEANS MEAN VAR STD MIN MAX RANGE DATA =COVID;
VAR NEW_CASES;
RUN;


	PROC MEANS noprint SUM DATA = COVID;
	BY DATE;
	VAR NEW_CASES;
	OUTPUT OUT= SUM_BY_DATE SUM=NEW_CASES;
	RUN;

	PROC MEANS DATA = COVID;
	VAR NEW_CASES;
	RUN;
	*CORRELATION ANALYSIS;
	*//////////////////////////////////////;
		DATA TRANS;
		SET COVID;
		KEEP COUNTY NEW_CASES DATE;
		RUN; 

		%SORTI(TRANS, COUNTY);
		
		PROC TRANSPOSE DATA = TRANS OUT = T_TRANS;
		BY COUNTY ;
		VAR NEW_CASES;
		RUN;

		PROC CORR DATA = T_TRANS;
		VAR COL1-COL75;
		RUN;

*ADD A ODS OUTPUT FORMAT TO MAKE THE GRAPH BIGGER;
	PROC SGPLOT DATA =COVID;
	SERIES X = DATE Y = NEW_CASES/ GROUP = COUNTY;
	TITLE 'Spagetti Plot Daily Number of New Cases';
	RUN;

	PROC SGPLOT DATA = SUM_BY_DATE;
	SERIES X = DATE Y = NEW_CASES;
	TITLE'Number of New COVID-19 Cases State-wide';
	RUN;
*MODELING;
	*//////////////////////////////////////;

