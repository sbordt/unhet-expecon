clear all
set more off 

cd "S:\people\Sebastian B\Masterarbeit\FehrGächter2000"

use AER2000ExpData

replace matching = "1" if matching=="stranger"
replace matching = "0" if matching=="partner"
rename matching stranger 

replace treatment = "1" if treatment=="with pun." | treatment=="with pun"
replace treatment = "0" if treatment=="without pun."
rename treatment punishment

destring session stranger period punishment playerNo group contributions groupcontributions profit1ststage pun_sum_given pun_cost sum_pun_received profit, replace dpcomma

replace profit = profit1ststage if profit == .

foreach i of numlist 1/24 {
	recode p`i' (. = 0)
	replace p`i' = abs(p`i')
}

recode pun_sum_given pun_cost sum_pun_received (. = 0)
replace pun_sum_given = abs(pun_sum_given)

* whether the player punished in a given period
gen punished = 0

foreach i of numlist 1/24 {
	replace punished =  1 if p`i' != 0
}

* generate 'year' and recode periods from 1 to 10
gen year = 1
replace year = 2 if period > 10
replace period = period - 10 if year == 2

sort session group year period player
order session group year period player

* welfare
by session group year period: egen group_welfare = total(profit)

save FehrGächter2000, replace

* verify data
gen sum_given = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 + p11 + p12 + p13 + p14 + p15 + p16 + p17 + p18 + p19 + p20 + p21 + p22 + p23 + p24
assert sum_given == pun_sum_given


