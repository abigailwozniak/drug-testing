#delimit ;
capture log close;

log using Table3_divisions2.log, replace ;

/*****

Tests prediction that testing sector employment of non-users increased in post periods.
Second prediction, that this is larger for blacks is also tested.
Specifications with SEs printed using estimates table are those reported in paper.

*****/

set mem 700m ;
set matsize 300 ;
set more off ;

cd .. ;
cd ../Data_Setup_NSDUH/. ;
use Output/DRUGDATA_FINAL2.dta ;
 
cd ../Tables/Table_3/. ;

*use drugdata_hitest.dta ;
*use "H:\Other\Data and do files\Data and do files\Data_NSDUH\DRUGDATA_FINAL2.dta" ;

summ surveyyr ;
tab1 surveyyr ;

*gen young=(age<=12) ;
gen young=age1825 ;

***This drops people younger than 18;
drop if age<7;
***This drops people 65 or older;
drop if age>16;

*gen edgrp4=education if education <5;
gen edgrp4=educcat2 if educcat2 <5;

* High testing ind dummy ;
*label define industry 1 "Mining" 2 "Comm, util, trans" 3 "Manufacturing" 4 "Construction"
5 "Wholesale trade" 6 "Retail trade" 7 "FIRE" 8 "Services" 9 "Agriculture" 10 "Government" 11 "Missing" ;

gen empdhi=1 if employed==1 & inlist(industry,1,2, 3, 10)==1 ;
replace empdhi=0 if employed==1 & inlist(industry,4,5,6,7,8,9)==1 ;

tab1 surveyyr ;
drop if empdhi==. ;  * This drops years before 1985 - no industry data ;
tab1 surveyyr ;

* Drug use variables ;

gen usermon=summon ;
gen useryr=0 ;
replace useryr=1 if mrjyr==1 | inhyr==1 | anlyr==1 | stmyr==1 | sedyr==1 ;
gen useryr2=useryr ;
replace useryr2=1 if iemyr==1 ; * this var only available for 1990 on.

*rename anydrug  user;
rename employed empd;

gen female = 1 if gender==0;
replace female = 0  if gender==1;

replace age2=age*age ;

rename hispanic hisp;
rename surveyyr  year;

*drop if year > 1999 ;
drop if year > 1997 ; * No division data for 1998 and 1999. ;

* Construct period variables ;

gen p8893=(year>=1988 & year<=1993) ;
gen p9499=(year>=1994 & year<=1999) ;
gen post=(p9499==1) ;

* Code divisions by testing rates in NSDUH state data: 1=lowest, 3=highest ;
* These are tabulated in state_test_rates_table.do - 3 is borderline, could go with 6 & 7 ;

gen divtest=. ;
replace divtest=1 if inlist(division,1,2,9)==1 ;
replace divtest=2 if inlist(division,4,5,8)==1 ;
replace divtest=3 if inlist(division,6,7,3)==1 ;

summ year useryr useryr2 usermon divtest ;

** Create controls for regression adjustment ;

* group specific qtts ;
gen tt=year-1980 ;
gen qtt=tt*tt ;
gen ctt=tt*qtt ;

gen btt=black*tt ;
gen htt=hisp*tt ;
gen ftt=female*tt ;
gen ytt=young*tt ;
gen bqtt=black*qtt ;
gen hqtt=hisp*qtt ;
gen fqtt=female*qtt ;
gen yqtt=young*qtt ;
gen bctt=black*ctt ;
gen hctt=hisp*ctt ;
gen fctt=female*ctt ;
gen yctt=young*ctt ;

char edgrp4[omit] 2 ;
xi, prefix(_E) i.edgrp4*tt i.edgrp4*qtt i.edgrp4*ctt ;

xi, prefix(_D) i.division*black i.division*hisp i.division*female i.division*young i.division*i.edgrp4 i.division*tt ;
drop _Dedgrp4* ;

global controls1 black hisp female age age2 _E* _D*
  tt qtt ctt btt htt ftt ytt bqtt hqtt fqtt yqtt bctt hctt fctt yctt ;

reg empdhi $controls1 ;
predict rempdhi, resid ;

summ empdhi rempdhi ;

*** Tabulate means of resid empdhi by divtest and time period ;

gen timepd=. ;
replace timepd=1 if year>=1985 & year<=1988 ;
replace timepd=2 if year>=1989 & year<=1993 ;
replace timepd=3 if year>=1994 ;
tab1 timepd ;

summ timepd divtest ;

sort timepd divtest ;

by timepd divtest: ttest rempdhi, by(useryr) ;
by timepd divtest: ttest rempdhi, by(usermon) ;
by timepd divtest: ttest rempdhi if black==1, by(usermon) ;
by timepd divtest: ttest rempdhi if black==0 & hisp==0, by(usermon) ;


log close ;
clear ;

