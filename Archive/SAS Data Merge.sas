
PROC DATASETS NOPRINT LIB=WORK KILL;
RUN;
QUIT;

DM LOG "CLEAR;";
%macro importer(dset, file);
proc import out = T_&dset datafile= "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\&file"
dbms = xlsx replace;
getnames= yes;
datarow = 2;
run;

data &dset;
LENGTH COUNTY $20.;
set t_&dset;
if  find(geo_id, "id", "i") then delete;

County = upcase(substr(name, 1, index(name," County")));
run;


proc sort data =&dset;
by COUNTY;
run;

%mend;
%importer(inc  ,Census\Florida 2018 Median Income.xlsx);
%importer(Edu  ,Census\Florida Education 2018.xlsx);
%importer(Race ,Census\Florida Race & Pop 2018.xlsx);

proc import out = covid1 datafile= "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Txt\Output\Complete Data Set 2020.xlsx"
dbms = xlsx replace;
getnames = yes;
datarow=2;
run;

data COVID;
set coVID1;
COUNTY = UPCASE(COUNTY);
RUN;

PROC SORT DATA = COVID;
BY COUNTY;
RUN;


DM LOG "CLEAR;";
data Final;
LENGTH COUNTY $20.;
merge covid inc edu race;
by COUNTY;
keep COUNTY Awaiting_testing	Inconclusive	Negative	Positive	Percent_positive	Total_tested	Date	file_name	Awaiting_BPHL_testing	Total	Awaiting_Testing	New_Negatives	New_Cases
 S1901_C01_012E S1501_C02_002E S1501_C02_009E DP05_0001E DP05_0037PE DP05_0038PE DP05_0039PE DP05_0044PE DP05_0052PE;
run;
QUIT;


PROC EXPORT DATA = FINAL OUTFILE = "C:\Users\Daniel chacreton\Documents\Python\USF\COVID-19 Project\Data\Complete COVID Dataset 6-2-20"
DBMS = XLSX REPLACE;
RUN;
