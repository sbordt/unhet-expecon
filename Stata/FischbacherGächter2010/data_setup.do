cd "S:\people\Sebastian B\Masterarbeit\FischbacherGächter2010"

use "new data zip file\figae_beliefs&contributions.dta", clear

* rename variables 
rename idsess session
rename subject player
rename contribution cont
rename idtyp preftype

order session player period
sort session player period

drop idsubj
gen random = 1

bys session group period: egen totcont = total(cont)
gen profit = 20-cont + 0.4*totcont

save FischbacherGächter2010, replace
