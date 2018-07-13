/*==================================================
project:       create repo for GPWG2 data (eusilc)
Author:        Andres Castaneda based on Minh's power shell files 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    12 Jul 2018 - 14:28:52
Modification Date:   
Do-file version:    01
References:          
Output:             dta file
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_gpwg2, rclass
syntax , [ out(string)  datetime(numlist) ] 
version 14

/*==================================================
create txt file
==================================================*/

/* 
Note: this part still needs to be automated
*/


/*==================================================
load data from txt
==================================================*/
local rootaux "`out'/_aux"

*----------
//getting datalibweb formatted catalog powershell
tempfile cattmp ctryregname
dlw_countryname, savepath(`ctryregname')

//Datalib_all_DTAs_EUSILC.txt is input from powershell - running daily by a person
import delimited using "`rootaux'\Datalib_all_DTAs_EUSILC.txt" , /* 
*/     clear varnames(2) delim(";")

*---------- split variables
split fullname, p("\")

ren fullname7 code
ren fullname9 surveyid
ren fullname10 filename
drop fullname*

split filename, p("_")
ren filename2 years
ren filename3 survname
ren filename4 vermast
ren filename6 veralt	
ren filename8 col
ren filename9 module
drop filename?


*----------fix and merge data
replace mod = subinstr(mod,".dta","",.)

replace vermast  = lower(vermast)
replace veralt   = lower(veralt)
replace survname = upper(survname)

merge m:1 code using `ctryregname', keep(1 3) nogen

ren code country // has to be done after the merge
replace country = upper(country)
order country years surveyid survname col module filename /* 
*/ filename region countryname vermast veralt 

//drop WRK old
drop  creationtime lastwritetime  length

*---------- keep latest
bys country years survname col mod (verm vera): gen latest = _n==_N
tostring years, replace
replace col = "GPWG2"

drop owner
char _dta[version] $S_DATE
keep if latest==1
sort country years survname module
isid country years survname module
compress


*---------- save
cap datasignature confirm using /* 
*/    "`out'/_datasignature/repo_gpwg2", strict
if (_rc) {
	noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/repo_gpwg2", replace)
	
	noi datasignature set, reset /* 
	*/    saving("`out'/_datasignature/repo_gpwg2_`datetime'", replace)
	
	* save files
	save "`out'/_vintage/repo_gpwg2_`datetime'.dta", replace
	save "`out'/repo_gpwg2.dta", replace		
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


