********************************************************************************
*This file produces Appendix Table A2 (pg. 6 Supplementary Material)
*
*It uses the DRUGDATA_FINAL2.dta file that contains NSDUH data from 1979-2006
********************************************************************************
clear all
capture log close

log using appendix_table_a2.log, replace

cd ..
cd ..
cd ../Data_Setup_NSDUH/.

*use DRUGDATA_FINAL2.dta
use Output/DRUGDATA_FINAL2.dta

cd ../Tables/Appendix_Tables/Appx_table_A2/.

*Drop people younger than 18
drop if age<7

*Drop people 65 or older
drop if age>16

*Create decades
gen decade = 1980
replace decade = 1990 if surveyyr > 1989 & surveyyr < 2000
replace decade = 2000 if surveyyr >= 2000

tab surveyyr decade

gen period = "1990-2006"
replace period = "1980s" if surveyyr < 1990

**RACE**************************************************************************

gen new_white = 0
replace new_white = 1 if white == 1 & hispanic == 0
drop white
rename new_white white

gen new_black = 0
replace new_black = 1 if black == 1 & hispanic == 0
drop black
rename new_black black

gen other = 0
replace other = 1 if (black == 0 & white == 0 & hispanic == 0)

local drugs sum mrj iem
foreach d of local drugs {
	gen white_`d' = 0 if white == 1
	replace white_`d' = 1 if `d'mon == 1 & white == 1
	replace white_`d' = . if `d'mon == . & white == 1

	gen black_`d' = 0 if black == 1
	replace black_`d' = 1 if `d'mon == 1 & black == 1
	replace black_`d' = . if `d'mon == . & black == 1

	gen hispanic_`d' = 0 if hispanic == 1
	replace hispanic_`d' = 1 if `d'mon == 1 & hispanic == 1
	replace hispanic_`d' = . if `d'mon == . & hispanic == 1
	
	gen other_`d' = 0 if other == 1
	replace other_`d' = 1 if `d'mon ==1 & other == 1
	replace other_`d' = . if `d'mon == . & other == 1
}
	
local race white black hispanic other
local drugs sum mrj iem
foreach y of local race {
	foreach z of local drugs {
		bysort decade: egen `y'_decade_nm_`z' = total(`y') if `y'_`z' != .
		bysort period: egen `y'_period_nm_`z' = total(`y') if `y'_`z' != .
		
		*Decadal totals and percent
		bysort decade: egen `y'_`z'_decade = total(`y'_`z')
		gen `y'_`z'_pct_decade = `y'_`z'_decade/`y'_decade_nm_`z'
		replace `y'_`z'_pct_decade = . if `y'_`z'_pct_decade == 0
		
		*Period totals and percent
		bysort period: egen `y'_`z'_period = total(`y'_`z')
		gen `y'_`z'_pct_period = `y'_`z'_period/`y'_period_nm_`z'
		replace `y'_`z'_pct_period = . if `y'_`z'_pct_period == 0
		}
	}

preserve

collapse white_mrj_pct_decade white_iem_pct_decade ///
		 black_mrj_pct_decade black_iem_pct_decade ///
		 hispanic_mrj_pct_decade hispanic_iem_pct_decade ///
		 other_mrj_pct_decade other_iem_pct_decade, by(decade)

*Total percent within decade
*White drug use by decade (mrj = Marijuana, iem = Other)
list decade white_mrj_pct_decade white_iem_pct_decade, table
*Black drug use by decade (mrj = Marijuana, iem = Other)
list decade black_mrj_pct_decade black_iem_pct_decade, table
*Hispanic drug use by decade (mrj = Marijuana, iem = Other)
list decade hispanic_mrj_pct_decade hispanic_iem_pct_decade, table
*Other race drug use by decade (mrj = Marijuana, iem = Other)
list decade other_mrj_pct_decade other_iem_pct_decade, table

restore
preserve

collapse white_sum_pct_period black_sum_pct_period hispanic_sum_pct_period other_sum_pct_period, by(period)
*Any drug use in last month
list period white_sum_pct_period black_sum_pct_period hispanic_sum_pct_period other_sum_pct_period

restore

**GENDER/SEX********************************************************************

fre gender

gen women = 0
replace women = 1 if gender == 0

gen men = 0
replace men = 1 if gender == 1

local drugs sum mrj iem
foreach d of local drugs {
	gen men_`d' = men*(`d'mon)
	replace men_`d' = . if `d'mon == .
	
	gen women_`d' = women*(`d'mon)
	replace women_`d' = . if `d'mon == .
}

