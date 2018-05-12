
*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that will generate final analytic file;
%include '.\STAT6863-02_s18-team-3_project2_data_preparation';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Do Medicare patients with RA/OA have more inpatient claims than 
patients that not have RA/OA? Is there a statistically significant difference?

Rationale: This should help identify trends in hospitalization for patients 
with certain chronic conditions.

Note: This compares the variable "Chronic Condition: RA/OA" in 
Master_Beneficiary_Summary_2010.csv to "Inpatient admission date" in 
Master_Inpatient_Claim_2010.csv.

proc sql outobs=10;
    select
        BENE_ID
        RA_OA_Status
        CLM_ID
	InP_PMT_AMT
    from
        Mbsf_AB_2010_and_Ip2010line_v2
    order by
        BENE_ID
    ;
quit;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the median inpatient claim amount for Medicare patients with 
COPD versus patients that do not have COPD? Is there a statistically significant
difference?

Rationale: This should help identify differences in hospitalization costs for 
patients with/without certain chronic conditions.

Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Inpatient_Claim_2010.csv.
;

proc sql outobs=10;
    select
        BENE_ID
        COPD_Status
        CLM_ID
	InP_PMT_AMT
    from
        Mbsf_AB_2010_and_Ip2010line_v2
    order by
        BENE_ID
    ;
quit;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the median outpatient claim amount for Medicare patients with 
COPD versus patients that do not have COPD? Is the difference statistically
significant?

Rationale: This should help identify differences in outpatient costs for 
patients with/without certain chronic conditions.

Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Outpatient_Claim_1_2010.csv.
;

proc sql outobs=10;
    select
        BENE_ID
        COPD_Status
        CLM_ID
	OP_PMT_AMT
    from
        Mbsf_AB_2010_and_Op2010line_v2
    order by
        BENE_ID
    ;
quit;

/*Data Exploration*/

title "Inspect Inpatient Claim Payment Amount in Ip2010line";

/* check for distribution of IP Claim Payments to ensure sufficient info to
answer research questions*/

proc sql;
    select
         min(PMT_AMT) as min
        ,max(PMT_AMT) as max
        ,mean(PMT_AMT) as mean
        ,median(PMT_AMT) as median
        ,nmiss(PMT_AMT) as missing
    from
        Ip2010line
    ;
quit;
title;

title "Inspect Outpatient Claim Payment Amount in Op2010claim";

/* check for distribution of OP Claim Payments to ensure sufficient info to
answer research questions*/

proc sql;
    select
         min(PMT_AMT) as min
        ,max(PMT_AMT) as max
        ,mean(PMT_AMT) as mean
        ,median(PMT_AMT) as median
        ,nmiss(PMT_AMT) as missing
    from
        Op2010claim
    ;
quit;
title;
