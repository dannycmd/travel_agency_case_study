************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           Section C.sas                                                                          *
*                                                                                                          *
*   Description:    Analysis and reporting of the data                                                     *
*                                                                                                          *
*   Parameters:     Required:                                                                              *
*                                                                                                          *                                                                     
*                   Optional:                                                                              *
*                                                                                                          *
*   Creation Date:  20/08/2021                                                                             *
*                                                                                                          *
*   Created By:     Dan Rooney                                                                             *                                                                                                       
*                                                                                                          *                 
*   Edit History:                                                                                          *
*   +---------------+-------------+---------------------------------------------------------------------+  *
*   |  Programmer   |   Date      |     Description                                                     |  *
*   +---------------+-------------+---------------------------------------------------------------------+  *
*   |               |             |                                                                     |  *
*   +---------------+-------------+---------------------------------------------------------------------+  *
************************************************************************************************************;

* Direct the log to a text file;
proc printto log = "&root\SAS\Logs\Section C Log.txt";
run;

* Create a table showing frequency counts for each interest by calculating sum of each Boolean column;
proc means data=detail.households_detail noprint;
    var Mountaineering--Trail;
    output out=marts.interests_counts (drop=_type_ _freq_) sum= / autoname;
run;

* Now we want to create a table showing frequency counts for each interest classified by the 
  age of the primary householder at the holiday departure date
  First we perform an inner join with the bookings dataset to get the departure dates of holidays
  booked by each customer - this will remove any customers who have not made any bookings
  Then we join with the households_detail dataset again to get the dob of the primary householder
  for each booking;
proc sql;
    CREATE TABLE dob_of_primary_householder AS
        SELECT sub.*, 
               h2.dob AS dob_of_primary_householder
        FROM
            (SELECT h1.*,
                    b.departure_date
             FROM detail.households_detail h1
             INNER JOIN raw.bookings b
                 ON h1.customer_id = b.customer_id) sub
        INNER JOIN detail.households_detail h2
            ON sub._primary_id = h2.customer_id;
quit;

* Add a column containing the age of the primary householder at the start of the holiday;
data dob_of_primary_householder;
    set dob_of_primary_householder;
    age_at_holiday_start = intck('YEAR', dob_of_primary_householder, departure_date, 'C');
    format age_at_holiday_start age.;
    label age_at_holiday_start = "Age at holiday departure date";
run;

* Create a table showing frequency counts for each interest classified by the 
  age of the primary householder at the holiday departure date;
proc means data=dob_of_primary_householder noprint missing nway;
    var Mountaineering--Trail;
    class age_at_holiday_start;
    output out=marts.interests_counts_by_age (drop=_type_ _freq_) sum= / autoname;
run;

* Create two tables showing frequency counts of each interest by gender;
%sort_ds(in_ds = detail.households_detail, out_ds = households_detail_sorted, by_vars = gender, where = %str(gender in ('M', 'F')))

proc means data=households_detail_sorted sum stackodsoutput;
    var Mountaineering--Trail;
    by gender;
    ods output Summary=marts.interests_counts_by_gender (rename=(sum=count));
run;

data marts.interests_counts_by_gender;
    set marts.interests_counts_by_gender (drop=variable rename=(label=interest));
    format count 6.;
run;

* The marts.interests_counts_by_gender table contains frequency counts for each gender for every interest
  We want to split this into one table for each gender and then only show the five most popular interests for each
  Therefore need to sort by gender and descending count;
%sort_ds(in_ds = marts.interests_counts_by_gender, by_vars = gender count, desc = false true)

data marts.male_interests_counts marts.female_interests_counts;
    set marts.interests_counts_by_gender;

    if gender = 'M' then output marts.male_interests_counts;
    else output marts.female_interests_counts;
run;

data marts.male_interests_counts;
    set marts.male_interests_counts (obs=5);
run;

data marts.female_interests_counts;
    set marts.female_interests_counts (obs=5);
run;

* Create a PDF report;
ods pdf file = "&root\SAS\Reports\Section C - Frequency Counts of Interests.pdf";

title "Section C: Analysis and Reporting";
title3 "Frequency counts of customer interests";
%print_ds(in_ds = marts.interests_counts)
title "Frequency counts of customer interests";
title2 height=2 "Grouped by age of the primary householder on the holiday departure date";
%print_ds(in_ds = marts.interests_counts_by_age)
title;

ods pdf close;

* Create an Excel spreadsheet containing the top five interests for each gender;
ods excel file = "&root\SAS\Reports\Frequency Counts of Interests by Gender.xlsx";

%print_ds(in_ds = marts.male_interests_counts)
%print_ds(in_ds = marts.female_interests_counts)

ods excel close;

* Direct the log back to the editor;
proc printto;
run;
