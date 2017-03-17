
capture program drop xtgfe_estat
program xtgfe_estat, rclass
    version 13
 
    if "`e(cmd)'" != "xtgfe" {
        error 301
    }
 
    gettoken subcmd rest : 0, parse(" ,")
    if "`subcmd'"=="geplot" {
		geplot
    }
    else {
        estat_default `0'
        return add
    }
	
	return add
end
 
**********************************************
* Plot group effects						 *
**********************************************
capture program drop geplot 
program geplot
	version 13
		
	local groups `e(groups)'
	local assignment_var `e(assignment_var)'
	local ID `e(ID)'
	matrix G = e(G)
	
	qui {
		* count number of observations assigned to each group
		matrix g_nobs = J(1,`groups',0)
		
		foreach i of numlist 1/`groups' { 
			preserve
			keep if `assignment_var' == `i'	 
			duplicates drop `ID', force
			count
			matrix g_nobs[1,`i'] = r(N)
			restore
		}
		
		* create plot
		preserve
		clear
		matrix G_prime = G'
		svmat G_prime
		svmat m_time, names("T")

		foreach i of numlist 1/`groups' { 
			local nobs = g_nobs[1,`i']
				
			label variable G_prime`i' "Group `i' (`nobs' observations)"
		}

		scatter G* T, connect(l l l l l l l l l l l l l l l l l l l l) ///
						lpattern(solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid ) ///
						msymbol(o o o o o o o o o o o o o o o o o o o o) ///									
						title("Heterogeneous Group Effects (Time series)") xtitle("") ytitle("") 
		restore	
	}
end












