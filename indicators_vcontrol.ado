/*==================================================
project:       vintage control of indicators.ado
Author:        Andres Castaneda 
----------------------------------------------------------------------
Creation Date:     1 Jun 2018 - 15:32:22
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_vcontrol, rclass

syntax, vars(varlist)

qui {
	tempvar vermast veralt malt mdate mmst
	foreach var in vermast veralt {
		gen ``var'' = subinstr(upper(`var'), "V", "", .)
		destring ``var'', replace
	}
	
	bysort `vars': egen  `mmst' = max(`vermast')
	replace `mmst' = cond(`mmst' == `vermast', 1, 0)
	
	bysort `vars': egen  `malt' = max(`veralt') if (`mmst' == 1)
	replace `malt' = cond(`malt' == `veralt', 1, 0)
	
	
	bysort `vars' filename: egen double `mdate' = max(datetime) if (`malt' == 1)
	
	replace `mdate' = cond(`mdate' == datetime & `malt' == 1, 1, 0) 
	
	local dt: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
	* local dt: disp %tdDDMonCCYY date("12 May 2018", "DMY")
	local dt = trim("`dt'")
	cap confirm new var vc_`dt'
	if (_rc) drop vc_`dt'
	
	cap des vc_*, varlist
	if (_rc == 0) {
		
		
		local vcdates = "`r(varlist)'"
		local vcdates: subinstr local vcdates "vc_" "", all
		
		local vcnumbers ""
		foreach vcdate of local vcdates {
			local vcnumbers "`vcnumbers' `=date("`vcdate'", "DMY")'"
		}
		local vcnumbers = trim("`vcnumbers'")
		
		if (wordcount("`vcnumbers'") >1) {
			local vcnumbers: subinstr local vcnumbers " " ", ", all
			local maxvc: disp %tdDDmonCCYY max(`vcnumbers')
		}
		else {
			local maxvc: disp %tdDDmonCCYY `vcnumbers'
		}
		local maxvc = "vc_" + trim("`maxvc'")
	}
	else local maxvc ""
	
	if ("`maxvc'" != "") {
		cap assert `maxvc' == `mdate' if !missing(`maxvc', `mdate')
		if (_rc == 0) {
			noi disp "{ul:NOTE:} Vintage control variable for today (vc_`dt')" /* 
			*/ _c " is the same as the one last time (`maxvc')" _n
			exit 
		}
	}
	
	rename `mdate' vc_`dt'
	
}


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
