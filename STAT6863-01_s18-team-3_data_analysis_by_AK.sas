
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

title1 justify=left
'Question 1: What was the proportion of alived inpatient and outpatient benefeciaries and HMOs benefeciaries continiously enrolled in Medicare program in 2010?'
;

title2 justify=left
'Rationale: It should identify type of medical services under Medicare program in 2010'
;

footnote1 justify=left
'Out of total benefeciaries population 96% of benefeciaries are enrolled in inpatient and outpatient Medicare services. Since the other type of medical services are excluded from data analysis, we can see the high proportion of inpatient and outpatient benefeciaries'  
;

footnote2 justify=left
'Only 30% of benefeciaries from total population also uses the other type of medical services provided by Health Medical Organizations (HMOs)'
; 

footnote3 justify=left
'Only 0.94% of benefeciaries from total benefeciaries population who use Medicare program are passed away in 2010.'
; 

*Note: It compares Columns "contenrl_ab_2010" (Part A and B) and "contenrl_hmo" 
(HMOs) and "death_dt" from contenr2010_analytic_file. 

Limitation: We have inpatient and outpatient benefeciaries for one year (2010), 
who continiously enrolled in Medicare program. The other type of Medicare 
services are not included in our data set. We have already excluded the values
of "contenrl_ab_2010" equal to missing from this analysis. In this dataset we
have benefeciaries who are both enrolled in Medicare and HMOs services. Also,
this data set includes information about benefeciaries being enrolled in 
Medicare program but passed away in 2010;

proc freq data=contenr2010_analytic_file; 
    tables contenrl_ab_2010 contenrl_hmo_2010 death_2010 / missing; 
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 2: What is the percentage of Medicare benefeciaries by sex and ethnicity?'
;

title2 justify=left
'Rationale: This should help to identify benefeciaries of Medicare services by Sex and by Race in 2010 to explore the composition of our population.'
; 

footnote1 justify=left
'From total benefeciaries population 43% are men and 57% are women. Women utilize Medicare services 1.33 times more than men.'
; 

footnote2 justify=left
'The benefeciaries population who are continiously enrolled in 2010 are the following: White are 84%, Black are 10%, Other are 4% and 2% are Hispanic'
;

footnote3 justify=left
'The largest proportion of White benefeciaries can be explained that the minorBlack, Other and Hispanic ethnicities might not be eligible being enrolled in Medicare program'
; 

*Note: This compares "Sex", "Race" columns from prepared analytic datasets
contenr2010_analytic_file. 

Limitation: We analysed information in the data set contenr2010_analytic_file 
for only inpatient and outpatient beneficiaries who are continiously enrolled 
in 2010 year. The other type of Medicare services are not included in our data
set;

title "Frequency of Sex in 2010 data";
proc freq data=contenr2010_analytic_file; 
    tables gender / missing;
run;
title;

title "Frequency of Race in 2010 data";
proc freq data=contenr2010_analytic_file order=freq; 
    tables ethnicity / missing;
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 3: What is the top age category of benefeciaries who was enrolled in Medicare program in 2010?'
;

title2 justify=left
'Rationale: This should help to identify the composition benefeciaries of Medicare services by age group from 65 to over 95 years old.'
;

footnote1 justify=left
'This analysis shows that the top age group category of benenefeciaries in Medicare program are from age 66 to 75 years old. The percentage of this age category out of total population is 33%'
;

footnote2 justify=left
'Also, this analysis helps us to reveal disabled benefeciaries under age of 65, that being eligible to enroll in Medicare program in 2010.'
; 

* Note: It calculates column Study_Age that contains age as of 01.01.2010. 
It also uses variable Age_cats to group benefeciaries by value of study_age
column. We calculated variable age_cats that groups study_age into the 
following age categories: < 65 years old, age between 64 and 74, 75 and 84, 85
and 94 and greater 95. It also compares the column "County" and "State" with 
the column of the bene_id and claim_id from contenr2010_analytic_file.

Limitation: We have information about inpatient and outpatient benefeciaries,
who continiously enrolled in Medicare program in 2010. The other type of 
Medicare services are excluded from the data set. Counties that do not have 
information about benefeciaries and their claims under Medicare program are 
excluded from data analysis;

title "Age by Category in 2010 data";
proc freq data=contenr2010_analytic_file order=freq;
    tables study_age * age_cats / list missing;
    format age_cats age_cats_fmt.; 
run;

title1
'Plot illustrating the proportion of study age between male and female benefeciaries in Medicare program'
;

footnote1
'In the above plot, we can see that the proportion of women starting from age of 65 years old are much higher than the proportion of men'  
;

footnote2
'It might reveal that the female inpatient and outpatient benefeciaries have higher life expectancy than male benefecieries.'
;

proc sgplot data=contenr2010_analytic_file;
hbar study_age / stat=mean
		         group=gender;
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

proc sgplot data=contenr2010_analytic_file;
hbar age_cats / group=gender;
run;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 4: What is the top five states and counties of benefeciaries population in 2010?'
;

title2 justify=left
'Rationale: This gets information about composition of senior Americans by states and counties.'
;

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
