/*
Programmed by: Akruti Sinha
Programmed on: 2023-09-01
Programmed to: Provide data on temperature and precipitation throughout the years.
Last Modified on: 09/04/23
*/

*Setting up the working directory;
X 'cd L:\st555\data';
libname InputDS "." ;
x 'cd S:\ST555-Results';

*Setting up logistics - PDF Name, No Date. And closing the listing window;
ods pdf file="HW0 Sinha Partial Weather Listing.pdf" style = Festival;
ods listing close;
options nodate;

/* 
  Working on the first listing of HW0
*/

*Printing the unsorted dataset's contents minus EngineHost details;
proc contents data = InputDS.raleightempprecip varnum;
title 'Descriptor Information Before Sorting'; 
title2 'with Variable Information in Column Order';
ods exclude EngineHost;
run;

/*
  Working on Second Listing of HW0
*/

/*Printing the sorted dataset's contents minus variables*/
title 'Descriptor Information After Sorting';
title2 'with Variable Information in Column Order';
proc contents data = InputDS.RTPSorted;
ods exclude EngineHost Variables;
run;

*Printing the Max Temperatures list;
title 'January Daily Max Temperatures';
title2 'Most Recent 5 Years';
proc print data=InputDS.RTPSorted (obs=5);
            var Year TempMax1-TempMax31;
run;

*Printing the Minimumum Temperatures list;
title 'January 1st-7th Temperature Extremes';
title2 'Most Recent 5 Years';
proc print data=InputDS.RTPSorted (obs=5);
            var Year--TempMax7;
run;

/*
  Working on Third Listing of HW0
*/

*Printing the precipitation values of the last 10 years;
title 'Daily Rainfall';
title2 'Most Recent 10 Years';
proc print data=InputDS.RTPSorted (obs=10);
           var Year Prcp:;
run;

ods pdf close;
quit;
