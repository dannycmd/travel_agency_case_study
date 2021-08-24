************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           sort_ds.sas                                                                            *
*                                                                                                          *
*   Description:    Sorts the input dataset using PROC SORT. If an output dataset is not specified then    *
*                   the input dataset will be overwritten. Can sort by multiple variables and specify      *
*                   whether to sort them ascending or descending. Can also sort subsets of the input       *
*                   dataset using the optional 'where' argument and sort views using the 'view'            *
*                   argument. Requires the macro %check_variables_exist.                                   *
*                                                                                                          *
*   Parameters:     Required: in_ds, by_vars                                                               *
*                                                                                                          *                                                                     
*                   Optional: out_ds, desc, where, view                                                    *
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

%macro sort_ds(in_ds=/*Input dataset*/, 
               out_ds=/*Output dataset*/,
               by_vars=/*Variables to sort by. List variables in order, separated by spaces.*/,
               desc=/*Optional argument to sort variables in descending order, e.g. desc=true false.*/,
               where=/*Add where statement to filter data before sorting. Must be inclosed in %str() e.g. where=%str(gender in ('M', 'F'))*/,
               view=false/*Set view=true in order to sort a view.*/);
    %local num_vars j;
    %let where = %quote(&where);

    %if %length(&in_ds) = 0 %then %do;

        %put ERROR: Must provide an input dataset;
        %return;

    %end;

    %if &view = true %then %let view_arg = %str(, VIEW);
    %else %let view_arg = %str();

    %if %sysfunc(exist(&in_ds %unquote(&view_arg))) %then %do;

        %check_variables_exist(&in_ds, &by_vars)

        %let num_vars = %sysfunc(countw(&by_vars));

        proc sort data=&in_ds %if &out_ds ne %str() %then out=&out_ds;;

            by %do j = 1 %to &num_vars;
                
                    %if %scan(&desc, &j, " ") = true %then %do;
                        descending
                    %end;

                    %scan(&by_vars, &j, " ")

                %end;;

            %if %length(&where) > 0 %then %do;
                 where &where;   
            %end;

        run;

    %end;

    %else %put ERROR: The input dataset &in_ds does not exist;
%mend;
