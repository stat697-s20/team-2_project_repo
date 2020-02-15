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
was downloaded and edited to produce file gradaf17.xlsx by importing into Excel. 
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
was downloaded and edited to produce file gradaf16.xlsx by importing into Excel. 
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

[Number of Observations] 100,000

[Number of Features] 2

[Data Source] The file
http://www3.cde.ca.gov/download/dq/StaffAssign16.zip
was downloaded, imported into R for further editting followed by being exported 
as StaffAssign16.xlsx. To make the file less than 5MB, 100000 rows were picked 
out of all the observation units randomly , and all the columns except
'CountyName' and 'EstimatedFTE' were removed. The R dateframe produced was then 
imported into Excel to produce file StaffAssign16.xlsx 

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The columns "District Code" and "School Code" form a 
composite key, which together are equivalent to the unique id column CDS_CODE 
in dataset gradaf16 and gradaf17. However, in our research the column 'CountyName' would be used to combine this table with other tables.
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

[Number of Features] 3

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=Enrollment&cPage=filesenr.asp
was downloaded, imported into R for further editting followed by being exported 
as enr16.xlsx. As not all the schools have a considerably large number of Grade 
12 students, rows with the value of column 'GR_12' less than 10 were removed. 
All the columns except 'CDS_CODE', 'COUNTY' and 'GR_12' were removed.

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


/* check gradaf17 for bad unique id values, where the columns COUNTY, DISTRICT, 
and SCHOOL form a composite key*/
proc sql;
    /* check gradaf17 for duplicate unique id values; after executing this 
    query, we see that gradaf17_raw_dups has no missing unique id component */
    create table gradaf17_raw_dups as
        select
            COUNTY
            ,DISTRICT
            ,SCHOOL
            ,count(*) as row_count_for_unique_id_value
        from
            gradaf17
        group by
            COUNTY
            ,DISTRICT
            ,SCHOOL
        having
            row_count_for_unique_id_value > 1
    ;
    /* remove rows with missing unique id components, or with unique ids that do 
    not correspond to schools; after executing this query, the new dataset from
    gradaf1617 will have no duplicate/repeated unique id values, and all unique
    id values will correspond to our experimental units of interest, which are
    California Public K-12 schools; this means the columns COUNTY, DISTRICT, and
    SCHOOL in gradaf1617 are guaranteed to form a composite key */
    create table gradaf17_nomissing as
        select
            *
        from
            gradaf17
        where
            /* remove rows with missing unique id value components */
            not(missing(COUNTY))
            and
            not(missing(DISTRICT))
            and
            not(missing(SCHOOL))
            and
            not(missing(CDS_CODE))
    ;
quit;


/* check gradaf16 for bad unique id values, where the columns COUNTY, DISTRICT, 
and SCHOOL form a composite key*/
proc sql;
    /* check for duplicate unique id values; after executing this query, we see
    that gradaf16 contains no rows, so no mitigation is needed to ensure
    uniqueness */
    create table gradaf16_dups as
        select
            COUNTY
            ,DISTRICT
            ,SCHOOL
            ,count(*) as row_count_for_unique_id_value
        from
            gradaf16
        group by
            COUNTY
            ,DISTRICT
            ,SCHOOL
        having
            row_count_for_unique_id_value > 1
    ;
    /* remove rows with missing unique id components, or iwht unique ids that do
    not correspond to schools; after executing this query, the new dataset 
    gradaf1516 will have no duplicate/repeated unique id values, and all unique 
    id values will correspond to our experimental units of interest, which are 
    California Public K-12 schools; this means the columns COUNTY, DISTRICT, and
    SCHOOL in gradaf1516 are guaranteed to form a composite key */
    create table gradaf16_nomissing as
        select
            *
        from
            gradaf16
        where
            /* remove rows with missing unique id value components */
            not(missing(COUNTY))
            and
            not(missing(DISTRICT))
            and
            not(missing(SCHOOL))
            and
            not(missing(CDS_CODE))
    ;
quit;

