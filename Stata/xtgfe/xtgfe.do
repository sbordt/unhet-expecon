global gfe_estimator_dir "S:\people\Sebastian B\Masterarbeit\xtgfe\"

capture program drop xtgfe
program xtgfe, eclass
	version 13
	syntax varlist(min=1), groups(integer) [debug(integer 0) nomissthres(integer -1) algorithm(integer 1) nsim(integer 5) neighbours(integer 10) ///                              
											 steps(integer 10) errors(integer 0) ///
											 errors_algorithm(integer 1) errors_nsim(integer 10) ///
											 errors_neighbours(integer 5) errors_steps(integer 10) ///
											 errors_replications(integer 5)]
	tokenize `varlist'
	local OUTCOME "`1'"
	macro shift
	local COVARIATES "`*'"
	local NCOVARIATES: word count `COVARIATES'
	
	* no covariates => no std. errors
	if `NCOVARIATES' == 0 {
		local errors = 0
	}	
	
	local ID "`_dta[iis]'"
	local TIME "`_dta[tis]'"
	if missing("`ID'") | missing("`TIME'") {	// we require the user to indicate panel dimensions using 'xtset' in advance
		di as error "panel variable not set; use xtset varname ..." 
		error 459
	}
	
	if missing("$gfe_estimator_dir") {
		di as error "the directory to of the executabtle and *.bat-file of the gfe estimator has to be specified in the global variable gfe_estimator_dir" 
		error 9
	}
	
	di ""
	di "   Grouped Fixed-Effects Estimator (GFE) from Bonhomme and Manresa."
	di ""
	di "   PARAMETERS:"
	di "      Number of groups = `groups'"
	di "      Number of covariates = `NCOVARIATES'"
	
	if `algorithm' == 0 {
		di "      Algorithm = Iterative"
		di "      Number of simulations = `nsim'" 
	}
	else if `algorithm' == 1 {
		di "      Algorithm = VNS"
		di "      Number of simulations = `nsim'" 
		di "      Number of neighbours = `neighbours'" 
		di "      Number of steps = `steps'"
	}
	else {
		di as error "Algorithm must be 0 (Iterative) or 1 (VNS, the default option)."
		error 9
	}
	
	if `errors' == 0 {
		di "      No std. errors"
	}
	else {
		if `errors_algorithm' == 0 {
			di "      Std. errors algorithm = Iterative"
			di "      Std. errors number of simulations Nsim = `errors_nsim'"
		}
		else if `errors_algorithm' == 1 {
			di "      Std. errors algorithm = VNS"
			di "      Std. errors number of simulations Nsim = `errors_nsim'"
			di "      Std. errors number of neighbours = `errors_neighbours'"
			di "      Std. errors number of steps = `errors_steps'" 
		}
		else {
			di as error "Bootstrap algorithm must be 0 (Iterative) or 1 (VNS, the default option)."
			error 9
		}
		di "      Std. errors number of replications = `errors_replications'"
	}

	tempvar nomis_tot sumnomis uno var1 var2
	tempfile ORIGINAL_DATA ID_list ASSIGNMENT
	tempname foutputobj foutputobj_errors foutputobj_bootstrap
	
	*****************************************************************
	* Create a directory for the estimation to take place			*
	*****************************************************************
	if `debug' {
		// use the directory where the Bootstrap_version.exe is located
		local dir = "${gfe_estimator_dir}"
	}
	else {
		// create a temporary directory, make sure that we create a new one
		tempfile tmp
		local dir = ustrregexrf("`tmp'", ".tmp$", "" ) + " gfe estimation on" + subinstr("$S_DATE $S_TIME", ":", "_", 3) + "\"
		capture confirm file "`dir'gfe.bat"
		while _rc == 0 {
			local dir = ustrregexrf("`tmp'", ".tmp$", "" ) + " gfe estimation on" + subinstr("$S_DATE $S_TIME", ":", "_", 3) + "\"
			capture confirm file "`dir'gfe.bat"
		}
		
		mkdir "`dir'"
		copy "${gfe_estimator_dir}gfe.bat" "`dir'gfe.bat"
		copy "${gfe_estimator_dir}Bootstrap_version.exe" "`dir'Bootstrap_version.exe"
	}

	quietly {
		* save data (to be restored at the end)
		save `ORIGINAL_DATA'
		
		**********************************************************************************************
		* Handling of missing observations and creation of txt files as input to the executable		 *											   *
		**********************************************************************************************
		sort `ID' `TIME'
		
		* Define non-missing indicators, as well as a global missing indicator
		gen `nomis_tot'=1
		
		foreach vv of varlist `varlist' {
			tempvar nomis_`vv'
			gen `nomis_`vv'' = (`vv'~=.)
			replace `nomis_tot'=`nomis_tot'*`nomis_`vv''
		}

		* Compute the number of non-missing observations, by ID
		bys `ID' (`TIME'): egen `sumnomis'=sum(`nomis_tot')
		
		* Keep only if number of non-missing observations>=nomissthres (optional)
		if `nomissthres' > 0 {
			keep if `sumnomis' >= `nomissthres'
		}

		* Recompute the total non-missing indicator
		drop `sumnomis'
		bys `ID' (`TIME'): egen `sumnomis'=sum(`nomis_tot')

		* Create a file with the unit identifiers
		preserve
		gen `uno' = 1
		collapse (count) `uno', by(`ID')
		drop `uno'
		save `ID_list', replace
		restore

		* We use the convention that, when OUTCOME or any of the COVARIATES is missing, 
		*  then all of them are set to zero
		foreach vv of varlist `varlist'{
			replace `vv'=0 if `nomis_tot'==0 
		}
		
		* Store all distinct time periods in a matrix
		preserve
		keep `TIME'
		sort `TIME'
		duplicates drop
		mkmat `TIME', matrix(m_time)
		restore
		
		* Store N and T_max (ie, the maximum number of periods per individual)
		// THIS CODE IS MESSED UP AND ENTIRELY WRONG TODO: FIX
		preserve 
		su `ID', det
		count if `ID'==r(min)
		scalar Tmax=r(N)
		count
		scalar NTmax=r(N)
		scalar N=NTmax/Tmax
		gen `var1' = N
		gen `var2' = Tmax
		collapse `var1' `var2'
		outsheet using "`dir'InputNT.txt", nonames replace
		restore
		
		* count the number on nonmissing observations
		count if `nomis_tot' != 0
		local N_NOMISS = r(N)

		* Print the pattern of missing data to txt file
		preserve 
		keep `ID' `TIME' `nomis_tot'
		sort `ID' `TIME'
		reshape wide `nomis_tot', i(`ID') j(`TIME') 
		drop `ID'
		outsheet using "`dir'Ti_unbalanced.txt", nonames replace
		restore		
		
		* Print the data to txt file
		preserve
		sort `ID' `TIME'
		keep `OUTCOME' `COVARIATES'
		order `OUTCOME' `COVARIATES'
		outsheet using "`dir'data.txt", nonames replace
		restore
		
		*****************************************************************
		* Call the executable (via a bat-script)      			        *
		*****************************************************************
		shell "`dir'gfe.bat" `groups' `NCOVARIATES' `algorithm' `nsim' `neighbours' ///
												`steps' `errors' `errors_algorithm' ///
												`errors_nsim' `errors_neighbours' ///
												`errors_steps' `errors_replications'
				
		*****************************************************************
		* Incorporate the group assignement into the original data     	*
		*****************************************************************
		use `ORIGINAL_DATA', clear
		
		local assignment_var assignment
		capture confirm variable `assignment_var'		
		while !_rc {
			local assignment_var `assignment_var'_
			capture confirm variable `assignment_var'
		}
		
		* renumber groups according to their size, s.t. the largest group is group 1, then group 2, ...
		insheet using "`dir'assignment.txt", clear
		merge 1:1 _n using `ID_list'
		drop _merge
		bys v1: egen count = count(v1)
		replace count = -100*count-v1
		egen `assignment_var' = group(count)
		label variable `assignment_var' "Group No."
		drop v1 count
		save `ASSIGNMENT'
		
		use `ORIGINAL_DATA', clear
		merge m:1 `ID' using `ASSIGNMENT'
		drop _merge
	}
	
	********************************************************************
	* Read txt files created by the executable and display results     *
	********************************************************************
	
	************************  outputobj.txt ************************
	preserve
	clear
	quietly set obs `nsim'
	quietly gen objective = .
	
	di as text ""
	di as text "   " as text "{hline 64}"
	di as text "   " as text "         Values of objective function by iteration"
	di as text "   " as text "{hline 64}"
	
	file open `foutputobj' using "`dir'outputobj.txt", read
	foreach i of numlist 1/`nsim' {
		file read `foutputobj' line
		file read `foutputobj' line
		tokenize `line'
		quietly replace objective = `3' in `i'
		
		if `nsim' < 10 | `i' < 6 | `nsim'-`i' < 5 {
			di as text "      `i'. Iteration: " as result "`3'"
		}
		if `nsim' > 10 & `i' == 6 {
			di as text "      ..."
		}
		
		file read `foutputobj' line
	}
	file close `foutputobj'
	mkmat objective if _n < 401, matrix(mat_objective) 
	
	egen min = min(objective)
	gen good = (objective-min)/min < 1e-5		// a relative error of 1e-5 should do it, althoug this is quite arbitrary
	egen ngood  = sum(good)
	
	local objective_min = min[1]
	local ngood = ngood[1]
	
	di as text ""
	di as text "      Minimum: " as result "`objective_min'"  as text " (attained `ngood' times)"
	
	if `ngood' < 3 {	// if the optimum was not hit at least 3 times, issue a warning 
		di as err "      The values of the objective do not look unanimously good ... was the optimal solution found?"
	}	
	di as text ""
	
	restore
	
	************************  outputobj_bootstrap.txt ************************
	if `errors' == 1 {
		file open `foutputobj_errors' using "`dir'outputobj_bootstrap.txt", read
		file read `foutputobj_errors' line
		tokenize `line'
	
		while (!missing("`1'")) {
			while (!missing("`1'")) {
				local bootstrap_errors `bootstrap_errors' `1'
				macro shift
			}
			file read `foutputobj_errors' line
			tokenize `line'
		}
		file close `foutputobj_errors'
		
		* store bootstrap errors in a matrix
		matrix e = J(1,`NCOVARIATES',0)
	
		tokenize `bootstrap_errors'
		foreach i of numlist 1/`NCOVARIATES' {
			matrix e[1,`i'] = `1'
			macro shift
		}	
	}

	************************  assignment_bootstrap.txt ***********************
	if `errors' == 1 {
		file open `foutputobj_bootstrap' using "`dir'assignment_bootstrap.txt", read
		file read `foutputobj_bootstrap' line
		tokenize `line'
	
		while (!missing("`1'")) {
			while (!missing("`1'")) {
				local bootstrap_assignments `bootstrap_assignments' `1'
				macro shift
			}
			file read `foutputobj_bootstrap' line
			tokenize `line'
		}
		file close `foutputobj_bootstrap'	
		
		* store bootstrap assignments in a matrix
		matrix m_ba = J(`errors_replications', `NCOVARIATES', 0)
		
		tokenize `bootstrap_assignments'
		foreach i of numlist 1/`errors_replications' {
			foreach j of numlist 1/`NCOVARIATES' {
				matrix m_ba[`i',`j'] = `1'
				macro shift
			}
		}
				
		matrix colnames m_ba = `COVARIATES'
	}
	
	**************************************************************
	* Perform an OLS regression to get the coefficients		     *
	**************************************************************
	preserve
	qui xi: reg `varlist' i.`assignment_var'*i.`TIME', cluster(`ID')
	
	matrix b = e(b)
	
	* estimated group effects
	matrix G = J(`groups',`=Tmax',0)
	
	foreach i of numlist 1/`groups' {
		local rownames = "`rownames' group_`i'" 
	}
	matrix rownames G = `rownames' 
	
	local colnames = ""
	foreach i of numlist 1/`=Tmax' {
		local colnames = "`colnames' T_`i'" 
	}
	matrix colnames G = `colnames' 
	
	* first come assignment effects
	scalar index_b = `NCOVARIATES'+1
	
	foreach i of numlist 2/`groups' {
		foreach j of numlist 1/`=Tmax' {
			matrix G[`i',`j'] = G[`i',`j'] + b[1,`=index_b']
		} 
		scalar index_b = index_b+1
	}
	
	* then time effects
	foreach i of numlist 2/`=Tmax' {
		foreach j of numlist 1/`groups' {
			matrix G[`j',`i'] = G[`j',`i'] + b[1,`=index_b']
		} 
		scalar index_b = index_b+1
	}
	
	* then interaction effects
	foreach i of numlist 2/`groups' {
		foreach j of numlist 2/`=Tmax' {
			matrix G[`i',`j'] = G[`i',`j'] + b[1,`=index_b']
			scalar index_b = index_b+1
		} 
	}
	
	* then the constant term, which affects them all
	foreach i of numlist 1/`groups' {
		foreach j of numlist 1/`=Tmax' {
			matrix G[`i',`j'] = G[`i',`j'] + b[1,`=index_b']
		} 
	}
	
	* estimated coefficients
	if `NCOVARIATES' > 0 {
		matrix b = b[1,1..`NCOVARIATES']
	}	
	restore

	**************************************************************
	* Add estimated group effects to the data					 *
	**************************************************************
	qui {
		local group_effect_var e_group_effect
		capture confirm variable `group_effect_var'		
		while !_rc {
			local group_effect_var `group_effect_var'_
			capture confirm variable `group_effect_var'
		}	
	
		gen `group_effect_var' = .

		foreach i of numlist 1/`groups' {
			local tmp = rowsof(m_time)
			
			foreach j of numlist 1/`tmp' {
				replace `group_effect_var' = G[`i',`j'] if `assignment_var' == `i' & `TIME' == m_time[`j',1]
			} 
		}
	}
		
	**********************************************
	* Display coefficients and standard errors   *
	**********************************************
	di as text "   " as text "{hline 13}{c TT}{hline 50}"
	di as text "   " as text "           y {c |}     Coef.       Std. Err. (Bootstrap)"
	di as text "   " as text "{hline 13}{c +}{hline 50}"
	
	local index = 1
	foreach covariate in `COVARIATES' {
		local tmp = b[1,`index']
			
		if `errors' == 1 { 
			local tmp2 = e[1,`index']
			di as text "   " as text %12s abbrev("`covariate'",12) " {c |} " as result %10.0g `tmp' "         " as result %10.0g `tmp2'
		}
		else {
			di as text "   " as text %12s abbrev("`covariate'",12) " {c |} " as result %10.0g `tmp' "         " as text "      -"
		}
			
		
		local index = `index'+1
	}
	di as text "   " as text "{hline 13}{c BT}{hline 50}"
	
	**********************************************
	* Remove temporary files					 *
	**********************************************
	if !`debug' shell rm "`dir'" /s /q
	
	**********************************************
	* Store regression results in ereturn        *
	**********************************************
	//tempvar `sample'
	gen mysample = 1
	
	if `NCOVARIATES' > 0 {
		ereturn post b, esample(mysample)
	}
	else {
		ereturn post, esample(mysample)
	}
	
	ereturn scalar groups = `groups'
	ereturn scalar NCOVARIATES = `NCOVARIATES'
	ereturn scalar objective = `objective_min'
	
	qui count 
	ereturn scalar N = r(N)
	
	ereturn local ID				"`ID'"
	ereturn local TIME				"`TIME'"
	ereturn local OUTCOME			"`OUTCOME'"
	ereturn local COVARIATES		"`COVARIATES'"
	ereturn local assignment_var	"`assignment_var'"
	ereturn local group_effect_var	"`group_effect_var'"
    ereturn local estat_cmd 		"xtgfe_estat"
    ereturn local cmd       		"xtgfe"
	
	ereturn matrix G = G	
	ereturn matrix mat_objective = mat_objective
	
	* bootstrapped errors
	if `errors' == 1 {
		ereturn matrix errors = e
		ereturn matrix error_assignments = m_ba
	}	
end
