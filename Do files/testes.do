		
		
			use "$data\final\firm_year_level.dta" if main_dataset == 1 , clear
	
			
			matrix results = (0,0,0,0,0)
			foreach type_firm_2015 in 0 1 2 {
				forvalues period = 2010(1)2018 {
				ci means turnover_r if period == `period' & type_firm_2015 == `type_firm_2015'
				di `mean'
				matrix rx`esults = results \ (`period', `type_firm_2015',r(mean), r(lb), r(ub))
				}
			}
			clear 
			svmat results
			drop in 1
			
			rename (results1-results5)  (period type_firm_2015 turnover_r lower upper)
			
			foreach var of varlist turnover_r  {
					    
				if "`var'" == "productivity" {
					local min = 10
					local inter = 10
					local max = 40
					local ytitle "Sales per employee, thousands  2018 EUR"
				}
					if "`var'" == "turnover_r" {
					    local min = 40
						local inter = 20
						local max = 160
						local ytitle "Average sales, thousands 2018 EUR"

					}
					if "`var'" == "employees" {
					    local min = 2
						local inter = 1
						local max = 6
						local ytitle "N. employees"
					}
						
					tw 	///
					(rarea lower upper period if type_firm_2015 == 1, fcolor(cranberry) lcolor(cranberry) fintensity(50)) ///
					(line `var'  period if type_firm_2015 == 1,   lcolor(cranberry) lwidth(0.5) lp(shortdash)) 	///  
					(line `var'  period if  type_firm_2015 == 0 , lcolor(navy) lwidth(0.5) lp(solid)  ///  			
					ylabel(, labsize(medium) nogrid gmax angle(horizontal) format(%12.0fc)) yscale(alt) ///
					///
					ytitle("`ytitle'", size(medium))   ///
					///
					xtitle("",) ///
					///
					xlabel(2010(1)2018, labsize(medium)) ///
					///
					title(, pos(12) size(medsmall) color(black)) ///
					///
					subtitle(, pos(12) size(medsmall) color(black)) ///
					///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
					///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
					///
					legend(order(1 ""  2 "Comparison" 3 "" 4 "KCGF") region(lwidth(none)) cols(2) size(medium) position(12)) ///
					///
					ysize(5) xsize(5) ///
					///
					note("", color(black) fcolor(background) pos(7) size(small)))	
					graph export "$output/figures/timetrend`var'_matching`comparison'.pdf", as(pdf) replace
					}


				foreach variable in 2{
						foreach comparison in 0 1 {
						twoway 	scatter xb employees  if variable == `variable' & comparison == `comparison',  msymbol(O) msize(medium) color(cranberry)	 ///
						|| rcap lower upper employees if variable == `variable' & comparison == `comparison' , lcolor(navy)  lwidth(medthick)					 ///
						xtitle("`xtitle'", size(small)) xlabel(, labsize(large))										  									 ///
						ytitle("Probability of treatment", size(medium)) ylabel(, nogrid labsize(large) gmax angle(horizontal) format (%4.3fc))  												///					
						title(, size(large) color(black)) 																																		///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
						legend(order(1 "Probability of treatment" 2 "95% CI" ) pos(12) cols(2) region(lstyle(none) fcolor(none)) size(large)) 	  														///
						ysize(4) xsize(6)  	saving(a`comparison'`variable'.gph, replace)
						}
				}
			
		
		
		
		
		
		
					**
			*1* PSM
			*--------------------------------------------------------------------------------------------------------------------------------*
			use "$data\final\firm_year_level.dta"  , clear
			*--------------------------------------------------------------------------------------------------------------------------------*
				
				**
				**
				*----------------------------------------------------------------------------------------------------------------------------*
				keep 	if main_dataset == 1   & period == 2015 & active == 1
				keep 	if inlist(size, 1,2,3) | (size == .     & (inlist(size_creditdata, 1,2,3)))
				keep 	if inlist(type_firm_2015,0, 2) 
				*----------------------------------------------------------------------------------------------------------------------------*

				**
				*Treatment status
				*----------------------------------------------------------------------------------------------------------------------------*
				gen 	treated = 1 if type_firm_2015 == 2
				replace treated = 0 if type_firm_2015 == 0
				*----------------------------------------------------------------------------------------------------------------------------*
					
				**
				*Matching
				*----------------------------------------------------------------------------------------------------------------------------*
				psmatch2 treated $controls0_ols		, n(3) common ties
				probit treated $controls0_ols
				return list 
				predict xb,
				
				ci means xb
			
		
						keep 		if _support == 1						
				keep 		if _weight != .
				gen 		_weight2 = _pscore/(1-_pscore) 	if  _treated == 0
				replace 	_weight2 = 1 					if 	_treated == 1
		
		
		
				probit treated $controls0_ols
				return list 
				predict xb2
				
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		use "$data\final\firm_year_level.dta" 	 if main_dataset == 1 & period == 2015 & active == 1  , clear
						
											keep if inlist(size, 1,2,3) | (size == . & (inlist(size_creditdata, 1,2,3)))
											
		tab type_firm_2015									
		
		
		

		global covars firms_age sq_firms_age  export_tx import_tx employees sq_employees lag1_employees sq_lag1_employees ///
							productivity_r sq_productivity lag1_productivity_r sq_lag1_productivity_r		///
							wages_worker_r sq_wages_worker_r lag1_wages_worker_r sq_lag1_wages_worker_r		///
							num_loans lag1_num_loans lag2_num_loans lag3_num_loans lag4_num_loans lag5_num_loans sq_lag1_num_loans sq_lag2_num_loans sq_lag3_num_loans sq_lag4_num_loans sq_lag5_num_loans ///
							sectionid 
			br fuid $covars
			
		local totalvars = 0
			
		foreach var of varlist $covars {
		    
			local totalvars = `totalvars' + 1
			
		}

		di `totalvars'
		
		
		tab type_firm_2015
		
		global covarstest0 firms_age export_tx import_tx productivity wages_worker_r employees	num_loans				///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	
									
		
		global covarstest1 firms_age export_tx import_tx productivity wages_worker_r employees num_loans							///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	///
								lag1*  																					///
								sq_lag1*	
								
		global covarstest2 firms_age export_tx import_tx productivity wages_worker_r employees	num_loans						///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	///
								lag1*  lag2*  																					///
								sq_lag1* sq_lag2*																				
			
		global covarstest3 firms_age export_tx import_tx productivity wages_worker_r employees	num_loans						///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	///
								lag1*  lag2*   lag3*  																					///
								sq_lag1* sq_lag2*	 sq_lag3*																				
			
		global covarstest4 firms_age export_tx import_tx productivity wages_worker_r employees num_loans							///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	///
								lag1*  lag2*   lag3*  lag4*  																					///
								sq_lag1* sq_lag2*	 sq_lag3* sq_lag4*																				
			

		global covarstest5 firms_age export_tx import_tx productivity wages_worker_r employees	num_loans						///
								sq_firms_age sq_export_tx sq_import_tx sq_productivity sq_wages_worker_r sq_employees	///
								lag1*  lag2*   lag3*  lag4*  lag5*  																					///
								sq_lag1* sq_lag2*	 sq_lag3* sq_lag4*	 sq_lag5*																				
								
			
		
		gen nomissings = 0
		gen totalvars = 0
		foreach var of varlist $covars {
				replace totalvars = totalvars + 1
				replace nomissings = nomissings+1 if !missing(`var')
		}
		*br fuid type_firm_2015 totalvars nomissings 
        tab  type_firm_2015 if totalvars == nomissings
		tab  totalvars
		
		
		
		

							/*			
					preserve
						keep if _treated == 1
						keep _n1 _n2 _n3  treated 
						
						mkmat _n1, matrix(A)
						mkmat _n2, matrix(B)
						mkmat _n3, matrix(C)
						
						matrix _id = (A \ B \ C)
						clear
						svmat _id
						rename _id1 _id
						
						duplicates drop
						tempfile id
						save `id'
					restore
					
					preserve
					merge 1:1 _id using `id', keep(3) nogen
					keep fuid treated _weight2 _weight _pscore
					tempfile id 
					save `id'
					restore
					
					keep if _treated == 1
					gen base = 1
					keep fuid treated _weight2 _weight _pscore
					append using `id'
					*/
					
					
					
					
					
					tw 	///
					(rarea lturnover_r uturnover_r period if type_firm_2015 == 2, fcolor(cranberry) lcolor(cranberry) fintensity(50)) ///
					(line turnover_r  period if type_firm_2015 == 2,   lcolor(cranberry) lwidth(0.5) lp(shortdash)) 	/// 
					(rarea lturnover_r uturnover_r period if type_firm_2015 == 0, fcolor(navy) lcolor(navy) fintensity(50)) ///
					(line turnover_r period if  type_firm_2015 == 0, lcolor(navy) lwidth(0.5) lp(solid)  ///  			
					ylabel(, labsize(medium) nogrid gmax angle(horizontal) format(%12.0fc)) yscale(alt) ///
					///
					ytitle("`ytitle'", size(medium))   ///
					///
					xtitle("",) ///
					///
					xlabel(2010(1)2018, labsize(medium)) ///
					///
					title(, pos(12) size(medsmall) color(black)) ///
					///
					subtitle(, pos(12) size(medsmall) color(black)) ///
					///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
					///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
					///
					legend(order(1 "95% CI"  2 "Treated" 3 "95% CI" "" 4 "Comparison") region(lwidth(none)) cols(2) size(medium) position(12)) ///
					///
					ysize(5) xsize(5) ///
					///
					note("", color(black) fcolor(background) pos(7) size(small)))	
					graph export "$output/figures/timetrend`var'_matching`comparison'.pdf", as(pdf) replace				
					
					
					
					
					
					
					
					
					
					
					
					
					