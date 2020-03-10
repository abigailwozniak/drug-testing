#delimit ;

log using specifications.log, replace ;

/*****

Build up to preferred specification from basic D-in-D style spec.

*****/

set mem 6g ;
set matsize 800 ;
set more off ;

cd .. ;
cd .. ;
cd ../Data_Setup_March_CPS/. ;

use Output/marcps.dta ;

cd ../Tables/Appendix_Tables/Appx_table_A4/. ;

*use "/afs/crc.nd.edu/user/a/awaggone/Private/Private/Drugs_2011/marcps.dta" ;
*use "/afs/crc.nd.edu/user/a/awaggone/Private/Private/Drugs_2011/marcps_test.dta" ;

/** Construct variables for estimation **/

* Pro and anti dummies, by state-year ;
gen pro=0 ;
replace pro=1 if (year>=yrpro & yrpro~=0) ;
gen anti=0 ;
replace anti=1 if (year>=yranti & yranti~=0) ;

* Reduce education groups to 2 ;
gen lowskill=1 if edgrp4==1 | edgrp4==2 ;
replace lowskill=0 if edgrp4==3 | edgrp4==4 ;

gen young=(age<=25) ;
summ young lowskill ;

gen age2=age*age ;

* demog-pro and anti interactions ;
gen blackpro=black*pro ;
gen hisppro=hisp*pro ;
gen femalepro=female*pro ;
gen youngpro=young*pro ;
gen lowskillpro=lowskill*pro ;

gen blackanti=black*anti ;
gen hispanti=hisp*anti ;
gen femaleanti=female*anti ;
gen younganti=young*anti ;
gen lowskillanti=lowskill*anti ;

* Time cubics and their double interactions ;
gen ttrend=year - 1980 ;
sum ttrend ;
gen ttrend2=ttrend^2 ;
gen ttrend3=ttrend^3 ;

gen ttrendbl=ttrend*black ; gen ttrend2bl=ttrend2*black ; gen ttrend3bl=ttrend3*black ;
gen ttrendhi=ttrend*hisp ; gen ttrend2hi=ttrend2*hisp ; gen ttrend3hi=ttrend3*hisp ;
gen ttrendfe=ttrend*female ; gen ttrend2fe=ttrend2*female ; gen ttrend3fe=ttrend3*female ;
gen ttrendyo=ttrend*young ; gen ttrend2yo=ttrend2*young ; gen ttrend3yo=ttrend3*young ;
gen ttrendlo=ttrend*lowskill ; gen ttrend2lo=ttrend2*lowskill ; gen ttrend3lo=ttrend3*lowskill ;

* State dummies and their interactions with demographics plus linear state trends ;

char statefip[omit] 17 ; * omit IL - set this so not omitting a pro or anti state ;

/** Outcome variables **/

gen empdhi=1 if empd==1 & inlist(ind1,1,4,5,3,11)==1 ;
replace empdhi=0 if empd==1 & inlist(ind1,1,4,5,3,11)~=1 ;
summ empdhi ;

gen empdmid=1 if firmsizer==2 | firmsizer==3 ;
replace empdmid=0 if firmsizer==1 | firmsizer==4 ;

gen empdlg=1 if firmsizer==4 ;
replace empdlg=0 if firmsizer==1 | firmsizer==2 | firmsizer==3 ;

gen ph=. ;
replace ph=1 if pensionr==1 | inclughr==1 ;
replace ph=0 if pensionr==0 & inclughr==0 ;
replace ph=. if pensionr==. | inclughr==. ;

summ empdmid empdlg ph ;

gen lrhw=log(rhwage) ;


/** Estimations **/

/** Main specification with DTI interactions **/

*** Spec 1: Basic DD - state and year FE plus linear state trends ;

xi, prefix(_S) i.statefip*ttrend ;
xi, prefix(_T) i.year ;

global controls blackpro hisppro femalepro youngpro lowskillpro pro
  black hisp female lowskill age age2
  _T* _S* ;
  
global outvars blackpro hisppro femalepro youngpro lowskillpro pro
  black hisp female lowskill age age2 ;
  
reg empdhi $controls [pw=wtsupp], cluster(statefip) ;
estimates store empdhi1 ;

*** Spec 2: Add demog group specific state FE to Spec 1 ;

drop _S* ;
xi, prefix(_S) i.statefip*black i.statefip*hisp i.statefip*female i.statefip*young i.statefip*lowskill 
  i.statefip*ttrend ;

reg empdhi $controls [pw=wtsupp], cluster(statefip) ;
estimates store empdhi2 ;

*** Spec 3: Add cubic state trends and demog group specific year FE ;

drop _S* ;
xi, prefix(_S) i.statefip*black i.statefip*hisp i.statefip*female i.statefip*young i.statefip*lowskill 
  i.statefip*ttrend i.statefip*ttrend2 i.statefip*ttrend3 ;

drop _T* ;
xi, prefix(_T) i.year*black i.year*hisp i.year*female i.year*young i.year*lowskill ;

global controls blackpro hisppro femalepro youngpro lowskillpro pro
  black hisp female lowskill age age2
  _T* _S* ;
  
reg empdhi $controls [pw=wtsupp], cluster(statefip) ;
estimates store empdhi3 ;


*** Spec 4: Sub demog group specific cubic time trends for group specific year FE ;

drop _S* _T* ;
xi, prefix(_S) i.statefip*black i.statefip*hisp i.statefip*female i.statefip*young i.statefip*lowskill 
  i.statefip*ttrend i.statefip*ttrend2 i.statefip*ttrend3 ;

global controls blackpro hisppro femalepro youngpro lowskillpro pro
  black hisp female lowskill age age2
  tt* _S* ;
  
reg empdhi $controls [pw=wtsupp], cluster(statefip) ;
estimates store empdhi4 ;

*** Spec 5: Add time varying state controls to Spec 4 - this drops 2007-2010 ;

drop _S* ;
xi, prefix(_S) i.statefip*black i.statefip*hisp i.statefip*female i.statefip*young i.statefip*lowskill 
  i.statefip*ttrend i.statefip*ttrend2 i.statefip*ttrend3 ;

global controls blackpro hisppro femalepro youngpro lowskillpro pro
  black hisp female lowskill age age2
  minwage unemploymentrate incarcr
  tt* _S* ;
  
reg empdhi $controls [pw=wtsupp], cluster(statefip) ;
estimates store empdhi5 ;

estimates table empdhi1 empdhi2 empdhi3 empdhi4 empdhi5, keep($outvars) b(%7.3f) se(%7.3f) stats(N) ;
estimates table empdhi1 empdhi2 empdhi3 empdhi4 empdhi5, keep($outvars) b(%7.3f) star ;


log close ;
clear ;

