/*NOTE: this is the Stata code used to create the index in 2022
	Code used in 2024 was updated from this
	Originall file was called MakeSent_20220803
	Renamed to the file to match the 2024 version before pushing to Git
*/



* This program takes the raw data in columns D through P in the DATA worksheet and produces the sentiment measures in columns B and C        
clear all       
macro drop _all
local date 20220803
local endym 202206 
global endymg 202206   

import delimited "D:\InvestorSentiment\202207\Investor_Sentiment_Data_`date'_PRE.csv"
keep if yearmo < .
save "D:\InvestorSentiment\202207\Investor_Sentiment_Data_`date'_PRE", replace
* import delimited "C:\Users\jzeitler\Documents\InvestorSentiment\202206\Investor_Sentiment_Data_`date'_PRE.csv", clear

capture program drop sentmo        
program define sentmo        
        
gen year = int(yearmo/100)         
gen mo = (year-1960)*12+(yearmo-year*100)        
        
cap destring ripo, force replace        
        
foreach varname of varlist indpro employ {        
        gen g`varname' = `varname'/`varname'[_n-12]-1
        gen g`varname'1 = g`varname'[_n-12]
}        
foreach varname of varlist consdur consnon consserv {        
        gen g`varname' = (`varname'/`varname'[_n-12])/(cpi/cpi[_n-12])-1
        gen g`varname'1 = g`varname'[_n-12]
}        
gen recess1 = recess[_n-1]        
        
capture tsset mo        
sort mo        
        
* Define monthly equivalents to annual variables        
        
gen nipo_sum = sum(nipo)        
gen nipo_am = nipo_sum - nipo_sum[_n-12] if nipo~=.&nipo[_n-11]~=.        
replace nipo_am = nipo_sum if nipo~=.&nipo[_n-11]~=.&nipo[_n-12]==.        
        
replace ripo=0 if nipo==0 | ripo==.        
sum mo        
local lastmo = r(max)        
gen ripo_am = .        
forvalues t = 1/`lastmo' {        
        qui sum nipo_am if mo==`t'
        local nipo_am = r(mean)
        capture reg ripo if (mo>`t'-12)&(mo<=`t') [aweight = nipo/`nipo_am']
        capture predict ripowtdavg if mo==`t'
        qui sum ripo nipo if (mo>`t'-12)&(mo<=`t') 
        capture replace ripo_am = ripowtdavg if mo==`t'&r(N)==12
        capture drop ripowtdavg
}        
        
gen ripom = ripo        
gen nipom = nipo        
replace ripo = ripo_am        
replace nipo = nipo_am        
        
drop *_sum nipo_am ripo_am        
        
sort mo        
        
foreach varname of varlist pdnd ripo ripom {        
        gen raw_lag`varname' = `varname'[_n-12]
        egen sraw_lag`varname' = std(raw_lag`varname') if yearmo>=`1' & yearmo<=`2'
        reg raw_lag`varname' gindpro1 gconsdur1 gconsnon1 gconsserv1 gemploy1 recess1 if yearmo>=`1' & yearmo<=`2'
        predict e_lag`varname', resid
        egen se_lag`varname' = std(e_lag`varname') if yearmo>=`1' & yearmo<=`2'
}        
        
foreach varname of varlist nipo cef s pdnd ripo nipom ripom {        
        gen raw_`varname' = `varname'
        egen sraw_`varname' = std(`varname') if yearmo>=`1' & yearmo<=`2'
        reg raw_`varname' gindpro gconsdur gconsnon gconsserv gemploy recess if yearmo>=`1' & yearmo<=`2'
        predict e_`varname', resid
        egen se_`varname' = std(e_`varname') if yearmo>=`1' & yearmo<=`2'
}        
        
foreach type in raw_ e_ {        
        pca `type'cef                 `type'nipo `type'lagripo `type'lagpdnd `type's if yearmo>=`1' & yearmo<=`2'
        predict `type'f2 if yearmo>=`1' & yearmo<=`2'
        egen s`type'f2 = std(`type'f2)
        reg s`type'f2 s`type'cef                  s`type'nipo s`type'lagripo s`type'lagpdnd s`type's
}        
        
list yearmo *f2        
twoway line sraw_f2 se_f2 yearmo        
gen ispos_sraw_f2_temp=(sraw_f2>0&yearmo==200012)        
egen ispos_sraw_f2=max(ispos_sraw_f2_temp)        
replace sraw_f2=-sraw_f2 if ispos_sraw_f2==0        
gen ispos_se_f2_temp=(se_f2>0&yearmo==200012)        
egen ispos_se_f2=max(ispos_se_f2_temp)        
replace se_f2=-se_f2 if ispos_se_f2==0        
twoway line sraw_f2 se_f2 yearmo        
sum *f2        
        
        
order yearmo sraw_f2 raw_lagpdnd raw_nipo raw_lagripo raw_cef raw_s  se_f2 e_lagpdnd e_nipo e_lagripo e_cef e_s           
keep yearmo sraw_f2 raw_lagpdnd raw_nipo raw_lagripo raw_cef raw_s   se_f2 e_lagpdnd e_nipo e_lagripo e_cef e_s           
        
rename sraw_f2 SENT        
rename se_f2 SENT_ORTH        
        
label var SENT "SENT"        
label var SENT_ORTH "SENT_ORTH"        
        
save sentcalc_month, replace        
outsheet using sentcalc_month.csv, c replace        
        
gen yearfrac=int(yearmo/100)+mod(yearmo,100)/12        
twoway line SENT SENT_ORTH yearfrac if yearmo>=`1', xtitle("") xlabel(1965(5)2020) title("Investor Sentiment Index, 196507-`2'")        
        
        
end        
     
*NOTE: INSPECT OUTPUT IN CASE PCA YIELDS NEGATIVE OF SENTIMENT        
             
        
sentmo 196507 `endym' 


graph save "Graph" "D:\InvestorSentiment\202207\MakeSent_`date'.gph", replace 
graph export "D:\InvestorSentiment\202207\MakeSent_`date'.jpg", as(jpg) name("Graph") quality(100) replace    
keep yearmo SENT SENT_ORTH
keep if yearmo < .

* keep if yearmo >= 196507
* keep if yearmo <= `endym'
merge 1:1 yearmo using "D:\InvestorSentiment\202207\Investor_Sentiment_Data_`date'_PRE"
keep if _merge == 3
keep yearmo SENT SENT_ORTH v3 pdnd ripo nipo cefd s v9 indpro consdur consnon consserv recess employ cpi

save "D:\InvestorSentiment\202207\Investor_Sentiment_Data_`date'_POST", replace
export excel _all using "D:\InvestorSentiment\202207\Investor_Sentiment_Data_POST_`date'.xlsx", firstrow(varlabels) replace keepcellfmt
