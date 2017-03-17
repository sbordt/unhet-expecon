cd "S:\people\Sebastian B\Masterarbeit\Income and Democracy\"

use "5yearpanel.dta", clear

tsset code_numeric year_numeric
sort code_numeric year_numeric

gen L_fhpolrigaug = L.fhpolrigaug
gen L_lrgdpch = L.lrgdpch 

* keep only the relevant periods (1960-2000)
drop if year<1960

* keep only balanced subsample of 630 observations
keep if samplebalancefe==1

save "5yearpanel_balace630", replace

* GFE (replication of bonhomme & manresa) 
xtset code_numeric year
xtgfe fhpolrigaug L_fhpolrigaug L_lrgdpch, groups(4)

* visualize group effects 
estat geplot



