

	*__________________________________________________________________________________________________________________________________________*

	**
	*IMPACT EVALUATION DATASET 
	
	
		/*
		
		The outliers in terms of duration and interest rates I excluded in the do file 2.Credit Registry & KCGF.
		
		Sales, salaries import amount, export amount 					- > I replaced by missing the bottom 5% or the top 95%
		
		Productivity and wages per employees	     					- > I replaced by missing the bottom 5% or the top 95%
		
		Average growth rate in employment, sales and sales per employee - > I replaced by missing the bottom 5% or the top 95%
		
		number_loans_up2015 and number_loans_up_t_minus1				- > I replaced by missing top 95% (a lot of firms have 0 loans, so it would not make sense to replace by missing the bottom 5%)
		
		
		*/

	
	*A*
	*Tax Registry and Credit Registry in kosovo
	*----------------------------------------------------------------------------------------------------------------------------------------->>
	{
		
		**
		*First year the firm got a loan
		*------------------------------------------------------------------------------------------------------------------------------------->>
			use "$data\inter\Credit Registry_firm-year-level.dta"   if period <= 2018, clear
				duplicates drop fuid, force			
				keep 			fuid first_*			//keep only the firm id and the first year the firm got a loan
				tempfile 		first_loan				//we need the first year to set up a variable that is equal to 1 for the treatment year and 
				save 		   `first_loan'				//for the years after that. 
		
		
		**
		*Credit Registry up to 2018
		*------------------------------------------------------------------------------------------------------------------------------------->>
			use  "$data\inter\Credit Registry_firm-year-level.dta"  if period <= 2018, clear
			drop first* 
				tempfile 		loans
				save 		   `loans'
			
			
		**
		*Merging Tax Registry and Credit Registry
		*------------------------------------------------------------------------------------------------------------------------------------->>
			use "$data\inter\Tax Registry.dta", clear   					//Turnover = 0 or missing, how to interpret?
				drop 		group_sme
				merge 		1:1 fuid period 	using  `loans', 
				
				**
				**
				gen 		 formal = _merge != 2							//firm only foud in credit data -> evidence of informality according to Blerta (Financial Private Sector Specialist WB).
				label define formal 0 "Informal" 1 "Formal"	
				label val 	 formal formal
				
				**
				replace 	num_loans 		= 0 if _merge == 1  			//if firm is only in the Tax Registry Data, the number of loans is 0
				replace 	num_loans_kcgf 	= 0 if _merge == 1				//if firm is only in the Tax Registry Data, the number of loans is 0		
				drop 		_merge	
				
				**
				merge 		m:1 fuid		  	using  `first_loan', nogen 	//identifying the year the firm got its first loan
				
				**When the tax registry does not have the firms' size, lets use the credit registry data. 
				replace 	sme 		= "a.1-9" 		if size_creditdata == 1 & sme == ""
				replace 	sme 		= "b.10-49" 	if size_creditdata == 2 & sme == ""
				replace 	sme 		= "c.50-249" 	if size_creditdata == 3 & sme == ""
				replace 	sme			= "d.250+"	 	if size_creditdata == 4 & sme == ""
				egen	 	group_sme 	= group(sme)
				replace  	group_sme 	= 5 			if group_sme == .
			}		
			                                                                                                                                                                                                                   

			
	*B*
	*Data Cleaning
	*----------------------------------------------------------------------------------------------------------------------------------------->>
	{			
				**
				**
				drop 		legalformid letype statusid
				order 		fuid period municipalityid
					
				**	
				*Economic sector of activitity
				*------------------------------------------------------------------------------------------------------------------------------>>
				drop 		sectionid
				egen 		sectionid = group(section)
				tab  		sectionid,    gen(sectionid)
				
				
				**
				*First and last year of the firm in the dataset, it will help to correct deathyear
				*------------------------------------------------------------------------------------------------------------------------------>>
				bys	 		fuid: egen fyear_main_dataset = min(period)												//first year of the firm in the panel
				bys 		fuid: egen lyear_main_dataset = max(period)												//last  year of the firm in the panel
				
				
				**
				**Firms that never registered sales 
				*------------------------------------------------------------------------------------------------------------------------------>>
				bys 		fuid: gen obs = _N
				gen 		nosales =  (turnover == 0 | turnover == .) & formal == 1
				bys 		fuid: egen total = sum(nosales)
				count 										if total == obs 	//all the years in the dataset, no sales registered
				sort 		fuid period
				br 			fuid period turnover obs total 	if total == obs	
				tab 		formal 							if total == obs		//all the firms in this situation are "formal"
				
					*Exclusions -> firms that have never registered any sales in the dataset 
					*------------------------------>>>>>
					*------------------------------>>>>>
					drop 									if total == obs		// firms that have never registered any turnover 
					drop 									   total    obs	nosales	//firms that in all the panel years turnover is always 0 or missing
					*------------------------------>>>>>
					*------------------------------>>>>>
				
				
				**
				*-> The variable deathyear come from the Tax Registry dataset. Adjusting variable deathyear as we identify several inconsistences
				*------------------------------------------------------------------------------------------------------------------------------>>
				
				**
				//for the same firm, some years deathyear != , and some years = ..If the firm has at least one year with deathyear !=. lets consider this year
				bys			fuid: egen 	A =      max(deathyear)
				replace 	deathyear = A 								if missing(deathyear)			
				drop 		A
				sort 		fuid period
				
				
				**
				//how can the year of closing be before the firm start to operate?
				count 							 						if deathyear < fyear_main_dataset 				//death year < first year firm in the panel 
				replace  	deathyear = .	 							if deathyear < fyear_main_dataset

				
				**
				//how the firm close in t if it has sales the year after ???
				br 			fuid period turnover deathyear 				if period > deathyear & !missing(deathyear) 
				bys 		fuid: egen A = max(period) 					if turnover != . & turnover!= 0			
				bys 		fuid: egen max_year_turn = max(A) 															//last year the firm registered sales
				gen		 	erro  = 1  					 				if  deathyear < max_year_turn					//the firm registered sales in a year after the deathyear, which is an evidence of error. 
				replace 	deathyear = . 			  				 	if erro == 1									//firms that had death rate but that are not closed. 
				drop 		A max_year_turn erro

				
				//firm is closed in tax registry but open in credit registry
				gen 		erro = 1 if formal == 0 & period > deathyear												//formal = 0 means that the firm is only in the credit registry data (so the firm has a loan)
				bys 		fuid: egen max_error = max(erro)
				replace 	deathyear = . if max_error == 1
				drop 		erro
				
				**
				//Defining death year for closed firms without this information, firms for which the last year in the panel < last year registed for firms in the tax registry.
				sort 		period 
				global 		lastyear = period[_N] 
				di 			$lastyear	//last year the firm is in the panel of tax registry
				sort 		fuid period
				br 			fuid period turnover lyear_main_dataset deathyear 	
				replace 	deathyear = period 									if period == lyear_main_dataset & lyear_main_dataset < $lastyear & deathyear == .
				bys			fuid:  egen A = max(deathyear)
				replace 	deathyear = A 										if missing(deathyear)
				drop 		A
				
				**ERRORR!!! 
				***----------------------------------------->>
				***----------------------------------------->>
				replace employees 	= . if employees == 0
					
					
				**
				*EUR 2021
				*---------------------------------------------------------------------------------------------------------------------------------->>
				local 		ppi2021 100
				local 		ppi2020 96.75858732
				local 		ppi2019 96.56545641
				local 		ppi2018 94.0450491
				local 		ppi2017 93.06783681
				local 		ppi2016 91.70148469
				local 		ppi2015 91.45455738
				local 		ppi2014 91.95109329
				local 		ppi2013 91.55739648
				local 		ppi2012 89.9650157
				local 		ppi2011 87.78787637
				local 		ppi2010 81.78486712
				keep if 	period >= 2010
				forvalues 	period  = 2010(1)2021 {
					foreach var of varlist turnover salaries exports_amount imports_amount {
						if `period' == 2010 gen 	`var'_r = (`var')/(`ppi`period''/100) if period == `period'
						if `period' != 2010 replace `var'_r = (`var')/(`ppi`period''/100) if period == `period'
					}
				}				
				drop turnover salaries exports_amount imports_amount
				
				
				**
				*Outliers by firms' size
				*------------------------------------------------------------------------------------------------------------------------------>>

				foreach var of varlist  turnover_r salaries_r exports_amount_r imports_amount_r  	{
					foreach sme in 1 2 3 4 5														{
							su 		`var' 		if group_sme == `sme', detail
							replace `var' = . 	if group_sme == `sme' & (`var' <= r(p10) | `var' >= r(p90))
					}
				}				
								
				**
				*Productivity -> sales per employee
				*---------------------------------------------------------------------------------------------------------------------------------->>
				gen 	productivity_r = turnover_r/employees 	//sales divided by the number of employees
				gen 	wages_worker_r = salaries_r/employees  	//total wages divided by the number of employees
				
				foreach var of varlist productivity_r wages_worker_r  {
					foreach sme in 1 2 3 4 5						  {
							su 		`var' 		if group_sme == `sme', detail
							replace `var' = . 	if group_sme == `sme' & (`var' < r(p5) | `var' > r(p95))
					}
				}				

				**
				**
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		main_dataset = 1			//firms either in tax registry or in credit data
				
				//we do not have a balance panel. if the firm closed in 2016, we will not have information for the firm in 2017/2018, etc.
				//we need to set up a balanced panel.
				
				
				**
				*Saving some important variables at firm level to merge with the balanced panel
				*------------------------------------------------------------------------------------------------------------------------------>>
				preserve
				duplicates drop fuid, force
				keep 			fuid birthyear birthyear_creditdata deathyear first* fyear_main_dataset lyear_main_dataset	
				tempfile 		data
				save  		   `data'
				restore
				drop 				 birthyear birthyear_creditdata deathyear first* fyear_main_dataset lyear_main_dataset	

				
				**
				**Balanced panel
				*------------------------------------------------------------------------------------------------------------------------------>>
				tsset fuid period
				tsfill, full											//filling the gaps. for ex, if the firm exited in 2016, adding 2017 and 2018. 
						
				merge 			m:1 fuid using `data', nogen				
				
				drop 								if period 		< 	fyear_main_dataset				//keeping only years after the first year the we saw the firm in the main dataset
				replace 		main_dataset = 0	if main_dataset == .								//main_dataset = 0, rows created to input 0 to num employees, productivity and sales for firms that closed
			
				label define 	main_dataset 	1 "Tax/Credit Registry" 0 "Created to add 0s to outcome variables of exited firms"
				label val 		main_dataset main_dataset
				
				//to have a better idea of the effect of the KCGF, we input zero values for the following variables for the years after the firm closed:
				*employees, productivity and turnover. If we dont do that, we underestimate the impact of the fund. 
			
			
				**
				*------------------------------------------------------------------------------------------------------------------------------>>
				sort 			fuid period
				br 				fuid period  main_dataset deathyear turnover* employees productivity_r
				
				foreach 	var of varlist sectionid sectionid1-sectionid21 divisionid activityid size size_creditdata municipalityid  ethnicity {
				replace `var' = `var'[_n-1] 	if main_dataset == 0 	& `var'[_n-1] != .  & fuid[_n] == fuid[_n-1]		//to run the regressions with the exited firms, we need the variables size, economic sector, and municipality to use as control. 
				}
				replace sme   =   sme[_n-1] 	if main_dataset == 0 	&   sme[_n-1] != "" & fuid[_n] == fuid[_n-1]		
					
				foreach var of varlist turnover_r employees productivity_r {												//replacing the vars with 0 for firms that closed. 
				replace `var' = 0				if main_dataset == 0
				}

				replace 	num_loans 		= 0 if main_dataset == 0
				replace 	num_loans_kcgf  = 0 if main_dataset == 0

					
				**
				*Identifying if the firm is active or inactive in that year
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		 active = (period <= deathyear | deathyear == . ) | formal == 0 	//informal = 1 means that the firm was only found in credit data
				replace 	 active = 0 if main_dataset == 0
				label define active 1 "Active firm in year t" 0 "Closed firm in year t"
				label val    active active
				gen 		 inactive = active == 0
				bys  		 fuid: egen a = min(period) if inactive == 1							//identifying if the company closed definitely
				bys  		 fuid: egen b = max(period) if   active == 1
				bys  		 fuid: egen min_inactive = min(a)
				bys  		 fuid: egen max_active   = max(b)
				gen 		 closed_definitely = min_inactive > max_active  & !missing(min_inactive) & !missing(max_active) & period >= min_inactive
				sort 		 fuid period
				br   		 fuid period main_dataset  deathyear  active  min_inactive max_active closed_definitely
				
							
				**
				*Lag values
				*------------------------------------------------------------------------------------------------------------------------------>>
				sort fuid period
				foreach var of varlist sme size wages_worker_r turnover_r productivity_r employees num_loans  {
					gen lag1_`var' = l1.`var'
					gen lag2_`var' = l2.`var'
					gen lag3_`var' = l3.`var'
					gen lag4_`var' = l4.`var'
					gen lag5_`var' = l5.`var'
					if "`var'" == "num_loans" {
					gen lag6_`var' = l6.`var'
					gen lag7_`var' = l7.`var'
					gen lag8_`var' = l8.`var'
					}
				}
				
				foreach var of varlist *num_loans* {
					replace `var' = 0 if missing(`var')
				}
				
				
				**
				*Treatment status
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		has_loan = loanamount != . & loanamount != 0
				gen 		has_kcgf = num_loans_kcgf 	   > 0  & !missing(num_loans_kcgf)
				gen 		no_loan	 = has_loan == 0 & has_kcgf == 0
				bys 		fuid: egen A = max(has_loan)
				bys 		fuid: egen B = max(has_kcgf )
				gen 		treated_loan = A == 1
				gen 		treated_kcgf = B == 1
				drop A B
				
				
				**
				*Dummy for after treatment 
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		after_loan 	 = period >= first_loan
				gen 		after_kcgf 	 = period >= first_kcgf

				
				**
				**Whether before 2016 (when KCGF was launched) the firm had access to the credit market
				*------------------------------------------------------------------------------------------------------------------------------>>
				
				//variables available only for 2015 (so we can check firms' access to the lending market before KCGF was created
				*had_loan_up2015, number_loans_up2015, didnothave_loan_up2015
				gen	 		had_loan_up2015 =  	    ((num_loans != 0 & !missing(num_loans)) 	   | ///
												(lag1_num_loans != 0 & !missing(lag1_num_loans))   | ///
												(lag2_num_loans != 0 & !missing(lag2_num_loans))   | ///
												(lag3_num_loans != 0 & !missing(lag3_num_loans))   | ///
												(lag4_num_loans != 0 & !missing(lag4_num_loans)))  	 & period == 2015 
				replace  				had_loan_up2015  		 = . 											if period != 2015	
				gen 	 				didnothave_loan_up2015 	 = 1 											if had_loan_up2015 == 0	
				replace  				didnothave_loan_up2015   = 0 											if had_loan_up2015 == 1						
				
				label 		define 		had_loan_up2015  0 "Firm without loan between before 2016" 1 "Firm with loan before 2016"		
				label 		val 		had_loan_up2015  had_loan_up2015
				
				
				egen 	 	number_loans_up2015 = rsum(*num_loans) 												if period == 2015
				
				foreach 	sme in 1 2 3 4 5						  {
				su	     	number_loans_up2015																	if group_sme == `sme' & period == 2015, detail
				replace  	number_loans_up2015 = . 															if group_sme == `sme' & period == 2015 & number_loans_up2015 > r(p95)
				}
			
			
				**
				**Number of loans until t-1 (in period t, lets check how many loans the firm have had up to t-1, a measure of credit history)
				*------------------------------------------------------------------------------------------------------------------------------>>
				egen 		number_loans_up_t_minus1 = rsum(lag1_num_loans lag2_num_loans lag3_num_loans lag4_num_loans lag5_num_loans lag6_num_loans lag7_num_loans lag8_num_loans)
				
				foreach 	sme in 1 2 3 4 5							  {
				su	     	number_loans_up_t_minus1					if group_sme == `sme', detail
				replace  	number_loans_up_t_minus1				=. 	if group_sme == `sme' & number_loans_up_t_minus1 > r(p95)
				}
		
				gen 		has_credit_history  = number_loans_up_t_minus1 > 0
				replace 	has_credit_history  = . 					if missing(number_loans_up_t_minus1)
				
				gen			nocredit_history 	= 1 					if has_credit_history 	== 0 
				replace 	nocredit_history 	= 0   					if has_credit_history 	== 1 

				
				**
				**Type of firm after 2015
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		A  =  1 if num_loans 		!= 0 & !missing(num_loans	  ) & period > 2015
				replace 	A  =  2 if num_loans_kcgf 	!= 0 & !missing(num_loans_kcgf) & period > 2015
				replace 	A  =  0 if num_loans		== 0 & period > 2015
				
				sort 	 	fuid period
				bys 	 	fuid: egen  type_firm_after2015 = max (A)
				br 		 	fuid main_dataset period num_loans* A type_firm_after2015
				drop 	 	A
				label	 	define  type_firm_after2015 0 "No loan (2016-2018)" 1 "Loan (2016-2018)" 2 "KCGF loan (2016-2018)" 
				label	 	val 	type_firm_after2015  type_firm_after2015 
				

				**
				**Type of firm panel
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		A  =  1 if num_loans 		!= 0 & !missing(num_loans	  )
				replace 	A  =  1 if num_loans_kcgf 	!= 0 & !missing(num_loans_kcgf) 
				replace 	A  =  0 if num_loans		== 0 
				
				sort 	 	fuid period
				bys 	 	fuid: egen  type_firm_panel = max (A)
				br 		 	fuid main_dataset period num_loans* A  type_firm_panel
				drop 		A
				label	 	define  type_firm_panel 0 "No loan 2010-2018" 1 "Loan 2010-2018"
				label	 	val 	type_firm_panel type_firm_panel 
				
				
				**
				**Firm closes after 2015, only available for 2015
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen					willclose_after2015 = deathyear   != . & deathyear > 2015
				replace 			willclose_after2015 = . 										if period != 2015
				gen 				notclose_after2015  = willclose_after2015  == 0
				replace 			notclose_after2015  = . 										if period != 2015
				label 		define  willclose_after2015 0 "Firm remains open (2016-2018)" 1 "Firm exited (2016-2018)" 
				label 		val		willclose_after2015 willclose_after2015
				 
				 
				*Firms with loans by formal
				*------------------------------------------------------------------------------------------------------------------------------>>
				gen 		has_loan_informal 	= has_loan == 1 & formal == 0
				gen 		has_kcgf_informal 	= has_kcgf == 1 & formal == 0
				gen 		no_loan_informal    = no_loan  == 1 & formal == 0
				
				
				*Squared values
				*------------------------------------------------------------------------------------------------------------------------------>>
				global 		covars firms_age  productivity_r wages_worker_r employees lag* num_loans number_loans_up2015 number_loans_up_t_minus1
				foreach 	var of varlist $covars {
					gen 	sq_`var' = `var'^2 
				}
				

				*Quantiles productivity
				*------------------------------------------------------------------------------------------------------------------------------>>
				
				forvalues 	period = 2010(1)2021 {
				cap noi quantiles productivity_r 		if period == `period' & active == 1 ,  n(10) gencatvar(qua_productivity_r`period')
				cap noi quantiles turnover_r 		 	if period == `period' & active == 1 ,  n(10) gencatvar(qua_turnover_r`period')
				cap noi quantiles wages_worker_r	 	if period == `period' & active == 1 ,  n(10) gencatvar(qua_wages_worker_r`period')
				cap noi quantiles avgrowth_turnover_r   if period == `period' & active == 1 ,  n(10) gencatvar(qua_avgrowth_turnover_r`period')
				}
								
				*Average growth in the last years
				*------------------------------------------------------------------------------------------------------------------------------>>
					
				sort fuid period
				foreach 	var of varlist productivity_r employees turnover_r {
				gen			avgrowth_`var' = ((`var'/lag1_`var') - 1)*100  if main_dataset == 1
				su 			avgrowth_`var', detail
				replace 	avgrowth_`var' = . if avgrowth_`var' <= r(p10) | avgrowth_`var' >= r(p90)
				}
							
				gen 	lag1_avgrowth_productivity_r = l1.avgrowth_productivity_r
				gen 	lag1_avgrowth_employees		 = l1.avgrowth_employees
				gen 	lag1_avgrowth_turnover_r 	 = l1.avgrowth_turnover_r
				
				**
				*Labels
				*------------------------------------------------------------------------------------------------------------------------------>>
				label 		var firms_age					"Firms' age'"
				label 		var employees					"Num. employees"
				label 		var turnover_r					"Sales, 2021 EUR"
				label 		var productivity_r				"Productivity, 2021 EUR"
				label 		var wages_worker_r				"Average wage, 2021 EUR"
				label 		var import_tx					"Firm imports"
				label 		var export_tx					"Firm exports"
				label 		var number_loans_up2015			"Num. loans 2010-2015"
				label 		var nocredit_history			"No credit history"
				label 		var willclose_after2015			"Stopped operating after 2015"
				label 		var duration					"Loan duration"
				label		var irate_nominal				"Nominal interest rate"
				label 		var had_loan_up2015				"Firm access to credit 2010-2015"
				label 		var avgrowth_productivity_r		"Annual average growth in productivity, %"
				label 		var avgrowth_employees			"Annual average growth in employment, %"
				label 		var avgrowth_turnover_r			"Annual average growth in sales, %"
				
				gen 		nonmissing = 1 if turnover_r != . & productivity_r != . & employees != .
				**
				**
				sort 		fuid period
				*compress
				save 			"$data\final\firm_year_level.dta", replace
		}		

