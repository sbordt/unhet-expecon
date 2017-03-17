cd "S:\people\Sebastian B\Masterarbeit\VCMPooledStranger"

* Fehr & Gächter 2000
use "S:\people\Sebastian B\Masterarbeit\FehrGächter2000\FehrGächter2000", clear 

keep if !punishment & stranger

rename playerNo player
rename contributions cont
rename groupcontributions groupcont
* rename group_welfare groupwelfare

gen othercont = round((groupcont - cont)/3)

keep session group period player cont othercont profit // groupwelfare
gen experiment = "Fehr & Gächter 2000"

order experiment session group period player cont othercont profit // groupwelfare

save VCMStrangers, replace

* Nikiforakis 2008
use "S:\people\Sebastian B\Masterarbeit\Nikiforakis2008\NN_CPun_Data", clear 

keep if !fixed & vcm

rename mycont cont
*rename welfare groupwelfare

drop player
rename subject player

gen othercont = round((totcont - cont)/3)

keep session group period player cont othercont profit // groupwelfare
gen experiment = "Nikiforakis 2008"

order experiment session group period player cont othercont profit // groupwelfare

append using VCMStrangers
save VCMStrangers, replace

* Fischbaer & Gächter 2010
use "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010\FischbacherGächter2010", clear

rename otherscontrib othercont

keep session group period player cont othercont profit preftype belief b* u predictedcontribution sequencePC
gen experiment = "Fischbaer & Gächter 2010"

order experiment session group period player cont othercont profit

label var preftype "Preference type: 1= conditional cooperator; 2= selfish ; 3= triangle; 4 = other"	// misslabeled in the original dataset

append using VCMStrangers
save VCMStrangers, replace


* prepare dataset for analysis
use VCMStrangers, clear

gen oldid = 1000*session+player
replace oldid = 100000 + oldid if experiment == "Nikiforakis 2008"
replace oldid = 200000 + oldid if experiment == "Fischbaer & Gächter 2010"
egen playerID = group(oldid)
drop oldid

sort playerID period
xtset playerID period
tsset playerID period

bys playerID: gen firstcont = cont[1]
bys playerID: gen initialbelief = belief[1]

gen Lcont = L.cont
gen L2cont = L.Lcont
gen L3cont = L.L2cont

gen Lothercont = L.othercont
gen L2othercont = L.Lothercont
gen L3othercont = L.L2othercont

label var session 	"Session No. within the original experiment"
label var group  	"Group No. (within session)"
label var player  	"Subject No. (within session)"
label var playerID	"Unique subject No. within the dataset"

order experiment playerID period

save VCMStrangers, replace
outsheet * using  VCMStrangers.csv , comma replace


