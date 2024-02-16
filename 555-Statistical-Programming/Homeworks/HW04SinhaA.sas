/*
Programmed by: Akruti Sinha
Programmed on: 2023-10-01
Programmed to: Working on HW2
Last Modified on: 10.16.23
*/

*Setting up the working directory;
x "cd L:\st555\Data\";
libname InputDS ".";
filename RawData ".";

x "cd L:\st555\Results";
libname Results ".";

x "cd S:\ST555-Results\HW4";
libname HW4 ".";
filename HW4 ".";

*Setting up macro variables for Year and CompOpts;
%let Year = 1998;
%let CompOpts = outbase outcompare outdiff outnoequal noprint /*not print output*/ method = absolute criterion = 1E-15;

*Setting all ods related options;
ods listing;
ods pdf file = "HW4 Sinha Lead Report.pdf";
ods trace on;
ods noproctitle;
ods exclude all;

*Setting no date and format search;
options nodate;
options fmtsearch = (HW4);

*Reading the data file: LeadProjects.txt;
Data HW4.LeadProjects(drop=_:);
  attrib StName     length=$2  label="State Name"
         Region     length=$9
         JobID      length=8
         Date       length=8   format=date9.
         PolType    length=$4  label="Pollutant Name"
         PolCode    length=$8  label="Pollutant Code"    
         Equipment  length=8   format=dollar11.    
         Personnel  length=8   format=dollar11.
         JobTotal   length=8   format=dollar11.;
  infile Rawdata("LeadProjects.txt") dsd firstobs=2 truncover;
  input _StName $ _JobID $ _DateRegion : $13. _PolCodeType $
        Equipment : comma. Personnel : comma.;
  *Inputting data from raw data and correcting format where needed;
  Date = input(compress(_DateRegion,,'ai'),5.);
  Region = propcase(compress(_DateRegion,,'ak'));
  PolCode = substr(_PolCodeType,1,1);
  PolType = substr(_PolCodeType,2);
  *Defining jobtotal;
  JobTotal=Equipment+Personnel;
  *Correcting the name to uppercase;
  StName=upcase(_StName);
  *Correcting 0 and 1 in job ids;
  JobID=input(tranwrd(tranwrd(_JobID,'l','1'),'O','0'),5.);
run;

*Sorting the data;
proc sort data=HW4.LeadProjects out=HW4.HW4SinhaLead;
  by Region StName descending jobtotal;
run;

*Saving the Descriptor portion;
ods output position = HW4.HW4SinhaDesc(drop=member);
proc contents data = HW4.HW4SinhaLead varnum;
run;

*Performing electronic validation for the metadata;
proc compare base = Results.HW4DugginsDesc 
             compare = HW4.HW4SinhaDesc
             out = HW4.DiffsA
             &CompOpts;
run;

*Performing electronic validation for the data;
proc compare base = Results.HW4DugginsLead 
             compare = HW4.HW4SinhaLead
             out = HW4.DiffsB
             &CompOpts;
run;

*Creating a format;
proc format library = HW4;
  value MyQtr "01JAN&Year"d -< "01APR&Year"d = 'Jan/Feb/Mar'
              "01APR&Year"d -< "01JUL&Year"d = 'Apr/May/Jun'
              "01JUL&Year"d -< "01OCT&Year"d = 'Jul/Aug/Sep'
              "01OCT&Year"d -  "31DEC&Year"d = 'Oct/Nov/Dec';
run;

*Setting options to write to the destinations;
ods exclude none;

*First Table: 90th Percentile of Total Job Cost By Region and Quarter;
title '90th Percentile of Total Job Cost By Region and Quarter';
title2 "Data for &Year";
ods listing exclude summary;
ods output Summary = HW4.sum1;
proc means data = HW4.HW4SinhaLead p90;
  class Region Date;
  var JobTotal;
  format Date MyQtr.;
run;
title;

*Creating the first graph and setting graph revolution and size;
ods listing image_dpi = 300;
ods graphics / reset width = 6in imagename = "HW4SinhaGraph1_90p";
proc sgplot data = HW4.sum1;
  hbar Region / response = JobTotal_P90
                group = Date 
                groupdisplay = cluster
                datalabel = nobs 
                datalabelattrs = (size = 6pt);
  keylegend / location = outside 
              position = top;
  xaxis label = "90th Percentile of Total Job Cost" grid;
  format JobTotal_P90 dollar6.;
run;

*Second Table: Frequency of Cleanup by Region and Date;
title 'Frequency of Cleanup by Region and Date';
title2 "Data for &Year";
ods listing exclude crosstabfreqs;
ods output CrossTabFreqs = HW4.sum2 (where = (_TYPE_ eq '11') 
                                     keep = Region Date _TYPE_ RowPercent);
proc freq data = HW4.HW4SinhaLead;
  table region*date / nocol nopercent;
  format date MyQtr.;
run;
title;

*Creating the second graph and setting graph revolution;
ods listing image_dpi = 300;
ods graphics / reset width = 6in imagename = "HW4SinhaGraph2_Region";
ods output sgplot = HW4.HW4SinhaGraph2;
proc sgplot data = HW4.sum2;
  styleattrs datacolors = (green orange blue red);
  vbar Region / response = RowPercent 
                group = date 
                groupdisplay = cluster;
  keylegend / location = inside
              down = 2
              opaque;
  xaxis labelattrs = (size = 16pt) 
        valueattrs = (size = 14pt);
  yaxis label = "Region Percentage within Pollutant" 
        labelattrs = (size = 16pt)
    valueattrs = (size = 12pt) 
    grid gridattrs = (thickness = 3 color = grayCC)
        valuesformat = comma4.1
        offsetmax = 0.05
        values = (0 to 45 by 5);
run;

*Validatin the the content portion;
proc compare base = Results.HW4DugginsGraph2 
             compare = HW4.HW4SinhaGraph2
             out = diffsC 
             &CompOpts;
run;

*Wrapping up;
ods trace off;
ods pdf close;
quit;
