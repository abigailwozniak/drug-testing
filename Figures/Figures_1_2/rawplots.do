#delimit ;

log using rawplots.log, replace ;

/*****

Graph share in high testing industry by race over time.

*****/

set mem 1g ;
set matsize 800 ;
set more off ;

cd .. ;
cd ../Data_Setup_March_CPS/. ;

*"C:\Users\awaggone\Documents\Drug Testing\REStat revision\Data and do files\Data_March_CPS\marcps.dta" ;
use Output/marcps.dta ;
*use marcps_test.dta ;

cd ../Figures/Figures_1_2/. ;

summ year ;
tab1 year ;

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

drop if hisp==1 ;
preserve ;

collapse (mean) empdhi, by(year black) ;
summ ;
sort year ;

graph twoway connect empdhi year if black==0, msymbol(+) ||
  connect empdhi year if black==1,
  msymbol(S)
  legend(label(1 "Whites") label(2 "Blacks"))
  ytitle("")
  ti("Share of Employed in High Testing Industries")
  saving("Output/rawplots_year", replace) ;

clear ;

restore ;

drop if yrpro==0 & yranti==0 ;
tab1 state if yrpro >0 ;
tab1 state if yranti >0 ;

gen yearlaw=yrpro ;
replace yearlaw=yranti if yearlaw==0 ;
summ yearlaw ;
gen ttlaw = year - yearlaw ;
summ ttlaw ;

gen everpro=0 ;
replace everpro=1 if yrpro> 0 ;

*** Plots by time to law implementation ;
*** Raw and lowess mean smoothed relative to year zero mean - all data and trimmed to 10 years pre and post ;

collapse (mean) empdhi, by(ttlaw everpro black) ;
summ ;
sort ttlaw ;

graph twoway connect empdhi ttlaw if black==1 & everpro==1 ||
  connect empdhi ttlaw if black==1 & everpro==0 ||
  connect empdhi ttlaw if black==0 & everpro==1 ||
  connect empdhi ttlaw if black==0 & everpro==0 ,
  legend(label(1 "Blacks, Pro States") label(2 "Blacks, Anti States") label(3 "Whites, Pro States") label(4 "Whites, Anti States"))
  ti("Share of Employed in High Testing Industries")
  ytitle("")
  ylabel(.1 (.1) .5)
  xtitle("Years to Law Implementation")  
  saving("Output/rawplots_ttlaw", replace) ;

graph twoway connect empdhi ttlaw if black==1 & everpro==1 ||
  connect empdhi ttlaw if black==0 & everpro==1,
  legend(label(1 "Blacks, Pro States") label(2 "Whites, Pro States")) 
  ti("Share of Employed in High Testing Industries")
  ytitle("")
  yscale(range(.1 .5))
  ylabel(.1 (.1) .5)
  xtitle("Years to Law Implementation")  
  saving("Output/rawplots_ttlaw_pro", replace) ;

graph twoway scatter empdhi ttlaw if black==1 & everpro==1 & (ttlaw >= -10 & ttlaw <= 10)||
  scatter empdhi ttlaw if black==0 & everpro==1 & (ttlaw >= -10 & ttlaw <= 10),
  legend(label(1 "Blacks, Pro States") label(2 "Whites, Pro States")) 
  ti("Share of Employed in High Testing Industries")
  ytitle("")
  yscale(range(.1 .5))
  ylabel(.1 (.1) .5)
  xtitle("Years to Law Implementation")  
  saving("Output/rawplots_ttlaw_pro10yr", replace) ;  

graph twoway scatter empdhi ttlaw if black==1 & everpro==0 & (ttlaw >= -10 & ttlaw <= 10)||
  scatter empdhi ttlaw if black==0 & everpro==0 & (ttlaw >= -10 & ttlaw <= 10),
  legend(label(1 "Blacks, Anti States") label(2 "Whites, Anti States")) 
  ti("Share of Employed in High Testing Industries")
  ytitle("")
  yscale(range(.1 .5))
  ylabel(.1 (.1) .5)
  xtitle("Years to Law Implementation")  
  saving("Output/rawplots_ttlaw_anti10yr", replace) ;    
  

/** Generate smoothed series **/
  
lowess empdhi ttlaw if black==1 & everpro==1, mean adjust nograph generate(sm_empdhi_bp) ;
lowess empdhi ttlaw if black==0 & everpro==1, mean adjust nograph generate(sm_empdhi_wp) ;  
lowess empdhi ttlaw if black==1 & everpro==0, mean adjust nograph generate(sm_empdhi_ba) ;
lowess empdhi ttlaw if black==0 & everpro==0, mean adjust nograph generate(sm_empdhi_wa) ;

summ sm_* ;

gen zerorate=sm_empdhi_bp if black==1 & everpro==1 & ttlaw==0 ;
replace zerorate=sm_empdhi_wp if black==0 & everpro==1 & ttlaw==0 ;
replace zerorate=sm_empdhi_ba if black==1 & everpro==0 & ttlaw==0 ;
replace zerorate=sm_empdhi_wa if black==0 & everpro==0 & ttlaw==0 ;

