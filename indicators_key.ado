/*====================================================================
*!project:       Key indicators
*!Author:        GTSD
*!Creation Date: 18Jun2018 - 13:58:05
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_key
syntax [aweight fweight pweight], plines(string) wlfvars(string) 

tempname Mkey // name of big matrix

qui {
	
	cap drop hhsize
	ren hsize hhsize
	sort  hhid relationharm  
	duplicates drop hhid , force		//MAKING it household level data
	gen double popw `exp'*hhsize
	
	//Define rural
	cap gen rur=(urban==0) if urban!=.
	
	//Age groups
	recode  age (0/14 = 1 gage1) (15/64 = 2 gage2) (65/max = 3 gage3) , gen(gage)
	replace gage=. if age==.
	
	clonevar edu = educat4
	replace edu = . if edu!=. & (age<16 | age==.)
	
	* lab def males 0 "ggender" 1 "ggender1"
	* lab val male males
	local byvars rur male gage edu
	
	local w = 0
	foreach wvar of local wlfvars {
		local ++w
		
		foreach ll of local plines	{
			local a = 100*`ll'
			gen poor`a'`wvar' = (`wvar'_ppp < `ll') if `wvar'_ppp != .
		}
		
		* la def poor 1"Poor" 0"Non Poor"
		* for var poor* : la val X poor
		
		//Define b40
		gen B40`wvar' = q`wvar' <= 4 
		gen T60`wvar' = B40`wvar' ==0 if B40`wvar' !=.
		* la def b40 1"B40" 0"T60"
		* la val B40 b40
		
		foreach pline of loc plines	{
			local nm = 100*`pline'
			gen poor`nm'_np`wvar' = poor`nm'`wvar' ==0 if poor`nm'`wvar' !=.
			rename poor`nm'`wvar' poor`nm'_p`wvar'
		}
		
		local meanes poor190_np`wvar' poor190_p`wvar' poor320_np`wvar' poor320_p`wvar' ///
		poor550_np`wvar' poor550_p`wvar' B40`wvar' T60`wvar' 
		
		local m = 0
		foreach byvar of local byvars	{
			local ++m
			
			tempname Mt
			
			tabstat `meanes' [aw = popw], by(`byvar') save  nototal
			tabstatmat `Mt',  nototal
			mata: Km = st_matrix(st_local("Mt")) ; /* 
			*/        st_matrix(st_local("Mt"), (Km, (1::rows(Km))))
			
			mat `Mkey' = nullmat(`Mkey') \ `Mt', J(rowsof(`Mt'), 1, `m') /* 
			*/          , J(rowsof(`Mt'), 1, `w')  
			
		} // end of byvars loop
		
	}  // end of welfare vars loop
	
	drop _all
	mat colname `Mkey' = p_190np p_190p p_320np p_320p /* 
	*/            p_550np p_550p p_B40 p_T60 precase byvar welfarevar 
	
	svmat `Mkey', names(col)
	tostring precase byvar welfarevar, replace force
	
	* Add Labels
	
	* welfare var
	local i = 0
	foreach wvar of local wlfvars {
		local ++i
		replace welfarevar = "`wvar'" if welfarevar == "`i'"
	}
	
	* byvars
	local i = 0
	foreach byvar of local byvars {
		local ++i
		replace byvar = "`byvar'" if byvar == "`i'"
	}
	
	replace precase = byvar+precase
	drop byvar
	
	save __Iwildcard.dta, replace
	
} // end of qui

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

