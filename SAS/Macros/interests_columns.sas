************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           interests_columns.sas                                                                  *
*                                                                                                          *
*   Description:    Used to create the Boolean interests columns in Section B.                             *
*                                                                                                          *
*   Parameters:     Required: interests                                                                    *
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

%macro interests_columns(interests);
    %local len i args;
    %let len = %length(&interests);
    %let args = %str(/);

        %do i = 1 %to &len;
            
            %let args = &args%substr(&interests, &i, 1);
            %if &i = &len %then %let args = &args%str(/i);
            %else %let args = &args%str(|);

        %end;

    prxmatch("&args", interests) > 0
%mend;