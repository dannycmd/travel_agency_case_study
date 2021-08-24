************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           Section A.sas                                                                          *
*                                                                                                          *
*   Description:    Import the data (bookings.csv, destinations.csv, households.csv, loyalty.data)         *
*                   into corresponding datasets.                                                           *
*                                                                                                          *
*   Parameters:     Required:                                                                              *
*                                                                                                          *                                                                     
*                   Optional:                                                                              *
*                                                                                                          *
*   Creation Date:  18/08/2021                                                                             *
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
proc printto log = "&root\SAS\Logs\Section A Log.txt";
run;

* Import 'loyalty.dat' into raw.loyalty
  File is tab-delimited;
data raw.loyalty (drop=invested_date rename=(invested_date_new=invested_date));
    length account_id 6 loyalty_id $7 invested_date $9 initial_value 4 investor_type $10 current_value 5; 
    infile input(loyalty.dat) firstobs=2 dlm='09'x;
    input account_id loyalty_id $ invested_date $ initial_value investor_type $ current_value;
    invested_date_new = input(invested_date, date9.);
    format invested_date_new date9. 
           initial_value current_value nlmnlgbp12.2;
    label account_id = "Customer Account Number"
          loyalty_id = "Loyalty Identification"
          invested_date = "Investment Date"
          initial_value = "Initial Share Value"
          investor_type = "Type of Investor"
          current_value = "Current Share Value"; 
run;

* Import 'Households.csv' into raw.households;
data raw.households (drop=dob customer_startdate contact_date rename=(dob_new=dob customer_startdate_new=customer_startdate contact_date_new=contact_date));
    length family_name $20 forename $20 dob $9 loyalty_id $20 address_1 $50 address_2 $50 address_3 $50 address_4 $50 postcode $10 email1 $50 contact_preference $7 interests $10 customer_startdate $9 contact_date $9;
    infile input(Households.csv) firstobs=2 dsd;
    input customer_id family_name $ forename $ title $ gender $ dob $ loyalty_id $ address_1 $ address_2 $ address_3 $ address_4 $ postcode $ email1 $ contact_preference $ interests $ customer_startdate $ contact_date $;
    dob_new = input(dob, date9.);
    customer_startdate_new = input(customer_startdate, date9.);
    contact_date_new = input(contact_date, date9.);
    format dob_new
           customer_startdate_new
           contact_date_new date9.;
    label customer_id = "Customer Identification"
          family_name = "Family Name"
          forename = "Forename"
          title = "Title"
          gender = "Gender"
          dob = "Date of Birth"
          loyalty_id = "Loyalty Identification"
          address_1 = "Address1"
          address_2 = "Address2"
          address_3 = "Address3"
          address_4 = "Address4"
          postcode = "Postcode"
          email1 = "Email Address"
          interests = "Customer Interests"
          contact_preference = "Customers Contact Preference"
          customer_startdate = "Customer Enrolment Date"
          contact_date = "Date Customer last Contacted";
run;

* Import 'Destinations.csv' into raw.destinations;
data raw.destinations;
    length description $50;
    infile input(Destinations.csv) firstobs=2 dsd;
    input code $ description $;
run;

* Create a SAS format called 'dest_code' from raw.destinations;
data destinations_fmt;
    set raw.destinations (rename=(description=label code=start));
    type = "C";
    fmtname = "dest_code";
run;
    
* Store the 'dest_code' format in the shared library;
proc format lib=shared cntlin=destinations_fmt;
run;

* Import 'Bookings.csv' into raw.bookings
  Applying the new 'dest_code' format to the destination_code column;
data raw.bookings (drop=holiday_cost booked_date departure_date rename=(holiday_cost_new=holiday_cost booked_date_new=booked_date departure_date_new=departure_date));
    length family_name $30 brochure_code $2 room_type $20 booked_date $9 departure_date $9 holiday_cost $20;
    infile input(Bookings.csv) firstobs=2 dsd;
    input family_name $ brochure_code $ room_type $ booking_id $ customer_id booked_date $ departure_date $ duration pax insurance_code holiday_cost $ destination_code $;
    holiday_cost = substr(holiday_cost, 2);
    holiday_cost_new = input(holiday_cost, comma9.2);
    booked_date_new = input(booked_date, date9.);
    departure_date_new = input(departure_date, date9.);
    format holiday_cost_new nlmnlgbp9.2
           booked_date_new
           departure_date_new date9.
           destination_code $dest_code.;
    label booking_id = "Booking ID"
          customer_id = "Customer ID"
          family_name = "Family Name"
          brochure_code = "Brochure of Destination"
          booked_date = "Date Customer Booked Holiday"
          departure_date = "Holiday Departure Date"
          duration = "Number of Nights"
          pax = "Number of Passengers"
          insurance_code = "Customer Added Insurance"
          room_type = "Room Type"
          holiday_cost = "Total Cost (�) of Holiday"
          destination_code = "Destination Code";
run;

* Create a PDF report;
ods pdf file = "&root\SAS\Reports\Section A - Importing Text Files.pdf";
title "Section A - Importing Text Files";

proc odstext;
    p "Notes:" / style=[fontweight=bold];
    p "";
        list;
            item "'loyalty.dat' is tab-delimited, whereas the other input files are all comma separated. Therefore, it is assumed that there are no missing values in 'loyalty.dat'";
            item "Some of the descriptions in 'Destinations.csv' are truncated in the input data file - the source of this error will want to be investigated.";
            item "The number of lines in each dataset matches the number of lines in the corresponding input file (accounting for the fact that the first line has been used for the column names). This can be checked using:";
        end;
    p "&root\Python\count_lines.py" / style=[color=blue textindent=50];
run;

title;

proc contents data=raw._all_;
run;

ods _all_ close;

* Direct the log back to the editor;
proc printto;
run;
