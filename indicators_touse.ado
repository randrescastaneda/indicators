/*==================================================
project:       vintage control of indicators.ado
Author:        Andres Castaneda 
----------------------------------------------------------------------
Creation Date:     1 Jun 2018 - 15:32:22
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_touse, rclass

syntax [anything(name=calcset id="set of calculations")], [ ///
			vars(varlist) ///
			pause         ///
]

qui {
	if ("`pause'" == "pause") pause on
	else pause off
	
	/*==================================================
	1: Vintage Control Variables
	==================================================*/
	
	tempvar vermast veralt malt mdate mmst
	
	if ("`vars'" == "") local vars "countrycode year survname type module"
	if !inlist("`calcset'", "wdi") {
		
		foreach var in vermast veralt {
			gen ``var'' = subinstr(upper(`var'), "V", "", .)
			destring ``var'', replace
		}
		
		bysort `vars': egen  `mmst' = max(`vermast')
		replace `mmst' = cond(`mmst' == `vermast', 1, 0)
		
		bysort `vars': egen  `malt' = max(`veralt') if (`mmst' == 1)
		replace `malt' = cond(`malt' == `veralt', 1, 0) if (`mmst' == 1)
		
	}
	
	if ("`calcset'" == "wdi") {
		* this part is not done yet. 
		
		
	}
	
	cap confirm var _touse
	if (_rc) {
		gen _touse = `malt'
	}
	else {
		cap assert _touse == `malt'
		if (_rc) {
			noi disp in y "variable _touse has changed"
			list `vars' if _touse != `malt'
			replace _touse = `malt'
		}
	}
	tempvar tmean
	egen `tmean' = mean(_touse), by(`vars')
	sum `tmean', meanonly
	if r(mean) != 1 {
		noi tabdisp year veralt  vermast  if `tmean' != 1, /* 
	 */	 c( survname ) by( countrycode type ) concise
	}
	
	
}


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
