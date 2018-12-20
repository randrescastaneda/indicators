/*==================================================
project:       transform old files shape to new saving way
Author:        Andres Castaneda 
----------------------------------------------------
Creation Date:    20 Dec 2018 - 09:02:07
==================================================*/

/*==================================================
                        0: Program set up
==================================================*/
program define indicators_newsavingway, rclass

if ("`1'" != "prepare") exit 

local out  "\\wbgfscifs01\GTSD\02.core_team\02.data\01.Indicators"

if ("`2'" == "") local indicators "pov ine shp key"
else             local indicators "`2'"

foreach i of local indicators {
	if ("`i'" == "key") local precase "precase"
	else                local precase ""
	indicators `i', load
	indicators_vcselect, maxdate
	if ("`r(vcdate)'" == "vc_") {
		noi datasignature set, reset /* 
		*/    saving("`out'/_datasignature/indicators_`i'_wide", replace)
		continue 
	}
	local vcvar = "`r(maxdate)'" 
	keep if `vcvar' == 1
	duplicates report filename welfarevar `precase'
	cap assert r(unique_value) == r(N)
	if (_rc) {
		noi disp in red "check unique values in `i'"
		continue
	}
	drop vc_*
	preserve 
		keep date time datetime filename welfarevar
		save "`out'/_keys/indicators_`i'_key", replace
	restore 
	save, replace 
}



end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
