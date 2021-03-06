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
program define indicators, rclass
version 14.0

syntax anything(name=calcset id="set of calculations"),  ///
[                                   ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			REGions(string)                     ///
			FILENames(string)                   ///
			REPOsitory(string)                  ///
			reporoot(string)                    ///
			repofromfile                        ///
			MODule(string)                      ///
			plines(string)                      ///
			cpivintage(string)                  ///
			veralt(string)                      ///
			vermast(string)                     ///
			TYPEs(string)                       ///
			trace(string)                       ///
			WBOdata(string)                     ///
			vcdate(string)                      ///
			createrepo                          ///
			WELFAREvars(string)                 ///
			newonly force                       ///
			noi  gpwg2  pause                   ///
			load  shape(string)                 ///
			purge restore keep(string)          ///
] 

if ("`pause'" == "pause") pause on
else pause off

* Host name
if  inlist("`c(hostname)'", "wbgmsbdat002", "wbgmsbdat001", "dpg-stata642") {
	if  inlist("`c(username)'", "wb384996") {
		local hdrive "X:"
	}
	else local hdrive "\\wbgfscifs01\GTSD"
}
else local hdrive "\\wbgfscifs01\GTSD"

* Directory Paths

local out         "`hdrive'\02.core_team\02.data\01.Indicators"
if ("`reporoot'" == "") local reporoot "`out'"


