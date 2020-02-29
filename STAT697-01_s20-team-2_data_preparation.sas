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

[Experimental Unit Description] K-12 California public education certified 
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
in dataset gradaf16 and gradaf17. However, in our research the column 
'CountyName' would be used to combine this table with other tables.
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

[Number of Features] 23

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=Enrollment&cPage=filesenr.asp 
was downloaded, imported into R for further editting followed by being exported 
as enr16.xlsx. The column CDS_CODE was set to 'TEXT' format. As not all the 
schools have a considerably large number of Grade 12 students, rows with the 
value of column 'GR_12' less than 10 were removed.

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsenr.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset enr16 is the primary 
key column.
*/
%let inputDataset4DSN = enr16;
%let inputDataset4URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/enr16.xlsx?raw=true
;
%let inputDataset4Type = XLSX;


/* Load raw datasets over the wire, if they doesn't already exist. Input the 
macro variables of the dsn, url and dataset file type.  */
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
        %loadDataIfNotAlreadyAvailable
        (
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets


/* Check gradaf17 for bad unique id values, where the columns County, 
District, and School are intended to form a composite key. 

Check for duplicate unique id values; after executing this query, we 
see that the unique id components in gradaf17_raw_dups has no missing 
values. */
proc sql;
create table gradaf17_raw_dups as
        select
             county
            ,district
            ,school
            ,count(*) 
            as row_count_for_unique_id_value
        from gradaf17
        group by
             County
            ,District
            ,School
        having
            row_count_for_unique_id_value > 1
    ;
    /* Remove rows with missing unique id components. This query ensures that 
    the new dataset from gradaf17_nomissing will have no duplicate/repeated 
    unique ids, and all unique id components correspond with experimental units 
    of interest, which is County. */
    create table gradaf17_nomissing as
        select *
        from gradaf17
        where
            not(missing(County))
            and
            not(missing(District))
            and
            not(missing(School))
            and
            not(missing(CDS_Code))
    ;
quit;


/* Check gradaf16 for bad unique id values, where the columns County, District, 
and School form a composite key. Check for duplicate unique id values. This 
query creates a new table gradaf16_dups and shows that gradaf16 contains no 
duplicates. */
proc sql;
    create table gradaf16_dups as
        select
             County
            ,count(*) 
            as row_count_for_unique_id_value
        from gradaf16
        group by County
        having
            row_count_for_unique_id_value > 1
    ;
    /* Remove rows with missing unique id components; after executing this 
    query, a new table gradaf16_nomissing is created after removing 
    duplicate/repeated unique id values. The columns County, District, and
    School in gradaf1516 form a composite key, and all unique ids that
    correspond to our experimental units of interest, which are the counties. */
    create table gradaf16_nomissing as
        select *
        from gradaf16
        where
            not(missing(County))
            and
            not(missing(District))
            and
            not(missing(School))
            and
            not(missing(CDS_Code))
    ;
quit;


/* Join gradaf16 and gradaf17 where County is the primary key. Check for 
unique id values that are repeated or missing; after executing this query, we 
see that gradaf17_raw_bad_unique_ids shows 0 values that need to be removed. 

The query below allows us to build a fit-for-purpose mitigation step with no 
guessing or unnecessary effort */
proc sql;
    create table gradaf17_raw_bad_unique_ids as
        select gradaf17.*
        from gradaf17 as A
            left join
            (
                select
                     CDS_Code
                    ,count(*) as row_count_for_unique_id_value
                from gradaf17
                group by County
            ) 
            as B
            on A.CDS_Code=B.CDS_Code
        having
            row_count_for_unique_id_value > 1
            or
            missing(CDS_Code)
    ;
    /* after executing this query, the new dataset gradaf1617 will have no 
    duplicate/repeated unique id values, and all unique id values will 
    correspond to our experimental units of interest, California counties; this
    means the column County in gradaf1617 is guaranteed to form a primary key */
    create table gradaf1617 as
        select *
        from gradaf16 as A
            left join
            (
            select
                 County
                ,count(*) as row_count_for_unique_id_value
            from gradaf17
            group by County
            )
            as B
            on A.County=B.County
        having
            row_count_for_unique_id_value > 1
    ;
    /* We want to identify duplicates in the unique primary key CDS_Code in 
    dataset gradaf17 */
    create table gradaf17_clean as
        select
             CDS_Code
            ,County
            ,Hispanic
            ,Am_Ind
            ,African_Am
            ,White
            ,Total
        from gradaf17_nomissing
    ;
    /* It is too tedious to compare the graduation rate between all schools and
    school districts in California. Instead, we combine them by the county. */
    create table gradaf17_county as
        select
             County
            ,Hispanic
            ,Am_Ind
            ,African_Am
            ,White
            ,sum(Total) 
            as County_Total
        from gradaf17_clean
        group by County
    ;
quit;


/* Check enr16 for bad unique id values, and use summary function to create new
columns by adding the value of the same column of multiple observation units 
which share the same unique id. As one specific school goes with multiple rows 
of data with each row representing an unique combination of ethnicity, we need 
to check for duplcate unique id values and combine the value of column 'GR_12' 
of rows of data that share the same unique id value - CDS_code. After exeuting 
this query, we see there are 1977 rows and 2 columns, and the table 
enr16_addsup will have no duplicated unique id values. */
proc sql;
    create table enr16_addsup as
        select
             CDS_Code
            ,County
            ,sum(GR_12) 
            as total_num_of_Graduate
        from enr16
        group by CDS_Code
    ;
    /* remove rows with missing unique id components. After executing this
    query, the table enr16_w3clean generated still has 1977 rows, which means no
    missing value of CDS_Code here */
    create table enr16_w3clean as
        select
             CDS_Code
            ,County
            ,total_num_of_Graduate
        from enr16_addsup
        where not(missing(CDS_Code))
    ;
quit;


/* check StaffAssign16 for bad unique id values, and use summary function to 
create new columns by getting the average value of the same column of multiple 
observation units which share the same unique id. As one row in staffassign16 
represents one staff, the first thing we need to do is to get the average value 
of Column EstimatedFTE of rows sharing the same composite keys formed by column 
DistrictCode and SchoolCode. After executing this query, there are 7680 rows and 
3 columns in the newly-generated table staffassign16_average. */
proc sql;
    create table staffassign16_average as
        select
             CountyName
            ,round(avg(EstimatedFTE),0.01) as AvgEstimatedFTE
        from
            StaffAssign16
        group by
            CountyName            
    ;
    /* remove rows with missing unique id components. After executing this 
    query, the table staffassign16_w3clean generated still has 7680 rows, which
    means no missing value of DistrictCode or Schoolcode here */
    create table staffassign16_w3clean as
        select *
        from staffassign16_average
        where 
            not(missing(CountyName))
    ;
quit;


/* The analytic dataset is built here.
Three datasets are needed for YX's data analysis, they are gradaf17, enr16 and 
StaffAssign16. MW's data analysis needs to combine gradaf16 and gradaf17, and 
apply the summary function to the column values after the datasets are being 
grouped-by the column county. The codes below use three layers of subquery to 
combine these four datasets into one table.*/
proc sql;
    create table analytic_file_raw as
        select 
            gradaf1617.county
            ,gradaf1617.county_am_ind
            ,gradaf1617.county_african_am
            ,gradaf1617.county_white
            ,gradaf1617.county_total
            ,univ_ratio_staff.AvgEstimatedFTE
            ,univ_ratio_staff.Avg_Rate_of_Univ
        from
            /* Below we combine the dataset univ_ratio_by_county with dataset 
            staffassign16_w3clean, and name it as univ_ratio_staff*/
            (select 
                Univ_Ratio_by_County.COUNTY
                ,Univ_Ratio_by_County.Avg_Rate_of_Univ
                ,StaffAssign.AvgEstimatedFTE
            from   
                /*Below we create the temporary dataset univ_ratio_by_county. 
                When the CDS_CODE column and COUNTY column from table gradaf17 
                and enr16 were both matching, I understood that they are talking 
                about the same school, and used the number of Grade 12 
                enrollment from enr16 as the denominator and the number of 
                students meeting CSU/UC University requirements as the numerator 
                to calculate a ratio. Then I grouped the join table by county 
                and calcuated the average ratio of each county group. */
                (select
                    upcase(enr.COUNTY) as COUNTY
                    /* use the number of students meeting university 
                    requirements from table gradaf17 as the numerator, the 
                    number of students totally enrolled on that year from table 
                    enr16 as the denonminator, to calculate the ratio. As 
                    students enrolled in AY2016 and graduated in AY2017, here I 
                    chose to use enr16 rather than enr17. */
                    ,round(avg(gradaf17.TOTAL/enr.total_num_of_Graduate),0.01) 
                    as Avg_Rate_of_Univ
                from
                    enr16_w3clean as enr
                    , gradaf17_clean as gradaf17
                where
                    /* Both the county name and the cds_code need to match */
                    enr.COUNTY = gradaf17.COUNTY
                    and enr.CDS_CODE = gradaf17.CDS_CODE
                group by
                    enr.COUNTY) as Univ_Ratio_by_County
                ,staffassign16_w3clean as StaffAssign
            /*Below by using the WHERE clause, we combine the dataset 
            Univ_Ratio_by_County and staffassign16_w3clean.*/
                where StaffAssign.CountyName = Univ_Ratio_by_County.COUNTY) as 
            univ_ratio_staff
            /*Below we created gradaf1617 datasets by left join gradaf17 with 
            gradaf16 on the condition that the variable COUNTY are the same. 
            Then we group the jointed table by variable COUNTY, use summary 
            function to get the sum of number of various ethnic groups for each 
            of the counties. Later this combined dataset gradaf1617 would be 
            combined with the combination of Univ_Ratio_by_County and
            staffassign16_w3clean on the condition of the same value of 
            COUNTY.*/
            ,(select
                upcase(A.COUNTY) as county
                ,sum(A.HISPANIC) as county_hispanic
                ,sum(A.AM_IND) as county_am_ind
                ,sum(A.AFRICAN_AM) as county_african_am
                ,sum(A.WHITE) as county_white
                ,sum(A.TOTAL) as county_total
            from
                gradaf17_clean as A
            left join
                (
                select
                     COUNTY
                    ,count(*) as row_count_for_unique_id_value
                from gradaf16
                group by COUNTY
                having row_count_for_unique_id_value > 1
                )
                as B
            on A.COUNTY=B.COUNTY
            group by
                A.COUNTY
            having county_total > 0
                ) as gradaf1617               
        where
            univ_ratio_staff.COUNTY = gradaf1617.county
    ;
quit;

        
/* check analytic_file_raw for rows whose unique id values are repeated or 
missing, where the column County is intended to be a primary key; after 
executing this data step, we see that there is no missing or repeated value, the 
new table generated has the same number of observations units as the original 
table. */
proc sql;
    create table analytic_file_raw_checked as
        select distinct County
            ,AvgEstimatedFTE
            ,Avg_Rate_of_Univ
        from analytic_file_raw
        where not(missing(County))
    ;
quit;