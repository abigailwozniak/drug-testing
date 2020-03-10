#delimit ;

* load the estimates from placebo iterations ;
*use placebo_results;
use Output/placebo_results;
summ ;
*list ;

global truediffc = 0.108 ;

histogram diffc, bin(100)
	xtitle("Estimated Difference in Employment Rates")
  xline($truediffc)
  saving("Output/placebograph.gph", replace) ;
