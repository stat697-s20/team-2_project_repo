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
Question 1 of 3: Is there a difference in proportion of those meeting UC/CSU 
requirements among California high school graduates in AY2015-16 and AY2016-17? 

Rationale: This can help identify the difference in the average rate of meeting 
UC/CSU requirements between AY2015-16 and AY2016-17.

Note: The total of from schools in the same county are combined to make 
Total16, Total17, and Total1617 for AY2015-16, AY2016-17, and the 
combined total from each county in both academic years, respectively. From the 
Exploratory Data Analysis (EPA), the primary key CDS_Codee between AY2015-16 and 
AY2016-17 differ. We assigned County as experimental unit for comparison since 
they are identical in the datasets.

Limitations: We must assume no significant changes in the district boundaries 
between AY2015-16 and AY2016-17 that could significantly affect the student body 
demographic. Missing and incomplete data, by default, are ignored.
*/
proc summary data=gradaf16;
    by County Year;
    var Total;
    output out=want (drop=_:) sum=Total16;
run;

proc summary data=gradaf17;
    var Total;
    by County Year;
    output out=want sum=Total17;
run;

/* Row sums by County and joined Year is set as the proportion denominator. */
proc summary data=gradaf1617;
    var Total;
    by County;
    output out=want (drop=_:) sum=Total1617;
run;
quit;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Is there a difference in the proportion of those meeting UC/CSU
requirements between counties among Californian high school graduates in 
AY2015-16 and/or AY2016-17?  

Rationale: A change in proportion of those meeting UC/CSU requirements between 
counties can tell us about the contemporary demographic conditions.

Note: Future direction can be used as a comparison for the proportion of 
counties that may require more resource allocation.

Limitations: Unique counties in gradaf16 are fewer than in gradaf17. A 
closer look at the difference in observation length is an indicator for possible
error source. Further investigation needed.
*/
proc freq data=gradaf17_COUNTY;
    by County;
    var 
         Hispanic 
        ,Am_Ind
        ,African_Am
        ,White
        ,Total
    ;
proc print;
quit;



*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a difference in the proportion of those meeting UC/CSU
requirements rate between race/ethnicity among Californian high school graduates
in AY2015-16 and/or AY2016-17? 

Rationale: Comparing the graduation rate between ethnic groups can help us 
evaluate the how they perform compare to the population average. Based on this 
dataset, it is possible to evaluate this research question using this data.

Note: Variation in graduation rates difference among race groups may tell us 
about the demographic shift, on average. In future directions, it might be 
interesting to investigate the among the ethnic groups between the counties. 

Limitations: Students of mixed race is not accounted for. Missing data are 
omitted. From the Exploratory Data Analysis, it may be possible to analyze the
graduation rate among different Race since the columns in gradaf16 and 
gradaf17 gave us the relevant category race {Hispanic, Am_Ind, Asian, 
Pac_Isld, Filipino, African_Am, White, Two_More_Races, Not_Reported}. However, 
we recommend ommiting Asian, Pac_Isld, Filipino, Two_More_Races, and 
Not_Reported since they are too vague. */

proc means data=gradaf1617;
run;

proc means data=gradaf17_COUNTY;
run;