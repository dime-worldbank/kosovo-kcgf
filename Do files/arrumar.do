	

	
	
			
			
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
			
			
			
	
	
	
	