bysort black everpro: egen mzerorate=max(zerorate) ;

gen asm_empdhi_wp = sm_empdhi_wp - mzerorate ;
gen asm_empdhi_bp = sm_empdhi_bp - mzerorate ;
gen asm_empdhi_wa = sm_empdhi_wa - mzerorate ;
gen asm_empdhi_ba = sm_empdhi_ba - mzerorate ;

sort ttlaw ;

/** Graphs of smoothed data **/

graph twoway connect asm_empdhi_bp ttlaw if black==1 ||
  connect asm_empdhi_wp ttlaw if black==0,
  legend(label(1 "Blacks, Pro States") label(2 "Whites, Pro States")) 
  ti("Share of Employed in High Testing Industries")
  subti("(Relative to Passage Year, Smoothed)")
  ytitle("")
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_lowess1", replace) ;

graph twoway connect asm_empdhi_ba ttlaw if black==1 ||
  connect asm_empdhi_wa ttlaw if black==0,
  legend(label(1 "Blacks, Anti States") label(2 "Whites, Anti States")) 
  ti("Share of Employed in High Testing Industries")
  subti("(Relative to Passage Year, Smoothed)")
  ytitle("")
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_lowess2", replace) ;

graph twoway connect asm_empdhi_bp ttlaw if black==1 & (ttlaw >= -10 & ttlaw <= 10), msymbol(+)  ||
  connect asm_empdhi_wp ttlaw if black==0 & (ttlaw >= -10 & ttlaw <= 10),
  msymbol(S)
  legend(label(1 "Blacks") label(2 "Whites")) 
  ti("Relative Employment in High Testing Industries")
  subti("(Pro-Testing States Only, Smoothed)")
  ytitle("")
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_lowess1trim10", replace) ;

graph twoway connect asm_empdhi_ba ttlaw if black==1 & (ttlaw >= -10 & ttlaw <= 10), msymbol(+)  ||
  connect asm_empdhi_wa ttlaw if black==0 & (ttlaw >= -10 & ttlaw <= 10),
  msymbol(S)
  legend(label(1 "Blacks") label(2 "Whites")) 
  ti("Relative Employment in High Testing Industries")
  subti("(Anti-Testing States Only, Smoothed)")
  ytitle("")
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_lowess2trim10", replace) ;
  
/** Graphs of smoothed data plus raw rates **/

graph twoway connect asm_empdhi_bp ttlaw if black==1 & (ttlaw >= -10 & ttlaw <= 10), yaxis(1) lcolor(black) mcolor(black) msymbol(triangle)||
  connect asm_empdhi_wp ttlaw if black==0 & (ttlaw >= -10 & ttlaw <= 10), yaxis(1) lcolor(gs8) mcolor(gs8) msymbol(circle)||
  scatter empdhi ttlaw if black==1 & everpro==1 & (ttlaw >= -10 & ttlaw <= 10), yaxis(2) msymbol(triangle_hollow) mcolor(black)||
  scatter empdhi ttlaw if black==0 & everpro==1 & (ttlaw >= -10 & ttlaw <= 10), yaxis(2) msymbol(circle_hollow) mcolor(gs8)||,
  legend(order(- "Left axis:" 1 2 - "Right axis:" 3 4) holes(2 6) label(1 "Blacks") label(2 "Whites") label(3 "Blacks") label(4 "Whites")) 
  ti("Employment in High Testing Industries: Pro-testing States")
  subti(" ")
  ytitle("ER relative to year zero, smoothed", axis(1))
  ytitle("Employment rate (ER)", axis(2))
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_proboth10", replace) ;

graph twoway connect asm_empdhi_ba ttlaw if black==1 & (ttlaw >= -10 & ttlaw <= 10), yaxis(1) lcolor(black) mcolor(black) msymbol(triangle)||
  connect asm_empdhi_wa ttlaw if black==0 & (ttlaw >= -10 & ttlaw <= 10), yaxis(1) lcolor(gs8) mcolor(gs8) msymbol(circle)||
  scatter empdhi ttlaw if black==1 & everpro==0 & (ttlaw >= -10 & ttlaw <= 10), yaxis(2) msymbol(triangle_hollow) mcolor(black)||
  scatter empdhi ttlaw if black==0 & everpro==0 & (ttlaw >= -10 & ttlaw <= 10), yaxis(2) msymbol(circle_hollow) mcolor(gs8)||,
  legend(order(- "Left axis:" 1 2 - "Right axis:" 3 4) holes(2 6) label(1 "Blacks") label(2 "Whites") label(3 "Blacks") label(4 "Whites")) 
  ti("Employment in High Testing Industries: Anti-testing States")
  subti(" ")
  ytitle("ER relative to year zero, smoothed", axis(1))
  ytitle("Employment rate (ER)", axis(2))
  xtitle("Years to Law Implementation")
  saving("Output/rawplots_ttlaw_antiboth10", replace) ;
    

clear ;

