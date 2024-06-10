*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 0. README                                                                   *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

clear all
cap log close
set more off

* set your directory below
cd "~/Desktop/sentiment"

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 1. Download Macro variables from FRED                                       *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

* you will need to visit 
* https://fred.stlouisfed.org/docs/api/api_key.html
* and obtain your key (free) to login to the FRED database

set fredkey "your_fredkey_goes_here", permanently

* for example,
* set fredkey "a1b2c3d4e5f6", permanently

** load six macro variables 
import fred INDPRO PCEDG PCEND PCES PAYEMS CPIAUCSL 

* industrial production, consumer durables, consumer nondurables, 
* consumer service, employment, cpi (for price level adjustment)
rename INDPRO indpro 
rename PCEDG consdur
rename PCEND consnon
rename PCES consserv
rename PAYEMS employ
rename CPIAUCSL cpi

gen year = year(daten)
gen month = month(daten)
gen yearmo = year*100 + month

* we don't need data prior to 1958
drop if yearmo < 195801 | yearmo > 202312

* monthly NBER recession coded as 1
* the latest NBER recession is 2020 COVID shock
* please update accordingly

generate recess = 0
replace recess = 1 if (yearmo >= 195801 & yearmo <= 195804) | (yearmo >= 196004 & yearmo <= 196102) | (yearmo >= 196912 & yearmo <= 197011) | (yearmo >= 197311 & yearmo <= 197503) | (yearmo >= 198001 & yearmo <= 198007) | (yearmo >= 198107 & yearmo <= 198211) | (yearmo >= 199007 & yearmo <= 199103) | (yearmo >= 200103 & yearmo <= 200111) | (yearmo >= 200712 & yearmo <= 200906) | (yearmo >= 202002 & yearmo <= 202004)
	

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 2. Save as "macro_var.dta"                                                  *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

drop datestr daten year month

order yearmo indpro consdur consnon consserv recess employ cpi 

* macro_var.dta will be used in "2. Create Baker-Wurgler Sentiment.do"
save macro_var, replace	


