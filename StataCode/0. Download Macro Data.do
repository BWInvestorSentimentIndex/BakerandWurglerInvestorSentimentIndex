*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 0. README                                                                   *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

clear all
cap log close
set more off

* set your directory below
//cd "~/Desktop/sentiment"
local year 2026 //Update to CURRENT year
local yearmin1 = `year'-1 
local enddate `yearmin1'12

di `yearmin1'
di `enddate'

cd "C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for `year'" //UPDATE TO YOUR FILE PATH


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 1. Download Macro variables from FRED                                       *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


*** SET API KEY ***
* you will need to visit 
* https://fred.stlouisfed.org/docs/api/api_key.html
* and obtain your key (free) to login to the FRED database

//set fredkey "YOUR API KEY HERE", permanently

* for example,
* set fredkey "abc123abc123", permanently


* Alternatively, keep API key in a .txt file and load it in 
file open mykeyfile using "C:\Users\dmangoubi\Documents\APIKEYS\FRED.txt", read text
file read mykeyfile line
file close mykeyfile

local fredkey_local `"`line'"'

set fredkey "`fredkey_local'", permanently


** load six macro variables 
import fred INDPRO PCEDG PCEND PCES PAYEMS CPIAUCSL USREC, clear 

* industrial production, consumer durables, consumer nondurables, 
* consumer service, employment, cpi (for price level adjustment)
rename INDPRO indpro 
rename PCEDG consdur
rename PCEND consnon
rename PCES consserv
rename PAYEMS employ
rename CPIAUCSL cpi
rename USREC recess //NBER recession data directly pulled from FRED

gen year = year(daten)
gen month = month(daten)
gen yearmo = year*100 + month

* we don't need data prior to 1958
di `enddate'
drop if yearmo < 195801 | yearmo > `enddate'


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 2. Save as "macro_var.dta"                                                  *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

drop datestr daten year month

order yearmo indpro consdur consnon consserv recess employ cpi 

* macro_var.dta will be used in "2. Create Baker-Wurgler Sentiment.do"
save macro_var, replace	


