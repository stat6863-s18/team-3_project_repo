
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
'Question: What proportion of patients that have made one or more inpatient
claims are identified as having rheumatoid arthritis or osteoarthritis?

title2 justify=left
'Rationale: This should help identify trends in hospitalization for patients 
with certain chronic conditions.'
;

footnote1 justify=left
"XXXXXXXXXXXX"
;

footnote2 justify=left
"XXXXXXXXXXXX"
;

Note: This compares the variable "Chronic Condition: RA/OA" in 
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
	where
	    IP_Num_Clm >= 1 
        group by 
            BENE_ID;
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
"XXXXXXXXXXXXXXX"
;

footnote2 justify=left
"XXXXXXXXXXXXXXX"
;

Note: This compares the variable "Chronic Condition: COPD" in 
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
	where
	    IP_Num_Clm >= 1
        group by 
            BENE_ID;
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
"XXXXXXXXXXXXXXX"
;

footnote2 justify=left
"XXXXXXXXXXXXXXX"
;

Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Outpatient_Claim_1_2010.csv.

Limitations: No limitations identified during exploratory steps.
;

PROC SQL;
    create table COPD_OPTotal_Pmt_raw AS
        select
            Bene_ID
	   ,COUNT(OP_Claim) AS OP_Num_Clm
	   ,SUM(OP_PMT_AMT) AS OPTot_Pmt
	   ,COPD_Status
        from
            contenr2010_analytic_file
	where
	    OP_Num_Clm
        group by 
            BENE_ID;
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

*Data Exploration;

title "Inspect Inpatient Claim Payment Amount in COPD_IPTotal_Pmt";

* check for distribution of IP Claim Payments to ensure sufficient info to
answer research questions;

proc sql;
    select
         min(IPTot_Pmt) as min
        ,max(IPTot_Pmt) as max
        ,mean(IPTot_Pmt) as mean
        ,median(IPTot_Pmt) as median
        ,nmiss(IPTot_Pmt) as missing
    from
         COPD_IPTotal_Pmt
    ;
quit;
title;

title "Inspect Outpatient Claim Payment Amount in COPD_OPTotal_Pmt;

* check for distribution of OP Claim Payments to ensure sufficient info to
answer research questions;

proc sql;
    select
         min(OPTot_Pmt) as min
        ,max(OPTot_Pmt) as max
        ,mean(OPTot_Pmt) as mean
        ,median(OPTot_Pmt) as median
        ,nmiss(OPTot_Pmt) as missing
    from
         COPD_OPTotal_Pmt
    ;
quit;
title;
