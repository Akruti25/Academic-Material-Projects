/*
Programmed by: Akruti Sinha
Programmed on: 2023-10-28
Programmed to: Working on HW5
Last Modified on: 11.02.23
*/

*Setting up the working directory;
x "cd L:\st555\Data\";
libname InputDS ".";
filename RawData ".";

x "cd L:\st555\Results";
libname Results ".";

x "cd S:\ST555-Results\HW5-asinha6";
libname HW5 ".";
filename HW5 ".";

*Setting up macro variables and storing all attributes with inputOptions(for So2, CO, TSP);
%let inputOptions = _StName $ _JobID $ _DateAndRegion : $30. (Equipment Personnel)(: comma.);
%let CompOpts = outbase outcompare outdiff outnoequal noprint 
                method = absolute criterion = 1E-9;

*Set up options and all ods related options;
options fmtsearch = (Results InputDS);
*Adding nobylien to stop adding of polcode grouping;
options nobyline;
options nodate;
ods listing image_dpi=300;
*Adding startpage to prevent pagebreaks automatic;
ods pdf file = "HW5 Sinha Projects Graphs.pdf" dpi=300 startpage=never;
ods noproctitle;
ods trace on;

*STEP 1: READING ALL DATA ONE BY ONE;
data HW5.HW5SinhaTSP;
     infile RawData ("TSPProjects.txt") truncover dsd firstobs = 2;
     input &inputOptions;
run;

data HW5.HW5SinhaCO;
     infile RawData ("COProjects.txt") truncover dsd firstobs = 2;
     input &inputOptions;
run;

data HW5.HW5SinhaSO2;
     infile RawData ("SO2Projects.txt") truncover dsd firstobs = 2;
     input &inputOptions;
run;

data HW5.HW5SinhaO3;
     infile RawData ("O3Projects.txt") truncover dsd firstobs = 2;
     input _StName $ 
           _JobID $ 
           _DateAndRegion : $30. 
           _PolCodeAndType $ 
           (Equipment Personnel)(: comma.);
run;

*STEP 2: MERGING THE 5 DATASETS;
data HW5.SinhaMerged(label = 'Cleaned and Combined EPA Projects Data' drop=_:);
    *STEP 2A: SPECIFYING ATTRIBUTES AND SET (same flow as that in dugginsprojectsdesc);
     attrib StName     length=$2  label="State Name"
            Region     length=$9
            JobID      length=8
            Date       length=8   format=date9.
            PolType    length=$4  label="Pollutant Name"
            PolCode    length=$8  label="Pollutant Code"    
            Equipment  length=8   format=dollar11.    
            Personnel  length=8   format=dollar11.
            JobTotal   length=8   format=dollar11.;
     set Results.HW4DugginsLead(in=inLead)
          HW5.HW5SinhaTSP(in=inTSP)
          HW5.HW5SinhaCO(in=inCO)
          HW5.HW5SinhaSO2(in=inSO2)
          HW5.HW5SinhaO3(in=inO3);

     *STEP 2B: ADDING/FIXING POLCODE AND POLTYPE (first for O3 and then for others);
     if inO3 eq 1 then do;
         if substr(_PolCodeAndType,1,1) eq '5' then do;
              PolCode='5'; 
              PolType=substr(_PolCodeAndType,2);
             end;
           else do;
                PolCode=''; 
                PolType=_PolCodeAndType;
               end;
      end;
     if inCO eq 1 then do;
          PolCode = '3'; 
          PolType = 'CO';
         end;
       else if inSO2 eq 1 then do;
            PolCode = '4'; 
            PolType = 'SO2';
           end;
         else if inTSP eq 1 then do;
              PolCode = '1'; 
              PolType = 'TSP';
            end;

      *STEP 2C: CLEANING THE DATA IN ONE SINGLE STEP;
      if inLead ne 1 then do;
            StName= upcase(_StName);
            Region = propcase(compress(_DateAndRegion,,'d'));
            Date = input(compress(_DateAndRegion,,'a'),5.);
            *fixing the 0 and 1 in jobid;
            JobID= input(tranwrd(tranwrd(_JobID,'l','1'),'O','0'),5.);
            *Avoiding the missing values note: not computing jobtotal when equip and personnel is missing;
            if equipment eq '' and personnel eq '' then JobTotal='';
               else
                JobTotal= sum(Equipment,Personnel);    
        end;
