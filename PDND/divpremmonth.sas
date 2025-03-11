/*
-----------------------------------------------------------------------------------
File: divpremmonth.sas
Author(s): James Zeitler 
Description: Pulls Data from WRDS and calculates PDND for the Sentiment Index 
Output: 
	-EMPLOY_CPI 
	-NYSE_MSIA
	-premium (NOTE: this is the output file with PDND)

Notes: 
	This is updaed code from 2022 for the Baker-Wurgler Sentiment Index.
	It creates the "PDND" sentiment proxy and exports that. (PDND is used as input for other code to calculate the sentiment index)

Daniel Mangoubi (updated code 5/9/2024; 3/11/2025)
Dmangoubi@hbs.edu 
-----------------------------------------------------------------------------------
*/

* divpremmonth_jaz_20210111.sas *         ;
signoff wrds;
run;
proc datasets library = work kill;
run;
quit;
%let ldir = C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for 2025\SAS Output;
%let cees = &ldir.\EMPLOY_CPI_20210111.xlsx;
%let premium = &ldir.\premium_20210111.xlsx;
%let msia = &ldir.\NYSE_MSIA_20210111.xlsx;
%put &ldir.;
%put &cees.;
%put &premium.;
%put &msia.;
* %let cees = O:\Data\BRS\JZeitler\James\Afac\MBaker\InvestorSentiment\202012\EMPLOY_CPI_20210111.xlsx;
* %let premium = O:\Data\BRS\JZeitler\James\Afac\MBaker\InvestorSentiment\202012\premium_20210111.xlsx;
* %let msia = O:\Data\BRS\JZeitler\James\Afac\MBaker\InvestorSentiment\202012\NYSE_MSIA_20210111.xlsx;
options nocenter errors = 1;
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
 options comamid=TCP remote=WRDS;
 signon username=_prompt_;
 libname outputr '/home/harvard/dmangoubi' server = wrds;
 libname workr slibref=work server=wrds;
 libname rcrspq slibref=crspq server=wrds;
 libname rcomp slibref = compd server = wrds;
run;
quit;
/* -------------------------------------------------------------------------------------------------------------------- */
/*
/* Program name: ws.sas
/*
/* 	This program assembles data from Compustat and CRSP to match Worldscope.
/*
/* -------------------------------------------------------------------------------------------------------------------- */
rsubmit;
OPTIONS MPRINT NODATE NOCENTER NONUMBER PS=MAX LS=MAX;
/*
LIBNAME output '/sastemp1/mbaker';
LIBNAME input 'input';
LIBNAME input2 '/projects/harvard/mbaker/test';
*/
LIBNAME output '/home/harvard/dmangoubi';
endrsubmit;
rsubmit;
/* -------------------------------------------------------------------------------------------------------------------- */
/* A-1. Data checking macros
/* -------------------------------------------------------------------------------------------------------------------- */

* a. Basic contents ;

%MACRO lookatdata (dbase);

PROC CONTENTS DATA=&dbase; RUN;
PROC PRINT DATA=&dbase(OBS=100); RUN;
PROC MEANS DATA=&dbase; RUN;

%MEND lookatdata;

%lookatdata (compd.funda);
%lookatdata (crspq.msf);
%lookatdata (crspq.mse);
%lookatdata (crspq.ccmxpf_linktable);
endrsubmit;

*%lookatdata (output.crspgibbs05);

rsubmit;

/* -------------------------------------------------------------------------------------------------------------------- */
/* B-1. Prepare databases (CRSP Link, CRSP Codes, COMPUSTAT) to be merged
/* -------------------------------------------------------------------------------------------------------------------- */

* a. Create link table between CRSP and Compustat, rename to match Worldscope ;
DATA crsp;
	SET crspq.msf;
	crspme = abs(prc*shrout);
	KEEP permno date crspme;
/*
DATA cstlink;
	SET crspq.ccmxpf_lnkhist;
	* WRDS: ccmxpf_linktable superseded by ccmxpf_lnkhist *;
	IF linkenddt*1=. THEN linkenddt=mdy(12,31,2035);
	permno = lpermno;
	if linktype in("LC","LU","LS") then usedflag = 1;
	else usedflag = 0;
	* In ccmxpf_lnkhist LPERMNO rather than NPERMNO *;
	KEEP permno gvkey linkdt linkenddt linktype usedflag;
*/
DATA cstlink ;
	SET crspq.ccmxpf_lnkused (rename = (upermno    = permno
                                        ugvkey     = gvkey
                                        uiid       = iid
                                        ulinkprim  = linkprim
                                        ulinktype  = linktype
                                        ulinkid    = linkid
						                upermco    = permco
						                ulinkdt    = linkdt
						                ulinkenddt = linkenddt));
	* WRDS: ccmxpf_linktable superseded by ccmxpf_lnkhist *;
	IF linkenddt*1=. THEN linkenddt=mdy(12,31,2035);
