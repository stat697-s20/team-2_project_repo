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


/* Check gradaf17 for duplicate unique id values, where the columns County, 
District, and School are intended to form a composite key; after executing this 
query, we see that the unique id components in gradaf17_raw_dups has no 
duplicate ids values. */
proc sql;
create table gradaf17_raw_dups as
        select
             County
            ,District
            ,School
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
    /* Remove rows with missing unique id components. This and the above query 
    ensures that the new dataset from gradaf17_nomissing will have no
    duplicate/repeated unique ids, and all unique id components correspond with 
    experimental units of interest, which is County. */
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
    /*By selecting the columns of interest from the table created right above, 
    we have the table gradaf17_clean ready for the next step - multiple datasets 
    combination*/
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
quit;


/* Check gradaf16 for duplicate unique id values, where the columns County, 
District, and School are intended to form a composite key; after executing this 
query, we see that the unique id components in gradaf16_raw_dups has no 
duplicate ids values. */
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
    /* Remove rows with missing unique id components. This and the above query 
    ensures that the new dataset from gradaf16_nomissing will have no 
    duplicate/repeated unique ids, and all unique id components correspond with 
    experimental units of interest, which is County. */
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


/* For dataset enr16, use summary function to create new columns by adding the 
value of the same columns of multiple observation units which share the same 
unique id. As one specific school goes with multiple rows of data with each row 
representing an unique combination of ethnicity, we need to check for duplicate 
unique id values and combine the value of column 'GR_12' for observation units 
that share the same unique id value - CDS_Code. After exeuting this query, we 
see there are 8239 rows and 3 columns, and the table enr16_addsup will have no 
duplicated unique id values. In the where clause, the condition is the column 
County should be not missing as later County would be the primary key of the 
w6ps combined table*/
proc sql;
    create table enr16_addsup as
        select
             CDS_Code
            ,County
            ,sum(GR_12) 
            as Total_Num_of_Graduate
        from enr16
        where
            not(missing(County))
        group by CDS_Code
    ;
    /* remove rows with missing unique id components. After executing this
    query, the table enr16_w3clean generated still has 8239 rows, which means no
    missing value of CDS_Code here */
    create table enr16_clean as
        select
             CDS_Code
            ,County
            ,Total_Num_of_Graduate
        from enr16_addsup
        where not(missing(CDS_Code))
    ;   
quit;


/* For StaffAssign16, use summary function to 
create new columns by getting the average value of the same column for multiple 
observation units which share the same primary id - here we have CountyName as 
the primary id. After executing this query, there are 58 rows and 2 columns in 
the newly-generated table staffassign16_average. */
proc sql;
    create table staffassign16_average as
        select
             CountyName
            ,round(avg(EstimatedFTE),0.01) as Avg_Estimated_FTE
        from
            StaffAssign16
        group by
            CountyName            
    ;
    /* remove rows with missing unique id components. After executing this 
    query, the table staffassign16_w3clean generated still has 58 rows, which
    means no missing value of DistrictCode or Schoolcode here */
    create table staffassign16_clean as
        select *
        from staffassign16_average
        where 
            not(missing(CountyName))
    ;
quit;


/* The analytic dataset is built here by combining four datasets.
Three datasets are needed for YX's data analysis, they are gradaf17, enr16 and 
StaffAssign16. MW's data analysis needs to combine gradaf16 and gradaf17, and 
apply the summary function to the column values after the datasets are being 
grouped-by the column county. The codes below use three layers of subqueries to 
combine these four datasets into one table.*/
proc sql;
    create table analytic_file_raw as
        select 
             gradaf1617.County
            ,gradaf1617.County_Am_Ind
            ,gradaf1617.County_African_Am
            ,gradaf1617.County_White
            ,gradaf1617.County_Total
            ,univ_ratio_staff.Avg_Estimated_FTE
            ,univ_ratio_staff.Avg_Rate_of_Univ
        from
            /* Below we combine the dataset univ_ratio_by_county with dataset 
            staffassign16_clean, and name the new dataset as univ_ratio_staff */
            (select 
                 univ_ratio_by_county.County
                ,univ_ratio_by_county.Avg_Rate_of_Univ
                ,StaffAssign.Avg_Estimated_FTE
            from   
                /*Below we create the temporary dataset univ_ratio_by_county. 
                When the CDS_Code column and County column from dateset gradaf17 
                and enr16 were both matching, I understood that they are talking 
                about the same school, and used the number of Grade 12 
                enrollment from enr16 as the denominator and the number of 
                students meeting CSU/UC entrance requirements as the numerator 
                to calculate a ratio. Then I grouped this join table by county 
                and calculated the average ratio of each county group. */
                (select
                    upcase(enr.County) as County
                    /* use the number of students meeting UC/CSU entrance 
                    requirements from dataset gradaf17 as the numerator, the 
                    number of students totally enrolled on that year from 
                    dataset enr16 as the denonminator, to calculate the ratio. 
                    As students enrolled in AY2016 and graduated in AY2017, here 
                    I chose to use enr16 rather than enr17. */
                    ,round(avg(gradaf17.Total/enr.Total_Num_of_Graduate),0.01) 
                    as Avg_Rate_of_Univ
                from
                     enr16_clean as enr
                    ,gradaf17_clean as gradaf17
                where
                    /* Both the county name and the cds_code need to match */
                    enr.County = gradaf17.County
                    and enr.CDS_Code = gradaf17.CDS_Code
                group by
                    enr.County) as univ_ratio_by_county
                ,staffassign16_clean as staffassign
            /*Below by using the WHERE clause, we combine the dataset 
            univ_ratio_by_county and staffassign16_clean.*/
                where staffassign.CountyName = univ_ratio_by_county.County) as 
                univ_ratio_staff
            /*Below we created gradaf1617 datasets by left join gradaf17 with 
            gradaf16 on the condition that the variable County are the same. 
            Then we group the jointed table by variable County, use summary 
            function to get the sum of number of various ethnic groups for each 
            of the counties. Later this combined dataset gradaf1617 would be 
            combined with the combination of univ_ratio_by_county and
            staffassign16_clean on the condition of the same value of 
            column County.*/
            ,(select
                 upcase(A.County) as County
                ,sum(A.Hispanic) as County_Hispanic
                ,sum(A.Am_Ind) as County_Am_Ind
                ,sum(A.African_Am) as County_African_Am
                ,sum(A.White) as County_White
                ,sum(A.Total) as County_Total
            from
                gradaf17_clean as A
            left join
                (
                select
                     County
                    ,count(*) as Row_Count_for_Unique_Id_Value
                from gradaf16
                group by County
                having Row_Count_for_Unique_Id_Value > 1
                )
                as B
            on A.County=B.County
            group by
                A.County
            having County_Total > 0
                ) as gradaf1617               
        where
            univ_ratio_staff.County = gradaf1617.County
    ;
quit;

        
/* check analytic_file_raw for rows whose unique id values are repeated or 
missing, where the column County is intended to be a primary key; after 
executing this data step, we see that there is no missing or repeated value, the 
new table generated has the same number of observations units, which is 49, as 
the original table. */
proc sql;
    create table analytic_file_raw_checked as
        select distinct 
             County
            ,County_Am_Ind
            ,County_African_Am
            ,County_White
            ,County_Total
            ,Avg_Estimated_FTE
            ,Avg_Rate_of_Univ
        from analytic_file_raw
        where not(missing(County))
    ;
quit;
