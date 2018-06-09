/*==================================================
project:       save indicators
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     8 Jun 2018 - 16:01:39
Modification Date:   
Do-file version:    01
References:          
Output:             dta files
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_save
syntax anything(name=calcset id="set of calculations"), ///
basename(string) out(string) datetime(numlist) [case(string)]


/*==================================================
1: Save results
==================================================*/
cap noi datasignature confirm using /* 
*/    "`out'/_datasignature/`basename'", strict
if (_rc) {
	* Set signature
	cap noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/`basename'", replace)
	cap noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/`basename'_`datetime'")
	
	* save files
	save "`out'/_vintage/`basename'_`datetime'.dta"
	save "`out'/`basename'_wide.dta", replace
	
	* convert to long
	if inlist("`calcset'", "ine", "shp") {
		reshape long values, i(filename) j(`case') string
		order region countrycode year filename `case' values
	}
	
	else if ("`calcset'" == "pov") { // Poverty case
		reshape long fgt0_ fgt1_ fgt2_, i(filename date time vc_*) j(line)
		rename fgt*_ fgt*
		reshape long fgt, i(filename line date time vc_*) j(FGT)
		rename (FGT fgt) (fgt values)
		order region countrycode year filename  line fgt values
	}
	
	else {
		disp as err "calculation invalid"
		error
	}
	
	save "`out'/`basename'_long.dta", replace
}
else {
	noi disp "files `basename'* are identical to last version"
}


** ----------- Display Results
local regionsp "EAP ECA LAC MNA SAR SSA"

if ("`calcset'" == "pov") {
	local sname "Poverty"
	local disptab `"tabdisp year veralt line if (fgt == 0 & region == "\`regionp'"), c(values) by(countryname) concise"'
}
if ("`calcset'" == "ine") {
	local sname "Inequality"
	local disptab `"tabdisp year veralt ineq if (region == "\`regionp'"), c(values) by(countryname) concise"'
}
if ("`calcset'" == "shp") {
	local sname "Shared Prosperity"
	local disptab `"tabdisp year veralt case if (region == "\`regionp'" & inlist(case, "b40", "t60", "mean")), c(values) by(countryname) concise"'
}



noi disp in y _n `"{stata use "`out'/`basename'_long.dta": Load `sname' file}"'
foreach regionp of local regionsp {
	noi disp in y _n `"{stata `disptab':    `regionp'}"'
} // end of regions loop

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


