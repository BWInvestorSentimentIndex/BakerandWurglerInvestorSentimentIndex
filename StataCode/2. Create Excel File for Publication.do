*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 0. README                                                                   *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

clear all
cap log close
set more off
local year 2026

* set your directory below
cd "C:\Users\dmangoubi\OneDrive - Harvard Business School\Daniel Projects\Sentiment Index\Data for `year'"


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 1. Create Sheet 1 (README)                                                  *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

putexcel set "SENTIMENT_`year'.xlsx", sheet("README") replace
putexcel A1 = "INVESTOR SENTIMENT DATA"
putexcel A1, bold

putexcel A2 = "GENERAL NOTES"
putexcel A3 = "UPDATED: March, `year'"
putexcel A4 = "Code, data, notes, and yearly updates are posted here: "
putexcel B5 = "https://github.com/BWInvestorSentimentIndex/BakerandWurglerInvestorSentimentIndex"


putexcel A6 = "Data are generally as used and described in Baker and Wurgler, 'Investor Sentiment and the Cross-Section of Stock Returns,' Journal of Finance vol. 61, August 2006, p.1645-1680."

putexcel B7 = "and Baker and Wurgler, 'Investor Sentiment in the Stock Market,' Journal of Economic Perspectives vol. 21(2), Spring 2007, p. 129-152."

putexcel A8 = "All variable values are as of end of the indicated period"

putexcel A9 = "201101+ raw data are as constructed by James Zeitler and Jennifer Beauregard of Harvard Business School"

putexcel A10 = "202207+ raw data are as constructed by Dean Ryu and Daniel Mangoubi of Harvard Business School"

putexcel A11 = "Data are subject to change if data improvements are available or revisions occur"

putexcel A13 = "UNLIKE IN BAKER AND WURGLER (2006, 2007), NYSE TURNOVER HAS BEEN DROPPED AS ONE OF THE SIX SENTIMENT INDICATORS. THE SENTIMENT INDEX MAINTAINED NOW IS BASED ON FIVE INDICATORS."

putexcel B14 = "Turnover does not mean what it once did, given the explosion of institutional high-frequency trading and the migration of trading to a variety of venues"

putexcel A16 = "DO NOT USE THESE SERIES FOR MEASURING CHANGES IN SENTIMENT (E.G. SENTIMENT(T)-SENTIMENT(T-1)) DUE TO LAG STRUCTURES, AMONG OTHER CONSIDERATIONS.  THESE ARE LOW-FREQUENCY LEVELS INDICATORS."

putexcel B17 = "See 2007 paper for a discussion of a changes-in-sentiment indicator"

putexcel A19 = "Model for SENT_ORTH was updated in 2026 by Dean Ryu. "
putexcel A19, bold
putexcel A20 = "The SENT_ORTH index is constructed by aggregating market-based sentiment proxies and orthogonalizing these proxies with respect to a set of macroeconomic variables."
putexcel A21 = "In the original implementation, these macro variables were transformed into year-over year growth rates before entering the orthogonalization regressions. During the COVID-19 period, however, this transformation produced mechanically extreme values because the denominator of the year-over-year ratio corresponded to unusually depressed economic conditions in early 2020."
putexcel A22 = "The new model addresses this issue by revising the macro-processing procedure so that the sentiment orthogonalization is based off of deterending macro series rather than year-over-year differences."
putexcel A23 = "For more details see: (1) Create Baker-Wurgler Sentiment Index.do and (2) The BW INDEX DETEREND.pdf Memo, both of which are available on the GitHub linked above. "


 


putexcel A25 = "SENT"
putexcel B25 = "Sentiment index in Baker and Wurgler (2006); updated version of Eq. (2) in that paper; based on first principal component of FIVE (standardized) sentiment proxies"


putexcel A26 = "SENT⊥"
putexcel A26, bold
putexcel B26 = "Sentiment index in Baker and Wurgler (2006); updated version of Eq. (3) in that paper; based on first principal component of FIVE (standardized) sentiment proxies where each of the proxies has first been orthogonalized with respect to a set of six macroeconomic indicators"

putexcel A28 = "pdnd"
putexcel B28 = "Value-weighted dividend premium defined following Baker and Wurgler (2004) (values differ slightly from there due to subsequent improvements in the CRSP/Compustat merge procedure). The indexes use the t-12 value.   (From SAS program divpremmonth_jaz_20210111.sas)"

