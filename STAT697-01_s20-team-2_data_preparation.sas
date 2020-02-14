*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/*
[Dataset 1 Name] gradaf17

[Dataset Description] Graduates meeting University of California (UC)/California 
State University (CSU) entrance requirements by racial/ethnic group and school, 
AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 2,535

[Number of Features] 15

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=UCGradEth&cPage=filesgradaf.asp 
was downloaded and edited to produce file gradaf17.xls by importing into Excel. 
And the column CDS_CODE was set to 'TEXT' format.

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset gradaf17 is the 
primary key column.
*/
%let inputDataset1DSN = gradaf17;
%let inputDataset1URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/gradaf17.xlsx?raw=true
;
%let inputDataset1Type = XLSX;


/*
[Dataset 2 Name] gradaf16

[Dataset Description] SGraduates meeting University of California (UC)/
California State University (CSU) entrance requirements by racial/ethnic group 
and school, AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 2,522

[Number of Features] 15

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2015-16&cCat=UCGradEth&cPage=filesgradaf.asp
was downloaded and edited to produce file grad16.xls by importing into Excel. 
And the column CDS_CODE was set to 'TEXT' format. 

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgrad09.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset gradaf16 is the 
primary key column.
*/
%let inputDataset2DSN = gradaf16;
%let inputDataset2URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/gradaf16.xlsx?raw=true
;
%let inputDataset2Type = XLSX;


/*
[Dataset 3 Name] StaffAssign16

[Dataset Description] Assignment data for all K-12 California public education 
certificated teachers, administrators, and pupil services personnel, AY2016-17

[Experimental Unit Description] K-12 California public education certificated 
teachers, administrators, and pupil services personnel, AY2016-17

[Number of Observations] 40,000

[Number of Features] 5

[Data Source] The file
http://www3.cde.ca.gov/download/dq/StaffAssign16.zip
was downloaded, imported into R with all columns setting to Character class. To 
make the file less than 5MB, 40000 rows were picked out of all the observation 
units randomly , and all the columns except 'DistrictCode', 'SchoolCode', 
'StaffType', 'EstimatedFTE' and 'File Created' were removed. The R dateframe 
produced was then imported into Excel to produce file StaffAssign.xls 

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The columns "District Code" and "School Code" form a 
composite key, which together are equivalent to the unique id column CDS_CODE 
in dataset grad16 and grad17.
*/
%let inputDataset3DSN = StaffAssign16;
%let inputDataset3URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/StaffAssign16.xlsx?raw=true
;
%let inputDataset3Type = XLSX;


/*
[Dataset 4 Name] enr16

[Dataset Description] Enrollment data for primary enrollments, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 8239

[Number of Features] 4

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=Enrollment&cPage=filesenr.asp
was downloaded, imported into R with all columns setting to Character class. As 
not all the schools have a considerably large number of Grade 12 students, rows 
with the value of column 'GR_12' less than 10 were removed. All the columns 
except 'CDS_CODE', 'ETHNIC', 'GENDER' and 'GR_12' were removed.

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsenr.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset enr16 is the primary 
key column.
*/
%let inputDataset4DSN = enr16;
%let inputDataset4URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/enr16.xlsx?raw=true
;
%let inputDataset4Type = XLSX;


/* load raw datasets over the wire, if they doesn't already exist */
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    /*input the macro variables of the dsn, url and dataset file type*/
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        /* to check they doesn't already exist */
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            /* loading datasets over the line */
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


proc sql;
    /* check for duplicate unique id values; after executing this query, we see
    that grad17_raw_dups has no missing unique id component */
    create table grad17_raw_dups as
        select
            COUNTY
            ,DISTRICT
            ,SCHOOL
            ,count(*) as row_count_for_unique_id_value
        from
            grad17
        group by
            COUNTY
            ,DISTRICT
            ,SCHOOL
        having
            row_count_for_unique_id_value > 1
    ;
    /* remove rows with missing unique id components, or with unique ids that do 
    not correspond to schools; after executing this query, the new dataset from
    grad1617 will have no duplicate/repeated unique id values, and all unique id
    values will correspond to our experimental units of interest, which are
    California Public K-12 schools; this means the columns COUNTY, DISTRICT, and
    SCHOOL in grad1617 are guaranteed to form a composite key */
    create table grad1617 as
        select
            *
        from
            grad17
        where
            /* remove rows with missing unique id value components */
            not(missing(COUNTY))
            and
            not(missing(DISTRICT))
            and
            not(missing(SCHOOL))
    ;
