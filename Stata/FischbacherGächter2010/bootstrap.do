cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010\csv\GFE\bootstrap"

// ALL
import delimited using "belief_G1_ALL.txt", clear
hist v1, start(-0.5) width(0.1) fintensity(25) color(gs10) lwidth(0.3)

import delimited using "belief_G2_ALL.txt", clear
graph addplot hist v1, start(-0.5) width(0.1) fcolor(none) lwidth(0.3) ///
			xsize(5) ysize(4) xlabel(-0.5(0.25)1.5) xtitle("Bootstrapped Estimates of Belief")

graph export "bootstrap_1.pdf", replace


import delimited using "predcont_G1_ALL.txt", clear
hist v1, start(-1) width(0.15) fintensity(25) color(gs10) lwidth(0.3)

import delimited using "predcont_G2_ALL.txt", clear
graph addplot hist v1, start(-1) width(0.15) fcolor(none) lwidth(0.3) /// 
			xsize(5) ysize(4) xlabel(-1.2(1.0)2.2) xtitle("Bootstrapped Estimates of Predicted Contribution")

graph export "bootstrap_2.pdf", replace

// NC
import delimited using "belief_G1_NC.txt", clear
hist v1, start(-0.5) width(0.1) fintensity(25) color(gs10) lwidth(0.3)

import delimited using "belief_G2_NC.txt", clear
graph addplot hist v1, start(-0.5) width(0.1) fcolor(none) lwidth(0.3) ///
			xsize(5) ysize(4) xlabel(-0.5(0.25)1.5) xtitle("Bootstrapped Estimates of Belief")

graph export "bootstrap_1_NC.pdf", replace


import delimited using "predcont_G1_NC.txt", clear
hist v1, start(-1) width(0.15) fintensity(25) color(gs10) lwidth(0.3)

import delimited using "predcont_G2_NC.txt", clear
graph addplot hist v1, start(-1) width(0.15) fcolor(none) lwidth(0.3) /// 
			xsize(5) ysize(4) xlabel(-1.2(1.0)2.2) xtitle("Bootstrapped Estimates of Predicted Contribution")

graph export "bootstrap_2_NC.pdf", replace

// NCCC
import delimited using "belief_G2_CCNC.txt", clear
hist v1, start(-0.5) width(0.1) fcolor(white) lwidth(0.25) legend(on position(1) ring(0))

import delimited using "belief_G1_CCNC.txt", clear
graph addplot hist v1, start(-0.5) width(0.1) fintensity(75) color(sky) fcolor(sky) lcolor(sky)

import delimited using "belief_G2_CCNC.txt", clear
graph addplot hist v1, start(-0.5) width(0.1) fcolor(none) lwidth(0.25) ///
			xsize(5) ysize(4) xlabel(-0.5(0.5)2) ylabel(0(0.5)3.5) ///
			xtitle("Bootstrapped Estimate of Belief") ytitle("Relative Frequency") ///
			legend(order(1 "Group 1" 2 "Group 2"))

graph save "bootstrap_belief_CCNC.gph", replace
graph export "bootstrap_belief_CCNC.pdf", replace

import delimited using "predcont_G2_CCNC.txt", clear
hist v1, start(-1.5) width(0.15) fcolor(white) lwidth(0.25) legend(on position(1) ring(0)) 

import delimited using "predcont_G1_CCNC.txt", clear
graph addplot  hist v1, start(-1.5) width(0.15) fintensity(75) color(sky) lwidth(0.25) 

import delimited using "predcont_G2_CCNC.txt", clear
graph addplot hist v1, start(-1.5) width(0.15) fcolor(none) lwidth(0.25) /// 
			xsize(5) ysize(4) xlabel(-1.5(0.5)1.5) ylabel(0(0.5)3.5) ///
			xtitle("Bootstrapped Estimate of Predicted Contribution") ytitle("Relative Frequency") ///
			legend(order(1 "Group 1" 2 "Group 2"))

graph save "bootstrap_predcont_CCNC.gph", replace
graph export "bootstrap_predcont_CCNC.pdf", replace

// FMM doesn't fit the data well
//fmm v1, components(2) mixtureof(normal)
//graph twoway (hist v1, bin(30)) ///
//			(function y=normalden(x,.1693504,.188327), range(-0.5 1.5) lw(medthick)) ///
//			(function y=normalden(x,.9573362,.1197841), range(-0.5 1.5) lw(medthick))