putexcel A29 = "ripo"
putexcel B29 = "First-day returns on IPOs from Ibbotson, Sindelar, and Ritter (1994) and updates (NIPO-weighted average of monthly RIPOs) from Jay Ritter's website. We provide monthly data here; the indexes use the nipo-weighted average over the prior twelve months to smooth noise, and then use the t-12 value of the result"

putexcel A30 = "nipo"
putexcel B30 = "IPO volume from Ibbotson, Sindelar, and Ritter (1994) and updates from Jay Ritter's website. We provide monthly data here; the indexes use the sum of nipo over the prior twelve months to smooth noise"

putexcel A31 = "cefd"
putexcel B31 = "Closed-end fund discount from Neal and Wheatley (1998) for 1934 to 1964 ('domestic stock funds'); Lakonishok, Shleifer, Vishny (1991) for 1965 to 1985 (general equity funds only); CDA/Wiesenberger for 1986; Herzfeld from 1987-2010; Morningstar from 2011. (unlevered general equity only) (equal-weighted)"

putexcel A32 = "s"
putexcel B32 = "Equity share in new issues defined following Baker and Wurgler (2000), i.e., the total volume of equity issues over the prior twelve months divided by the total volume of equity and debt issues over the prior twelve months from Federal Reserve Bulletin"

putexcel A34 = "indpro"
putexcel B34 = "Industrial production index; we provide monthly data here; the orthogonalized index uses growth over the t-12 value"

putexcel A35 = "consdur"
putexcel B35 = "Nominal durables consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value"

putexcel A36 = "consnon"
putexcel B36 = "Nominal nondurables consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value"

putexcel A37 = "consserv"
putexcel B37 = "Nominal services consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value"

putexcel A38 = "recess"
putexcel B38 = "NBER recession indicator"

putexcel A39 = "employ"
putexcel B39 = "Employment; we provide monthly data here; the orthogonalized index uses growth over the t-12 value"

putexcel A40 = "cpi"
putexcel B40 = "Consumer price index"
putexcel A41 = "Note: CPI data is missing in Oct-2025 due to a government shut down."


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 2. Create Sheet 2 (DATA)                                                    *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

import excel "All sources for `year'.xlsx", sheet("Collected Data") first clear
drop if mi(yearmo)
merge 1:1 yearmo using macro_var.dta
drop _merge

* for ipo variables 
destring ripo, replace force

merge 1:1 yearmo using baker-wurgler-sentiment.dta
drop _merge


** Note: Choose either 2-1 or 2-2 below


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 2-1. Export the whole database (faster)                                     *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

** export the entire database in the second sheet labelled "DATA"

*export excel yearmo SENT SENT_ORTH pdnd ripo nipo cefd s indpro consdur consnon consserv recess employ cpi using "SENTIMENT.xlsx", sheet("DATA") sheetreplace firstrow(variables) keepcellfmt



*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* 2-2. Export with customization (slower but useful sometimes)                *
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

** same as 2-1, but user-specified command can go here, 
** such as highlighting specific rows with color

putexcel set "SENTIMENT_`year'.xlsx", sheet("DATA") modify

putexcel A1 = "yearmo"
putexcel B1 = "SENT"
putexcel C1 = "SENT_ORTH"
putexcel D1 = "pdnd"
putexcel E1 = "ripo"
putexcel F1 = "nipo"
putexcel G1 = "cefd"
putexcel H1 = "s"
putexcel I1 = "indpro"
putexcel J1 = "consdur"
putexcel K1 = "consnon"
putexcel L1 = "consserv"
putexcel M1 = "recess"
putexcel N1 = "employ"
putexcel O1 = "cpi"

** Print Data
qui forvalues i = 1/`=_N' {
	
	local row = `i' + 1 // increase by one since first row is header
    
		putexcel A`row' = yearmo[`i'] B`row' = SENT[`i'] C`row' = SENT_ORTH[`i'] D`row' = pdnd[`i'] E`row' = ripo[`i'] F`row' = nipo[`i'] G`row' = cefd[`i'] H`row' = s[`i'] I`row' = indpro[`i'] J`row' = consdur[`i'] K`row' = consnon[`i'] L`row' = consserv[`i'] M`row' = recess[`i'] N`row' = employ[`i'] O`row' = cpi[`i']
		}