quit;


* check grad16 for bad unique id values, where the columns COUNTY, DISTRICT, and 
SCHOOL form a composite key;

proc sql;
    /* check for duplicate unique id values; after executing this query, we see
    that grad16 contains now rows, so no mitigation is needed to ensure
    uniqueness */
    create table grad16_dups as
        select
            COUNTY
            ,DISTRICT
            ,SCHOOL
            ,count(*) as row_count_for_unique_id_value
        from
            grad16
        group by
            COUNTY
            ,DISTRICT
            ,SCHOOL
        having
            row_count_for_unique_id_value > 1
    ;
    /* remove rows with missing unique id components, or iwht unique ids that do
    not correspond to schools; after executing this query, the new dataset 
    grad1516 will have no duplicate/repeated unique id values, and all unique id
    values will correspond to our experimental units of interest, which are 
    California Public K-12 schools; this means the columns COUNTY, DISTRICT, and
    SCHOOL in grad1516 are guaranteed to form a composite key */
    create table grad1516 as
        select
            *
        from
            grad16
        where
            /* remove rows with missing unique id value components */
            not(missing(COUNTY))
            and
            not(missing(DISTRICT))
            and
            not(missing(SCHOOL))
    ;
quit;

* check grad17 for bad unique id values, where the column CDS_CODE is intended 
to be a primary key;

proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
    non-schools; after executing this query, we see that 
    grad17_raw_bad_unique_ids only has no-school values of CDS_CODE that need to 
    be removed. The query below allows us to build a fit-for-purpose mitigation 
    step with no guessing or unnecessary effort */
    create table grad17_raw_bad_unique_ids as
        select
            A.*
        from
            grad17 as A
            left join
            (
                select
                    CDS_CODE
                    ,count(*) as row_count_for_unique_id_value
                from
                    grad17
                group by
                    CDS_CODE
            ) as B
            on A.CDS_CODE=B.CDS_CODE
        having
            /*capture rows corresponding to repeated primary key values */
            row_count_for_unique_id_value > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(CDS_CODE)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(CDS_CODE,8,7) in ("0000000","0000001")
    ;
    /* remove rows with primary keys that do not correspond to schools; after
    executing this query, the new dataset grad1617 will have no 
    duplicate/repeated unique id values, and all unique id values will 
    correspond to our experimental units of interest, which are California 
    Public K-12 schools; this means the column CDS_CODE in grad1617 is 
    guaranteed to form a primary key */
    create table grad1617 as
        select
            *
        from
            grad17
    ;
quit;

    /* We want to identify duplicates in the unique primary key CDS_CODE in
    dataset grad17. */

proc sql; 
    create table grad17_clean as
        select
            CDS_CODE
            ,COUNTY
            ,HISPANIC
            ,AM_IND
            ,AFRICAN_AM
            ,WHITE
            ,TOTAL
        from 
            grad17
        group by 
            COUNTY
    ;

    /* It is too mundane to compare the graduation rate between all schools and
    school districts in the State of California. Rather, we combine them by
    County*/
    create table grad17_county as
        select
            COUNTY
            ,HISPANIC
            ,AM_IND
            ,AFRICAN_AM
            ,WHITE
            ,sum(TOTAL) as COUNTY_TOTAL
        from grad17_clean
        group by COUNTY
    ;
quit;

*check enr16 for bad unique id values, and use summary function to create new
columns by adding the value of the same column of multiple observation units 
which share the same unique id;

