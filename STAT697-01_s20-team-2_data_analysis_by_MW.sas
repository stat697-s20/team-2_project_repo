*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include './STAT697-01_s20-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: Which county has the largest proportion of EstimatedFTE in 
AY2016-17?

Rationale: We are interested to know if the county with the largest number of 
UC/CSU eligible high school graduates in gradaf17 is the same as the county 
with the largest EstimatedFTE in K-12 schools during AY2016-17.

Note: This vertical sums StaffAssign16_EstFTE from estimatedFTE by 
CountyName, and then compute the max value in StaffAssign16.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Which county has the largest number of UC/CSU eligible 
high school graduates in AY2016-17?

Rationale: Provided that the county with the largest EstimatedFTE value would 
have a greater funding source, and thus we expect the county would have the 
highest UC/CSU eligible high school graduates for the same school year.

Note: This vertical sums gradaf17_total from Total by CountyName, and compute 
the max value in gradaf17.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Which county has the largest proportion difference in UC/CSU 
eligibility rate between races during AY2015-16 and AY2016-17?

Rationale: We are interested to know if certain county had significant 
difference in UC/CSU eligibility rate. Provided additional data in from other 
school years, we can observe the trends longitudinally. 

Note: This left-join the total from the gradaf16 and gradaf17 by CountyName.
*/