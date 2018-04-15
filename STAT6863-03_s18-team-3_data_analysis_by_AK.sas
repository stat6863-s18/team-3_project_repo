
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
Question: What is the proportion of beneficiaries who was 
enrolled in Medicare program by state and county?

Rationale: This should help identify utilization of Medicare services by state
and by county.

Note: This compares the column "County" and "State" from msabea.txt 
to the column of the BENE_ID and Claim_ID from Master_Beneficiary_Summary_2010.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Who was continiously enrolled in Medicare program in 2010?

Rationale: This helps to understand how many beneficiaries who were 
at age over 65 as of January 2010 continiously enrolled in Medicare program and 
further to do analysis by gender, race. It also gets information about
proportion of Americans by age category 

Note: This compares the column "BENE_HI_CVRAGE_TOT_MONS" 
"BENE_SMI_CVRAGE_TOT_MONS" and BENE_ID from Master_Beneficiary_Summary_2010.
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

Note: This compares the column BENE_ID, and CLN_ID from Master_inpatient_
claim file after merging with Inpatient_Claim_2 file by composite key.
;