proc sql;
    /* as one specific school goes with multiple rows of data with each row 
    representing an unique combination of ethnicity and gender, we need to check
    for duplcate unique id values and combine the value of column 'GR_12' of 
    rows of data that share the same unique id value - CDS_code. After exeuting 
    this query, we see there are 1977 rows and 2 columns, and the table 
    enr16_addsup will have no duplicated unique id values. */
    create table enr16_addsup as
        select
             CDS_Code
            ,sum(GR_12) as total_number_of_GR12_Graduate
        from
            enr16
        group by
             CDS_Code
    ;
    /* remove rows with missing unique id components. After executing this
    query, the table enr16_w3clean generated still has 1977 rows, which means no
    missing value of CDS_Code here */
    create table enr16_w3clean as
        select
             CDS_Code
            ,total_number_of_GR12_Graduate
        from
            enr16_addsup
        where
             /* remove rows with missing unique id value components */
            not(missing(CDS_Code))
    ;
quit;

* check StaffAssign16 for bad unique id values, and use summary function to 
create new columns by getting the average value of the same column of multiple 
observation units which share the same unique id;

proc sql;
    /* As one row in staffassign16 represents one staff, the first thing we need
    to do is to get the average value of Column EstimatedFTE of rows sharing the
    same composite keys formed by column DistrictCode and SchoolCode. After 
    executing this query, there are 7680 rows and 3 columns in the newly-
    generated table staffassign16_average*/
    create table staffassign16_average as
        select
             DistrictCode
            ,Schoolcode
            ,avg(EstimatedFTE) as AvgEstimatedFTE
        from
            StaffAssign16
        group by
            DistrictCode
            ,Schoolcode            
    ;
    /* remove rows with missing unique id components. After executing this 
    query, the table staffassign16_w3clean generated still has 7680 rows, which
    means no missing value of DistrictCode or Schoolcode here */
    create table staffassign16_w3clean as
        select
             cats(DistrictCode, Schoolcode) as CDS_Code
            ,DistrictCode
            ,Schoolcode
            ,AvgEstimatedFTE
        from
            staffassign16_average
        where
             /* remove rows with missing unique id value components */
            not(missing(DistrictCode))
            and
            not(missing(Schoolcode))
    ;
quit;


* inspect columns of interest in cleaned versions of datasets;

title "Inspect Percent_Graduation_by_Race in grad1617";
proc sql;
    select
        min(Percent_Graduation_by_Race) as min
        ,max(Percent_Graduation_by_Race) as max
        ,mean(Percent_Graduation_by_Race) as max
        ,median(Percent_Graduation_by_Race) as max
        ,nmiss(Percent_Graduation_by_Race) as missing
    from
        grad1617
    ;
quit;
title;

title "Inspect Percent_Graduation_by_Race in grad1516";
proc sql;
    select
         min(Percent_Graduation_by_Race) as min
        ,max(Percent_Graduation_by_Race) as max
        ,mean(Percent_Graduation_by_Race) as max
        ,median(Percent_Graduation_by_Race) as max
        ,nmiss(Percent_Graduation_by_Race) as missing
    from
        grad1516
    ;
quit;
title;

title "Inspect total_number_of_GR12_Graduate in enr16_w3clean";
proc sql;
    select
         min(total_number_of_GR12_Graduate) as min
        ,max(total_number_of_GR12_Graduate) as max
        ,mean(total_number_of_GR12_Graduate) as max
        ,median(total_number_of_GR12_Graduate) as max
        ,nmiss(total_number_of_GR12_Graduate) as missing
    from
        enr16_w3clean
    ;
quit;
title;

title "Inspect AvgEstimatedFTE in staffassign16_w3clean";
proc sql;
    select
         min(AvgEstimatedFTE) as min
        ,max(AvgEstimatedFTE) as max
        ,mean(AvgEstimatedFTE) as max
        ,median(AvgEstimatedFTE) as max
        ,nmiss(AvgEstimatedFTE) as missing
    from
        staffassign16_w3clean
    ;
quit;
title;


/* using the TABLES dictionary table view to get detailed list of files we've
generated above*/
proc sql;
    select *
    from dictionary.tables
     /* As TABLES dictionary table produces a large amount of information, here
    we need to specify in the where clause*/
    where libname = 'WORK'
    order by memname;
quit;
