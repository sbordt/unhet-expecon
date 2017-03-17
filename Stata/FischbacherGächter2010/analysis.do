cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

use "S:\people\Sebastian B\Masterarbeit\VCMPooledStranger\VCMStrangers", clear
keep if experiment == "Fischbaer & Gächter 2010"
save FG2010, replace

*******************************************************************************
* Add varable "indistinguishable"
*******************************************************************************
use FG2010, clear
//gen indistinguishable = 0

levelsof playerID, local(subjects)
foreach subject of local subjects {
	reg predictedcontribution belief if playerID == `subject', noconst
	matrix b = e(b)
	
	if abs(b[1,1]-1)<0.1 {
		qui replace indistinguishable = 1 if playerID == `subject' 
		di `subject'
	}
}
count if indistinguishable == 1

save FG2010, replace

*******************************************************************************
* Define "confused" individuals
*******************************************************************************
gen confused = preftype == 4 | playerID == 186 | playerID == 249 | playerID == 263 | playerID == 276
save FG2010, replace

*******************************************************************************
* Systematically anaylze the relation between contributions, beliefs and 
* predicted contributions.
*******************************************************************************
use FG2010, clear

// THE ENTIRE DATA
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_All.csv", comma replace

// ALL DISTINGUISHABLE PLAYERS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_Distinguishable.csv" if indistinguishable == 0, comma replace

// THE ENTIRE DATA WITHOUT "CONFUSED" INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_NotConfused.csv" if confused == 0, comma replace

// ALL DISTINGUISHABLE PLAYERS WITHOUT "CONFUSED" INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_Distinguishable_NotConfused.csv" if indistinguishable == 0 & confused == 0, comma replace

// CONDIIONAL COOPERATORS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_CC.csv" if preftype == 1, comma replace

// CONDIIONAL COOPERATORS WITHOUT "INDISTINGUISHABLE" INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_CC_Distinguishable.csv" if preftype == 1 & indistinguishable == 0, comma replace

// CONDIIONAL COOPERATORS WITHOUT CONFUSED INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_CC_NotConfused.csv" if preftype == 1 & confused == 0, comma replace

// CONDIIONAL COOPERATORS WITHOUT "INDISTINGUISHABLE" AND CONFUSED INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_CC_Distinguishable_NotConfused.csv" if preftype == 1 & indistinguishable == 0 & confused == 0, comma replace

// FREE RIDERS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_FR.csv" if preftype == 2, comma replace

// TRIANGLE CONTRIBUTORS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_TR.csv" if preftype == 3, comma replace

// "CONFUSED" INDIVIDUALS
outsheet playerID period cont belief predictedcontribution using "csv/FG2010_Confused.csv" if confused == 1, comma replace

********************************************************************************
* PLS csv -> STATA datasets
********************************************************************************
foreach f in "FG2010_All" "FG2010_NotConfused"  "FG2010_Distinguishable" "FG2010_CC_Distinguishable_NotConfused" ///
			 "FG2010_CC" "FG2010_CC_Distinguishable" "FG2010_CC_NotConfused" "FG2010_Distinguishable_NotConfused" "FG2010_FR" ///
			 "FG2010_TR" "FG2010_Confused" {
	preserve
	insheet using "csv/PLS/`f'_PLS.csv", clear
	rename v1 playerID
	rename v2 PLS_group
	save "csv/PLS/`f'_PLS", replace
	restore
	
	preserve
	insheet using "csv/PLS/`f'_PLS_BeliefOnly.csv", clear
	rename v1 playerID
	rename v2 PLS_group
	save "csv/PLS/`f'_PLS_BeliefOnly", replace
	restore
	
	preserve
	insheet using "csv/PLS/`f'_PLS_PredContOnly.csv", clear
	rename v1 playerID
	rename v2 PLS_group
	save "csv/PLS/`f'_PLS_PredContOnly", replace
	restore
}