local gender men women
local drugs sum mrj iem
foreach y of local gender {
	foreach z of local drugs {
		bysort decade: egen `y'_decade_nm_`z' = total(`y') if `y'_`z' != .
		bysort period: egen `y'_period_nm_`z' = total(`y') if `y'_`z' != .
		
		*Decadal totals and percent
		bysort decade: egen `y'_`z'_decade = total(`y'_`z')
		gen `y'_`z'_pct_decade = `y'_`z'_decade/`y'_decade_nm_`z'
		replace `y'_`z'_pct_decade = . if `y'_`z'_pct_decade == 0
		
		*Period totals and percent
		bysort period: egen `y'_`z'_period = total(`y'_`z')
		gen `y'_`z'_pct_period = `y'_`z'_period/`y'_period_nm_`z'
		replace `y'_`z'_pct_period = . if `y'_`z'_pct_period == 0
		}
	}

preserve
	 
collapse men_mrj_pct_decade men_iem_pct_decade ///
		 women_mrj_pct_decade women_iem_pct_decade, by(decade)

*Total percent within decade
*Men drug use by decade (mrj = Marijuana, iem = Other)
list decade men_mrj_pct_decade men_iem_pct_decade, table
*Women drug use by decade (mrj = Marijuana, iem = Other)
list decade women_mrj_pct_decade women_iem_pct_decade, table

restore
preserve

collapse men_sum_pct_period women_sum_pct_period, by(period)
*Any drug use in last month
list period men_sum_pct_period women_sum_pct_period

restore

**AGE***************************************************************************

fre age
gen young = 0
replace young = 1 if age <=12

gen old = 0
replace old = 1 if age > 12

local drugs sum mrj iem
foreach d of local drugs {
	gen young_`d' = 0 if young == 1
	replace young_`d' = 1 if `d'mon == 1 & young == 1
	replace young_`d' = . if `d'mon == .
	
	gen old_`d' = 0 if old == 1
	replace old_`d' = 1 if `d'mon == 1 & old == 1
	replace old_`d' = . if `d'mon == .
}

local ages young old 
local drugs sum mrj iem
foreach y of local ages {
	foreach z of local drugs {
		*Decadal totals and percent
		bysort decade: egen `y'_decade_nm_`z' = total(`y') if `y'_`z' != .
		bysort period: egen `y'_period_nm_`z' = total(`y') if `y'_`z' != .
		
		*Decadal totals and percent
		bysort decade: egen `y'_`z'_decade = total(`y'_`z')
		gen `y'_`z'_pct_decade = `y'_`z'_decade/`y'_decade_nm_`z'
		replace `y'_`z'_pct_decade = . if `y'_`z'_pct_decade == 0
		
		*Period totals and percent
		bysort period: egen `y'_`z'_period = total(`y'_`z')
		gen `y'_`z'_pct_period = `y'_`z'_period/`y'_period_nm_`z'
		replace `y'_`z'_pct_period = . if `y'_`z'_pct_period == 0
		}
	}

preserve
		 
collapse young_mrj_pct_decade young_iem_pct_decade ///
		 old_mrj_pct_decade old_iem_pct_decade, by(decade)

*Total percent within decade
*<26 drug use by decade (mrj = Marijuana, iem = Other)
list decade young_mrj_pct_decade young_iem_pct_decade, table
*>25 drug use by decade (mrj = Marijuana, iem = Other)
list decade old_mrj_pct_decade old_iem_pct_decade, table

restore
preserve

collapse young_sum_pct_period old_sum_pct_period, by(period)
*Any drug use in last month
list period young_sum_pct_period old_sum_pct_period

restore

**EDUCATION*********************************************************************

fre educcat2

gen low = 0
replace low = 1 if (educcat2 == 1 | educcat2 == 2)

gen high = 0
replace high = 1 if (educcat2 == 3 | educcat2 == 4)


local drugs sum mrj iem
foreach d of local drugs {
	gen low_`d' = 0 if low == 1
	replace low_`d' = 1 if `d'mon == 1 & low == 1
	replace low_`d' = . if `d'mon == .
	
	gen high_`d' = 0 if high == 1
	replace high_`d' = 1 if `d'mon == 1 & high == 1
	replace high_`d' = . if `d'mon == .
}

local educ1 low high 
local drugs sum mrj iem
foreach y of local educ1 {
	foreach z of local drugs {	
		*Decadal totals and percent
		bysort decade: egen `y'_decade_nm_`z' = total(`y') if `y'_`z' != .
		bysort period: egen `y'_period_nm_`z' = total(`y') if `y'_`z' != .
		
		*Decadal totals and percent
		bysort decade: egen `y'_`z'_decade = total(`y'_`z')
		gen `y'_`z'_pct_decade = `y'_`z'_decade/`y'_decade_nm_`z'
		replace `y'_`z'_pct_decade = . if `y'_`z'_pct_decade == 0
		
		*Period totals and percent
		bysort period: egen `y'_`z'_period = total(`y'_`z')
		gen `y'_`z'_pct_period = `y'_`z'_period/`y'_period_nm_`z'
		replace `y'_`z'_pct_period = . if `y'_`z'_pct_period == 0
		}
	}

preserve
		 
