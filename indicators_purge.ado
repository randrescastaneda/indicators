/*==================================================
project:       purge indicators files
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    19 Jul 2018 - 20:15:19
Modification Date:   
Do-file version:    01
References:          
Output:             dta file purged
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_purge, rclass
syntax anything(name=calcset id="set of calculations"), /* 
  */   [ vcdate(string)     /* 
  */  restore out(string)   /* 
  */  datetime(numlist)     /* 
  */  shape(string)     /* 
  */	load ]

version 14

*-------------------- Conditions --------------------------
qui {

if (("`restore'" != "" & "`load'" != "") | /* 
*/  ("`restore'" == "" & "`load'" == "")) {
	noi disp in r "you must select either {it:load} or {it:restore}"
	error
}


/*==================================================
1:  Purge data
==================================================*/
if ("`purge'" != "") {
	
	if ("`keep'" == "after") local drop "BEFORE"
	else                     local drop "AFTER"

	indicators `calcset', load
	local filename = "`r(filename)'"
	
	indicators_vcselect,  vcdate(`vcdate')
	local vcvar     = "`r(vcdate)'" 
	local alldates  = "`r(alldates)'"
	local datecount = wordcount("`alldates'")
	confirm var `vcvar'
	
	
	cap window stopbox rusure /* 
	*/  "You are about to delete vc_* vars and observations `drop' `vcvar'"  /* 
	*/  " in `filename'" "Are you sure want to make that change?"
	
	if (_rc != 0) error
	
	
	mata: A = tokens(st_local("alldates"))
	mata: A = "vc_" :+ A
	mata: date = st_local("vcvar")
	mata: n = selectindex(regexm(A, date))
	mata: st_local("n", strofreal(n))
	
	
	if ("`keep'" == "after") {
		keep if inlist(`vcvar', 1, .)
		foreach v of numlist 1/`=`n'-1' {
			local var: word `v' of `alldates'
			drop vc_`var'
		}
	}
	else { 
		drop if `vcvar' == .
		foreach v of numlist `=`n'+1'/`datecount' {
			local var: word `v' of `alldates'
			drop vc_`var'
		}
	}
	
	local basename "indicators_`calcset'"
	cap noi indicators_save `calcset', basename(`basename') out("`out'") /*  
	*/  datetime(`datetime')
	
}


/*==================================================
2: Restore Data
==================================================*/

if ("`restore'" != "" | "`load'" != "") {

	local files: dir "`out'/_vintage" files "indicators_`calcset'*"
	local vcnumbers: subinstr local files "indicators_`calcset'_" "", all
	local vcnumbers: subinstr local vcnumbers ".dta" "", all
	local vcnumbers: list sort vcnumbers

	local vcnumbers: list sort vcnumbers
	* return local vcnumbers = "`vcnumbers'"
	noi disp in y "list of available vintage control dates for file indicators_`calcset'"
	local alldates ""
	local i = 0
	foreach vc of local vcnumbers {
		
		local ++i
		if (length("`i'") == 1 ) local i = "00`i'"
		if (length("`i'") == 2 ) local i = "0`i'"
		
		if regexm("`vc'", "([0-9]+)_(rf)_([0-9]+)") {  // if version was restored 
			local vc1 = regexs(1)
			local vc2 = regexs(3)
			local find = "restored from"
		}
		else {
			local vc1  = "`vc'"
			local vc2  = ""
			local find = ""
		}
		
		
		local dispdate: disp %tcDDmonCCYY_HH:MM:SS `vc1'
		local dispdate = trim("`dispdate'")
		
		if ("`vc2'" != "") {
			local dispdate2: disp %tcDDmonCCYY_HH:MM:SS `vc2'
			local dispdate2 = trim("`dispdate2'")
		}
		
		
		noi disp `"   `i' {c |} {stata `vc1':`dispdate'} `find' `dispdate2'"'
		
		local alldates "`alldates' `dispdate'"
	}
	
	if (inlist("`vcdate'" , "", "pick", "choose")) {
		noi disp _n "select vintage control date from the list above" _request(_vcnumber)
		local vcdate: disp %tcDDmonCCYY_HH:MM:SS `vcnumber' 
	}
	else {
		cap confirm number `vcdate'
		if (_rc ==0) {
			local vcnumber = `vcdate'
			local vcdate: disp %tcDDmonCCYY_HH:MM:SS `vcnumber'
		}
		else {
			if (!regexm("`vcdate'", "^[0-9]+[a-z]+[0-9]+ [0-9]+:[0-9]+:[0-9]+$") /* 
			 */ | length("`vcdate'")!= 18) {
			 
				local datesample: disp %tcDDmonCCYY_HH:MM:SS /* 
				 */   clock("`c(current_date)' `c(current_time)'", "DMYhms")
				noi disp as err "vcdate() format must be %tdDDmonCCYY, e.g " _c /* 
				 */ `"{cmd:`=trim("`datesample'")'}"' _n
				 error
			}
			local vcnumber: disp %13.0f clock("`vcdate'", "DMYhms")
		}
	
	}

	local filename: dir "`out'/_vintage" files "indicators_`calcset'_`vcnumber'*.dta"
	if (`"`filename'"' == "") {
		noi disp in r "there is no file indicators_`calcset'_`vcnumber'*.dta in vintage"
		error
	}
	local loadfile = "`out'/_vintage/"+`filename'
	* confirm file "`out'/_vintage/`filename'"
	* use "`out'/_vintage/`filename'", clear
	confirm file "`loadfile'"
	use "`loadfile'", clear
	noi disp in y "file " in w `filename' in y " was loaded"
	
	return local filename `filename'
	
	if ("`restore'" != "") {
		cap window stopbox rusure /* 
		*/  "You are about to replace current indicators_`calcset' files with "  /* 
		*/  "file indicators_`calcset'_`vcnumber' from `vcdate'" /* 
		*/  "Are you sure want to make that change?"
		if (_rc != 0) error

		local basename "indicators_`calcset'"		
		cap noi indicators_save `calcset', basename(`basename') out("`out'") /*  
		*/  datetime(`datetime') vcnumber(`vcnumber')
	}
	if ("`load'" != "" & "`shape'" == "long") {
		qui indicators_reshape_long `calcset'
	} 
	
	
	* return local alldates = trim("`alldates'")
}

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


