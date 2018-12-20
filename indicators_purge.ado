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
*/ [ vcdate(string) keep(string) purge restore out(string) datetime(numlist)]

version 14

*-------------------- Conditions --------------------------

if (("`restore'" != "" & "`purge'" != "") | /* 
*/  ("`restore'" == "" & "`purge'" == "")) {
	noi disp in r "you must select either {it:purge} or {it:restore}"
	error
}

if ("`keep'" == "" & "`purge'" != "") {
	noi disp in red "option {it:keep()} must be either before or after " _n /* 
	*/ "when used with option {it:purge}"
	error
}

if !inlist("`keep'", "before", "after", "") {
	noi disp in red "option {it:keep()} must be either before or after"
	error
}

if ("`vcdate'" != "") {
	if (!regexm("`vcdate'", "^[0-9]+[a-z]+[0-9]+$") | length("`vcdate'")!= 9) {
		local datesample: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
		noi disp as err "vcdate() format must be %tdDDmonCCYY, e.g " _c /* 
		*/ `"{cmd:`=trim("`datesample'")'}"' _n
		error
	}
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

if ("`restore'" != "") {

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
		if (length("`i'") < 2 ) local i = "0`i'"
		local dispdate: disp %tcDDmonCCYY_HH:MM:SS `vc'
		local dispdate = trim("`dispdate'")
		noi disp `"   `i' {c |} {stata `vc':`dispdate'}"'
		local alldates "`alldates' `dispdate'"
	}
	noi disp _n "select vintage control date from the list above" _request(_vcnumber)
	local vcdate: disp %tcDDmonCCYY_HH:MM:SS `vcnumber' 
	
	confirm file "`out'/_vintage/indicators_`calcset'_`vcnumber'.dta"
	
	cap window stopbox rusure /* 
	*/  "You are about to replace current indicators_`calcset' files with "  /* 
	*/  "file indicators_`calcset'_`vcnumber' from `vcdate'" /* 
	*/  "Are you sure want to make that change?"
	if (_rc != 0) error
	
	use "`out'/_vintage/indicators_`calcset'_`vcnumber'.dta", clear
	local basename "indicators_`calcset'"
	cap noi indicators_save `calcset', basename(`basename') out("`out'") /*  
	*/  datetime(`datetime')
	
	* return local alldates = trim("`alldates'")
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


