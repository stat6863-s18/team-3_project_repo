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

[Unique ID Schema] The columns "Claim_ID", "Bene_ID" form a composite key.

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

* set global system options;
options fullstimer;

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

* inspect columns of interest in cleaned versions of data sets
/*
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

     title "Inspect Inpatient Claim Claim Utilization Day Count (UTIL_DAY) in Ip2010claim";
	proc sql;
    	    select
         	min(bene_hi_cvrage_tot_mons) as min
        	,max(bene_hi_cvrage_tot_mons) as max
        	,mean(bene_hi_cvrage_tot_mons) as mean
        	,nmiss(bene_hi_cvrage_tot_mons) as missing
    	    from
            	mbsf_ab_2010
    	    ;
	quit;
	title;
*/

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

*CREATE A 2010 ENROLLMENT FILE OF ONLY CONTINUOUSLY ENROLLED BENEFICIARIES
BY COMBINING ALIVE BENEFICIARIES WITH PARTS A AND B OR HMO COVERAGE*/;
data contenr_2010_fnl;
    set contenr_2010;
	if contenrl_ab_2010='ab' and contenrl_hmo_2010='nohmo' and death_2010 ne 1;
run;

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

*combine op2010claim and op2010line_wide horizontally using a data-step match-merge;
* note: After running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.03 seconds of combined "real time" to execute and a maximum of
  about 27.9 MB of memory (25076 KB for the data step vs. 27908 KB for the
  proc sort step) on the computer they were tested on;


/* MERGE OUTPATIENT BASE CLAIM AND TRANSFORMED REVENUE CENTER FILES */
data op2010_v1;
    retain
        bene_id
        clm_id
        from_dt
        thru_dt
        hcpcs_cd1
		hcpcs_cd3
		admtg_dgns_cd
    ;
    keep
        bene_id
        clm_id
        from_dt
        thru_dt
        hcpcs_cd1
		hcpcs_cd3
		admtg_dgns_cd
    ;
    merge
        op2010claim
        op2010line_wide
    ;
    by bene_id clm_id;

run;
proc sort data=op2010_v1;
    by bene_id clm_id;
run;

* combine out2010 and out2010line_wide horizontally using proc sql;
* note: After running the proc sql step below several times and averaging
  the fullstimer output in the system log, they tend to take about 0.03
  seconds of "real time" to execute and about 35 MB of memory on the computer
  they were tested on. Consequently, the proc sql step appears to take roughly
  the same amount of time to execute as the combined data step and proc sort
  steps above, but to use 5MB more memory;

proc sql;
    create table op2010_v2 as
        select
             coalesce(A.bene_id,B.bene_id) as bene_id
            ,coalesce(A.clm_id,B.clm_id) as clm_id
            ,B.hcpcs_cd1 as Revenue_Center_1
            ,B.hcpcs_cd3 as Revenue_Center_2
            ,A.from_dt as from_dt
            ,A.thru_dt as thru_dt
			,A.admtg_dgns_cd
        from
            op2010claim as A
            full join
            op2010line_wide as B
            on A.bene_id=B.bene_id and A.clm_id=B.clm_id
        order by
            bene_id, clm_id
    ;
quit;

* verify that ip2010_v1 and ip2010_v2 are identical;
proc compare
        base=op2010_v1
        compare=op2010_v2
        novalues
    ;
run;
title;

* combine Mbsf_AB_2010 and Ip2010line horizontally using a data-step 
match-merge;
* note: After running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.03 seconds of combined "real time" to execute and a maximum of
  about 27.9 MB of memory (25076 KB for the data step vs. 27908 KB for the
  proc sort step) on the computer they were tested on;
  
data Mbsf_AB_2010_and_Ip2010line_v1;
    retain
        BENE_ID
        SP_RA_OA
        SP_COPD
        CLM_ID
        PMT_AMT
    ;
    keep
        BENE_ID
        SP_RA_OA
        SP_COPD
        CLM_ID
        PMT_AMT
    ;
    merge
        Mbsf_AB_2010
        Ip2010line 
    ;
    by BENE_ID;
run;

proc sort data= data Mbsf_AB_2010_and_Ip2010line_v1;
    by BENE_ID;
run;

* combine Mbsf_AB_2010 and Ip2010line horizontally using proc sql;
* note: After running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.03 seconds of combined "real time" to execute and a maximum of
  about 27.9 MB of memory (25076 KB for the data step vs. 27908 KB for the
  proc sort step) on the computer they were tested on;
  
