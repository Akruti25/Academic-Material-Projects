/*
Programmed by: Akruti Sinha
Programmed to: Working on Final Phase 2 Project
Last Modified on: 12.05.23
*/

*Setting up working directories;
x "cd L:\st555\Results\FinalProjectPhase1";
libname InputDS ".";
filename RawData ".";

x "cd S:\ST555-Results\Final2";
libname Final ".";
filename Final ".";

*Setting up options and PDF file;
ods pdf file = "Sinha Washington State Electric Vehicle Study.pdf" style=Sapphire dpi=300;
options nodate;
options nobyline;
ods noproctitle;
options fmtsearch = (Final);
ods graphics / width = 6in;
ods listing image_dpi = 300;

*Setting up Macro variables for headers and footers;
%let SubTitleOpts= h=10pt;
%let Title2Opts = h=14pt; 
%let IdStamp=Output created by &sysuserid on &sysdate9 using &SysVLong;
%let footOpts = j=left h=8pt italic;

*Setting up one proc format for all formats;
proc format library = Final;
  value cafvCodeFormat  1 = 'CAFV Eligible'
                        2 = 'Not CAFV Eligible'
                        3 = 'CAFV Eligibility Unknown'
                        ;
  value ModelYearFormat low-<2000='Pre-2000'
                        2000-2004='2000-2004'
                        2005-2009='2005-2009'
                        2010-2014='2010-2014'
                        2015-2019='2015-2019'
                        2020-2024='2020-2024'
                        ;
  value meanBEVFormat  0 = "cxfdae6b"
                    0 -< 200 = "cxefedf5"  
                    200 -< 250 = "cxbcbddc" 
                    250 -< 300 = "cx756bb1" 
                    300 - high = "cxc51b8a"
                    ;
  value ERangeFormat 0 = 'Not Yet Known'
                     0 -< 200 = 'Poor'
                     200 -< 250 = 'Average'
                     250 -< 300 = 'Good'
                     300 -high = 'Great'
                     other = 'Invalid/Missing'
                    ;
   value phevformat 0 -< 25 = "cxefedf5"  
                    25 -< 50 = "cxbcbddc" 
                    50 -< 75 = "cx756bb1" 
                    75 - high = "cxc51b8a"
                    ;
run;

*PHASE 1: OUTPUT 1;
ods pdf columns=2;
title &SubTitleOpts "Output 1";
title2 &Title2Opts "Listing of BEV Cars Not Known to be CAFV* Eligible";
title3 &SubTitleOpts "Partial Output -- Up to First 10 Records Shown per CAFV Status";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Clean Alternative Fuel Vehicle";
proc print data=InputDS.FinalDugginsEV (obs=10) noobs label;
    where CAFVCode=2 and EVTypeShort="BEV";
    var CAFVCode MAKE MODEL ERANGE;
    label CAFVCode= "CAFV Eligibility";
    format CAFVCode cafvCodeFormat.;
run;
proc print data=InputDS.FinalDugginsEV (obs=10) noobs label;
    where CAFVCode=3 and EVTypeShort="BEV";
    var CAFVCode MAKE MODEL ERANGE;
    label CAFVCode= "CAFV Eligibility";
    format CAFVCode cafvCodeFormat.;
run;
title;
footnote;

*PHASE 2: OUTPUT 2;
title &SubTitleOpts "Output 2"; 
title2 &Title2Opts "Selected Summary Statistics of MSRP and Electric Range";
footnote &footOpts "&IDStamp";
ods exclude quantiles extremeObs TestsForLocation ERange.MissingValues;
proc univariate data = InputDS.FinalDugginsEV;
    var BaseMSRP ERange;
run;
title;
footnote;

*PHASE 3: OUTPUT 3;
title &SubTitleOpts "Output 3";
title2 &Title2Opts "Quantiles and Missing Data Summary of Base MSRP";
title3 &SubTitleOpts "Grouped by Model Year";
footnote &footOpts "&IDStamp";
ods select quantiles MissingValues; 
proc univariate data=InputDS.FinalDugginsEV;
    class ModelYear;
    var BaseMSRP;
    format ModelYear ModelYearFormat.;
