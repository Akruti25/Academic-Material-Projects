/*
Programmed by: Akruti Sinha
Programmed to: Working on HW5
Last Modified on: 11.10.23
*/

*Setting up the working directory;
x "cd L:\st555\Data\";
libname InputDS ".";
filename RawData ".";

x "cd L:\st555\Results";
libname Results ".";

x "cd S:\ST555-Results\HW6-asinha6";
libname HW6 ".";
filename HW6 ".";

*Options setting;
ods pdf file = "HW6 Sinha IPUMS Report.pdf" dpi=300 startpage=never;
ods exclude none;
options nobyline;
options nodate;
ods listing image_dpi=300;
options fmtsearch = (HW6);

*macrovariables for mortagaged and contract.txt;
%let inputOptions = Serial Metro CountyFIPS $ MortPay: dollar6. HHI: dollar10. HomeVal: dollar10.;
%let attribOptions =  Serial          length=8   label="Household Serial Number"
                      Metro           length=8   label="Metro Status Code"
                      CountyFIPS      length=$3  label="County FIPS Code"
                      MortPay         length=8   label="Monthy Mortgage Payment"  format=dollar6.
                      HHI             length=8   label="Household Income"         format=dollar10.
                      HomeVal         length=8   label="Home Value"               format=dollar10.;
%let CompOpts = outbase outcompare outdiff outnoequal noprint 
                method = absolute criterion = 1E-15;
            
*STEP 1: READING ALL DATA ONE BY ONE;
*1A - Starting with Cities.txt;
data HW6.HW6SinhaCities;
     attrib City    length=$40 label="City Name"
            CityPop length=8   label="City Population (in 100s)" format=comma6.;
     infile RawData ("Cities.txt") dlm='09'x firstobs = 2 truncover;
     input City $ CityPop: comma6.;
     City = tranwrd(City, '/', '-');
run;
  
*1B - States.txt;
data HW6.HW6SinhaStates (drop=_:);
     attrib _SerialandState length=$30
            Serial          length=8   label="Household Serial Number"
            State           length=$20 label="State, District, or Territory"
            City            length=$40 label="City Name";
     infile RawData ("States.txt") dlm='09'x firstobs = 2 truncover;
     input _SerialandState $ City $;
     *cleaning the data;
     City = tranwrd(City, '/', '-');
     Serial = scan(_SerialandState, 1, '.');
     State = substr(_SerialandState, index(_SerialandState, '.') + 1);     
run;

*1C - contract.txt;
data HW6.HW6SinhaContract;
     attrib &attribOptions;
     infile RawData ("Contract.txt") dlm='09'x firstobs = 2 truncover;
     input &inputOptions;
run;

*1D - Mortgaged.txt;
data HW6.HW6SinhaMortgaged;
     attrib &attribOptions;
     infile RawData ("Mortgaged.txt") dlm='09'x firstobs = 2 truncover;
     input &inputOptions;
run;

*1E - Renters sas dataset;
data HW6.HW6SinhaRenters;
     set InputDS.Renters;
rename FIPS=CountyFIPS;
run;

*STEP2 - MERGE INTO ONE FINAL DATASET
*2A - Merge 'cities' and 'states' datasets ;
proc sort data=HW6.HW6SinhaCities; 
  by city; 
run;
proc sort data=HW6.HW6SinhaStates; 
  by city; 
run;
data HW6.CityAndStates;
  merge HW6.HW6SinhaCities HW6.HW6SinhaStates;
  by city;
run;

*2B - Creating a format for metrodesc;
proc format library = HW6;
  value MetroDesc 1 = 'Not in a Metro Area'
                  2 = 'In Central/Principal City'
                  3 = 'Not in Central/Principal City'
                  4 = 'Central/Principal Indeterminable'
                  other = 'Indeterminable';
