# Investor Sentiment Index
Code for Sentiment Index project

This repository contains the SAS and Stata code used to obtain data for and calculate the Baker-Wurgler Sentiment Index. See 'Investor Sentiment in the Stock Market,' Journal of Economic Perspectives vol. 21(2), Spring 2007, p. 129-152.

Data are generally as used and described in Baker and Wurgler, 'Investor Sentiment and the Cross-Section of Stock Returns,' Journal of Finance vol. 61, August 2006, p.1645-1680.


## INVESTOR SENTIMENT DATA
GENERAL NOTES
UPDATED: March 2026

Data are generally as used and described in Baker and Wurgler, 'Investor Sentiment and the Cross-Section of Stock Returns,' Journal of Finance vol. 61, August 2006, p.1645-1680.

All variable values are as of end of the indicated period
201101+ raw data are as constructed by James Zeitler and Jennifer Beauregard of Harvard Business School
202207+ raw data are as constructed by Dean Ryu and Daniel Mangoubi of Harvard Business School
Data are subject to change if data improvements are available or revisions occur. 

![Data Notice](https://img.shields.io/badge/Data%20Note-CPI%20missing%20Oct%202025-red)
No CPI Data for October 2025 was available due to a government shutdown. 
(See: https://www.bls.gov/cpi/additional-resources/2025-federal-government-shutdown-impact-cpi.htm)

UNLIKE IN BAKER AND WURGLER (2006, 2007), NYSE TURNOVER HAS BEEN DROPPED AS ONE OF THE SIX SENTIMENT INDICATORS. THE SENTIMENT INDEX MAINTAINED NOW IS BASED ON FIVE INDICATORS.


DO NOT USE THESE SERIES FOR MEASURING CHANGES IN SENTIMENT (E.G. SENTIMENT(T)-SENTIMENT(T-1)) DUE TO LAG STRUCTURES, AMONG OTHER CONSIDERATIONS.  THESE ARE LOW-FREQUENCY LEVELS INDICATORS.


<br>**Model for SENT_ORTH was updated in 2026 by Dean Ryu.**

The SENT_ORTH index is constructed by aggregating market-based sentiment proxies and orthogonalizing these proxies with respect to a set of macroeconomic variables. In the original implementation, these macro variables were transformed into year-over year growth rates before entering the orthogonalization regressions. During the COVID-19 period, however, this transformation produced mechanically extreme values because the denominator of the year-over-year ratio corresponded to unusually depressed economic conditions in early 2020. The new model addresses this issue by revising the macro-processing procedure so that the sentiment orthogonalization is based off of deterending macro series rather than year-over-year differences.For more details see: (1) Create Baker-Wurgler Sentiment Index.do and (2) The BW INDEX DETEREND.pdf Memo, both of which are available on this repository.

|||
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|SENT |Sentiment index in Baker and Wurgler (2006); updated version of Eq. (2) in that paper; based on first principal component of FIVE (standardized) sentiment proxies                                                                                                              |
| SENT⊥ | Sentiment index in Baker and Wurgler (2006); updated version of Eq. (3) in that paper; based on first principal component of FIVE (standardized) sentiment proxies where each of the proxies has first been orthogonalized with respect to a set of six macroeconomic indicators |

|||
|----|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|pdnd|Value-weighted dividend premium defined following Baker and Wurgler (2004) (values differ slightly from there due to subsequent improvements in the CRSP/Compustat merge procedure). The indexes use the t-12 value.   (From SAS program divpremmonth_jaz_20210111.sas)                                             |
|ripo|First-day returns on IPOs from Ibbotson, Sindelar, and Ritter (1994) and updates (NIPO-weighted average of monthly RIPOs) from Jay Ritter's website. We provide monthly data here; the indexes use the nipo-weighted average over the prior twelve months to smooth noise, and then use the t-12 value of the result|
|nipo|IPO volume from Ibbotson, Sindelar, and Ritter (1994) and updates from Jay Ritter's website. We provide monthly data here; the indexes use the sum of nipo over the prior twelve months to smooth noise                                                                                                             |
|cefd|Closed-end fund discount from Neal and Wheatley (1998) for 1934 to 1964 ('domestic stock funds'); Lakonishok, Shleifer, Vishny (1991) for 1965 to 1985 (general equity funds only); CDA/Wiesenberger for 1986; Herzfeld from 1987-2010; Morningstar from 2011. (unlevered general equity only) (equal-weighted)     |
|s   |Equity share in new issues defined following Baker and Wurgler (2000), i.e., the total volume of equity issues over the prior twelve months divided by the total volume of equity and debt issues over the prior twelve months from Federal Reserve Bulletin                                                        |

|||
|--------|----------------------------------------------------------------------------------------------------------------------------------------------|
|indpro  |Industrial production index; we provide monthly data here; the orthogonalized index uses growth over the t-12 value                           |
|consdur |Nominal durables consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value   |
|consnon |Nominal nondurables consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value|
|consserv|Nominal services consumption; we provide monthly data here; the orthogonalized index uses growth in the real value over the t-12 real value   |
|recess  |NBER recession indicator                                                                                                                      |
|employ  |Employment; we provide monthly data here; the orthogonalized index uses growth over the t-12 value                                            |
|cpi     |Consumer price index (NOTE: CPI data is missing in Oct-2025 due to a government shut down.)                                                                             |



