************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           Section B.sas                                                                          *
*                                                                                                          *
*   Description:    Prepare the datasets imported in Section A for analysis and reporting                  *
*                   by creating new variables and joining data                                             *
*                                                                                                          *
*   Parameters:     Required:                                                                              *
*                                                                                                          *                                                                     
*                   Optional:                                                                              *
*                                                                                                          *
*   Creation Date:  18/08/2021                                                                             *
*                                                                                                          *
*   Created By:     Dan Rooney                                                                             *                                                                                                       
*                   Amadeus Software Ltd                                                                   *                                                                                                        
*                   Dan.Rooney@amadeus.co.uk                                                               *
*                                                                                                          *                 
*   Edit History:                                                                                          *
*   +---------------+-------------+---------------------------------------------------------------------+  *
*   |  Programmer   |   Date      |     Description                                                     |  *
*   +---------------+-------------+---------------------------------------------------------------------+  *
*   |               |             |                                                                     |  *
*   +---------------+-------------+---------------------------------------------------------------------+  *
************************************************************************************************************;

* Direct the log to a text file;
proc printto log = "&root\SAS\Logs\Section B Log.txt";
run;

* Create a new variable called greeting that contains a formal greeting for each customer
  If the title is missing then a default title of Mr or Mrs is given based on gender
  If the gender is missing but can be determined from the title then the gender is updated
  A general greeting of 'Dear Customer' is given if the gender cannot be determined and forename is missing;
data staging.households_detail_1 / view=staging.households_detail_1;
    length greeting $40;
    label greeting = "Greeting";
    set raw.households;

    if missing(title) then do;
        if gender = "F" then title = "Mrs";
        else if gender = "M" then title = "Mr";
        else if missing(forename) then greeting = "Dear Customer";
    end;

    if missing(gender) then do;
        if lowcase(compress(title, ".")) in ("mrs","miss","ms") then gender = "F";
        else if lowcase(compress(title, ".")) in ("mr","sir") then gender = "M";
        else if missing(forename) then greeting = "Dear Customer";
    end;

    if not (missing(gender) and missing(forename)) then greeting = catx(" ", "Dear", propcase(compress(title, ".")), upcase(substr(forename, 1, 1)), propcase(family_name));
run;

* Each household can be uniquely identified by its combination of postcode and address_1
  so create a column called unique_id which is a unique identifier for each house;
%sort_ds(in_ds = staging.households_detail_1, out_ds = households_detail_1_sorted, by_vars = postcode address_1, view = true)

* Replacing missing values of gender and dob with 'x' and 1000000, respectively, so that they will come last when we sort them later;
%let missing_gender = "x";
%let missing_dob = 1000000;

data staging.households_detail_2 / view=staging.households_detail_2;
    set households_detail_1_sorted;
    by postcode address_1;
    if missing(dob) then dob = &missing_dob;
    if missing(gender) then gender = &missing_gender;
    if first.address_1 then unique_id + 1;
run;

* Each household has a primary householder based on the following hierarchy:
    1. Eldest female
    2. Eldest male
    3. If gender is unknown for any householder, use the eldest person in the household
    4. If neither gender nor dob are known for any householder, the customer with the
       lowest customer_id is the primary householder;

* First sort by the new unique_id column, gender, dob and customer_id;
%sort_ds(in_ds = staging.households_detail_2, out_ds = households_detail_2_sorted, by_vars = unique_id gender dob customer_id, view = true)

* The primary householder for each unique identifier will now be the first customer corresponding to that unique identifier;
data detail.primary_householders (keep=unique_id customer_id rename=(customer_id=_primary_id));
    set households_detail_2_sorted;
    by unique_id gender dob customer_id;
    if first.unique_id then output;
run;

* Merge the primary_householders and households_detail datasets by unique_id
  so that the primary householder of each customer can be seen;
