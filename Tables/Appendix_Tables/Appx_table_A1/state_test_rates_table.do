set more off

log using state_test_rates_table.log, replace

*** Read in data from SAMHSA on share of respondents by state reporting 
*** employer drug testing policies in 2002-2003. This is from SAMHSA NAC Ad Hoc excel file.
*** Tabulate mean shares by state testing regime.

*cd "C:\Users\awaggone\Documents\Drug Testing"

*use statecode.dta
use Input/statecode.dta
sort alphaindex
list abbrev alphaindex fipscode
*save statecode.dta, replace
save Input/statecode.dta, replace
clear

insheet using state_test_rates_NSDUH.txt
summ

*** Produces table with shares reporting yes for share any drug testing by employer, share testing at hire, share random testing
*** Computes unweighted means of shares (which are supposed to be accurate at state level

sort pro_anti statename
by pro_anti: list statename share_dt share_hiring share_random
by pro_anti: summ share_dt share_hiring share_random

drop if statefips==0
sort statename
list statename statefips
merge 1:1 _n using statecode.dta
drop _merge

rename statefips statefip

*** Calculate means by region and division

g division=.
replace division=1 if inlist(statefip,09,23,25,33,44,50)
replace division=2 if inlist(statefip,34,36,42)
replace division=3 if inlist(statefip,17,18,26,39,55)
replace division=4 if inlist(statefip,19,20,27,29,31,38,46)
replace division=5 if inlist(statefip,10,11,12,13,24,37,45,51,54)
replace division=6 if inlist(statefip,01,21,28,47)
replace division=7 if inlist(statefip,05,22,40,48)
replace division=8 if inlist(statefip,04,08,16,30,32,35,49,56)
replace division=9 if inlist(statefip,02,06,15,41,53)

gen region=.
replace region=1 if division==1 | division==2
replace region=2 if division==3 | division==4
replace region=3 if division==5 | division==6 | division==7
replace region=4 if division==8 | division==9

tabulate region, summarize(share_dt)
tabulate division, summarize(share_dt)

log close
clear


