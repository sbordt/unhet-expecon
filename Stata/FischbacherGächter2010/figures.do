*******************************************************************************
* Visualize the development of contributions, beliefs and predicted 
* contributions for all players in the Fischbaer & Gächter 2010 data
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

set scheme plotplainblind

foreach session of numlist 1/6 {
	use FG2010_Figures, clear
	
	keep if session == `session'
			
	local graphnames ""	  
				
	levelsof player, local(subjects)
	local i = 1
	local j = 1

	foreach subject of local subjects {
		preserve
		keep if player == `subject'
		local desc = description[1]
		restore
				
		twoway (connected predictedcontribution period if player == `subject', lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period if player == `subject', lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period if player == `subject', lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(8) ysize(5) title("Session `session', Subject Nr. `subject', `desc'") xtitle("")  ytitle("") legend(order(3 "contribution" 2 "belief" 1 "predicted contribution") position(6) rows(1)) name("subject_`subject'") 
						
		local graphnames `graphnames' subject_`subject'
					
		if mod(`i',6) == 0 | (`session' == 3 & `i' == 20){
			if mod(`i',6) == 0 {
				graph combine `graphnames', row(2) col(3) xsize(20) ysize(12) iscale(0.4)
			}
			else {	// session 3 is special in that it has only 20 players
				graph combine `graphnames', row(1) col(2) xsize(13.33) ysize(6) iscale(0.8)
			}
			graph export "figures\session_`session'_slide_`j'.pdf", replace
			
			graph drop _all
			local graphnames ""
			local j = `j'+1
		}
		
		local i = `i'+1
	}
}

* 2 contributions schedules in the thesis
use FG2010, clear
duplicates drop playerID, force

keep playerID b* preftype
drop belief							// data is now what we got in the P-experiment

reshape long b, i(playerID) j(othercont)

twoway (connected b othercont if playerID  == 282, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) (connected b othercont if playerID  == 234, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) 	///
		(connected b othercont if playerID  == 302, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) (connected b othercont if playerID  == 181, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) 	///
	, xlabel(0(1)20) ylabel(0(5)20) xsize(5) ysize(4) xtitle("Contribution of Other Players")  ytitle("Conditional Contribution") legend(off) 

graph export "figures\strategy_tr.pdf", replace	

twoway (connected b othercont if playerID  == 292, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) (connected b othercont if playerID  == 189, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) 	///
		(connected b othercont if playerID  == 251, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) (connected b othercont if playerID  == 217, lcolor(black) mcolor(black) lpattern(solid) msymbol(circle)) 	///
	, xlabel(0(1)20) ylabel(0(5)20) xsize(5) ysize(4) xtitle("Contribution of Other Players")  ytitle("Conditional Contribution") legend(off) 

graph export "figures\strategy_cc.pdf", replace		
	
* 6 players in the thesis
use FG2010, clear
keep if playerID  == 172 	
tab session player			// session 1 player 4
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
			
graph export "figures\player172.pdf", replace

use FG2010, clear
keep if playerID  == 253 	
tab session player			// session 4 player 17
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4)  xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
			
graph export "figures\player253.pdf", replace

use FG2010, clear
keep if playerID  == 274 	
tab session player			// session 5 player 14
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4) xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
			
graph export "figures\player274.pdf", replace

use FG2010, clear
keep if playerID  == 186 	
tab session player			// session 1 player 18
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4)  xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
			
graph export "figures\player186.pdf", replace


use FG2010, clear
keep if playerID  == 292 	
tab session player			// session 6 player 8
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4)  xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
			
graph export "figures\player292.pdf", replace

use FG2010, clear
keep if playerID  == 280 	
tab session player			// session 5 player 20
tab preftype

twoway (connected predictedcontribution period, lcolor(gs12) mcolor(gs12) lpattern(shortdash) msymbol(Sh) msize(4) ) ///
			   (connected belief period, lcolor(eltblue) mcolor(eltblue) lpattern(shortdash) msize(4) msymbol(Dh)) ///
			   (connected cont period, lcolor(black) lpattern(solid) mcolor(black) msize(2) msymbol(circle)) /// 
				, xlabel(1(1)10) ylabel(0(5)20) xsize(5) ysize(4)  xtitle("Period")  ytitle("Contribution") legend(order(3 "Contribution" 2 "Belief" 1 "Predicted contribution") position(6) rows(1))  
				
graph export "figures\player280.pdf", replace			


