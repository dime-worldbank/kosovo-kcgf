	

	
	
	
	use "$data\final\firm_year_level.dta" if active == 1, clear
	keep if turnover_r_all != 0
	gen report_profit =  profit_r != .
	collapse (mean) report_profit, by(period)
		
	
	use "$data\final\firm_year_level.dta" if active == 1, clear
	tab period formal
	bys period: su turnover_r,detail
		bys period: su employees,detail

	
	use "$data\final\firm_year_level.dta" if active == 1, clear
	xtset fuid period
	xtreg has_loan number_loans_up_t_minus1 i.municipalityid i.ethnicity lag1_employees lag2_employees lag1_turnover_r sq_lag1_turnover_r firms_age sq_firms_age sq_lag1_employees, fe 
	
	
	use "$data\inter\Credit Registry.dta", clear
	count
	codebook fuid if period == 2018
	

	
	use "$data\final\firm_year_level.dta" if  active == 1 & group_sme != 5 & turnover_r_all != 0, clear
		gen id = 1
		replace group_sme = 3 if group_sme == 4
		collapse (sum)id, by(group_sme period)
		bys period: egen total = sum(id)
		gen share = (id/total)*100
		format share %12.1fc
		
		keep if inlist(period,2010,2012,2014,2016,2018)
		
		keep share period group_sme
		reshape wide share, i(period) j(group_sme)

	
		graph bar (asis)share1 share2 share3, bargap(-30) bar(1, color(olive_teal*0.8)) bar(2, color(orange*0.5) ) bar(3, color(emidblue) ) 	///
		over(period, sort() label(labsize(medium) ) ) 																///
		blabel(bar, position(outside) orientation(horizontal) size(medium) color(black) format (%4.1fc))   								 	///
		ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   					///
		yscale(off) ///
		legend(order(1  "Micro"  2 "Small" 3 "Medium/Large"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(medlarge) position(12)) 		///	
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
		ysize(4) xsize(4) 																						
		local nb =`.Graph.plotregion1.barlabels.arrnels'
		di `nb'
		forval i = 1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		graph export "$output\figures\micro-year.pdf", as(pdf) replace	

		
	
	use "$data\final\firm_year_level.dta" 	if  active == 1 & group_sme == 1 & period == 2010 & turnover_r_all != 0, clear
		keep 	fuid
		tempfile temp
		save 	`temp'
	
	use "$data\final\firm_year_level.dta" 	if  active == 1 & period == 2018 & group_sme == 2, clear
		tab birthyear
	
	use 	"$data\final\firm_year_level.dta" , clear
		merge 	m:1 fuid using `temp', keep(3) nogen
		gen 	fechou = 1 if deathyear != . & period == 2010
		keep if period == 2018 | period == 2010
		sort 	fuid period
		gen 	aumentou_tamanho = .
		replace	aumentou_tamanho = 1 if period == 2010 & fechou !=1 & group_sme[_n+1] > 1 & group_sme != 5 & fuid[_n] == fuid[_n+1]
		gen continuou_micro = 1 if fechou == . & aumentou_tamanho == .
		keep if period == 2010
		gen id= 1
		collapse (sum) aumentou_tamanho fechou continuou_micro id, by(period)
		
	
	
	use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & turnover_r_all != 0, clear
	
		gen id = 1
		replace group_sme = 3 if group_sme == 4
		keep if inrange(sec_activityid,1,4)
		label drop group_sme
		
		label define group_sme 1 "Micro" 2 "Small" 3 "Medium/Large" 
		label val group_sme group_sme
		
		collapse (sum)id,by(sec_activityid period group_sme )
		
		reshape wide id, i(period group_sme ) j(sec_activityid)

			**
			graph pie id1 id2 id3 id4, by(group_sme,  note("") graphregion(color(white)) cols(3))    ///
			pie(1, explode  color(navy*0.9)) pie(2, explode  color(cranberry*0.6))  pie(3, explode  color(gs12))  pie(4, explode  color(olive_teal*0.5)) pie(5, explode color(gs12)) pie(6, explode color(cranberry*0.6)) ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			legend(order(1 "Primary" 2 "Secondary" 3 "Tertiary" 4 "Quaternary") cols(4) pos(12) region(lstyle(none) fcolor(none)) size(large)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(8) 	
			graph export "$output/figures/sector_activity.pdf", as(pdf) replace	
			graph export "$output/figures/sector_activity.emf", as(emf) replace	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2014, 2018), clear

	
	collapse (mean)has_loan, by(period group_sme)	
	replace has_loan = has_loan*100
	
	reshape wide has_loan, i(period) j(group_sme)
	

			*Average between 2017-2018
			graph bar (asis)has_loan1 has_loan2 has_loan3 has_loan4, bargap(-30) bar(1, color(olive_teal*0.8)) bar(2, color(orange*0.5) ) bar(3, color(emidblue) ) bar(4, color(gs12) ) 	///
			over(period, sort() label(labsize(medium) ) ) 																///
			blabel(bar, position(outside) orientation(horizontal) size(medium) color(black) format (%4.0fc))   								 	///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   					///
			yscale(off) ///
			legend(order(1  "Micro"  2 "Small" 3 "Medium"  4 "Large") region(lwidth(none) color(white) fcolor(none)) cols(4) size(medlarge) position(12)) 		///	
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			ysize(4) xsize(4) 																						

			
		local nb =`.Graph.plotregion1.barlabels.arrnels'
		di `nb'
		forval i = 1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		graph export "$output\figures\loan-year.pdf", as(pdf) replace	

		
			
	use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018 & has_loan == 1 , clear
		
		tab group_sme has_credit_history
		
		
	use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018, clear
	tab group_sme has_credit_history
	
	
			
	
	use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & sec_activityid != . & group_sme!= 5, clear
		
		
			replace group_sme = 3 if group_sme == 4

		collapse (mean) has_loan, by(sec_activityid group_sme)
			
			sort group_sme sec_activityid
			
			
			
			
	use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & !missing(sectionid), clear

	
	iebaltab turnover_r  productivity_r nocredit_history avgrowth_productivity_r avgrowth_employees avgrowth_turnover_r,  cov(sectionid) format(%12.0fc %12.2fc) grpvar(group_sme) save("$output/tables/teste.xls") 	rowvarlabels replace 

	
	
	use 	"$data\final\firm_year_level.dta" if active == 1 & main_dataset == 1, clear	

	collapse (mean)has_loan, by(period group_sme ethnicity)
	
	
	
	
	
			*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
		*----------------------------------------------------------------------------------------------------------------------------*

			graph pie notclose_after2015 willclose_after2015 , by(group_sme,    note("") legend(off) graphregion(color(white)) cols(3))  ///
			pie(1, explode  color(gs14)) pie(2, explode color(red))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 											///
			plabel(2 "Close",   						 gap(2)   format(%2.0fc) size(large)) 												///
			plabel(1 "Remain open",    						 gap(2)   format(%2.0fc) size(large)) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("", span color(black) fcolor(background) pos(7) size(small))																///
			ysize(4) xsize(10) 	
			graph export "$output/figures/exit_by_size.pdf", as(pdf) replace	

			
			
	use 	"$data\final\firm_year_level.dta" if active == 1 & sec_activityid == 1, clear

	collapse (mean) productivity_r, by(group_sme period)
	
	
	
	
	/*
	
	
		
	*--------------------------------------------------------->>>
	**
	*Size of the firms
	use "$data\final\firm_year_level.dta" 	if  active == 1 & group_sme != 5, clear
	gen id = 1
	replace group_sme = 3 if group_sme == 4
	tab group_sme, gen (group)
	
			graph pie group1 group2 group3 if period == 2018,   ///
			pie(1, explode  color(olive_teal*0.8)) pie(2, explode  color(orange*0.5))  pie(3, explode  color(emidblue))  pie(4, explode  color(gs12)) pie(5, explode color(gs12)) pie(6, explode color(cranberry*0.6)) ///
			plabel(_all percent,   						 gap(-5) format(%2.0fc) size(medsmall)) 												///
			legend(order(1 "Micro" 2 "Small" 3 "Medium/Large" ) cols(3) pos(12) region(lstyle(none) fcolor(none)) size(medlarge)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(4) 	
			graph export "$output/figures/share-micro.pdf", as(pdf) replace	
			graph export "$output/figures/share-micro.emf", as(emf) replace	
			
			
			
	
	
	
	
