/*
Programmed by: Akruti Sinha
Programmed to: Working on Final Phase 1 Project
Last Modified on: 11.28.23
*/

*Setting up working directories;
x "cd L:\st555\Data\WashingtonState\RawData ";
libname InputDS ".";
filename RawData ".";

x "cd L:\st555\Data\WashingtonState\FormatCatalogs";
libname Formats ".";

x "cd L:\st555\Results\";
libname Results ".";

x "cd S:\ST555-Results\Final";
libname Final ".";
filename Final ".";

*Setting up options;
options fmtsearch = (Formats);

*PHASE 1- READING IN DATA;
*1A - UNKNOWN DATASET;
*Setting up format for month names;
proc format;
  value $MonthNameToNumeric
    'January' = 1
    'February' = 2
    'March' = 3
    'April' = 4
    'May' = 5
    'June' = 6
    'July' = 7
    'August' = 8
    'September' = 9
    'October' = 10
    'November' = 11
    'December' = 12
    other = .;
run;
data Final.UnknownDataset(keep = Vin Zip LegDist DOLID CensusTract RegDate ElecUtil location);
  infile RawData("EV-CAFV(unk).txt") dlm=';' dsd firstobs=12;
  length VIN $10 
         Zip1-Zip250 $5 
         LegDist1-LegDist250 $2
         DOLID1-DOLID250 $9 
         CensusTract1-CensusTract250 $11
         UnknownDate1-UnknownDate250 $20 
         ElecUtil1-ElecUtil250 $200
         Location1-Location250 $45;
  input  VIN $ Zip1-Zip250 $ LegDist1-LegDist250 $ DOLID1-DOLID250 $ CensusTract1-CensusTract250 $ UnknownDate1-UnknownDate250 $ ElecUtil1-ElecUtil250 $Location1-Location250 $;
  *Defining Arrays;
  array ZipArr[*] Zip:;
  array LegDistArr[*] LegDist:;
  array DOLIDArr[*] DOLID:;
  array CensusTractArr[*] CensusTract:;
  array UnknownDateArr[*] UnknownDate:;
  array ElecUtilArr[*] ElecUtil:;
  array locationArr[*] location:;
  *Loop to reshape data;
  do i = 1 to dim(ZipArr);
      if (not missing(ZipArr[i]) | not missing(LegDistArr[i])
              | not missing(DOLIDArr[i]) | not missing(CensusTractArr[i])
              | not missing(UnknownDateArr[i]) | not missing(ElecUtilArr[i]) 
              | not missing(LocationArr[i])) then do;
          Zip = ZipArr[i];
          LegDist = LegDistArr[i];
          DOLID = DOLIDArr[i];
          CensusTract = CensusTractArr[i];
          UnknownDate = UnknownDateArr[i];
          ElecUtil = ElecUtilArr[i];
          Location = LocationArr[i];
          *Turning the dates in words to SAS formatted dates;
          MonthName = scan(UnknownDate, 1, ' ');
          Day = input(scan(UnknownDate, 2, ' ,'), 3.);
          Year = input(scan(UnknownDate, 3, ' '), 4.);
          MonthNumeric = put(MonthName, $MonthNameToNumeric.);
          RegDate = mdy(MonthNumeric, Day, Year);
          format RegDate YYMMDD10.;
        output;
      end;
  end;
run;

*1B - YES DATASET;
data Final.YesDataset;
  attrib VIN              length=$10  label="Vehicle Identification Number"               format=$10. 
         Zip              length=$5   label="Vehicle Registration Zip Code"
         LegDist          length=$2   label="Vehicle Registration Legislative District"
         DOLID            length=$9   label="WA Department of Licensing ID"               format=$9.
         CensusTract      length=$11  label="Vehicle Registration US Census Tract"
         RegDate          length=8    label="Last Registration Date"                      format=YYMMDD10.
         ElecUtil         length=$200 label="Electric Utilities Servicing Vehicle Registration Address"
         _Location        length=$45  
        ;
  infile RawData("EV-CAFV(yes).txt") dlm="092c"x dsd truncover firstobs=6;
  input VIN: $10. Zip $ LegDist $ DOLID: $9. CensusTract $ RegDate: YYMMDD10. ElecUtil $ _Location $;
run;