proc sql;
    CREATE VIEW staging.households_detail_3 AS
        SELECT a.*,
               b._primary_id
        FROM staging.households_detail_2 a
        INNER JOIN detail.primary_householders b
            ON a.unique_id = b.unique_id;
quit;

* Add a Boolean column called primary_householder to the primary_householders dataset
  that indicates whether or not the customer is the primary householder of their household;
data staging.households_detail_4 / view=staging.households_detail_4;
    set staging.households_detail_3;
    primary_householder = _primary_id = customer_id;
    label primary_householder = "Primary Householder";
run;

* Each letter code in the interests column of households_detail corresponds to an interest of the customer
  Add Boolean columns for each interest that indicate which activities each customer is interested in
  Reset missing values of gender and dob to their default values

CODE	DESCRIPTION
A,K,L	Mountaineering
B	    Water Sports
C,X	    Sightseeing
D	    Cycling
E	    Climbing
F,W	    Dancing
H,G	    Hiking
J	    Skiing
M	    Snowboarding
N	    White Water Rafting
P,Q,R	Scuba Diving
S	    Yoga
T,U	    Mountain Biking
V,Y,Z	Trail Walking ;
data detail.households_detail;
    set staging.households_detail_4;

    mountaineering = prxmatch('/A|K|L/i', interests) > 0;
    water = prxmatch('/B/i', interests) > 0;
    sight = prxmatch('/C|X/i', interests) > 0;
    cycle = prxmatch('/D/i', interests) > 0;
    climb = prxmatch('/E/i', interests) > 0;
    dance = prxmatch('/F|W/i', interests) > 0;
    hike = prxmatch('/H|G/i', interests) > 0;
    ski = prxmatch('/J/i', interests) > 0;
    snowboard = prxmatch('/M/i', interests) > 0;
    white = prxmatch('/N/i', interests) > 0;
    scuba = prxmatch('/P|Q|R/i', interests) > 0;
    yoga = prxmatch('/S/i', interests) > 0;
    biking = prxmatch('/T|U/i', interests) > 0;
    trail = prxmatch('/V|Y|Z/i', interests) > 0;

    if gender = &missing_gender then gender = ' ';
    if dob = &missing_dob then dob = .;
    label mountaineering = "Mountaineering"
          water = "Water Sports"
          sight = "Sightseeing"
          cycle = "Cycling"
          climb = "Climbing"
          dance = "Dance"
          hike = "Hiking"
          ski = "Skiing"
          snowboard = "Snowboarding"
          white = "White Water Rafting"
          scuba = "Scuba Diving"
          yoga = "Yoga"
          biking = "Mountain Biking"
          trail = "Trail Walking";
run;

* Create two new datasets contact_post and contact_email containing
  customers whose contact preferences are 'Post' and 'E-Mail' respectively;
data marts.contact_post (drop=email1) marts.contact_email (drop=family_name--postcode title);
    set detail.households_detail (keep=greeting--forename address_1--contact_preference customer_id title
                   where=(contact_preference in ('Post', 'E-Mail')));

    if contact_preference = 'Post' then output marts.contact_post;

    else output marts.contact_email;
run;

* Customers pay for their holiday through payment of a deposit of 20% at point of booking
  The remaining balance of 80% is paid within the six week period preceding the holiday departure date
  If a holiday is booked within six weeks of departure a single invoice for the full balance is issued;
data bookings_deposit bookings_balance (drop=deposit balance);
    set raw.bookings;
    * Number of days between the date the holiday was booked and the departure date;
    date_diff = intck('DAY', booked_date, departure_date);

    * Six weeks = 42 days
      Calculate deposit and balance if date_diff < 42 days;
    if date_diff > 42 then do;
        deposit = 0.2 * holiday_cost;
        balance = 0.8 * holiday_cost;
        output bookings_deposit;
    end;

    else output bookings_balance;

    drop date_diff;
    format deposit
           balance nlmnlgbp12.2;
run;