run; 
*2C - Concatenating the 4 datasets + data cleaning;
data HW6.HousingData;
    attrib Serial          length=8   label="Household Serial Number"          
           CountyFIPS      length=$3  label="County FIPS Code"
           Metro           length=8   label="Metro Status Code" 
           MetroDesc       length=$32 label="Metro Status Description"
           CityPop         length=8   label="City Population (in 100s)" format=comma6.
           MortPay         length=8   label="Monthly Mortgage Payment"  format=dollar6.
           HHI             length=8   label="Household Income"         format=dollar10.
           HomeVal         length=8   label="Home Value"               format=dollar10.
           State           length=$20 label="State, District, or Territory"
           City            length=$40 label="City Name"
           MortStat        length=$45. label="Mortgage Status"
           Ownership       length=$6. label="Ownership Status";        
    *Set the four household datasets and create a variable based on the dataset source;
    set HW6.HW6SinhaContract(in=c) 
        InputDS.FreeClear(in=d) 
        HW6.HW6SinhaMortgaged(in=e) 
        HW6.HW6SinhaRenters(in=f);
    *Create the Ownership variable;
    if f=1 then Ownership = 'Rented';
    else Ownership = 'Owned';

    *Create the Mortgage Status variable;
    if c=1 then MortStat = 'Yes, contract to purchase';
    else if e=1 then MortStat = 'Yes, mortgaged/ deed of trust or similar debt';
    else if d=1 then MortStat = 'No, owned free and clear';
    else MortStat = 'N/A';

    *Create the MetroDesc variable without using conditional logic;
    MetroDesc = put(metro, MetroDesc.);

    *Set Home Value to .R for renters and .M for generic missing values;
    if f=1 then homeval = .R;
    else if homeval = 9999999 then homeval = .R;
    else if homeval = . then homeval = .M;
run;
*2D - Sorting for one final merge;
proc sort data=HW6.HousingData; 
  by Serial; 
run;
proc sort data=HW6.CityAndStates; 
  by Serial; 
run;
*2E - One final merge;
data HW6.HW6SinhaIpums2005;
    merge HW6.HousingData
          HW6.CityAndStates;
    by serial; 
run;

*STEP 3: VALIDATION ELECTRONICALLY;
*3A - Saving descriptor for future compare;
ods exclude all;
ods output position = HW6.HW6SinhaDesc(drop=member);
proc contents data = HW6.HW6SinhaIpums2005 varnum;
run;

*3B - Comparing the data;
proc compare base = Results.HW6DugginsIpums2005
             compare = HW6.HW6SinhaIpums2005
             out = HW6.DataDifference
             &CompOpts;
run;

*3C: COMPARING/VALIDATION OF DESCRIPTOR PORTIONS;
proc compare base = Results.HW6DugginsDesc 
             compare = HW6.HW6SinhaDesc
             out = HW6.DescDifference
             &CompOpts;
run;

*STEP 4: PRODUCING REPORT;
ods proctitle;
ods listing close;
*4A - First 2 pages;
title "Listing of Households in NC with Incomes Over $500,000";
proc report data=HW6.HW6SinhaIpums2005 nowd;
            where hhi > 500000 and State = 'North Carolina';
            columns city metro mortstat hhi homeval;
run;
title;

*4B - Pages 2-5; 
ods pdf select CityPop.BasicMeasures CityPop.Quantiles histogram
               MortPay.Quantiles
               HHI.BasicMeasures HHI.ExtremeObs
               HomeVal.BasicMeasures HomeVal.ExtremeObs
               MissingValues;
ods graphics / reset width = 5.5in;
proc univariate data = HW6.HW6SinhaIpums2005;
  var CityPop MortPay HHI HomeVal;
  histogram CityPop / kernel(c=0.79);
run;

*4C - Last page;
ods pdf startpage= now;
title "Distribution of City Population";
title2 "(For Households in a Recognized City)";
footnote j=left "Recognized cities have a non-zero value for City Population.";
proc sgplot data = HW6.HW6SinhaIpums2005 (where=(city ne 'Not in identifiable city (or size group)'));
           histogram CityPop / scale = proportion;
           density CityPop / type = kernel;
           xaxis label="City Population (in 100s)"
                 values=(0 to 80000 by 20000);
           yaxis display = (nolabel)
                 values=(0 to 0.25 by 0.05)
                 valuesformat = percent5.;
           keylegend / location = inside 
                        position = ne;
run;
title;
title2;
footnote;
*Panel graph;
title "Distribution of Household Income Stratified by Mortgage Status";
footnote j=left "Kernel estimate parameters were determined automatically.";
proc sgpanel data=HW6.HW6SinhaIpums2005 NOAUTOLEGEND;
             panelby MortStat / novarname;
             histogram hhi / scale=proportion;
             colaxis label='Household Income';
             rowaxis display=(nolabel)
                     values=(0 to 0.25 by 0.05)
                     valuesformat = percent7.;
run;
title;
footnote;
*Wrapping up everything;
ods trace off;
ods pdf close;
quit;
