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
will be able to join `gradaf16` and `gradaf17` and compare the average graduation 
rate. From the Exploratory Data Analysis (EPA), the primary key CDS_CODE between 
2015-2016 and 2016-2017 are different. Rather than using the SCHOOL as 
experimental unit, it may be more consistent to assign DISTRICT or COUNTY as 
experimental unit for comparison.

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
to know about the nonrespondents. Based on the Exploratory Data Analysis, the
gender of students was not provided in this subset of data. We may need to check
back to the database to find and select the dataset with pertaining information
about gender. The gradaf16 and gradaf17 datasets we gathered are insufficient to 
answer this research question.
*/


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a difference in the graduation rate between 
race/ethnicity among high school students in California in 2016 and/or 2017? 

Rationale: Comparing the graduation rate between ethnic groups can help us 
evaluate the how they perform compare to the population average. Based on this 
dataset, it is possible to evaluate this research question using this data.

Note: Variation in graduation rates difference among race groups may tell us 
about the demographic shift, on average. In future directions, it might be 
interesting to investigate the among the ethnic groups between the counties. 

Limitations: Students of mixed race is not accounted for. Missing data are 
omitted. From the Exploratory Data Analysis, it may be possible to analyze the
graduation rate among different Race since the columns in gradaf16 and gradaf17 gave
us the relevant category Race {HISPANIC, AM_IND, ASIAN, PAC_ISLD, FILIPINO,
AFRICAN_AM, WHITE, TWO_MORE_RACES, NOT_REPORTED}. However, we recommend ommiting 
the ASIAN, PAC_ISLD, FILIPINO, TWO_MORE_RACES, and NOT_REPORTED since they are 
too vague. 
*/