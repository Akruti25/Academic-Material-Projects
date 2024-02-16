/*
Programmed by: Akruti Sinha
Programmed on: 2023-09-29
Programmed to: Working on HW2
Last Modified on: 10.05.23
*/

*Setting up the working directory;
x "cd L:\st555\Data\BookData\ClinicalTrialCaseStudy";
libname InputDS ".";
filename RawData ".";

x "cd L:\st555\Results";
libname Results ".";

x 'cd S:\ST555-Results';
libname HW3 ".";
filename HW3 ".";

*Closing listing window;
ods listing close;;
*Setting up macro variables and storing all attributes with VarAttrs;
%let VarAttrs = attrib Subj        label = 'Subject Number'                   length = 8
                       sfReas      label = 'Screen Failure Reason'            length = $ 50
                       sfStatus    label = 'Screen Failure Status (0 = Failed)' length = $ 1
                       BioSex      label = 'Biological Sex'                   length = $ 1
                       VisitDate   label = 'Visit Date'                       length = $ 10
                       failDate    label = 'Failure Notification Date'        length = $ 10
                       sbp         label = 'Systolic Blood Pressure'          length = 8
                       dbp         label = 'Diastolic Blood Pressure'         length = 8
                       bpUnits     label = 'Units (BP)'                       length = $ 5
                       pulse       label = 'Pulse'                            length = 8
                       pulseUnits  label = 'Units (Pulse)'                    length = $ 9
                       position    label = 'Position'                         length = $ 9
                       temp        label = 'Temperature'                      length = 8    format = 5.1
                       tempUnits   label = 'Units (Temp)'                     length = $ 1
                       weight      label = 'Weight'                           length = 8
                       weightUnits label = 'Units (Weight)'                   length = $ 2
                       pain        label = 'Pain Score'                       length = 8;
*Define macro varibale for title, sorting and comparing (proc compare);
%let Visit = 3 Month;
%let ValSort = descending sfStatus sfReas descending VisitDate descending failDate Subj;
%let CompOpts = outbase outcompare outdiff outnoequal noprint
     method = absolute criterion = 1E-10;

*Reading the first Site data, 3 Month Visit.txt;
data HW3.Site1_3Month;
    &VarAttrs;
    infile Rawdata("Site 1, &Visit Visit.txt") dsd dlm = '09'x;
    input Subj sfReas $ sfStatus BioSex $ VisitDate $ failDate $ sbp dbp bpUnits $ 
          pulse pulseUnits $ position $ temp tempUnits $ weight weightUnits $ pain;
run;

*Reading the second Site data, 3 Month Visit.csv;
data HW3.Site2_3Month;
    &VarAttrs;
    infile Rawdata("Site 2, &Visit Visit.csv") dsd;
    input Subj sfReas $ sfStatus BioSex $ VisitDate $ failDate $ sbp dbp bpUnits $ 
          pulse pulseUnits $ position $ temp tempUnits $ weight weightUnits $ pain;
    *Printing the IB to the log for every record;
    list;
run;

*Reading the third Site data, 3 Month Visit.dat;
data HW3.Site3_3Month;
    &VarAttrs;
    infile Rawdata("Site 3, &Visit Visit.dat");
    input Subj             1-7
          sfReas         $ 8-58
          sfStatus       $ 59-61
          BioSex         $ 62
          VisitDate      $ 63-72
          failDate       $ 73-82
          sbp              83-85
          dbp              86-88
          bpUnits        $ 89-94
          pulse            95-97
          pulseUnits     $ 98-107
          position       $ 108-118
          temp             119-123
          tempUnits      $ 124
          weight           125-127
          weightUnits    $ 128-129
          pain             130-132;
    *Printing the values of Subject and Pulse in the log from the PDV for every record;
    putlog Subj= Pulse=;
run;

*Sorting the data for first site;
proc sort data=HW3.Site1_3Month;
          by &ValSort;
run;

*Sorting the data for second site;
proc sort data=HW3.Site2_3Month;
          by &ValSort;
run;

*Sorting the data for third site;
proc sort data=HW3.Site3_3Month;
          by &ValSort;
run;

*Setting up destinations and opening the PDF, RTF, and PPT;
ods pdf file = "HW3 Sinha &Visit Clinical Report.pdf" style = Printer;
ods rtf file = "HW3 Sinha &Visit Clinical Report.rtf" style = Sapphire;
ods powerpoint file = "HW3 Sinha &Visit Clinical Report.pptx" style = Powerpointdark;
ods trace on;
ods noproctitle;
options nodate;

