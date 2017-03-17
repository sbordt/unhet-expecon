set more off

cd "S:\people\Sebastian B\Masterarbeit\Nikiforakis2008"

* replicate table 1 in the paper
/*
use NN_CPun_Data, clear 
order session fixed pcp p vcm before period

bys session: egen mean_vcm = mean(mycont) if vcm == 1
bys session: egen mean_other = mean(mycont) if vcm == 0

keep session fixed pcp p vcm before mean_vcm mean_other
duplicates drop

sort session vcm
*/

*
* The effect of having a P-treatment before VCM on the individual contribution in the first period (sessions 5-8 and 13-16)
* 
* Wilcoxon rank-sum (Mann-Whitney) test rejects the null that there is no difference at 95%
*
* With total contributions or fixed/random seperately always rejected at above 80%
* 
* 
use NN_CPun_Data, clear 
keep if vcm & period == 1 & (session == 5 | session == 6 | session == 7 | session == 8 | session == 13 | session == 14 | session == 15 | session == 16)

ranksum mycont, by(before)

* in comparison, there is no significant effect of PCP
use NN_CPun_Data, clear 
keep if vcm & period == 1 & (session == 1 | session == 2 | session == 3 | session == 4 | session == 9 | session == 10 | session == 11 | session == 12)

ranksum mycont, by(before)

* is there an effect on first period of PCP of having VCM before
use NN_CPun_Data, clear 
keep if pcp & period == 1 & (session == 1 | session == 2 | session == 3 | session == 4)

ranksum mycont, by(year)

********************************************************************************
* 0 and 20 as focal points
********************************************************************************
use NN_CPun_Data, clear 
keep if fixed & pcp

tab mycont if period == 1
tab mycont if period == 2
tab mycont if period == 3
tab mycont if period == 4
tab mycont if period == 5
tab mycont if period == 6
tab mycont if period == 7
tab mycont if period == 8
tab mycont if period == 9
tab mycont if period == 10

