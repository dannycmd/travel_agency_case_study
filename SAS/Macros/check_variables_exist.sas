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
    
    * If no variables were provided then quit;
    %if %length(&vars) = 0 %then %do;

        %put ERROR: Must provide at least one variable;
        %return;

    %end;

    * Count how many variables were provided;
    %let num_vars = %sysfunc(countw(&vars));

    * Open the input dataset - dsid will contain the dataset ID (or 0 if the dataset does not exist);
    %let dsid = %sysfunc(open(&in_ds));

        * Loop through variables in the dataset;
        %do i = 1 %to &num_vars;

            %let var = %scan(&vars, &i, " ");

            * varnum(dataset ID, variable) will return 0 if the variable does not exist in the dataset;
            %if %sysfunc(varnum(&dsid, &var)) = 0 %then %do;

                %put ERROR: The variable &var does not exist;
                %return;

            %end;

        %end;
    
    * Close the dataset - return code is captured but not used (0 if successful, not 0 if not successful);
    %let rc = %sysfunc(close(&dsid));
%mend;
