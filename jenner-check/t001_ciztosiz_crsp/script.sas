/* ----------------------------------------------------------------------------
   Source: PDND/divpremmonth.sas  (Baker-Wurgler Investor Sentiment Index)
   Macro %ciztosiz, verbatim from the repository: converts CRSP CIZ-format
   monthly stock data to the legacy SIZ layout, deriving the SHRCD and EXCHCD
   classification variables. Exercised here against the bundled sample via a
   monthly-frequency call (the same call the program issues at line 162).
   ---------------------------------------------------------------------------- */
%macro ciztosiz(freq = m, startdt = 01JAN1960, enddt = 31DEC2025, outds = ciz2siz_crsp_&freq.);
%if &freq=D or &freq = d %then %do;
    %let freq=d;
    %let varfreq = dly;
%end;
%else %if &freq ne d %then %do;
    %let freq=m;
    %let varfreq = mth;
%end;

%let cizds = &freq.sf_v2;

%put &cizds. &freq. &varfreq.;
* dly version of the data does not include IssuerNm variable, need to add back;
%if &freq = d %then %do;
    proc sql;
         create table &cizds. as select distinct a.*, b.IssuerNm
         from crsp.&cizds. (where = (&varfreq.caldt >= "&startdt."d and &varfreq.caldt <= "&enddt."d)) as a
         left join crsp.stkSecurityInfoHist as b
         on a.permno = b.permno
         and b.secInfoStartDt<= a.&varfreq.caldt <= b.secInfoEndDt
        ;
    quit;
%end;
%else %do;
    data &cizds.;
        set crsp.&cizds. (where = (&varfreq.caldt >= "&startdt."d and &varfreq.caldt <= "&enddt."d));
    run;
%end;

data &outds.;
    set &cizds.;
    rename &varfreq.caldt = date
           &varfreq.prevdt = prevdate
           &varfreq.ret = ret
           &varfreq.retx = retx
           &varfreq.prc = prc
           &varfreq.PrevPrc = prevprc
           &varfreq.vol = vol
           &varfreq.cap = mktcap
           &varfreq.PrevCap = prevmktcap
           &varfreq.cumfacpr = cfacpr
           &varfreq.cumfacshr = cfacshr
           cusip = ncusip
           issuerNm = comnam;
* create shrcd style variable;
    if ShareType="NS" and SecurityType="EQTY" and SecuritySubType="COM" and USIncFlg="Y" and IssuerType='ACOR' then shrcd = 10;
    else if ShareType="NS" and SecurityType="EQTY" and SecuritySubType="COM" and USIncFlg="Y" and IssuerType='CORP' then shrcd = 11;
    else if ShareType="NS" and SecurityType="EQTY" and SecuritySubType="COM" and USIncFlg="N" and IssuerType='CORP' then shrcd = 12;
    else if ShareType="NS" and SecurityType="FUND" and SecuritySubType="CEF" and USIncFlg="Y" and IssuerType='ACOR' then shrcd = 14;
    else if ShareType="NS" and SecurityType="FUND" and SecuritySubType="CEF" and USIncFlg="N" and IssuerType='ACOR' then shrcd = 15;
    else if ShareType="NS" and SecurityType="EQTY" and SecuritySubType="COM" and USIncFlg="Y" and IssuerType='REIT' then shrcd = 18;
    else if ShareType='CE' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 20;
    else if ShareType='CE' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='CORP' then shrcd = 21;
    else if ShareType='NS' and SecurityType='DERV' and SecuritySubType='ATR' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 23;
    else if ShareType='CE' and SecurityType='FUND' and SecuritySubType='CEF' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 24;
    else if ShareType='AD' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='N' and IssuerType='ACOR' then shrcd = 30;
    else if ShareType='AD' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='N' and IssuerType='CORP' then shrcd = 31;
    else if ShareType='SB' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 40;
    else if ShareType='SB' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='CORP' then shrcd = 41;
    else if ShareType='SB' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='N' and IssuerType='CORP' then shrcd = 42;
    else if ShareType='SB' and SecurityType='FUND' and SecuritySubType='CEF' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 44;
    else if ShareType='SB' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='REIT' then shrcd = 48;
    else if ShareType='UG' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 70;
    else if ShareType='UG' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='Y' and IssuerType='CORP' then shrcd = 71;
    else if ShareType='UG' and SecurityType='EQTY' and SecuritySubType='COM' and USIncFlg='N' and IssuerType='CORP' then shrcd = 72;
    else if ShareType='NS' and SecurityType="FUND" and SecuritySubType="ETF" and USIncFlg="Y" and IssuerType='ACOR' then shrcd = 73;
    else if ShareType='UG' and SecurityType='FUND' and SecuritySubType='ETV' and USIncFlg='Y' and IssuerType='ACOR' then shrcd = 74;
    else shrcd = 75;
* create exchcd style variable;
    if primaryexch = 'N'      and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 1;
    else if primaryexch = 'A' and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 2;
    else if primaryexch = 'Q' and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 3;
    else if primaryexch = 'R' and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 4;
    else if primaryexch = 'B' and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 5;
    else if primaryexch = 'I' and conditionaltype = 'RW' and TradingStatusFlg = 'A' then exchcd = 6;
    else if primaryexch = 'N' and conditionaltype = 'RW' and TradingStatusFlg = 'H' then exchcd = -2;
    else if primaryexch = 'A' and conditionaltype = 'RW' and TradingStatusFlg = 'H' then exchcd = -2;
    else if primaryexch = 'Q' and conditionaltype = 'RW' and TradingStatusFlg = 'H' then exchcd = -2;
    else if primaryexch = 'N' and conditionaltype = 'RW' and TradingStatusFlg = 'S' then exchcd = -1;
    else if primaryexch = 'A' and conditionaltype = 'RW' and TradingStatusFlg = 'S' then exchcd = -1;
    else if primaryexch = 'Q' and conditionaltype = 'RW' and TradingStatusFlg = 'S' then exchcd = -1;
    else if primaryexch = 'N' and conditionaltype = 'NW' and TradingStatusFlg = 'A' then exchcd = 31;
    else if primaryexch = 'N' and conditionaltype = 'WI' and TradingStatusFlg = 'A' then exchcd = 31;
    else if primaryexch = 'A' and conditionaltype = 'NW' and TradingStatusFlg = 'A' then exchcd = 32;
    else if primaryexch = 'Q' and conditionaltype = 'NW' and TradingStatusFlg = 'A' then exchcd = 33;
    else if primaryexch = 'X' and conditionaltype = 'NT' then exchcd = 0;
    else exchcd = 99;
run;
%mend ciztosiz;

/* Build one monthly CRSP file (the program's line-162 call). */
%ciztosiz(freq = m, startdt = 01JAN1960, enddt = 31DEC2025, outds = work.msf_ciz);

proc print data = work.msf_ciz;
  var permno date ncusip comnam shrcd exchcd;
run;

proc freq data = work.msf_ciz;
  tables shrcd exchcd;
run;