*	permno = lpermno;
*	if linktype in("LC","LU","LS") then usedflag = 1;
*   else usedflag = 0;
	* In ccmxpf_lnkhist LPERMNO rather than NPERMNO *;
	KEEP permno gvkey linkdt linkenddt linktype usedflag;

PROC SQL;
	CREATE TABLE gvkeymerge AS
	SELECT A.date, A.permno, A.crspme, B.gvkey, B.linktype, B.usedflag
	FROM crsp A, cstlink B
	WHERE A.permno=B.permno AND B.linkdt<=A.date<=B.linkenddt;

PROC SORT DATA=gvkeymerge;
	BY permno date DESCENDING usedflag;

DATA gvkeymerge;
	SET gvkeymerge;
	IF ~(permno=lag(permno) AND date=lag(date) AND lag(usedflag)=1) AND 
	   ~(permno=lag2(permno) AND date=lag2(date) AND lag2(usedflag)=1) AND
	   ~(permno=lag3(permno) AND date=lag3(date) AND lag3(usedflag)=1);
	keep = (linktype~="LD" AND linktype~="LX");

PROC SORT DATA=gvkeymerge;
	BY permno date keep;

DATA output.linktable;
	SET gvkeymerge;
	BY permno date keep;
	IF last.date;
	yrmo = year(date)*100+month(date);
	year = year(date);
	KEEP permno yrmo gvkey;
endrsubmit;

rsubmit;
* b. Create a dataset with company name and industry - could also be used for share code and exchange ;

DATA crspdata;
	SET crsp.mse;
	IF shrcd~=. AND siccd~=. AND exchcd~=.;
	year = year(date);
	KEEP permno year date shrcd siccd exchcd comnam ticker;

PROC SORT DATA=crspdata;
	BY permno year;

DATA lastcrsp;
	SET crspdata;
	BY permno year;
	IF first.permno;
	hshrcd = shrcd;
	hsiccd = siccd;
	hexchcd = exchcd;
	hcomnam = comnam;
	hticker = ticker;
	KEEP permno hshrcd hsiccd hexchcd hcomnam hticker;

DATA crspdata;
	SET crspdata;
	BY permno year date;
	IF last.year;
	KEEP permno year shrcd siccd exchcd comnam ticker;

DATA crsp;
	SET crsp.msf;
	year = year(date);
	KEEP permno year;

PROC SORT DATA=crsp NODUPKEY;
	BY permno year;

DATA crspdata;
	MERGE crsp (IN=incrsp) crspdata;
	BY permno year;
	IF incrsp;

DATA crspdata;
	MERGE crspdata (IN=incrsp) lastcrsp;
	BY permno;
	IF incrsp;
endrsubmit;

rsubmit;
* b1. Fill in CRSP data ;

DATA crspdata;
	SET crspdata;
	BY permno year;
	RETAIN siccd1 shrcd1 exchcd1 comnam1 ticker1;
	IF first.permno THEN DO; siccd1 = hsiccd; shrcd1 = hshrcd; exchcd1 = hexchcd; comnam1 = hcomnam; ticker1 = hticker; END;
	IF siccd~=. THEN siccd1 = siccd;
	IF shrcd~=. THEN shrcd1 = shrcd;
	IF exchcd~=. THEN exchcd1 = exchcd;
	IF comnam~="" THEN comnam1 = comnam;
	IF ticker~="" THEN ticker1 = ticker;
	DROP siccd shrcd exchcd comnam ticker;

DATA output.codes;
	SET crspdata;
	shrcd = shrcd1;
	siccd = siccd1;
	exchcd = exchcd1;
	comnam = comnam1;
	ticker = ticker1;
	company = comnam;
	KEEP permno year company siccd shrcd exchcd;

PROC MEANS;
run;
quit;
endrsubmit;

rsubmit;
* c. Set annual Compustat data, rename to match Worldscope ; 

DATA output.allworld;
SET compd.funda;

