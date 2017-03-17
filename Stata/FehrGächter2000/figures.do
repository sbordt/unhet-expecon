clear all
set more off 

cd "S:\people\Sebastian B\Masterarbeit\FehrGächter2000"

set scheme plotplainblind

foreach session of numlist 4/5 {
	foreach group of numlist 1/6 {
		foreach year of numlist 1/2 {
		
			use FehrGächter2000, clear 
			keep if session == `session' & group == `group' & year == `year'
			
			qui sum	
			if r(N) == 0 continue	// not all combinations exist
	
			if punishment[1] == 1 {
				local graphnames ""  
				
				levelsof playerNo, local(subjects) 
				foreach subject of local subjects {
					
					twoway (connected contributions period if playerNo == `subject') || ///
						(scatter pun_sum_given period if playerNo == `subject' & pun_sum_given > 0, msymbol(plus) msize(huge)) ///
						(scatter sum_pun_received period if playerNo == `subject' & sum_pun_received > 0, msymbol(circle_hollow) msize(huge)) || ///
						(connected profit period if playerNo == `subject', lpattern(shortdash) lcolor(red) yaxis(2)) ///
						, xlabel(1(1)10) ylabel(0(5)20) ylabel(-30(15)45, axis(2)) xsize(8) ysize(5) title("Contributions and Welfare of Subject Nr. `subject'") xtitle("")  ytitle("") ytitle("", axis(2)) legend(label(1 "contribution") label(2 "punished") label(3 "was punished") order(2 3) position(6) rows(1)) name("subject_`subject'") 
					
					local graphnames `graphnames' subject_`subject'
				}
				
				graph twoway (connected groupcontributions period if playerNo == playerNo[1]), xlabel(1(1)10) ylabel(0(20)80) xsize(8) ysize(5) title("Total Contributions") xtitle("")  ytitle("") legend(label(1 "contribution") position(6)) name("contributions") 
				graph twoway (connected group_welfare period if playerNo == playerNo[1], lpattern(shortdash) lcolor(red)), xlabel(1(1)10) ylabel(0(32)128) xsize(8) ysize(5) title("Total Welfare") xtitle("") ytitle("") legend(label(1 "welfare") position(6)) name("welfare")
				local graphnames `graphnames' contributions welfare 
				// TODO: MAKE LEGNEDS WORK
				
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.4) title("Session `session' Group `group' (Year `year', P)")
				graph export "figures\session_`session'_group_`group'_year_`year'.pdf", replace
				graph drop _all
			}
			else {
				local graphnames ""  
				
				levelsof playerNo, local(subjects) 
				foreach subject of local subjects {
					
					twoway (connected contributions period if playerNo == `subject') ///
					(connected profit period if playerNo == `subject', lpattern(shortdash) lcolor(red) yaxis(2)) ///
					, xlabel(1(1)10) ylabel(0(5)20) ylabel(-30(15)45, axis(2)) xsize(8) ysize(5) title("Contributions and Welfare of Subject Nr. `subject'") xtitle("")  ytitle("") ytitle("", axis(2)) ytitle("", axis(2)) legend(label(1 "contribution") position(6) rows(1)) name("subject_`subject'") 
					
					local graphnames `graphnames' subject_`subject'
				}
				
				graph twoway (connected groupcontributions period if playerNo == playerNo[1]), xlabel(1(1)10) ylabel(0(20)80) xsize(8) ysize(5) title("Total Contributions") xtitle("")  ytitle("") name("contributions") 
				graph twoway (connected group_welfare period if playerNo == playerNo[1], lpattern(shortdash) lcolor(red)), xlabel(1(1)10) ylabel(0(32)128) xsize(8) ysize(5) title("Total Welfare") xtitle("")  ytitle("") name("welfare")
				local graphnames `graphnames' contributions welfare 
				
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.4) title("Session `session' Group `group' (Year `year', VCM)")
				graph export "figures\session_`session'_group_`group'_year_`year'.pdf", replace
				graph drop _all
			}			
		}
	}
}

* sessions 4-5 p average contributions per group
use FehrGächter2000, clear 

replace group = 100*session+group

keep if punishment & !stranger 
duplicates drop group period, force

replace groupcontributions = groupcontributions / 4

graph twoway connected groupcontributions period if session==100, legend(position(6) rows(1))
foreach group of numlist 401 402 403 404 501 502 503 504 505  {
	graph addplot scatter groupcontributions period if group==`group', connect(1) msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) lwidth(thin)
}
graph addplot scatter groupcontributions period if group==506, connect(1) msymbol(circle) mcolor(black) lcolor(black) lpattern(dash) lwidth(thin) xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 4-5 (P) average contribution per group") xtitle("")  ytitle("")  legend(off) aspect(0.65)
graph export "figures\sessions_4_5_p_group_average.pdf", replace
