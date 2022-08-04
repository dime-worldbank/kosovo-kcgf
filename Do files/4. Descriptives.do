


	*--------------------------------------------------------->>>
	**
	*Statistics for blogpost
	
		use "$data\final\firm_year_level.dta" if period == 2015 & active == 1, clear
		
		**
		*% of firms with access to credit
		bys sme: su has_loan										
		su  has_loan 					if inlist(sme, "c.50-249", "d.250+")		//medium and large firms with loans. 
		
		
		**
		*Percentage of these active firms that ended up stopping their operations after 2015
		bys sme: su willclose_after2015 
		su  willclose_after2015  		if size == 3 | size == 4, detail
		
		
		**
		*For firms with no loans in 2015, what is the percentage of them that had access to the lending market between 2010 and 2014?
		su 	had_loan_up2015 			if has_loan == 0 			
		
		
		**
		*Loan Interast rates according to firms' size
		bys size: su irate_nominal 		if irate_nominal >0,detail
		su irate_nominal 				if irate_nominal >0 & inlist(size, 3, 4),detail
		
		
		**
		*Loan duration according to firms size. 
		bys size: su duration 			if irate_nominal >0,detail
		su irate_nominal 				if duration  	 >0 & inlist(size, 3, 4),detail
		

		**
		*Productivity 
		bys sme: su productivity_r,detail
	*________________________________________________________________________________________________________________________________*
		
		
		
		
	*--------------------------------------------------------->>>
	**
	*What are the determinants of a firm having access to credit_treatment_status
	{
		use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018, clear
		
		**
		reg 		has_loan 	 number_loans_last5years    												///
					productivity_r  lag1_productivity 	sq_productivity_r 									///
					employees sq_employees																	///									
					export_tx import_tx sq_number_loans_last5years wages_worker_r sq_wages_worker_r lag1_wages_worker_r		
		predict  xb 			//probability of treatment according to the model
		drop if employee > 30

		**
		matrix results = (0,0,0,0,0)
		local xvar = 1
		foreach variable in employees qua_productivity_r2018 qua_turnover_r2018 number_loans_last5years {
			levelsof `variable', local(`variable'_list) 
			foreach code in ``variable'_list' {
				ci means xb if `variable' == `code'
				matrix results = results\(`xvar', `code', r(mean), r(lb), r(ub))
			}
			local xvar = `xvar' + 1
			di as red "`xvar''"
		}

		
		**	
		**
		clear 
		svmat results
		drop in 1
		rename (results1-results5) (variable code xb lower upper)	
		keep if xb >= 0 & xb <= 1

		**
		**
		foreach variable in 1 2 3 4  {
			     
				if `variable' == 1   {
				local xtitle 	= "Number  of employees (2018)"
				*local title		"Probability of having a loan versus num. employees"
				}
				if `variable' == 2   {
				local xtitle = "Deciles of sales per employee (2018)"
				*local title		"Probability of having a loan versus sales per employee"
				}
				if `variable' == 3  {
				local xtitle = "Deciles of total sales (2018)"	
				*local title		"Probability of having a loan versus total sales"
				}
				if `variable' == 4   {
				local xtitle = "Number loans in the last 5 years (2018)"		
				*local title		"Probability of having a loan versus credit history"
				}
				
				tw 	///
				(rarea lower upper 	code if variable == `variable' , fcolor(gs12%30) lcolor(bg) fintensity(50)) ///
				(line  xb 			code if variable == `variable' , lcolor(cranberry) lwidth(0.5) lp(shortdash)  ///  			
				ylabel(,  labsize(medium) nogrid gmax angle(horizontal) format(%12.3fc)) ysca()  ///
				///
				ytitle("Probability of loan", size(medium))   ///
				///
				xtitle("`xtitle'", size(medium)) ///
				///
				xlabel(, angle(360) labsize(medium)) ///
				///
				title("`title'", pos(12) size(medlarge) color(black)) ///
				///
				subtitle(, pos(12) size(medsmall) color(black)) ///
				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				legend(order(1 "95% CI"  2 "Probability of loan in 2018" ) region(lwidth(none)) cols(1) size(medium) position(0) bplacement(seast)) ///
				///
				ysize(5) xsize(7)	 ///
				///
				note("", color(black) fcolor(background) pos(7) size(small))) 
				graph export "$output/figures/probability_`variable'.pdf", replace
				}
		}
	*________________________________________________________________________________________________________________________________*
		
		
		
	*--------------------------------------------------------->>>
	**
	*Comparing firms with access to credit and firms without access to credit (2018)

		use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018 & main_dataset == 1, clear		
		tab sme if type_firm_panel == 0			//more than 98% of the firms that did not have access to credit between 2010-2018 are micro-firms. 
		
		
		keep if inlist(sme, "a.1-9") 
		
		keep if type_firm_panel == 0 | (type_firm_panel == 1 & has_loan == 1)
		
		replace export_tx = export_tx*100
		replace import_tx = import_tx*100
		replace has_credit_history = has_credit_history*100
			
		eststo clear
		bys  type_firm_panel: eststo:  estpost sum employees turnover_r productivity_r wages_worker_r export_tx import_tx firms_age has_credit_history 
		esttab using "$output/tables/Firms' characteristics_with and without credit.csv", replace  cells("mean sd min max") nodepvar    

		foreach var of varlist avgrowth_turnover_r avgrowth_productivity_r { 
			
			if "`var'" == "avgrowth_turnover_r" {
				local xtitle = "Annual growth sales"
				local color olive_teal
			}
			
			if "`var'" == "avgrowth_productivity_r" {
				local xtitle = "Annual growth sales per employee"
				local color orange*0.8
			}	
				
			tw (histogram `var' if type_firm_panel == 0 ,  percent color(`color') fintensity(50))  (histogram `var'  if type_firm_panel == 1 ,  percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "Credit constrained firms" 2 "Firms with loans approved") pos(12) size(medium) cols(1) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 ///
			xtitle("`xtitle'", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 				 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(6) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output/figures/g_`var'.pdf", as (pdf) replace
		}
	*________________________________________________________________________________________________________________________________*
		
		
	
		
	*--------------------------------------------------------->>>
	**
	*Probability of getting  a loan in 2018 based on observable characteristics

	use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018, clear

		keep if inlist(sme, "a.1-9") 
		
		keep if type_firm_panel == 0 | (type_firm_panel == 1 & has_loan == 1)

		
		psmatch2 has_loan i.group_sme i.municipality i.sectionid productivity_r employees avgrowth_productivity_r avgrowth_employees,  n(3) common ties	
		
		*----------------------------------------------------------------------------------------------------------------------------*
		keep 		if _support == 1	& _weight  != .	
				

				**
				*Kernel Density
				*----------------------------------------------------------------------------------------------------------------------------*
				tw kdensity _pscore if has_loan == 1  [aw = _weight],  lw(1.5) lp(dash) color(cranberry) 			///
				///
				|| kdensity _pscore if has_loan == 0  [aw = _weight],  lw(thick) lp(dash) color(gs12) 				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
				ylabel(, labsize(small) nogrid angle(horizontal) format(%2.1fc)) 									///
				xlabel(, labsize(small) gmax angle(horizontal)) 													///
				ytitle("Number of firms", size(medsmall))			 												///
				xtitle("Probability of getting a loan", size(large)) 													///
				title("", pos(12) size(medsmall)) 																	///
				subtitle(, pos(12) size(medsmall)) 																	///
				ysize(5) xsize(7) 																					///
				legend(order(1 "Firms with loans approved" 2 "Credit constrained firms") pos(12) region(lstyle(none) fcolor(none)) size(medium))  	///
				note("", color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/probability_loan.pdf", as(pdf) replace

		
		
		
	*--------------------------------------------------------->>>
	**
	*Statistics for Access to Finance Document
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & active == 1, clear
			recode group_sme ( 3 4 = 3), gen(size_firm)			//medium and large firms together 
			
			**
			replace willclose_after2015 = willclose_after2015*100
			replace had_loan_up2015     = had_loan_up2015*100
			replace irate_nominal 		= .   if irate_nominal 		== 0
			replace duration 	  		= .   if duration 	    	== 0
			replace employees 			= .   if employees 			== 0
			gen		nocredit_history 	= 100 if had_loan_up2015 	== 0   & has_loan == 0
			replace nocredit_history 	= 0   if had_loan_up2015 	== 100 & has_loan == 0
			replace turnover_r 			= turnover_r/1000
			replace productivity_r 		= productivity_r/1000
			
			**
			tabform  turnover_r employees productivity_r willclose_after2015 nocredit_history duration irate_nominal ///
			using "$output\tables\Statists2015_Access to Finance.xls", by(size_firm) sd sdbracket
	}
	*________________________________________________________________________________________________________________________________*
		
		
	
	
	*--------------------------------------------------------->>>
	**
	*type_firm_after2015
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49"), clear
			
			gen micro =  sme == "a.1-9" 
			gen small =  sme == "b.10-49"
			
			gen productivity_micro 	= productivity_r 	if micro == 1
			gen turnover_micro 		= turnover_r 		if micro == 1
			gen productivity_small 	= productivity_r 	if small == 1
			gen turnover_small		= turnover_r 		if small == 1
		
			
			**
			replace willclose_after2015 = willclose_after2015*100
			replace had_loan_up2015     = had_loan_up2015*100
			replace irate_nominal 		= .   if irate_nominal 		== 0
			replace duration 	  		= .   if duration 	    	== 0
			replace employees 			= .   if employees 			== 0
			gen		nocredit_history 	= 100 if had_loan_up2015 	== 0   & has_loan == 0
			replace nocredit_history 	= 0   if had_loan_up2015 	== 100 & has_loan == 0
			replace turnover_r 			= turnover_r/1000
			replace productivity_r 		= productivity_r/1000
			replace import_tx 			= import_tx*100
			replace export_tx 			= export_tx*100
			replace micro 				= micro*100
		
			tabform  firms_age employees micro turnover_micro turnover_small productivity_micro productivity_small wages_worker_r import_tx export_tx had_loan_up2015 willclose_after2015 ///
			using "$output\tables\firms' characteristics by status 2016-2018.xls", vertical by(type_firm_after2015) sd sdbracket nototal

		
		

			
			
	}
	*________________________________________________________________________________________________________________________________*
		
	
		
		
		
		
	*--------------------------------------------------------->>>
	**
	**
	*Firms size, according to Tax Registry. Lots of missings, undereporting might be a problem
	*________________________________________________________________________________________________________________________________*
	{		// 70\% of firms in Kosovo are micro
		
		**
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 		"$data\final\firm_year_level.dta" if inlist(period, 2018,2017) & active == 1, clear
		*----------------------------------------------------------------------------------------------------------------------------*
		
		**
		**
		gen 		id = 1
		replace 	size = 5 if size == .
		graph pie id, over(size) plabel(_all percent, gap(-10) format(%2.1fc) size(medsmall)) 		//% of firms by size (micro, small, medium ad large)									

		**
		**
		replace 	employees = 20  if employees >  20  & employees < 50 
		replace 	employees = 21  if employees >= 50  & employees < 250
		replace 	employees = 22  if employees > 250  & employees != .
		replace 	employees = 23  if employees == .
		label 		define employees 20 "20-49" 21 "50-249" 22 "250+" 23 "N/A"
		label 		val employees employees
	
		**
		**
		collapse 	(sum)id, by(employees)
		egen 		total 	= sum(id)
		gen 		share 	= (id/total)*100
		gen 		shareNA = share 			if employees == 23
		replace 	share 	= .  				if employees == 23

		**
		**
		graph bar (asis)share shareNA ,  bar(1, color(navy) fintensity(inten50)) bar(2, color(gs18) fintensity(inten70)) 				///
		over(emplo, sort() label(labsize(medium) angle(90))) stack 																		///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   						///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc) )  					///
			yscale(line ) 																												///
			legend(order(1  "With number of employees in Tax Registry"  2 "Missing"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(large) position(12)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 ///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 ///
			text(10 50  "70% micro, 6.8% small, 1% medium, 0.2% large, 22% N/A", size(medsmall)) ///
			ysize(6) xsize(10) 																					
			graph export "$output\figures\share firms by employees.pdf", as(pdf) replace				
	}
			
		
		
		
	*--------------------------------------------------------->>>
	**
	**
	*Share of firms with loans by number of employees
	*________________________________________________________________________________________________________________________________*
	{		//the bigger the firm, the higher the % with loans
		**
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2015,2017, 2018) , clear
		*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			**
			gen 		id = 1 
			gen 		has_otherloan 	= 1   if has_kcgf == 0     & has_loan  == 1
			replace 	employees 		= 0   if sme == "a.1-9"    & employees == .
			replace 	employees 		= 20  if  employees >  20  & employees < 50 
			replace 	employees 		= 21  if (employees >= 50  & employees < 250) | sme == "c.50-249"
			replace 	employees 		= 22  if (employees > 250  & employees != . ) | sme == "d.250+"
			label 		define employees 0 "0 or N/A" 20 "20-49" 21 "50-249" 22 "250+" 
			label 		val employees employees
			
			replace period = 2017 if period == 2018
			**
			**
			collapse (sum) has_kcgf  id has_otherloan, by(employees period)
			gen 		share_kcgf  = (has_kcgf/ id)*100
			gen 		share_loans = (has_otherloan/ id)*100
			
			**
			**
			graph bar (asis)share_kcgf share_loans if inlist(period,2017),  bar(1, color(navy) fintensity(inten30)) bar(2, color(cranberry) fintensity(inten30)) 		///
			 over(emplo, sort() label(labsize(medium) angle(45)) ) stack 																		///
			blabel(bar, position(outside) orientation(horizontal) size(large) color(black) format (%4.0fc))   								 	///
			ytitle("% firms with loans", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   ///
			yscale(line ) ///
			legend(order(1  "KCGF"  2 "Other loans"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(large) position(12)) 		///	
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			ysize(6) xsize(10) 																						
			graph export "$output\figures\share with loans by employees.pdf", as(pdf) replace	
			
			**
			**
			graph bar (asis)share_loans if inlist(period, 2015),   bar(1, color(cranberry) fintensity(inten30)) 		///
			 over(emplo, sort() label(labsize(medium) angle(45)) ) stack 																		///
			blabel(bar, position(outside) orientation(horizontal) size(large) color(black) format (%4.0fc))   								 	///
			ytitle("% firms with loans", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   ///
			yscale(line ) ///
			legend(off) 		///	
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			ysize(6) xsize(10) 																						
			graph export "$output\figures\share with loans by employees_2015.pdf", as(pdf) replace	
			
			
			
	}
	
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*Distribution of the number of employees among firms with access to credit, only MSME
	*________________________________________________________________________________________________________________________________*
	{	
		**
		**
		*KCGF Updated Dataset	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\KCGF.dta"  if LoanStatus != "Canceled" & inlist(size_kcgf, 1,2), clear
		*----------------------------------------------------------------------------------------------------------------------------*
			gen 	 has_kcgf = 1
			keep 	 has_kcgf size_kcgf employees group_period period turnover
			tab group_period	//1 from 2016-2019, 2 from 2020-2022, 3 Economic Recovery Package
			tempfile kcgf 
			save    `kcgf'
			
		
		**
		**
		*Tax Registry excluding KCGF (because it is not updated), 
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\final\firm_year_level.dta" if active == 1  & inlist(sme, "a.1-9", "b.10-49") , clear		
		*----------------------------------------------------------------------------------------------------------------------------*
		
			gen 	group_period = 4 if has_loan == 1	& has_kcgf == 0	//firms with loans
			replace group_period = 5 if has_loan == 0					//firms without loans
			append  using `kcgf'
			
			**
			*Average number of employees by type of firm
			bys group_period: su employees , detail
			
			keep  if inlist(period,2016,2018) //comparing firms size of firms with loans -> KCGF and other loans
			
			
			
			tw (histogram employees if group_period == 1, bin(15) percent color(emidblue) fintensity(50))  (histogram employees if group_period == 4 , bin(15) percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "KCGF" 2 "Other loans") pos(12) size(large) cols(3) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("%", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 	 ///
			xtitle("Number employees", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			text(10 28 "* Micro and small enterprises", size(small))		 			 ///
			text(35 28 "Median KCGF: 2 employees. 80% firms between 1 and 10", size(medium))		 			 ///
			text(25 28 "Median other loans: 3 employees. 80% firms between 1 and 16", size(medium)) 			 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(7) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output\figures\distribution of employees.pdf", as(pdf) replace		
			
	}	
	

	
	
	*--------------------------------------------------------->>>
	**
	**
	*When KCGF funds were signed
	*________________________________________________________________________________________________________________________________*
	{	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" if period > 2015 & LoanStatus != "Canceled", clear
		*----------------------------------------------------------------------------------------------------------------------------*

			gen id = 1
			
			collapse (sum)id  	disbursedamount_r, by(DisbursementMonthYear)
			su  				disbursedamount_r, detail
			
			replace  disbursedamount_r = disbursedamount_r/1000000
					
					twoway ///
					(bar disbursedamount_r DisbursementMonthYear		, barw(.5)  mlab() mlabpos(12) mlabcolor(black) lcolor(navy) lwidth(0.2) fcolor(gs14) fintensity(inten60) yaxis(2)) 			 ///
				|| (scatter id DisbursementMonthYear , symbol(O) color(cranberry*0.8) msize(medsmall) ml() mlabcolor(black) mlabposition(3) mlabsize(2) yaxis(1) 	 ///
					ysca(axis(1) r(0(50)150) line)   ylab(, nogrid	  angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 	 ///
					ysca(axis(2) r()  line)  ylab(,  nogrid   angle(horizontal) labsize(small) format(%4.0f) axis(2))		///
					xline()	///
					xsca() ///
					legend(order(1 "Disbursement" 2 "N. of KCGF loans"  ) cols(2) size(medium) region(lwidth(none) color(none)) pos(6))  /// 		
					title("", pos(12) size(medsmall) color(black)) 														///     
					ytitle("N. of KCGF loans", axis(1) size(medium) color(black))										/// 
					ytitle("Disbursements, million 2021 EUR", axis(2) size(medium) color(black)) 						///
					xtitle("", size(small))  																			///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					note("", span color(black) fcolor(background) pos(7) size(vsmall)))
					graph export "$output/figures/numberKcgfloans.pdf", as(pdf) replace	
	}

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Total amount of KCGF and non KCGF loans. Average loan, only MSME
	*________________________________________________________________________________________________________________________________*
	{	
		
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 					if period > 2015 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*----------------------------------------------------------------------------------------------------------------------------*
			su 			loanamount_r, detail
			replace 	loanamount_r = . 			if loanamount_r >= r(p95)
			gen 		fund = 1
			tempfile 	kcgf
			save 	   `kcgf'
		
		
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\Credit Registry.dta" 	if period > 2015 & fund != 1, clear												//non kcgf loans. Each row in this dataset is one contract. same firm can have several in the same year. 
		replace fund = 2 if fund == 3
		*----------------------------------------------------------------------------------------------------------------------------*
				
				**
				**Checking the firm sales to see if the approved amount is much more than the total sales (which indicates that something might be wrong)
				merge m:1 fuid period using "$data\final\firm_year_level.dta", keep (1 3) keepusing (turnover_r size sme) nogen
				
				**
				keep 	if (inlist(sme, "a.1-9", "b.10-49", "c.50-249") & period < 2019) | (period == 2019 & inlist(size_creditdata, 1,2,3)) //only MSME
				
				**
				*Ouliers in terms of approved amount divided by turnover. -> it does not make sense the company get a loan that might be more than 10 times their total sales 
				gen 	p = loanamount_r/turnover_r
				su  	p 										, detail //only for the non-covered loans, lets see the total amount of KCGF without excluding anything
				gen 	outlier = 1 							if p > r(p95) & p != .		   //excluding the percentile 95
				replace loanamount_r = . 						if outlier == 1
	
				**
				**Outliers in terms of amount
				su 		loanamount_r 							if outlier != 1, detail
				replace loanamount_r = . 						if outlier != 1 & (loanamount_r < r(p5) | loanamount_r >= r(p95))

				**
				**
				append using `kcgf'
				
				**
				**
				keep if period < 2019
				
				**
				**
				su loanamount_r if fund == 2, detail
				su loanamount_r if fund == 1, detail
				
				**
				*Distribution of loan amounts by fund
				twoway  (kdensity loanamount_r  			if fund == 1,   lcolor(cranberry) lwidth( thick ) )  													///	
						(kdensity loanamount_r 				if fund == 2,   lcolor(red) lwidth( thin)    															///
				title("", pos(12) size(medium) color(black))																										///
				subtitle("" , pos(12) size(medsmall) color(black))  																								///
				ylabel(, labsize(small) nogrid) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 													///
				yscale(alt) 																																		///
				xtitle("Loan amount, in 2021 EUR", size(medsmall) color(black)) ytitle("Density")  																	///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				ysize(5) xsize(7) 																																	///
				text(0.00002 120000   "10% of loans not covered by KCGF to MSME are > 54k EUR", size(medsmall)) ///
				fcolor(none) lcolor(black)), legend(order(1 "KCGF" 2 "Not covered by KCGF") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(12)) ///
				note(, span color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/loanamount_2016-2019.pdf", as(pdf) replace			
	}		

	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*KCGF total and other descriptives
	*________________________________________________________________________________________________________________________________*
	{
	
		*--------------------------------------------------------------------------------------------------------------------------------*
		*--------------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 				if period > 2015 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*--------------------------------------------------------------------------------------------------------------------------------*
								

			**
			*Interest rates and duration of KCGF loans by period of time
			foreach var of varlist irate_nominal duration 	{
				foreach group_period in 1 2 3 				{
					di as red "`var'" "`group_period'"
					su 		   `var'	  	if group_period == `group_period', detail
				}
			}
			
				
			**
			**
			clonevar 	average_loan_r  		= loanamount_r
			replace 	loanamount_r    		= loanamount_r/1000000
		

			
			**
			*Creating total category
			expand 2, gen(REP)
			replace Product = "Total" if REP == 1
			
			
			**
			**Descriptives of KCGF loans
			gen 		id   = 1
			collapse (sum) id loanamount_r (median) average_loan_r collateralvalue_r shareloan_turnover duration irate_nominal (mean) economic_recovery, by(period Product)
			replace economic_recovery = economic_recovery*100
			
			
			
			**
			**
			br		period id average_loan_r loanamount_r irate_nominal collateralvalue_r duration shareloan_turnover economic_recovery					if Product == "Total"
			
			
			br		Product id average_loan_r irate_nominal collateralvalue_r duration shareloan_turnover				if Product != "Total" & period == 2021
		
	}	
			
		
		
		
	*--------------------------------------------------------->>>
	**
	**
	*Other loans total and descriptives
	*________________________________________________________________________________________________________________________________*
	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\Credit Registry.dta" 	if period > 2015, clear							//each row is one contract. same firm can have several in the same year. 
		replace fund = 2 if fund == 3
		*----------------------------------------------------------------------------------------------------------------------------*
		
				**
				*Checking the firm sales to see if the approved amount is much more than the total sales (which indicates that something might be wrong)
				merge m:1 fuid period using "$data\final\firm_year_level.dta", keep (1 3) keepusing (turnover_r size sme group_sme) nogen
				
				
				**
				*Only MSME
				keep 	if (inlist(sme, "a.1-9", "b.10-49", "c.50-249") & period < 2019) | (period == 2019 & inlist(size_creditdata, 1,2,3))
				
				
				**
				*Outliers by firms' size
				replace irate_nominal = . if irate_nominal 	== 0
				replace duration      = . if duration 		== 0
				foreach group_sme in 1 2 3 {
					su 		irate_nominal 		if group_sme == `group_sme', detail
					replace irate_nominal = . 	if group_sme == `group_sme' & (irate_nominal <= r(p5) | irate_nominal >= r(p95))
					su 		duration 			if group_sme == `group_sme', detail
					replace duration 	  = . 	if group_sme == `group_sme' & (duration 	 <= r(p5) | duration	  >= r(p95))				
				}
						

				**
				*Interest rates and duration of other loans
				foreach var of varlist irate_nominal duration {
						su `var', detail
				}
		
				
				**
				*Ouliers in terms of approved amount divided by turnover. -> it does not make sense the company get a loan that might be more than 10 times their total sales
				gen 	p = loanamount_r/turnover_r
				su  	p 										, detail //only for the non-covered loans, lets see the total amount of KCGF without excluding anything
				gen 	outlier = 1 							if p > r(p95) & p != .		   //excluding the percentile 95				
				replace loanamount_r = . 						if outlier == 1
	
				**
				**Outliers in terms of amount
				su 		loanamount_r 							if outlier != 1, detail
				replace loanamount_r = . 						if outlier != 1 & (loanamount_r < r(p5) | loanamount_r >= r(p95))

						
				**
				*Loan amount as % of turnover
				gen 		shareloan_turnover 		= (loanamount_r /turnover_r)*100
				su			shareloan_turnover		, detail
				replace 	shareloan_turnover 		= . 	if shareloan_turnover < r(p5) | shareloan_turnover > r(p95)
				

				**
				**Average loan
				clonevar  average_loan_r =	loanamount_r
							
				**
				*Firm id
				egen 	id = tag(fuid period)					//firm indicator
				
				**
				*Total loan amount
				collapse (sum) loanamount_r id (median)average_loan_r collateralvalue_r duration irate_nominal shareloan_turnover (mean) classA, by(period fund)
				format  *amount* %15.1fc				
				replace  loanamount_r =  loanamount_r/1000000
				order 	 period id ave*		//other loans, total, contracts and average amount
				br		 period id average_loan_r loanamount_r irate_nominal collateralvalue_r duration shareloan_turnover 	if fund == 2
				br		 period id average_loan_r loanamount_r irate_nominal collateralvalue_r duration shareloan_turnover  if fund ==1
	
					
				
	
	*--------------------------------------------------------->>>
	**
	**
	*Balance test 2015 
	*________________________________________________________________________________________________________________________________*

	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49"), clear
		gen micro =  sme == "a.1-9" 
		gen small =  sme == "b.10-49"
		
		gen productivity_micro 	= productivity_r 	if micro == 1
		gen turnover_micro 		= turnover_r 		if micro == 1
		gen productivity_small 	= productivity_r 	if small == 1
		gen turnover_small		= turnover_r 		if small == 1
		
		
		iebaltab firms_age employees micro turnover_micro turnover_small productivity_micro productivity_small wages_worker_r import_tx had_loan_up2015 willclose_after2015, stdev  format(%12.0fc %12.2fc) grpvar(type_firm_after2015) save("$output/tables/Table1.xls") 	rowvarlabels replace 
	*________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Access to credit prior to 2016
	*________________________________________________________________________________________________________________________________*
	{
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 &  inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
		*----------------------------------------------------------------------------------------------------------------------------*

			graph pie had_loan_up2015 didnothave_loan_up2015, by(type_firm_after2015,  note("") legend(off) graphregion(color(white)) cols(3))  ///
			pie(1, explode  color(emidblue*0.8)) pie(2, explode color(gs12))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			plabel(2 "No credit",   						 gap(2)   format(%2.0fc) size(large)) 												///
			plabel(1 "With loans",    						 gap(2)   format(%2.0fc) size(large)) 												///
			legend(order(1 "Access to credit before 2016" 2 "Without access to credit before 2015") ) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(10) 	
			graph export "$output/figures/had_loan_up2015_subgroup.pdf", as(pdf) replace	
	}
	*________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Exit rates
	*________________________________________________________________________________________________________________________________*
	{
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 &  inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
		*----------------------------------------------------------------------------------------------------------------------------*

			graph pie notclose_after2015 willclose_after2015 , by(type_firm_after2015,   note("") legend(off) graphregion(color(white)) cols(3))  ///
			pie(1, explode  color(gs14)) pie(2, explode color(red))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 											///
			plabel(2 "Close",   						 gap(2)   format(%2.0fc) size(large)) 												///
			plabel(1 "Remain open",    						 gap(2)   format(%2.0fc) size(large)) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("", span color(black) fcolor(background) pos(7) size(small))																///
			ysize(4) xsize(10) 	
			graph export "$output/figures/exit_by_subgroup.pdf", as(pdf) replace	
	}
	*________________________________________________________________________________________________________________________________*
	
	

	*--------------------------------------------------------->>>
	**
	**
	*Balance test between KCGF and Economic Recovery Package
	*________________________________________________________________________________________________________________________________*
	{
	
			use "$data\inter\KCGF.dta" if period > 2020 & inlist(size_kcgf, 1,2,3), clear
			tab group_period
			
			foreach group_period in 2 3 {
				foreach var of varlist  turnover_r ProjectedAnnualTurnover productivity_r {
					su		 `var'		if group_period == `group_period', detail
					replace  `var' = .	if group_period == `group_period' & (`var' < r(p5) |`var' > r(p95))
				}
			}
				
			iebaltab GuaranteePercentageRequested Maturity NominalInterestrate employees turnover_r productivity_r , format(%12.2fc) grpvar(group_period) save("$output/tables/Table2.xls") 	rowvarlabels replace 
		}
	*________________________________________________________________________________________________________________________________*
	
	
	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 				if period == 2021 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*----------------------------------------------------------------------------------------------------------------------------*
			gen id = 1
			graph pie id, over(Product)  ///
			pie(1, explode  color(emidblue*0.8))   ///
			pie(2, explode  color(gs12))  ///
			pie(3, explode  color(orange*0.5))  ///
			pie(4, explode  color(erose*1.2))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			plabel(4 "Start up",   						 gap(1)   format(%2.0fc) size(large)) 													///
			plabel(3 "Regular",   						 gap(2)   format(%2.0fc) size(large)) 													///
			plabel(2 "Eco Rev Package",   				 gap(4)   format(%2.0fc) size(large)) 													///
			plabel(1 "Agro",    						 gap(7)   format(%2.0fc) size(large)) 													///
			legend(off) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(5) 	
			graph export "$output/figures/kcgf_windows.pdf", as(pdf) replace	

	
		use "$data\inter\KCGF.dta" 				if period == 2021 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
	
	
		collapse (median)loanamount_r irate_nominal, by( Product)
		egen cod_prod = group(Product)
						
		format irate_nominal %12.2fc	
		gen zero = 0
		format loanamount_r %12.0fc
		
	twoway ///
	(bar loanamount_r  cod_prod, barw(.5)  lcolor(emidblue) lwidth(0.2) fcolor(emidblue) fintensity(inten80) 					       yaxis(2)) 				///
	|| (scatter loanamount_r  cod_prod, mlabcolor(black) mlabposition(12) symbol(none) mlabel(loanamount_r) yaxis(2))		///
	|| (scatter irate_nominal cod_prod , symbol(O) color(cranberry) msize(medlarge) ml( irate_nominal ) mlabcolor(black) mlabposition(12) mlabsize(3) yaxis(1)		///
	ysca(axis(1) r(-10 12))  ylab(1(2)10,  nogrid angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 		///
	ysca(axis(2) r(10000 50000))  ylab(10000(10000)50000, nogrid   angle(horizontal) labsize(small) format(%4.0fc) axis(2))					 	///
	legend(order(1 "Median loan amount, 2021 EUR" 2 "" 3 "Nominal interest rate") cols(3) size(medsmall) region(lwidth(none) color(none)) pos(12))  			 				/// 		
	xlabel(1 "Agro" 2 "Eco. Rec. Package" 3 "Regular" 4 "Start up") ///
	title("", pos(12) size(medsmall) color(black)) 														///     
	ytitle("Nominal interest rates", axis(1) size(small) color(black))											/// 
	ytitle("Median loan amount, 2021 EUR", axis(2) size(small) color(black)) 				///
	xtitle("") ///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
	plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
	ysize(5) xsize(7))							 													
	graph export "$output/figures/Number of ASAs and Life time expenditures.pdf", as(pdf) replace		

	xsca( r(2017 2022)   )     xlab(2018(1)2021,     labsize(small) format(%4.0fc)) 					///

						
						
						
					twoway ///
					(bar loanamount_r  cod_prod		, barw(.5)  mlab() mlabpos(12) mlabcolor(black) lcolor(navy) lwidth(0.2) fcolor(gs14) fintensity(inten60) yaxis(2)) 			 ///
				|| (scatter  irate_nominal  cod_prod , symbol(O) color(cranberry*0.8) msize(medsmall) ml() mlabcolor(black) mlabposition(3) mlabsize(2) yaxis(1) 	 ///
					ysca(axis(1) ) line)   ylab(, nogrid	  angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 	 ///
					ysca(axis(2) r()  line)  ylab(,  nogrid   angle(horizontal) labsize(small) format(%4.0f) axis(2))		///
					xline()	///
					xsca() ///
					legend(order(1 "Disbursement" 2 "N. of KCGF loans"  ) cols(2) size(medium) region(lwidth(none) color(none)) pos(6))  /// 		
					title("", pos(12) size(medsmall) color(black)) 														///     
					ytitle("N. of KCGF loans", axis(1) size(medium) color(black))										/// 
					ytitle("Disbursements, million 2021 EUR", axis(2) size(medium) color(black)) 						///
					xtitle("", size(small))  																			///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					note("", span color(black) fcolor(background) pos(7) size(vsmall)))
					graph export "$output/figures/numberKcgfloans.pdf", as(pdf) replace	

	
							twoway ///
					(bar loanamount_r  cod_prod			, barw(.5)  mlab(loanamount_r ) mlabpos(12) mlabcolor(black) lcolor(navy) lwidth(0.2) fcolor(gs14) fintensity(inten60) yaxis(2)) 			 ///
				|| (scatter  irate_nominal  cod_prod , symbol(O) color(cranberry*0.8) msize(medsmall) ml() mlabcolor(black) mlabposition(3) mlabsize(2) yaxis(1) 	 ///
					ysca(axis(1) r(0(2)10) line)   ylab(, nogrid	  angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 	 ///
					ysca(axis(2) r()  line)  ylab(,  nogrid   angle(horizontal) labsize(small) format(%4.0f) axis(2))		///
					xline()	///
					xsca() ///
					legend(order(1 "Disbursement" 2 "N. of KCGF loans"  ) cols(2) size(medium) region(lwidth(none) color(none)) pos(6))  /// 		
					title("", pos(12) size(medsmall) color(black)) 														///     
					ytitle("N. of KCGF loans", axis(1) size(medium) color(black))										/// 
					ytitle("Disbursements, million 2021 EUR", axis(2) size(medium) color(black)) 						///
					xtitle("", size(small))  																			///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					note("", span color(black) fcolor(background) pos(7) size(vsmall)))
				graph export "$output/figures/numberKcgfloans.pdf", as(pdf) replace	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*

	
	use "$data\final\firm_year_level.dta" if active == 1 & period == 2015 & (inlist(size, 1,2,3) | (size == . & (inlist(size_creditdata, 1,2,3)))), clear

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	***->> Muitas diferencas entre o que esta registrado nos dados kcgf e a tax registry
	*--------------------------------------------------------->>>
	**
	**
	*Dispertion of productivity and sales
	*--------------------------------------------------------------------------------------------------------------------------------*
			
			**
			**
			*KCGF Updated Dataset
			use 	"$data\inter\KCGF.dta"  if LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear
			gen 	 has_kcgf = 1
			keep 	 has_kcgf employees group_period period turnover_r productivity_r
			foreach var of varlist  turnover_r  productivity_r  {		//check the histogram of these variables, huge dispertion
				su 		`var',  detail
				replace `var' = . if  `var'< r(p10) | `var' > r(p90)
			}
			tempfile kcgf 
			save    `kcgf'
	
	
			**
			**
			*Tax Registry
			use "$data\final\firm_year_level.dta" if active == 1 & has_kcgf == 0 & (inlist(size, 1,2,3) | (size == . & (inlist(size_creditdata, 1,2,3)))) , clear	//we already replace by . top95 % in terms of numer of employees, sales, productitivy, since the dispertion is so high, lets 
			
			/*
			foreach var of varlist  turnover_r  productivity_r  {		//check the histogram of these variables, huge dispertion
				su 		`var',  detail
				replace `var' = . if  `var'< r(p5) | `var' > r(p95)
			}
			*/
			append using `kcgf'
				
				su 	turnover_r 			if credit_treatment_status == 2,  detail
				quantiles 	turnover_r 	if credit_treatment_status == 2, nq(100) gen(quantiles)
				sort turnover_r quantiles
				br turnover_r quantiles if credit_treatment_status == 2
			

			/*
			**
			*Outliers
			foreach  credit_treatment_status  in 0 1 2  {
				di as red `group_period'
				su 		employees		if  credit_treatment_status== `credit_treatment_status', detail
				replace employees = . 	if  credit_treatment_status == `credit_treatment_status' & ( employees < r(p5) |  employees >= r(p95))
			}
			*/
			
			foreach var of varlist productivity_r turnover_r {
				    if "`var'" == "turnover_r" {
					    local xtitle "Sales, in 2018 EUR"
						local min = 0
						local inter = 40000
						local max = 120000
					}	
				    if "`var'" == "productivity_r" {
					    local xtitle "Sales per employee, in 2018 EUR"
						local min = 0
						local inter = 20000
						local max = 60000
					}
				**
				keep if inlist(period, 2016,2018)
				*Distribution of loan amounts by fund
				twoway  (kdensity `var' if has_kcgf  == 1,   lcolor(orange) lwidth( thick ) )  														///	
						(kdensity `var' if has_loan  == 1 & has_kcgf == 0,   lcolor(emidblue ) lwidth( thick ) ) 														///
						(kdensity `var' if has_loan  == 0 & has_kcgf == 0,   lcolor(black) lwidth(thin ) ) 														///
				(kdensity `var' if credit_treatment_status ==4,   lcolor(orange) lwidth(thin)  														///
				title("", pos(12) size(medium) color(black))																										///
				subtitle("" , pos(12) size(medsmall) color(black))  																								///
				ylabel(, labsize(small) nogrid) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 													///
				yscale(alt) 																																		///
				xtitle("`xtitle'", size(medsmall) color(black)) ytitle("Density")  																							///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				ysize(5) xsize(6) 																																	///
				fcolor(none) lcolor(black)), legend(order(1  "KCGF"  2 "Loan without KCGF"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(medsmall) position(12)) ///
				note(, span color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/distribution_`var'2010-2015.pdf", as(pdf) replace	
			}
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		use 		"$data\final\firm_year_level.dta" if inlist(period, 2018,2017) & active == 1 & formal == 1, clear
				collapse (mean) has_loan has_kcgf (median) turnover_r wages_worker_r productivity_r employees loanamount_r loanamount_r_kcgf, by(size)		
					replace has_loan = has_loa*100
					replace has_kcgf = has_kcgf*100
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	*--------------------------------------------------------->>>
	*--------------------------------------------------------->>>
	**
	**
	*% of Firms with loans
	*--------------------------------------------------------------------------------------------------------------------------------*

			use "$data\final\firm_year_level.dta" if inlist(period, 2018,2017) & active == 1 & (inlist(size, 1,2,3) | (size == . & (inlist(size_creditdata, 1,2,3)))), clear
			replace has_loan = 0 if has_loan_informal == 1

			graph pie no_loan has_kcgf has_loan  has_loan_informal ,  pie(1, explode  color(gs14)) pie(2, explode color(red*0.8)) pie(3, explode color(navy*0.5) )  pie(4, explode color(navy*0.7) )  ///
			legend(off) 	 																												///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 											///
			plabel(1 "No loan",   						 gap(2)   format(%2.0fc) size(medsmall))  											///
			plabel(2 "Loan KCGF",    					 gap(6)   format(%2.0fc) size(medsmall)) 											///
			plabel(3 "Loan, formal firm",    			 gap(1)   format(%2.0fc) size(medsmall)) 											///
			plabel(4 "Loan, informal firm",    			 gap(1)   format(%2.0fc) size(medsmall)) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("Source: Kosovo Credity Registry, 2017 and 2018.", span color(black) fcolor(background) pos(7) size(small))				///
			ysize(6) xsize(6) 	
			graph export "$output/figures/loans_2017-2018.pdf", as(pdf) replace	

			
									
		

					
			
	*--------------------------------------------------------->>>
	**
	**
	*KCGF and other firms size
	*--------------------------------------------------------------------------------------------------------------------------------*
			
			**
			*No loans
			use "$data\final\firm_year_level.dta" if inlist(size, 1,2,3) & (no_loan == 1 & period> 2015) , clear		//we already replace by . top95 % in terms of numer of employees, sales, productitivy, since the dispertion is so high, lets 
					gen id = 1
					gen 	group = 1 if employees <=2
					replace group = 2 if inrange(employees,3,9  )
					replace group = 3 if inrange(employees,10,49  )
					replace group = 4 if employees > 49 & employees < 250
					replace group= 5 if employees >= 250 & employees != .
				collapse (sum) id, by(group)
				gen fund = 3
				tempfile noloan
				save    `noloan'
			
			**
			*KCGF
			use "$data\inter\KCGF.dta" 				if period > 2015 & LoanStatus != "Canceled" , clear	//not including large companies
					gen id = 1
					gen 	group = 1 if employees <=2
					replace group = 2 if inrange(employees,3,9  )
					replace group = 3 if inrange(employees,10,49  )
					replace group = 4 if employees > 49 & employees < 250
					replace group = 5 if employees >= 250 & employees != .
				collapse (sum) id, by(group)
				gen fund = 1
			tempfile kcgf
			save    `kcgf'

			**
			*Other loans
			use "$data\final\firm_year_level.dta" if (has_kcgf == 0 & has_loan == 1) & period> 2015 , clear		//we already replace by . top95 % in terms of numer of employees, sales, productitivy, since the dispertion is so high, lets 
					gen id = 1
					gen 	group = 1 if employees <=2
					replace group = 2 if inrange(employees,3,9  )
					replace group = 3 if inrange(employees,10,49  )
					replace group = 4 if employees > 49 & employees < 250
					replace group = 5 if employees >= 250 & employees != .

				collapse (sum) id, by(group)
				gen fund = 2
			append using `kcgf'
			append using `noloan'
			drop if group == .
			reshape wide id, i(fund) j(group)
			egen total = rsum(id*)
			gen  p1 = (id1/(total))*100
			gen  p2 = (id2/(total))*100
			gen  p3 = (id3/(total))*100
			gen  p4 = (id4/(total))*100
			gen  p5 = (id5/(total))*100

			label define fund 1 "KCGF" 2 "Other loans" 3 "No loan"
			
			label val 	 fund fund

				
				graph bar (asis) p1 p2 p3 p4 p5  , bargap(-30)  bar(1, color(gs12)  fintensity(inten60) ) bar(2, color(navy) fintensity(inten30)) 	 bar(3, color(cranberry) fintensity(inten90)) bar(4, color(erose) ) 		 	///
			 over(fund, sort(fund) label(labsize(medium))) 																		 				///
				blabel(bar, position(outside) orientation(horizontal) size(vsmall) color(black) format (%4.0fc))   								 		///
				ytitle("% loans", size(large)) ylabel(, nogrid  labsize(small) gmax angle(horizontal) format (%4.0fc) )  					///
				yscale(alt) ///
				legend(order(1 "Up to 1 employee" 2 "2 to 5 employees" 3 "6 to 20 employees" 4 "More than 20") region(lwidth(white) lcolor(white) fcolor(white)) cols(3) size(medium) position(12))     ///
				note("" , span color(black) fcolor(background) pos(7) size(small)) 							 				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 			///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 			///
				ysize(6) xsize(11)
				local nb =`.Graph.plotregion1.barlabels.arrnels'
					di `nb'
					forval i = 1/`nb' {
					  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
					  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
					}
					.Graph.drawgraph
				graph export "$output\figures\loans by number employees.pdf", as(pdf) replace	
				



	
			use "$data\final\firm_year_level.dta" if active == 1 & period <= 2015 & inlist(size, 1,2,3) , clear		//we already replace by . top95 % in terms of numer of employees, sales, productitivy, since the dispertion is so high, lets 
				su turnover_r, detail
				
				gen group = 1 if turnover <= 5000
				replace group = 2 if turnover 
	

		
	*--------------------------------------------------------->>>
	**
	**
	*Loan conditions
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" if period > 2015, clear

			su  		NominalInterestrate, detail
			replace  	NominalInterestrate = . if  NominalInterestrate <= r(p1) | NominalInterestrate >= r(p99)
			
			foreach var of varlist NominalInterestrate loanamount_r {
				su `var', detail
				replace  `var' = . if  `var' <= r(p1) |`var' >= r(p99)

						twoway  (kdensity `var' if group_period == 1 ,  lcolor(navy) lwidth( thin ) )  														///	
						(kdensity `var' if group_period == 2,   lcolor(cranberry*0.7) lwidth(thin))  														///
						(kdensity  `var' if group_period == 3,   lcolor(cranberry) lwidth(thick) ) 														///
						(kdensity  `var'  if group_period == 4,   lcolor(orange) lwidth(thin)  														///
				title("", pos(12) size(medium) color(black))																										///
				subtitle("" , pos(12) size(medsmall) color(black))  																								///
				ylabel(, labsize(small) nogrid) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 													///
				yscale(alt) 																																		///
				xtitle("Nominal Interest Rate", size(medsmall) color(black)) ytitle("Density")  																							///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				ysize(5) xsize(6) 																																	///
				fcolor(none) lcolor(black)), legend(order(1  "KCGF 2016-2019"  2 "KCGF 2020-2022" 3 "Economic Recovery Package" ) region(lwidth(none) color(white) fcolor(none)) cols(2) size(medsmall) position(12)) ///
				note(, span color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/kcgf_`var'.pdf", as(pdf) replace	
			}
			
	
			
			
			
			
			bys group_period: su  employees, detail

	
	
	
	
					su loanamount_r if inlist(group_period,1), detail
				
				twoway  (kdensity loanamount_r  			if group_period == 1,   lcolor(navy) lwidth( thin ) )  														///	
						(kdensity loanamount_r 				if group_period == 3,   lcolor(cranberry*0.8) lwidth( thin))    																///
						(kdensity loanamount_r 				if group_period == 2,   lcolor(cranberry) lwidth( thick) )   																///
						(kdensity loanamount_r 				if group_period == 4,   lcolor(cranberry) lwidth( thick)    																///
				title("", pos(12) size(medium) color(black))																										///
				subtitle("" , pos(12) size(medsmall) color(black))  																								///
				ylabel(, labsize(small) nogrid) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 													///
				yscale(alt) 																																		///
				xtitle("Loan amount, in 2021 EUR", size(medsmall) color(black)) ytitle("Density")  															///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				ysize(5) xsize(7) 																																	///
				text(0.00002 120000   "10% of loans not covered by KCGF to MSME are > 54k EUR", size(medsmall)) ///
				fcolor(none) lcolor(black)), legend(order(1 "KCGF" 2 "Not covered by KCGF") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(12)) ///
				note(, span color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/loanamount_2016-2019.pdf", as(pdf) replace	
	
	

			

	
	
	
	
	
	
	
	/*
	
	**
	*
	*--------------------------------------------------------------------------------------------------------------------------------*
	foreach comparison in 0 1 {
	
		**
		*% LASSO
		*----------------------------------------------------------------------------------------------------------------------------*
		{
		use "$data\final\firm_year_level.dta" if main_dataset == 1 & period == 2016 & (first_kcgf == . | first_kcgf > 2016) & active == 1, clear	 
		
			br fuid econ_sector fyear_main_dataset  credit_treatment_status *wages_worker*
			
			**
			global covars		c.age##c.age							///
								export_tx import_tx  					///
								c.productivity##c.productivity 			///	
								c.wages_worker##c.wages_worker			///
								c.num_loans##c.num_loans				///
								c.employees_tx##c.employees_tx 			///
								c.lag1_productivity##c.lag1_productivity c.lag2_productivity##c.lag2_productivity   ///
								c.lag1_num_loans##c.lag1_num_loans c.lag2_num_loans##c.lag2_num_loans 				///
								c.lag1_wages_worker##c.lag1_wages_worker c.lag2_wages_worker##c.lag2_wages_worker   ///
								c.lag1_employees_tx##c.lag1_employees_tx c.lag2_employees_tx##c.lag2_employees_tx   ///
								
			keep if inlist(credit_treatment_status, `comparison', 2)
			
			lasso 	linear  treated_kcgf  $covars   i.econ_sector i.municipalityid_tx, rseed(628879)			
			di  			 `e(allvars_sel)'
			global  controls `e(allvars_sel)'
			reg 			treated_kcgf  $covars   i.econ_sector i.municipalityid_tx
		}
	
	


		
		
		
		
		
		
		
		
		
		
				
				
			
			
			
			/*
			foreach var of varlist age lag_turnover_tx lag_wages_worker lag_productivity lag_num_loans {
					ttest `var', by(has_kcgf)
			}
			*/		
			
			
			
			
			
			
			
			
			
			
			
	use "$data\final\firm_year_level.dta" if active == 1 & main_dataset == 1, clear
			gen id = 1
			
			collapse (sum) id, by(period turnover_status)
			reshape wide id, i(period) j(turnover_status)
			
	
	
	
			
			
			
			
			
			
			
			
			use  "$data\final\firm_year_level.dta", clear 

			
			
			collapse (sum) loanamount_r, by(period )

			
			
			
			
			

			
			
			
			graph bar (asis)num_loans num_firms if period >= 2016 , bar(1, color(gs12)  fintensity(inten60) ) bar(2, color(navy) fintensity(inten30)) 			 	///
			over(fund) over(period, sort() label(labsize(small))) stack 																		 				///
			blabel(bar, position(center) orientation(horizontal) size(vsmall) color(black) format (%4.0fc))   								 	///
			ytitle("Number of active ASAs", size(medsmall)) ylabel(, labsize(small) gmax angle(horizontal) format (%4.0fc) )  					///
			yscale(line) ///
			legend(order(1 "Without IE" 2 "With IE" ) region(lwidth(white) lcolor(white) fcolor(white)) cols(4) size(medsmall) position(6))     ///
			note("Source: Operations Monitoring" , span color(black) fcolor(background) pos(7) size(small)) 							 		///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			ysize(6) xsize(7) 																							
			graph export "$figures/Number of ASAs by GP.pdf", as(pdf) replace				

			
			
			
			
			lasso 
			
			/*
			
				**
	*Total amount of loans and loans covered by KCGF, excluding outliers
	*--------------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\Credit Registry.dta" if period > 2016 , clear								//each row is one contract. same firm can have several in the same year. 
				
			replace fund = 2 if fund == 3		
			
			tab 	fund, // a loan is either covered by the KCGF or not. 
				
			collapse (sum) loanamount_r (mean)fundcoverage, by(fund fuid period)					//by firm and year, the total approved amount by year and fund
				
				**
				**Checking the firm sales to see if the approved amount is much more than the total sales (which indicates that something might be wrong)
				merge m:1 fuid period using "$data\final\firm_year_level.dta", keep (1 3) keepusing (turnover_r)
				
				**
				*Ouliers in terms of approved amount divided by turnover. -> it does not make sense the company get a loan that might be more than 10 times their total sales 
				gen 	p = loanamount_r/turnover_r
				su  	p 										if fund != 1,   					detail //only for the non-covered loans, lets see the total amount of KCGF without excluding anything
				gen 	outlier = 1 							if fund != 1 & p > r(p95) & p != .		   //excluding the percentile 95
				replace loanamount_r = . 				if outlier == 1
				su 		p 		if fund == 1, detail
				replace p = . 	if fund == 1 & p > r(p90)
				su 		p 		if fund == 2, detail
				replace p = . 	if fund == 2 & p > r(p90)	
				
				**
				*Outliers in terms of approved amount, does it make sense in the country a company have loans of hundreds of millions??
				su 		loanamount_r 					if fund == 1 & outlier != 1, detail
				replace loanamount_r = . 				if fund == 1 & outlier != 1 & loanamount_r >= r(p95)

				su 		loanamount_r 					if fund == 2 & outlier != 1, detail
				replace loanamount_r = . 				if fund == 2 & outlier != 1 & loanamount_r >= r(p95) 
				
				**
				**Firms beneficited
				gen 	num_firms = 1			//each row is a firm in year t, the firm only appers twice if the firm nas one loan KCGF and one not covered by the fund
				
				su 		loanamount_r  if fund == 1, detail					//average amount a firm get from KCGF
				su 		loanamount_r  if fund == 2, detail					//average amount a firm get from a loan not covered by KCGF
				su 		turnover_r 		if fund == 2 & loanamount_r > 200000

				**
				**Average loan
				clonevar  amount_mean_eu_r =	loanamount_r
								
				**
				*Total loan amount
				collapse (sum) loanamount_r num_firms (mean)amount_mean_eu_r fundcoverage, by(fund period)
				format  *amount* %15.1fc				//these amounts do no make much sense.
				sort 	 period fund
				replace  loanamount_r =  loanamount_r/1000000
			
			
			
			
			
			
			
