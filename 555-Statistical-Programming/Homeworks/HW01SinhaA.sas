/*
Programmed by: Akruti Sinha
Programmed on: 2023-09-09
Programmed to: Working on HW2
Last Modified on: 09.11.23
*/

*Setting up the working directory;
X 'cd L:\st555\data';
libname InputDS "." ;
x 'cd S:\ST555-Results';
libname HW1 ".";

*Setting up logistics - PDF Name, No Date. And closing the listing window;
ods pdf file="HW1 Sinha Weather Analysis.pdf" style = Festival;
ods listing close;
options nodate;

*Sorting the dataset by Year, Month, Day in descending order;
proc sort data = InputDS.rtptall
          out = HW1.rtptall_sorted;
     by descending Year MonthN DayN;
run;

*Printing the sorted dataset's details for the first page;
title 'Descriptor Information After Sorting';
proc contents data = HW1.rtptall_sorted varnum;
ods noproctitle;
ods exclude EngineHost Attributes;
run;
title;


/*Working on Summary of Temp and Precipitation Pg 2*/
title 'Raleigh, NC: Summary of Temperature and Precipitation';
title2 'in June, July, and August';
title3 h=8pt 'by 15-Year Groups (Since 1887)';
footnote h=8pt j=left 'Excluding Years Prior to 1900';
proc means data = HW1.rtptall_sorted
           n median qrange mean stddev
           noobs maxdec = 2;
     class GroupDesc;
     where MonthC in ('June', 'July', 'August') and Year>=1900;
     var Tmax Tmin Prcp;
     label Year = 'Year Group'
           Tmax = 'Daily Max Temp' 
           Tmin = 'Daily Min Temp'
           Prcp = 'Daily Precip.';
run;
title;
title2;
title3;
footnote;

*Declaring format for Min and Max temperatures;
proc format;
  value Tmin(fuzz=0) other='Not Recorded'
             low-<32='<32'
             32-<50='[32,50)'
             50-<70='[50,70)'
             70-high='>=70'
           ;
   value Tmax(fuzz=0) low-<50='<50'
              50-<75='[50,75)'
              75-<90='[75,90)'
              90-high='>=90'
              other='Not Recorded'
           ;

*Page 3 - Precipitation and Temperature Group Classification; 
title 'Raleigh, NC: Amount of Precipitation by 15-Year Group (Since 1887)';
title2 'and by Temperature Group Cross-Classification';
footnote h=8pt j=left 'Excluding Weekends';
proc freq data=HW1.rtptall_sorted (where=(DayC not in ('Saturday', 'Sunday')));
     tables GroupDesc Tmin*Tmax / missing;;
     weight Prcp;
     format Tmin Tmin. Tmax Tmax.;
run;
title;
title2;
footnote;

*Anova Table Pages 4-12;
title 'Predicting Precipitation from Temperature (Min&Max) and Day of the Week';
title2 'Using Independent Models for each 15-Year Group (Since 1887)';
footnote h=8pt j=left 'Only displaying the Type III ANOVA Table';
ods select 'Type III Model ANOVA';
proc glm data = HW1.rtptall_sorted;
          by descending GroupDesc;
          class DayC;
          model Prcp = tMax tMin DayC;
run;
title;
title2;
footnote;

*Proc printing temp and precipitation for Jan and Dec - Page 13,14;
title 'Listing of Temperature and Precipitation Values';
footnote h=8pt j=left 'Restricted to January and December of 2021';
proc print data = HW1.rtptall_sorted noobs label;
     var DayC Tmin Tmax Prcp;
     by MonthN;
     id MonthC DayN;
     sum Prcp;
     attrib Prcp format=4.2; 
     where MonthN in (1,12) and Year = 2021;
run;
title;
footnote;
ods pdf close;

*reopening listing;
ods listing;
quit;