run;
title;
footnote;

*PHASE 4: OUTPUT 4;
ods pdf columns=1;
title &SubTitleOpts "Output 4";
title2 &Title2Opts "90% Confidence Interval for Electric Range";
title3 &SubTitleOpts "Grouped by CAFV* Status and EV Type";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Clean Alternative Fuel Vehicle";
proc means data = InputDS.FinalDugginsUniqueVinMask nonobs maxdec=3 alpha=0.1 lclm mean uclm stderr n; 
    class CAFVCode EVTypeShort;
    var ERange;
run;
title;
footnote;

*PHASE 5: OUTPUT 5;
ods pdf columns=2 startpage=now;
title &SubTitleOpts "Output 5";
title2 &Title2Opts "Frequency Analysis of State";
title3 h=8pt " ";
title4 &SubTitleOpts "(Cumulative Statistics omitted)";
footnote &footOpts "&IDStamp";
proc freq data = InputDS.FinalDugginsEV order=freq;
  tables StateCode / nocum MISSING;
run;
title;
footnote;

*PHASE 6: OUTPUT 6;
ods pdf columns=1;
title &SubTitleOpts "Output 6";
title2 &Title2Opts "Frequency Analysis of EV Type, Primary Utility*";
title3 &Title2Opts "and CAFV** by EV Type";
title4 &SubTitleOpts "(Cumulative Statistics omitted)";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Defined as first electric utility listed in the data base for the vehicle location.";
footnote3 &footOpts "**Clean Alternative Fuel Vehicle";
proc freq data=InputDS.FinalDugginsEV order=freq;
  tables EVTypeShort / nocum;
  tables PrimaryUtil /nocum;
  tables CAFV*EVTypeShort /format=comma11. ;
run;
title;
footnote;

*PHASE 7: OUTPUT 7;
title &SubTitleOpts "Output 7";
title2 &Title2Opts "Frequency Analysis of Model Year by Electric Range";
title3 &SubTitleOpts "For BEV Cars Only";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Range categories: 0 = Not Yet Known; (0,200)=Poor; [200,250)=Average;[250,300)=Good;300+=Great;Other=Invalid/Missing";
proc freq data=InputDS.FinalDugginsEV (where=(EVTypeShort='BEV'));
  tables ModelYear*ERange / format=comma11. missing;
  format ModelYear ModelYearFormat. ERange ERangeFormat.;
run;
title;
footnote;

*PHASE 8: OUTPUT 8;
title &SubTitleOpts "Output 8";
title2 h=14pt "Frequency Analysis of Model Year by Electric Range";
title3 h=10pt "Only for BEV Cars with Reported (>0) Ranges";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Range categories: 0 = Not Yet Known; (0,200)=Poor; [200,250)=Average;[250,300)=Good;300+=Great;Other=Invalid/Missing";
proc freq data=InputDS.FinalDugginsEV (where=(EVTypeShort='BEV' and ERange>0));
  tables ModelYear*ERange / format=comma11. missing;
  format ModelYear ModelYearFormat. ERange ERangeFormat.;
run;
title;
footnote;

*PHASE 9: OUTPUT 9;
title &SubTitleOpts "Output 9";
title2 &Title2Opts "Frequency of EV Type for Each CAFV Elibility Category";
footnote &footOpts "&IDStamp";
proc sgplot data = InputDS.FinalDugginscafvcrossev;
       styleattrs datacolors = (cxdd1c77 cx2ca25f);
        vbar CAFVCode / response = RowPercent
                        nooutline
                        barwidth=0.5                
                        group = EVTypeShort;
        xaxis label = "CAFV Eligibility"
                values=("1" "2" "3") valuesdisplay=("Yes" "No" "Unknown")
                valueattrs = (size = 14pt)
                labelattrs = (size = 10pt);
        yaxis label = " % of CAFV Category" 
              values=(0 to 100 by 10) 
              valueattrs = (size = 12pt)
              labelattrs = (size = 10pt);
        keylegend / title="EVType"
                    opaque
                    position=ne
                    location = inside 
                    across = 1;
