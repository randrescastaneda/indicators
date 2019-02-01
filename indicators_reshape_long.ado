/*==================================================
project:       save in long format indicators files
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     1 Feb 2019 - 10:44:41
Modification Date:   
Do-file version:    01
References:          
Output:             dta file
==================================================*/

/*==================================================
                        0: Program set up
==================================================*/
program define indicators_reshape_long, rclass

syntax anything(name=calcset id="set of calculations")

 version 14


/*==================================================
              Depending on calcset
==================================================*/
if ("`calcset'" == "key")  local precase "precase"
else                       local precase ""



*------ Remove all vc_ but the last one. 
drop if _touse != 1

local vars "filename datetime welfarevar `precase'"

*----- indicator-specific modifications -----------
if inlist("`calcset'", "ine", "shp") {
	reshape long values, i(`vars') j(case) string
	
	order region countrycode year filename welfarevar case values
}
else if inlist("`calcset'", "key") {
	reshape long values, i(`vars') j(case) string
	
	replace case = precase+case
	drop precase
	order region countrycode year filename welfarevar case values
}	
else if ("`calcset'" == "pov") { // Poverty case
	
	reshape long fgt0_ fgt1_ fgt2_, i(`vars') j(line)
	rename fgt*_ fgt*
	
	reshape long fgt, i(`vars' line) j(FGT)
	rename (FGT fgt) (fgt values)
	order region countrycode year filename welfarevar line fgt values
}		
else if ("`calcset'" == "wdi") { // WDI indicators
	des, varlist
	local wdivars = "`r(varlist)'"
	foreach var of local wdivars {
		if regexm("`var'", "vc_") continue
		if regexm("`var'", "_") local indvars "`indvars' `var'"
	}
	rename (`indvars') values=
	
	cap des vc_*, varlist
	if (_rc ==0) local vcvars = "`r(varlist)'"
	else         local vcvars = ""
	
	reshape long values, i(regioncode countrycode year date time `vcvars') j(case) string
}
else {
	disp as err "calculation invalid"
	error
}

char _dta[shape]   "long"	


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


