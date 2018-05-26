*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset 1 Name] Inpatient_Claim_2_2010.csv

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
%let inputDataset1DSN = Ip2010claim;
%let inputDataset1URL =
https://raw.githubusercontent.com/stat6863/team-3_project_repo/master/data/Master_Inpatient_Claim_2010_sorted.csv?raw=true
;
%let inputDataset1Type = CSV;


*
[Dataset 2 Name] Master_Beneficiary_Summary_2010.csv

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
%let inputDataset2DSN = Mbsf_AB_2010;
%let inputDataset2URL =
https://github.com/stat6863/team-3_project_repo/blob/master/data/Master_Beneficiary_Summary_2010.csv?raw=true
;
%let inputDataset2Type = CSV;


*
[Dataset 3 Name] Outpatient_Claim_2_2010.csv

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
%let inputDataset3DSN = Op2010claim;
%let inputDataset3URL =
?raw=true
;
%let inputDataset3Type = CSV;


*
[Dataset 4 Name] MSABEA03.csv

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
%let inputDataset4DSN = Msabea_ssa;
%let inputDataset4URL =
https://raw.githubusercontent.com/stat6863/team-3_project_repo/master/data/MSABEA03.csv?raw=true
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

* First, we try to do full join with 3 files:ip2010claim, op2010claim
and msbf_2010_ab;

proc sql;
    create table contenr2010_analytic_file_raw as
        select
	     coalesce(A.Bene_ID,C.Bene_ID,D.Bene_ID)
             AS Bene_ID
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

        ip2010line as c

            on A.Bene_ID = C.Bene_ID

            full join

        op2010claim as D
            on a.Bene_ID = d.Bene_ID

	order by
        Bene_ID
    ;
quit;

*/We combine ip2010claim, op2010claim, mbsf_ab_2010 and msabea_ssa data sets
in final analytic file named contenr2010_analytic_file using full join and union;

proc sql;
	create table contenr2010_analytic_file_raw as
		select
			a.bene_id 'Benefeciary Code'
			,a.clm_id 'Benefeciary Claim' format= 20. 
			,put(c.race,2.) 'Benefeciary Race Code' as Race
			,put(c.sex,2.) 'Sex' as Sex
			,c.bene_dob 'Date of Birth' 
			,c.bene_hi_cvrage_tot_mons 'Part A'
			,c.bene_smi_cvrage_tot_mons 'Part B'
			,c.bene_hmo_cvrage_tot_mons 'HMO'
			,c.death_dt 'Date of Death'
			,d.county format=$25. length=25 'County Name'
			,d.state length=2 'State Name'
			,c.sp_ra_oa as RA_OA_Status
	        ,c.sp_copd as COPD_Status
			,a.pmt_amt as IP_Pmt_Amt
	        	
		from
			ip2010claim A
 
		full join
			mbsf_ab_2010 C  

		on a.bene_id=c.bene_id  
 
		full join
			msabea_ssa D

		on c.ssa=d.ssa 

   	union corr

		select
			b.bene_id 'Benefeciary Code'
			,b.clm_id 'Benefeciary Claim' format= 20.
			,put(c.race,2.) 'Benefeciary Race Code' as Race
			,put(c.sex,2.) 'Sex' as Sex
			,c.bene_dob 'Date of Birth' 
			,c.bene_hi_cvrage_tot_mons 'Part A'
			,c.bene_smi_cvrage_tot_mons 'Part B'
			,c.bene_hmo_cvrage_tot_mons 'HMO'
			,c.death_dt 'Date of Death'
			,D.county format=$25. length=25 'County Name'
			,D.state length=2 'State Name'
			,c.sp_ra_oa as RA_OA_Status
	        ,c.sp_copd as COPD_Status
	        ,b.pmt_amt as OP_Pmt_Amt
	        
		from
			op2010claim B

		full join
			mbsf_ab_2010 C
 
		on b.bene_id=c.bene_id 

		full join
			msabea_ssa D
 
		on c.ssa=d.ssa 

		order by bene_id, clm_id
		;
quit;

*Since incorporating this query to our single SQL query above causing to produce 
more complicated code, we buld separate SQL query to prepare continious enrollment
benefeciaries in 2010 (Part A, Part B, without HMO benefeciaries, 
who are still alive in 2010);

proc sql;
create table contenr2010_analytic_file_raw1 as
	   select
		   bene_id 
	       ,clm_id
	       ,Sex
	       ,Race
	       ,death_dt
		   ,state
	       ,county
	       ,COPD_Status
           ,RA_OA_Status
		   ,bene_hi_cvrage_tot_mons
		   ,bene_smi_cvrage_tot_mons
	       ,bene_hmo_cvrage_tot_mons
	       ,bene_dob
	       ,
		   case 
		      when bene_hi_cvrage_tot_mons=12 
			  and bene_smi_cvrage_tot_mons=12 then "ab"
		      else "noab"
		   end as contenrl_ab_2010
		   ,
		   case
		      when bene_hmo_cvrage_tot_mons=12 then "hmo"
			  else "nohmo"
		   end as contenrl_hmo_2010
		   ,
		   case
	 	      when death_dt ne . then 1
			  else 0
		   end as death_2010
from contenr2010_analytic_file_raw;
quit;

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

* After combining all data sets and adding several vars to define continious
enrollement for data analysis we still have missing values because of full 
join, so we need to fix it;
 
data contenr2010_analytic_file_raw1;
set contenr2010_analytic_file_raw1;
where clm_id > 1 ;
run;

* we use proc sort to indiscriminately remove
  duplicates, after which column Bene_ID and Clm_ID is guaranteed to form
  a composite key;
proc sort
        nodupkey
        data=contenr2010_analytic_file_raw1
        out=contenr2010_analytic_file
    ;
    by
        Bene_ID clm_id
    ;
run;

* check everything looks fine now;
proc print data=contenr2010_analytic_file(obs=25); run;
