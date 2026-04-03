*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
**# 0. README AND SET UP                                                                  *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

*===============================================================================
* NOTE ON UPDATE TO sentmo calculations:
* Created by Dean Ryu — January 14, 2026
*
* This STATA code constructs the Baker–Wurgler (BW) investor sentiment index.
* The orthogonalized version is constructed using detrended macro variables, 
* rather than the original year-over-year growth-rate.
*===============================================================================


* this STATA code requires two datasets, 
* "macro_var.dta" that you created through "1. Download Macro Data.do"; and 
* "All sources for 2025.xlsx" that contains five sentiment proxies (hand-collected). Use Sheet 'Collected Data'




* SET UP
clear all
cap log close
set more off

* set your directory below
local year 2026
local yearmin1 = `year'-1
cd "C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for `year'"


* load the sentiment proxies dataset, and merge it with 
* "macro_var.dta" that we created in "1. Download Macro Data.do"
import excel "All sources for `year'.xlsx", sheet("Collected Data") first clear
list in 505/510
drop if mi(yearmo) 

merge 1:1 yearmo using macro_var.dta
assert _merge ==3
drop _merge


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
**# 1. Create Baker-Wurgler Sentiment                                           *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


program define sentmo

    gen year = int(yearmo/100)
    gen mo   = (year-1960)*12 + (yearmo - year*100)

    cap destring ripo, force replace


    capture tsset mo, monthly
    sort mo

    *-----------------------------------------------------------
    * REAL CONSUMPTION & LOGS
    *-----------------------------------------------------------
    gen consdur_real  = consdur  / cpi if consdur  < .
    gen consnon_real  = consnon  / cpi if consnon  < .
    gen consserv_real = consserv / cpi if consserv < .

    gen ln_indpro = ln(indpro)   if indpro   > 0
    gen ln_employ = ln(employ)   if employ   > 0
    gen ln_consdur  = ln(consdur_real)  if consdur_real  > 0
    gen ln_consnon  = ln(consnon_real)  if consnon_real  > 0
    gen ln_consserv = ln(consserv_real) if consserv_real > 0

    *-----------------------------------------------------------
    * DETRENDING: 12-MONTH MOVING AVERAGE OF LOGS
    *-----------------------------------------------------------
    tssmooth ma ln_indpro_trend = ln_indpro, window(12)
    tssmooth ma ln_employ_trend = ln_employ, window(12)

    tssmooth ma ln_consdur_trend  = ln_consdur,  window(12)
    tssmooth ma ln_consnon_trend  = ln_consnon,  window(12)
    tssmooth ma ln_consserv_trend = ln_consserv, window(12)

    * Percent deviations from trend
    gen gindpro  = exp(ln_indpro  - ln_indpro_trend ) - 1 if ln_indpro_trend < .
    gen gemploy  = exp(ln_employ  - ln_employ_trend ) - 1 if ln_employ_trend < .

    gen gconsdur  = exp(ln_consdur  - ln_consdur_trend ) - 1 if ln_consdur_trend < .
    gen gconsnon  = exp(ln_consnon  - ln_consnon_trend ) - 1 if ln_consnon_trend < .
    gen gconsserv = exp(ln_consserv - ln_consserv_trend) - 1 if ln_consserv_trend < .

    * 12-month lags
    gen gindpro1   = gindpro[_n-12]
    gen gemploy1   = gemploy[_n-12]
    gen gconsdur1  = gconsdur[_n-12]
    gen gconsnon1  = gconsnon[_n-12]
    gen gconsserv1 = gconsserv[_n-12]

    gen recess1 = recess[_n-1]

    *-----------------------------------------------------------
    * IPO ANNUALIZATION (ROLLING 12-MONTH)
    *-----------------------------------------------------------
    gen nipo_sum = sum(nipo)
    gen nipo_am  = nipo_sum - nipo_sum[_n-12] if nipo < . & nipo[_n-11] < .
    replace nipo_am = nipo_sum if nipo < . & nipo[_n-11] < . & nipo[_n-12] == .

    replace ripo = 0 if nipo == 0 | ripo == .
    
	sum mo
    local lastmo = r(max)
    gen ripo_am = .

    forvalues t = 1/`lastmo' {
        qui sum nipo_am if mo == `t'
        local nipo_bar = r(mean)
        capture reg ripo if mo > `t'-12 & mo <= `t' [aweight = nipo/`nipo_bar']
        capture predict ripowtdavg if mo == `t'
        qui sum ripo nipo if mo > `t'-12 & mo <= `t'
        capture replace ripo_am = ripowtdavg if mo == `t' & r(N) == 12
        capture drop ripowtdavg
    }

    gen ripom = ripo
    gen nipom = nipo
    replace ripo = ripo_am
    replace nipo = nipo_am

    drop *_sum nipo_am ripo_am
    
	sort mo

    *-----------------------------------------------------------
    * LAGGED VARIABLES
    *-----------------------------------------------------------
    foreach v of varlist pdnd ripo ripom {
        gen raw_lag`v' = `v'[_n-12]
        egen sraw_lag`v' = std(raw_lag`v') if yearmo >= `1' & yearmo <= `2'
        reg raw_lag`v' gindpro1 gconsdur1 gconsnon1 gconsserv1 gemploy1 recess1 if yearmo >= `1' & yearmo <= `2'
        predict e_lag`v', resid
        egen se_lag`v' = std(e_lag`v') if yearmo >= `1' & yearmo <= `2'
    }

    *-----------------------------------------------------------
    * RAW AND ORTHOGONALIZED SENTIMENT PROXIES
    *-----------------------------------------------------------
    foreach varname of varlist nipo cef s pdnd ripo nipom ripom {
        gen raw_`varname' = `varname'
        egen sraw_`varname' = std(`varname') if yearmo >= `1' & yearmo <= `2'
        reg raw_`varname' gindpro gconsdur gconsnon gconsserv gemploy recess if yearmo >= `1' & yearmo <= `2'
        predict e_`varname', resid
        egen se_`varname' = std(e_`varname') if yearmo >= `1' & yearmo <= `2'
    }

    *-----------------------------------------------------------
    * PCA
    *-----------------------------------------------------------
    foreach type in raw_ e_ {
        pca `type'cef `type'nipo `type'lagripo `type'lagpdnd `type's if yearmo >= `1' & yearmo <= `2'
        predict `type'f2 if yearmo >= `1' & yearmo <= `2'
        egen s`type'f2 = std(`type'f2)
		reg s`type'f2 s`type'cef s`type'nipo s`type'lagripo s`type'lagpdnd s`type's
    }

    *-----------------------------------------------------------
    * SIGN NORMALIZATION (DEC 2000 POSITIVE)
    *-----------------------------------------------------------
    gen flip_raw = (sraw_f2 > 0 & yearmo == 200012)
    egen keep_raw = max(flip_raw)
    replace sraw_f2 = -sraw_f2 if keep_raw == 0

    gen flip_e = (se_f2 > 0 & yearmo == 200012)
    egen keep_e = max(flip_e)
    replace se_f2 = -se_f2 if keep_e == 0

    *-----------------------------------------------------------
    * FINAL OUTPUT
    *-----------------------------------------------------------
    rename sraw_f2 SENT
    rename se_f2   SENT_ORTH
	
	keep yearmo SENT SENT_ORTH pdnd ripo nipo cefd s ///
         indpro consdur consnon consserv recess employ cpi

    order yearmo SENT SENT_ORTH pdnd ripo nipo cefd s ///
          indpro consdur consnon consserv recess employ cpi
		  
    save sentcalc_month, replace
    export excel "sentiment.xlsx", firstrow(variables) replace

end

*===============================================================================
* RUN PROGRAM
*===============================================================================
	
sentmo 196507 `yearmin1'12


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
**# 2. Save the file                                                            *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

order yearmo SENT SENT_ORTH
save baker-wurgler-sentiment, replace	
		
