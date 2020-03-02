*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include './STAT697-01_s20-team-2_data_preparation.sas';


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question 1 of 3: What are the top ten counties that have the highest average Estimated FTE?'
;

title2 justify=left
'Rationale: This would help identify counties with high level of average Estimated FTE'
;

footnote1 justify=left
"The difference between the county ranking NO.1 and county ranking No.10 regarding the value of average Estimated FTE is less than 7."
;

footnote2 justify=left
"Per the assumption here, the high value of average Esimated FTE means that more teachers are working on a full-time basis."
;

/*
Note: This needs to get the average of the column 'EstimatedFTE' for all the 
observation units with the same input on the column 'CountyName' from 
StaffAssign16.

Limitations: Missing and incomplete data are omitted. And the results of 
different counties could be of little difference. 

Methodology: Use proc sql statement to retrieve from the table 
analytic_file_raw_checked the data of average value of Estimated FTE by county, 
then get the retrieved data sorted by the value, and save the output of query 
into a table. Then retrieve first 10 rows from the newly-generated table. After 
that, use proc sgplot ststement to output a boxplot to illustrate the 
distribution of the value of Estimated FTE for all the counties.

Followup Steps:More carefully and thoroughly inspections on the data could be 
done here.
*/


/*Use the proc report statement, from the data preparation file, select the 
county name and the average value of Estimated FTE of each county, sort by the 
value of Estimated FTE*/
ods exclude all;
proc report data=analytic_file_raw_checked out=q1(drop=_BREAK_);
    columns
        Avg_Estimated_FTE
        County
    ;        
    define Avg_Estimated_FTE / order descending;
run;
ods exclude none;

/*output first 10 rows of the above sorted data, addressing research question*/
proc report data=q1(obs=10);
run;

/* clear titles/footnotes*/
title;
footnote;


title1 justify=left
"Plots illustrating distribution of the value of Avg_Estimated_FTE for all the 
counties"
;

footnote1 justify=left
"In the plot above, we can see that most the counties have the value of 
Avg_Estimated_FTE between 20 and 35."
;

proc sgplot data=q1;
    hbox Avg_Estimated_FTE / category=County;
run;

/* clear titles/footnotes*/
title;
footnote;
    
    
*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question 2 of 3: What are the top ten counties that have the highest percentage of graduates meeting UC/CSU entrance requirement out of all the students enrolled into Grade twelve?'
;

title2 justify=left
'Rationale: This would help identify counties with high percentage of students meeting UC/CSU entrance requirements'
;

footnote1 justify=left
"The county Sierra here ranks No.1 with the percentage of students meeting UC/CSU entrance requirement being more than 1, which is obviously suspicious and undoubtedly required more inspection."
;

footnote2 justify=left
"The other nine counties have the rate between 0.5 and 0.6, which looks sensible and is bascialy consistent with the general public recognition of 'the good counties in California'."
;

/*
Note: This needs to find out observation units with column 'GR_12' not equal to 
zero in the dataset enr16, and divide their number of Grade twelve enrollments 
by the value of column 'Total' of the observation units with the same SchoolCode 
in the dataset gradaf17, then get the average of these results from observation 
units with the same name of county.

Limitations: Missing and incomplete data are omitted. And the 'Total' column in
the gradaf17 dataset might not be best possible denonminator of the ratio as it
does not include students with high school equivalencies. And the results from
different counties could be of little difference. 

Methodology: Use proc sql statement to retrieve from the table 
analytic_file_raw_checked the data of average rate of students meeting UC/CSU 
entrance requirement by county, then get the retrieved data sorted by the value, 
and save the output of query into a table. Then retrieve the first 10 rows of 
data from the newly-generated table. After that, use proc sgplot statement to 
output a boxplot to illustrate the distribution of the value of Avg_Rate_of_Univ 
for all the counties.

Followup Steps: More carefully and thoroughly inspections on the data could be 
done here. Sierra county ranks NO.1 here with a rate of more than 1, it's 
obviously suspicious.
*/


/*From the table analytic_file_raw_checked from the data preparation file, 
select the county name and the average rate of students meeting UC/CSU 
university requirement for each county, and sort by the value of 
Avg_Rate_of_Univ*/
proc sql;
    create table q2 as
        select
            Avg_Rate_of_Univ
            ,County
        from
            analytic_file_raw_checked
        order by 
            Avg_Rate_of_Univ desc
        ;
quit;

/*output first 10 rows of the above sorted data, addressing research question*/
proc sql outobs=10;
    select 
        *
    from
        q2
    ;
quit;

/* clear titles/footnotes*/
title;
footnote;


title1 justify=left
'Plots illustrating distribution of the value of Avg_Rate_of_Univ for all the counties'
;

footnote1 justify=left
"In the plot above, apart from the Sierra county, which is a suspicious outlier, most of the counties have the value of Avg_Rate_of_Univ between 0.2 and 0.6."
;

proc sgplot data=q2;
    hbox Avg_Rate_of_Univ / category=County;
run;

/* clear titles/footnotes*/
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Research Question 3 of 3: Is there any relationship between the two variables  respectively explored by the above two questions?'
;

title2 justify=left
'Rationale: This would help inform for counties in California whether the level of average Estimated FTE is associated with the percentage of students meeting UC/CSU entrance requirements.'
;

/*
Note: This needs to obtain the correlation of the two variables explored above.

Limitations: The comparison between the rankings produced by the previous two
questions could be preliminary. And the pbserved association between these two 
variables could be caused by other confounding factors.

Methodology: Use proc corr statement to perform a correlation analysis,and then 
use procsgplot statement to output a scatterplot, illustrating the correlation 
presented.

Followup Steps: A more formal inferential technique such as linear/logistic
regression might be needed here.
*/


title3 justify=left
'Correlation analysis between Avg_Estimated_FTE and Avg_Rate_of_Univ'
;

footnote1 justify=left
"Assuming the two variables Avg_Estimated_FTE and Avg_Rate_of_Univ are normally distributed, the correlation analysis shouws that there is a slightly positive correlation between the average value of estimated FTE for each county and the average rate of students meeting UC/CSU entrance requirements for each county."
;

footnote1 justify=left
"The value of Spearman correlation coefficient obtained here is slightly higher than the value of pearson correlation coefficient, although their calculation methods are quite similar."
;

proc sql;
    create table q3 as
        select
             Avg_Rate_of_Univ
            ,q2.County
            ,Avg_Estimated_FTE
        from
             q1
            ,q2
        where
            q1.County = q2.County
        ;
quit;

proc corr data=q3 noprob nosimple PEARSON SPEARMAN;
   var Avg_Estimated_FTE Avg_Rate_of_Univ;
run;

/* clear titles/footnotes*/
title;
footnote;


title1 justify=left
'Plots illustrating a slight positive correlation between Avg_Estimated_FTE and Avg_Rate_of_Univ'
;

footnote1 justify=left
"In the plot above, we can see the average rate of students meeting university requirements tends to increase as the average value of Estimated FTE increases."
;

proc sgplot data=q3;
    scatter x=Avg_Estimated_FTE y=Avg_Rate_of_Univ;
    ellipse x=Avg_Estimated_FTE y=Avg_Rate_of_Univ;
run;

/* clear titles/footnotes*/
title;
footnote;