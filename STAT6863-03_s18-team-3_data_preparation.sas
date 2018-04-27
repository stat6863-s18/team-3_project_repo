*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] Master_Inpatient_Claim_2010.csv

[Dataset Description] Impatient Medicare Data by Service Line, 2010


[Experimental Unit Description] Benefeciary Claim

[Number of Observations] 13,916      

[Number of Features] 10

[Data Source] The file https://www.cms.gov/Research-Statistics-Data-and-Systems
/Downloadable-Public-Use-Files/SynPUFs/Downloads
/DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.zip
was downloaded and edited to produce file by subsetting to get 2010 year 

[Data Dictionary] https://github.com/stat6863/team-3_project_repo/blob/master
/data/Data_Dictionary_Medicare.doc

[Unique ID Schema] The columns "Claim_ID", "Bene_ID" and "CLM_LN" form 
a composite key

;
%let inputDataset1DSN = Ip2010line;
%let inputDataset1URL =
https://github.com/stat6863/team-3_project_repo/blob/master/data/Master_Inpatient_Claim_2010.csv?raw=true
;
%let inputDataset1Type = CSV;




*
[Dataset 2 Name] Inpatient_Claim_2_2010.csv

[Dataset Description] Impatient Medicare Data by claim, 2010

[Experimental Unit Description] Beneficiary Claim

[Number of Observations] 13,916     

[Number of Features] 36

[Data Source] The file https://www.cms.gov/Research-Statistics-Data-and-Systems
/Downloadable-Public-Use-Files/SynPUFs/Downloads
/DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.zip
was downloaded and edited to produce the file by subsetting to get 2010 year 

[Data Dictionary] https://github.com/stat6863/team-3_project_repo/blob/master/
data/Data_Dictionary_Medicare.doc

[Unique ID Schema] The columns "Claim_ID", "Bene_ID" form a composite key
.
;
%let inputDataset2DSN = Ip2010claim;
%let inputDataset2URL =
https://github.com/stat6863/team-3_project_repo/blob/master/data/Inpatient_Claim_2_2010.csv?raw=true
;
%let inputDataset2Type = CSV;


*
[Dataset 3 Name] Master_Beneficiary_Summary_2010.csv

[Dataset Description] Master Beneficiary Medicare Summary, 2010

[Experimental Unit Description] Beneficiary Claim
[Number of Observations] 112,374

[Number of Features] 32

[Data Source] https://www.cms.gov/Research-Statistics-Data-and-Systems
/Downloadable-Public-Use-Files/SynPUFs/Downloads/DE1_0_2010_Beneficiary_
Summary_File_Sample_1.zip was downloaded and edited to produce the file by
subsetting to get 2010 year 

[Data Dictionary] https://github.com/stat6863/team-3_project_repo/blob/master/
data/Data_Dictionary_Medicare.doc

[Unique ID Schema] The column BENE_ID is a unique id.
;
%let inputDataset3DSN = Mbsf_AB_2010;
%let inputDataset3URL =
https://github.com/stat6863/team-3_project_repo/blob/master/data/Master_Beneficiary_Summary_2010.csv?raw=true
;
%let inputDataset3Type = CSV;


*
[Dataset 4 Name] Outpatient_Claim_2_2010.csv

[Dataset Description] Outpatient Medicare Data by Claim, 2010

[Experimental Unit Description] Beneficiary Claim

[Number of Observations] 175,005

[Number of Features] 31

[Data Source]  The file https://www.cms.gov/Research-Statistics-Data-and-Systems
/Downloadable-Public-Use-Files/SynPUFs/Downloads/DE1_0_2008_to_2010_Outpatient_
Claims_Sample_1.zip
was downloaded and edited to produce file by subsetting to get 2010 year 

[Data Dictionary] https://github.com/stat6863/team-3_project_repo/blob/master/
data/Data_Dictionary_Medicare.doc

[Unique ID Schema] "Claim_ID", "Bene_ID" form a composite key
;
%let inputDataset4DSN = Op2010claim;
%let inputDataset4URL =
https://github.com/stat6863/team-3_project_repo/blob/master/data/Outpatient_Claim_2_2010.csv?raw=true
;
%let inputDataset4Type = CSV;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 4;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets

