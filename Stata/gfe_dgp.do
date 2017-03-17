capture program drop gfe_dgp

* Data generating process of the Grouped Fixed-Effects Estimator (GFE) from Bonhomme and Manresa. 
* using file can specify the group effects
program gfe_dgp
	version 13
	syntax [using/], n(integer) t(integer) g(integer) v(integer)
		
	quietly {
		tempfile group_effects
		
		* group effects
		if missing("`using'") {
			clear
			set obs `g'
			gen group = _n
			expand `t'
			bysort group: gen TIME = _n
			gen group_effect = rnormal()
			save `group_effects'
		}

		* covariates, outcome and error term
		clear 
		set obs `n'
		gen ID = _n
		gen group = 1+floor(runiform(0,`g'))
		expand `t'
		bysort ID: gen TIME = _n 
		
		if missing("`using'") {
			merge m:1 group TIME using `group_effects'
			drop _merge		
		}
		else {
			merge m:1 group TIME using "`using'"
			assert _merge == 3
			drop _merge
		}
		sort ID TIME
		order ID TIME group
		rename group_effect alpha_g_i
		label variable alpha_g_i "grouped fixed effect"
		
		gen y = alpha_g_i
		label variable y "~ x1 + ... + xn + alpha_g_i + epsilon"
		
		foreach i of numlist 1/`v' {	// have some variation in the distrubtions and correlation with the grouped fixed effect
			if (`i' == 1) {
				gen x`i' = rnormal(0,1)
				label variable x`i' "~ i.i.d. normal(0, 1)"
			} 
			else if (`i' == 2) {
				gen x`i' = rnormal(alpha_g_i,1)
				label variable x`i' "~ i.i.d. normal(alpha_g_i, 1)"
			} 
			else if (`i' == 3) {
				gen x`i' = rnormal(-alpha_g_i,1)
				label variable x`i' "~ i.i.d. normal(-alpha_g_i, 1)"
			}
			else if (`i' == 4) {
				gen x`i' = runiform(-1,1)
				label variable x`i' "~ i.i.d. uniform(-1, 1)"
			}
			else if (`i' == 5) {
				gen x`i' = rbeta(0.5,0.5)
				label variable x`i' "~ i.i.d. beta(0.5, 0.5)"
			}
			else if (`i' == 6) {
				gen x`i' = rpoisson(10)
				label variable x`i' "~ i.i.d. poi(10)"
			}
			else if (`i' == 7) {
				gen x`i' = 1+5*abs(alpha_g_i)
				label variable x`i' "~ i.i.d. poi(1 + 5*abs(alpha_g_i))"
			}
			else {
				gen x`i' = rnormal()
				label variable x`i' "~ i.i.d. normal(0, 1)"
			}
			
			replace y = y + x`i'
		}

		* error term
		gen epsilon = rnormal(0,1)
		label variable epsilon "~ i.i.d. normal(0, 1)"
		
		replace y = y + epsilon
		
		* indicate panel data
		xtset ID TIME
	}
end
