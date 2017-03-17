cd "S:\people\Sebastian B\Masterarbeit\VCMPool"
use VCMPool, clear

* groups
replace groupcont = groupcont / 4
replace group = 100*session + group
replace group = group + 1000 if experiment == "Fehr & Gächter 2000"

duplicates drop group period, force
sort group period
xtset group period
graph twoway connected groupcont period if group==-1, legend(off)
preserve
keep if experiment == "Fehr & Gächter 2000"
local groups 1402 1403 1501 1503 
foreach group of local groups {
	graph addplot scatter groupcont period if group==`group', connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
}
restore
graph addplot scatter groupcont period if group==-1, ///
	xtitle("Period")  ytitle("Group Avg. Contribution") xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) legend(off)

graph save "figures/vcm_group_avg.gph", replace
graph export "figures/vcm_group_avg.pdf", replace

* sessions
replace session = session + 1000 if experiment == "Fehr & Gächter 2000"

bys session period: egen sescont = total(groupcont)
tab session group
bys session period: replace sescont = sescont/_N

duplicates drop session period, force
sort session period
xtset session period

graph twoway connected sescont period if session==-1, legend(off)
preserve
keep if experiment == "Nikiforakis 2008"
foreach session of numlist 5 6 7 8 {
	graph addplot scatter sescont period if session==`session', connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
}
restore
graph addplot scatter sescont period if session==-1, ///
	xtitle("Period")  ytitle("Session Avg. Contribution") xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) legend(off)

graph save "figures/vcm_session_avg.gph", replace	
graph export "figures/vcm_session_avg.pdf", replace
