
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
Question: Amongst providers with complete results for both median time for door to
diagnostic evaluation and comparison to national mortality rate, is there an association
between higher values for door to door diagnostic evaluation and the mortality rate?

Rationale: This should help identiy providers that have longer times for diagnostic
evaluation with higher mortality rates. Intervention may be recommended to reduce
the median door to door time.

Note: This compares the variable "door to diagnostic eval" in Timely_and_Effective to 
"Mortality National Comparison" in Hospital_General.
;

*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Amongst providers, is there an association between patients leaving before
they are seen and scoring for effectiveness of care?

Rationale: This would help inform whether wait time is a factor in the ratings for
effectiveness of care

Note: This compares the variable "left before being seen" in Timely_and_Effective to 
"Effectiveness of Care National Comparison" in Hospital_General.
;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
*
Question: Amongst providers, is there an association between the median time to
administration of pain meds and the scoring for readmission?

Rationale: This would help inform whether shorter times for administration of pain
meds is a factor in the ratings for readmission

Note: This compares the variable "median time to pain med" in Timely_and_Effective to 
"Readmission National Comparison" in Hospital_General.
;