run;
  
*STEP 3: SORTING THE DATA AND STORING IN SINHAPROJECTS;
proc sort data=HW5.SinhaMerged out=HW5.HW5SinhaProjects;
     by PolCode Region descending JobTotal descending date JobID;
run;

*STEP 4A: SAVING DESCRIPTIOR PORTION FOR LATER VALIDATION;
ods exclude all;
ods output position = HW5.HW5SinhaProjectsDesc(drop=member);
proc contents data = HW5.HW5SinhaProjects varnum;
run;

*STEP 4B: COMPARING/VALIDATION OF DATA;
proc compare base = Results.HW5DugginsProjects 
             compare = HW5.HW5SinhaProjects
             out = HW5.DataDifference
             &CompOpts;
run;

*STEP 4C: COMPARING/VALIDATION OF DESCRIPTOR PORTIONS;
proc compare base = Results.HW5DugginsProjectsDesc 
             compare = HW5.HW5SinhaProjectsDesc
             out = HW5.DescDifference
             &CompOpts;
run;

*STEP 5A: GRAPH DATA OPTIONS SAVED VIA PROC MEANS;
ods exclude summary;
ods output Summary = HW5.HW5SinhaSummary;
proc means data = HW5.HW5SinhaProjects(where = (not missing(PolCode) and not missing(Region))) q1 q3;
     by PolCode;
     class Region Date;
     var JobTotal;
     format Date MyQtr.;
run;

*STEP 5B: MAKING THE BAD PLOTS AND SPECIFYING THE OPTIONS FOR IT;
ods listing image_dpi = 300;
ods graphics / reset width = 6in imagename = "HW5SinhaBadPlot";
title "25th and 75th Percentiles of Total Job Cost";
title2 "By Region and Controlling for Pollutant = #byval1";
title3 h=8pt "Exluding Records where Region was Unknown (Missing)";
footnote j=left "Bars are labeled with the number of jobs contributing to each bar";
proc sgplot data = HW5.HW5SinhaSummary;
      by polcode;
      vbar Region / response = JobTotal_q3
                    group = Date 
                    groupdisplay = cluster
                    grouporder = ascending
                    nooutline
                    datalabel = nobs datalabelattrs = (size = 7pt)
                    name = 'SinhaBadPlot1'
                    ;
      vbar Region / response = jobtotal_q1
                    group = Date 
                    groupdisplay = cluster
                    grouporder = ascending
                    nooutline
                    name = 'SinhaBadPlot2'
                    ;
      styleattrs datacolors = (cx1b9e77 cxd95f02 cx7570b3 cxe7298a cx525252 cx525252 cx525252 cx525252);
      xaxis display = (nolabel);
      yaxis display = (nolabel);
      keylegend 'SinhaBadPlot1' / location = outside position = top;
      format polcode $polmap. 
             jobtotal: dollar6.;
run;
title;
footnote;

*STEP 5C: MAKING THE GOOD PLOTS AND SPECIFYIN THE OPTIONS FOR IT; 
ods listing image_dpi = 300;
ods graphics / reset width = 6in imagename = "HW5SinhaGoodPlot";
title "25th and 75th Percentiles of Total Job Cost";
title2 "By Region and Controlling for Pollutant = #byval1";
title3 h=8pt "Excluding Records where Region was Unknown (Missing)";
footnote j=left "Bars are labeled with the number of jobs contributing to each bar";
proc sgplot data = HW5.HW5SinhaSummary;
     by polcode;
     highlow x=region low=JobTotal_q1 high=JobTotal_q3 / type=bar
          group = Date 
          groupdisplay = cluster
          grouporder = ascending      
          type = bar
          highlabel = nobs
          labelattrs = (color = black)
          lineattrs = (color = black)
          ;
     styleattrs datacolors = (cx1b9e77 cxd95f02 cx7570b3 cxe7298a cx525252 cx525252 cx525252 cx525252);
     xaxis display = (nolabel);
     yaxis display = (nolabel) grid gridattrs=(color = cxbdbdbd thickness = 3) offsetmax = 0.125;
     keylegend / location = inside position = top title = 'Date';
     format polcode $polmap. 
            jobtotal: dollar6.;
run;
title;
footnote;

*STEP 6: WRAPPING UP AND CLOSING EVERYTHING;
ods trace off;
ods pdf close;
quit;