*1C - NO DATASET;
data Final.NoDataset;
  attrib VIN              length=$10  label="Vehicle Identification Number"             format=$10. 
         Zip              length=$5   label="Vehicle Registration Zip Code"
         LegDist          length=$2   label="Vehicle Registration Legislative District"
         DOLID            length=$9   label="WA Department of Licensing ID"             format=$9.
         CensusTract      length=$11  label="Vehicle Registration US Census Tract"
         RegDate          length=8    label="Last Registration Date"                    format=YYMMDD10.
         ElecUtil         length=$200 label="Electric Utilities Servicing Vehicle Registration Address"
         _Location        length=$45 ;
  infile RawData("EV-CAFV(no).txt") dsd firstobs=8;
  input #1 VIN $1-10 Zip $11-15 LegDist $16-17 DOLID $18-26 CensusTract $28-38 RegDate: 39-46 
        #2 ElecUtil: $200.
        #3 _Location: $45.;
run;

*PHASE 2- CREATING IN ALLCAFV DATASET;
data Final.AllCAFV;
     attrib VIN              length=$10  label="Vehicle Identification Number" format=$10. 
            Zip              length=$5   label="Vehicle Registration Zip Code"
            ZipN             length=8    label="Vehicle Registration Zip Code" format=z5.
            LegDist          length=$2   label="Vehicle Registration Legislative District"
            DOLID            length=$9   label="WA Department of Licensing ID" format=$9.
            CensusTract      length=$11  label="Vehicle Registration US Census Tract"
            RegDate          length=8    label="Last Registration Date"        format=YYMMDD10.
            CAFV             length=$60  label="Clean Alternative Fuel Vehicle Eligible Description"
            CAFVCode         length=8    label="Clean Alternative Fuel Vehicle Eligible (1=Y,2=N,3=U)"
            ElecUtil         length=$200 label="Electric Utilities Servicing Vehicle Registration Address"
            _Location        length=$45;
   set Final.YesDataset(in=inYes)
       Final.NoDataset(in=inNo)
       Final.UnknownDataset(in=inUnknown);
   *Putting in CAFV and CAFVCode;
   ZipN = input(Zip, 5.);
   if inYes = 1 then do;
      CAFV = "Clean Alternative Fuel Vehicle Eligible";
      CAFVCode = 1;
      end;
    else if inNo = 1 then do;
        CAFV = "Not eligible due to low battery range";
        CAFVCode = 2;
        end;
      else if inUnknown=1 then do;
          CAFV = "Eligibility unknown as battery range has not been researched";
          CAFVCode = 3;
          end;
run;

*PHASE 3 - MERGING THE ALLCAFV DATASET WITH ACCESS FILES DATASET;
libname AccData access "L:\st555\Data\WashingtonState\StructuredData\LookUp.accdb";

*3A: Merging with Non-demographics Registrations dataset - Sort first, merge second;
proc sort data=Final.AllCAFV;
    by DOLID;
run;
data Final.CAFDemNo;
    merge Final.AllCAFV AccData."Non-Domestic Registrations"n;
    by DOLID;
run;

*3B: Merging with Demographics dataset - Sort first, merge second;
proc sort data=Final.CAFDemNo;
    by VIN;
run;
*Making the penultimate dataset;
data Final.Penult;
    merge Final.CAFDemNo (in=inCAFNODEM) AccData.Demographics (in=inDEM);
    by VIN;
    if inCAFNODEM = 1 and inDEM = 1;
run;
*Clearing libname;
libname AccData clear;

*PHASE 4: CREATING THE FINALEV DATASET FROM THE PENULT(IMATE) DATASET by combining with SASHELP.ZIP;
*4A: Sorting the dataset to do the final merge;
proc sort data=Final.Penult;
    by zipN;