collapse low_mrj_pct_decade low_iem_pct_decade ///
		 high_mrj_pct_decade high_iem_pct_decade, by(decade)

*Total percent within decade
*Low educated drug use by decade (mrj = Marijuana, iem = Other)
list decade low_mrj_pct_decade low_iem_pct_decade, table
*Highly educated drug use by decade (mrj = Marijuana, iem = Other)
list decade high_mrj_pct_decade high_iem_pct_decade, table

restore
preserve

collapse low_sum_pct_period high_sum_pct_period, by(period)
*Any drug use in last month
list period low_sum_pct_period high_sum_pct_period

restore

**MUTALLY EXCLUSIVE GROUPS******************************************************

local educ1 low high
local race black white
local genders men women
local drugs sum mrj iem
foreach x of local educ1 {
	foreach y of local race {
		foreach z of local genders {
			gen `x'_`y'_`z' = `x'*`y'*`z'
			foreach a of local drugs {
				replace `x'_`y'_`z' = . if `a'mon == .
				
				gen `x'_`y'_`z'_`a' = `x'*`y'*`z'*(`a'mon)
				replace `x'_`y'_`z'_`a' = . if `a'mon == .
				
				bysort decade: egen `x'_`y'_`z'_dec_nm_`a' = total(`x'_`y'_`z') if `x'_`y'_`z'_`a' != .
				bysort period: egen `x'_`y'_`z'_per_nm_`a' = total(`x'_`y'_`z') if `x'_`y'_`z'_`a' != .
				
				*Decadal totals and percent
				bysort decade: egen `x'_`y'_`z'_`a'_dec = total(`x'_`y'_`z'_`a')
				gen `x'_`y'_`z'_`a'_pct_dec = `x'_`y'_`z'_`a'_dec/`x'_`y'_`z'_dec_nm_`a'
				replace `x'_`y'_`z'_`a'_pct_dec = . if `x'_`y'_`z'_`a'_pct_dec == 0
				
				*Decadal totals and percent
				bysort period: egen `x'_`y'_`z'_`a'_per = total(`x'_`y'_`z'_`a')
				gen `x'_`y'_`z'_`a'_pct_per = `x'_`y'_`z'_`a'_per/`x'_`y'_`z'_per_nm_`a'
				replace `x'_`y'_`z'_`a'_pct_per = . if `x'_`y'_`z'_`a'_pct_per == 0
				}
			}
		}
	}

preserve

collapse low_black_men_mrj_pct_dec low_black_men_iem_pct_dec ///
		 high_black_men_mrj_pct_dec high_black_men_iem_pct_dec ///
		 low_black_women_mrj_pct_dec low_black_women_iem_pct_dec ///
		 high_black_women_mrj_pct_dec high_black_women_iem_pct_dec ///
		 low_white_men_mrj_pct_dec low_white_men_iem_pct_dec ///
		 high_white_men_mrj_pct_dec high_white_men_iem_pct_dec ///
		 low_white_women_mrj_pct_dec low_white_women_iem_pct_dec ///
		 high_white_women_mrj_pct_dec high_white_women_iem_pct_dec, by(decade)

*Total percent within decade
*LS Black Men
list decade low_black_men_mrj_pct_dec low_black_men_iem_pct_dec, table
*HS Black Men
list decade high_black_men_mrj_pct_dec high_black_men_iem_pct_dec, table
*LS Black Women
list decade low_black_women_mrj_pct_dec low_black_women_iem_pct_dec, table
*HS Black Women
list decade high_black_women_mrj_pct_dec high_black_women_iem_pct_dec, table
*LS White Men
list decade low_white_men_mrj_pct_dec low_white_men_iem_pct_dec, table
*HS White Men
list decade high_white_men_mrj_pct_dec high_white_men_iem_pct_dec, table
*LS White Women
list decade low_white_women_mrj_pct_dec low_white_women_iem_pct_dec, table
*HS White Women
list decade high_white_women_mrj_pct_dec high_white_women_iem_pct_dec, table

restore
preserve

collapse low_black_men_sum_pct_per ///
		 high_black_men_sum_pct_per ///
		 low_black_women_sum_pct_per ///
		 high_black_women_sum_pct_per ///
		 low_white_men_sum_pct_per ///
		 high_white_men_sum_pct_per ///
		 low_white_women_sum_pct_per ///
		 high_white_women_sum_pct_per, by(period)

*Any drug use - average 1990-2006
*LS Black Men
list period low_black_men_sum_pct_per, table
*HS Black Men
list period high_black_men_sum_pct_per, table
*LS Black Women
list period low_black_women_sum_pct_per, table
*HS Black Women
list period high_black_women_sum_pct_per, table
*LS White Men
list period low_white_men_sum_pct_per, table
*HS White Men
list period high_white_men_sum_pct_per, table
*LS White Women
list period low_white_women_sum_pct_per, table
*HS White Women
list period high_white_women_sum_pct_per, table

restore

log close






