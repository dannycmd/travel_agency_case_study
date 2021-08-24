************************************************************************************************************
*                                                                                                          *                                                                                                          
*   Name:           autoexec.sas                                                                           *
*                                                                                                          *
*   Description:    The user must input the path to the project root and then the librefs                  *
*                   and filerefs will be assigned. Global SAS options are also set.                        *
*                                                                                                          *
*   Parameters:     Required:   Path to project root (&root)                                               *
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


* Enter the path to the project root;

%let root = ;

*************************************************************************************************************************************************************************;


* Check whether the root directory entered above actually exists;
%macro check_valid_path(path=);
    %local first_char;

    %let path = %nrbquote(&path);
    %let fileref = root;

    %if &path eq %str() %then %do;
        %put ERROR: Must be provide a path to the project root;
        %return;
    %end;

    %let first_char = %qsubstr(&path, 1, 1);

    %if &first_char ne %str(%') and &first_char ne %str(%") %then %let path = "&path";
    filename &fileref &path;
    %if %sysfunc(fexist(&fileref)) = 0 %then %put ERROR: The specified path to the project root does not exist;
%mend;

%check_valid_path(path=&root)

* Create folders referenced in libname statements if they do not exist already;
options dlcreatedir;

* Standard data libraries;
filename input "&root\SAS\Data\Input";
libname raw "&root\SAS\Data\Raw";
libname detail "&root\SAS\Data\Detail";
libname marts "&root\SAS\Data\Marts";
libname staging "&root\SAS\Data\Staging";
libname except "&root\SAS\Data\Exceptions";
libname system "&root\SAS\Data\Metadata";

* Shared SAS objects e.g. formats;
libname shared "&root\SAS\Shared";

* Autocall macro library;
filename macros "&root\SAS\Macros";

* Standard SAS options;
options mautosource
        sasautos=(macros sasautos)
        fmtsearch=(shared)
        msglevel=i
        mcompilenote=noautocall;
