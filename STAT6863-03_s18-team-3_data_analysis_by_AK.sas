
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
Question: What was the percentage of Medicare benefeciaries by sex and race?
What is the proportion of benefeciaries who are still alive in 2010?

Rationale: This should help identify benefeciaries of Medicare services by Sex
and by Race in 2010 to explore the composition of our population.

Note: This compares SEX, Race columns from prepared analytic datasets
contenr_2010fnl and DEATH_2010 column from contenr_2010 data set. 


*FREQUENCY OF CONTINUOUS ENROLLMENT ALIVE BENEFECIARIES (PART A, B AND HMO); 
proc freq data=contenr_2010; 
    tables contenrl_ab_2010 contenrl_hmo_2010 death_2010; 
run;

*INVESTIGATION OF SEX AND RACE IN THE 2010 DATA BY CREATING FORMATS */;
proc format; 
    value $sex_cats_fmt
		'0'='UNKNOWN'
        '1'='MALE'
        '2'='FEMALE';
run;

title "FREQUENCY OF SEX IN 2010 DATA";
proc freq data=contenr_2010_fnl; 
    tables sex / missing;
	format sex $sex_cats_fmt.; 
run;

proc format; 
    value $race_cats_fmt
        '0'='UNKNOWN'
        '1'='WHITE' 
        '2'='BLACK'
        '3'='OTHER'
        '4'='ASIAN'
		'5'='HISPANIC'
		'6'='NORTH AMERICAN NATIVE';
run;

title "FREQUENCY OF RACE IN 2010 DATA";
proc freq data=contenr_2010_fnl; 
    tables race / missing;
	format race $race_cats_fmt.; 
run;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the proportion of benefeciaries who was enrolled in Medicare
program by age categories? 

Rationale: This should help identify benefeciaries of Medicare services by age
group from 65 to over 95 years old. It shows the top age category in Medicare 
program 

Note: It calculates column Study_Age that contains age as of 01.01.2010. 
It also uses variable Age_cats to group benefeciaries by value of Study Age
column 

/* CALCULATING VARIABLE AGE_CATS THAT GROUPS STUDY_AGE INTO AGE CATEGORIES */;
proc format; 
    value age_cats_fmt
        0='AGE LESS THAN 65'
        1='AGE BETWEEN 65 AND 74, INCLUSIVE' 
        2='AGE BETWEEN 75 AND 84, INCLUSIVE'
        3='AGE BETWEEN 85 AND 94, INCLUSIVE'
        4='AGE GREATER THAN OR EQUAL TO 95';
run;

data contenr_2010_fnl;
    set contenr_2010_fnl;
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

/* DISPLAY AGE GROUP CHARACTERISTICS IN 2010 ENROLLMENT DATA */
title "STUDY_AGE AND AGE_CATS IN 2010 DATA";
proc freq data=contenr_2010_fnl;
    tables study_age * age_cats / list missing;
    format age_cats age_cats_fmt.; 
run;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the proportion of beneficiaries who was enrolled in Medicare
program by state and county? 

Rationale: This should help identify benefeciaries of Medicare services by age
categories. It also identify the benefeciaries by state and by county.










*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the proportion of beneficiaries who was enrolled in Medicare program
by state and county? What is top 5 medical services for inpatient beneficiaries who 
were enrolled in Medicare program in 2010?

Rationale: This would help identify what kind of medical services were
in high demand to see utilization of Medicare hospital services by state
and county. This should help identify benefeciaries of Medicare services by state
and by county.

Note: This compares the column BENE_ID, Claim_ID and CLN_ID from 
Master_inpatient_claim file after merging with Inpatient_Claim_2 file
by composite key. It also compares the column "County" and "State" from msabea.txt 
to the column of the BENE_ID and Claim_ID from Master_Beneficiary_Summary_2010.

Limitations: Comparing procedure during merge process shows a couple of
columns from op2010claim and op2010line_wide data sets that might be 
excluded from initial analysis, since bene_id and claim_id rows for these 
column are not identical. However, these rows are saved in separate file
if they are required for furher investigation.
Values of Admtg_dgns_cd equal to zero should be 
excluded from this analysis, since they are potentialy missing values.
In addition values of hcpcs_cd1 and hcpcs_cd3 equal to missing
should be excluded from analysis.;

proc sql outobs=10;
    select
         bene_id
        ,clm_id
        ,input(admtg_dgns_cd, best15.) as Admit_Code
		,Revenue_Center_1
		,Revenue_Center_2
    from
        op2010_v2
    where
        calculated Admit_Code > 0
		and Revenue_Center_1 is missing
		and Revenue_Center_2 is missing
    order by
        bene_id, clm_id
    ;
quit;


data op_2010 op_nomatch;
    merge op2010claim(in=a) op2010line_wide(in=b);
	by bene_id clm_id;
	if a and b then output op_2010;
    else output op_nomatch;
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What was the proportion of inpatient and outpatient benefeciaries
and HMO benefeciaries continiously enrolled in Medicare program in 2010?
What was the proportion of benefeciaries who passed away?

Rationale: This helps to understand how many beneficiaries who were 
at age over 65 as of January 2010 continiously enrolled in Medicare program
(Part A, Part B and Part C )and further to do analysis by gender, race.
It also gets information about proportion of Americans by age category 

Note: This compares the column "BENE_HI_CVRAGE_TOT_MONS" 
"BENE_SMI_CVRAGE_TOT_MONS" and BENE_HMO_CVRAGE_TOT_MONS and from
Master_Beneficiary_Summary_2010 by creating contenr_2010 data set.
;

