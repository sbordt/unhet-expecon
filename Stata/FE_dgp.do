capture program drop FE_dgp

* Data generating process of longitudal data with individual and time fixed effects
program FE_dgp
	version 13
	syntax , n(integer) t(integer) v(integer)
		
	quietly {	
		tempfile time_effects
		
		* time effects
		clear
		set obs `t'
		gen TIME = _n
		gen delta_t = rnormal(0,1)
		save `time_effects'		
		
		* individual effects and time effects
		clear
		set obs `n'
		gen ID = _n
		gen c_i = rnormal(0,1)
		expand `t'
		bysort ID: gen TIME = _n
		order ID TIME
		merge m:1 TIME using `time_effects'
		drop _merge
		sort ID TIME
		order ID TIME c_i delta_t
		
		label variable c_i "~ i.i.d. normal(0,1)"
		label variable delta_t "~ i.i.d. normal(0,1)"
		
		* covariates and outcome
		gen y = c_i + delta_t
		
		foreach i of numlist 1/`v' {	// have some variation in the distrubtions and correlation with the individual fixed effect
			if (`i' == 1) {
				gen x1 = rnormal(0,1)
				label variable x`i' "~ i.i.d. normal(0,1)"
			} 
			else if (`i' == 2) {
				gen x2 = rnormal(c_i,1)
				label variable x`i' "~ i.i.d. normal(c_i,1)"
			}
			else if (`i' == 3) {
				gen x3 = rnormal(-c_i,1)
				label variable x`i' "~ i.i.d. normal(-c_i,1)"
			}
			else if (`i' == 4) {
				gen x4 = runiform(-1,1)
				label x`i' "~ i.i.d. uniform(-1, 1)"
			}
			else {
				gen x`i' = rnormal()
				label variable x`i' "~ i.i.d. normal(0,1)"
			}
			
			replace y = y + x`i'
		}

		* error term
		gen epsilon = rnormal(0,1)
		label variable epsilon "~ i.i.d. normal(0,1)"
		
		replace y = y + epsilon
		
		xtset ID TIME
	}
end
