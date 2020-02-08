*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include '/folders/myfolders/team-2_project_repo/STAT697-01_s20-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: What are the top thirty school districts that have the highest 
average Estimated FTE? 
Rationale: This would help identify school districts with high level of average 
Estimated FTE.
Note: This needs to get the average of the column 'Estimated FTE' for all the 
observation units with the same input on the column 'DistrictCode' from 
StaffAssign16.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: What are the top thirty school districts that have the highest 
percentage of graduates meeting UC/CSU entrance requirement out of all the 
students enrolled into Grade twelve? 
Rationale: This would help identify school districts with high percentage of 
students meeting UC/CSU requirements.
Note: This needs to find out observation units with column 'GR_12' not equal to 
zero in the dataset enr16, and divide their number of Grade twelve enrollments 
by the value of column 'Total' of the observation units with the same SchoolCode 
in the dataset grad17, then get the average of these results from observation 
units with the same district code.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Are there any overalp between the results of the above two 
questions? 
Rationale: This would help inform whether the level of average Estimated FTE is 
associated with the percentage of students meeting university requirements.
Note: This needs to compare the result of the above two questions.
*/