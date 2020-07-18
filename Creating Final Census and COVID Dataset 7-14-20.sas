
PROC DATASETS NOPRINT LIB=WORK KILL;
RUN;
QUIT;

DM LOG "CLEAR;";

*IMPORTING CENSUS DATA;
*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;

	%MACRO IMPORTER(DSET, FILE);
	PROC IMPORT OUT = T_&DSET DATAFILE= "C:\Users\chacr\OneDrive\Documents\Coding\Python\USF\COVID-19 Project\Data\&FILE"
	DBMS = XLSX REPLACE;
	GETNAMES= YES;
	DATAROW = 2;
	RUN;

	DATA &DSET;
	LENGTH COUNTY $20.;
	SET T_&DSET;
	IF  FIND(GEO_ID, "ID", "I") THEN DELETE;

	COUNTY = UPCASE(SUBSTR(NAME, 1, INDEX(NAME," County")));
	RUN;


	PROC SORT DATA =&DSET;
	BY COUNTY;
	RUN;

	%MEND;

	%IMPORTER(INC1  ,CENSUS\FLORIDA 2018 MEDIAN INCOME.XLSX);
	%IMPORTER(EDU1  ,CENSUS\FLORIDA EDUCATION 2018.XLSX);
	%IMPORTER(RACE1 ,CENSUS\FLORIDA RACE & POP 2018.XLSX);
	%IMPORTER(AGE1 ,CENSUS\FLORIDA MEDIAN AGE 2018.XLSX);

	%MACRO SORTI(DSET, VAR1, VAR2, VAR3);
	PROC SORT DATA =&DSET;
	BY &VAR1 &VAR2 &VAR3;
	RUN;
	%MEND;

	DATA INC;
	SET INC1;
	KEEP S1901_C01_012E COUNTY;
	RUN;

	DATA RACE;
	SET RACE1;
	KEEP COUNTY DP05_0001E DP05_0037PE DP05_0038PE DP05_0039PE DP05_0044PE DP05_0052PE;
	RUN ;


	DATA AGE;
	SET AGE1;
	KEEP COUNTY S0101_C01_032E;
	RUN ;


	DATA EDU;
	SET EDU1;
	KEEP COUNTY S1501_C02_002E S1501_C02_009E ;
	RUN ;

	%SORTI(AGE, COUNTY);
	%SORTI(EDU , COUNTY);
	%SORTI(INC , COUNTY);
	%SORTI(RACE , COUNTY);

	DATA FINAL_CENSUS;
	MERGE AGE EDU INC RACE;
	BY COUNTY;

	RUN;
	PROC DATASETS NOPRINT; 
	DELETE AGE AGE1 EDU EDU1 INC INC1 RACE RACE1 t_INC1 T_EDU1 T_AGE1 T_RACE1;
	RUN;
	QUIT;

	proc import out = RWJ1 datafile= "C:\Users\chacr\OneDrive\Documents\Coding\Python\USF\COVID-19 Project\Data\RWJ Data\FL_CHR_2020.xls"
	DBMS = xls REPLACE;
	GETNAMES = YES;
	DATAROW=2;
	RUN;

	DATA RWJ;
	SET RWJ1;
		COUNTY = UPCASE(COUNTY);
	RUN;

*IMPORTING COVID DATA;
*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;

	proc import out = covid1 datafile= "C:\Users\chacr\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\Final COVID Only Dataset 7-17-2020 (CLEAN).xlsx"
	DBMS = xlsx REPLACE;
	GETNAMES = YES;
	DATAROW=2;
	SHEET = 'Sheet1';
	RUN;

	DATA COVID;
	SET COVID1;
	IF COUNTY = "DADE" THEN COUNTY = "MIAMI-DADE";
	IF COUNTY = "" THEN COUNTY = "UNKNOWN";
	COUNTY = UPCASE(COUNTY);
	date1 = date - 21916;
	drop date;
	rename date1 = date;
	format date1 mmddyy10.;
	RUN;

	%SORTI(COVID, COUNTY);
	%SORTI(FINAL_CENSUS, COUNTY);
	%SORTI(RWJ, COUNTY);


	DATA FINAL_COMPLETE;
	MERGE COVID FINAL_CENSUS;
	BY COUNTY;
	
	KEEP RANDOM COUNTY AWAITING_TESTING DATE FILE_NAME	INCONCLUSIVE	NEGATIVE	POSITIVE	PERCENT_POSITIVE	TOTAL_TESTED DAY_OF_WEEK	NEW_NEGATIVES	NEW_CASES week