* Replace new variable names with old ;
*************************************************** ;
data6 = AT;
data10 = PSTKL;
data25 = CSHO;
data26 = DVPSX_F;
data35 = TXDITC;
data56 = PSTKRV;
data60 = CEQ;
data130 = PSTK;
data181 = LT;
data199 = PRCC_F;
data216 = SEQ;
* data330 = PRBO;
zlist = EXCHG;
*************************************************** ;

IF fyr = 0 THEN fyr = .;
year = fyear;
IF fyr>0 AND fyr <= 5 THEN year = fyear+1;
csyrmo = year*100+fyr;
yrmo = csyrmo;
IF data10~=. THEN pstock = data10;
IF pstock = . AND data56~=. THEN pstock = data56;
IF pstock = . THEN pstock = data130;
IF data216~=. THEN se = data216;
IF se = . AND data60~=. AND data130~=. THEN se = data60+data130;
IF se = . THEN se = data6-data181;

a = data6;
* be = se-pstock+data35-sum(data330,0);
be = se-pstock+data35;
me = data199*data25;
v = data6-be+me;
payer = (data26>0);
IF a*1>0.5 AND be~=. AND me~=. AND data26~=.;

KEEP yrmo csyrmo gvkey a be me v payer;

* c1. Eliminate true duplicates: Same on all annual items ;

PROC SORT DATA=output.allworld NODUPKEY;
BY yrmo csyrmo gvkey a be me v payer;

PROC MEANS;


endrsubmit;

rsubmit;
* d. Set CRSP data, rename to match Worldscope ;

DATA allreturn;
	SET crspq.msf;
	yrmo = year(date)*100+month(date);
	year = year(date);
	cap = abs(prc)*shrout;
	price = abs(prc);
	num_shares = shrout;
	KEEP permno year yrmo cap price num_shares ret;

* d1. Eliminate true duplicates: Same on all monthly items ;

PROC SORT DATA=allreturn NODUPKEY;
	BY permno year yrmo cap price num_shares ret;

* d2. Merge on extra variables ;

DATA output.allreturn;
	MERGE allreturn (IN=inall) output.codes;
	BY permno year;
	IF inall;

PROC MEANS;

* e. Expand linktable to include wsyrmo ;

DATA return;
	SET output.linktable;

DATA world;
	SET output.allworld;
	KEEP gvkey csyrmo yrmo;

PROC SORT DATA=return;
	BY gvkey yrmo;

PROC SORT DATA=world;
	BY gvkey yrmo;

* e1. Merge data by SEDOL YRMO ;

DATA link;
	MERGE world (IN=inw) return (IN=inr);
	BY gvkey yrmo;
	inworld = inw;
	inreturn = inr;

* e2. Carry forward Worldscope matching information on YRMO WS_SEDOL ;

DATA link(DROP=csyrmo);
	SET link;
	BY gvkey yrmo;
	RETAIN csyrmok csyrmok1;
	IF first.gvkey THEN DO; csyrmok = csyrmo; csyrmok1 = .; END;
	IF csyrmo~=. THEN DO; csyrmok1 = csyrmok; csyrmok = csyrmo; END;

* e3. Limit carry forward to start 4 months after match and end 15 months after match ;

DATA output.linktable (KEEP=yrmo permno csyrmo gvkey);
	SET link;
	BY gvkey yrmo;
	RETAIN csyrmo gvkey lag;
	IF first.gvkey THEN csyrmo = .;
	IF csyrmok1~=. AND (int(yrmo/100)-1900)*12+yrmo-int(yrmo/100)*100>(int(csyrmok1/100)-1900)*12+csyrmok1-int(csyrmok1/100)*100+3 THEN DO; csyrmo = csyrmok1; lag = 1; END;
	IF csyrmok~=. AND (int(yrmo/100)-1900)*12+yrmo-int(yrmo/100)*100>(int(csyrmok/100)-1900)*12+csyrmok-int(csyrmok/100)*100+3 THEN DO; csyrmo = csyrmok; lag = 0; END;
	IF lag = 1 AND (csyrmok1=. OR (int(yrmo/100)-1900)*12+yrmo-int(yrmo/100)*100>(int(csyrmok1/100)-1900)*12+csyrmok1-int(csyrmok1/100)*100+15) THEN csyrmo = .; 
	IF lag = 0 AND (csyrmok=. OR (int(yrmo/100)-1900)*12+yrmo-int(yrmo/100)*100>(int(csyrmok/100)-1900)*12+csyrmok-int(csyrmok/100)*100+15) THEN csyrmo = .; 
	IF inreturn;

