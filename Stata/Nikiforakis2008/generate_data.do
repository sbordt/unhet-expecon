clear all
set more off

cd "S:\people\Sebastian B\Masterarbeit\Nikiforakis2008"

insheet using "NN_CPun_Data.csv", delimiter(;) clear

label variable p1 "punishment points given to player 1"
label variable p2 "punishment points given to player 2"
label variable p3 "punishment points given to player 3"
label variable p4 "punishment points given to player 4"

label variable cp1 "counter-punishment points given to player 1"
label variable cp2 "counter-punishment points given to player 2"
label variable cp3 "counter-punishment points given to player 3"
label variable cp4 "counter-punishment points given to player 4"

recode session (101 = 1) (102 = 3) (103 = 4) (104 = 2) (105 = 7) (106 = 8) (107 = 5) (108 = 6) (201 = 9) (202 = 11) (203 = 12) (204 = 10) (205 = 15) (206 = 16) (207 = 13) (208 = 14)

gen year = 1+((!before & (p | pcp))  | (before & vcm)) 

recode p1 p2 p3 p4 cp1 cp2 cp3 cp4 (-1 = .)

* generate player number 1 ... 4 in accodance with p1-p4 and cp1-cp4
sort session year period group subject
order session year period group subject

bys session year period group: gen player = _n
foreach i of numlist 1/4 {
	replace player = `i' if (p | pcp ) & p`i' == .
}

* number subjects 1 ... 192
save NN_CPun_Data, replace
duplicates drop subject, force
keep subject
sort subject
gen subject_ = _n
merge 1:m subject using NN_CPun_Data
drop _merge
drop subject
rename subject_ subject

order session year group period player
sort session year group period player 

* number groups 1 ... 4 (per session and year)
save NN_CPun_Data, replace
duplicates drop group, force
by session year: gen group_ = _n
keep group group_
merge 1:m group using NN_CPun_Data
drop _merge
drop group
rename group_ group

order session year group period player
sort session year group period player 

* number clusters as used by Nikiforakis 1 ... 32
save NN_CPun_Data, replace
duplicates drop cluster, force
keep cluster
sort cluster
gen cluster_ = _n
merge 1:m cluster using NN_CPun_Data
drop _merge
drop cluster
rename cluster_ cluster

order session year group period player
sort session year group period player 

* generate a variable for the number of punishment points received by player i
foreach i of numlist 1/4 {
	gen rec_p`i' = .
	label variable rec_p`i' "punishment points received by player `i'"

	foreach j of numlist 1/4 {
		by session year group period: replace rec_p`i' = p`j'[`i'] if player == `j'
	}
}

* generate a variable for the number of counter-punishment points received by player i
foreach i of numlist 1/4 {
	gen rec_cp`i' = .
	label variable rec_cp`i' "counter-punishment points received by player `i'"

	foreach j of numlist 1/4 {
		by session year group period: replace rec_cp`i' = cp`j'[`i'] if player == `j'
	}
}

* generate punishment and payoff
egen p_total = rowtotal(p1 - p4) if p | pcp
label variable p_total "total number of punishment points given (own calculation)"

egen rec_p_total = rowtotal(rec_p1 - rec_p4) if p | pcp
label variable rec_p_total "total number of punishment points received (own calculation)"

egen cp_total = rowtotal(cp1 - cp4) if pcp
label variable cp_total "total number of counter-punishment points given (own calculation)"

egen rec_cp_total = rowtotal(rec_cp1 - rec_cp4) if pcp
label variable rec_cp_total "total number of counter-punishment points received (own calculation)"


* assert that our own calculations match date given by Nikiforakis
assert p_total == pts_given	
label variable pts_given "total number of punishment points given (Nikiforakis)"
 
* total number of punishment periods per group
by session year group period: egen p_incidence = total(p_total)
replace p_incidence = !(!p_incidence)
replace p_incidence = 0 if player != 1

by session year group: egen group_p_periods = total(p_incidence) if p | pcp | fixed
label variable group_p_periods "total number of punishment periods per group"
drop p_incidence  
 
//assert rec_cp_total == cpts_given	

// TODO understand other variables by nikiforakis







* generate a text variable containing the names of players punished by the player
/*foreach i of numlist 1/4 {
	gen p`i'_text = ""
	replace p`i'_text = "Player `i' " if p`i' > 0 & p`i' != .
}

gen punished = p1_text + p2_text + p3_text + p4_text

foreach i of numlist 1/4 {
	drop p`i'_text
}
*/
/*

* generate a text variable containing the names of players who punished the player
foreach i of numlist 1/4 {
	gen r_p`i'_text = ""
	replace r_p`i'_text = "Player `i' " if r_p`i' > 0 & r_p`i' != .
}

gen punished = r_p1_text + r_p2_text + r_p3_text + r_p4_text

foreach i of numlist 1/4 {
	drop r_p`i'_text
}

* generate a text variable containing the names of players who counter-punished the player
foreach i of numlist 1/4 {
	gen r_cp`i'_text = ""
	replace r_cp`i'_text = "Player `i' " if r_cp`i' > 0 & r_cp`i' != .
}

gen counter_punished_names = r_cp1_text + r_cp2_text + r_cp3_text + r_cp4_text

foreach i of numlist 1/4 {
	drop r_cp`i'_text
}

*/
by session year group period: egen welfare = sum(profit)

save NN_CPun_Data, replace






*** structure of dependent variables ***
use NN_CPun_Data, replace
assert abs( profit - (20-mycont+inc_proj) )<0.001 if vcm==1

assert abs( inc_stg_1 - (20-mycont+inc_proj) )<0.001 if p==1 | pcp==1	//inc_stg_1=. if vcm==1

assert abs( profit - ( (max(0,10-rcvd_pts))/10 )*(inc_stg_1) + cost_pts )<0.001 if p==1
assert abs( inc_stg_2 - ( (max(0,10-rcvd_pts))/10 )*(inc_stg_1) + cost_pts )<0.001 if pcp==1	//inc_stg_2=. if p==1

assert abs( profit - ( (max(0,10-rcvd_pts))/10 )*(inc_stg_1) + cost_pts )<0.001 if pcp==1 & cpts_given==0 & temp_tcp==0
assert abs( inc_stg_2 - ( (max(0,10-rcvd_pts))/10 )*(inc_stg_1) + cost_pts )<0.001 if pcp==1

*** total group contributions ***
use NN_CPun_Data, replace

by session year group period: egen group_total_cont = sum(mycont)
assert group_total_cont == totcont 