run;
*4B: FINAL EV DS;
data Final.FinalSinhaEV;
  attrib  Vin              length=$10  label="Vehicle Identification Number"                  format=$10.  informat=$10.
          MaskVin          length=$10  label="Partially Masked VIN"
          Zip              length=$5   label="Vehicle Registration Zip Code"
          ZipN             length=8    label="Vehicle Registration Zip Code"                  format=z5.
          CityName         length=$35  label="City Name"
          StateFips        length=8    label="State FIPS"
          StateCode        length=$2   label="State Postal Code"
          StateName        length=$25  label="State Name"
          CountyFips       length=8    label="County FIPS"
          CountyName       length=$25  label="County Name"
          LegDist          length=$2   label="Vehicle Registration Legislative District"
          DOLID            length=$9   label="WA Department of Licensing ID"                  format=$9.   informat=$9.
          CensusTract      length=$11  label="Vehicle Registration US Census Tract"
          RegDate          length=8    label="Last Registration Date"                         format=YYMMDD10.
          ModelYear        length=8    label="Vehicle Model Year"
          EVType           length=$50  label="EV Type (long)"                                 format=$50.  informat=$50.
          EVTypeShort      length=$4   label="EV Type (short)"
          Erange           length=8    label="Electric Range"
          BaseMSRP         length=8    label="Reported Base MSRP"
          Make             length=$20  label="Vehicle Make"
          Model            length=$25  label="Vehicle Model"
          CAFV             length=$60  label="Clean Alternative Fuel Vehicle Eligible Description"
          CAFVCode         length=8    label="Clean Alternative Fuel Vehicle Eligible (1=Y, 2=N, 3=U)"
          ElecUtil         length=$200 label="Electric Utilities Servicing Vehicle Registration Address"
          PrimaryUtil      length=$200 label="Primary Electric Utility at Vehicle Location"
          Latitude         length=8    label="Vehicle Registration Latitude (decimal)"        format=13.8
          Longitude        length=8    label="Vehicle Registration Longitude (decimal)"       format=13.8
          ;
  merge Final.Penult (in=inPenult) SAShelp.Zipcode(rename=(zip=zipN State=StateFIPS City=CityName Countynm=CountyName County=CountyFIPS ));
  by ZipN;
  if inPenult = 1;
  keep Vin MaskVin Zip ZipN CityName StateFips StateCode StateName CountyFIPS CountyName LegDist DOLID CensusTract RegDate ModelYear EVType EVTypeShort ERange BaseMSRP Make Model CAFV CAFVCode ElecUtil PrimaryUtil Latitude Longitude;
  *Data Cleaning and Adding new variables;
  *Creating MaskVin by using cats;
  maskvin = cats('*******', substr(VIN, 8));
  *Creating EVTypeShort - Last word extract + remove () + remove any spaces;
  EVTypeShort = compress(tranwrd(scan(EVType, -1, ' '), '()', ''));
  *Creating Primary Util;    
  PrimaryUtil = scan(ElecUtil, 1, '|');
  *Creating State Name;
  if ST eq 'AP' then StateName = 'Armed Forces Pacific';
    else if ST eq 'BC' then StateName= 'British Columbia';
  *Creating BASEMSRP;
  if BaseMSRP = . then BaseMSRP = .M;
    else if BaseMSRP < 0 then BaseMSRP = .I;
      else if BaseMSRP = 0 then BaseMSRP = .Z;
  *Creating latitude and longitude from location;
  if not missing(_Location) then do;
      Longitude = input(scan(scan(_Location, 2, '('),1,''),13.8);
      Latitude = input(tranwrd(scan(scan(_Location, 2, '('),2,''),')',''),13.8);
      format Longitude Latitude 13.8;  
    end;
  *Creating/Formatting Make and Model;
  Make = input(MakeCat, $evmake.);
  Model = input(ModelCat, $evmodel.);
  *Renaming CensusTract to CensusTract2020 to match metadata;
  rename CensusTract=CensusTract2020;
run;

*PHASE 5: CREATING SINHAMODELS DATASET FROM FINALEV;
proc sort data=Final.FinalSinhaEV out=Final.ModelSort NODUPKEY;
    by Make Model;
run;
proc transpose data=Final.ModelSort out=Final.FinalSinhaModels(drop=_name_ _LABEL_) prefix=Model;
    by Make;
    var Model;
run;

*PHASE 6: CREATING UNIQUEVINMASK DATASET FROM FINALEV;
proc sort data=Final.FinalSinhaEV out=Final.FinalSinhaUniqueVinMask NODUPKEY;
    by VIN;
run;

*PHASE 7: CREATING CAFVCROSSEV DATASET FROM FINALEV;
ods output crosstabfreqs=Final.FinalSinhaCAFVCROSSEV(keep=CAFVCode EVTypeShort _TYPE_ Percent RowPercent ColPercent
                                                     where=(not missing(CAFVCode) and not missing(EVTypeShort)));
proc freq data=Final.FinalSinhaEV;
    tables CAFVCode*EVTypeShort;
run;

*PHASE 8: WRAPPING UP;
quit;