run;
title;
footnote;

*PHASE 10: OUTPUT 10;
ods layout gridded rows=2 columns=1;
title &SubTitleOpts "Output 10";
title2 &Title2Opts "Frequency of CAFV Elibility Category for Each EV Type";
footnote &footOpts "&IDStamp";
proc sgplot data = InputDS.FinalDugginscafvcrossev;
     styleattrs datacolors = ( cx7fcdbb cxd95f0e cx756bb1);
      hbar EVTypeShort / response = ColPercent
                         group = CAFVCode
                         groupdisplay=cluster
                         nooutline
                         datalabel = colpercent datalabelattrs = (size = 10pt color=cxbdbdbd)
                         DATALABELFITPOLICY=NONE; *adding because it gives warning otherwise (Suggested by log);
                         format CAFVCode cafvcodeFormat.;
      keylegend / title="CAFV"
                  position=ne 
                  location = inside
                  across = 1 
                  opaque;
      xaxis label = "% EV Type"
              values=(0 to 100 by 10)
              valueattrs = (size = 14pt)
              labelattrs = (size = 10pt)
              grid gridattrs=(color = cxf0f0f0 thickness = 2)
              ;     
      yaxis label = "EV Type" 
            valueattrs = (size = 12pt)
            labelattrs = (size = 10pt)
            ;
run;
title;
footnote;
ods layout end;

*PHASE 11: OUTPUT 11;
title &SubTitleOpts "Output 11";
title2 &Title2Opts "Comparative Boxplots for Electric Range";
title3 h=8pt "Excluding Missing or Non-US State Postal Codes";
footnote &footOpts "&IDStamp";
proc sgplot data= InputDS.FinalDugginsEV(where=(StateCode ne 'BC' and StateCode ne 'AP' AND not missing(StateCode))) ;
    vbox ERange / Category=StateCode group=StateCode groupdisplay=cluster grouporder=ascending;
    xaxis display=none offsetmin=0.07 offsetmax=0.07;
    keylegend / position=east across=2 title="State";
run;
title;
footnote;

*PHASE 12: OUTPUT 12;
ods pdf columns=2 startpage=now;;
title &SubTitleOpts "Output 12";
title2 &Title2Opts "Frequency of Masked VIN Under 70/30 Plan";
title3 &SubTitleOpts "Showing Only: Make = JEEP";
footnote &footOpts "&IDStamp";
proc freq data=InputDS.FinalDugginsUniqueVinMask (where=(Make="JEEP")) order=freq;
    tables MaskVin / nocum;
run;
title;
footnote;

*PHASE 13: OUTPUT 13;
ods pdf columns=1;
title &SubTitleOpts "Output 13";
title2 &Title2Opts "Listing of EV Makes and Models";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "Wow. This is just an awful table. Please don't ever make something like this ever again. Seriously. This is bad.";
proc report data=InputDS.FinalDugginsModels;
   columns ('Vehicle Make' Make) ('Models in Database' (Model:));
   define Make/ID '';
   define Model: / '';
run;
title;
footnote;

*PHASE 14 - OUTPUT 14;
title &SubTitleOpts "Output 14";
title2 &Title2Opts "Analyis of Electric Range and Base MSRP";
title3 &SubTitleOpts "Grouped by Model Year, EV Type*, and CAFV Eligibility";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Due to substantial differences between range for PHEV and BEV, pooled statistics should not be used for inferences";
proc report data=InputDS.FinalDugginsEV nowd;
   columns ModelYear EVTypeShort CAFVCode ('Electric Range' (ERange=ERangeMean ERange=ERangeStd ERange=ERangeCount)) 
                                          ('Base MSRP' (BaseMSRP=BaseMean BaseMSRP=BaseStd BaseMSRP=BaseCount));
   define ModelYear /group format=ModelYearFormat. order=internal;
   define EVTypeShort/group 'EV Type';
   define CAFVCode /group 'CAFV' format=cafvcodeFormat.;
   define ERange / analysis;
   define BaseMSRP /analysis;
   define ERangeMean / analysis mean 'Mean' format=comma11.1 ;
   define ERangeStd / analysis std 'Std. Dev.' format=comma11.2;
   define ERangeCount / analysis n 'Count' format=comma12. ;
   define BaseMean / analysis mean 'Mean' format=dollar11. ;
   define BaseStd / analysis std 'Std. Dev.' format=dollar11.;
   define BaseCount / analysis n 'Count' format=comma12. ;
   break after ModelYear / summarize;
