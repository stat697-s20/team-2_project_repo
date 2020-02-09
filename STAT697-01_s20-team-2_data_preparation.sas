*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/*
[Dataset 1 Name] grad17

[Dataset Description] Graduates meeting University of California (UC)/California State University (CSU) entrance requirements by racial/ethnic group and school, AY2016-17

[Experimental Unit Description] California public K-12 schools in AY2016-17

[Number of Observations] 2,535

[Number of Features] 15

[Data Source] The file http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=GradEth&cPage=filesgrad.asp was downloaded and edited to produce file grad17.xls by importing into Excel. And the column CDS_CODE was set to 'TEXT' format.

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgrad09.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset grad17 is the 
primary key column.
*/
%let inputDataset1DSN = grad17;
%let inputDataset1URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/grad17.xlsx?raw=true
;
%let inputDataset1Type = XLSX;


/*
[Dataset 2 Name] grad16

[Dataset Description] SGraduates meeting University of California (UC)/
California State University (CSU) entrance requirements by racial/ethnic group 
and school, AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 2,521

[Number of Features] 15

[Data Source] The file http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2015-16&cCat=GradEth&cPage=filesgrad.asp was downloaded and edited to produce file grad16.xls by importing into Excel. And the column CDS_CODE was set to 'TEXT' format. 

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgrad09.asp

[Unique ID Schema] The unique id column CDS_CODE in dataset grad16 is the 
primary key column.
*/
%let inputDataset2DSN = grad16;
%let inputDataset2URL =
https://github.com/yxie18-stat697/team-2_project_repo/blob/master/data/grad16.xlsx?raw=true
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
composite key, which together are equivalent to the unique id column CDS_CODE in 
dataset grad16 and grad17.
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

[Data Source] The file http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2016-17&cCat=Enrollment&cPage=filesenr.asp
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
    select *
    from dictionary.tables
    where libname = 'WORK'
    order by memname;
quit;