* Sort the bookings_deposit and bookings_balance datasets by booked_date;
%sort_ds(in_ds = bookings_deposit, out_ds = detail.bookings_deposit, by_vars = booked_date)
%sort_ds(in_ds = bookings_balance, out_ds = detail.bookings_balance, by_vars = booked_date)

* Create a dataset containing only the customers that are shareholders and details from the households dataset about these customers;
proc sql;
    CREATE TABLE detail.shareholders (drop=l_id h_id) AS
        SELECT COALESCE(l_id, h_id) as loyalty_id,
               *
        FROM raw.loyalty (rename=(loyalty_id=l_id)) l
        LEFT JOIN raw.households (rename=(loyalty_id=h_id)) h
            ON l_id = h_id;
quit;

* Create a dataset containing only the customers who have not made a booking;
proc sql;
    CREATE TABLE detail.household_only AS 
        SELECT h.*
        FROM detail.households_detail h
        LEFT JOIN raw.bookings b
            ON h.customer_id = b.customer_id
        WHERE b.customer_id IS MISSING;
quit;

* Create a dataset containing details about the primary householder for households that have made more than one booking
  From inner-most query to outer-most:
        -> Select all customer_id values of customers who have made more than one booking and remerge
        -> Join with the households_detail dataset to get details about the customers
        -> Join with the households_detail dataset again but this time matching _primary_id to 
           customer_id to show the details of the primary householder for each booking;

proc sql;
    CREATE TABLE bookings_multi AS
        SELECT sub1.*
        FROM
            (SELECT h2.*,
                    sub2.brochure_code,
                    sub2.room_type,
                    sub2.booking_id,
                    sub2.duration,
                    sub2.pax,
                    sub2.insurance_code,
                    sub2.destination_code,
                    sub2.holiday_cost,
                    sub2.booked_date,
                    sub2.departure_date
             FROM
                 (SELECT *, 
                         COUNT(*) AS num_bookings
                  FROM raw.bookings
                  GROUP BY customer_id
                  HAVING num_bookings > 1) sub2
            LEFT JOIN detail.households_detail h2
                ON sub2.customer_id = h2.customer_id) sub1
        INNER JOIN detail.households_detail h1
            ON sub1._primary_id = h1.customer_id
        ORDER BY sub1.customer_id, sub1.booking_id;
quit;

* Create a format for grouping together age ranges;
proc format lib=shared;
    value age low - 18  = "Under 18"
              18 - 24   = "18-24"
              25 - 34   = "25-34"
              35 - 44   = "35-44"
              45 - 54   = "45-54"
              55 - 64   = "55-64"
              65 - high = "65+"
              .         = "Missing";
run;
              
* Add a column containing the age of the primary householder at the start of the holiday
  and apply the new age format to it;
data detail.bookings_multi;
    set bookings_multi;
    age_at_holiday_start = intck('YEAR', dob, departure_date, 'C');
    format age_at_holiday_start age.;
run;

* Create a PDF report;
ods pdf file = "&root\SAS\Reports\Section B - Data Management.pdf";

title "Section B - Data Management";
title3 "Primary householders";
title4 height=1 "'Primary Householder' column holds Boolean values, indicating whether or not the customer is the primary householder";
footnote "First 30 observations";
%print_ds(in_ds = detail.households_detail, vars = customer_id primary_householder)
title "Customer interests";
%print_ds(in_ds = detail.households_detail, vars = customer_id mountaineering water sight cycle climb dance hike ski snowboard white scuba yoga biking trail)
title "Customers to be contacted by post";
%print_ds(in_ds = marts.contact_post)
title "Customers to be contacted by email";
%print_ds(in_ds = marts.contact_email)
title "Over 6 weeks until holiday departure date";
%print_ds(in_ds = detail.bookings_deposit)
title "Under 6 weeks until holiday departure date";
%print_ds(in_ds = detail.bookings_balance)
title;
footnote;

ods pdf close;

* Direct the log back to the editor;
proc printto;
run;