run;
title;
footnote;

*PHASE 15: OUTPUT 15;
title &SubTitleOpts "Output 15";
title2 &Title2Opts "Analyis of Electric Range and Base MSRP";
title3 &SubTitleOpts "Grouped by Model Year, EV Type*, and CAFV Eligibility";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Due to substantial differences between range for PHEV and BEV, pooled statistics should not be used for inferences";
footnote3 &footOpts "Alternative Display: EV Type displays on all non-summary rows";
proc report data=InputDS.FinalDugginsEV nowd;
   columns ModelYear EVTypeShort FinalEVType CAFVCode ('Electric Range' (ERange=ERangeMean ERange=ERangeStd ERange=ERangeCount)) 
                                          ('Base MSRP' (BaseMSRP=BaseMean BaseMSRP=BaseStd BaseMSRP=BaseCount));
   define ModelYear / group order=internal format=ModelYearFormat.;
   define EVTypeShort / group noprint;
   define FinalEVType / computed 'EV Type' order=data;;
   define CAFVCode / group 'CAFV' format=cafvcodeFormat.;
   define ERange / analysis;
   define BaseMSRP / analysis;
   define ERangeMean / analysis mean 'Mean' format=comma11.1 ;
   define ERangeStd / analysis std 'Std. Dev.' format=comma11.2;
   define ERangeCount / analysis n 'Count' format=comma12. ;
   define BaseMean / analysis mean 'Mean' format=dollar11. ;
   define BaseStd / analysis std 'Std. Dev.' format=dollar11.;
   define BaseCount / analysis n 'Count' format=comma12. ;
   break after ModelYear / summarize;
   compute before EVTypeShort;
       DummyEVType = EVTypeShort;
    endcomp;
   compute FinalEVType /  length=25 character;
       if (_BREAK_='') then
          *If the break variable is empty, that is for non summary rows;
           FinalEVType = DummyEVType;
         else
            *Leaving it empty for summary rows;
            FinalEVType='';
   endcomp;
run;
title;
footnote;

*PHASE 16: OUTPUT 16;
title &SubTitleOpts "Output 16";
title2 &Title2Opts "Color-Coded Analyis of Electric Range and Base MSRP";
title3 &SubTitleOpts "Grouped by Model Year, EV Type*, and CAFV Eligibility";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Due to substantial differences between range for PHEV and BEV, pooled statistics should not be used for inferences";
footnote3 &footOpts "*Despite PHEV and BEV range differences, all color-coding uses BEV cutoffs.";
footnote4 &footOpts "Alternative Display: EV Type displays on all non-summary rows";
*Credit for styling elements: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/proc/p0xcdcilo2yuuwn1t9uks2c1e66e.htm;
proc report data=InputDS.FinalDugginsEV nowd
   style(lines)=[textalign=right color=white backgroundcolor=black];
   columns ModelYear EVTypeShort FinalEVType CAFVCode ('Electric Range' (ERange=ERangeMean ERange=ERangeStd ERange=ERangeCount)) 
                                          ('Base MSRP' (BaseMSRP=BaseMean BaseMSRP=BaseStd BaseMSRP=BaseCount));
   define ModelYear /group format=ModelYearFormat. order=internal;
   define EVTypeShort/group noprint;
   define FinalEVType / computed 'EV Type' order=data;;
   define CAFVCode /group 'CAFV' format=cafvcodeFormat.;
   define ERange / analysis;
   define BaseMSRP /analysis;
   define ERangeMean / analysis mean 'Mean' format=comma11.1 
                           style=[background=meanBEVFormat.];
   define ERangeStd / analysis std 'Std. Dev.' format=comma11.2;
   define ERangeCount / analysis n 'Count' format=comma12. ;
   define BaseMean / analysis mean 'Mean' format=dollar11. ;
   define BaseStd / analysis std 'Std. Dev.' format=dollar11.;
   define BaseCount / analysis n 'Count' format=comma12. ;
   break after ModelYear / summarize style=[color=black background=cxbdbdbd];
   compute before EVTypeShort;
       DummyEVType = EVTypeShort;
    endcomp;
   compute FinalEVType / character length=25;
       if (_BREAK_='') then
          *If the break variable is empty, that is for non summary rows;
           FinalEVType = DummyEVType;
         else
            *Leaving it empty for summary rows;
            FinalEVType='';
   endcomp;
   compute after;
      line 'Electric range-based coloring:<200, 200-250, 250-300, >300';
   endcomp;
