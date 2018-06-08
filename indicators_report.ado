/*====================================================================
*!project:       Inequality indicators
*!Author:        GTSD
*!Creation Date:     3 May 2018 - 15:26:58
*!----------------------------------------------------------------------
*!Dependencies:  The World Bank
====================================================================*/

program define indicators_report, rclass

syntax, file(string)

qui {
	use "`file'", clear
	* --------Display results
	** Those that are OK
	
	count if (regexm(strofreal(comment), "0$"))
	local nok = `r(N)'
	
	noi disp in w _dup(30) "-" " Countries OK" _dup(30) "-"
	if (`nok' != 0) {
		local tabdispt `"tabdisp filename date  if (regexm(strofreal(comment), "0$")), c(comment time) concise  by(region)"'
		noi disp `"{stata `tabdispt':OK table}"'
	}
	else noi disp "no observation was ok"
	
	** Those with errors
	count if (regexm(strofreal(comment), "[1-9]$"))
	local nerr = `r(N)'
	noi disp in w _dup(30) "-" " Countries with errors " _dup(30) "-"
	if (`nerr' != 0) {
		local tabdispt `"tabdisp filename  date if (regexm(strofreal(comment), "[1-9]$") & ok == 0), c(comment time) concise by(region)"'
		noi `tabdispt'
		noi disp `"{stata `tabdispt':NOT ok table}"'
	}
	else noi disp "no observation with Error"
	noi disp in w "{hline}"
	
	set trace off
	
}
end

exit 

