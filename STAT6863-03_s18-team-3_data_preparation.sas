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

