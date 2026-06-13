options obs=100;
options nocenter;

/* A local CRSP library, standing in for the WRDS CRSP library the program
   reads in production. */
libname crsp "./input";

/* ----------------------------------------------------------------------------
   Mock CRSP CIZ monthly stock file (crsp.msf_v2), supplying just the columns
   the %ciztosiz macro's monthly path reads. Real runs pull this from WRDS via
   the CRSP library; here it is a small inline sample so the macro's
   share-code / exchange-code classification logic can be exercised locally.
   ---------------------------------------------------------------------------- */
data crsp.msf_v2;
  length cusip $9 issuerNm $32
         ShareType $2 SecurityType $4 SecuritySubType $3 USIncFlg $1
         IssuerType $4 primaryexch $1 conditionaltype $2 TradingStatusFlg $1;
  informat mthcaldt mthprevdt yymmdd10.;
  format   mthcaldt mthprevdt yymmdd10.;
  input permno mthcaldt mthprevdt mthret mthretx mthprc mthPrevPrc
        mthvol mthcap mthPrevCap mthcumfacpr mthcumfacshr
        cusip $ issuerNm $ ShareType $ SecurityType $ SecuritySubType $
        USIncFlg $ IssuerType $ primaryexch $ conditionaltype $ TradingStatusFlg $;
  datalines;
10001 2024-01-31 2023-12-29 0.012 0.012 24.5 24.2 1200 29400 28800 1.0 1.0 36720410 GORMAN_RUPP NS EQTY COM Y CORP N RW A
10002 2024-01-31 2023-12-29 -0.004 -0.004 11.3 11.4 800 9040 9120 1.0 1.0 05978R10 BANNER_FIN NS EQTY COM Y ACOR N RW A
10025 2024-01-31 2023-12-29 0.030 0.028 88.0 85.5 540 47520 46170 1.0 1.0 00846U10 AGILENT NS EQTY COM Y CORP Q RW A
10026 2024-01-31 2023-12-29 0.005 0.005 142.1 141.4 300 42630 42420 1.0 1.0 46625H10 JPMORGAN_FD NS FUND CEF Y ACOR N RW A
10028 2024-01-31 2023-12-29 -0.010 -0.010 6.7 6.77 4100 27470 27757 1.0 1.0 74762E10 PUBLIC_STG NS EQTY COM Y REIT N RW A
10032 2024-01-31 2023-12-29 0.018 0.018 53.2 52.3 920 48944 48116 1.0 1.0 88160R10 TESLA_ADR AD EQTY COM N CORP Q NW A
10044 2024-01-31 2023-12-29 0.000 0.000 19.9 19.9 150 2985 2985 1.0 1.0 12345610 SOME_HALT NS EQTY COM Y CORP N RW H
10101 2024-02-29 2024-01-31 0.022 0.021 27.4 24.5 1350 36990 29400 1.0 1.0 36720410 GORMAN_RUPP NS EQTY COM Y CORP N RW A
10102 2024-02-29 2024-01-31 0.009 0.009 11.4 11.3 760 8664 9040 1.0 1.0 05978R10 BANNER_FIN NS EQTY COM Y ACOR N RW A
10125 2024-02-29 2024-01-31 -0.015 -0.015 86.7 88.0 600 52020 47520 1.0 1.0 00846U10 AGILENT NS EQTY COM Y CORP Q RW A
;
run;
