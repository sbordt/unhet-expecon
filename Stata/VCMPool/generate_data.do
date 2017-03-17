cd "S:\people\Sebastian B\Masterarbeit\VCMPool"

* Fehr & Gächter 2000
use "S:\people\Sebastian B\Masterarbeit\FehrGächter2000\FehrGächter2000", clear 

keep if !punishment & !stranger

rename playerNo player
rename contributions cont
rename groupcontributions groupcont
rename group_welfare groupwelfare

keep session group period player cont groupcont profit groupwelfare
gen experiment = "Fehr & Gächter 2000"

save VCMPool, replace

* Nikiforakis 2008
use "S:\people\Sebastian B\Masterarbeit\Nikiforakis2008\NN_CPun_Data", clear 

keep if fixed & vcm

rename mycont cont
rename totcont groupcont
rename welfare groupwelfare

keep session group period player cont groupcont profit groupwelfare
gen experiment = "Nikiforakis 2008"

append using VCMPool
save VCMPool, replace
