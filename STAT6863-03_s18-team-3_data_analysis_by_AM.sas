
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
patients that not have RA/OA?

Rationale: This should help identify trends in hospitalization for patients 
with certain chronic conditions.

Note: This compares the variable "Chronic Condition: RA/OA" in 
Master_Beneficiary_Summary_2010.csv to "Inpatient admission date" in 
Master_Inpatient_Claim_2010.csv.

Limitations: No apparent limitations although care should be taken during merge
since there are possible cases of multiple or zero admissions per beneficiary. 
;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the median inpatient claim amount for Medicare patients with 
COPD versus patients that do not have COPD?

Rationale: This should help identify differences in hospitalization costs for 
patients with/without certain chronic conditions.

Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Inpatient_Claim_2010.csv.

Limitiations: No apparent limitations at this time.
;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: What is the median outpatient claim amount for Medicare patients with 
COPD versus patients that do not have COPD?

Rationale: This should help identify differences in outpatient costs for 
patients with/without certain chronic conditions.

Note: This compares the variable "Chronic Condition: COPD" in 
Master_Beneficiary_Summary_2010.csv to "Claim Payment Amount" in 
Master_Outpatient_Claim_1_2010.csv.

Limitiations: No apparent limitations at this time.
;

proc sql outobs=10;
    select
         School
        ,District
        ,Number_of_SAT_Takers /* NUMTSTTAKR from sat15 */
        ,Number_of_Course_Completers /* TOTAL from gradaf15 */
        ,Number_of_SAT_Takers - Number_of_Course_Completers
         AS Difference
        ,(calculated Difference)/Number_of_Course_Completers
         AS Percent_Difference format percent12.1
    from
        sat_and_gradaf15_v2
    where
        Number_of_SAT_Takers > 0
        and
        Number_of_Course_Completers > 0
    order by
        Difference desc
    ;
quit;

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