********************************************************************************
* GFE csv -> STATA datasets
********************************************************************************
foreach f in "FG2010_All" "FG2010_NotConfused"  "FG2010_Distinguishable" "FG2010_CC_Distinguishable_NotConfused" ///
			 "FG2010_CC" "FG2010_CC_Distinguishable" "FG2010_CC_NotConfused" "FG2010_Distinguishable_NotConfused" "FG2010_FR" ///
			 "FG2010_TR" "FG2010_Confused" {
	preserve
	insheet using "csv/GFE/`f'_GFE_2.csv", clear
	rename v1 playerID
	rename v2 GFE_group
	save "csv/GFE/`f'_GFE_2", replace
	restore
	
	preserve
	insheet using "csv/GFE/`f'_GFE_3.csv", clear
	rename v1 playerID
	rename v2 GFE_group
	save "csv/GFE/`f'_GFE_3", replace
	restore
}

********************************************************************************
* Compare PLS with GFE assignments - THEY ALIGN, BUT GFE IS MORE STRICT
********************************************************************************
use FG2010, clear

merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
drop _merge
rename PLS_group PLS_All
merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"
drop _merge
rename GFE_group GFE_All
tab PLS_All GFE_All				// GFE group 1 is a subset of PLS group 1, except for one individual

preserve	// PLS on those who are not confused aligns with PLS on the whole dataset
merge n:1 playerID using "csv/PLS/FG2010_NotConfused_PLS"
drop _merge
rename PLS_group PLS_NotConfused
recode PLS_NotConfused (.=-1)

tab PLS_All PLS_NotConfused
restore

preserve	// for PLS on free riders and PLS on the whole dataset, there is a reduction towards the GFE assignment
merge n:1 playerID using "csv/PLS/FG2010_FR_PLS_BeliefOnly"
drop _merge
rename PLS_group PLS_FR

tab PLS_All PLS_FR
tab playerID if PLS_All == 1 & PLS_FR == 1
restore

preserve	
merge n:1 playerID using "csv/GFE/FG2010_NotConfused_GFE_2"
drop _merge
recode GFE_group (.=-1)

tab GFE_All GFE_group
restore

preserve	
merge n:1 playerID using "csv/PLS/FG2010_NotConfused_PLS"
drop _merge
rename PLS_group PLS_NotConfused

merge n:1 playerID using "csv/GFE/FG2010_NotConfused_GFE_2"
drop _merge
rename GFE_group GFE_NotConfused

tab PLS_NotConfused GFE_NotConfused
restore

// PLAYERS 186, 249, 263 and 276 are confused, with them we would have to need a look at GFE 3
preserve	
merge n:1 playerID using "csv/GFE/FG2010_Distinguishable_NotConfused_GFE_2"
drop _merge
recode GFE_group (.=-1)

tab GFE_All GFE_group
restore

// compare CC not confused - pretty well aligned
preserve	
merge n:1 playerID using "csv/PLS/FG2010_CC_NotConfused_PLS"
drop _merge
rename PLS_group PLS_NotConfused

merge n:1 playerID using "csv/GFE/FG2010_CC_NotConfused_GFE_2"
drop _merge
rename GFE_group GFE_NotConfused

tab PLS_NotConfused GFE_NotConfused
restore

********************************************************************************
* Indistingushable players
********************************************************************************
use FG2010, clear

merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
drop _merge
qui merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"

keep if indistinguishable

tab PLS_group 
tab GFE_group

reg cont belief
reg cont predictedcontribution

