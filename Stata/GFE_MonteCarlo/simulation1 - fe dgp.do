***************************************************************************
*	Simulation 4: Estimates of fe dgp 									  *
***************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\data\simulation1\"

foreach g of numlist -1 0 2 4 10 {		// where -1 is OLS, 0 is FE
	foreach errorscale of numlist 0 1 2 4 {
		di `g'
		di `errorscale'

		capture confirm file "E_`g'_`errorscale'.dta"
		if _rc==0 continue		
		
		foreach i of numlist 1/100 {
			* simulate
			FE_dgp, n(200) t(5) v(3)
			replace y = x1 + x2 + x3 + c_i + delta_t + 0.5*epsilon*`errorscale'
			
			* estimate
			if `g' == -1 {
				qui reg y x1 x2 x3
			}
			else if `g' == 0 {
				qui xi: xtreg y x1 x2 x3 i.TIME, fe
			}			
			else {
				local nsim = 15 + 5*`errorscale'
				qui xtgfe y x1 x2 x3, groups(`g') nsim(`nsim')
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
		}
		
		clear
		svmat E, names(col)
		save "E_`g'_`errorscale'", replace
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
	foreach g of numlist -1 0 2 4 10 {
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

* bar plots
set scheme plotplainblind, permanently

foreach x in x1 x2 x3 {
	preserve
	keep G E `x'_mean `x'_p5 `x'_p95
	rename `x'_mean point
	rename `x'_p5 p5
	rename `x'_p95 p95

	sort E G
	//generate GEindex = _n  if E == 0
	generate GEindex = _n  if E == 1
	replace GEindex = _n+1  if E == 2
	replace GEindex = _n+2  if E == 4

	twoway	(bar point GEindex if G==-1, fcolor(gs10) fintensity(0)) ///
			(bar point GEindex if G==0, fcolor(gs10) fintensity(75) lcolor(none)) ///
			(bar point GEindex if G==2, fcolor(sky) fintensity(75) lcolor(none)) ///
			(bar point GEindex if G==4, fcolor(turquoise) fintensity(75) lcolor(none)) ///
			(bar point GEindex if G==10, fcolor(cranberry) fintensity(75) lcolor(none)) ///
			(rcap p5 p95 GEindex), ///
			legend(row(1) order(1 "OLS" 2 "FE" 3 "G=2" 4 "G=4" 5 "G=10") position(6)) ///
			xlabel( 5 " " 8 "E=0.5" 14 "E=1" 20 "E=2" 23 " ", noticks) ///
			xtitle("") ytitle("Estimate of  {&beta}") xsize(5) ysize(4) ylabel(0.4(0.1)1.2)
	restore
	
	graph save "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\figures\gfe_on_fe_esimate_`x'.gph", replace
	graph export "S:\people\Sebastian B\Masterarbeit\GFE_MonteCarlo\figures\gfe_on_fe_esimate_`x'.pdf", replace
}
	   

********************************************************************************
* Relation between groups and fixed effects for E=0
********************************************************************************

* simulate
set seed 26
FE_dgp, n(200) t(5) v(3)
replace y = x1 + x2 + x3 + c_i + delta_t

* estimate
xtgfe y x1 x2 x3, groups(10)

twoway (histogram c_i if assignment == 1, color(green) frequency start(-3) width(0.1)) ///
	   (histogram c_i if assignment == 2, fcolor(none) lcolor(black) frequency start(-3) width(0.1))  ///
	   (histogram c_i if assignment == 3, fcolor(none) lcolor(blue) frequency start(-3) width(0.1))   ///
	   (histogram c_i if assignment == 4, fcolor(none) lcolor(yellow) frequency start(-3) width(0.1)) ///
	   (histogram c_i if assignment == 5, fcolor(none) lcolor(pink) frequency start(-3) width(0.1))   ///
	   (histogram c_i if assignment == 6, fcolor(none) lcolor(khaki) frequency start(-3) width(0.1))   ///
	   (histogram c_i if assignment == 7, fcolor(none) lcolor(maroon) frequency start(-3) width(0.1))   ///
	   (histogram c_i if assignment == 8, fcolor(none) lcolor(orange) frequency start(-3) width(0.1))   ///
	   (histogram c_i if assignment == 9, fcolor(none) lcolor(gold) frequency start(-3) width(0.1))  ///
	   (histogram c_i if assignment == 10, fcolor(none) lcolor(midblue) frequency start(-3) width(0.1))   

