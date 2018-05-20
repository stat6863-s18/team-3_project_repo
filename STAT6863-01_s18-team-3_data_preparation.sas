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


*
[Dataset 5 Name] MSABEA03.csv

[Dataset Description] US State and County Codes

[Experimental Unit Description] US State Code

[Number of Observations] 32,090

[Number of Features] 3

[Data Source]  https://www.cms.gov/Research-Statistics-Data-and-Systems/
Statistics-Trends-and-Reports/HealthPlanRepFileData/Downloads/SCP-2003.zip
was downloaded and edited to produce file by subsetting to get State,
County and SSA Code. 

[Data Dictionary] https://github.com/stat6863/team-3_project_repo/blob/master/
data/Data_Dictionary_Medicare.doc

[Unique ID Schema] "State", "County" form a composite key
;
%let inputDataset5DSN = Msabea_ssa;
%let inputDataset5URL =
https://raw.githubusercontent.com/stat6863/team-3_project_repo/master/data/MSABEA03.csv?raw=true
;
%let inputDataset5Type = CSV;


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
    %do i = 1 %to 5;
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

    * check for duplicate unique id values after executing this query, we
    see that Ip2010line_dups has no rows. No mitigation needed for ID values;  

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
    *check for duplicate unique id values; after executing this query, we
     see that Mbsf_AB_2010_dups has no rows. No mitigation needed for ID values;
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

* check Op2010claim for bad unique id values, where the column Clm_ID is a unique key;

proc sql;
    *check for duplicate unique id values after executing this query, we
     see that Op2010claim_dups has no rows. No mitigation needed for ID values;
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

* inspect columns of interest in cleaned versions of data sets;

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

* We have in this file information about Medicare beneficiaries who
enrolled in Part A (BENE_HI_CVRAGE_TOT_MONS), Part B
(BENE_SMI_CVRAGE_TOT_MONS) and Part C (BENE_HMO_CVRAGE_TOT_MONS)
program.

Prepare datasets to get continious enrollment in mbsf_ab_2010 file;

data contenr_2010;
    set mbsf_ab_2010;
	length contenrl_ab_2010 contenrl_hmo_2010 $5.;
    * Identify Benefeciaries With Parts A And B or HMO Coverage;
    if bene_hi_cvrage_tot_mons=12 and bene_smi_cvrage_tot_mons=12 then
    contenrl_ab_2010='ab'; else contenrl_ab_2010='noab'; 
    if bene_hmo_cvrage_tot_mons=12 then contenrl_hmo_2010='hmo';
    else contenrl_hmo_2010='nohmo'; 
	* classify benefeciaries that passed away in 2010;
	if death_dt ne . then death_2010=1; else death_2010=0;
run;
title;

* Create a 2010 enrollment file of only continuously enrolled beneficiaries
by combining alive beneficiaries with parts a and b or hmo coverage;
data contenr_2010_fnl;
    set contenr_2010;
	if contenrl_ab_2010='ab' and contenrl_hmo_2010='nohmo' and death_2010 ne 1;
run;

*Sort outpatient claim lines file in preparation for transformation;
proc sort data=op2010line out=op2010line; 
	by bene_id clm_id clm_ln; 
run;

* Transform outpatient claim line file;
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

* Sort claim and transformed claim lines files in preparation for merge;
proc sort data=op2010claim out=op2010claim; 
	by bene_id clm_id; 
run; 

proc sort data=op2010line_wide;
    by bene_id clm_id;
run; 

* Combine op2010claim and op2010line_wide horizontally using a data-step match-merge;

* Note: after running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.03 seconds of combined "real time" to execute and a maximum of
  about 27.9 mb of memory (25076 kb for the data step vs. 27908 Kb for the
  proc sort step) on the computer they were tested on;

* Merge outpatient base claim and transformed revenue center files;
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

* Combine out2010 and out2010line_wide horizontally using proc sql;

