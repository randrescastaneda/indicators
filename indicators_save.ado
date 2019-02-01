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
syntax anything(name=calcset id="set of calculations"), /* 
 */  basename(string) out(string) /* 
 */  datetime(numlist) [ force pause vcnumber(numlist) ]


if ("`pause'" == "pause") pause on
else                      pause off

/*==================================================
1: Save results
==================================================*/
qui {
// check whether file is the same as before
* create temporal id

// precase local for key indicators
if ("`calcset'" == "key")  local precase "precase"
else                       local precase ""


// extract key for dates
preserve 
	keep date time datetime filename welfarevar `precase'
	tempfile tkey
	save `tkey', replace
	pause after saving new key
restore 
drop date time datetime 

// confirm data has changed
cap noi datasignature confirm using /* 
*/    "`out'/_datasignature/`basename'", strict
if (_rc | "`force'" == "force") {
	
	//-------  Set signature
	noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/`basename'", replace)
	noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/`basename'_`datetime'", replace)
	
	// merge new dates
	merge 1:1 filename welfarevar `precase' using `tkey', /* 
 */	 update replace nogen
 
 
	* save files
	if ("`vcnumber'" != "") {  // if it was restored
		local vfilename "`basename'_`datetime'_rf_`vcnumber'.dta"
		local datetimeHRF_rf: disp %tcDDmonCCYY_HH:MM:SS `vcnumber'
		local datetimeHRF_rf = trim("`dispdate'")
	}
	else {   // if it is new
		local vfilename "`basename'_`datetime'.dta"
	}
	
	*------------------------------------------------
	*------- Create characteristics of file ---------
	*------------------------------------------------
	local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
	local datetimeHRF = trim("`dispdate'")
	
	
	char _dta[datetimeSIF]    "`datetime'"
	char _dta[datetimeHRF]    "`datetimeHRF'"
	char _dta[datetimeSIF_rf] "`vcnumber'"
	char _dta[datetimeHRF_rf] "`datetimeHRF_rf'"
	char _dta[basename]       "`basename'"
	char _dta[calcset]        "`calcset'"
	char _dta[shape]          "wide"
	
	
	*------------------------------------------------
	*------- Save in wide format---------
	*------------------------------------------------
	
	save "`out'/_vintage/`vfilename'", replace
	save "`out'/`basename'_wide.dta", replace
	
	*------------------------------------------------
	*------------ convert to long--------------------
	*------------------------------------------------
	
	indicators_reshape_long `calcset'
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


disp in y _n `"{stata use "`out'/`basename'_long.dta": Load `sname' file}"'
foreach regionp of local regionsp {
	disp in y _n `"{stata `disptab':    `regionp'}"'
} // end of regions loop


}
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. Important locals to use in other programs


local datasignature_si  : char  _dta[datasignature_si] 
local datetimeSIF       : char  _dta[datetimeSIF]      
local datetimeHRF       : char  _dta[datetimeHRF]      
local datetimeSIF_rf    : char  _dta[datetimeSIF_rf]   
local datetimeHRF_rf    : char  _dta[datetimeHRF_rf]     
local shape             : char  _dta[shape]          
local calcset           : char  _dta[calcset]          


2.
3.


Version Control:








