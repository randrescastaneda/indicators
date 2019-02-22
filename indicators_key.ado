/*====================================================================
*!project:       Key indicators
*!Author:        GTSD
*!Creation Date: 18Jun2018 - 13:58:05
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_key
syntax [aweight fweight pweight], ///
plines(string)    ///
wlfvars(string)   ///
wildcard(string)  ///
[ pause ]
if ("`pause'" == "pause") pause on
else                      pause off



tempname Mkey // name of big matrix

qui {
	
	/* 
	cap drop hhsize
	ren hsize hhsize
	sort  hhid
	duplicates drop hhid , force		//MAKING it household level data
	gen double popw `exp'*hhsize
	*/
	
	//Define rural
	cap gen rur=(urban==0) if urban!=.
	replace rur = rur + 1  // to match convention of PEB SM2018
	
	//Age groups
	recode  age (0/14 = 1 gag1) (15/64 = 2 gag2) (65/max = 3 gag3) , gen(gag)
	replace gag=. if age==.
	
	clonevar edu = educat4
	replace edu = . if edu!=. & (age<16 | age==.)
	
	* lab def males 0 "ggender" 1 "ggender1"
	* lab val male males
	rename male gen
	replace gen  = gen + 1  // to match convention of PEB SM2018
	local byvars rur gen gag edu
	
	pause key - before loop of welfare variables. 
	local w = 0
	foreach wvar of local wlfvars {
		local ++w
		
		foreach ll of local plines	{
			local a = 100*`ll'
			gen poor`a'`wvar' = (`wvar'_ppp < `ll') if `wvar'_ppp != .
		}
		
		pause key - after creating poverty indicator with `wvar'
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
		local nm: word count `meanes'
		foreach byvar of local byvars	{
			local ++m
			if inlist("`byvar'" , "rur", "gen") numlist "1/2"
			if inlist("`byvar'" , "gag")        numlist "1/3"
			if inlist("`byvar'" , "edu")        numlist "1/4"
			
			local levels = "`r(numlist)'"
			
			foreach level of local levels {
			tempname Mt
				/* NOTE: This process is significantly slower than the one before, but 
				in this way we make sure countries that have incomplete values in their
				categorical variables are included correctly.  */
			pause before - tabstat `meanes' [aw `exp'] if `byvar' == `level' , save
			
				cap tabstat `meanes' [aw `exp'] if `byvar' == `level' , save
				if (_rc) {
					
					matrix `Mt' = J(1, `nm', .)
				}
				else {
					
					tabstatmat `Mt',  nototal	
					
				}
				
				matrix `Mt' = `Mt', `level'
				mat `Mkey' = nullmat(`Mkey') \ `Mt', J(rowsof(`Mt'), 1, `m'), /* 
				*/           J(rowsof(`Mt'), 1, `w')  
				
			} // end of levels loop
		} // end of byvars loop
		
	}  // end of welfare vars loop
	
	
	drop _all
	mat colname `Mkey' = p_190np p_190p_ p_320np p_320p_ /* 
	*/            p_550np p_550p_ p_B40__ p_T60__ precase byvar welfarevar 
	
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
	
	save `wildcard', replace
	
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
	
		