/*check gradaf17 for bad unique id values, where the column CDS_CODE is intended 
to be a primary key*/
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
    non-schools; after executing this query, we see that 
    gradaf17_raw_bad_unique_ids only has no-school values of CDS_CODE that need
    to be removed. The query below allows us to build a fit-for-purpose 
    mitigation step with no guessing or unnecessary effort */
    create table gradaf17_raw_bad_unique_ids as
        select
            A.*
        from
            gradaf17 as A
            left join
            (
                select
                    CDS_CODE
                    ,count(*) as row_count_for_unique_id_value
                from
                    gradaf17
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
    executing this query, the new dataset gradaf1617 will have no 
    duplicate/repeated unique id values, and all unique id values will 
    correspond to our experimental units of interest, which are California 
    Public K-12 schools; this means the column CDS_CODE in gradaf1617 is 
    guaranteed to form a primary key */
    create table gradaf1617 as
        select
            *
        from
            gradaf17
    ;
quit;

/* We want to identify duplicates in the unique primary key CDS_CODE in dataset
gradaf17. */
proc sql; 
    create table gradaf17_clean as
        select
            CDS_CODE
            ,COUNTY
            ,HISPANIC
            ,AM_IND
            ,AFRICAN_AM
            ,WHITE
            ,TOTAL
        from 
            gradaf17_nomissing
    ;
    /* It is too mundane to compare the graduation rate between all schools and
    school districts in the State of California. Rather, we combine them by
    County*/
    create table gradaf17_county as
        select
            COUNTY
            ,HISPANIC
            ,AM_IND
            ,AFRICAN_AM
            ,WHITE
            ,sum(TOTAL) as COUNTY_TOTAL
        from gradaf17_clean
        group by COUNTY
    ;
quit;

/*check enr16 for bad unique id values, and use summary function to create new
columns by adding the value of the same column of multiple observation units 
which share the same unique id*/
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
            ,COUNTY
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
            ,COUNTY
            ,total_number_of_GR12_Graduate
        from
            enr16_addsup
        where
             /* remove rows with missing unique id value components */
            not(missing(CDS_Code))
    ;
quit;

/* check StaffAssign16 for bad unique id values, and use summary function to 
create new columns by getting the average value of the same column of multiple 
observation units which share the same unique id*/
proc sql;
    /* As one row in staffassign16 represents one staff, the first thing we need
    to do is to get the average value of Column EstimatedFTE of rows sharing the
    same composite keys formed by column DistrictCode and SchoolCode. After 
    executing this query, there are 7680 rows and 3 columns in the newly-
    generated table staffassign16_average*/
    create table staffassign16_average as
        select
            CountyName
            ,avg(EstimatedFTE) as AvgEstimatedFTE
        from
            StaffAssign16
        group by
            CountyName            
    ;
    /* remove rows with missing unique id components. After executing this 
    query, the table staffassign16_w3clean generated still has 7680 rows, which
    means no missing value of DistrictCode or Schoolcode here */
    create table staffassign16_w3clean as
        select
             *
        from
            staffassign16_average
        where
             /* remove rows with missing countynames */
            not(missing(CountyName))
    ;
quit;


/* build analytic dataset from raw datasets imported above, including only the
columns and minimal data-cleaning/transformation needed to address each
research questions/objectives in data-analysis files */
proc sql;
    create table analytic_file_raw as
        select 
            StaffAssign.AvgEstimatedFTE
            , Univ_Ratio_by_County.COUNTY
            , Univ_Ratio_by_County.Avg_Rate_of_Univ
        from
            (select
                upcase(enr.COUNTY) as COUNTY
                /* use the number of students meeting university requirements 
                from table gradaf17 as the numerator, the number of students 
                totally enrolled on that year from table enr16 as the 
                denonminator, to calculate the ratio. As students enrolled in 
                AY 2016 and graduated in AY 2017, here I chose to use enr16 
                rather than enr17. */
                , avg(gradaf17.TOTAL/enr.total_number_of_GR12_Graduate) as 
                Avg_Rate_of_Univ
            from
                enr16_w3clean as enr
                , gradaf17_clean as gradaf17
            where
                /*Both the county name and the cds_code need to match*/
                enr.COUNTY = gradaf17.COUNTY
                and enr.CDS_CODE = gradaf17.CDS_CODE
            group by
                enr.COUNTY) as Univ_Ratio_by_County
                , staffassign16_w3clean as StaffAssign
        where
            StaffAssign.CountyName = Univ_Ratio_by_County.COUNTY
    ;
     
        

/* using the TABLES dictionary table view to get detailed list of files we've
generated above by printing the names of all tables/datasets*/
proc sql;
    select *
    from dictionary.tables
     /* As TABLES dictionary table produces a large amount of information, here
    we need to specify in the where clause*/
    where libname = 'WORK'
    order by memname;
quit;
