*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include './STAT697-01_s20-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: Is there a difference in the graduation rate between 2016 and 
2017 among high school students in California? 

Rationale: This can help identify the difference in the average graduation rate 
between the school years.

Note: The rows are organized by the school district and county names, and we 
will be able to join `grad16` and `grad17` and compare the average graduation 
rate.

Limitations: We must assume no significant changes in the district boundaries 
between the 2016 and 2017 that could significantly affect the student body 
demographic. Missing and incomplete data are omitted.

*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Is there a difference in the graduation rate between the 
genders among high school students in California in 2016 or 2017? 

Rationale: A change in graduation rates between the genders can tell us about 
the current demographic conditions.

Note: Future direction can be used as a comparison for the graduation rate among 
nonbinary gender students.

Limitations: Nonresponse in the gender column is omitted. Not enough information 
to know about the nonrespondents.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a difference in the graduation rate between 
race/ethnicity among high school students in California in 2016 and/or 2017? 

Rationale: Comparing the graduation rate between ethnic groups can help us 
evaluate the how they perform compare to the population average.

Note: Variation in graduation rates difference among race groups may tell us 
about the demographic shift, on average. In future directions, it might be 
interesting to investigate the among the ethnic groups between the counties. 

Limitations: Students of mixed race is not accounted for. Missing data are 
omitted.
*/