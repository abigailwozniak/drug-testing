set more off

log using ratechanges.log, replace

/*****

Read in data from SAMHSA on state level drug testing rates for years 99-01, 02-03, and 07-09.

Calculate changes in DT rates over time periods. Produces both weighted and unweighted stats.

*****/

set mem 50m

insheet using state_test_rates_NSDUH_9901.txt
summ

tempfile temp9901
sort statefips
save `temp9901', replace
clear

insheet using state_test_rates_NSDUH_0203.txt
summ

tempfile temp0203
sort statefips
save `temp0203', replace
clear

insheet using state_test_rates_NSDUH_0709.txt
summ

drop pro_anti

sort statefips
merge 1:1 statefips using `temp9901'
drop _merge

drop pro_anti

sort statefips
merge 1:1 statefips using `temp0203'
drop _merge

summ

*** Produces table with shares reporting yes for share any drug testing by employer and share testing at hire
*** Unweighted means of shares (which are supposed to be accurate at state level)

drop if statefips==0 | statefips==11

sort pro_anti statename

by pro_anti: list statename share_dt_9901 share_dt_0203 share_dt_0709 
by pro_anti: list statename share_hiring_9901 share_hiring_0203 share_hiring_0709
by pro_anti: list statename share_random_9901 share_random_0203 share_random_0709

by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709

by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 if inlist(statefips,22,30,44,50)==0
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709 if inlist(statefips,22,30,44,50)==0
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709 if inlist(statefips,22,30,44,50)==0

* above, weighted
by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 [fw=obs_dt_0203] if inlist(statefips,22,30,44,50)==0
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709 [fw=obs_dt_0203] if inlist(statefips,22,30,44,50)==0
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709 [fw=obs_dt_0203] if inlist(statefips,22,30,44,50)==0


*** Repeat means for states with most clear passage in 02-03 to 07-09 period

* LA passed pro in 2003
summ share_dt_9901 share_dt_0203 share_dt_0709 if statefips==22
summ share_hiring_9901 share_hiring_0203 share_hiring_0709 if statefips==22
summ share_random_9901 share_random_0203 share_random_0709 if statefips==22

* MT passed anti in 2005
summ share_dt_9901 share_dt_0203 share_dt_0709 if statefips==30
summ share_hiring_9901 share_hiring_0203 share_hiring_0709 if statefips==30
summ share_random_9901 share_random_0203 share_random_0709 if statefips==30

* MT plus RI and VT which passed anti in 2003
summ share_dt_9901 share_dt_0203 share_dt_0709 [fw=obs_dt_0203] if statefips==30 | statefips==44 | statefips==50
summ share_hiring_9901 share_hiring_0203 share_hiring_0709 [fw=obs_dt_0203] if statefips==30 | statefips==44 | statefips==50
summ share_random_9901 share_random_0203 share_random_0709 [fw=obs_dt_0203] if statefips==30 | statefips==44 | statefips==50

*** Better comparison states, those with low or high testing in 02-03 (weighted)

* low testing rate in 02-03
by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 <= 30)
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 <= 30)
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 <= 30)

* high testing rate in 02-03
by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 50)
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 50)
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 50)

* higher testing rate in 02-03
by pro_anti: summ share_dt_9901 share_dt_0203 share_dt_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 55)
by pro_anti: summ share_hiring_9901 share_hiring_0203 share_hiring_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 55)
by pro_anti: summ share_random_9901 share_random_0203 share_random_0709 [fw=obs_dt_0203] if (inlist(statefips,22,30,44,50)==0 & share_dt_0203 >= 55)



log close
clear


