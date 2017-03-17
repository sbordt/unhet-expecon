clear all

cd "S:\people\Sebastian B\Masterarbeit\Nikiforakis2008"

set scheme plotplainblind

foreach session of numlist 1/8 {
	foreach group of numlist 1/3 {
		foreach year of numlist 1/2 {
		
			use NN_CPun_Data, clear 
			keep if session == `session' & group == `group' & year == `year'
			
			if pcp[1] == 1 {
				local graphnames ""  
				
				levelsof subject, local(subjects) 
				foreach subject of local subjects {
					
					twoway (connected mycont period if subject == `subject')  ///
						(scatter p_total period if subject == `subject' & p_total > 0, msymbol(plus) msize(huge)) ///
						(scatter rec_p_total period if subject == `subject' & rec_p_total > 0, msymbol(circle_hollow) msize(huge)) ///
						(scatter cp_total period if subject == `subject' & cp_total > 0, msymbol(X) msize(huge)) /// 
						(scatter rec_cp_total period if subject == `subject' & rec_cp_total > 0, msymbol(circle_hollow) msize(huge)) ///
						(connected profit period if subject == `subject', lpattern(shortdash) lcolor(red) yaxis(2)) ///
						, xlabel(1(1)10) ylabel(0(5)20) ylabel(-30(15)45, axis(2)) xsize(8) ysize(5) title("Contributions and Welfare of Subject Nr. `subject'") xtitle("")  ytitle("") ytitle("", axis(2)) legend(label(1 "contribution") label(2 "punished") label(3 "was punished") label(4 "counter-punished") label(5 "was counter-punished") label(6 "profit") order(2 3 4 5) position(6) rows(1)) name("subject_`subject'") 
					
					local graphnames `graphnames' subject_`subject'
				}
				
				graph twoway (connected totcont period if player == 1), legend(all) xlabel(1(1)10) ylabel(0(20)80) xsize(8) ysize(5) title("Total Contributions") xtitle("")  ytitle("") name("contributions") 
				graph twoway (connected welfare period if player == 1, lpattern(shortdash) lcolor(red)), legend(label(1 "welfare") order(1) rows(1) position(6))  xlabel(1(1)10) ylabel(0(32)128) xsize(8) ysize(5) title("Total Welfare") xtitle("")  ytitle("") name("welfare")
				local graphnames `graphnames' contributions welfare 
				// TODO: MAKE LEGNEDS WORK
				
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.38) title("Session `session' Group `group' (Year `year', PCP)")
				graph export "figures\session_`session'_group_`group'_year_`year'.pdf", replace
				graph drop _all
			}
			
			if p[1] == 1 {
				local graphnames ""  
				
				levelsof subject, local(subjects) 
				foreach subject of local subjects {
					
					twoway (connected mycont period if subject == `subject') || ///
						(scatter p_total period if subject == `subject' & p_total > 0, msymbol(plus) msize(huge)) ///
						(scatter rec_p_total period if subject == `subject' & rec_p_total > 0, msymbol(circle_hollow) msize(huge)) || ///
						(connected profit period if subject == `subject', lpattern(shortdash) lcolor(red) yaxis(2)) ///
						, xlabel(1(1)10) ylabel(0(5)20) ylabel(-30(15)45, axis(2)) xsize(8) ysize(5) title("Contributions and Welfare of Subject Nr. `subject'") xtitle("")  ytitle("") ytitle("", axis(2)) legend(label(1 "contribution") label(2 "punished") label(3 "was punished") order(2 3) position(6) rows(1)) name("subject_`subject'") 
					
					local graphnames `graphnames' subject_`subject'
				}
				
				graph twoway (connected totcont period if player == 1), legend(all) xlabel(1(1)10) ylabel(0(20)80) xsize(8) ysize(5) title("Total Contributions") xtitle("")  ytitle("") name("contributions") 
				graph twoway (connected welfare period if player == 1, lpattern(shortdash) lcolor(red)), legend(label(1 "welfare") order(1) rows(1) position(6))  xlabel(1(1)10) ylabel(0(32)128) xsize(8) ysize(5) title("Total Welfare") xtitle("")  ytitle("") name("welfare")
				local graphnames `graphnames' contributions welfare 
				
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.4) title("Session `session' Group `group' (Year `year', P)")
				graph export "figures\session_`session'_group_`group'_year_`year'.pdf", replace
				graph drop _all
			}
			
			if vcm[1] == 1 {
				local graphnames ""  
				
				levelsof subject, local(subjects) 
				foreach subject of local subjects {
					
					twoway (connected mycont period if subject == `subject') ///
					(connected profit period if subject == `subject', lpattern(shortdash) lcolor(red) yaxis(2)) ///
					, xlabel(1(1)10) ylabel(0(5)20) ylabel(-30(15)45, axis(2)) xsize(8) ysize(5) title("Contributions and Welfare of Subject Nr. `subject'") xtitle("")  ytitle("") ytitle("", axis(2)) ytitle("", axis(2)) legend(label(1 "contribution") position(6) rows(1)) name("subject_`subject'") 
					
					local graphnames `graphnames' subject_`subject'
				}
				
				graph twoway (connected totcont period if player == 1), legend(all) xlabel(1(1)10) ylabel(0(20)80) xsize(8) ysize(5) title("Total Contributions") xtitle("")  ytitle("") name("contributions") 
				graph twoway (connected welfare period if player == 1, lpattern(shortdash) lcolor(red)), legend(label(1 "welfare") order(1) rows(1) position(6))  xlabel(1(1)10) ylabel(0(32)128) xsize(8) ysize(5) title("Total Welfare") xtitle("")  ytitle("") name("welfare")
				local graphnames `graphnames' contributions welfare 
				
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.4) title("Session `session' Group `group' (Year `year', VCM)")
				graph export "figures\session_`session'_group_`group'_year_`year'.pdf", replace
				graph drop _all
			}
		}
	}
}

* sessions 1-4 vcm average contributions per group
use NN_CPun_Data, clear 
keep if fixed & vcm & player == 1

replace totcont = totcont / 4

graph twoway connected totcont period if session==100, legend(position(6) rows(1))

graph addplot scatter totcont period if session==1 & group==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue)
graph addplot scatter totcont period if session==1 & group==2, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue)
graph addplot scatter totcont period if session==1 & group==3, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue)

graph addplot scatter totcont period if session==2 & group==1, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry)
graph addplot scatter totcont period if session==2 & group==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry)
graph addplot scatter totcont period if session==2 & group==3, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry)

graph addplot scatter totcont period if session==3 & group==1, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen)
graph addplot scatter totcont period if session==3 & group==2, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen)
graph addplot scatter totcont period if session==3 & group==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen)

graph addplot scatter totcont period if session==4 & group==1, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan)
graph addplot scatter totcont period if session==4 & group==2, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan)
graph addplot (scatter totcont period if session==4 & group==3, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 1-4 (VCM) average contribution per group") xtitle("")  ytitle("") legend(order(2 "Session 1" 5 "Session 2" 8 "Session 3" 11 "Session 4")) aspect(0.65)
graph export "figures\sessions_1_4_vcm_group_average.pdf", replace

* sessions 1-4 vcm average contributions per session
use NN_CPun_Data, clear 
keep if fixed & vcm & player == 1

bys session period: egen session_group_mean  = sum(totcont) 
replace session_group_mean = session_group_mean / 12
keep if group == 1

graph twoway connected session_group_mean period if session==100, legend(position(6) rows(1))
graph addplot scatter session_group_mean period if session==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot (scatter session_group_mean period if session==4, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan)  lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 1-4 (VCM) average contribution per session") xtitle("")  ytitle("")  legend(order(2 "Session 1" 3 "Session 2" 4 "Session 3" 5 "Session 4")) aspect(0.65)
graph export "figures\sessions_1_4_vcm_session_average.pdf", replace

* sessions 1-4 pcp average contributions per group, colored by session
use NN_CPun_Data, clear 
keep if fixed & pcp & player == 1

replace totcont = totcont / 4

graph twoway connected totcont period if session==100, legend(position(6) rows(1))

graph addplot scatter totcont period if session==1 & group==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==1 & group==2, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==1 & group==3, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==2 & group==1, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==2 & group==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==2 & group==3, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==3 & group==1, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==3 & group==2, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==3 & group==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==4 & group==1, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==4 & group==2, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot (scatter totcont period if session==4 & group==3, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 1-4 (PCP) average contribution per group") xtitle("")  ytitle("")  legend(order(2 "Session 1" 5 "Session 2" 8 "Session 3" 11 "Session 4")) aspect(0.65)
graph export "figures\sessions_1_4_pcp_group_average.pdf", replace

* sessions 1-4 pcp average contributions per group, colored by number of punishment periods
use NN_CPun_Data, clear 
keep if fixed & pcp & player == 1

replace totcont = totcont / 4

bys session group: gen r = round(255*group_p_periods/10)
bys session group: gen g = round(255*(10-group_p_periods)/10)

graph twoway connected totcont period if session==100, legend(position(6) rows(1))

foreach session of numlist 1/4 {
	foreach group of numlist 1/3 {
		preserve
		keep if session==`session' & group==`group'
		local r = r[1] 
		local g = g[1]
		restore

		if `session'==4 & `group'==3 {
			graph addplot (scatter totcont period if session==`session' & group==`group', connect(1) msymbol(circle) mcolor("`r' `g' 0") lcolor("`r' `g' 0") lpattern(dash) lwidth(thin)),  ///
				xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 1-4 (PCP) average contribution per group") subtitle("green (no punishment group) - red (heavy punishment group)") xtitle("")  ytitle("") legend(off) aspect(0.65)
		}
		else {
			graph addplot scatter totcont period if session==`session' & group==`group', connect(1) msymbol(circle) mcolor("`r' `g' 0") lcolor("`r' `g' 0") lpattern(dash) lwidth(thin) aspect(0.65)
		}
	}
}
graph export "figures\sessions_1_4_pcp_group_average_color_punishment.pdf", replace


* sessions 1-4 pcp average contributions per session
use NN_CPun_Data, clear 
keep if fixed & pcp & player == 1

bys session period: egen session_group_mean  = sum(totcont) 
replace session_group_mean = session_group_mean / 12
keep if group == 1

graph twoway connected session_group_mean period if session==100, legend(position(6) rows(1))
graph addplot scatter session_group_mean period if session==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot (scatter session_group_mean period if session==4, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 1-4 (PCP) average contribution per session") xtitle("")  ytitle("")  legend(order(2 "Session 1" 3 "Session 2" 4 "Session 3" 5 "Session 4")) aspect(0.65)
graph export "figures\sessions_1_4_pcp_session_average.pdf", replace

	
* sessions 5-8 vcm average contributions per group
use NN_CPun_Data, clear 
keep if fixed & vcm & player == 1

replace totcont = totcont / 4

graph twoway connected totcont period if session==100, legend(position(6) rows(1))

graph addplot scatter totcont period if session==5 & group==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==5 & group==2, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==5 & group==3, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==6 & group==1, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==6 & group==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==6 & group==3, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==7 & group==1, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==7 & group==2, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==7 & group==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==8 & group==1, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==8 & group==2, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot (scatter totcont period if session==8 & group==3, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 5-8 (VCM) average contribution per group") xtitle("")  ytitle("")  legend(order(2 "Session 5" 5 "Session 6" 8 "Session 7" 11 "Session 8")) aspect(0.65)
graph export "figures\sessions_5_8_vcm_group_average.pdf", replace	

* sessions 5-8 vcm average contributions by session
use NN_CPun_Data, clear 
keep if fixed & vcm & player == 1

bys session period: egen session_group_mean  = sum(totcont) 
replace session_group_mean = session_group_mean / 12
keep if group == 1

graph twoway connected session_group_mean period if session==100, legend(position(6) rows(1))
graph addplot scatter session_group_mean period if session==5, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==6, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==7, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot (scatter session_group_mean period if session==8, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 5-8 (VCM) average contribution per session") xtitle("")  ytitle("")  legend(order(2 "Session 5" 3 "Session 6" 4 "Session 7" 5 "Session 8")) aspect(0.65)
graph export "figures\sessions_5_8_vcm_session_average.pdf", replace

* sessions 5-8 vcm average contribution by individual
use NN_CPun_Data, clear 
keep if fixed & vcm & session > 4

replace player = 100*session + 10*group + player 

xtset player period
xtline mycont
	
* sessions 5-8 p average contributions per group
use NN_CPun_Data, clear 
keep if fixed & p & player == 1

replace totcont = totcont / 4

graph twoway connected totcont period if session==100, legend(position(6) rows(1))

graph addplot scatter totcont period if session==5 & group==1, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==5 & group==2, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==5 & group==3, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==6 & group==1, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==6 & group==2, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==6 & group==3, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==7 & group==1, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==7 & group==2, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==7 & group==3, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)

graph addplot scatter totcont period if session==8 & group==1, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot scatter totcont period if session==8 & group==2, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)
graph addplot (scatter totcont period if session==8 & group==3, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 5-8 (P) average contribution per group") xtitle("")  ytitle("")  legend(order(2 "Session 5" 5 "Session 6" 8 "Session 7" 11 "Session 8")) aspect(0.65)
graph export "figures\sessions_5_8_p_group_average.pdf", replace

* sessions 5-8 p average contributions by session
use NN_CPun_Data, clear 
keep if fixed & p & player == 1

bys session period: egen session_group_mean  = sum(totcont) 
replace session_group_mean = session_group_mean / 12
keep if group == 1

graph twoway connected session_group_mean period if session==100, legend(position(6) rows(1))
graph addplot scatter session_group_mean period if session==5, connect(1) msymbol(circle) mcolor(midblue) lcolor(midblue) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==6, connect(1) msymbol(circle) mcolor(cranberry) lcolor(cranberry) lpattern(dash) lwidth(thin)
graph addplot scatter session_group_mean period if session==7, connect(1) msymbol(circle) mcolor(midgreen) lcolor(midgreen) lpattern(dash) lwidth(thin)
graph addplot (scatter session_group_mean period if session==8, connect(1) msymbol(circle) mcolor(cyan) lcolor(cyan) lpattern(dash) lwidth(thin)), ///
	xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Sessions 5-8 (P) average contribution per session") xtitle("")  ytitle("")  legend(order(2 "Session 5" 3 "Session 6" 4 "Session 7" 5 "Session 8")) aspect(0.65)
graph export "figures\sessions_5_8_p_session_average.pdf", replace


********************************************************************************
* Figures in the thesis
********************************************************************************

* p figure
use NN_CPun_Data, clear 
keep if fixed & p

replace group = 100*session + group
duplicates drop group period, force

replace totcont = totcont / 4

// xtset group period
// xtgfe totcont, groups(3)
// estat geplot

sort group period
graph twoway connected totcont period if group==0, legend(position(6) rows(1))

graph addplot scatter totcont period if group==503, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==601, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==602, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==701, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==702, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==801, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==802, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)

graph addplot scatter totcont period if group==501, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)
graph addplot scatter totcont period if group==502, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)
graph addplot scatter totcont period if group==603, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)
graph addplot scatter totcont period if group==803, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)

graph addplot scatter totcont period if group==703, connect(l) lstyle(solid) lcolor(sky) mcolor(sky) msymbol(circle) ///
	xtitle("Period")  ytitle("Avg. Contribution per Group") xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) legend(off)
	
graph export "figures\thesis_p.pdf", replace

* pcp figure
use NN_CPun_Data, clear 
keep if fixed & pcp

replace group = 100*session + group
duplicates drop group period, force

replace totcont = totcont / 4

// xtset group period
// xtgfe totcont, groups(4)
// estat geplot

sort group period
graph twoway connected totcont period if group==0, legend(position(6) rows(1))

graph addplot scatter totcont period if group==103, connect(l) lstyle(solid) lcolor(sky) mcolor(sky) msymbol(circle)
graph addplot scatter totcont period if group==203, connect(l) lstyle(solid) lcolor(sky) mcolor(sky) msymbol(circle)
graph addplot scatter totcont period if group==301, connect(l) lstyle(solid) lcolor(sky) mcolor(sky) msymbol(circle)
graph addplot scatter totcont period if group==302, connect(l) lstyle(solid) lcolor(sky) mcolor(sky) msymbol(circle)

graph addplot scatter totcont period if group==102, connect(l) lstyle(solid) lcolor(turquoise) mcolor(turquoise) msymbol(circle)
graph addplot scatter totcont period if group==201, connect(l) lstyle(solid) lcolor(turquoise) mcolor(turquoise) msymbol(circle)
graph addplot scatter totcont period if group==401, connect(l) lstyle(solid) lcolor(turquoise) mcolor(turquoise) msymbol(circle)

graph addplot scatter totcont period if group==101, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)
graph addplot scatter totcont period if group==303, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)
graph addplot scatter totcont period if group==402, connect(l) lstyle(solid) lcolor(gs10) mcolor(gs10) msymbol(circle)

graph addplot scatter totcont period if group==202, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
graph addplot scatter totcont period if group==403, connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle) ///
	xtitle("Period")  ytitle("Avg. Contribution per Group") xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) legend(off)
	
graph export "figures\thesis_pcp.pdf", replace

* histogram with total periods of punishment per group in PCP and P
* PCP
use NN_CPun_Data, clear 
keep if fixed & pcp

replace group = 100*session + group
keep if period == 10 & player == 1
drop period

keep group group_p_periods

hist group_p_periods, discrete xlabel(0(1)10) ylabel(0(0.05)0.35) xsize(5) ysize(4) legend(off) xtitle("Total Number of Periods with Punishment per Group")  ytitle("Relative Frequency") 
graph export "figures\thesis_pcp_hist.pdf", replace

* P
use NN_CPun_Data, clear 
keep if fixed & p

replace group = 100*session + group
keep if period == 10 & player == 1
drop period

keep group group_p_periods

hist group_p_periods, discrete xlabel(0(1)10) ylabel(0(0.05)0.35) xsize(5) ysize(4) legend(off) xtitle("Total Number of Periods with Punishment per Group")  ytitle("Relative Frequency")  
graph export "figures\thesis_p_hist.pdf", replace


