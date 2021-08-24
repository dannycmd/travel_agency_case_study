************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           control.sas                                                                            *
*                                                                                                          *
*   Description:    The user can either run the entire program or run each section in order.               *
*                   Sections A-C must be run in order.                                                     *
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

%include "&root\SAS\Programs\Section A.sas" / source2;
%include "&root\SAS\Programs\Section B.sas" / source2;
%include "&root\SAS\Programs\Section C.sas" / source2;
