
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
*

title1 justify=left
'Question: What proportions of patients have made zero or more than one inpatient
claims by rheumatoid arthritis or osteoarthritis status?'

title2 justify=left
'Rationale: This should help identify trends in hospitalization for patients 
with certain chronic conditions.'
;

footnote1 justify=left
'There appears to be a large number of patients that have submitted zero claims.'
;

footnote2 justify=left
'Depending on the magnitude of the imbalance in the number of claims submitted,
parametric methods may not be appropriate for data analysis and a non-parametric
method may need to be further explored.'
;

*Note: This compares the variable "Chronic Condition: RA/OA" in 
Master_Beneficiary_Summary_2010.csv to "Clm_ID" in 
Master_Inpatient_Claim_2010.csv.

Limitations: This question assumes that each admission is logged individually
as referenced by claim ID. This may not be acccurate.
;

proc sql;
    create table RAOA_IPClaim_raw AS
        select
            Bene_ID
	   ,COUNT(IP_ClmID) AS IP_Num_Clm
	   ,RA_OA_Status
        from
            contenr2010_analytic_file
        group by 
            BENE_ID
;	    
quit;

proc sort
        nodupkey
        data=RAOA_IPClaim_raw
        out=RAOA_IPClaim 
    ;
    by
        Bene_ID
    ;
run;

proc print data = RAOA_IPClaim (obs=50);
run;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*

title1 justify=left
'Research Question: Of patients that have made inpatient claims, is there a 
significant difference in claim amounts for patients with COPD versus patients 
that do not have COPD?'
;

title2 justify=left
'Rationale: This should help identify differences in hospitalization costs for 
patients with/without certain chronic conditions.'
;

footnote1 justify=left
'In the exploratory analysis, there appears to be a minimal difference in the
distribution and magnitude of claim amounts based on COPD Status.'
;

footnote2 justify=left
'This apparent lack of difference should be explored in further detail using an
inferential method.'
;

*Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Inpatient_Claim_2010.csv.

Limitations: No limitations identified during exploratory steps.
;

proc sql;
    create table COPD_IPTotal_Pmt_raw AS
        select
            Bene_ID
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

proc sort
        nodupkey
        data=COPD_IPTotal_Pmt_raw
        out=COPD_IPTotal_Pmt
    ;
    by
        Bene_ID
    ;
run;

proc sql;
    select
         min(IPTot_Pmt) as min
        ,max(IPTot_Pmt) as max
        ,mean(IPTot_Pmt) as mean
        ,median(IPTot_Pmt) as median
    from
         COPD_IPTotal_Pmt
    group by
        COPD_Status
    ;
quit;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question: Of patients that have made outpatient claims, is there a 
significant difference in claim amounts for patients with COPD versus patients 
that do not have COPD?'
;

title2 justify=left
'Rationale: This should help identify differences in outpatient costs for 
patients with/without certain chronic conditions.'
;

footnote1 justify=left
'In the exploratory analysis, there appears to be a significant difference in the
distribution and magnitude of outpatient claim amounts based on COPD Status.'
;

footnote2 justify=left
'This difference should be explored in further detail using an inferential method.'

*Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Outpatient_Claim_1_2010.csv.

Limitations: No limitations identified during exploratory steps.
;

proc sql;
    create table COPD_OPTotal_Pmt_raw AS
        select
            Bene_ID
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

proc sort
        nodupkey
        data=COPD_OPTotal_Pmt_raw 
        out=COPD_OPTotal_Pmt 
    ;
    by
        Bene_ID
    ;
run;

proc sql;
    select
         min(OPTot_Pmt) as min
        ,max(OPTot_Pmt) as max
        ,mean(OPTot_Pmt) as mean
        ,median(OPTot_Pmt) as median
    from
        COPD_OPTotal_Pmt
    group by 
        COPD_Status    
;
quit;