********************************************************************************
* The assignments of players depicted in the thesis
********************************************************************************
foreach pid of numlist 172 253 274 186 292 280 {
	qui  {
		use FG2010, clear
		merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
		drop _merge
		qui merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"
	}
	
	di "----- PlayerID `pid' -----"
	tab PLS_group GFE_group if playerID == `pid'
}

foreach pid of numlist 274 292 280 {
	qui  {
		use FG2010, clear
		merge n:1 playerID using "csv/PLS/FG2010_CC_NotConfused_PLS"
		drop _merge
		qui merge n:1 playerID using "csv/GFE/FG2010_CC_NotConfused_GFE_2"
	}
	
	di "----- PlayerID `pid' -----"
	tab PLS_group GFE_group if playerID == `pid'
}

foreach pid of numlist 172 253 {
	qui  {
		use FG2010, clear
		merge n:1 playerID using "csv/PLS/FG2010_FR_PLS"
		drop _merge
		qui merge n:1 playerID using "csv/GFE/FG2010_FR_GFE_2"
	}
	
	di "----- PlayerID `pid' -----"
	tab PLS_group GFE_group if playerID == `pid'
}
		
********************************************************************************
* Compare PLS & GFE assignments with P-Types
********************************************************************************
use FG2010, clear

merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
drop _merge
rename PLS_group PLS_All
merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"
drop _merge
rename GFE_group GFE_All

tab PLS_All GFE_All				// GFE group 1 is a subset of PLS group 1, except for one individual

tab preftype PLS_All			// All P-Types split in terms of both PLS and GFE
tab preftype GFE_All

********************************************************************************
* Beliefs by P-Types - they don't seem to differ significanly
********************************************************************************
use FG2010, clear

bys preftype: sum belief if period == 1
bys preftype: sum belief if period == 3
bys preftype: sum belief if period == 6

ranksum belief if period == 1 & preftype < 3, by(preftype)		// beliefs in the first period are not significantly different

ranksum belief if period == 2 & preftype < 3, by(preftype)		// in some other periods they are, but then again not
ranksum belief if period == 3 & preftype < 3, by(preftype)		
ranksum belief if period == 4 & preftype < 3, by(preftype)		
ranksum belief if period == 5 & preftype < 3, by(preftype)		
ranksum belief if period == 6 & preftype < 3, by(preftype)		
ranksum belief if period == 7 & preftype < 3, by(preftype)		
ranksum belief if period == 8 & preftype < 3, by(preftype)		
ranksum belief if period == 9 & preftype < 3, by(preftype)		
ranksum belief if period == 10 & preftype < 3, by(preftype)		

ranksum cont if period == 1 & preftype < 3, by(preftype)		// as a comparison, contributions are significantly different in all periods
ranksum cont if period == 2 & preftype < 3, by(preftype)
ranksum cont if period == 3 & preftype < 3, by(preftype)
ranksum cont if period == 4 & preftype < 3, by(preftype)
ranksum cont if period == 5 & preftype < 3, by(preftype)

*******************************************************************************
* Table with beliefs, contributions and prediscted contributions by 
* preference-, PLS- and GFE-Types (TABLE ABC)
*******************************************************************************
use FG2010, clear

merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
drop _merge
merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"
drop _merge

* Panel A
preserve
keep if period == 1

sum cont if preftype == 1
sum belief if preftype == 1
sum predictedcontribution if preftype == 1

sum cont if preftype == 2
sum belief if preftype == 2
sum predictedcontribution if preftype == 2

sum cont if preftype == 3
sum belief if preftype == 3
sum predictedcontribution if preftype == 3

sum cont if preftype == 4
sum belief if preftype == 4
sum predictedcontribution if preftype == 4

sum cont if PLS_group == 1
sum belief if PLS_group == 1
sum predictedcontribution if PLS_group == 1

sum cont if PLS_group == 2
sum belief if PLS_group == 2
sum predictedcontribution if PLS_group == 2

sum cont if GFE_group == 1
sum belief if GFE_group == 1
sum predictedcontribution if GFE_group == 1

sum cont if GFE_group == 2
sum belief if GFE_group == 2
sum predictedcontribution if GFE_group == 2
restore

* Panel B
sum cont if preftype == 1
sum belief if preftype == 1
sum predictedcontribution if preftype == 1

sum cont if preftype == 2
sum belief if preftype == 2
sum predictedcontribution if preftype == 2

sum cont if preftype == 3
sum belief if preftype == 3
sum predictedcontribution if preftype == 3

sum cont if preftype == 4
sum belief if preftype == 4
sum predictedcontribution if preftype == 4

sum cont if PLS_group == 1
sum belief if PLS_group == 1
sum predictedcontribution if PLS_group == 1

sum cont if PLS_group == 2
sum belief if PLS_group == 2
sum predictedcontribution if PLS_group == 2

sum cont if GFE_group == 1
sum belief if GFE_group == 1
sum predictedcontribution if GFE_group == 1

sum cont if GFE_group == 2
sum belief if GFE_group == 2
sum predictedcontribution if GFE_group == 2

*******************************************************************************
* Add a description for the figure caption
*******************************************************************************
use FG2010, clear

merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
drop _merge
merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"

gen description = ""
levelsof playerID, local(subjects)

foreach subject of local subjects {
	preserve
	keep if playerID == `subject'
	local a = preftype[1]
	local b = PLS_group[1]
	local c = GFE_group[1]
	local ind = indistinguishable[1]
	local confused = confused[1]
	
	local desc "P-Experiment: `a', PLS: `b', GFE: `c'"
	
	if `ind' == 1 {
		local desc "`desc', Indistinguishable"
	}

	if `confused' == 1 {
		local desc "`desc', Confused"
	}
	restore
	
	replace description = "`desc'" if playerID == `subject'
}

save FG2010_Figures, replace

*******************************************************************************
* Table 2 in the thesis (free rider table)
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"
use FG2010, clear

// players that act as "strong free rider" in the C-experiment
gen C_Type = .
bys playerID: egen allcont = total(cont)
replace C_Type = 2 if allcont == 0 
recode C_Type (.=-1)

keep if preftype == 2
tab C_Type

* OLS
reg cont belief, robust cl(session)
reg cont belief if C_Type != 2, robust cl(session)

* FE
xtreg cont belief , fe robust cl(session)
xtreg cont belief if C_Type != 2, fe robust cl(session)

* Post-Lasso
merge n:1 playerID using "csv/PLS/FG2010_FR_PLS_BeliefOnly"
assert _merge == 3
drop _merge

xtreg cont belief if PLS_group == 1 , fe robust cluster(session)
xtreg cont belief if PLS_group == 2 , fe robust cluster(session)

* GFE standard errors (for comparison only, the table shows bootstrapped standard errors)
merge n:1 playerID using "csv/GFE/FG2010_FR_GFE_2"

xtreg cont belief i.period if GFE_group == 1, robust cluster(session)
xtreg cont belief i.period if GFE_group == 2, robust cluster(session)

*******************************************************************************
* Table 3 in the thesis (explaining contributions)
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

use FG2010, clear
xtset playerID period

* OLS
reg cont belief predictedcontribution, robust cl(session)
reg cont belief predictedcontribution if confused==0, robust cl(session)
reg cont belief predictedcontribution if preftype == 1 & confused == 0, robust cl(session)
reg cont belief predictedcontribution if preftype == 3, robust cl(session)


* FE
xtreg cont belief predictedcontribution, fe robust cl(session)
xtreg cont belief predictedcontribution if confused==0, fe robust cl(session)
xtreg cont belief predictedcontribution if preftype == 1 & confused == 0, fe robust cl(session)
xtreg cont belief predictedcontribution if preftype == 3, fe robust cl(session)

* Post-Lasso
preserve
merge n:1 playerID using "csv/PLS/FG2010_All_PLS"
assert _merge == 3

xtreg cont belief predictedcontribution if PLS_group == 1 , fe robust cluster(session)
xtreg cont belief predictedcontribution if PLS_group == 2 , fe robust cluster(session)
restore

preserve
keep if preftype == 1 & confused == 0 
merge n:1 playerID using "csv/PLS/FG2010_CC_NotConfused_PLS"
assert _merge == 3

xtreg cont belief predictedcontribution if PLS_group == 1 , fe robust cluster(session)
xtreg cont belief predictedcontribution if PLS_group == 2 , fe robust cluster(session)
restore

preserve
keep if preftype == 3
merge n:1 playerID using "csv/PLS/FG2010_TR_PLS"
assert _merge == 3

xtreg cont belief predictedcontribution if PLS_group == 1 , fe robust cluster(session)
xtreg cont belief predictedcontribution if PLS_group == 2 , fe robust cluster(session)
restore

preserve
keep if confused==0
merge n:1 playerID using "csv/PLS/FG2010_NotConfused_PLS"
assert _merge == 3

xtreg cont belief predictedcontribution if PLS_group == 1 , fe robust cluster(session)
xtreg cont belief predictedcontribution if PLS_group == 2 , fe robust cluster(session)
restore

* GFE (for comparision of standard errors only)
preserve
merge n:1 playerID using "csv/GFE/FG2010_All_GFE_2"
assert _merge == 3

reg cont belief predictedcontribution i.period if GFE_group == 1 , robust cluster(session)
reg cont belief predictedcontribution i.period  if GFE_group == 2 , robust cluster(session)
restore


*******************************************************************************
* Relation between "player types" in the P- and C-experiment
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

use FG2010, clear
xtset playerID period

// "player types" in the in the P-experiment
preserve
duplicates drop playerID, force
tab preftype
restore

// players that act as "strong free rider" in the C-experiment
gen C_Type = .
bys playerID: egen allcont = total(cont)
//hist allcont
replace C_Type = 2 if allcont == 0 

// count P-"strong free rider" who are also "C-strong free rider" (13/32)
preserve
keep if C_Type == 2
duplicates drop playerID, force
tab preftype
tab u if preftype == 2					// 10 players have 0, one player 3 and one 5
tab sequencePC if preftype == 2			// no sequence effect
restore

// those P-"strong free rider" who are not "C-strong free rider" (19/32) follow their beliefs
preserve
keep if preftype == 2 & C_Type != 2
reg cont belief , r cl( session ) 
xtreg cont belief , r cl( session ) 	

tab u if period == 1				// interestingly, 13 have 0, then 5,6,8,10 each once and twice 20

tab firstcont if period == 1		// this one is higher	
sum firstcont if period == 1

tab allcont if period == 1
sum allcont if period == 1

tab sequencePC if period == 1		// no sequence effect
restore

// Look at P-"perfect conditional cooperators" (13)
gen P_perfect_CC = (b0 == 0) & (b1 == 1) & (b2 == 2) & (b3 == 3) & (b4 == 4) & (b5 == 5) & (b6 == 6) & (b7 == 7) & (b8 == 8) & (b9 == 9) & (b10 == 10) & (b11 == 11)  & (b12 == 12) & (b13 == 13) & (b14 == 14) & (b15 == 15) & (b16 == 16) & (b17 == 17) & (b18 == 18) & (b19 == 19) & (b20 == 20)

preserve
keep if P_perfect_CC == 1
tab C_Type	// 1 free rider, drop him
drop if C_Type == 2
reg cont belief , r cl( session ) 
xtreg cont belief , r cl( session ) 
count
restore

*******************************************************************************
* Earnigs differential among P-"strong free riders"
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

use FG2010, clear
keep if preftype == 2
xtset playerID period

// players that act as "strong free rider" in the C-experiment
gen C_Type = .
bys playerID: egen allcont = total(cont)
replace C_Type = 2 if allcont == 0 
recode C_Type (.=-1)

// simple eanings differential ("C-strong free rider" earn significantly more)
bys playerID: egen gameprofit = total(profit)

tab gameprofit if C_Type == 2 & period == 1 
tab gameprofit if C_Type != 2 & period == 1
sum gameprofit if C_Type == 2 & period == 1 
sum gameprofit if C_Type != 2 & period == 1 

ranksum gameprofit if period == 1, by(C_Type)

// check if there is random error or endogeneity by checking contributions of other players in the first period 
// (it is higher for "C-strong free riders", but not significant of pronounced)
tab othercont if C_Type == 2 & period == 1 
tab othercont if C_Type != 2 & period == 1
sum othercont if C_Type == 2 & period == 1 
sum othercont if C_Type != 2 & period == 1

ranksum othercont if period == 1, by(C_Type)

// check if there is random error or endogeneity by checking contributions of other players in all periods
tab othercont if C_Type == 2
tab othercont if C_Type != 2
sum othercont if C_Type == 2 
sum othercont if C_Type != 2 

ranksum othercont, by(C_Type)

*******************************************************************************
* Endogeneity of beliefs
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"
use FG2010, clear

// players that act as "strong free rider" in the C-experiment
gen C_Type = .
bys playerID: egen allcont = total(cont)
replace C_Type = 2 if allcont == 0 
recode C_Type (.=-1)

keep if preftype == 2

bys C_Type: sum belief if period == 1
ranksum belief if period == 1, by(C_Type)

bys C_Type: sum belief 
ranksum belief, by(C_Type) 

*******************************************************************************
* Tables for the online appendix
*******************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

foreach f in "FG2010_All" "FG2010_NotConfused"  "FG2010_CC_NotConfused" "FG2010_TR" "FG2010_FR" {
	* GFE
	use FG2010, clear	
	keep playerID session player
	duplicates drop
	merge 1:1 playerID using "csv/GFE/`f'_GFE_2"
	keep if _merge == 3
	keep session player GFE_group
	rename GFE_group group

	save `f'_GFE, replace
	
	* PLS
	use FG2010, clear	
	keep playerID session player
	duplicates drop
	merge 1:1 playerID using "csv/PLS/`f'_PLS"
	keep if _merge == 3
	keep session player PLS_group
	rename PLS_group group

	save `f'_PLS, replace
}

