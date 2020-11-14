PROC DATASETS NOPRINT LIB=WORK KILL;
RUN;
QUIT;
DM ODSRESULTS "CLEAR;";
DM LOG "CLEAR;";
proc import out = covid datafile="C:\Users\chacr\OneDrive\Documents\Coding\COVID-19 Project\Data\Final Combined Dataset COVID & Census (7-14-20).xlsx"
dbms=xlsx replace;
getnames=Yes;
datarow=2;
run;
proc import out = covid_new datafile="C:\Users\chacr\OneDrive\Documents\Coding\COVID-19 Project\Data\NEW Data Set (Oxford Control Measures).xlsx"
dbms=xlsx replace;
getnames=Yes;
datarow=2;
run;
data covid1;
set covid;
int = input(DP05_0001E,comma10.);
/*drop DP05_0001E;*/
/*rename int = med_income;*/
run;

proc contents;
run;

%macro mixedlm(dset ,dv, iv1, iv2,iv3,iv4,iv5,iv6,iv7,iv8,iv9,iv10);
DM ODSRESULTS "CLEAR;";
DM LOG "CLEAR;";
proc mixed data = &dset;
class  county phase(ref="0");
model &dv =  &iv1 &iv2 &iv3 &iv4 &iv5 &iv6 &iv7 &iv8 &iv9 &iv10/s;
random int /subject = county  type=UN G ;
/*repeated date/subject=county;*/
run;
%mend;
*Daily Case Count;
%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,c6_stay_at_home_requirements,c1_school_closing,phase, uninsured_percent,overcrowding,clinical_care_rank);
%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,c6_stay_at_home_requirements,c1_school_closing,phase1,phase2,phase3, clinical_care_rank);
	*no Phases;
%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,c6_stay_at_home_requirements,c1_school_closing,clinical_care_rank);
	*no Oxford;
%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,phase1,phase2,phase3, clinical_care_rank);
%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,phase, clinical_care_rank);


%mixedlm(covid_new,daily_case_count,day_of_week,daily_test_count,pop2020,c6_stay_at_home_requirements,c1_school_closing,phase1,phase2,c2_workplace_closing,phase3, clinical_care_rank);


%mixedlm(covid_new,percent_positive,day_of_week,c6_stay_at_home_requirements,phase,c1_school_closing);
%mixedlm(covid_new,positive,day_of_week,total_tested,pop2020,c6_stay_at_home_requirements,phase,c1_school_closing, uninsured_percent,overcrowding,clinical_care_rank);
%mixedlm(covid_new,positive,day_of_week,c6_stay_at_home_requirements,phase,c1_school_closing);
