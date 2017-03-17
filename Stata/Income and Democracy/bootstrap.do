********************************************************************************
* First, check how BM compute their bootstrapped standard errors
********************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\Income and Democracy" 
use 5yearpanel_balace630, clear

sort code_numeric year
xtset code_numeric year

xtgfe fhpolrigaug L_fhpolrigaug L_lrgdpch, groups(4) nsim(10) errors(1) errors_nsim(100)
estat geplot

clear
matrix E = e(error_assignments)
svmat E, names(col)

* use original estimate as "mean" 
gen se = (L_fhpolrigaug - .30164063)^2
egen sse = total(se) 
gen error = sqrt(sse/(_N-1))  

* use the mean of the bootstrap replications (this is what BM do)
egen mean = mean(L_fhpolrigaug)
gen se_2 = (L_fhpolrigaug - mean)^2
egen sse_2 = total(se_2)
gen error_2 = sqrt(sse_2/(_N-1))

********************************************************************************
* Perform bootstrap replications
********************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\Income and Democracy" 

set matsize 1400
foreach i of numlist 1/1400 {
	use "S:\people\Sebastian B\Masterarbeit\Income and Democracy\5yearpanel_balace630", clear
	keep code_numeric year fhpolrigaug L_fhpolrigaug L_lrgdpch
	bsample 90, cluster(code_numeric) idcluster(ID)
	sort ID year
	xtset ID year
	xtgfe fhpolrigaug L_fhpolrigaug L_lrgdpch, groups(4) nsim(50)
	
	if `i' == 1 {
		matrix E = e(b)
	}
	else {
		matrix E = E\e(b)
	}
}

clear
svmat E, names(col)
save bootstrap_replications, replace

********************************************************************************
* Compute bootstrapped standard errors
********************************************************************************
cd "S:\people\Sebastian B\Masterarbeit\Income and Democracy" 
use bootstrap_replications, clear

set scheme plotplainblind, permanently
hist L_fhpolrigaug, bin(20) xsize(5) ysize(4) fintensity(25) fcolor(gs10) xtitle("Bootstrapped Estimate of Coefficient on Lagged Democracy")
graph export "figures\bootstrapped_hist.pdf", replace

* use original estimate as "mean" 
gen se = (L_fhpolrigaug - .30164063)^2
egen sse = total(se) 
gen error = sqrt(sse/(_N-1))  

* use the mean of the bootstrap replications
egen mean = mean(L_fhpolrigaug)
gen se_2 = (L_fhpolrigaug - mean)^2
egen sse_2 = total(se_2)
gen error_2 = sqrt(sse_2/(_N-1))

* also for income
gen se_gdpch = (L_lrgdpch - .08230333)^2
egen sse_gdpch = total(se_gdpch) 
gen error_gdpch = sqrt(sse_gdpch/(_N-1))  

egen mean_gdpch = mean(L_lrgdpch)
gen se_2_gdpch = (L_lrgdpch - mean_gdpch)^2
egen sse_2_gdpch = total(se_2_gdpch)
gen error_2_gdpch = sqrt(sse_2_gdpch/(_N-1))

* OLS point estimate
use "S:\people\Sebastian B\Masterarbeit\Income and Democracy\5yearpanel_balace630", clear

reg fhpolrigaug L_fhpolrigaug L_lrgdpch

* Average number of distinct observations in the mean bootstrap sample
foreach i of numlist 1/1400 {
	use "S:\people\Sebastian B\Masterarbeit\Income and Democracy\5yearpanel_balace630", clear
	keep code_numeric year fhpolrigaug L_fhpolrigaug L_lrgdpch
	bsample 90, cluster(code_numeric) idcluster(ID)
	keep if year == 1970
	duplicates drop code_numeric, force
	count
	
	if `i' == 1 {
		matrix E = r(N)
	}
	else {
		matrix E = E\r(N)
	}
}

clear
svmat E, names(col)
sum c1

********************************************************************************
* Assess "misclassification" to explain bias towards OLS
********************************************************************************
use "S:\people\Sebastian B\Masterarbeit\Income and Democracy\5yearpanel_balace630", clear

xtgfe fhpolrigaug L_fhpolrigaug L_lrgdpch, groups(4) nsim(10)
xtreg  fhpolrigaug L_fhpolrigaug L_lrgdpch i.assignment#i.year, robust

duplicates drop code_numeric, force
keep code_numeric assignment

save "S:\people\Sebastian B\Masterarbeit\Income and Democracy\assignment", replace

foreach i of numlist 1/100 {
	use "S:\people\Sebastian B\Masterarbeit\Income and Democracy\5yearpanel_balace630", clear
	keep code_numeric year fhpolrigaug L_fhpolrigaug L_lrgdpch
	bsample 90, cluster(code_numeric) idcluster(ID)
	sort ID year
	xtset ID year
	xtgfe fhpolrigaug L_fhpolrigaug L_lrgdpch, groups(4) nsim(50)

	duplicates drop code_numeric, force
	keep code_numeric assignment
	rename assignment b_assignment
	
	merge 1:1 code_numeric using "S:\people\Sebastian B\Masterarbeit\Income and Democracy\assignment"
	keep if _merge == 3
	
	match_assignments assignment b_assignment

	if `i' == 1 {
		matrix MISSPEC = r(misspec_per_cent) 			
	}
	else {
		matrix MISSPEC = MISSPEC\r(misspec_per_cent)
	}
}

clear
svmat MISSPEC, names(col)
save "S:\people\Sebastian B\Masterarbeit\Income and Democracy\MISSPEC", replace

sum c1
