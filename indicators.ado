/*====================================================================
project:       Basic indicators (poverty and Inequality)
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:     3 May 2018 - 15:26:58
Modification Date:   
Do-file version:    01
References:          
Output:             dta, xlsx, csv
====================================================================*/

/*====================================================================
0: Program set up
====================================================================*/
program define indicators
version 14.0

syntax anything(name=calcset id="set of calculations"),  ///
[                                   ///
update                              ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
FILENames(string)                   ///
REPOsitory(passthru)                ///
reporoot(string)                    ///
MODule(passthru)                    ///
plines(string)                      ///
cpivintage(string)                  ///
veralt(string)                      ///
vermast(string)                     ///
trace(string)                       ///
WBOdata(string)                     ///
replace                             ///
createrepo                          ///
save                                ///
noSHOW                              ///
clear  *                            ///
]


drop _all
* Directory Paths

local out         "\\wbgfscifs01\GTSD\02.core_team\02.data\01.Indicators"
if ("`reporoot'" == "") local reporoot "`out'"


qui {
	local sscados "groupfunction wbopendata"
	foreach ado of local sscados {
		cap which `ado'
		if (_rc) ssc install `ado'
		else adoupdate `ado', ssconly 
		if ("`r(pkglist)'" != "") adoupdate `ado', update
	}
	
	
	*------------------ Initial Parameters  ------------------
	local date      = c(current_date)
	local time      = c(current_time)
	local datetime  : disp %tcDDmonCCYY_HH.MM clock("`date'`time'", "DMYhms")
	local user      = c(username)
	local dirsep    = c(dirsep)
	local nummin    = 30
	local vintage:  disp %tdD-m-CY date("`c(current_date)'", "DMY")
	
	
	*------------------  Conditions  ------------------
	
	if ("`plines'" == "")     local plines "1.9 3.2 5.5"
	if ("`cpivintage'" == "") local cpivintage "v02"
	if ("`repository'" == "") local repository "all_GMD"
	if ("`wbodata'" == "")    local wbodata  NE.CON.PRVT.PC.KD; NY.GDP.PCAP.PP.CD; /* 
	*/                                       NY.GDP.PCAP.PP.KD; NY.GNP.PCAP.CD;    /*
	*/                                       NY.GNP.PCAP.KD; SI.POV.NAHC;          /* 
	*/                                       SP.RUR.TOTL; SP.RUR.TOTL.ZS;          /*
	*/                                       SP.POP.TOTL; SI.POV.GINI 
	
	
	local calcset = lower("`calcset'")
	
	/*====================================================================
	REPORT
	====================================================================*/
	
	if (regexm("`calcset'", "report")) {
		indicators_report, file("`out'\indicators_reportfile.dta")
		exit
	}
	
	
	*--------------- Post file creation-----------------
	tempname ef
	tempfile errfile
	postfile `ef' str4(region countrycode year) str50(filename) int comment ///
	using `errfile', replace 
	
	
	/*====================================================================
	1:  Create repository
	====================================================================*/
	
	*--------------------1.1: Load repository data
	if ("`createrepo'" != "") {
		cap datalibweb, repo(erase `repository', force) reporoot("`reporoot'") type(GMD)
		datalibweb, repo(create `repository') reporoot("`reporoot'") /* 
		*/         type(GMD) country(`countries') year(`years')       /* 
		*/         region(`regions') module(`module')
	}
	
	use "`reporoot'\repo_`repository'.dta", clear
	
	drop if module == "L"  // Ask Minh what is L and whether this drop id OK
	
	tostring _all, replace
	order country years surveyid survname col module filename ///
	latest region countryname vermast veralt
	des, varlist
	local varlist = "`r(varlist)'"
	
	*--------------------1.2: Condition to filter data
	
	* Countries
	if ("`countries'" != "") {
		local countrylist ""
		foreach country of local countries {
			local countrylist `"`countrylist', "`country'""'
		}
		keep if inlist(country `countrylist')
	}
	
	* Regions
	if ("`regions'" != "") {
		local regionlist ""
		foreach region of local regions {
			local regionlist `"`regionlist', "`region'""'
		}
		keep if inlist(region `regionlist')
	}
	
	** years
	if ("`years'" != "") {
		numlist "`years'"
		local years  `r(numlist)'
		local yearlist ""
		foreach year of local years {
			local yearlist `"`yearlist', "`year'""'
		}
		keep if inlist(years `yearlist')
	}
	
	** filename
	if ("`filenames'" != "") {
		local filenames = upper("`filenames'")
		local filenamelist ""
		foreach filename of local filenames {
			local filenamelist `"`filenamelist', "`filename'""'
		}
		keep if inlist(upper(filename) `filenamelist')
	}
	
	
	
	*--------------------1.3: send info to MATA
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	local n = _N
	local vars countrycode year surveyid survname type module filename ///
	latest region countryname vermast veralt
	
	
	/*====================================================================
	2: Poverty and Inequality
	====================================================================*/
	
	
	if (regexm("`calcset'", "ine|pov")) {
		tempfile wrkpov wrkine   // working surveys file
		drop _all
		save `wrkpov', replace emptyok
		save `wrkine', replace emptyok
		
		local i = 0
		while (`i' < `n') {
			local ++i
			set trace off
			
			*--------------------2.2: Load data
			mata: _ind_ids(R)
			noi disp in y _n `"datalibweb, country(`countrycode') year(`year') type(`type') fileserver filename(`filename') cpivintage(`cpivintage') nometa clear"'
			cap datalibweb, country(`countrycode') year(`year') type(`type')  ///
			fileserver filename(`filename') cpivintage(`cpivintage') nometa clear
			if (_rc) {
				disp in red "datalibweb didn't load `filename'"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (11)
				continue
			}
			
			*--------------------2.3: check usability of survey
			
			**** Welfare
			cap confirm var welfare, exact 
			if (_rc) {
				disp in red "No welfare variable in `filename'"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (12)
				continue
			}
			gen  welfareused =  welfare // default welfare
			cap drop if welfare<0  //NEW for EUSILC
			
			
			**** treatment of weight variable
			cap confirm var weight, exact 
			if (_rc == 0) local weight weight
			else local weight weight_p 
			
			
			*** Extract
			cap drop __0*   // drop any temporal variable
			cap tostring hhid, replace
			
			** welfare in ppp
			cap gen double welfare_ppp = welfareused/cpi2011/icp2011/365
			if (_rc) {
				disp in red "Err creating welfare_ppp"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (13)
				
				continue
			}
			
			**----------------- Inequality ------------------
			
			if (regexm("`calcset'", "ine")) {
				if regexm("`trace'", "ine") set trace on
				cap indicators_ine, weight(`weight') 
				if (_rc) {
					disp in red "Err calculating inequality"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (21)
					continue
				}
				local _gini = `r(_gini)'
				local _theil = `r(_theil)'
			}
			set trace off
			
			**----------------- FGT family ------------------
			if (regexm("`calcset'", "pov")) {
				if regexm("`trace'", "pov") set trace on
				
				cap indicators_pov [aw = `weight'], plines("`plines'") ///
				vars("`vars'") i(`i')
				if (_rc) {
					disp in red "Err calculating poverty"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (31)
					continue
				}
				_gendatetime, date("`date'") time("`time'")
				
				append using `wrkpov' 
				save `wrkpov', replace 		
				
				disp in y _n "`filename' pov OK"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (30)
			}
			set trace off
			
			**----------------- Inequality, create file
			if (regexm("`calcset'", "ine")) {
				drop _all
				set obs 1
				* create variables and date
				foreach var of local vars {
					gen `var' = "``var''"
				}
				_gendatetime, date("`date'") time("`time'")
				
				gen double valuesgini = `_gini'
				gen double valuestheil = `_theil'
				
				append using `wrkine' 
				compress
				save `wrkine', replace 		
				
				disp in y _n "`filename' ine OK"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (20)
				
			}
			
		} // end of surveys loop
		
		
		*=========  update poverty and Inequality files =============
		
		*--- Poverty
		if (regexm("`calcset'", "pov")) {
			if regexm("`trace'", "pov") set trace on
			use `wrkpov', clear
			local povfile_wide "`out'\indicators_pov_wide.dta"
			cap confirm new file "`povfile_wide'"
			if (_rc) {
				append using "`povfile_wide'"
				local dropvars "region countrycode year filename fgt* welfare_mean"
				sort `dropvars' date time
				duplicates drop `dropvars', force
			}
			
			_vcontrol, vars(region countrycode year)			
			save "`povfile_wide'", replace
			
			reshape long fgt0_ fgt1_ fgt2_, i(filename date time vc_*) j(line)
			rename fgt*_ fgt*
			reshape long fgt, i(filename line date time vc_*) j(FGT)
			rename (FGT fgt) (fgt values)
			order region countrycode year filename  line fgt values
			save "`out'\indicators_pov_long.dta", replace
			
			levelsof region, local(regionsp)
			foreach regionp of local regionsp {
				noi disp in y _n "Poverty in `regionp'"
				noi tabdisp year veralt line if (fgt == 0 & region == "`regionp'"), ///
				c(values) by(countryname) concise
			} // end of regions loop
		} // end pov file update section
		set trace off
		
		
		*--- Inequality
		if (regexm("`calcset'", "ine")) {
			if regexm("`trace'", "ine") set trace on
			use `wrkine', clear
			local inefile_wide "`out'\indicators_ine_wide.dta"
			cap confirm new file "`inefile_wide'"
			if (_rc) {
				append using "`inefile_wide'"
				local dropvars "region countrycode year filename values*"
				sort `dropvars' date time
				duplicates drop `dropvars', force
			}
			
			_vcontrol, vars(region countrycode year)
			save "`inefile_wide'", replace
			
			reshape long values, i(filename) j(ineq) string
			order region countrycode year filename ineq values
			save "`out'\indicators_ine_long.dta", replace
			
			levelsof region, local(regionsp)
			foreach regionp of local regionsp {
				noi disp in y _n "Inequality in `regionp'"
				noi tabdisp year veralt ineq if (region == "`regionp'"), ///
				c(values) by(countryname) concise
			} // end of regions loop
		} // end of ine file update
		set trace off
		
	}	// end of Poverty and inequality
	set trace off	
	
	
	
	/*====================================================================
	3:Shared Prosperity
	====================================================================*/
	
	*--------------------3.1:
	
	
	*--------------------3.2:
	
	
	*--------------------3.3:
	
	/*====================================================================
	4: WDI
	====================================================================*/
	
	if (regexm("`calcset'", "wdi")) {
		if regexm("`trace'", "wdi") set trace on 			
		
		cap {
			*--------------------3.1: extract and save 
			wbopendata, indicator(`wbodata') long clear nometadata
			compress
			_gendatetime, date("`date'") time("`time'")
			local wdifile_wide "`out'\indicators_wdi_wide.dta"
			cap confirm new file "`wdifile_wide'"
			if (_rc) {
				append using "`wdifile_wide'"
				des, varlist
				local wdivars = "`r(varlist)'"
				local datetimevars "date time"
				local wdivars: list wdivars - datetimevars
				
				sort `wdivars' date time
				duplicates drop `wdivars', force
			}
			_vcontrol, vars(region countrycode year)
			
			save "`wdifile_wide'", replace
			
			*------------------3.2: Reshape -> long
			* Identify indicators vars
			des, varlist
			local wdivars = "`r(varlist)'"
			foreach var of local wdivars {
				if regexm("`var'", "_") local indvars "`indvars' `var'"
			}
			
			rename (`indvars') values=
			reshape long values, i(regioncode countrycode year date time) j(wdi) string
			
			save "`out'\indicators_wdi_long.dta", replace
			
			if regexm("`trace'", "wdi") set trace off
		}  // end of cap
		*--------------------3.3: Errors
		if (_rc) {
			noi disp in red "Err extracting WDI info"
			post `ef' ("ALL") ("ALL") ("ALL") ///
			("wbopendata") (51)
			error
		}
		else {
			noi disp in y _n "`filename' WDI OK"
			post `ef' ("ALL") ("ALL") ("ALL") ///
			("wbopendata") (50)
		}
	} // end of data from WDI
	set trace off
	
	*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	
	/*====================================================================
	Update Errors files
	====================================================================*/
	
	*--------------------4.1:
	if regexm("`trace'", "err") set trace on
	postclose `ef'
	use `errfile', clear
	label define comment ///
	11  "datalibweb didn't load file"  ///
	12  "No welfare variable in file"  ///
	13  "Err creating welfare_ppp"  ///
	21  "Err in ine"  ///
	31  "Err in pov"  ///
	41  "Err in shp"  ///
	51  "Err in wdi"  ///
	20  "OK ine"  ///
	30  "OK pov"  ///
	40  "OK shp"  ///
	50  "OK wdi"  ///
	, modify
	
	label values comment comment
	compress
	count
	if r(N) >= 1 {
		_gendatetime, date("`date'") time("`time'")
		local masterr "`out'\indicators_reportfile.dta"
		cap confirm new file "`masterr'"
		if (_rc) append using "`masterr'"
		
		* drop duplicated error messages and leave the earliest
		sort region countrycode year filename date time
		count if (regexm(strofreal(comment), "[1-9]$"))
		local nerr = `r(N)'
		
		if (`nerr' != 0) {
			duplicates drop region countrycode filename comment ///
			if (regexm(strofreal(comment), "[1-9]$")), force
		}
		else noi disp "No observation with error"
		
		/* drop duplicated OK messages and leave the latest. 
		we leave the latest because it vould be the case that
		the dataset has changed so that the resutls have changed
		and it is necessary to know when those results are being 
		effective. */
		
		count if (regexm(strofreal(comment), "0$"))
		local nok = `r(N)'
		if (`nok' != 0) {
			
			gsort region countrycode year filename comment -date -time
			duplicates drop region countrycode year filename comment ///
			if (regexm(strofreal(comment), "0$")), force
			
			cap drop ok
			bysort region countrycode year filename: ///
			egen ok = total(regexm(strofreal(comment), "0$"))
			
		}
		else {
			cap confirm var ok
			if (_rc) gen ok = 0
		}
		noi disp in w "{hline}"
		
		save "`masterr'", replace
		
		indicators_report , file("`masterr'")
	
	
	
} // end of qui

end // end of indicators.ado

*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><	

/*====================================================================
Additional programs
====================================================================*/

*-------------------- Generate time variables
program define _gendatetime
syntax , [date(string) time(string)]

if ("`date'" == "") local date = c(current_date)
if ("`time'" == "") local time = c(current_time)

gen double date = date("`date'", "DMY")
format date %td

gen double time = clock("`time'", "hms")
format time %tcHH:MM:SS

// I do it this way to understand the relation
gen double datetime = date*24*60*60*1000 + time  
format datetime %tcDDMonCCYY_HH:MM:SS

end



program define _vcontrol
syntax, vars(varlist)

tempvar vermast veralt malt mdate
foreach var in vermast veralt {
	gen ``var'' = subinstr(upper(`var'), "V", "", .)
	destring ``var'', replace
}

bysort `vars': egen  `malt' = max(`veralt')
replace `malt' = cond(`malt' == `veralt', 1, 0)


bysort `vars' filename: egen double `mdate' = max(datetime) /* 
*/ if `malt' == 1
replace `mdate' = cond(`mdate' == datetime & `malt' == 1, 1, 0) 

local dt: disp %tdDDmonthCCYY date("`c(current_date)'", "DMY")
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
		local maxvc: disp %tdDDmonthCCYY max(`vcnumbers')
	}
	else {
		local maxvc: disp %tdDDmonthCCYY `vcnumbers'
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

end

/*====================================================================
Mata functions
====================================================================*/
mata:
mata drop _ind*()
mata set mataoptimize on
mata set matafavor speed

void _ind_ids(string matrix R) {
	i = strtoreal(st_local("i"))
	vars = tokens(st_local("vars"))
	for (j =1; j<=cols(vars); j++) {
		//printf("j=%s\n", R[i,j])
		st_local(vars[j], R[i,j] )
	} 
} // end of IDs variables

end





exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. to extract labels in wbopendata
scalar a = fileread("c:\ado\plus/w/wbopendata_indicators.hlp")
2.
3.


Version Control:


adopath ++ "\\\wbgfscifs01\GTSD\02.core_team\01.programs\01.ado\indicators"

indicators pov, countr(PRY ALB) years(2012 2013) trace(pov)

indicators pov, countr(HND) years(2012 2013) 
indicators ine, countr(HND) years(2012 2013) 

* indicators pov, filename(PRY_2012_EPH_V01_M_V02_A_GMD_ALL.dta) trace(pov)
