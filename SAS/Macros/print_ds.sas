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
    %if %length(&in_ds) = 0 %then %do;

        %put ERROR: Must provide an input dataset;
        %return;

    %end;

    %if %sysfunc(exist(&in_ds)) %then %do;

        %if %length(&vars) > 0 %then %check_variables_exist(&in_ds, &vars);

        proc print data=&in_ds (obs=&num_obs) label noobs;
            %if %length(&vars) > 0 %then %do;
                var &vars;
            %end;
        run;

    %end;

    %else %put ERROR: The input dataset &in_ds does not exist;
%mend;