proc sql;
    create table Mbsf_AB_2010_and_Ip2010line_v2 as
        select
             coalesce(A.BENE_ID,B.BENE_ID) as BENE_ID
            ,input(A.SP_RA_OA) as RA_OA_Status
            ,input(A.SP_COPD) as COPD_Status
            ,input(B.CLM_ID) as CLM_ID
	    ,input(B.PMT_AMT) as InP_PMT_AMT
        from
            Mbsf_AB_2010 as A
            full join
            Ip2010line as B
            on A.BENE_ID=B.BENE_ID
        order by
            BENE_ID
    ;
quit;

* verify that Mbsf_AB_2010_and_Ip2010line_v1 and Mbsf_AB_2010_and_Ip2010line_v2
are identical;

proc compare
        base= Mbsf_AB_2010_and_Ip2010line_v1        
        compare= Mbsf_AB_2010_and_Ip2010line_v2
        novalues
    ;
run;

* combine ip2010claim and op2010claim vertically using a data-step interweave,
* note: After running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.11 seconds of combined "real time" to execute and a maximum of
  about 24 MB of memory (984 KB for the data step vs. 24000 KB for the
  proc sort step) on the computer they were tested on;

data ip2010claim_and_op2010claim_v1;
    retain
        Bene_ID
        Claim_ID
        Admtg_dgns_CD
        From_DT
        Thru_DT
        Provider
    ;
    keep
        Bene_ID
        Clm_ID
        Admtg_dgns_CD
        From_DT
        Thru_DT
        Provider
    ;
    length    
        Bene_ID $16.
        Clm_ID  $15.
        Admtg_dgns_CD  $5.
		From_DT   4.
		Thru_DT   4.
		Provider  $6.

    ;
    set
        ip2010claim(
            in = ip2010claim_row
            
        )
        op2010claim(
            
        )
    ;
    by
        Bene_ID
        Clm_ID
    ;

    if
        ip2010claim_row=1
    then
        do;
            Type = "IP-2010";
           
        end;
    else
        do;
            Type = "OP-2010";
            
        end;
run;
proc sort data=ip2010claim_and_op2010claim_v1;
    by Bene_ID Clm_ID;
run;

* combine ip2010claim and op2010claim vertically using proc sql;
* note: After running the proc sql step below several times and averaging
  the fullstimer output in the system log, they tend to take about 0.21
  seconds of "real time" to execute and about 25 MB of memory on the computer
  they were tested on. Consequently, the proc sql step appears to take more
  time to execute as the combined data step and proc sort steps
  above, but to use the same amount of memory;

proc sql;
    create table ip2010claim_and_op2010claim_v2 as
        (
            select
                 a.Bene_ID
                 ,a.Clm_ID
                 ,a.Admtg_dgns_CD
                 ,a.From_DT
                 ,a.Thru_DT
                 ,a.Provider
            from
                Ip2010claim as a
        )
		outer union corr
        (
            select
                 b.Bene_ID
                 ,b.Clm_ID
                 ,b.Admtg_dgns_CD
                 ,b.From_DT
                 ,b.Thru_DT
                 ,b.Provider
            from
                Op2010claim as b
        )
		order by
             Bene_ID
            ,Clm_ID
	;
quit;

* verify that ip2010claim_and_op2010claim_v1 and ip2010claim_and_op2010claim_v2 are
  identical;
proc compare
        base=ip2010claim_and_op2010claim_v1
        compare=ip2010claim_and_op2010claim_v2
        novalues
    ;
run;

*PREPARATION OF STATE AND COUNTY INFORMATION FOR CONTENR2010_FNL DATASET THAT
CONTAINS ALL BENEFECIARIES (PART A, B and HMO) WHO ENROLLED IN MEDICARE
PROGRAM IN 2010

/* LOAD SSA STATE AND COUNTY CODE INFORMATION */;

data msabea_ssa;
filename msabea url "https://raw.githubusercontent.com/stat6863/team-3_project_repo/master/data/MSABEA03_State_County_Code.TXT";
	infile msabea missover; 
	input 
		county $  1-25
		state  $ 26-27
		ssa    $ 30-34; 
run; 

/* SORT SSA STATE AND COUNTY CODES FILE TO REMOVE DUPLICATE RECORD */
proc sort data=msabea_ssa nodupkey; 
	by ssa; 
run;

/* CREATE SSA VARIABLE ON ENROLLMENT DATA*/
data contenr_2010_fnl;
	set contenr_2010_fnl;
	ssa=state_cd||cnty_cd;
run;

/* SORT CONTINUOUS ENROLLMENT DATA CONTENR_2010_FNL
AND MERGE WITH MSABEA FILE */
proc sort data=contenr_2010_fnl; by ssa; run;

data contenr_2010_fnl;
	merge contenr_2010_fnl(in=a) msabea_ssa(in=b);
	by ssa;
	if a;
run;

/* CREATE FINAL ENROLLMENT FILE WITH STATE AND COUNTY CODE*/
proc sort data=contenr_2010_fnl; 
	by bene_id; 
run;

