/***

Report share of establishments with a drug testing program

***/

clear
set more off
set mem 700m
set matsize 800

log using Table1_1997-2006.log, replace

cd ..
cd ../Data_Setup_NSDUH/.

*use "DRUGDATA_FINAL2.dta"
use Output/DRUGDATA_FINAL2.dta

cd ../Tables/Table_1/.

/* Share of establishments with a drug testing program by industry */

sum usdrgtst2 if employed==1 & age2249==1
sum usdrgtst2 if employed==1 & industry == 1 & age2249==1
sum usdrgtst2 if employed==1 & industry == 2 & age2249==1
sum usdrgtst2 if employed==1 & industry == 3 & age2249==1
sum usdrgtst2 if employed==1 & industry == 4 & age2249==1
sum usdrgtst2 if employed==1 & industry == 5 & age2249==1
sum usdrgtst2 if employed==1 & industry == 6 & age2249==1
sum usdrgtst2 if employed==1 & industry == 7 & age2249==1
sum usdrgtst2 if employed==1 & industry == 8 & age2249==1
sum usdrgtst2 if employed==1 & industry == 9 & age2249==1
sum usdrgtst2 if employed==1 & industry == 10 & age2249==1

/* Share of establishments with a drug testing program by establishment size */
bysort locsize: sum usdrgtst2 if employed==1 & age2249==1

