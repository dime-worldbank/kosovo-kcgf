
	
	
	*A*
	*Variables selected as good predictors of the probability of getting a KCGF funded loan, machine learning models
	*________________________________________________________________________________________________________________________________________*
	{ //Analysis performed by Simon Neumeyer in Python 
	
	**
	*Models tested: OLS, Lasso, Forest, XGboost
	
		**
		*Comparion Group 0 -> no loans. 
		*------------------------------------------------------------------------------------------------------------------------------------*
		global controls0_ols	   		num_loans    		 lag1_num_loans     		lag2_num_loans   		///
										employees 	 		 lag1_employees 			sq_employees 			///
										productivity_r 		 export_tx  										///
										sq_number_loans_up2015													///
										sectionid1			
									
		global controls0_lasso	    	num_loans 			 sq_lag2_num_loans   								///
										number_loans_up2015 													///
										wages_worker_r 		 lag1_wages_worker_r    	 						///
										productivity_r 		 sectionid12 										///
										employees 			 lag1_employees 			sq_lag2_employees
				
				
		global controls0_ridge    		num_loans    		 lag1_num_loans    			lag2_num_loans 			///
										employees 			 lag1_employees 	  		sq_employees			///
										productivity_r 		 export_tx 											///
										sq_number_loans_up2015 													///
										sectionid1		
				
				
		global controls0_forest	 		num_loans 			 sq_num_loans 										///
										wages_worker_r		 sq_wages_worker_r				 					///
										number_loans_up2015  sq_number_loans_up2015								///
										productivity_r 		 sq_productivity_r 			sq_lag1_productivity_r
		
		
		global controls0_xgboost	 	import_tx 			 sectionid1 				sectionid20 			///
										sq_number_loans 	 sq_lag1_num_loans 	    	sq_lag2_num_loans 		///
										num_loans 			 sq_lag1_wages_worker_r 	sq_number_loans_up2015
										
		global controls0_vivian	 		number_loans_up2015 sq_number_loans_up2015				///
										productivity_r 		 sq_productivity_r employees		///
										wages_worker_r		 sq_wages_worker_r					///
										sectionid1-sectionid20 firms_age
		
		
		**
		*Comparion Group 1 -> other loans
		*------------------------------------------------------------------------------------------------------------------------------------*
		global controls1_ols	   		num_loans    		 lag1_num_loans     		lag2_num_loans   		///
										employees 	 		 lag1_employees 			sq_employees 			///
										productivity_r 		 export_tx  										///
										sq_number_loans_up2015													///
										sectionid1			
									
		global controls1_lasso	    	num_loans 			 sq_lag2_num_loans   								///
										number_loans_up2015 													///
										wages_worker_r 		 lag1_wages_worker_r    	 						///
										productivity_r 		 sectionid12 										///
										employees 			 lag1_employees 			sq_lag2_employees
				
				
		global controls1_ridge    		num_loans    		 lag1_num_loans    			lag2_num_loans 			///
										employees 			 lag1_employees 	  		sq_employees			///
										productivity_r 		 export_tx 											///
										sq_number_loans_up2015 													///
										sectionid1		
				
				
		global controls1_forest	 		num_loans 			 sq_num_loans 										///
										wages_worker_r		 sq_wages_worker_r				 					///
										number_loans_up2015  sq_number_loans_up2015								///
										productivity_r 		 sq_productivity_r 			sq_lag1_productivity_r
		
		
		global controls1_xgboost	 	import_tx 			 sectionid1 				sectionid20 			///
										sq_number_loans 	 sq_lag1_num_loans 	    	sq_lag2_num_loans 		///
										num_loans 			 sq_lag1_wages_worker_r 	sq_number_loans_up2015
										
		global controls1_vivian	 		number_loans_up2015 sq_number_loans_up2015		///
										productivity_r 		 sq_productivity_r employees		///
										wages_worker_r		 sq_wages_worker_r					///
										sectionid1-sectionid20 firms_age
										
		}	
		
	
	
	*B*
	*Propensity score matching using the vector of covariates suggested by the machine learning and testing parallel trends of the matched sample
	*________________________________________________________________________________________________________________________________________*
		
		
	*----------------------------------------------------------------------------------------------------------------------------------------*		
	foreach model in ols lasso ridge  forest xgboost vivian  	{  //ols lasso ridge  forest xgboost
		
		foreach comparison in 0 1  					 			{	//0 1 //1	//0-> firms with no loans, 1-> firms with loans
			
			**
			*1* PSM
			*--------------------------------------------------------------------------------------------------------------------------------*
			use "$data\final\firm_year_level.dta"  , clear
			*--------------------------------------------------------------------------------------------------------------------------------*
			{	
				**
				**
				*----------------------------------------------------------------------------------------------------------------------------*
				keep 	if main_dataset == 1   & period == 2015 				//active firms in 2015
				keep 	if sme 			== "a.1-9"	//micro, small or medium firms
				keep 	if inlist(type_firm_after2015,`comparison', 2) 							//keeping only comparison group 0 or 1 and type_firm_2015 = 2 (which means the ones that had access to KCGF)
				keep    if active == 1
				*drop 	if deathyear 	== 2015
				*----------------------------------------------------------------------------------------------------------------------------*

				**
				*Treatment status
				*----------------------------------------------------------------------------------------------------------------------------*
				gen 	treated = 1 if type_firm_after2015 == 2									//treated firms are the ones with KCGF
				replace treated = 0 if type_firm_after2015 == `comparison'						//comparison firms
				*----------------------------------------------------------------------------------------------------------------------------*
					
				**
				*Matching
				*----------------------------------------------------------------------------------------------------------------------------*
				if `comparison' == 0 & "`model'" == "ols" 		{
				psmatch2 treated $controls0_ols		, n(3) common ties
				probit	 treated $controls0_ols
				}
				if `comparison' == 0 & "`model'" == "lasso"  { 
				psmatch2 treated $controls0_lasso, n(3) common ties
				probit	 treated $controls0_lasso
				}
				if `comparison' == 0 & "`model'" == "ridge"  { 
				psmatch2 treated $controls0_ridge, n(3) common ties
				probit	 treated $controls0_ridge
				}				
				if `comparison' == 0 & "`model'" == "forest" 	{
				psmatch2 treated $controls0_forest	, n(3) common ties
				probit	 treated $controls0_forest 
				}
				if `comparison' == 0 & "`model'" == "xgboost" 	{
				psmatch2 treated $controls0_xgboost	, n(3) common ties
				probit	 treated $controls0_xgboost	
				}
				if `comparison' == 0 & "`model'" == "vivian" 	{
				psmatch2 treated $controls0_vivian	, n(3) common ties
				probit	 treated $controls0_vivian
				
				}				
				if `comparison' == 1 & "`model'" == "ols" 		{
				psmatch2 treated $controls1_ols		, n(3) common ties
				probit	 treated $controls1_ols	
				}
				if `comparison' == 1 & "`model'" == "lasso"  {
				psmatch2 treated $controls1_lasso, n(3) common ties
				probit	 treated $controls1_lasso
				}
				if `comparison' == 1 & "`model'" == "ridge"  {
				psmatch2 treated $controls1_ridge, n(3) common ties
				probit	 treated $controls1_ridge
				}				
				if `comparison' == 1 & "`model'" == "forest" 	{
				psmatch2 treated $controls1_forest	, n(3) common ties
				probit	 treated $controls1_forest
				}
				if `comparison' == 1 & "`model'" == "xgboost" 	{
				psmatch2 treated $controls1_xgboost	, n(3) common ties	
				probit	 treated $controls1_xgboost
				}
				if `comparison' == 1 & "`model'" == "vivian" 	{
				psmatch2 treated $controls1_vivian	, n(3) common ties	
				probit	 treated $controls1_vivian
				}				
				
				*----------------------------------------------------------------------------------------------------------------------------*
				
				*Weights
				*----------------------------------------------------------------------------------------------------------------------------*
				gen 		   _weight2  = _pscore/(1-_pscore) 	if  _treated == 0
				replace 	   _weight2  = 1 					if 	_treated == 1
				*----------------------------------------------------------------------------------------------------------------------------*
				
				**
				*
				*----------------------------------------------------------------------------------------------------------------------------*
				preserve
				predict  xb 			//probability of treatment according to the model
				gen model = "`model'"
				save "$data\inter\matching_models\matching_`model'_`comparison'.dta", replace
				restore
			
				**
				**Commom support
				*----------------------------------------------------------------------------------------------------------------------------*
				keep 		if _support == 1	& _weight  != .	
				tempfile  matched_comparison`comparison'
				save	 `matched_comparison`comparison''			//matched firms on the commom support 
				*----------------------------------------------------------------------------------------------------------------------------*
				
				**
				*Kernel Density
				*----------------------------------------------------------------------------------------------------------------------------*
				tw kdensity _pscore if treated == 1  [aw = _weight],  lw(1.5) lp(dash) color(cranberry) 			///
				///
				|| kdensity _pscore if treated == 0  [aw = _weight],  lw(thick) lp(dash) color(gs12) 				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
				ylabel(, labsize(small) nogrid angle(horizontal) format(%2.1fc)) 									///
				xlabel(, labsize(small) gmax angle(horizontal)) 													///
				ytitle("Number of firms", size(medsmall))			 												///
				xtitle("Probability of getting KCGF", size(large)) 													///
				title("", pos(12) size(medsmall)) 																	///
				subtitle(, pos(12) size(medsmall)) 																	///
				ysize(5) xsize(7) 																					///
				legend(order(1 "Treated" 2 "Comparison") pos(12) region(lstyle(none) fcolor(none)) size(large))  	///
				note("", color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/matching_`model'`comparison'.png", as(png) replace
			}	

			
			**
			*2* Checking the parallel trends on the matched sample 
			*--------------------------------------------------------------------------------------------------------------------------------*
			*****----------------------->>>>
			{
			***ATTENTION
			foreach main_dataset in 0 1 {
				
				 use "$data\final\firm_year_level.dta", clear
					
					if `main_dataset' == 1 keep if main_dataset == 1
					
					*------------------------------------------------------------------------------------------------------------------------*
						
					merge m:1 fuid using `matched_comparison`comparison'', keep(3) nogen keepusing(_weight _weight2 treated)		//keeping only the firms on the commum support
			
					**
					**
					replace productivity_r 	= productivity_r/1000
					replace turnover_r 		= turnover_r/1000
						
					**
					**
					*Mean and 95% CI
					*-------------------------------------------------------------------------------------------------------------------------*
					matrix results1 = (0,0,0,0,0)
					matrix results2 = (0,0,0,0,0)
					matrix results3 = (0,0,0,0,0)

					foreach type_firm_2015 in `comparison' 2 {
						forvalues period = 2010(1)2018 {
							ci means 	turnover_r 		[aw =_weight] if period == `period' & type_firm_after2015 == `type_firm_2015'
							matrix 		results1 = results1 \ (`period', `type_firm_2015',r(mean), r(lb), r(ub))
							ci means 	productivity_r  [aw =_weight] if period == `period' & type_firm_after2015 == `type_firm_2015'
							matrix 		results2 = results2 \ (`period', `type_firm_2015',r(mean), r(lb), r(ub))		
							ci means 	employees 		[aw =_weight] if period == `period' & type_firm_after2015 == `type_firm_2015'
							matrix		results3 = results3 \ (`period', `type_firm_2015',r(mean), r(lb), r(ub))
						}
					}
					*-------------------------------------------------------------------------------------------------------------------------*

					
					*-------------------------------------------------------------------------------------------------------------------------*
					foreach variable in 1 2 3 {
						clear 
						svmat results`variable'
						drop in 1
						if `variable' == 1 rename (results11-results15)  (period type_firm_after2015 turnover_r 			lturnover_r  		uturnover_r )
						if `variable' == 2 rename (results21-results25)  (period type_firm_after2015 productivity_r 		lproductivity_r 	uproductivity_r)
						if `variable' == 3 rename (results31-results35)  (period type_firm_after2015 employees 			lemployees 			uemployees)
						tempfile  `variable'
						save 	 ``variable'', replace
					}
					*-------------------------------------------------------------------------------------------------------------------------*
					
					**
					**
					*-------------------------------------------------------------------------------------------------------------------------*
					use `1', clear
						merge 1:1 period type_firm_after2015 using `2', nogen
						merge 1:1 period type_firm_after2015 using `3', nogen
					*-------------------------------------------------------------------------------------------------------------------------*
					
					
					**			
					**	
					*-------------------------------------------------------------------------------------------------------------------------*
					foreach var of varlist turnover_r productivity_r employees {
								
						if "`var'" == "productivity_r" {
							local min = 10
							local inter = 10
							local max = 40
							local ytitle "Sales per employee, thousands 2021 EUR"
						}
						if "`var'" == "turnover_r" {
							local min = 40
							local inter = 20
							local max = 160
							local ytitle "Average sales, thousands 2021 EUR"

						}
						if "`var'" == "employees" {
							local min = 2
							local inter = 1
							local max = 6
							local ytitle "N. employees"
						}
								
							tw 	///
							(rarea l`var' u`var' period if type_firm_after2015 == 2, fcolor(cranberry%30) lcolor(bg) fintensity(50)) ///
							(line `var'  period if type_firm_after2015 == 2,   lcolor(cranberry) lwidth(0.5) lp(shortdash)) 	/// 
							(rarea l`var' u`var' period if type_firm_after2015 == `comparison', fcolor(gs12%30) lcolor(bg) fintensity(50)) ///
							(line `var'  period if  type_firm_after2015 == `comparison', lcolor(gs12) lwidth(0.5) lp(shortdash)  ///  			
							ylabel(, labsize(medium) nogrid gmax angle(horizontal) format(%12.0fc))  ///
							///
							ytitle("`ytitle'", size(medium))   ///
							///
							xtitle("",) ///
							///
							xlabel(2010(1)2018, angle(45) labsize(medium)) ///
							///
							title("`ytitle'", pos(12) size(medsmall) color(black)) ///
							///
							subtitle(, pos(12) size(medsmall) color(black)) ///
							///
							graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							///
							plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							///
							xline(2017, lp(shortdash) lcolor(red)) ///
							legend(order(1 "95% CI"  2 "Treated" 3 "95% CI" 4 "Comparison") region(lwidth(none)) cols(2) size(medium) position(12)) ///
							///
							ysize(5) xsize(6) ///
							///
							note("", color(black) fcolor(background) pos(7) size(small)))	
							graph export "$output/figures/trend_`main_dataset'_`model'_`comparison'_`var'.png", as(png) replace
						}
					}	
			}
		}
	}		
		

	/*	
	*C*
	*Probability of receiving the treatment versus firms' characteristics
	*________________________________________________________________________________________________________________________________________*
	{	
		
		matrix results = (0,0,0,0,0,0)
		
		foreach comparison in 0 1 {
			use "$data\inter\matching_models\matching_forest_`comparison'.dta", clear  
				local xvar = 1
				foreach variable in employees qua_productivity_r qua_turnover_r number_loans_up2015 {
					levelsof `variable', local(`variable'_list) 
					foreach code in ``variable'_list' {
						ci means xb if `variable' == `code'
						matrix results = results\(`xvar', `comparison', `code', r(mean), r(lb), r(ub))
					}
					local xvar = `xvar' + 1
				}
		}		
		
		clear 
		svmat results
		drop in 1
		rename (results1-results6) (variable comparison code xb lower upper)
				
		foreach variable in 1 2 3 4 {
	  		foreach comparison in 0 1  {
			     
				 
				if `variable' == 1   {
				local xtitle 	= "Number  of employees"
				local min 		= 0
				local inter 	= 0.03
				local max 		= 0.15
				}
				
				if `variable' == 2   {
				local xtitle = "Deciles of sales per employee"
				local min 		= 0
				local inter 	= 0.03
				local max 		= 0.12	
				}
				if `variable' == 3  {
				local xtitle = "Deciles of total sales"
				local min 		= 0
				local inter 	= 0.03
				local max 		= 0.15			
				}
				if `variable' == 4   {
				local xtitle = "Number of loans between 2010-2015"
				
					if `comparison' == 0 {
					local min 		= 0
					local inter 	= 0.10
					local max 		= 0.50	
					}
					if `comparison' == 1 {
					local min 		= 0
					local inter 	= 0.10
					local max 		=  0.50	
					}				
				}
				if `comparison' == 1 local title = "Other loans & KCGF loans"
				if `comparison' == 0 local title = "No loans & KCGF loans"	
				
				tw 	///
				(rarea lower upper 	code if variable == `variable' & comparison == `comparison', fcolor(gs12%30) lcolor(bg) fintensity(50)) ///
				(line  xb 			code if variable == `variable' & comparison == `comparison', lcolor(cranberry) lwidth(0.5) lp(shortdash)  ///  			
				ylabel(`min'(`inter')`max',  labsize(medium) nogrid gmax angle(horizontal) format(%12.3fc)) ysca()  ///
				///
				ytitle("Probability of treatment", size(medium))   ///
				///
				xtitle("`xtitle'", size(medium)) ///
				///
				xlabel(, angle(360) labsize(medium)) ///
				///
				title("`title'", pos(12) size(large) color(black)) ///
				///
				subtitle(, pos(12) size(medsmall) color(black)) ///
				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				legend(order(1 "95% CI"  2 "Probability of treatment" ) region(lwidth(none)) cols(1) size(medium) position(0) bplacement(seast)) ///
				///
				ysize(5) xsize(6) saving(a`variable'`comparison'.gph, replace)	 ///
				///
				note("", color(black) fcolor(background) pos(7) size(small))) 
			}
		}
			graph combine a10.gph a11.gph, xsize(10) ysize(5) title("Probability of treatment and number of employees", color(black)) graphregion(fcolor(white)) 
			graph export "$output\figures\psm versus employees.png", as(png) replace
			graph combine a20.gph a21.gph, xsize(10) ysize(5) title("Probability of treatment and deciles of sales per employee", color(black)) graphregion(fcolor(white)) 
			graph export "$output\figures\psm versus productivity.png", as(png) replace
			graph combine a30.gph a31.gph, xsize(10) ysize(5) title("Probability of treatment and deciles ot total sales", color(black)) graphregion(fcolor(white)) 
			graph export "$output\figures\psm versus sales.png", as(png) replace
			graph combine a40.gph a41.gph, xsize(10) ysize(5) title("Probability of treatment and number of loans between 2010-2015", color(black)) graphregion(fcolor(white)) 
			graph export "$output\figures\psm versus number of loans.png", as(png) replace
		}
		*/	
		
	
	
	*D*
	*Regressions
	*________________________________________________________________________________________________________________________________________*
	{	
			foreach variable in l_productivity_r l_turnover_r l_employees closed_definitely  {	 //productivity_r turnover_r employees		
				estimates clear	
				foreach comparison in 1 {  //0 1
					local nmodel = 1
					foreach model in ols lasso ridge forest xgboost vivian		 				{  //ols lasso ridge forest xgboost
				
						use "$data\final\firm_year_level.dta", clear
						replace closed_definitely = closed_definitely*100
							merge m:1 fuid using  "$data\inter\matching_models\matching_`model'_`comparison'.dta", keep(3) nogen keepusing(_weight _weight2 _support) 
							keep 		if _support == 1	& _weight  != .				
				
							foreach sample in 1 2 {  //1 2
								xtset fuid period
								preserve
								if 		`sample' == 1 keep if main_dataset == 1
							    eststo: xtreg 	`variable'  after_kcgf i.period  [aw = _weight], fe cluster(fuid)
								local  ATT  = el(r(table),1,1)																					//average treatment effect
								*eststo	 model`comparison'`nmodel'`sample'
								
								/*
								if "`variable'" != "inactive" & "`variable'" != "closed_definitely" {
								su 		`variable' 			if type_firm_after2015 == 2 		   & period == 2015
								}
								scalar 	 media			   = r(mean)
								estadd   scalar media      = media:     model`comparison'`nmodel'`sample'
								scalar 	 effect			   = `ATT'/media
								estadd   scalar effect     = effect: 	model`comparison'`nmodel'`sample'
								*/
								restore
							}	
						local nmodel = `nmodel' + 1	
					}
				}
				if "`variable'" == "l_productivity_r" {
					estout * using "$output/Tables.xls", keep(after*) cells(b(star fmt(2)) se(fmt(2)) ci(par fmt(1))) 	starlevels(* 0.10 ** 0.05 *** 0.01)  stats(N r2, fmt(%9.0g %9.3f) labels("N. obs" "R2" ))  replace
				}
				else{
					estout * using "$output/Tables.xls", keep(after*) cells(b(star fmt(2)) se(fmt(2)) ci(par fmt(1))) 	starlevels(* 0.10 ** 0.05 *** 0.01)  stats(N r2, fmt(%9.0g %9.3f) labels("N. obs" "R2" )) append
				}
			}
		}	
		
		
		
		
		
		 use "$data\final\firm_year_level.dta", clear
		
			su closed_definitely if period < 2016 & num_loans != 0, detail
		
		
				/*
		 use "$data\final\firm_year_level.dta", clear,

		

		

		
			use "$data\final\firm_year_level.dta" if period == 2015, clear
			
				merge m:1 fuid using  "$data\inter\matching_models\matching_forest_1.dta", keep(3) nogen keepusing(_weight _weight2 _support) 
					keep 		if _support == 1	& _weight  != .				

						
			iebaltab firms_age employees turnover_r  productivity_r wages_worker_r import_tx export_tx number_loans_up2015 had_loan_up2015 inactive willclose_after2015  [aw=_weight] , format(%12.0fc %12.2fc) grpvar(type_firm_after2015) save("$output/tables/Table1.xls") 	rowvarlabels replace 

		
		
		
		
		
			use "$data\final\firm_year_level.dta", clear
						
							merge m:1 fuid using  "$data\inter\matching_models\matching_ols_1.dta", keep(3) nogen keepusing(_weight _weight2 _support) 
							keep 		if _support == 1	& _weight  != .		
		
			eststo: xtreg employees  after_kcgf i.period  [aw = _weight] if main_dataset == 1, fe cluster(fuid)