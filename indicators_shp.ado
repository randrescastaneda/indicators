/*==================================================
project:       calculate Shared Prosperity Indicators
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     9 Jun 2018 - 12:24:20
Modification Date:   
Do-file version:    01
References:          
Output:             __Iwildcard
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define indicators_shp, rclass
syntax [aweight fweight pweight], wlfvars(string) wildcard(string)


/*==================================================
1: Shared prosperity
==================================================*/

tempname shpf

postfile `shpf' str20 welfarevar double(St60 Nt60 t60 Sb40 Nb40 b40 Smean Nmean mean t10) /* 
*/  using `wildcard', replace

foreach wvar of local wlfvars { 
	
	cap b40 `wvar'_ppp [`weight'`exp']
	
	local results "St60 Nt60 t60 Sb40 Nb40 b40 Smean Nmean mean"
	foreach r of local results {
		local `r'  = `r(`r')'
	} 
	sum `wvar'_ppp [`weight'`exp'] if q`wvar'==10
	local t10 = r(mean)
	
	post `shpf' ("`wvar'") (`St60') (`Nt60') (`t60') (`Sb40') /* 
	*/	(`Nb40') (`b40') (`Smean') (`Nmean') (`mean') (`t10')
	
}
postclose `shpf'


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


