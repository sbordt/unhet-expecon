:: This script calls Bootstrap_version.exe, automatically entering program parameters.
::
:: It takes 12 parameters.
::
:: The 6 possible usages are:
::
:: gfe 5 5 1 2 3 3 1 1 5 3 3 2			(VNS and bootstraped standard errors with VNS)	
:: gfe 5 5 1 2 3 3 1 0 7 -1 -1 4 		(VNS and bootstraped standard errors with Algorithm 1)				
:: gfe 5 5 1 2 3 3 0 -1 -1 -1 -1 -1		(VNS, no standard errors)	
:: gfe 5 5 0 10 -1 -1 1 1 5 3 3 2		(Algorithm 1 and bootstraped standard errors with VNS)
:: gfe 5 5 0 10 -1 -1 1 0 7 -1 -1 4		(Algorithm 1 and bootstraped standard errors with Algorithm 1)
:: gfe 5 5 0 10 -1 -1 0 -1 -1 -1 -1 -1	(Algorithm 1, no standard errors)

:: change working directory to the directory of the script
CD /D %~dp0

:: read parameters
setlocal enableDelayedExpansion
SET ngroups=%1
SHIFT 
SET ncovariates=%1
SHIFT 
SET algorithm=%1
SHIFT 
SET nsim=%1
SHIFT 
SET neighbours=%1
SHIFT 
SET steps=%1
SHIFT 
SET bootstraped_errors=%1
SHIFT 
SET bootstraped_errors_algorithm=%1
SHIFT 
SET bootstraped_errors_nsim=%1
SHIFT 
SET bootstraped_errors_neighbours=%1
SHIFT 
SET bootstraped_errors_steps=%1
SHIFT 
SET bootstraped_replications=%1

:: call executable file inserting parameters into the input stream, depending on the choice of algorithm and standard errors
if "%algorithm%"=="1" (
	if "%bootstraped_errors%"=="1" (
		if "%bootstraped_errors_algorithm%"=="1" (
			(echo %ngroups%  
			echo %ncovariates% 
			echo %algorithm%
			echo %nsim%
			echo %neighbours%
			echo %steps%
			echo %bootstraped_errors%
			echo %bootstraped_errors_algorithm%
			echo %bootstraped_errors_nsim%
			echo %bootstraped_errors_neighbours%
			echo %bootstraped_errors_steps%
			echo %bootstraped_replications%)| Bootstrap_version.exe
		) else (
			(echo %ngroups%  
			echo %ncovariates% 
			echo %algorithm%
			echo %nsim%
			echo %neighbours%
			echo %steps%
			echo %bootstraped_errors%
			echo %bootstraped_errors_algorithm%
			echo %bootstraped_errors_nsim%
			echo %bootstraped_replications%)| Bootstrap_version.exe
		)
	) else (
		(echo %ngroups%  
		echo %ncovariates% 
		echo %algorithm%
		echo %nsim%
		echo %neighbours%
		echo %steps%
		echo %bootstraped_errors%)| Bootstrap_version.exe		
	)
) else (
	if "%bootstraped_errors%"=="1" (
		if "%bootstraped_errors_algorithm%"=="1" (
			(echo %ngroups%  
			echo %ncovariates% 
			echo %algorithm%
			echo %nsim%
			echo %bootstraped_errors%
			echo %bootstraped_errors_algorithm%
			echo %bootstraped_errors_nsim%
			echo %bootstraped_errors_neighbours%
			echo %bootstraped_errors_steps%
			echo %bootstraped_replications%)| Bootstrap_version.exe
		) else (
			(echo %ngroups%  
			echo %ncovariates% 
			echo %algorithm%
			echo %nsim%
			echo %bootstraped_errors%
			echo %bootstraped_errors_algorithm%
			echo %bootstraped_errors_nsim%
			echo %bootstraped_replications%)| Bootstrap_version.exe
		)
	) else (
		(echo %ngroups%  
		echo %ncovariates% 
		echo %algorithm%
		echo %nsim%
		echo %bootstraped_errors%)| Bootstrap_version.exe	
	)
)

