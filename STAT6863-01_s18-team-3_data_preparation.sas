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


* check Ip2010claim for bad unique id values, where the column CLM_ID is a 
unique key after executing this query, we see that Ip2010claim_dups has no 
rows. No mitigation needed for ID values;

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

* check Mbsf_AB_2010 for bad unique id values, where the column Bene_ID is a
unique key after executing this query, we see that Mbsf_AB_2010_dups has no 
rows. No mitigation needed for ID values;

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

* check Op2010claim for bad unique id values, where the column Clm_ID is a 
unique key after executing this query, we see that Op2010claim_dups has no 
rows. No mitigation needed for ID values;
  
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

* create formats to apply for sex, race, study_age, bene_hmo_cvrage_tot_mons 
and death_dt variables;

proc format; 
    value SexF
        1='Male'
        2='Female';
    value DiseaseF
        1='Yes'
        2='No';
    value ClaimF
	0 = '0'
	1-20 = '>1';
    value RaceF
        1='White' 
        2='Black'
        3='Other'
        4='Asian'
        5='Hispanic'
        6='North American Native';
    value AgeF
        10-64="10 - 65"
        65-74="65 - 74"
        75-84="75 - 84"
        85-94="85 - 94"
        95-110="95 -110";
    value HmoF
        12="hmo"
        0-11="nohmo";
    value deathF
        . = 'Alive'
        15000-20000 = 'Died';
run;

* Combine ip2010claim, op2010claim, mbsf_ab_2010 and msabea_ssa data sets
in final analytic file named contenr2010_analytic_file using full join 
and union;

proc sql;
    create table contenr2010_analytic_file_raw as
        select
            distinct a.bene_id 'Benefeciary Code'
            ,a.clm_id 'Benefeciary Claim' format= 20.
            ,c.race 'Benefeciary Race' format=RaceF.
            ,c.Sex format=SexF.  
            ,c.bene_dob 'Date of Birth' 
            ,c.bene_hi_cvrage_tot_mons 'Part A'
            ,c.bene_smi_cvrage_tot_mons 'Part B'
            ,c.bene_hmo_cvrage_tot_mons 'HMO' format=Hmof.
            ,c.death_dt 'Date of Death' format=deathF.
            ,
            floor(
            (
            intck('month', c.bene_dob, '01jan2010'd) - 
            (day('01jan2010'd) < day(c.bene_dob))
            ) / 12) format=AgeF. as Study_Age
            ,
            case
              when c.bene_hi_cvrage_tot_mons=12 
              and c.bene_smi_cvrage_tot_mons=12 then "ab"
              else "noab"
            end as Contenrl_ab_2010
 
            ,d.county length=25 'County Name' as county
            ,d.state length=2 'State Name'
            ,c.sp_ra_oa as RA_OA_Status format=DiseaseF.
            ,c.sp_copd as COPD_Status format=DiseaseF.
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
        
            distinct b.bene_id 'Benefeciary Code'
            ,b.clm_id 'Benefeciary Claim' format= 20.
            ,c.race 'Benefeciary Race' format=RaceF.
            ,c.sex format=SexF. 
            ,c.bene_dob 'Date of Birth' 
            ,c.bene_hi_cvrage_tot_mons 'Part A'
            ,c.bene_smi_cvrage_tot_mons 'Part B'
            ,c.bene_hmo_cvrage_tot_mons 'HMO' format=Hmof.
            ,c.death_dt 'Date of Death' format=deathF.
            ,
            floor(
            (
            intck('month', c.bene_dob, '01jan2010'd) - 
            (day('01jan2010'd) < day(c.bene_dob))
            ) / 12) format=AgeF. as study_age
            ,
            case
              when c.bene_hi_cvrage_tot_mons=12 
              and c.bene_smi_cvrage_tot_mons=12 then "ab"
              else "noab"
            end as contenrl_ab_2010

            ,d.county length=25 'County Name' as county
            ,d.state length=2 'State Name'
            ,c.sp_ra_oa as RA_OA_Status format=DiseaseF.
            ,c.sp_copd as COPD_Status format=DiseaseF.
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

*Remove blanks after full join and outer union;

data contenr2010_analytic_file;
set contenr2010_analytic_file_raw;
    where bene_id is not missing 
    and 
    clm_id > 1 and county is not missing;
run;