* check Ip2010line for bad unique id values, where the column CLM_ID is a unique key;
proc sql;
    /* check for duplicate unique id values; after executing this query, we
       see that Ip2010line_dups has no rows. No mitigation needed for ID values*/
    create table Ip2010line_dups as
        select
             CLM_ID
            ,count(*) as row_count_for_unique_id_value
        from
            Ip2010line
        group by
             CLM_Id
        having
            row_count_for_unique_id_value > 1
    ;
quit;
* check Ip2010claim for bad unique id values, where the column CLM_ID is a unique key;
proc sql;
    /* check for duplicate unique id values; after executing this query, we
       see that Ip2010claim_dups has no rows. No mitigation needed for ID values*/
    create table Ip2010claim_dups as
        select
             CLM_ID
            ,count(*) as row_count_for_unique_id_value
        from
            Ip2010claim
        group by
             CLM_Id
        having
            row_count_for_unique_id_value > 1
    ;
quit;
* check Mbsf_AB_2010 for bad unique id values, where the column Bene_ID is a unique key;
proc sql;
    /* check for duplicate unique id values; after executing this query, we
       see that Mbsf_AB_2010_dups has no rows. No mitigation needed for ID values*/
    create table Mbsf_AB_2010_dups as
        select
             Bene_ID
            ,count(*) as row_count_for_unique_id_value
        from
            Mbsf_AB_2010
        group by
             Bene_ID
        having
            row_count_for_unique_id_value > 1
    ;
quit;
proc sql;
    /* check for duplicate unique id values; after executing this query, we
       see that Op2010claim_dups has no rows. No mitigation needed for ID values*/
    create table Op2010claim_dups as
        select
             Clm_ID
            ,count(*) as row_count_for_unique_id_value
        from
            Op2010claim
        group by
             CLM_ID
        having
            row_count_for_unique_id_value > 1
    ;
quit;

/*For Amber’s Research Questions*/
title "Inspect SP_RA_OA in Mbsf_AB_2010";
proc sql;
    select
        nmiss(SP_RA_OA) as missing
    from
        Mbsf_AB_2010
    ;
quit;
title;

title "Inspect SP_COPD in Mbsf_AB_2010";
proc sql;
    select
        nmiss(SP_COPD) as missing
    from
        Mbsf_AB_2010
    ;
quit;
title;

title "Inspect Inpatient Claim Payment Amount in Ip2010line";
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

/*For Azamat's Research Questions*/
title "Inspect BENE_HI_CVRAGE_TOT_MONS in Mbsf_AB_2010";
proc sql;
    select
        nmiss(BENE_HI_CVRAGE_TOT_MONS) as missing
    from
        Mbsf_AB_2010
    ;
quit;
title;

title "Inspect BENE_HMO_CVRAGE_TOT_MONS in Mbsf_AB_2010";
proc sql;
    select
        nmiss(BENE_HMO_CVRAGE_TOT_MONS) as missing
    from
        Mbsf_AB_2010
    ;
quit;
title;

title "Inspect Inpatient Claim Claim Utilization Day Count (UTIL_DAY) in Ip2010claim";
proc sql;
    select
         min(UTIL_DAY) as min
        ,max(UTIL_DAY) as max
        ,mean(UTIL_DAY) as mean
        ,median(UTIL_DAY) as median
        ,nmiss(UTIL_DAY) as missing
    from
        Ip2010claim
    ;
quit;
title;

title "Inspect Outpatient Claims Start Date (FROM_DT) in Op2010claim";
proc sql;
    select
         min(FROM_DT) as min
        ,max(FROM_DT) as max
        ,mean(FROM_DT) as mean
        ,median(FROM_DT) as median
        ,nmiss(FROM_DT) as missing
    from
        Op2010claim
    ;
quit;
title;

proc contents data=mbsf_ab_2010; run;
*We have in this file information about Medicare beneficiaries who
enrolled in Part A (BENE_HI_CVRAGE_TOT_MONS), Part B
(BENE_SMI_CVRAGE_TOT_MONS) and Part C (BENE_HMO_CVRAGE_TOT_MONS)
program.

PREPARE DATASETS TO GET CONTINUOUS ENROLLMENT IN MBSF_AB_2010 FILE;

