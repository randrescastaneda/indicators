/*==================================================
project:       PEB vintage control
Author:        Andres Castaneda 
----------------------------------------------------------------------
Creation Date:     1 Jun 2018 - 12:45:19
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_vcselect, rclass
syntax , [ vcdate(string) MAXdate]

if ("`vcdate'" != "") {
	if (!regexm("`vcdate'", "^[0-9]+[a-z]+[0-9]+$") | length("`vcdate'")!= 9) {
		local datesample: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
		noi disp as err "vcdate() format must be %tdDDmonCCYY, e.g " _c /* 
		 */ `"{cmd:`=trim("`datesample'")'}"' _n
		 error
	}
}

cap des vc_*, varlist
if (_rc == 0) {
	
	
	local dates = "`r(varlist)'"
	local dates: subinstr local dates "vc_" "", all
	
	local vcnumbers ""
	foreach date of local dates {
		local vcnumbers "`vcnumbers' `=date("`date'", "DMY")'"
	}
	local vcnumbers = trim("`vcnumbers'")
	
	* display dates 
	local vcnumbers: list sort vcnumbers
	noi disp in y "list of available vintage control dates"
	local i = 0
	foreach vc of local vcnumbers {
		local ++i
		if (length("`i'") < 2 ) local i = "0`i'"
		local dispdate: disp %tdDDmonCCYY `vc'
		noi disp `"   `i' {c |} {stata vc_`dispdate':`=trim("`dispdate'")'}"'
	}
	
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

if ("`vcdate'" == "" & "`maxdate'" == "") {
	disp _n "select vintage control date from the list above" _request(_vcdate)
}
else local vcdate = "`maxvc'"

return local vcdate   = "`vcdate'"
return local maxdate  = "`maxvc'"

end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

This is equivalent to peb_vcontrol