qui {
	
	/*====================================================================
	Conditions
	====================================================================*/
	*------------------ Initial Parameters  ------------------
	local date      = c(current_date)
	local time      = c(current_time)
	local datetime  = clock("`date'`time'", "DMYhms")   // number, not date
	local user      = c(username)
	local dirsep    = c(dirsep)
	local nummin    = 30
	local vintage:  disp %tdD-m-CY date("`c(current_date)'", "DMY")
	
	local allind   "pov ine shp key"
	local allind_: subinstr local allind " " "|", all
	
	*------------------  Conditions  ------------------
	local calcset   = lower("`calcset'")
	local countries = upper("`countries'")
	
	if ("`plines'" == "")     local plines "1.9 3.2 5.5"
	if ("`cpivintage'" == "") local cpivintage ""
	if ("`repository'" == "") local repository "all_GMD"
	if ("`wbodata'" == "")    local wbodata  NE.CON.PRVT.PC.KD; NY.GDP.PCAP.PP.CD; /* 
	*/                                       NY.GDP.PCAP.PP.KD; NY.GNP.PCAP.CD;    /*
	*/                                       NY.GNP.PCAP.KD; SI.POV.NAHC;          /* 
	*/                                       SP.RUR.TOTL; SP.RUR.TOTL.ZS;          /*
	*/                                       SP.POP.TOTL; SI.POV.GINI 
	if ("`welfarevars'" == "") {
		local welfarevars welfare welfshprosperity welfareused welfarenom /* 
		*/   welfaredef welfareother pcexp pcinc
	}
	
	if ("`purge'" == "" & "`restore'" == "" & "`load'" == "" & /* 
	*/  !inlist("`calcset'", "report", "repo") ) {
		
		if ( ("`countries'" == "" & "`regions'" == "") | /* 
		*/   ("`countries'" != "" & "`regions'" != "" )) {
			noi disp in r "You must select either countries() or regions()"
			error
		}
	} // end of countries or regions not selected
	
	if ("`calcset'" == "repo" & "`createrepo'" == "" & "`load'" == "") {
		noi disp in r "you must specify either {it:load} or {it:createrepo}"
		error
	}
	
	* vcdate
	if ("`vcdate'" != "") {
		cap confirm number `vcdate'
		if (_rc ==0) {
			local vcnumber = `vcdate'
			local vcdate: disp %tcDDmonCCYY_HH:MM:SS `vcnumber'
		}
		else { // if it not a number only
			local vcn = 0
			local vcs = 0
			if (regexm("`vcdate'", "[0-9]+")) { // if it has at least one number
				if (!regexm("`vcdate'", "^[0-9]+[a-z]+[0-9]+ [0-9]+:[0-9]+:[0-9]+$") /* 
					*/ | length("`vcdate'")!= 18) {
					local vcn = 1
				}
				else local vcnumber: disp %13.0f clock("`vcdate'", "DMYhms")
			}
			else {  // if only has letters
				if (!inlist("`vcdate'" , "pick", "choose")) {
					local vcs = 1
				}
			} 
			
			if (`vcn' == 1 | `vcs' == 1) {
				local datesample: disp %tcDDmonCCYY_HH:MM:SS /* 
				 */   clock("`c(current_date)' `c(current_time)'", "DMYhms")
				noi disp as err "vcdate() format must be %tdDDmonCCYY, e.g " _c /* 
				 */ `"{cmd:`=trim("`datesample'")'}"' _n /* 
				 */ as err "or either {it:pick} or {it:choose}" _n
				 error			
			}
		}
	}  // end of vcdate() condition
	
	
	*------------------ SSC commands  ------------------
	local sscados "groupfunction wbopendata quantiles tabstatmat missings"
	foreach ado of local sscados {
		cap which `ado'
		if (_rc) ssc install `ado'
		local adoupdate "`adoupdate' `ado'"
	}
	
	if ("`adoupdate'" != "") 	{
		adoupdate `adoupdate', ssconly 		
		if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update
	}
	
	/*====================================================================
	Load files
	====================================================================*/
	drop _all
	
	if ("`load'" == "load") {
		if wordcount("`calcset'") != 1 {
			noi disp in red "Only one file can be loaded"
			error
		}
		if ("`calcset'" == "repo") {
			use "`reporoot'\repo_vc_`repository'.dta", clear
			noi disp "repo_vc_`repository'.dta loaded"
			exit
		}
		if ("`shape'" == "") local shape "wide"
		if !inlist("`shape'", "wide", "long") {
			noi disp in r "shape can me wide or long only"
		}
		
		if ("`vcdate'" != "") {
			noi indicators_purge `calcset', vcdate(`vcdate') shape(`shape') /* 
			*/  `restore' out("`out'") datetime(`datetime') `load'
			return add 
		}
		else {
			use "`out'/indicators_`calcset'_`shape'.dta", clear
			noi disp "indicators_`calcset'_`shape'.dta loaded"
			return local filename = "indicators_`calcset'_`shape'.dta"
		}
		exit
	}
	
	/*====================================================================
	PURGE OR RESTORE
	====================================================================*/
	if ("`restore'" != "" | "`purge'" != "") {
		if (wordcount("`calcset'") != 1) {
			noi disp in r "set of calculations must be one when using {it:purge} or {it:restore}"
			error
		}
		noi indicators_purge `calcset', vcdate(`vcdate')   /* 
		*/  `restore' out("`out'") datetime(`datetime')    /* 
		*/  `purge' countries(`countries') years(`years')
		exit
	}
	
	
	
	/*====================================================================
	REPORT
	====================================================================*/
	
	if (regexm("`calcset'", "report")) {
		noi indicators_report, file("`out'\indicators_reportfile.dta")
		exit
	}
	
	*--------------- Post file creation-----------------
	tempname ef
	tempfile errfile
	postfile `ef' str4(region countrycode year) str50(filename) int comment ///
	using `errfile', replace 
	
	
	/*====================================================================
	1.1  Create repository
	====================================================================*/
	
	*--------------------1.1: Load repository data
	if ("`createrepo'" != "" & "`calcset'" == "repo") {
		
		cap confirm file "`reporoot'\repo_gpwg2.dta"
		if ("`gpwg2'" == "gpwg2" | _rc) {
			indicators_gpwg2, out("`out'") datetime(`datetime')
		}
		
		local dt: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
		local dt = trim("`dt'")
		
		if ("`repofromfile'" == "") {
			cap datalibweb, repo(erase `repository', force) reporoot("`reporoot'") type(GMD)
			datalibweb, repo(create `repository') reporoot("`reporoot'") /* 
			*/         type(GMD) country(`countries') year(`years')       /* 
			*/         region(`regions') module(`module')
			noi disp "repo `repository' has been created successfully."
			use "`reporoot'\repo_`repository'.dta", clear
			append using "`reporoot'\repo_gpwg2.dta"			
		}
		else {
			use "`reporoot'\repo_`repository'.dta", clear
		}
		
		* Fix names of surveyid and files
		local repovars filename surveyid
		foreach var of local repovars {
			replace `var' = upper(`var')
			replace `var' = subinstr(`var', ".DTA", ".dta", .)
			foreach x in 0 1 2 {
				while regexm(`var', "_V`x'") {
					replace `var' = regexr(`var', "_V`x'", "_v`x'")
				}	
			}
		}
		duplicates drop filename, force
		
		save "`reporoot'\repo_`repository'.dta", replace
		
		* confirm file exists
		cap confirm file "`reporoot'\repo_vc_`repository'.dta"
		if (_rc) {
			gen vc_`dt' = 1
			save "`reporoot'\repo_vc_`repository'.dta", replace
			noi disp "repo_vc_`repository' successfully updated"
			exit 
		}
		
		use "`reporoot'\repo_vc_`repository'.dta", clear
		
		* Fix names of surveyid and files
		local repovars filename surveyid
		foreach var of local repovars {
			replace `var' = upper(`var')
			replace `var' = subinstr(`var', ".DTA", ".dta", .)
			foreach x in 0 1 2 {
				while regexm(`var', "_V`x'") {
					replace `var' = regexr(`var', "_V`x'", "_v`x'")
				}	
			}
		}
		duplicates drop filename, force
		
		merge 1:1 filename using "`reporoot'\repo_`repository'.dta"
		
		cap confirm new var vc_`dt'
		if (_rc) drop vc_`dt'
		recode _merge (1 = 0 "old") (3 = 1 "same") (2 = 2 "new"), gen(vc_`dt')
		sum vc_`dt', meanonly
		if r(mean) == 1 {
			noi disp in r "variable {cmd:vc_`dt'} is the same as previous version. No update"
			drop vc_`dt' _merge
			error
		}
		else {
			noi disp in y "New vintages:"
			noi list filename if vc_`dt' == 2
		}
		
		drop _merge
		save "`reporoot'\repo_vc_`repository'.dta", replace
		exit
	}
	
	/*====================================================================
	1.2  Use repository
	====================================================================*/
	
	* use "`reporoot'\repo_vc_`repository'.dta", clear
	indicators repo, load `pause' repository(`repository') reporoot(`reporoot')
	
	* ----Keep most recent repo or whatever the user selects -----------------------
	
	des vc_*, varlist
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
		noi disp `"   `i' {c |} `=trim("`dispdate'")'"'
	}
	
	if ("`vcdate'" != "") { // date selected by the user
		if (!regexm("`vcdate'", "^[0-9]+[a-z]+[0-9]+$") | length("`vcdate'")!= 9) {
			local datesample: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
			noi disp as err "vcdate() format must be %tdDDmonCCYY, e.g " _c /* 
			*/ `"{cmd:`=trim("`datesample'")'}"' _n
			error
		}
		confirm var vc_`vcdate'
		local maxvc "vc_`vcdate'"
	}
	else { // max date
		
		if (wordcount("`vcnumbers'") >1) {
			local vcnumbers: subinstr local vcnumbers " " ", ", all
			local maxvc: disp %tdDDmonCCYY max(`vcnumbers')
		}
		else {
			local maxvc: disp %tdDDmonCCYY `vcnumbers'
		}
		local maxvc = "vc_" + trim("`maxvc'")
	}
	
	keep if inlist(`maxvc', 1, 2)
	
	* New surveys only
	if ("`newonly'" == "newonly") {
		keep if `maxvc' == 2
		count
		if r(N) == 0 {
			noi disp in r "No new surveys in repository. " _n ///
			" There might be, though, surveys that have been updated."
			error
		}
	}
	
	
	* remove unnecessary information
	* keep if inlist(module, "ALL", "GPWG", "UDB-C")  
	keep if regexm(module, "ALL|GPWG|GROUP|UDB\-C")
	
	tostring _all, replace
	rename col type
	order country years surveyid survname type module filename ///
	latest region countryname vermast veralt
	des, varlist
	local varlist = "`r(varlist)'"
	
	*--------------------1.2: Condition to filter data
	
	* Countries
	if ("`countries'" == "" & "`regions'" == "" ) {
		noi disp in r "You must select either countries() or regions()"
		error
	}
	if ("`countries'" != "" & "`regions'" != "" ) {
		noi disp in r "you must select either countries() or regions()"
		error
	}
	
	if (lower("`countries'") != "all" & "`regions'" == "" ) {
		local countrylist ""
		local countries = upper("`countries'")
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
	
	if ("`types'" != "") {
		local types = upper("`types'")
		local typelist ""
		foreach type of local types {
			local typelist `"`typelist', "`type'""'
		}
		keep if inlist(upper(type) `typelist')
	}
	if ("`module'" != "") {
		local modules = upper("`module'")
		local modulelist ""
		foreach mod of local modules {
			local modulelist `"`modulelist', "`mod'""'
		}
		keep if inlist(upper(module) `modulelist')
	}
	
	pause before sending to mata
	
	*--------------------1.3: send info to MATA
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	local n = _N
	local vars countrycode year surveyid survname type module filename ///
	latest region countryname vermast veralt
	
	/*====================================================================
	2: Poverty, Inequality and Shared Prosperity Calculations
	====================================================================*/
	
	if (`n' == 0) {
		noi disp in r "there is no data for the combination " _n /* 
		*/  "`countries' "  _n "`years'"
		error
	}
	
	if (regexm("`calcset'", "`allind_'|all")) {
		local wrkfiles "wrkpov wrkine wrkshp wrkkey"
		tempfile `wrkfiles' empty wildcard // working surveys file
		
		drop _all
		foreach wrkfile of local wrkfiles {
			save ``wrkfile'', replace emptyok
		}
		save `empty', replace emptyok
		
		
		local i = 0
		while (`i' < `n') {
			local ++i
			
			*--------------------2.2: Load data
			mata: _ind_ids(R)
			`noi' disp in w _n "{dup 20:-} New survey"
			foreach var of local vars {
				`noi' disp in g `"`var' {col 15}= "' in y `" ``var''"' 
			}
			
			if ( "`calcset'" == "key" & !inlist("`module'", "ALL", "UDB-C")) continue
			
			noi disp in y _n `"datalibweb, country(`countrycode') year(`year') type(`type') fileserver filename(`filename') cpivintage(`cpivintage') nometa clear"'
			
			cap datalibweb, country(`countrycode') year(`year') type(`type') fileserver  /* 
			*/			filename(`filename') cpivintage(`cpivintage') nometa clear
			if (_rc) {
				disp in red "datalibweb didn't load `filename'"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (11)
				continue
			}
			
			copy `empty' `wildcard', replace 
			*--------------------2.3: check usability of survey
			
			**** Welfare
			
			local wlfvars ""
			foreach wvar of local welfarevars {
				cap confirm var `wvar', exact
				if (_rc) continue
				else { // welfare in ppp
					
					replace `wvar' = . if `wvar' < 0
					cap gen double `wvar'_ppp = `wvar'/cpi2011/icp2011/365	
					if (_rc) {
						disp in red "Err creating `wvar'_ppp"
						post `ef' ("`region'") ("`countrycode'") ("`year'") ///
						("`filename'") (13)
						continue
					}
					local wlfvars "`wlfvars' `wvar'"
					
				} // end of condition if var exists
			} // end of welfare vars loop
			
			* drop welfare variables with missing values in all obs
			
			if ("`wlfvars'" == "") {
				disp in red "No welfare variable available in `filename'"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (12)
				continue
			}
			else {
				missings dropvars `wlfvars', force
				local dropvars = "`r(varlist)'"
				local wlfvars: list wlfvars - dropvars
				
				if ("`wlfvars'" == "") {  // one more time after substracting dropvars
					disp in red "No welfare variable available in `filename'"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (12)
					continue
				}
			}
			
			** welfare type
			
			local welftype: char _dta[welfaretype]     // if char exist
			if ("`welftype'" == "") {     
				cap confirm var welfaretype         // if var exist
				if (_rc) local welftype "Unknown"   // if var does not exist
				else {
					local welftype = welfaretype[1]
					if ("`welftype'" == "") local welftype "Unknown"
				}
			}
			
			**** treatment of weight variable
			cap confirm var weight, exact 
			if (_rc == 0) local weight weight
			else local weight weight_p 
			
			
			*** Extract
			cap drop __0*   // drop any temporal variable
			cap tostring hhid, replace
			
			
			*percentiles
			if ("`module'" != "GROUP") {
				foreach wvar of local wlfvars {
					quantiles `wvar'_ppp [aw = `weight'], n(10) gen(q`wvar') keeptog(hhid)
				}
			}
			else {
				cap noi {
					sum bins, meanonly
					gen qwelfare = round(1+ (bins-r(min))*(10-1)/(r(max)-r(min)))
				}
			}
			
			tempfile generalf dtasign
			save `generalf', replace
			datasignature set, reset saving(`dtasign', replace)
			
			**----------------- Inequality ------------------
			
			if (regexm("`calcset'", "ine|all")) {
				if regexm("`trace'", "ine|all") set trace on
				cap datasignature confirm using `dtasign'
				if (_rc) use `generalf', clear
				
				copy `empty' `wildcard', replace 
				cap indicators_ine, weight(`weight') wlfvars("`wlfvars'") /* 
        */ wildcard("`wildcard'")  `pause'
 
				if (_rc!=0){
					disp as error "Err calculating inequality"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ("`filename'") (21)
					continue
				}
				
				use `wildcard', clear
				foreach var of local vars {
					gen `var' = "``var''"
				}
				gen welftype = "`welftype'"
				replace welftype = "INC" if welfarevar == "pcinc"  
				replace welftype = "EXP" if welfarevar == "pcexp"  
				
				_gendatetime, date("`date'") time("`time'")
				
				append using `wrkine' 
				compress
				save `wrkine', replace 		
				
				disp in y _n "`filename' ine OK"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (20)

				
			}
			set trace off
			
			**----------------- FGT family ------------------
			if (regexm("`calcset'", "pov|all")) {
				if regexm("`trace'", "pov|all") set trace on
				
				cap datasignature confirm  using `dtasign'
				if (_rc) use `generalf', clear
				
				copy `empty' `wildcard', replace 
				cap `noi' indicators_pov [aw = `weight'], plines("`plines'") /* 
				*/  wlfvars(`wlfvars') wildcard("`wildcard'") `pause'
				
				if (_rc) {
					disp in red "Err calculating poverty"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (31)
					continue
				}
				
				use `wildcard', clear
				foreach var of local vars {
					gen `var' = "``var''"
				}
				
				gen welftype = "`welftype'"
				replace welftype = "INC" if welfarevar == "pcinc"  
				replace welftype = "EXP" if welfarevar == "pcexp"  
				
				_gendatetime, date("`date'") time("`time'")
				
				append using `wrkpov' 
				save `wrkpov', replace 		
				
				disp in y _n "`filename' pov OK"
				post `ef' ("`region'") ("`countrycode'") ("`year'") ///
				("`filename'") (30)
			}
			set trace off
			
			**----------------- Shared Prosperity ------------------
			if (regexm("`calcset'", "shp|all")) {
				if regexm("`trace'", "shp|all") set trace on
				
				cap datasignature confirm  using `dtasign'
				if (_rc) use `generalf', clear
				
				copy `empty' `wildcard', replace 
				cap indicators_shp [aw = `weight'], wlfvars(`wlfvars')  /*  
				*/ wildcard("`wildcard'")
				
				if (_rc) {
					disp in red "Err ShP"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (41)
					continue
				}
				else { // if not error
					
					use `wildcard', clear
					foreach var of local vars {
						gen `var' = "``var''"
					}
					
					* rename variables for reshape
					desc St60-t10, varlist
					local vars2ren "`r(varlist)'"
					rename (`vars2ren') values=
					
					_gendatetime, date("`date'") time("`time'")
					
					* Welfare type 
					gen welftype = "`welftype'"
					replace welftype = "INC" if welfarevar == "pcinc"  
					replace welftype = "EXP" if welfarevar == "pcexp"  
					
					label var valuesSt60  "Sum of welfare of the Top 60"
					label var valuesNt60  "No. of obs in the Top 60"
					label var valuest60   "Mean welfare of Top 60"
					label var valuesSb40  "Sum of welfare of the Bottom 40"
					label var valuesNb40  "No. of obs in the Bottom 40"
					label var valuesb40   "Mean welfare of Bottom 40"
					label var valuesSmean "Sum of welfare of Tot. population"
					label var valuesNmean "No. of obs in Tot. population"
					label var valuesmean  "Mean welfare of Tot. population"
					label var valuest10   "Mean welfare of the Top 10"
					
					append using `wrkshp' 
					save `wrkshp', replace 		
					
					disp in y _n "`filename' shp OK"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (40)
				}
			} // end of SHP
			set trace off
			
			**----------------- Key Indicators ------------------
			
			* pause iteration `i' 
			
			if (regexm("`calcset'", "key|all") & inlist("`module'", "ALL", "UDB-C")) {
				if regexm("`trace'", "key|all") set trace on
				
				cap datasignature confirm  using `dtasign'
				if (_rc) use `generalf', clear
				
				copy `empty' `wildcard', replace 
				cap noi indicators_key [aw = `weight'], wlfvars(`wlfvars') /* 
				*/  plines("`plines'") wildcard("`wildcard'") `pause'
				
				if (_rc) {
					disp in red "Err key indicators"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (61)
					continue
				}
				else { // if not error
					
					use `wildcard', clear
					foreach var of local vars {
						gen `var' = "``var''"
					}
					
					pause key - after creating key indic file wildcard
					* Welfare type 
					gen welftype = "`welftype'"
					replace welftype = "INC" if welfarevar == "pcinc"  
					replace welftype = "EXP" if welfarevar == "pcexp"  
					
					_gendatetime, date("`date'") time("`time'")
					
					rename p_* values*
					
					append using `wrkkey' 
					save `wrkkey', replace 		
					
					disp in y _n "`filename' key OK"
					post `ef' ("`region'") ("`countrycode'") ("`year'") ///
					("`filename'") (60)
				}
			} // end of key
			set trace off
			
		} // end of surveys loop
		
		*=============================================================
		*========= poverty, Inequality, Shared Prosperity FILES ======
		*=============================================================
		if (regexm("`calcset'", "`allind_'|all")) {       // only key indicators
			if regexm("`trace'", "file|all") set trace on   // trace
			
			if (regexm("`calcset'", "all")) local calcset "`allind'"  // remove all 
			
			
			foreach calc of local calcset {
				if !regexm("`calc'", "`allind_'") continue   // make sure 'report' or other don't go
				local basename "indicators_`calc'"
				
				
				if ("`calc'" == "key")  local precase "precase"
				else                    local precase ""
				
				
				
				// load current file and merge with new information
				indicators `calc', load `pause'
				cap confirm var datetime
				if (_rc) _gendatetime, date("`date'") time("`time'")
				
				noi desc using `wrk`calc''
				if (r(N) == 0) {
					noi disp in r "Warning: " in y "working file `calc' is empty"
					continue
				}
				
				merge 1:1 filename welfarevar `precase' using `wrk`calc'', /* 
				 */   update replace nogen 
				
				
				cap `noi' indicators_touse `calc', `pause'
				if (_rc) {
					disp in red "Err `calc' _touse variable"
					post `ef' ("all") ("all") ("") ("") (`e'2)
				}
				pause `calc' - After creating _touse variable
				
				* save file 
				cap noi indicators_save `calc', basename(`basename') out("`out'") /*  
				*/  datetime(`datetime') `force' `pause'
				if (_rc) {
					disp in red "Err `calc' saving"
					post `ef' ("all") ("all") ("") ("") (`e'3)
				}
				
			} // end of set of calculation loop 
			
		} // end pov file update section
		set trace off
	}
	
	/*====================================================================
	4: WDI
	====================================================================*/
	
	if (regexm("`calcset'", "wdi")) {
		local errwdi = 0
		cap  {
			*--------------------3.1: extract and save 
			wbopendata, indicator(`wbodata') long clear nometadata
			compress			
			
			replace regioncode = "EAP" if regioncode == "EAS"
			replace regioncode = "ECA" if regioncode == "ECS"
			replace regioncode = "LAC" if regioncode == "LCN"
			replace regioncode = "MNA" if regioncode == "MEA"
			replace regioncode = "SAR" if regioncode == "SAS"
			replace regioncode = "SSA" if regioncode == "SSF"
			
			
			_gendatetime, date("`date'") time("`time'")
		}  // end of cap
		if (_rc) {
			noi disp in red "Err extracting WDI info"
			post `ef' ("ALL") ("ALL") ("ALL") ///
			("wbopendata") (51)
			error
		}
		
		if regexm("`trace'", "wdi") set trace on 			
		local basename "indicators_wdi"
		local wdifile_wide "`out'/`basename'_wide.dta"
		cap confirm new file "`wdifile_wide'"
		//if (_rc) append using "`wdifile_wide'"
		
		
		cap noi indicators_vcontrol wdi
		if (_rc) {
			disp in red "Err wdi vcontrol"
			post `ef' ("all") ("all") ("") ("") (52)
			local errwdi = 1
		}
		
		local ivars "countrycode year datetime date time vc_*"
		reshape wide values, i(`ivars') j(wdi) string
		rename values* *
		
		order region* country* year date time datetime vc_*
		*------------------3.2: Reshape -> long and Save
		cap noi indicators_save wdi, basename(`basename') out("`out'") /* 
		 */ datetime(`datetime') `force'
		if (_rc) {
			disp in red "Err WDI saving"
			post `ef' ("all") ("all") ("") ("") (53)
			local errwdi = 1
		}
		
		if regexm("`trace'", "wdi") set trace off
		*--------------------3.3: Errors
		if (`errwdi' == 0) {
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
	61  "Err in key"  ///
	20  "OK ine"  ///
	30  "OK pov"  ///
	40  "OK shp"  ///
	50  "OK wdi"  ///
	60  "OK key"  ///
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
		
		else `noi' disp "No observation with error"
		
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
		`noi' disp in w "{hline}"
		
		save "`masterr'", replace
		indicators_report , file("`masterr'") `noi'
	}
	
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

cap confirm var date
if (_rc) gen double date = date("`date'", "DMY")
format date %td

cap confirm var time
if (_rc) gen double time = clock("`time'", "hms")
format time %tcHH:MM:SS

// I do it this way to understand the relation
gen double datetime = date*24*60*60*1000 + time  
format datetime %tcDDmonCCYY_HH:MM:SS

end

/*====================================================================
Mata functions
====================================================================*/
mata
//mata drop _ind*()
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


adopath ++ "c:\Users\wb384996\OneDrive - WBG\GTSD\02.core_team\01.programs\01.ado\indicators"
adopath - "c:\Users\wb384996\OneDrive - WBG\GTSD\02.core_team\01.programs\01.ado\indicators"

indicators all, countr(PRY ALB) years(2012 2013) 

indicators pov, countr(HND) years(2012 2013) 
indicators ine, countr(HND) years(2012 2013) 

indicators pov
indicators ine
indicators shp
indicators key

* indicators pov, filename(PRY_2012_EPH_V01_M_V02_A_GMD_ALL.dta) trace(pov)

