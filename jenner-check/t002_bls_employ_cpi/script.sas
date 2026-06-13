/* ----------------------------------------------------------------------------
   Source: PDND/divpremmonth.sas  (Baker-Wurgler Investor Sentiment Index)
   BLS macroeconomic-series ingestion (program lines 570-638), preserved as
   written: tab-delimited INFILE reads of total nonfarm employment (CES) and
   the all-items CPI (CUSR), the MMM->numeric-month parse, the series filters,
   the year/month merge, and the PROC FREQ checks. In production these read the
   BLS flat files; here the same reader logic runs against a small embedded
   sample (one year of monthly observations) supplied through DATALINES.
   Original data source, per the program's comments:
     https://download.bls.gov/pub/time.series/ce/ce.data.00a.TotalNonfarm.Employment
     http://download.bls.gov/pub/time.series/cu/cu.data.1.AllItems
   ---------------------------------------------------------------------------- */

data work.cees;
infile datalines lrecl = 120 dlm = '09'x pad missover firstobs = 2;
  length Series $16
         Year    8
	     MMM    $3
		 MM      8
	     EMPLOY   8;
informat Series $16.
         Year    4.0
	     MMM    $3.
	     EMPLOY comma16.0;
   input Series
         Year
	     MMM
	     EMPLOY ;
mm = input(substr(mmm,2,2),2.0);

if Series =: "CES0000000001";
datalines;
series_id	year	period	value
CES0000000001	2023	M01	155073
CES0000000001	2023	M02	155384
CES0000000001	2023	M03	155607
CES0000000001	2023	M04	155884
CES0000000001	2023	M05	156165
CES0000000001	2023	M06	156414
CES0000000001	2023	M07	156593
CES0000000001	2023	M08	156761
CES0000000001	2023	M09	156947
CES0000000001	2023	M10	157108
CES0000000001	2023	M11	157290
CES0000000001	2023	M12	157506
CES2000000001	2023	M01	8000
;
run;
quit;
proc freq data = work.cees;
  tables series;
run;
quit;

data work.cusr;
infile datalines lrecl = 120 dlm = '09'x pad missover firstobs = 2;
  length Series $16
         Year    8
	     MMM    $3
		 MM      8
	     CPI     8;
informat Series $16.
         Year    4.0
	     MMM    $3.
	     CPI     comma16.0;
   input Series
         Year
	     MMM
	     CPI ;
mm = input(substr(mmm,2,2),2.0);

if Series = "CUSR0000SA0";
datalines;
series_id	year	period	value
CUSR0000SA0	2023	M01	300536
CUSR0000SA0	2023	M02	301509
CUSR0000SA0	2023	M03	301744
CUSR0000SA0	2023	M04	302695
CUSR0000SA0	2023	M05	303294
CUSR0000SA0	2023	M06	303841
CUSR0000SA0	2023	M07	304348
CUSR0000SA0	2023	M08	305691
CUSR0000SA0	2023	M09	307051
CUSR0000SA0	2023	M10	307531
CUSR0000SA0	2023	M11	308024
CUSR0000SA0	2023	M12	308742
CUUR0000SA0	2023	M01	299170
;
run;
quit;
proc freq data = work.cusr;
  tables series;
run;
quit;

data work.cees_cusr;
 merge work.cees
       work.cusr;
 by year mm;
 if year >= 1958;
run;
quit;

proc print data = work.cees_cusr;
  var year mm employ cpi;
run;
