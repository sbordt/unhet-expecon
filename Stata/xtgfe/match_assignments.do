capture program drop match_assignments

* match two different groupings in a way that minimizes misspecifications 
program match_assignments, rclass
	version 13
	syntax varlist(min=2 max=2 numeric),
	
	tokenize `varlist'
	local g_1 "`1'"
	local g_2 "`2'"
		
	qui {
		tempvar max_group mode_assignment distinct_modes assertion a_group
		
		* determine the number of groups
		egen `max_group' = max(`g_1')
		local g = `max_group'[1]
	
		* FIRST: Does matching each group to it's mode work?
		sort `g_1'	

		* for each group, get the number that most elements were assigned to
		by `g_1': egen `mode_assignment' = mode(`g_2')
		
		* assert that we got a valid permutation
		egen `distinct_modes' = group(`mode_assignment')
		egen `assertion' = max(`distinct_modes')
		
		if (`assertion'[1] == `g') {
			* YES it works
		
			* recode
			gen `a_group' = .
			
			foreach i of numlist 1/`g' {
				preserve
				keep if `g_1' == `i' 
				local a = `mode_assignment'[1]
				restore
				
				replace `a_group' = `i' if `g_2' == `a'
			}
		} 
		else {
			* NO it does not work
			
			* SECOND: try all possibile permutations
			n assert `g' < 8
		
			* create a matrix where each row is a permutation
			preserve
			clear 
			set obs `g'
			gen i = _n

			foreach i of numlist 1/`g' {
				gen i_`i' =  i
			}
			drop i

			fillin i_1-i_`g'
			drop _fillin

			foreach i of numlist 1/`g' {
				foreach j of numlist 1/`g' {
					if `i'!=`j' {
						drop if i_`i' == i_`j'
					}
				}
			}
			mkmat i_1-i_`g', matrix(P)
			restore

			* try each permutation and choose the one that gives the smallest number of missmatches
			gen `a_group' = .
			local misspec = _N
		
			local n = rowsof(P)
			foreach row of numlist 1/`n' {
				matrix p = P[`row', 1..`g'] 
				
				* recode group assignment according to permutation
				gen p_group = .
				
				foreach i of numlist 1/`g' {
					replace p_group = `i' if `g_2' == p[1,`i']
				}
				
				* count number of missmatches
				count if `g_1' != p_group
				
				if  r(N) < `misspec' {
					local misspec = r(N)
					replace `a_group' = p_group
				}
				
				drop p_group
			}
		}
		
		count if `g_1' != `a_group'
		local misspec = r(N)
		local misspec_per_cent = `misspec'/_N*100
	}
	
	// TODO: STORE RESULTS, currently in tempvar a_group
		
	* store regression results
	return clear
	
	return scalar match = `misspec' == 0
	return scalar misspec_per_cent = `misspec_per_cent'
	
	di "`misspec' observations (`misspec_per_cent'%) were assigned to the wrong group."
end




