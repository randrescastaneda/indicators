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
basename(string) out(string) datetime(numlist) [ force ]


/*==================================================
1: Save results
==================================================*/
qui {
	cap noi datasignature confirm using /* 
	*/    "`out'/_datasignature/`basename'", strict
	if (_rc | "`force'" == "force") {
		* Set signature
		noi datasignature set, reset /* 
		*/    saving("`out'/_datasignature/`basename'", replace)
		noi datasignature set, reset /* 
		*/    saving("`out'/_datasignature/`basename'_`datetime'", replace)
		
		* save files
		save "`out'/_vintage/`basename'_`datetime'.dta", replace
		save "`out'/`basename'_wide.dta", replace
		
		*------------------------------------------------
		*------------ convert to long--------------------
		*------------------------------------------------
		
		*------ Remove all vc_ but the last one. 
		indicators_vcselect, maxdate
		local vcvar = "`r(maxdate)'" 
		keep if `vcvar' == 1
		
		desc vc_*, varlist
		local vclist = "`r(varlist)'"
		local vclist: list vclist - vcvar
		if ("`vclist'" != "") drop `vclist'
		
		
		*----- indicator-specific modifications -----------
		if inlist("`calcset'", "ine", "shp") {
			reshape long values, i(filename  datetime vc_* welfarevar) /* 
			*/     j(case) string
			
			order region countrycode year filename welfarevar case values
		}
		else if inlist("`calcset'", "key") {
			reshape long values, i(filename  datetime vc_* welfarevar precase) /* 
			*/     j(case) string
			
			replace case = precase+case
			drop precase
			order region countrycode year filename welfarevar case values
		}	
		else if ("`calcset'" == "pov") { // Poverty case
			
			reshape long fgt0_ fgt1_ fgt2_, i(filename datetime vc_* welfarevar ) j(line)
			rename fgt*_ fgt*
			
			reshape long fgt, i(filename datetime vc_* welfarevar line) j(FGT)
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
	local disptab `"tabdisp year veralt case if (region == "\`regionp'"), c(values) by(countryname) concise"'
	}
	if ("`calcset'" == "shp") {
	local sname "Shared Prosperity"
	local disptab `"tabdisp year veralt case if (region == "\`regionp'" & inlist(case, "b40", "t60", "mean")), c(values) by(countryname) concise"'
	}
	if ("`calcset'" == "wdi") {
	local sname "WDI"
	local disptab `"tabdisp year wdi if (regioncode == "\`regionp'" & inlist(wdi, "si_pov_nahc")), c(values) by(countryname) concise"'
	}
	
	
	noi disp in y _n `"{stata use "`out'/`basename'_long.dta": Load `sname' file}"'
	foreach regionp of local regionsp {
	noi disp in y _n `"{stata `disptab':    `regionp'}"'
	} // end of regions loop
	
	
	}
	end
	exit
	/* End of do-file */
	
	><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
	
	Notes:
	1.
	2.
	3.
	
	
	Version Control:
		