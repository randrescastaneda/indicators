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

syntax [anything], [ ///
			INDicators(string) ///
			vintage         ///
]

if ("`anything'" != "prepare") exit 

local out  "\\wbgfscifs01\GTSD\02.core_team\02.data\01.Indicators"

if ("`indicators'" == "") local indicators "pov ine shp key"


foreach i of local indicators {
	if ("`i'" == "key") local precase "precase"
	else                local precase ""
	
	if ("`vintage'" != "") {
		local files: dir "`out'/_vintage" files "indicators_`i'*"
		foreach file of local files {
			use "`out'/_vintage/`file'", clear
			
			indicators_vcselect, maxdate
			if ("`r(vcdate)'" == "vc_") {
				noi disp "no vc variables for `file'"
				continue 
			}
			local vcvar = "`r(maxdate)'" 
			keep if `vcvar' == 1
			if ("`i'" == "key") {
				cap confirm new var case
				if (_rc) local precase case
				else     local precase "precase"
			}
			cap duplicates report filename welfarevar `precase'
			if (_rc) cap duplicates report filename  `precase'
			if (_rc) duplicates report filename 
			cap assert r(unique_value) == r(N)
			if (_rc) {
				noi disp in red "check unique values in `file'"
				continue
			}
			drop vc_*
			indicators_touse `i', `pause'
			save, replace 
		}
	} 
	
	else {
		indicators `i', load
		indicators_vcselect, maxdate
		if ("`r(vcdate)'" == "vc_") {
			noi datasignature set, reset /* 
			*/    saving("`out'/_datasignature/indicators_`i'", replace)
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
			keep date time datetime filename welfarevar `precase'
			save "`out'/_keys/indicators_`i'_key", replace
		restore 
		save, replace 
	}
}



end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
