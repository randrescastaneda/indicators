/*====================================================================
*!project:       Poverty indicators
*!Author:        GTSD
*!Creation Date:     3 May 2018 - 15:26:58
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_pov
syntax [aweight fweight pweight], plines(string) wlfvars(string) 

foreach wvar of local wlfvars {
	preserve 
	foreach ll of local plines	{
		forval a=0/2	{
			gen fgt`a'_`=100*`ll'' = 100*((`wvar'_ppp<`ll')*(1-(`wvar'_ppp/`ll'))^`a')
		}
	}
	
	gen one = 1
	groupfunction [`weight'`exp'], mean(fgt* cpi2011 icp2011 `wvar'_ppp) by(one)
	drop one
	
	rename `wvar'_ppp welfare_mean
	label var welfare_mean "Welfare mean dollar a day (2011 PPP)"
	
	gen welfarevar = "`wvar'"
	
	append using __Iwildcard
	save __Iwildcard.dta, replace
	restore
}  // end of welfare vars loop


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