data contenr_2010;
    set mbsf_ab_2010;
	length contenrl_ab_2010 contenrl_hmo_2010 $5.;
    /* IDENTIFY BENEFICIARIES WITH PARTS A AND B OR HMO COVERAGE */
    if bene_hi_cvrage_tot_mons=12 and bene_smi_cvrage_tot_mons=12 then
    contenrl_ab_2010='ab'; else contenrl_ab_2010='noab'; 
    if bene_hmo_cvrage_tot_mons=12 then contenrl_hmo_2010='hmo';
    else contenrl_hmo_2010='nohmo'; 
	/* CLASSIFY BENEFICIARIES THAT PASSED AWAY IN 2010 */
	if death_dt ne . then death_2010=1; else death_2010=0;
run;
title;

title "VARIABLES USED TO GET CONTINUOUS ENROLLMENT";
proc freq data=contenr_2010; 
    tables contenrl_ab_2010 contenrl_hmo_2010 death_2010 / missing; 
run;
title;


*Azamat's Preparation and Merging Data Sets;

/* SORT OUTPATIENT CLAIM LINES FILE IN PREPARATION FOR TRANSFORMATION */
proc sort data=op2010line out=op2010line; 
	by bene_id clm_id clm_ln; 
run;

/* TRANSFORM OUTPATIENT CLAIM LINE FILE */;
data op2010line_wide(drop=i clm_ln hcpcs_cd);
	format	hcpcs_cd1-hcpcs_cd45 $5.;
	set op2010line;
	by bene_id clm_id clm_ln;
	retain 	hcpcs_cd1-hcpcs_cd45;

	array	xhcpcs_cd(45) hcpcs_cd1-hcpcs_cd45;

	if first.clm_id then do;
		do i=1 to 45;
			xhcpcs_cd(clm_ln)='';
		end;
	end;

	xhcpcs_cd(clm_ln)=hcpcs_cd;

	if last.clm_id then output;
run;

/* SORT CLAIM AND TRANSFORMED CLAIM LINES FILES IN PREPARATION FOR MERGE */
proc sort data=op2010claim out=op2010claim; 
	by bene_id clm_id; 
run; 

proc sort data=op2010line_wide;
    by bene_id clm_id;
run; 

proc print data=op2010line_wide(obs=2); 
	var bene_id clm_id hcpcs_cd1 hcpcs_cd2 hcpcs_cd3; 
run;

proc print data=op2010claim(obs=10); 
	var bene_id clm_id from_dt thru_dt; 
run;

*combine op2010claim and op2010line_wide horizontally using a data-step match-merge;
* note: After running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.03 seconds of combined "real time" to execute and a maximum of
  about 27.9 MB of memory (25076 KB for the data step vs. 27908 KB for the
  proc sort step) on the computer they were tested on;


/* MERGE OUTPATIENT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES */
data op_2010_v1;
    retain
        bene_id
        clm_id
        from_dt
        thru_dt
        hcpcs_cd1
		hcpcs_cd3
    ;
    keep
        bene_id
        clm_id
        from_dt
        thru_dt
        hcpcs_cd1
		hcpcs_cd3
    ;
    merge
        op2010claim
        op2010line_wide
    ;
    by bene_id clm_id;

run;
proc sort data=op_2010_v1;
    by bene_id clm_id;
run;

* combine out2010 and out2010line_wide horizontally using proc sql;
* note: After running the proc sql step below several times and averaging
  the fullstimer output in the system log, they tend to take about 0.03
  seconds of "real time" to execute and about 35 MB of memory on the computer
  they were tested on. Consequently, the proc sql step appears to take roughly
  the same amount of time to execute as the combined data step and proc sort
  steps above, but to use 5MB more memory;
* note to learners: Based upon these results, the proc sql step is preferable
  if memory performance isn't critical. This is because less code is required,
  so it's faster to write and verify correct output has been obtained;

proc sql;
    create table op2010_v2 as
        select
             coalesce(A.bene_id,B.bene_id) as Bene_Code
            ,coalesce(A.clm_id,B.clm_id) as Claim_Code
            ,B.hcpcs_cd1 as Revenue_Center_1
            ,B.hcpcs_cd3 as Revenue_Center_2
            ,A.from_dt as from_dt
            ,A.thru_dt as thru_dt
        from
            op2010claim as A
            full join
            op2010line_wide as B
            on A.bene_id=B.bene_id and A.clm_id=B.clm_id
        order by
            a.bene_id, a.clm_id
    ;
quit;

* verify that ip2010_v1 and ip2010_v2 are identical;
proc compare
        base=op2010_v1
        compare=op2010_v2
        novalues
    ;
run;