* Note: after running the proc sql step below several times and averaging
  the fullstimer output in the system log, they tend to take about 0.03
  seconds of "real time" to execute and about 35 mb of memory on the computer
  they were tested on. Consequently, the proc sql step appears to take roughly
  the same amount of time to execute as the combined data step and proc sort
  steps above, but to use 5mb more memory;

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

* Verify that ip2010_v1 and ip2010_v2 are identical;

proc compare
        base=op2010_v1
        compare=op2010_v2
        novalues
    ;
run;
title;

* Combine mbsf_ab_2010 and ip2010line horizontally using a data-step 
match-merge;

* Note: after running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.18 seconds of combined "real time" to execute and a maximum of
  about 26.5 mb of memory on the computer they were tested on;
  
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

* Combine mbsf_ab_2010 and ip2010line horizontally using proc sql;

* Note: after running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.13 seconds of combined "real time" to execute and a maximum of
  about 14.6 mb of memory on the computer they were tested on;
  
proc sql;
    create table Mbsf_AB_2010_and_Ip2010line_v2 as
        select
             coalesce(A.BENE_ID,B.BENE_ID) as BENE_ID
             A.SP_RA_OA as RA_OA_Status
             A.SP_COPD as COPD_Status
             B.CLM_ID as CLM_ID
	     B.PMT_AMT as InP_PMT_AMT
        from
            Mbsf_AB_2010 as A
            full join
            Ip2010line as B
            on A.BENE_ID=B.BENE_ID
        order by
            BENE_ID
    ;
quit;

* Verify that mbsf_ab_2010_and_ip2010line_v1 and mbsf_ab_2010_and_ip2010line_v2
are identical;

proc compare
        base= Mbsf_AB_2010_and_Ip2010line_v1        
        compare= Mbsf_AB_2010_and_Ip2010line_v2
        novalues
    ;
run;

* Combine ip2010claim and op2010claim vertically using a data-step interweave;

