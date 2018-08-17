/*====================================================================
*!project:       Inequality indicators
*!Author:        GTSD
*!Creation Date:     3 May 2018 - 15:26:58
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_ine, rclass
syntax , ///
weight(string)      ///
wlfvars(string)     ///
wildcard(string)  [ ///
pause               ///
]

if ("`pause'" == "pause") pause on
else pause off

* tempfile inefile
tempname inef

postfile `inef' str20 welfarevar double valuesgini valuestheil using "`wildcard'", replace

foreach wvar of local wlfvars { 

	putmata y = `wvar'_ppp  if (`wvar'_ppp!=. & `weight'!=.) , replace
	putmata w = `weight' if (`wvar'_ppp!=. & `weight'!=.), replace

	mata: st_local("_gini",strofreal(_ind_ine_gini(y,w)))
	mata: st_local("_theil",strofreal(_ind_ine_theil(y,w)))
	post `inef' ("`wvar'") (`_gini') (`_theil')

}
postclose `inef'
end

mata:

mata drop _ind*()
mata set mataoptimize on
mata set matafavor speed


function _ind_ine_theil(y,w){
	one=ln(y:/mean(y,w))
	two=one:*(y:/mean(y,w))
	return(mean(two,w))
}

function _ind_ine_gini(x, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}


void _ind_ids(string matrix R) {
	i = strtoreal(st_local("i"))
	vars = tokens(st_local("vars"))
	for (j =1; j<=cols(vars); j++) {
		//printf("j=%s\n", R[i,j])
		st_local(vars[j], R[i,j] )
	} 
} // end of IDs variables



end


