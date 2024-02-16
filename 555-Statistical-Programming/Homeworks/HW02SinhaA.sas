/*
Programmed by: Akruti Sinha
Programmed on: 2023-09-16
Programmed to: Working on HW2
Last Modified on: 09.26.23
*/

*Setting up the working directory;
X 'cd L:\st555\data';
libname InputDS "." ;
filename RawData ".";

x 'cd S:\ST555-Results';
libname HW2 ".";
filename HW2 ".";

*Setting the PDF and RTF Name;
ods pdf file = "HW2 Sinha Basic Sales Report.pdf" style = Journal;
ods rtf file = "HW2 Sinha Basic Sales Metadata.rtf" style = Sapphire;
ods trace on;
ods noproctitle;
ods listing close;

*Setting options;
options FMTSEARCH = (InputDS); 
options nodate; 
ods pdf exclude all;

*Using data statement to read the BasicSalesNorth data;
data HW2.BasicSalesNorth;
   infile RawData("BasicSalesNorth.dat") dlm='09'x firstobs = 11;
   attrib EmpID     label = 'Employee ID'     length = $4
          Cust      label = 'Customer'        length = $45
          Date      label = 'Bill Date'       format = yymmdd10.
          Region    label = 'Customer Region' length = $5
          Hours     label = 'Hours Billed'    format= 5.2
          Rate      label = 'Bill Rate'       format= dollar4.
          TotalDue  label = 'Amount Due'      format= dollar9.2;
   input Cust $ EmpID $ Region $ Hours Date Rate TotalDue;
run;

*Printing only the Position table from the North Regions;
ods select position;
title h=14pt "Variable-Level Metadata (Descriptor) Information";
title2 h=10pt "for Records from North Region";
proc contents data=HW2.BasicSalesNorth varnum;
run;
title;

*Using data statement to read the BasicSalesSouth data;
data HW2.BasicSalesSouth;
   infile RawData("BasicSalesSouth.prn") firstobs = 12;
   attrib EmpID     label = 'Employee ID'     length = $4
          Cust      label = 'Customer'        length = $45
          Date      label = 'Bill Date'       format = mmddyy10.
          Region    label = 'Customer Region' length = $5
          Hours     label = 'Hours Billed'    format= 5.2
          Rate      label = 'Bill Rate'       format= dollar4.
          TotalDue  label = 'Amount Due'      format= dollar9.2;
   input Cust $1-45 EmpID $46-49 Region $50-54 Hours 55-59 Date 60-64 Rate 65-67 TotalDue 68-74; 
 run;

*printing only the Position table from the South Regions;
ods select position;
title h=14pt "Variable-Level Metadata (Descriptor) Information";
title2 h=10pt "for Records from South Region";
proc contents data=HW2.BasicSalesSouth varnum;
run;
title;

*Using the data statement to read the BasicSalesEastWest data;
data HW2.BasicSalesEastWest;
   infile RawData("BasicSalesEastWest.txt") dlm="," firstobs = 12;
   attrib EmpID     label = 'Employee ID'     length = $4
          Cust      label = 'Customer'        length = $45
          Date      label = 'Bill Date'       format = date9.
          Region    label = 'Customer Region' length = $5
          Hours     label = 'Hours Billed'    format= 5.2
          Rate      label = 'Bill Rate'       format= dollar4.
          TotalDue  label = 'Amount Due'      format= dollar9.2;
   input Cust $1-45 EmpID $46-49 Region $50-53 Hours Date Rate TotalDue;
run;

*Printing only the Position table to from the East and West Regions;
ods select position;
title h=14pt "Variable-Level Metadata (Descriptor) Information";
title2 h=10pt "for Records from East and West Regions";
proc contents data=HW2.BasicSalesEastWest varnum;
run;
title;

*Printing the Salary Format Details;
title "Salary Format Details";
proc format library = InputDS fmtlib;
     select BasicAmtDue;
run;
title;

*Adding statements to print to PDF rather than RTF;
ods rtf exclude all;
ods pdf exclude none;

*Printing the Five Number Summaries of Hours and Bill Rate;
title h=14pt 'Five Number Summaries of Hours and Bill Rate';
title2 h=10pt 'Grouped by Employee and Total Bill Quartile';
footnote h=8pt j=left 'Produced using data from East and West Regions';
proc means data=HW2.BasicSalesEastWest nolabels min p25 p50 p75 max maxdec=2;
     class EmpId TotalDue; 
     var Hours Rate;
     format TotalDue BasicAmtDue.;
run;
title;

*Printing the breakdown of Records by Customer and Customer by Quarter';
title h=14pt 'Breakdown of Records by Customer and Customer by Quarter';
footnote h=8pt j=left 'Produced using data from North Region';
proc freq data=HW2.BasicSalesNorth;
     tables Cust;
     tables Cust*Date / norow nocol;
     format Date QTRR.;
run;
title;
footnote;

*Printing the Listing of Selected Billing Records;
title h=14pt 'Listing of Selected Billing Records';
footnote h=8pt j=left "Included: Records with an amount due of at least $1,000 orfrom Frank's Franks with a bill rate of $75 or $150.";
footnote2 h=8pt j=left 'Produced using data from South Region';
*Sorting the data;
proc sort data=HW2.BasicSalesSouth out=HW2.BasicSalesSouth2;
     by Cust descending Date;
run;

*Printing the last page;
proc print data=HW2.BasicSalesSouth2 label;
     where TotalDue >= 1000 OR Cust="Frank's Franks" AND Rate in (75, 150);
     id Cust Date EmpID;
     var Hours Rate TotalDue;
     sum Hours TotalDue;
     format TotalDue dollar10.2;
run;
title;
footnote;

ods trace off;
ods pdf close;
ods rtf close;
ods listing;
quit;
