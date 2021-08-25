%macro interests_columns(interests);
    %local len i args;
    %let len = %length(&interests);
    %let args = %str(/);

        %do i = 1 %to &len;
            
            %let args = &args%substr(&interests, &i, 1);
            %if &i = &len %then %let args = &args%str(/i);
            %else %let args = &args%str(|);

        %end;

    prxmatch("&args", interests) > 0;
%mend;
