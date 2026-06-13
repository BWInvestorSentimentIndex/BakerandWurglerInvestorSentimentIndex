options obs=100;
options nocenter;

/* ----------------------------------------------------------------------------
   Mock "combined" firm-month panel, standing in for the dataset the program
   assembles from the CRSP/Compustat merge (it arrives already restricted to
   common shares outside financials/utilities). Each row is one firm-month with
   the market-to-book value (vcrsp), book assets (acrsp), a dividend-payer flag,
   and the year-month key (yrmo) the dividend-premium step groups on.
   ---------------------------------------------------------------------------- */
data combined;
  input permno yrmo payer vcrsp acrsp;
  datalines;
10001 202301 1 1820.5 1450.0
10002 202301 1 2310.8 1780.0
10003 202301 1 1540.2 1290.0
10010 202301 0 980.4  1120.0
10011 202301 0 1430.7 1610.0
10012 202301 0 760.5  910.0
10001 202302 1 1890.1 1470.0
10002 202302 1 2280.6 1800.0
10003 202302 1 1610.9 1310.0
10010 202302 0 1010.3 1140.0
10011 202302 0 1390.2 1640.0
10012 202302 0 800.1  930.0
10001 202303 1 1955.4 1490.0
10002 202303 1 2401.2 1825.0
10003 202303 1 1672.3 1330.0
10010 202303 0 1055.6 1160.0
10011 202303 0 1420.8 1665.0
10012 202303 0 845.7  955.0
;
run;
