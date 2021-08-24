************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           check_variables_exist.sas                                                              *
*                                                                                                          *
*   Description:    Checks whether or not the variables listed exist in the input dataset. Assumes that    *
*                   the input dataset exists, so this should also be checked.                              *
*                                                                                                          *
*   Parameters:     Required: in_ds, vars                                                                  *
*                                                                                                          *                                                                     
*                   Optional:                                                                              *
*                                                                                                          *
*   Creation Date:  24/08/2021                                                                             *
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

%macro check_variables_exist(in_ds, vars);
    %local num_vars i dsid rc var;
    %if %length(&vars) = 0 %then %do;

        %put ERROR: Must provide at least one variable;
        %return;

    %end;

    %let num_vars = %sysfunc(countw(&vars));

    %let dsid = %sysfunc(open(&in_ds));

        %do i = 1 %to &num_vars;

            %let var = %scan(&vars, &i, " ");

            %if %sysfunc(varnum(&dsid, &var)) = 0 %then %do;

                %put ERROR: The variable &var does not exist;
                %return;

            %end;

        %end;

    %let rc = %sysfunc(close(&dsid));
%mend;
