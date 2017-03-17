***************************************************************************
*	Simulation 5: various estimates of gfe dgp with G = 4 				  *
***************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\data\simulation2\"

foreach g of numlist -1 0 2 4 -4 6 {	// where -1 is OLS, 0 is FE and -4 is the infeasible version of the gfe estimator
	foreach errorscale of numlist 0 1 2 4 {	
		di `g'
		di `errorscale'
		
		capture confirm file "E_`g'_`errorscale'.dta"
		if _rc==0 continue

		foreach i of numlist 1/100 {
			* group effects are AR(1)
			qui {
				clear
				set obs 4
				gen group = _n
				expand 7
				bysort group: gen TIME = _n
				gen group_effect = rnormal() 
				foreach t of numlist 2/7 {
					replace group_effect = rnormal(group_effect[_n-1], 1) if TIME==`t'
				}
				tempfile group_effects
				save `group_effects'
			}
		
			* simulate
			gfe_dgp using `group_effects', n(200) t(7) v(3) g(4)
			qui replace y = x1 + x2 + x3 + alpha_g_i + 0.5*epsilon*`errorscale'
			
			* estimate
			if `g' == -1 {
				qui reg y x1 x2 x3
			}
			else if `g' == 0 {
				qui xi: xtreg y x1 x2 x3 i.TIME, fe
			}
			else if `g' == -4 {
				qui xi: reg y x1 x2 x3 i.group*i.TIME
			}
			else {
				local nsim = 15 + 10*`errorscale'
				xtgfe y x1 x2 x3, groups(`g') nsim(`nsim')
			}			
				
			* store result
			if `i' == 1 {
				matrix E = e(b)
				matrix E = E[1,1..3]			
			}
			else {
				matrix ROW = e(b)
				matrix ROW = ROW[1,1..3]
				matrix E = E\ROW
			}
			
			* store percentage wrongly grouped (only g=4)
			if `g' == 4 {
				match_assignments group assignment
				
				if `i' == 1 {
					matrix MISSPEC = r(misspec_per_cent) 			
				}
				else {
					matrix MISSPEC = MISSPEC\r(misspec_per_cent)
				}
			}
		}
		
		* all done, save simulations results to file
		clear
		svmat E, names(col)
		save "E_`g'_`errorscale'", replace
		
		if `g' == 4 {
			clear
			svmat MISSPEC, names(col)
			save "MISSPEC_`g'_`errorscale'", replace
		}
	}
}

* read simulation means and empirical quantiles into data
qui{
	clear
	set obs 24
	gen G = .
	gen E = .
	foreach x in x1 x2 x3 {
		gen `x'_mean = .
		gen `x'_p5 = .
		gen `x'_p95 = .
	}

	local a 1
	foreach g of numlist -1 0 2 4 -4 6  {
		foreach errorscale of numlist 0 1 2 4 {
			qui replace G = `g' if _n == `a'
			qui replace E = `errorscale' if _n == `a'
			
			foreach x in x1 x2 x3 {
				preserve
				use "E_`g'_`errorscale'", clear
				sum `x', detail
				restore
				
				replace `x'_mean = r(mean) if _n == `a'
				replace `x'_p5 = r(p5) if _n == `a'
				replace `x'_p95 = r(p95) if _n == `a'
			}
			
			local a `a'+1
		}
	}
}

* plot
set scheme plotplainblind, permanently

foreach x in x1 x2 x3 {
	preserve
	keep G E `x'_mean `x'_p5 `x'_p95
	rename `x'_mean point
	rename `x'_p5 p5
	rename `x'_p95 p95

	recode G (-4=4.5)
	sort E G
	generate GEindex = _n  if E == 1
	replace GEindex = _n+1  if E == 2
	replace GEindex = _n+2  if E == 4
	
	//(bar point GEindex if G==-1) ///
	twoway	(bar point GEindex if G==0, fcolor(gs10) fintensity(0)) ///
			(bar point GEindex if G==2, fcolor(gs10) fintensity(75) lcolor(none)) ///
			(bar point GEindex if G==4, fcolor(sky) fintensity(75) lcolor(none)) ///  
			(bar point GEindex if G==4.5, fcolor(turquoise) fintensity(75) lcolor(none)) ///
			(bar point GEindex if G==6, fcolor(cranberry) fintensity(75) lcolor(none)) ///
			(rcap p5 p95 GEindex if G!=-1), ///
			legend(row(1) order(1 "FE" 2 "G=2" 3 "G=4" 4 "G=4 (infeasible)" 5 "G=6") position(6)) ///
			xlabel( 7 " " 10 "E=0.5" 17 "E=1" 24 "E=2" 27 " ", noticks) ///
			ytitle("Estimate of  {&beta}") xtitle("") xsize(5) ysize(4) ylabel(0.4(0.1)1.2)
	restore
	
	graph save "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\figures\gfe_4_esimate_`x'.gph", replace
	graph export "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\figures\gfe_4_esimate_`x'.pdf", replace
}

* misclassification
foreach errorscale of numlist 0 1 2 4 {	
	di "----------------------- `errorscale' -----------------------"
	use "MISSPEC_4_`errorscale'", clear
	sum c1
}