* Note: after running the data step and proc sort step below several times
  and averaging the fullstimer output in the system log, they tend to take
  about 0.11 seconds of combined "real time" to execute and a maximum of
  about 24 mb of memory (984 kb for the data step vs. 24000 Kb for the
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

* Combine ip2010claim and op2010claim vertically using proc sql;

* Note: after running the proc sql step below several times and averaging
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

* Verify that ip2010claim_and_op2010claim_v1 and ip2010claim_and_op2010claim_v2 are
  identical;

proc compare
        base=ip2010claim_and_op2010claim_v1
        compare=ip2010claim_and_op2010claim_v2
        novalues
    ;
run;

* Preparation of state and county information for contenr2010_fnl dataset that
contains all benefeciaries (part a, b and hmo) who enrolled in medicare
program in 2010;

* Sort ssa state and county codes file to remove duplicate record;
proc sort data=msabea_ssa nodupkey; 
	by ssa; 
run;

* Create ssa variable on enrollment data;
data contenr_2010_fnl;
	set contenr_2010_fnl;
	ssa=state_cd||cnty_cd;
run;

* Sort continuous enrollment data contenr_2010_fnl
and merge with msabea file;
proc sort data=contenr_2010_fnl; by ssa; run;

data contenr_2010_fnl;
	merge contenr_2010_fnl(in=a) src.msabea_ssa(in=b);
	by ssa;
	if a;
run;

* Create final enrollment file with state and county code;
proc sort data=contenr_2010_fnl; 
	by bene_id; 
run;

title;

* First, we try to do full join with 3 files:ip2010claim, op2010claim
and msbf_2010_ab;

* First, we try to do full join with 3 files:ip2010claim, op2010claim
and msbf_2010_ab;

proc sql;
    create table contenr2010_analytic_file_raw as
        select
		     coalesce(A.Bene_ID,C.Bene_ID,D.Bene_ID)
<<<<<<< HEAD
             AS Bene_ID
			 			 		 
=======
             AS Bene_ID			 		 
>>>>>>> b2d098e268681921f4cac51b9af86fe18c654027
			 ,c.thru_dt 
			 ,c.from_dt 
             		 ,a.bene_hi_cvrage_tot_mons as Part_A
			 ,a.bene_smi_cvrage_tot_mons as Part_B
			 ,a.bene_hmo_cvrage_tot_mons as Non_HMO
			 ,a.death_dt as Alive
			 ,a.sp_ra_oa as RA_OA_Status
			 ,a.sp_copd as COPD_Status
			 ,c.clm_id as IP_Claim
			 ,c.pmt_amt as IP_Pmt_Amt
			 ,d.clm_id as OP_Claim
			 ,d.pmt_amt as OP_Pmt_Amt	 
      
        from mbsf_ab_2010 as A

            full join

<<<<<<< HEAD
        ip2010claim as C
=======
        ip2010line as C
>>>>>>> b2d098e268681921f4cac51b9af86fe18c654027
            on A.Bene_ID = C.Bene_ID

            full join

        op2010claim as D
            on c.Bene_ID = d.Bene_ID

	order by
        Bene_ID
    ;
quit;

proc sql;
	create table contenr2010_analytic_file_raw as
		select
			 coalesce(A.Bene_ID,B.Bene_ID,C.Bene_ID) AS Bene_ID
			,coalesce(A.clm_ID,B.clm_ID) AS clm_ID
			,A.SSa
<<<<<<< HEAD

		from ip2010claim A 

		full join op2010claim B

		on (A.bene_id=B.bene_id and A.clm_id=B.clm_id)

		full join MBSF_ab_2010 C 

=======
		from ip2010claim A 
		full join op2010claim B

		on (A.bene_id=B.bene_id and A.clm_id=B.clm_id)
		full join MBSF_ab_2010 C 
>>>>>>> b2d098e268681921f4cac51b9af86fe18c654027
		on (A.bene_id=C.bene_id )
    ;
quit;

* Second we do full join of combined file i n previous step
and msabea_ssa data set to get state, county code in final
file.;

proc sql;
	create table contenr2010_analytic_file_raw as
		select
			coalesce(A.Bene_ID,B.Bene_ID,C.Bene_ID) AS Bene_ID
			,coalesce(A.clm_ID,B.clm_ID) AS clm_ID,
			Compress(C.state_Cd||C.CNTY_CD) as SSA
			from ip2010claim A,  op2010claim B, MBSF_ab_2010 C, msabea_ssa D
		where 
			(A.bene_id=B.bene_id  and A.clm_id=b.clm_id)
			and (A.bene_id=C.bene_id )
			and 
		and (ssa=D.ssa); 
quit;

<<<<<<< HEAD
/* notes to learners:
    (1) even though the data-integrity check and mitigation steps below could
        be performed with SQL queries, as was used earlier in this file, it's
        often faster and less code to use data steps and proc sort steps to
        check for and remove duplicates; in particular, by-group processing
        is much more convenient when checking for duplicates than the SQL row
        aggregation and in-line view tricks used above; in practice, though,
        you should use whatever methodology you're most comfortable with
    (2) when determining what type of join to use to combine tables, it's
        common to designate one of the table as the "master" table, and to use
        left (outer) joins to add columns from the other "auxiliary" tables
    (3) however, if this isn't the case, an inner joins typically makes sense
        whenever we're only interested in rows whose unique id values match up
        in the tables to be joined
    (4) similarly, full (outer) joins tend to make sense whenever we want all
        possible combinations of all rows with respect to unique id values to
        be included in the output dataset, such as in this example, where not
        every dataset will necessarily have every possible of Bene_ID
		and clm_id in it.
    (5) unfortunately, though, full joins of more than two tables can also
        introduce duplicates with respect to unique id values, even if unique
        id values are not duplicated in the original input datasets 
*/

=======
>>>>>>> b2d098e268681921f4cac51b9af86fe18c654027
* we use proc sort to indiscriminately remove
  duplicates, after which column Bene_ID and Clm_ID is guaranteed to form
  a composite key;
proc sort
        nodupkey
        data=contenr2010_analytic_file_raw
        out=contenr2010_analytic_file
    ;
    by
        Bene_ID, clm_id
    ;
run;
