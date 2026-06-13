/* ----------------------------------------------------------------------------
   Source: PDND/divpremmonth.sas  (Baker-Wurgler Investor Sentiment Index)
   The dividend-premium (PDND) calculation, the program's "premium" step
   (lines 474-526), preserved as written: aggregate value-weighted market-to-
   book by year-month and payer status with PROC MEANS, split payers from
   nonpayers, take the log dividend premium, and scale to PDND. This is the
   value-weighted dividend premium proxy described in the repository README.
   Runs here against the bundled monthly firm panel.
   ---------------------------------------------------------------------------- */

PROC SORT DATA=combined;
	BY yrmo payer;
run;

PROC MEANS DATA=combined NOPRINT;
	BY yrmo payer;
	VAR vcrsp acrsp;
	OUTPUT OUT=mb SUM= N=n_vcrsp n_acrsp;
run;

DATA mbpayer;
	SET mb;
	pvwmb = vcrsp/acrsp;
	pvcrsp = vcrsp;
	pacrsp = acrsp;
	pn_vcrsp = n_vcrsp;
	pn_acrsp = n_acrsp;
	IF payer=1;
	DROP payer vcrsp acrsp n_vcrsp n_acrsp;
run;

DATA mbnonpayer;
	SET mb;
	npvwmb = vcrsp/acrsp;
	npvcrsp = vcrsp;
	npacrsp = acrsp;
	npn_vcrsp = n_vcrsp;
	npn_acrsp = n_acrsp;
	IF payer=0;
	DROP payer vcrsp acrsp n_vcrsp n_acrsp;
run;

DATA premium;
	MERGE mbpayer mbnonpayer;
	BY yrmo;
	premium = log(pvwmb)-log(npvwmb);
run;

data premium;
 set premium;
 PDND = premium * 100;
run;

PROC PRINT DATA=premium;
  var yrmo pvwmb npvwmb premium PDND;
run;
