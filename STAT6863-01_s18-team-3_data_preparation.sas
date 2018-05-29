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
https://github.com/stat6863/team-3_project_repo/blob/master/data/Inpatient_Claim_2_2010.csv?raw=true
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
https://github.com/stat6863/team-3_project_repo/blob/master/data/Master_Beneficiary_Summary_2010_v2.csv?raw=true
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
https://github.com/stat6863/team-3_project_repo/blob/master/data/Outpatient_Claim_2_2010.csv?raw=true
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


* check Ip2010claim for bad unique id values, where the column CLM_ID is a unique key
after executing this query, we see that Ip2010claim_dups has no rows. 
No mitigation needed for ID values;

proc sql;
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

* check Mbsf_AB_2010 for bad unique id values, where the column Bene_ID is a unique key
  after executing this query, we see that Mbsf_AB_2010_dups has no rows. 
  No mitigation needed for ID values;

proc sql;
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

* check Op2010claim for bad unique id values, where the column Clm_ID is a unique key
  after executing this query, we see that Op2010claim_dups has no rows. 
  No mitigation needed for ID values;
  
proc sql;

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

* We combine ip2010claim, op2010claim, mbsf_ab_2010 and msabea_ssa data sets
in final analytic file named contenr2010_analytic_file using full join and union;

proc sql;
    create table contenr2010_analytic_file_raw as
        select
            a.bene_id 'Benefeciary Code'
            ,a.clm_id 'Benefeciary Claim' format= 20. 
            ,put(c.race,2.) 'Benefeciary Race Code' as Race
            ,put(c.sex,2.) 'Sex' as Sex format=$sex_cats_fmt.
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
            ,a.clm_ID as IP_ClmID format=20.
                
        from
            ip2010claim A
 
        full join
            mbsf_ab_2010 C  

        on a.bene_id=c.bene_id  
 
        full join
            msabea_ssa D

        on c.ssa=d.ssa 

    outer union corr

        select
            b.bene_id 'Benefeciary Code'
            ,b.clm_id 'Benefeciary Claim' format= 20.
            ,put(c.race,2.) 'Benefeciary Race Code' as Race
            ,put(c.sex,2.) 'Sex' as Sex format=$sex_cats_fmt.
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
            ,b.clm_id as OP_ClmID format=20.
            
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
           ,OP_Pmt_Amt
           ,OP_ClmID
           ,IP_Pmt_Amt
           ,IP_ClmID
           , 
           case
              when sex=" 1" then "Male"
              else "Female"
           end as gender
           ,
           case
              when race=" 1" then "White"
              when race=" 2" then "Black"
              when race=" 3" then "Other"
              else "Hispanic"
           end as ethnicity
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

* Note: To investigate the distribution of age of benefeciaries in the 2010
we created the appropriate age categories. Since it seems that the comparison 
operators with numerical variable is not working within Proc SQL Case statement
we used SAS data step instead to calculate age and apply formats.;

proc format; 
    value age_cats_fmt
          0=' < 65'
          1='65 and 74' 
          2='75 and 84'
          3='85 and 94'
          4=' > or = 95';
run;

data contenr2010_analytic_file_raw1;
    set contenr2010_analytic_file_raw1;
    format age_cats age_cats_fmt.;
    study_age=floor(
        (
        intck('month', bene_dob, '01jan2010'd) - 
        (day('01jan2010'd) < day(bene_dob))
        ) / 12);
    select;
        when (study_age<65)      age_cats=0;
        when (65<=study_age<=74) age_cats=1;
        when (75<=study_age<=84) age_cats=2;
        when (85<=study_age<=94) age_cats=3;
        when (study_age>=95)     age_cats=4;
    end;
    label age_cats='Beneficiary age category at January 1, 2010';
run;
 
data contenr2010_analytic_file_raw1;
set contenr2010_analytic_file_raw1;
    where bene_id is not missing 
    and 
    clm_id > 1 and county is not missing;
run;

proc sort
    nodupkey
    data=contenr2010_analytic_file_raw1
    out=contenr2010_analytic_file
    ;
    by
    Bene_ID clm_id
    ;
run;