day

	 
		S1901_C01_012E S1501_C02_002E S1501_C02_009E DP05_0001E DP05_0037PE DP05_0038PE DP05_0039PE
	DP05_0044PE DP05_0052PE NAME GEO_ID S0101_C01_032E NEW_NEGATIVE NEW_CASES FILENAME;
	RENAME DATE1 = DATE;
	RUN;
	QUIT;

	DATA COMPLETE_MULTI;
	MERGE COVID FINAL_CENSUS RWJ;
	BY COUNTY;
	
	KEEP RANDOM COUNTY AWAITING_TESTING DATE FILE_NAME	INCONCLUSIVE	NEGATIVE	POSITIVE	PERCENT_POSITIVE	TOTAL_TESTED DAY_OF_WEEK	NEW_NEGATIVES	NEW_CASES week
day

		S1901_C01_012E S1501_C02_002E S1501_C02_009E DP05_0001E DP05_0037PE DP05_0038PE DP05_0039PE
	DP05_0044PE DP05_0052PE NAME GEO_ID S0101_C01_032E NEW_NEGATIVE NEW_CASES FILENAME FIPS	Length_of_Life_rank	Quality_of_Life_rank	Health_Behaviors_rank	
	Clinical_Care_rank	Social_Economic_Factors_rank	Physical_Environment_rank	Adult_Smoking_percent	Adult_Obesity_percent	Uninsured_percent	
	Primary_Care_Physicians_ratio	Income_Inequality_ratio	Air_Pollution_particulate_matter	Overcrowding	Adult_Diabetes_percent	Median_Household_Income	
    Percent_Over_65_Yrs	Black_percent	Hispanic_percent	Female_percent	Rural_percent ;

	RUN;
	QUIT;

	%MACRO IMPORTER2(DSET, FILEPATH, SHEET);
	PROC IMPORT OUT = &DSET DATAFILE= &FILEPATH
	DBMS=XLSX REPLACE;
	GETNAMES= YES;
	SHEET = &SHEET;
	RUN;
	%MEND;
	
	%IMPORTER2(DICT, "C:\Users\chacr\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\Florida COVID Data Project Data Dictionary 7-14-20.xlsx", "Sheet1");
/*	%IMPORTER2(VALID, "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Data Dictionary.xlsx", "Validation Check");*/

	%MACRO EXPORTER (DSET, FILEPATH, SHEET);
	PROC EXPORT DATA = &DSET OUTFILE = &FILEPATH
	DBMS = XLSX REPLACE;
	SHEET= &SHEET;
	RUN;
	%MEND;

		%EXPORTER (FINAL_COMPLETE, "C:\Users\chacr\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\Final Combined Dataset COVID & Census (7-14-20)", "PROJECT_DATASET");
		%EXPORTER (DICT, "C:\Users\chacr\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\Final Combined Dataset COVID & Census (7-14-20)", "DICTIONARY");
		%EXPORTER (COMPLETE_MULTI, "C:\Users\chacr\OneDrive\USF\Course Work\2019-2020\Summer 20\DR-Long Data\Data\COVID Multi-state Model Data set (7-14-20)", "Project_Dataset");
/*		%EXPORTER (VALID, "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Final Combined Dataset COVID & Census (7-14-20)", "vALIDATION");*/

