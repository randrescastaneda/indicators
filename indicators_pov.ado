/*====================================================================
*!project:       Poverty indicators
*!Author:        GTSD
*!Creation Date:     3 May 2018 - 15:26:58
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_pov
syntax [aweight fweight pweight], ///
plines(string)   ///
wlfvars(string)  ///
wildcard(string) ///
[ pause ]

if ("`pause'" == "pause") pause on
else pause off

tempname Mt Mfgt

local  w = 0
foreach wvar of local wlfvars {
	local ++w
	foreach ll of local plines	{
		forval a=0/2	{
			gen fgt`a'_`=100*`ll''_`wvar' = 100*((`wvar'_ppp<`ll')*(1-(`wvar'_ppp/`ll'))^`a')
		}
	}
	
	local fgts "fgt0*_`wvar' fgt1*_`wvar' fgt2*_`wvar'"
	
	tabstat `fgts' [`weight'`exp'], save 
	tabstatmat `Mt',  nototal
	
	mat `Mfgt' = nullmat(`Mfgt') \ `w',`Mt'
	
}  // end of welfare vars loop

drop _all

mat colname `Mfgt' = welfarevar fgt0_190 fgt0_320  fgt0_550 /* 
 */                             fgt1_190 fgt1_320  fgt1_550 /* 
 */                             fgt2_190 fgt2_320  fgt2_550  

svmat `Mfgt', names(col)
tostring welfarevar, replace force

* Add welfare var Labels

local i = 0
foreach wvar of local wlfvars {
	local ++i
	replace welfarevar = "`wvar'" if welfarevar == "`i'"
}

save `wildcard', replace
end



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