*Excluding the output from ppt;
ods powerpoint exclude all;

*In (PDF+RTF)Page 1. Variable-level Attributes and Sort Information for Site 1;
title "Variable-level Attributes and Sort Information: Site 1 at &Visit Visit";
footnote h=10pt j=left "Prepared by &sysuserid on &sysdate";
ods select Position Sortedby;
proc contents data=HW3.Site1_3Month varnum;
run;
title;

*In (PDF+RTF)Page 2. Variable-level Attributes and Sort Information for Site 2;
title "Variable-level Attributes and Sort Information: Site 2 at &Visit Visit";
ods select Position Sortedby;
proc contents data=HW3.Site2_3Month varnum;
run;
title;

*In (PDF+RTF)Page 3. Variable-level Attributes and Sort Information for Site 3;
title "Variable-level Attributes and Sort Information: Site 3 at &Visit Visit";
ods select Position Sortedby;
proc contents data=HW3.Site3_3Month varnum;
run;
title;
footnote;

*Validating the first site data;
proc compare base = Results.HW3DugginsSite1 
             compare = HW3.Site1_3Month
             out = HW3.Diff1 
             &CompOpts;
run;

*Validating the second site data;
proc compare base = Results.HW3DugginsSite2 
             compare = HW3.Site2_3Month
             out = HW3.Diff2 
             &CompOpts;
run;

*Validating the third site data;
proc compare base = Results.HW3DugginsSite3 
             compare = HW3.Site3_3Month
             out = HW3.Diff3 
             &CompOpts;
run;

*Page 4: Printing the output to all three locations: PDF, RTF and PPT;
ods powerpoint exclude none;
title 'Selected Summary Statistics on Measurements';
title2 "for Patients from Site 1 at &Visit Visit";
footnote h=10pt j=left 'Statistic and SAS keyword: Sample size (n), Mean (mean), Standard Deviation (stddev), Median (median), IQR (qrange)';
footnote2 h=10pt j=left "Prepared by &sysuserid on &sysdate";
proc means data=HW3.Site1_3Month noobs n mean stddev median qrange maxdec=1;
           class pain;
           variable weight temp pulse dbp sbp;
run;
title;
footnote;

*Applying custom formats to both the Blood Pressure Variables (DBP and SBP);
proc format library = HW3;
     value sbp(fuzz=0) low -< 130 = 'Acceptable'
                       130 - high = 'High';
     value dbp(fuzz=0) low -< 80 = 'Acceptable'
                       80 - high = 'High';
run;

*Adding options to allow access to the format in InputDS library;
options FMTSEARCH = (HW3);  

*Page 5: Frequency Analysis of Positions and Pain by Blood Pressure for Site 2;
title 'Frequency Analysis of Positions and Pain Measurements by Blood Pressure Status';
title2 "for Patients from Site 2 at &Visit Visit";
footnote h=10pt j=left 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';
footnote2 h=10pt j=left "Prepared by &sysuserid on &sysdate";
*Changin the PDF output to have 2 columns;
ods pdf columns = 2;
proc freq data=HW3.Site2_3Month;
          table position pain*dbp*sbp / norow nocol;
          format dbp dbp. sbp sbp.;
run;
title;
footnote;

*Closing PPT and excluding all outputs here;
ods powerpoint exclude all;

*In (PDF+RTF) Page 6:. Selected Listing of Patients with a Screen Failure and Hypertension for Site 3;
title 'Selected Listing of Patients with a Screen Failure and Hypertension';
title2 "for patients from Site 3 at &Visit Visit";
footnote h=10pt j=left 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';
footnote2 h=10pt j=left 'Only patients with a screen failure are included.';
footnote3 h=10pt j=left "Prepared by &sysuserid on &sysdate";
*Changing PDF output back to one column;
ods pdf columns = 1;
proc print data=HW3.Site3_3Month label;
           where (sfStatus eq '0') AND (sbp>=130 OR dbp>=80);
           id Subj pain;
           var VisitDate sfStatus sfReas failDate BioSex sbp dbp bpUnits weight weightUnits;
run;
title;
footnote;

*Wrapping up;
ods trace off;
ods listing;
ods pdf close;
ods rtf close;
ods powerpoint close;
quit;
