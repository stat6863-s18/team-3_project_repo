
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that will generate final analytic file;
%include '.\STAT6863-02_s18-team-0_project2_data_preparation';

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What was the proportion of inpatient and outpatient benefeciaries and 
HMO benefeciaries continiously enrolled in Medicare program in 2010? What is 
the proportion of beneficiaries who was enrolled in Medicare program by state 
and county?

Rationale: It should identify benefeciaries as of January 2010 who continiously 
enrolled in Medicare program (Part A, Part B and HMO). This should also help 
identify the proportion of benefeciaries of Medicare services by state and by 
counties.

Note: It compares Columns "contenrl_ab_2010" (Part A and B) and "contenrl_hmo" 
(HMO) from contenr_2010 dataset. It also compares the column "County" and
"State" from contenr_2010_fnl analytical file.

Limitation: We have benefeciaries for 2010 year, who continiously enrolled in 
Medicare program. To get proportion of benefeciaries we analyse in formation
in the dataset for Part A, Part B and HMO. Also, it includes information about 
benefeciaries who passed away in 2010.; 

proc freq data=contenr2010_analytic_file; 
    tables contenrl_ab_2010 contenrl_hmo_2010 death_2010 / missing; 
run;

title "Frequency of Benefeciaries by State and County in 2010 Data";
proc freq data=contenr2010_analytic_file order=freq; 
    tables state county /missing;
run;
title;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What was the percentage of Medicare benefeciaries by sex and race?
What is the race with most of benefeciaries enrolled in 2010?

Rationale: This should help identify benefeciaries of Medicare services by Sex
and by Race in 2010 to explore the composition of our population. 

Note: This compares "Sex", "Race" columns from prepared analytic datasets
contenr_2010fnl. We investigate Sex And Race in The 2010 data by creating 
appropriate formats.

Limitation: The data set contenr_2010_fnl contains only beneficiaries
for continiously enrolled benefeciaries in 2010 year. This analytic dataset 
provide us only information for alived Part A, Part B and HMO benefeciaries that
are of our primary interest.;

proc format; 
	value $sex_cats_fmt
	      '0'='Unknown'
              '1'='Male'
              '2'='Female';
run;

title "Frequency of sex in 2010 data";
proc freq data=contenr2010_analytic_file; 
	tables sex / missing;
	format sex $sex_cats_fmt.; 
run;
title;

proc format; 
    value $race_cats_fmt
          '0'='Unknown'
          '1'='White' 
          '2'='Black'
          '3'='Other'
          '4'='Asian'
	  '5'='Hispanic'
	  '6'='North American Native';
run;

title "Frequency of race in 2010 data";
proc freq data=contenr2010_analytic_file order=freq; 
    tables race / missing;
	format race $race_cats_fmt.; 
run;
title;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the proportion of benefeciaries who was enrolled in Medicare
program by age categories? 

Rationale: This should help identify benefeciaries of Medicare services by age
group from 65 to over 95 years old. It shows the top age group in Medicare 
program. It also gets information about proportion of Americans by age category.
Also, it helps us to reveal disabled benefeciaries under age of 65, but who are
eligible to enroll in Medicare program in 2010.

Note: It calculates column Study_Age that contains age as of 01.01.2010. 
It also uses variable Age_cats to group benefeciaries by value of Study_Age
column. We calculated variable age_cats that groups study_age into the following 
age categories: < 65 years old, age between 64 and 74, 75 and 84, 85 and 94 and 
greater 95. 

Limitation: We have information only for 2010 year, who continiously enrolled
in Medicare program, excluding who passed away in 2010.  Also, age of all 
benefeciaries in the dataset was calculated as of January 1, 2010.;

proc format; 
    value age_cats_fmt
          0='Age Less Than 65'
          1='Age Between 65 and 74, Inclusive' 
          2='Age Between 75 and 84, Inclusive'
          3='Age Between 85 and 94, Inclusive'
          4='Age Greater Than or Equal To 95';
run;

data contenr2010_analytic_file;
	set contenr2010_analytic_file;
    format age_cats age_cats_fmt.;
    study_age=floor((intck('month', bene_dob, '01jan2010'd) - (day('01jan2010'd) 
    < day(bene_dob))) / 12);
    select;
    	when (study_age<65)      age_cats=0;
        when (65<=study_age<=74) age_cats=1;
        when (75<=study_age<=84) age_cats=2;
        when (85<=study_age<=94) age_cats=3;
        when (study_age>=95)     age_cats=4;
	end;
    label age_cats='Beneficiary age category at beginning of reference year
    (January 1, 2010)';
run;

title "Age by Category in 2010 data";
proc freq data=contenr2010_analytic_file order=freq;
    tables study_age * age_cats / list missing;
    format age_cats age_cats_fmt.; 
run;
title;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is top 5 medical services for inpatient beneficiaries who were 
enrolled in Medicare program in 2010?

Rationale: This would help identify what kind of medical services were in high 
demand to see utilization of Medicare hospital services by state and county.

Note: This compares the column BENE_ID, Claim_ID and CLN_ID from 
Master_inpatient_claim file after merging with Inpatient_Claim_2 file by composite
key. It also compares the column "County" and "State" from contenr_2010fnl to the
column of the BENE_ID and Claim_ID from Master_Beneficiary_Summary_2010.

Limitations: Comparing procedure during merge process shows a couple of columns 
from op2010claim and op2010line_wide data sets that might be excluded from initial
analysis, since bene_id and claim_id rows for these column are not identical. 
However, these rows are saved in separate file if they are required for furher 
investigation. Values of Admtg_dgns_cd equal to zero should be excluded from this
analysis, since they are potentialy missing values. In addition values of hcpcs_cd1
and hcpcs_cd3 equal to missing should be excluded from analysis;





