cd "S:\people\Sebastian B\Masterarbeit\VCMPooledStranger"

* all series for the online appendix
foreach g of numlist 2/10 {
	use VCMStrangers, clear

	xtgfe cont, groups(`g') nsim(50) 
	estat geplot
	graph export "figures/TS_Pattern_`g'.pdf", replace
}

* group effects in thesis
use VCMStrangers, clear

xtgfe cont, groups(5) nsim(5) 
estat geplot

graph save "figures/thesis_ts.gph", replace
graph export "figures/thesis_ts.pdf", replace

* individual contibutions in thesis
sort playerID period
graph twoway connected cont period if playerID==-1, legend(off)

preserve
keep if assignment == 5
local i = 1
levelsof playerID, local(subjects) 
foreach subject of local subjects {
	if mod(`i',4) == 0 {
		graph addplot scatter cont period if playerID==`subject', connect(l) lstyle(solid) lcolor(reddish) mcolor(reddish) msymbol(circle)
	}
	
	local i = `i'+1
}
restore
preserve
keep if assignment == 1
local i = 1
levelsof playerID, local(subjects) 
foreach subject of local subjects {
	if mod(`i',25) == 0 {
		graph addplot scatter cont period if playerID==`subject', connect(l) lstyle(solid) lcolor(black) mcolor(black) msymbol(circle)
	}
	
	local i = `i'+1
}
restore

graph addplot scatter cont period if playerID==-1, ///
	xtitle("Period")  ytitle("Contribution") xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) legend(off)

graph save "figures/players_g1_g5.gph", replace
graph export "figures/players_g1_g5.pdf", replace