run;
title;
footnote;

*PHASE 17: OUTPUT 17;
title &SubTitleOpts "Output 17";
title2 &Title2Opts "Color-Coded Analyis of Electric Range and Base MSRP";
title3 &SubTitleOpts "Grouped by Model Year, EV Type*, and CAFV Eligibility";
footnote &footOpts "&IDStamp";
footnote2 &footOpts "*Due to substantial differences between range for PHEV and BEV, pooled statistics should not be used for inferences";
footnote3 &footOpts "*BEV and PHEV rows use their respective cutoffs. Summary rows use BEV cutoffs.";
footnote4 &footOpts "Alternative Display: EV Type displays on all non-summary rows";
*Credit for styling elements: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/proc/p0xcdcilo2yuuwn1t9uks2c1e66e.htm;
proc report data=InputDS.FinalDugginsEV nowd
   style(lines)=[color=white backgroundcolor=black textalign=right];
   columns ModelYear EVTypeShort FinalEVType CAFVCode ('Electric Range' (ERange=ERangeMean ERange=ERangeStd ERange=ERangeCount)) 
                                          ('Base MSRP' (BaseMSRP=BaseMean BaseMSRP=BaseStd BaseMSRP=BaseCount));
   define ModelYear /group format=ModelYearFormat. order=internal;
   define EVTypeShort/group noprint;
   define FinalEVType / computed order=data 'EV Type' ;
   define CAFVCode /group 'CAFV' format=cafvcodeFormat.;
   define ERange / analysis;
   define BaseMSRP /analysis;
   define ERangeMean / analysis mean 'Mean' format=comma11.1;
   define ERangeStd / analysis std 'Std. Dev.' format=comma11.2;
   define ERangeCount / analysis n 'Count' format=comma12. ;
   define BaseMean / analysis mean 'Mean' format=dollar11. ;
   define BaseStd / analysis std 'Std. Dev.' format=dollar11.;
   define BaseCount / analysis n 'Count' format=comma12.;
   break after ModelYear / summarize style=[color=black background=cxbdbdbd];
    compute before EVTypeShort;
       DummyEVType = EVTypeShort;
    endcomp;
   compute FinalEVType / character length=25;
       if (_BREAK_='') then
            *If the break variable is empty, that is for non summary rows;
             FinalEVType = DummyEVType;
           else
              *Leaving it empty for summary rows;
              FinalEVType='';
   endcomp;
   compute ERangeMean;
       if FinalEVType = 'BEV' | not missing(_BREAK_) then
           call define(_COL_,'style','style=[background=meanBEVFormat.]');
       else if FinalEVType = 'PHEV' then
           call define(_COL_,'style','style=[background=phevformat.]');
  endcomp;
   compute after;
      line 'BEV range-based coloring:<200, 200-250, 250-300, >300';
      line 'PHEV range-based coloring:<25, 25-50, 50-75, >75';
   endcomp;
run;
title;
footnote;
*PHASE 18 - WRAPPING UP;
ods pdf close;
quit;
