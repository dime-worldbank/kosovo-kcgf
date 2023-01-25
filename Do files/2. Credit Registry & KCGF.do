

	*__________________________________________________________________________________________________________________________________________*
	**

	*LOAN DATASETS
	
		/*
		
		Dataset shared by the Central Bank of Kosovo -> I replaced duration and interest rates by missing if they are equal to 0
													    I replaced duration and interest rates by missing if they are in the bottom 5% or top 95%
			
			
			
		Dataset shared by KCGF-						 -> I replaced  duration and interest rates by missing if they are equal to 0. I DID NOT REPLACE BY MISSING BOTTOM 5 AND TOP 95/
													 -> I calculated the loan amount divided by the turnover and replaced this variable with missing the bottom 5% or top 95% (It does not make sense the firm get a loan that is more than double of their turnover. )
													 -> I replaced the variable employees by missing if it is = 0
		
		*/
		
		
		
		**
		** Credit Registry Data -> each row is a loan ID for firm i, in year t, ****the same firm can have several loans in the same year
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			**
			*Importing
			*------------------------------------------------------------------------------------------------------------------------------------->>
			/***
			import excel using  "$data\raw\LoanApplications-Final.xlsx", clear firstrow 
				duplicates r _all
				duplicates drop
				save "$data\inter\Credit Registry Raw.dta", replace
			*/
			
			**
			**Cleaning
			*------------------------------------------------------------------------------------------------------------------------------------->>
			use "$data\inter\Credit Registry Raw.dta", clear
				replace BirthDate = "" if BirthDate == "NULL"
				
				foreach var of varlist BirthDate MaturityDate {
					generate aux`var' = date(`var', "DMY")
					format   aux`var' %td
					drop 		`var'
					rename   aux`var' `var'
				}
				gen    ApprovedMonthYear = mofd(ApprovalDate)		//Loan approval. 
				format ApprovedMonthYear %tm
				gen    period  			 = year(ApprovalDate)
				keep 		if period >= 2010

				
				**
				*Renaiming variables
				*--------------------------------------------------------------------------------------------------------------------------------->>
				rename 		PersonBusinessNo 		lenderfiscalid  /*In case the business (from the list) is in related role to the loan then `Fake ID` of the business appears in the column “Fake Person Business No” */
				rename 		FakepersonbusinessNo 	fuid_lender
				rename 		IdNumber	 			fiscalid
				rename 		FakeIdNumber 			fuid 			/*when it is the borrower then it appears in the column “Fake Id Number”*/
				rename 		LoanNo 					loanid
				rename 		Id 						procedureid 
				rename 		ApprovalDate 			approvaldate
				rename 		BirthDate 				birthdate
				rename 		Institution 			institution
				rename 		PersonType 				persontype
				rename 		LegalEntityType 		legaltype
				rename 		Municipality 			municipality
				rename 		MaritalStatus 			maritalstatus
				rename 		Occupation 				occupation
				rename 		Income 					income
				rename 		LoanType 				loantype
				rename 		LoanActivityType 		loanactvitytype
				rename 		LoanPeriod 				loanperiod
				rename 		Period 					loanduration
				rename 		PaymentFrequency 		payfreq
				rename 		Amount 					loanamount
				rename 		OutstandingAmount 		amountout
				rename 		Currency 				currency
				rename 		MaturityDate 			maturity
				rename 		DisbursementDate 		disbursementdate
				rename 		DisbursementAmount 		disbursedamount
				rename 		EntryDateTime 			entrydate
				rename 		LoanClassification 		loanclass
				rename 		CollateralValue 		collateralvalue
				rename 		CollateralUsed 			collateral
				rename 		LoanPurpose 			loanpurpose
				rename 		Country 				country
				rename 		NominalInterestRate 	irate_nominal
				rename 		EffectiveInterestRate 	irate_effec
				rename 		Code 					code
				rename		CompanySize 			sizeclass
				rename 		Fund 					fund
				rename 		FundCoveredPercentage 	fundcoverage
				rename 		Reprogrammed 			reprogrammed
				rename 		Insolvency 				insolvency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				**
				*Type of institution
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 institution = "1" if institution == "Banka"
				replace 	 institution = "2" if institution == "Kompani sigurimi"
				replace 	 institution = "3" if institution == "MFI"
				destring 	 institution, replace
				label define institution 	1 "Bank" 2 "Insurance Company" 3 "MFI"
				label values institution institution	
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				**
				*Person type
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 persontype = "1" if persontype == "Juridik"
				replace 	 persontype = "2" if persontype == "Jorezident Juridik"
				replace 	 persontype = "3" if persontype == "Fizik"
				replace 	 persontype = "4" if persontype == "Jorezident Fizik"
				destring 	 persontype, replace
				label define persontype 1 "Legal" 2 "Non-resident legal" 3 "Physic" 4 "Non-resident physic"
				label values persontype persontype
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				**
				*Legal type
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 legaltype = "1" 	if legaltype == "Firmë individuale"
				replace 	 legaltype = "2" 	if legaltype == "Kompani e huaj"
				replace 	 legaltype = "3" 	if legaltype == "Kooperativë bujqësore"
				replace 	 legaltype = "4" 	if legaltype == "Ndërmarrje nën juridiksionin a KPA-së"
				replace 	 legaltype = "5" 	if legaltype == "Ndërmarrje publike"
				replace 	 legaltype = "6" 	if legaltype == "Ndërmarrje shoqërore"
				replace  	 legaltype = "7" 	if legaltype == "Organizatë joqeveritare - OJQ"
				replace 	 legaltype = "8" 	if legaltype == "Partneritet i limituar"
				replace 	 legaltype = "9" 	if legaltype == "Partneritet i përgjithshëm"
				replace  	 legaltype = "10" 	if legaltype == "Shoqëri aksionare (Sh.A.)"
				replace 	 legaltype = "11" 	if legaltype == "Shoqëri me përgjegjësi të kufizuar (Sh.P.K.)"
				replace 	 legaltype = "12" 	if legaltype == "NULL"
				destring 	 legaltype, replace
				label define legaltype 	1 "Personal Business Enterprise" 2 "Foreign Company" 							///
										3 "Agricultural Co-Op" 			 4 "Other Enterprises under KPA Jurisdiction" 	///
										5 "Public-Owned Enterprise"		 6 "Socially-Owned Enterprise" 					///
										7 "Non-governmental organization (NGO)" 										///
										8 "Limited partnership" 		 9 "General partnership" 						/// 
										10 "Joint-stock company"		 11 "Limited liability company" 12 "N/A"
				label values legaltype legaltype			
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				**
				*Loan type
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 loantype = "1" 	if loantype == "Asete tjera Kreditore"
				replace 	 loantype = "2" 	if loantype == "Faktoring"
				replace 	 loantype = "3" 	if loantype == "Garancione"
				replace 	 loantype = "4" 	if loantype == "Hua"
				replace 	 loantype = "5" 	if loantype == "Kredi Hipotekare Komerciale"
				replace 	 loantype = "6" 	if loantype == "Kredi Hipotekare Rezidenciale"
				replace 	 loantype = "7" 	if loantype == "Kredit Kartele"
				replace 	 loantype = "8"		if loantype == "Leter kredie"
				replace 	 loantype = "9" 	if loantype == "Lizing Operativ"
				replace 	 loantype = "10" 	if loantype == "Lizingu"
				replace 	 loantype = "11" 	if loantype == "Mbiterheqje"
				replace 	 loantype = "12" 	if loantype == "Tjera"
				replace 	 loantype = "13" 	if loantype == "Zotime tjera"

				destring 	 loantype, replace
				label define loantype 	1 "Other credit assets" 		2 "Factoring"   3 "Warranty"		 4 "Loan" 	  5 "Commercial mortgage loan"		///
										6 "Residential mortgage loan" 	7 "Credit card" 8 "Letter of credit" 9 "Leasing" 10 "Lease" 						///
										11 "Overdraft" 12 "Other"		13 "Other commitments"
										
				label values loantype loantype
				*--------------------------------------------------------------------------------------------------------------------------------->>

				**
				*Loan period
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 loanperiod = "1" 								if loanperiod == "Ditor"
				replace 	 loanperiod = "2" 								if loanperiod == "Mujor"
				replace 	 loanperiod = "3" 								if loanperiod == "Vjetor"

				destring 	 loanperiod, replace
				label define loanperiod 1 "Daily" 2 "Monthly" 3 "Annual"
				label value  loanperiod loanperiod
								
				gen 		 duration = .											
				replace 	 duration = loanduration * (12 / 365) 			if loanperiod == 1
				replace 	 duration = loanduration 						if loanperiod == 2
				replace 	 duration = loanduration * 12 					if loanperiod == 3		//loan duration in months
				*--------------------------------------------------------------------------------------------------------------------------------->>

				
				**
				*Payment frequency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 payfreq = "1" 									if payfreq == "Ditore"
				replace 	 payfreq = "2" 									if payfreq == "Mujore"
				replace 	 payfreq = "3"	 								if payfreq == "Kuartale"
				replace 	 payfreq = "4" 									if payfreq == "Gjysmevjetore"
				replace 	 payfreq = "5" 									if payfreq == "Vjetore"
				replace 	 payfreq = "6" 									if payfreq == "E Parregullt"
				replace 	 payfreq = "7" 									if payfreq == "E plote"
				replace 	 payfreq = "8" 									if payfreq == "Sipas kerkeses"
				replace 	 payfreq = "9" 									if payfreq == "NULL"
				destring 	 payfreq, replace
				label define payfreq 1 "Daily" 2 "Monthly" 3 "Quarterly"  4 "Semi-annual" 5 "Annual" 6 "Irregular" 7 "Full" 8 "On request" 9 "N/A" 
				label value  payfreq payfreq
				*--------------------------------------------------------------------------------------------------------------------------------->>

				
				
				*Loan Currency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 currency = "1" if currency == "Euro"
				replace 	 currency = "2" if currency == "USD"
				destring 	 currency, replace
				label define currency 1 "Euro" 2 "US dollars"
				label values currency currency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				

				**
				*Loan purpose
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 loanpurpose = "1" if loanpurpose == "Ditor"
				replace 	 loanpurpose = "2" if loanpurpose == "Mujor"
				replace 	 loanpurpose = "3" if loanpurpose == "Vjetor"

				destring 	 loanpurpose, replace
				label define loanpurpose 1 "Day" 2 "Month" 3 "Annual"
				label values loanpurpose loanpurpose
				*--------------------------------------------------------------------------------------------------------------------------------->>


				*
				*Country codes
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 country = "1" 	if country == "KOSOVA" 		| country == "KOSOVE" 	| country == "KOSOVO" 								///
											 | country == "KOSOVË" 		| country == "KS" 		| country == "Kosova" 		| country == "Kosovar" 	///
											 | country == "Kosove" 		| country == "Kosovo" 	| country == "Kosovë" 		| country == "XK" 		///
											 | country == "xk" 			| country == "Republika e Kosovës"
				replace 	 country = "2" 	if country == "AL" 			| country == "ALBANIA" 	| country == "SHQIPERI" 	| country == "SHQIPRI"
				replace 	 country = "3" 	if country == "MACEDONIA" 	| country == "MK" 		| country == "Macedonia" 	| country == "Maqedoni"
				replace 	 country = "4" 	if country == "TR" 			| country == "TURKEY"
				replace 	 country = "5" 	if country == "SI"
				replace 	 country = "6" 	if country == "MALI I ZI"
				replace 	 country = "7" 	if country == "HR" 			| country == "Croatia (Local Name: Hrvatska)"
				replace	 	 country = "8" 	if country == "GB" 			| country == "UNITED KINGDOM"
				replace 	 country = "9" 	if country == "US"
				replace 	 country = "10" if country == "DISELDORF" 	| country == "DE"
				replace 	 country = "11" if country == "NULL"

				destring 	 country, replace
				label define country 1 "Kosovo"  2 "Albania" 	    3 "Macedonia"      4 "Turkey"   5 "Slovenia" 6 "Montenegro" ///
									 7 "Croatia" 8 "United Kingdom" 9 "United States" 10 "Germany" 11 "N/A"
				label values country country
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				*
				*Size class
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 sizeclass = "1" 	if sizeclass == "XS"
				replace 	 sizeclass = "2" 	if sizeclass == "S"
				replace 	 sizeclass = "3" 	if sizeclass == "M"
				replace 	 sizeclass = "4" 	if sizeclass == "L"
				replace 	 sizeclass = "5" 	if sizeclass == "NA" | sizeclass == "NULL" 
				destring 	 sizeclass, replace
				label define sizeclass 1 "Micro" 2 "Small" 3 "Medium" 4 "Large" 5 "N/A"
				label values sizeclass sizeclass
				rename 		 sizeclass size_creditdata			// the majority of the firms are classified as N/A									

				
				*Size_creditdata is missing for the majority of observations, lets recover firms' size in Tax Registry 
				*--------------------------------------------------------------------------------------------------------------------------------->>
				merge 		m:1 fuid period using "$data\inter\Tax Registry.dta", keepusing(group_sme) keep (1 3)
				
				replace 	size_creditdata 	=  		group_sme if _merge == 3 //for the firms we found in tax registry, lets replace their size
				drop	 	_merge
				*--------------------------------------------------------------------------------------------------------------------------------->>

				**
				*Fund coverage
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 fund = "1" 		if fund == "Fondi Kosovar për Garanci Kreditore"
				replace 	 fund = "2" 		if fund == "Nuk mbulohet nga fondi"
				replace 	 fund = "3" 		if fund == "NULL"
				destring 	 fund, replace
				label define fund 1 "Kosovo Credit Guarantee Fund" 2 "Not covered by fund" 3 "N/A"
				label values fund fund
				*--------------------------------------------------------------------------------------------------------------------------------->>

				**
				*Collateral
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 collateral = "2" 	if collateral == "NULL"
				destring 	 collateral, replace
				label define collateral 0 "No" 1 "Yes" 2 "N/A"
				label values collateral collateral
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				
				*
				*Insolvency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				/*
				replace 	 insolvency = "2" 	if insolvency == "Riprogramim"
				replace 	 insolvency = "3" 	if insolvency == "Ristrukturim"
				replace 	 insolvency = "4" 	if insolvency == "N/A" 	| insolvency == "NA" 	| insolvency == "NULL" 
				destring 	 insolvency, replace
				label define insolvency 0 "No" 1 "Yes" 2 "Repogramming" 3 "Restructuring" 4 "N/A"
				label values insolvency insolvency
				*/
				drop insolvency
				
				**
				*Firms age
				*--------------------------------------------------------------------------------------------------------------------------------->>
				gen 		 birthyear = year(birthdate)
				rename 	 	 birthyear birthyear_creditdata
				bys 		 fuid: egen A = min(birthyear_creditdata)
				replace 	 birthyear_creditdata = A if birthyear_creditdata ==.
				drop 		 A
				gen  		 firms_age_creditdata = period - birthyear_creditdata		//age of the firm according to the credit dataset (so we can compare with firms' age in Tax Registry)
					
					
				*Other
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 income 		 = ""  	if income 			== "NULL"
				replace 	 disbursedamount = "" 	if disbursedamount 	== "NULL"
				replace 	 collateralvalue = "" 	if collateralvalue 	== "NULL"
				replace 	 irate_nominal 	 = "" 	if irate_nominal 	== "NULL"
				replace 	 irate_effec 	 = "" 	if irate_effec 		== "NULL"
				replace 	 fundcoverage 	 = "" 	if fundcoverage 	== "NULL"
				destring 	 income dis* coll* irate* fund*, replace
				*--------------------------------------------------------------------------------------------------------------------------------->>
				

				**
				*All amounts in Euros
				*--------------------------------------------------------------------------------------------------------------------------------->>
				merge 		m:1 ApprovedMonthYear using "$data\inter\usd-to-euro-ex.dta", keep (1 3) nogen
				replace 	loanamount   	 = loanamount/exchange_rate  	 if currency == 2	
				replace 	disbursedamount  = disbursedamount/exchange_rate if currency == 2	
				replace 	amountout  		 = amountout/exchange_rate 		 if currency == 2	
				replace 	collateralvalue  = collateralvalue/exchange_rate if currency == 2		
				
				
				**
				*Errors
				*--------------------------------------------------------------------------------------------------------------------------------->>
				drop 		if loanamount == 0 | missing(loanamount) 
				drop 		if missing(fuid)
				
				
				**
				*Duplicates
				*--------------------------------------------------------------------------------------------------------------------------------->>
				order 			fuid fiscalid procedureid loanid ApprovedMonthYear  period loanamount irate_nominal irate_effec currency disbursedamount amountout disbursementdate 	///
					loanpurpose reprogrammed loantype loanclass loanperiod payfreq loanduration institution country collateral collateralvalue 								/// 
					entrydate approvaldate maturity persontype legaltype size_creditdata birthdate municipality income occupation maritalstatus fund fundcoverage
				
				duplicates report 	fuid ApprovedMonthYear loanid 
				
				sort 				fuid loanid ApprovedMonthYear 
				
				egen du = tag(fuid loanid)
				
				br 					fuid loanid du ApprovedMonthYear maturity irate_nominal loanamount loanperiod loanclass  loanduration duration  loanpurpose payfreq
				
				duplicates drop 	fuid loanid ApprovedMonthYear, force 
				
				br 					fuid loanid ApprovedMonthYear maturity irate_nominal loanamount loanperiod loanclass  loanduration duration  loanpurpose payfreq
				
				drop du
					
					
				**
				*Size of the firm
				*--------------------------------------------------------------------------------------------------------------------------------->>
																									//for ex: firm A, loan 1-> micro, firm A, loan 2-> small.
				//variable size is also available in the credit registry data, thats why I rename the variable here. 
				//when we merge loan dataset with tax registry dataset, we can use this variable in case the variable size is missing in tax registry
					//same year, different loan ids and the same firm is registered with distinct sizes
				bys 	fuid period: egen A = mode(size_creditdata)
				count 											 		if A != size_creditdata			
				gen 	error = 1 										if A != size_creditdata
				bys 	fuid period: egen max_error = max(error)
				sort 	fuid period
				br 		fuid period size_creditdata group_sme A error max_error 	if max_error       == 1
				replace size_creditdata = A  				 			if !missing(A)	& missing(group_sme)	//for the same year, lets replace firm's size with the mode of firms size for that specific year
				replace size_creditdata = 5								if  missing(A)  & missing(group_sme) & max_error == 1
				drop 	A error max_error

				
				**
				*Amounts in EUR 2018
				*--------------------------------------------------------------------------------------------------------------------------------->>
				local ppi2021 100
				local ppi2020 96.75858732
				local ppi2019 96.56545641
				local ppi2018 94.0450491
				local ppi2017 93.06783681
				local ppi2016 91.70148469
				local ppi2015 91.45455738
				local ppi2014 91.95109329
				local ppi2013 91.55739648
				local ppi2012 89.9650157
				local ppi2011 87.78787637
				local ppi2010 81.78486712
				forvalues 	period  = 2010(1)2021{
					foreach var of varlist loanamount disbursedamount collateralvalue {
						if `period' == 2010 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
						if `period' != 2010 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
					}
				}
				format *amount* %15.2fc
				order fuid period loanid 
				sort  fuid period loanid
				
				
				**Loan classification (a measure of risk)
				*--------------------------------------------------------------------------------------------------------------------------------->>
				gen 	classA = loanclass == "A"
				replace classA = . if inlist(loanclass, "L", "W")
				replace classA = . if period == 2016 & fund == 2	//only 3 loans covered by KCGF in 2016. 
				
				
				**
				*Outliers in terms of interest rates and duration according to firms' size
				*---------------------------------------------------------------------------------------------------------------------------------->>
				*A lot of contracts are registered with interest rates equal to 0. 
				sort 	fuid period
				br 		fuid period loanid approvaldate maturity duration loanclass if duration		 == 0
				
				replace irate_nominal 	= . 										if irate_nominal == 0
				replace duration 		= . 										if duration 	 == 0
				
				foreach size_creditdata in 1 2 3 4 5 {
					su 		irate_nominal 											if size_creditdata == `size_creditdata', detail
					replace	irate_nominal = . 										if size_creditdata == `size_creditdata' & (irate_nominal < r(p5) | irate_nominal > r(p95))
					su 		duration 												if size_creditdata == `size_creditdata', detail
					replace duration 	  = . 										if size_creditdata == `size_creditdata' & (duration 	 <= r(p5) | duration	 >=r(p95))
				}
				
				
				su duration,detail		//80 months is the max duration
				
				//for cases that duration is missing, lets calculate the duration for loans in which we have maturity date and approval date
				replace 	duration 	  = (maturity - approvaldate)/30 			if duration == . & !missing(maturity) & !missing(approvaldate) & (maturity - approvaldate)/30 < r(max) & (maturity - approvaldate)/30 > r(min) & (maturity - approvaldate)/30 > 0 
				
				
				**
				*Payment of interest rates
				gen 	 installment = loanamount_r/duration

				
				foreach size_creditdata in 1 2 3 4 5 {
					su 		installment												if size_creditdata == `size_creditdata', detail
					replace	installment	= . 										if size_creditdata == `size_creditdata' & (installment	 < r(p5) | installment	 > r(p95))
				}

				
				gen interestmonth 		= ((((1+irate_nominal/100)^(1/12))^duration)-1)*loanamount_r					 	if duration < 12  											& !missing(installment)
				gen interest1 			=     (irate_nominal/100)*loanamount_r 												if duration >= 12 					& !missing(duration)	& !missing(installment)
				gen interest2 			= (((1+irate_nominal/100)^2) - 1)*(loanamount_r - 12*installment) 					if duration >= 24					& !missing(duration)	& !missing(installment)
				gen interest3 			= (((1+irate_nominal/100)^3) - 1)*(loanamount_r - 24*installment) 					if duration >= 36					& !missing(duration)	& !missing(installment)
				gen interest4 			= (((1+irate_nominal/100)^4) - 1)*(loanamount_r - 36*installment) 					if duration >= 48					& !missing(duration)	& !missing(installment)
				gen interest5 			= (((1+irate_nominal/100)^5) - 1)*(loanamount_r - 48*installment) 					if duration >= 60					& !missing(duration)	& !missing(installment)
				gen interest6 			= (((1+irate_nominal/100)^6) - 1)*(loanamount_r - 60*installment) 					if duration >= 72					& !missing(duration)	& !missing(installment)
				gen interest1months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(loanamount_r - 12*installment) 	if duration > 12 & duration < 24							& !missing(installment)
				gen interest2months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(loanamount_r - 24*installment)  	if duration > 24 & duration < 36							& !missing(installment)
				gen interest3months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(loanamount_r - 36*installment)  	if duration > 36 & duration < 48							& !missing(installment)
				gen interest4months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(loanamount_r - 48*installment)  	if duration > 48 & duration < 60							& !missing(installment)
				gen interest5months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(loanamount_r - 60*installment)  	if duration > 60 & duration < 72							& !missing(installment)
				egen total_interest = rowtotal(interest*), missing
			
				br 	 loanamount_r total_interest duration irate_nominal interest* 

				compress
				save 	"$data\inter\Credit Registry.dta", replace
				
				br 		fuid period loanid size_creditdata loanamount loanclass loanperiod loanduration maturity fund fundcoverage irate_nominal irate_effec
				bys 	period fuid: gen t = _N
				su 		t, detail 
				sort 	fuid period
				sort 	t
			    br 		t fuid period loanid approvaldate loanamount duration maturity irate_* loanclass fund approvaldate if t > 100
		}		
		*______________________________________________________________________________________________________________________________________*
		
		
		**
		** Loans collapsed at firm-year level -> panel of firms,
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{ //the previous dataset is not a panel, as the same firm can have multiple loans in the year t. 
		  //lets collapse loans by year/firm in order to have a panel and merge credit data with tax registry data. 
			use "$data\inter\Credit Registry.dta", clear
		
				**
				*Identifying Loan and Loan with KCGF
				gen 	num_loans 		= 1									//when we collapse using (sum)num_loans, we know how many loans that firm had for each one of the years in the panel
				gen 	num_loans_kcgf  = 1 				if fund == 1
				
				**
				*First year the firm ever got a loan
				bys 	fuid: egen first_loan = min(period) 			
				bys 	fuid: egen first_kcgf = min(period) if fund == 1
				bys 	fuid: egen   A = max(first_loan)
				bys		fuid: egen   B = max(first_kcgf)
				replace first_loan = A
				replace first_kcgf = B

				foreach var of varlist loanamount* disbursedamount* irate* duration {	//let's disaggregate kcgf loans from other loans
					gen 	`var'_kcgf 	= `var' if fund == 1
					replace `var'  		= . 	if fund == 1							//we will have one loan amount for kcgf loans and one loan amount for other loans. 
				}
				
				**		
				*Collapsing Loan Data by firm & year
					*Each row shows:
					*-> The average loan amount 
					*-> The total loan amount
					*-> The average interest rate of the loans
				collapse 	(sum)  loanamount* disbursed* num_loans num_loans_kcgf 	collateralvalue*					 	///
							///
							(mean) first_loan first_kcgf  irate*  birthyear_creditdata firms_age_creditdata	duration* 		///
							, by (fuid period size_creditdata)
							
					foreach var of varlist *amount* {
						replace `var' = . if `var' == 0
					}		
					
				gen 	has_collateral = collateralvalue > 0
				replace has_collateral = . if missing(collateralvalue)
				format 		*amount* %15.2fc	
				compress
				save 	  "$data\inter\Credit Registry_firm-year-level.dta", replace
		}
		*______________________________________________________________________________________________________________________________________*

		
		
		**
		**KCGF-> Dataset with only KCGF loans
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			import excel using "$data\raw\KCGF.xlsx", allstring clear firstrow
					
					keep	///
					FinancialInstitution Municipality Product TypeofClient 														///
					ApprovedAmount ApprovedDate DisbursementAmount DisbursementDate GuaranteePercentageRequested 				///
					NominalInterestrate EffectiveInterestRate Maturity GracePeriod 												///
					Region Section Division 																					///
					TotalAssetsofBusiness NoOfEmployees ProjectedNoOfEmployees BusinessAnnualTurnover ProjectedAnnualTurnover	///
					KCGFLoanStatus LoanStatus TotalCollateralvalue
					
					destring, replace
					rename  NoOfEmployees employees
					rename  BusinessAnnualTurnover turnover
					rename (Maturity NominalInterestrate) (duration irate_nominal)
					
					**
					*Error
					replace employees = . 	if employees == 0
					replace turnover = . 	if turnover  == 0
					

					*---------------------------------------------------------------------------------------------------------------------------------->>
					foreach var of varlist ApprovedDate DisbursementDate {
					    generate aux`var' = date(`var', "DMY")
						format   aux`var' %td
						drop 		`var'
						rename   aux`var' `var'
						
						if "`var'" == "ApprovedDate" 	 gen 	ApprovedMonthYear 	  = mofd(`var')  
						if "`var'" == "DisbursementDate" gen 	DisbursementMonthYear = mofd(`var')  
							format  *MonthYear %tm
					}
					
					gen 	period = year(ApprovedDate)
					rename (ApprovedAmount DisbursementAmount TotalCollateralvalue) (loanamount disbursedamount collateralvalue)
					drop	 					if ApprovedDate == .	//one observation
					
					
					*---------------------------------------------------------------------------------------------------------------------------------->>
					gen 	group_period = 1 	if period <= 2019
					replace group_period = 2 	if period >= 2020 & Product != "Economic Recovery Window"
					replace group_period = 3 	if period >= 2020 & Product == "Economic Recovery Window"
		
		
					*Size 
					*---------------------------------------------------------------------------------------------------------------------------------->>
					gen		size 			= .
					replace size 			= 1 if employees <  10 
					replace size 			= 2 if employees >= 10  & employees 		< 50
					replace size 			= 3 if employees >= 50  & employees 		< 250
					replace size 			= 4 if employees >= 250 & !missing(employees)
					label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)"
					label 	values size size
					rename  size   size_kcgf
					*---------------------------------------------------------------------------------------------------------------------------------->>
					
					
					**
					*Outliers in terms of interest rates and duration according to firms' size
					*---------------------------------------------------------------------------------------------------------------------------------->>
					/*
					foreach size_kcgf  in 1 2 3 4 5 {
						su 		irate_nominal 			if size_kcgf == `size_kcgf', detail
						replace	irate_nominal = . 		if size_kcgf == `size_kcgf' & (irate_nominal < r(p5) | irate_nominal > r(p95)) & r(N) > 10
						su 		duration 				if size_kcgf == `size_kcgf', detail
						replace duration 	  = . 		if size_kcgf == `size_kcgf' & (duration 	 < r(p5) | duration	     > r(p95)) & r(N) > 10			
					}
					*/
					*---------------------------------------------------------------------------------------------------------------------------------->>
									
					
					**
					*---------------------------------------------------------------------------------------------------------------------------------->>
					gen 		economic_recovery = Product == "Economic Recovery Window"	//identifying if a loan is Economic Recovery Window. 
					
					
					**
					*Amounts in EUR 2021
					*--------------------------------------------------------------------------------------------------------------------------------->>
					local ppi2021 100
					local ppi2020 96.75858732
					local ppi2019 96.56545641
					local ppi2018 94.0450491
					local ppi2017 93.06783681
					local ppi2016 91.70148469
					local ppi2015 91.45455738
					local ppi2014 91.95109329
					local ppi2013 91.55739648
					local ppi2012 89.9650157
					local ppi2011 87.78787637
					local ppi2010 81.78486712

					keep if 	period >= 2010
					forvalues 	period  = 2010(1)2021 {
						foreach var of varlist loanamount disbursedamount turnover  collateralvalue {
							if `period' == 2010 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
							if `period' != 2010 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
						}
					}
					
					foreach size_kcgf in 1 2 3 4 5 		  {
						su 		turnover_r 	    	if size_kcgf == `size_kcgf', detail
						replace turnover_r  = . 	if size_kcgf == `size_kcgf' & (turnover_r     <= r(p5) | turnover_r     >= r(p95))
					}
					
					gen     productivity_r   = turnover_r/employees	//sales divided by number of employees
					foreach size_kcgf in 1 2 3 4 5  	  {
						su 		productivity_r		if size_kcgf == `size_kcgf', detail
						replace productivity_r = . 	if size_kcgf == `size_kcgf' & (productivity_r <= r(p5) | productivity_r >= r(p95))
					}
					
					
					**
					*Loan amount as % of turnover
					*---------------------------------------------------------------------------------------------------------------------------------->>
					clonevar temp = loanamount_r
					foreach size_kcgf in 1 2 3 4 5		  {
						su 		 temp		if size_kcgf == `size_kcgf', detail
						replace  temp = . 	if size_kcgf == `size_kcgf' & ( temp      < r(p5) |  temp              > r(p95))
					}
					gen 		shareloan_turnover 		= (temp/turnover_r)*100
					su			shareloan_turnover		, detail
					replace 	shareloan_turnover 		= . 	if shareloan_turnover < r(p5) | shareloan_turnover > r(p95)
					*---------------------------------------------------------------------------------------------------------------------------------->>

					**
					*Payment of interest rates
					gen 	 installment = loanamount_r/duration
					
					foreach size_kcgf in 1 2 3 4 5 {
						su 		installment											if size_kcgf == `size_kcgf', detail
						replace	installment	= . 									if size_kcgf == `size_kcgf' & (installment	 < r(p5) | installment	 > r(p95))
					}

					gen interest1 			=     (irate_nominal/100)*temp 												if duration >= 12 					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest2 			= (((1+irate_nominal/100)^2) - 1)*(temp - 12*installment) 					if duration >= 24					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest3 			= (((1+irate_nominal/100)^3) - 1)*(temp - 24*installment) 					if duration >= 36					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest4 			= (((1+irate_nominal/100)^4) - 1)*(temp - 36*installment) 					if duration >= 48					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover) 
					gen interest5 			= (((1+irate_nominal/100)^5) - 1)*(temp - 48*installment) 					if duration >= 60					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest6 			= (((1+irate_nominal/100)^6) - 1)*(temp - 60*installment) 					if duration >= 72					& !missing(duration)	& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest1months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(temp - 12*installment)  	if duration > 12 & duration < 24							& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest2months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(temp - 24*installment)  	if duration > 24 & duration < 36							& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest3months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(temp - 36*installment)  	if duration > 36 & duration < 48							& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest4months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(temp - 48*installment)  	if duration > 48 & duration < 60							& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					gen interest5months 	= ((((1+irate_nominal/100)^(1/12))^duration)-1)*(temp - 60*installment)  	if duration > 60 & duration < 72							& !missing(installment) & !missing(temp) & !missing(shareloan_turnover)
					egen total_interest = rowtotal(interest*), missing
					
					

					br 		loanamount_r  temp  turnover_r shareloan_turnover installment irate_nominal interest1* if duration == 24
					format 	*amount* %15.2fc
					drop temp
					compress
					save "$data\inter\KCGF.dta", replace	
			}
		*______________________________________________________________________________________________________________________________________*
			

