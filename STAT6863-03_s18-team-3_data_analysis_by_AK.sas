
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
Question: What was the percentage of Medicare benefeciaries by sex and race
What is the proportion of beneficiaries who was enrolled in Medicare program
by state and county?

Rationale: This should help identify utilization of Medicare services by state
and by county.

Note: This compares SEX and Race column from prepared analytic dataset
contenr_2010. It also compares the column "County" and "State" from msabea.txt 
to the column of the BENE_ID and Claim_ID from Master_Beneficiary_Summary_2010.
;


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


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is top 5 medical services for inpatient beneficiaries who 
were enrolled in Medicare program in 2010?

Rationale: This would help identify what kind of medical services were
in high demand to see utilization of Medicare hospital services by state
and county. 

Note: This compares the column BENE_ID, Claim_ID and CLN_ID from 
Master_inpatient_claim file after merging with Inpatient_Claim_2 file
by composite key.

Limitations: Comparing procedure during merge process shows a couple of
columns from op2010claim and op2010line_wide data sets that might be 
excluded from initial analysis, since bene_id and claim_id rows for these 
column are not identical. However, these rows are saved in separate file
if they are required for furher investigation.
Values of Admtg_dgns_cd equal to zero should be 
excluded from this analysis, since they are potentialy missing values.
In addition values of hcpcs_cd1 and hcpcs_cd3 equal to missing
should be excluded from analysis.
;

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


