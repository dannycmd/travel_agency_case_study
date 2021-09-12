************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           print_ds.sas                                                                           *
*                                                                                                          *
*   Description:    Prints the input dataset using PROC PRINT. If the variables to print are not specified *
*                   then all variables are printed. Can also specify the number of observations to print.  *
*                   Requires the macro %check_variables_exist.                                             *
*                                                                                                          *
*   Parameters:     Required: in_ds                                                                        *
*                                                                                                          *                                                                     
*                   Optional: num_obs (default = 30), vars                                                 *
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

%macro print_ds(in_ds=/*Input dataset*/,
                num_obs=30/*Number of observations to print*/,
                vars=/*Variables to print. List variables in order, separated by spaces.*/);
    * Check an input dataset was provided otherwise quit;
    %if %length(&in_ds) = 0 %then %do;

        %put ERROR: Must provide an input dataset;
        %return;

    %end;

    * Check input dataset exists;
    %if %sysfunc(exist(&in_ds)) %then %do;

        * If variables were provided then check they exist using autocall macro;
        %if %length(&vars) > 0 %then %check_variables_exist(&in_ds, &vars);

        * Print the dataset;
        proc print data=&in_ds (obs=&num_obs) label noobs;
            %if %length(&vars) > 0 %then %do;
                var &vars;
            %end;
        run;

    %end;

    * If the input dataset does not exist then quit;
    %else %put ERROR: The input dataset &in_ds does not exist;
%mend;
