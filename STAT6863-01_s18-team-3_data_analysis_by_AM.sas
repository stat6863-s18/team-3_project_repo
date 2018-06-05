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
'Question: Is there a statisical difference in the proportion of patients that made zero or more than one inpatient claims by rheumatoid arthritis or osteoarthritis status?'
;

title2 justify=left
'Rationale: This should help identify trends in hospitalization for patients with certain chronic conditions.'
;

footnote1 justify=left
'There is a statistically significant difference between the number of expected and observed claims, indicating that patients with RA or OA file more inpatient claims than their peers who do not.'
;

footnote2 justify=left
'The result of this test was highly significant, but there may be other factors driving this difference, such as age, overall general health, and/or other competing risks'
;

*Note: This compares the variable "Chronic Condition: RA/OA" in 
Master_Beneficiary_Summary_2010.csv to "Clm_ID" in 
Master_Inpatient_Claim_2010.csv.
Limitations: This question assumes that each admission is logged individually
as referenced by claim ID. This may not be acccurate.
Methodology: Create a 2x2 table with COPD_Status versus number of inpatient claims
and use proc freq to evaluate independence of those variables.
Follow-up Steps: Further investigate by including other possible covariates and/or
class variables in the analysis to determine if there are other contributing
factors.
;

proc sql;
    create table RAOA_IPClaim AS
        select
            distinct Bene_ID
	   ,COUNT(IP_ClmID) AS IP_Claims format = ClaimF.
	   ,RA_OA_Status
        from
            contenr2010_analytic_file
        group by 
            BENE_ID
;	    
quit;

proc freq data= RAOA_IPClaim order=freq;
    tables RA_OA_Status*IP_Claims / chisq;
run;

title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question: Of patients that have made inpatient claims, is there a difference in claim amounts for patients with COPD versus patients that do not have COPD?'
;

title2 justify=left
'Rationale: This should help identify differences in hospitalization costs for patients with/without certain chronic conditions.'
;

title3 justify=center
'Plot illustrating the similarity in the distribution of inpatient claim amounts by COPD Status.'
;

footnote1 justify=left
'In the plots above, we can see the similarity in the distributions. Both are right-skewed, mostly unimodal and peaking near $5000.'
;

footnote2 justify=left
'To further explore this area of interest, inferential methods (parametric or non-parametric) could be employed to determine whether there is a statistically significant difference.'
;

*Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Inpatient_Claim_2010.csv.
Limitations: No limitations identified during exploratory steps.
Methodology: Use proc univariate to further explore the apparent lack
of difference in claim amounts for inpatient stays based on COPD status
Follow-up Steps: A possible follow-up to this approach could use formal 
inferential methods to compare mean and/or median values for each group 
to provide evidence of no difference in claim amounts.
;

proc sql;
    create table COPD_IPTotal_Pmt AS
        select
            distinct Bene_ID
	   ,COUNT(IP_ClmID) AS IP_Num_Clm
	   ,SUM(IP_PMT_AMT) AS IPTot_Pmt
	   ,COPD_Status
        from
            contenr2010_analytic_file
        group by 
            BENE_ID
	having 
	    SUM(IP_PMT_AMT) >0
;
quit;

proc univariate data=COPD_IPTotal_Pmt noprint;
    var IPTot_Pmt;
    class COPD_Status;
    histogram IPTot_Pmt / kernel(color=red) cfill=ltgray;
    label COPD_Status = 'COPD Status';
run;

title;
footnote;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question: For patients that have made outpatient claims, is there a difference in claim amounts for patients with COPD versus patients that do not have COPD?'
;

title2 justify=left
'Rationale: This should help identify differences in outpatient costs for patients with/without certain chronic conditions.'
;

footnote1 justify=left
'In the exploratory analysis, there appears to be a difference in the distribution and magnitude of outpatient claim amounts based on COPD Status.'
;

footnote2 justify=left
'This difference should be explored in further detail using an inferential method.'
;

*Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Outpatient_Claim_1_2010.csv.
Limitations: No limitations identified during exploratory steps.
;

proc sql;
    create table COPD_OPTotal_Pmt_raw AS
        select
            distinct Bene_ID
	   ,COUNT(OP_ClmID) AS OP_Num_Clm
	   ,SUM(OP_PMT_AMT) AS OPTot_Pmt
	   ,COPD_Status
        from
            contenr2010_analytic_file
        group by 
            BENE_ID
	having
	    SUM(OP_PMT_AMT) >0
;
quit;

*Sort by COPD_Status;

proc sort
    data=COPD_OPTotal_Pmt_raw 
    out=COPD_OPTotal_Pmt 
    ;
    by
    COPD_Status
    ;
run;   

proc report data= COPD_OPTotal_Pmt nowd headline headskip;	
    column (Min Max Mean Median),OPTot_Pmt;	
    define OPTot_Pmt / format=dollar11.2 ;
    by COPD_Status;
run;

title;
footnote;