PROC MEANS;

* f. Calculate dividend premium by month ;

DATA linktable;
	SET output.linktable;

DATA world;
	SET output.allworld;
	DROP yrmo;
	
DATA return;
	SET output.allreturn;

PROC SORT DATA=linktable;
	BY gvkey csyrmo;
		
PROC SORT DATA=world;
	BY gvkey csyrmo;

DATA combined;
	MERGE linktable (IN=inlink) world;
	BY gvkey csyrmo;
	IF inlink;

PROC SORT DATA=combined;
	BY permno yrmo;

PROC SORT DATA=return;
	BY permno yrmo;

DATA combined;
	MERGE combined (IN=inlink) return;
	BY permno yrmo;
	IF inlink;
	vcrsp = a-be+cap/1000;
	IF vcrsp~=. THEN acrsp = a;
	IF siccd < 6000 OR siccd > 6999;
	IF siccd < 4900 OR siccd > 4949;
	IF shrcd = 10 OR shrcd = 11;
	IF year>=1960;

PROC SORT DATA=combined;
	BY yrmo payer;
	
PROC MEANS;

PROC MEANS DATA=combined NOPRINT;
	BY yrmo payer;
	VAR vcrsp acrsp;
	OUTPUT OUT=mb SUM= N=n_vcrsp n_acrsp;
	
PROC MEANS;

DATA mbpayer;
	SET mb;
	pvwmb = vcrsp/acrsp;
	pvcrsp = vcrsp;
	pacrsp = acrsp;
	pn_vcrsp = n_vcrsp;
	pn_acrsp = n_acrsp;
	IF payer=1;
	DROP payer vcrsp acrsp n_vcrsp n_acrsp;

DATA mbnonpayer;
	SET mb;
	npvwmb = vcrsp/acrsp;
	npvcrsp = vcrsp;
	npacrsp = acrsp;
	npn_vcrsp = n_vcrsp;
	npn_acrsp = n_acrsp;
	IF payer=0;
	DROP payer vcrsp acrsp n_vcrsp n_acrsp;

DATA output.premium;
	MERGE mbpayer mbnonpayer;
	BY yrmo;
	premium = log(pvwmb)-log(npvwmb);

PROC PRINT DATA=output.premium;
run;
quit;
endrsubmit;
rsubmit;
proc download data = output.premium
               out = work.premium;
run;
quit;
endrsubmit;
data work.premium;
 set work.premium;
 	PDND = premium * 100;
run;
quit;
proc export data = work.premium
    outfile = "&premium."
	dbms = xlsx replace;
run;
quit;
rsubmit;
* GET NYSE MARKET CAP *;
proc download data = crspq.msia
               out = work.msia;
run;
quit;
endrsubmit;
data work.msia;
 set work.msia (keep = caldt totval);
 caldty = put(caldt,yymmddn8.);
run;
proc export data = work.msia 
    outfile = "&msia."
	dbms = xlsx replace;
	sheet = "MSIA";
run;
quit;

signoff wrds;
run;
quit;
*

/* -------------------------------------------------------------------------------------------------------------------- */
* ENDSAS;
/* -------------------------------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------------------------------- */
* ENDSAS;
/* -------------------------------------------------------------------------------------------------------------------- */
* filename cees url "http://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries";
* filename cees url "https://download.bls.gov/pub/time.series/ce/ce.data.00a.TotalNonfarm.Employment";

* DATA ORIGINALLY FROM HERE: https://download.bls.gov/pub/time.series/ce/ce.data.00a.TotalNonfarm.Employment ;
filename cees "C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for 2025\SAS Input\CES_Data.txt";
data work.cees;
infile cees lrecl = 120 dlm = '09'x pad missover firstobs = 2;
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
* if _n_ > 100 then stop;
              
if Series =: "CES0000000001";
run;
quit;
proc freq data = work.cees;
  tables series;
run;
quit;
* DATA ORIGINALLY FROM HERE: http://download.bls.gov/pub/time.series/cu/cu.data.1.AllItems ;
filename cusr "C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for 2025\SAS Input\CUSR_Data.txt";
data work.cusr;
infile cusr lrecl = 120 dlm = '09'x pad missover firstobs = 2;
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
* if _n_ > 100 then stop;
              
if Series = "CUSR0000SA0";
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
proc export data = work.cees_cusr
    outfile = "&cees."
	dbms = xlsx replace;
	sheet = "EMPLOY_CPI";
run;
quit;
data _null_;
run;
