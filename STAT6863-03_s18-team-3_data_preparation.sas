*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

[Dataset 1 Name] Hospital Charge Data

[Dataset Description] Inpatient Prospective Payment System (IPPS) Provider Summary for the Top 100 
Diagnosis-Related Groups (DRG) - FY2011

[Experimental Unit Description] Medicare Provider

[Number of Observations] 163,065 

[Number of Features] 12

[Data Source] https://data.cms.gov/api/views/97k6-zzx3/rows.csv?accessType=DOWNLOAD&bom=true&format=true

[Data Dictionary] https://data.cms.gov/Medicare-Inpatient/Inpatient-Prospective-Payment-System-IPPS-Provider/97k6-zzx3

[Unique ID Schema] The column Provider_ID is a unique id.
;
%let inputDataset1DSN = frpm1415_raw;
%let inputDataset1URL =
https://github.com/stat6250/team-0_project2/blob/master/data/frpm1415-edited.xls?raw=true
;
%let inputDataset1Type = XLS;

***

[Dataset 2 Name] Payment and Value of Care (Hospital)

[Dataset Description] Hospital-level results for payment measures and value of care displays
associated with 30-day mortality measures in 2015

[Experimental Unit Description] Medicare Provider

[Number of Observations] 19,200

[Number of Features] 23

[Data Source] https://data.medicare.gov/Hospital-Compare/Payment-and-value-of-care-Hospital/c7us-v4mf

[Data Dictionary] https://data.medicare.gov/Hospital-Compare/Payment-and-value-of-care-Hospital/c7us-v4mf

[Unique ID Schema] The columns "Provider_ID", and "Measure_ID" form a composite key, which together 
are equivalent to the unique id column Provider_ID in dataset hospital charge data.

***

[Dataset 3 Name] Timely and Effective Care: Process of Care Measures

[Dataset Description] The percentage of hospital patients who got treatments known to get the best 
results for certain common, serious medical conditions or surgical procedures in 2015

[Experimental Unit Description] Medicare Provider

[Number of Observations] 101,000                    
[Number of Features] 17

[Data Source] https://data.medicare.gov/Hospital-Compare/Timely-and-Effective-Care-Hospital/yv7e-xc69

[Data Dictionary] https://data.medicare.gov/Hospital-Compare/Timely-and-Effective-Care-Hospital/yv7e-xc69

[Unique ID Schema] The column Provider_ID is a unique id.

***

[Dataset 4 Name] Hospitals General Information

[Dataset Description] A list of all Hospitals that have been registered with Medicare. The list 
includes location, address, contact details, and hospital type.

[Experimental Unit Description] The US Hospitals registered in Medicare program.

[Number of Observations] 4,806 

[Number of Features] 28

[Data Source] https://data.medicare.gov/Hospital-Compare/Hospital-General-Information/xubh-q36u

[Data Dictionary] https://data.medicare.gov/Hospital-Compare/Hospital-General-Information/xubh-q36u

[Unique ID Schema] The column Provider_ID is a unique id.
;
%let inputDataset1DSN = frpm1415_raw;
%let inputDataset1URL =
https://github.com/stat6250/team-0_project2/blob/master/data/frpm1415-edited.xls?raw=true
;
%let inputDataset1Type = XLS;


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
