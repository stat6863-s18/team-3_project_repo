
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that will generate final analytic file;
%include '.\STAT6863-01_s18-team-3_data_preparation.sas';

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
Medicare program but passed away in 2010.

Methodology: Use proc freq to display percentage of continiously enrolled alive 
benefeciaries in Part A and Part B and Health Maintenance Organizations.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data by validating extra variables
with missing data.
;

proc freq data=contenr2010_analytic_file; 
    tables contenrl_ab_2010 bene_hmo_cvrage_tot_mons death_dt / missing; 
run;

* clear titles/footnotes;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 2: What is the percentage of Medicare benefeciaries by sex and ethnicity?'
;

title2 justify=left
'Rationale: This should help to identify benefeciaries of Medicare services by Sex and by Race in 2010 to explore the composition of our population.'
; 
*footnote;

*Note: This compares "Sex", "Race" columns from contenr2010_analytic_file. 

Limitation: We analysed information in the data set contenr2010_analytic_file 
for only inpatient and outpatient beneficiaries who are continiously enrolled 
in 2010 year. The other type of Medicare services are not included in our data
set.

Methodology: Use two proc freq to display the ordered proportion of
benefeciaries by sex and then by race.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data by validating extra variables
with missing data. Adding the other type of medical services to increase the 
population of investigated benefeciaries. Use chi square test of independence
to see the relationship between sex and race
; 

footnote1 justify=left
'From total benefeciaries population 43% are men and 57% are women. Women utilize Medicare services 1.33 times more than men.'
; 

proc freq data=contenr2010_analytic_file; 
    tables sex / missing;
run;

title;
footnote;

footnote1 justify=left
'The benefeciaries population who are continiously enrolled in 2010 are the following: White are 84%, Black are 10%, Other are 4%, and 2% are Hispanic'
;

footnote2 justify=left
'The largest proportion of White benefeciaries can be explained that the minor Black, Other and Hispanic ethnicities might not be eligible for Medicare program'
; 

proc freq data=contenr2010_analytic_file order=freq; 
    tables race / missing;
run;

* clear titles/footnotes;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 3: What is the top age category of benefeciaries who was enrolled in Medicare program in 2010?'
;

title2 justify=left
'Rationale: This should help to identify the composition of benefeciaries for Medicare services by age group from 65 to over 95 years old.'
;

* Note: It calculates column Study_Age that contains age as of 01.01.2010. 
It also uses variable Age_cats to group benefeciaries by value of study_age
column. We calculated variable age_cats that groups study_age into the 
following age categories: < 65 years old, age between 64 and 74, 75 and 84, 85
and 94 and greater 95. It also compares the column "County" and "State" with 
the column of the bene_id and claim_id from contenr2010_analytic_file.

Limitation: We have information about inpatient and outpatient benefeciaries,
who continiously enrolled in Medicare program in 2010. The other type of 
Medicare services are excluded from the data set.

Methodology: Use proc freq to display percent of benefeciaries by study age,
proc report to display their percent for each age categories by sex,
sgplot to output a horizontal bar plot, illustrating the the percentage of 
benefeciaries by sex to show the proportion of female and male in each
age categories.

Followup Steps: Analyse the proportion of male and female benefeciaries by
race for each age categories.
;

footnote1 justify=left
'This data analysis shows that the top age category of benenefeciaries in Medicare program are from age 65 to 74 years old. The percentage of this age category out of total population is 35%'
;

footnote2 justify=left
'Also, this data analysis helps us to reveal disabled benefeciaries under age of 65, that being eligible to enroll in Medicare program in 2010.'
; 

proc freq data=contenr2010_analytic_file; /*order=freq*/
    table study_age / list missing;
run;

footnote;

footnote1 justify=left
'This data analysis shows that the proportion of women in each age categories is larger than the proportion of men'
;

title;

* display study_age, sex, number of benefeciaries and percent for each age
categories by sex;
title' The Proportion of Men and Women by Age';
proc report data=contenr2010_anal_file_by_Age;
    columns
        Study_Age
        Sex
        N
        pctn
    ;
    define Study_Age / group;
    define Sex / group;
    define N / "N of Benefeciaries";
    define pctn / 'Percent of Total' f=percent9.3;
    rbreak after /summarize;
run;

title1
'Plot illustrating the proportion male and female benefeciaries by age categories under Medicare program'
;

footnote1
'In the above plot, we can see that the proportion of female benefeciaries much higher in all age categories except those of less than 65 years old'
;

footnote2
'This plot shows that women uses Medicare services more than men in the same age categories'
; 

proc sgplot data=contenr2010_analytic_file;
   hbar study_age / group=sex;
run;

* clear titles/footnotes;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 4: What is the the proportion of benefeciaries by states and counties in 2010?'
;

title2 justify=left
'Rationale: This gets information about composition of senior Americans by states and counties.'
;

* Note: It compares county and state column in contenr2010_analytic_file. 

Limitation: Counties that do not have information about benefeciaries and their
claims under Medicare program are excluded from data analysis.

Methodology: Use proc freq to display sorted percentage of benefeciaries by
state in descending order, proc sql to output the first top 5 counties with
largest benefeciary population.

Followup Steps: Analyse the frequency of benefeciaries grouped by state and 
county to see states with counties with largest senior and disabled population
for Medicare program and calculate the proportion of these benefeciaries from
total population.
;

footnote1 justify=left
'The top five US states of benefeciary population in 2010 are California, Florida, Texas, New York and Pensylvania.'   
;

footnote2 justify=left
'These top five states are covered 33% of total benefeciaries population. Three out of five states (CA, TX, NY) are the three largest states in the US'
;

proc freq data=contenr2010_analytic_file order=freq; 
    tables state /missing nocum;
run;

title;

footnote1 justify=left
'The top five US counties are Los Angeles, Cook, Jefferson, Orange and Montgomery'
;

footnote2 justify=left
'This data analysis shows that these top five counties represented the largest senior and disabled benefeciaries population in the US. The proportion of these population are covered 8% of total benefeciaries population'
; 

proc sql outobs=5;
    * print frequency of each Counties ;
    select
         County
        ,count(*) as Number_of_Benefeciaries
    from
        contenr2010_analytic_file
    group by
        County
    order by Number_of_Benefeciaries desc
    ;
quit;

* clear titles/footnotes;
title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 4: Is the race and sex are independent of each other'
;

title2 justify=left
'Rationale: This tests hypothesis about relationship between sex and race'
;





* Note: It compares sex and race columns in contenr2010_analytic_file. 

Limitation: the expected value for each cell in contingency table is five or
higher. Sex and race variables are not correlated with each other.

Methodology: Use proc freq with chisq option to calculate chi square statistics
and p value to conduct chi square test of independence of sex and race

Followup Steps: Perform a chi-square goodness of fit test that allow us to test
whether the observed proportions for race differ from hypothesized proportions
of this categorical variable.
;
