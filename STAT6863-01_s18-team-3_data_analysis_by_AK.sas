
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
 What is 
the proportion of beneficiaries who was enrolled in Medicare program by state 
and county?

Rationale: This should also help identify the proportion of benefeciaries of Medicare
services by state and by counties.;

title1 justify=left
'Question: What was the proportion of alived inpatient and outpatient benefeciaries and HMOs benefeciaries continiously enrolled in Medicare program in 2010?'
;

title2 justify=left
'Rationale: It should identify type of Medicare programs who are involved most?. It also can get information about quality of Medicare services by getting information about death percentage in 2010'
;

footnote1 justify=left
'Out of total benefeciaries population 96% of benefeciaries uses both inpatient and outpatient Medicare services'
;

footnote2 justify=left
'Only 30% of benefeciaries from total population also uses the other type of medical services provided by Health Medical Organizations (HMOs)'
; 

footnote3 justify=left
'Only 0.94% of benefeciaries from total benefeciaries population who use Medicare program are passed away in 2010. This means that both inpatient and outpatient benefeciaries got prompt and qualitatitive medical assistance in 2010'
; 

*Note: It compares Columns "contenrl_ab_2010" (Part A and B) and "contenrl_hmo" 
(HMOs) and "death_dt" from contenr2010_analytic_file. 

Limitation: We have inpatient and outpatient benefeciaries for one year (2010), 
who continiously enrolled in Medicare program. The other type of Medicare services are
not included in our data set. We have already excluded the values of "contenrl_ab_2010"
equal to missing from this analysis. In this dataset we have benefeciaries who are both
enrolled in Medicare and HMOs services. Also, this data set includes information about 
benefeciaries who passed away in 2010 being enrolled in Medicare program;

proc freq data=contenr2010_analytic_file; 
    tables contenrl_ab_2010 contenrl_hmo_2010 death_2010 / missing; 
run;



*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question: What was the percentage of Medicare benefeciaries by sex? What is the proportion of benefeciaries enrolled in 2010 by race?'
;

title2 justify=left
'Rationale: This should help identify benefeciaries of Medicare services by Sex and by Race in 2010 to explore the composition of our population.'
; 

footnote1 justify=left
'From total benefeciaries population 43% are men and 57% are women. Women uses Medicare services 1.33 times more than men.'
; 

footnote2 justify=left
'The benefeciaries population who are continiously enrolled in 2010 are the following: White - 84%, Black - 10%, Other - 4% and 2% - Hispanic'
;

footnote3 justify=left
'One of the explanations of these proportions are Black, Other and Hispanic ethnicity might not be eligible being enrolled in Medicare program'
; 

*Note: This compares "Sex", "Race" columns from prepared analytic datasets
contenr_2010fnl. We investigate Sex And Race in The 2010 data by creating 
appropriate formats.

Limitation: We analysed information in the data set contenr2010_analytic_file 
for only inpatient and outpatient beneficiaries who are continiously enrolled 
in 2010 year. The other type of Medicare services are not included in our data set.;


proc format; 
	value $sex_cats_fmt
	      '0'='Unknown'
              '1'='Male'
              '2'='Female';
run;

title "Frequency of Sex in 2010 data";
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

title "Frequency of Race in 2010 data";
proc freq data=contenr2010_analytic_file order=freq; 
    tables race / missing;
    format race $race_cats_fmt.; 
run;
title;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question: What is the top age category of benefeciaries who was enrolled in Medicare program in 2010? What is the top five states and counties of benefeciaries population in 2010?' 
;

title2 justify=left
'Rationale: This should help identify the composition benefeciaries of Medicare services by age group from 65 to over 95 years old. It also gets information about proportion of Americans by age category, state and county.'
;

footnote1 justify=left
'This analysis shows that the top age group category of benenefeciaries in Medicare program are from age 66 to 75 years old. The percentage of this age category out of total population is 32%'
;

footnote2 justify=left
'Also, this analysis helps us to reveal disabled benefeciaries under age of 65, that being eligible to enroll in Medicare program in 2010.'
; 

/* Note: It calculates column Study_Age that contains age as of 01.01.2010. 
It also uses variable Age_cats to group benefeciaries by value of study_age
column. We calculated variable age_cats that groups study_age into the following 
age categories: < 65 years old, age between 64 and 74, 75 and 84, 85 and 94 and 
greater 95. It also compares the column "County" and "State" with the column of the 
bene_id and claim_id from contenr2010_analytic_file.

Limitation: We have information about inpatient and outpatient benefeciaries,
who continiously enrolled in Medicare program in 2010. The other type of Medicare
services are excluded from the data set. Counties that do not have information about
benefeciaries and their claims under Medicare program are excluded from data analysis*/

proc format; 
    value age_cats_fmt
          0=' < 65'
          1='65 and 74' 
          2='75 and 84'
          3='85 and 94'
          4=' > or = 95';
run;

data contenr2010_analytic_file;
    set contenr2010_analytic_file;
    format age_cats age_cats_fmt.;
    study_age=floor(
        (
	    intck('month', bene_dob, '01jan2010'd) - 
	    (day('01jan2010'd) < day(bene_dob))
	) / 12);
    select;
    	when (study_age<65)      age_cats=0;
        when (65<=study_age<=74) age_cats=1;
        when (75<=study_age<=84) age_cats=2;
        when (85<=study_age<=94) age_cats=3;
        when (study_age>=95)     age_cats=4;
	end;
    label age_cats='Beneficiary age category at beginning of ref year (January 1, 2010)';
run;

title "Age by Category in 2010 data";
proc freq data=contenr2010_analytic_file order=freq;
    tables study_age * age_cats / list missing;
    format age_cats age_cats_fmt.; 
run;
title;


footnote1 justify=left
'The top five US states of benefeciaries population in 2010 are California, Florida, Texas, New York and Pensylvania. The top five counties are Los Angeles, Cook, Jefferson, Orange and Montgomery'  
;

footnote2 justify=left
'These top five states are covered 33% of total benefeciaries population. Three out of five states (CA, TX, NY) have the three states with largest population in the US'
;

footnote3 justify=left
'This data analysis shows that these top five counties represented the largest senior and disabled benefeciaries population in the US. The proportion of these population are covered 8% of total benefeciaries population'
; 

title "Frequency of Benefeciaries by State and County in 2010 Data";
proc freq data=contenr2010_analytic_file order=freq; 
    tables state county /missing;
run;
title;

title1
'Plot illustrating the average study age between male and female benefeciaries under Medicare program'
;

footnote1
'In the above plot, we can see that average study age of women higher than men (75 years old and 71 years old, respectively).'  
;

footnote2
'It might reveal that female inpatient and outpatient benefeciaries have higher life expectancy than male benefecieries'
;

proc gchart data=contenr2010_analytic_file;
vbar sex / sumvar=study_age
		   type=mean;
run;

title1
'Plot illustrating the proportion male and female benefeciaries by age categories under Medicare program'
;

footnote1
'In the above plot, we can that the proportion of female benefeciaries much higher in all age categories except that less than 65 years old'
;

footnote2
'This plot shows that women uses Medicare services more than men in the same age categories'
; 

proc gchart data=contenr2010_analytic_file;
vbar age_cats / subgroup=sex;
run;
quit;



