

	*__________________________________________________________________________________________________________________________________________*
	**

	*LOAN DATASETS
	
		
		**
		** Credit Registry Data -> each row is a loan ID for firm i, year t, the same firm can have several loans in the same year
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			**
			*Importing
			*------------------------------------------------------------------------------------------------------------------------------------->>
			/***
			import excel using  "$data_firmdynamics\Kosovo Credity Registry\LoanApplications-Final.xlsx", clear firstrow 
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

				
				**
				*Renaiming variables
				*--------------------------------------------------------------------------------------------------------------------------------->>
				rename PersonBusinessNo 		lenderfiscalid  /*In case the business (from the list) is in related role to the loan then `Fake ID` of the business appears in the column “Fake Person Business No” */
				rename FakepersonbusinessNo 	fuid_lender
				rename IdNumber	 				fiscalid
				rename FakeIdNumber 			fuid 			/*when it is the borrower then it appears in the column “Fake Id Number”*/
				rename LoanNo 					loanid
				rename Id 						procedureid 
				rename ApprovalDate 			approvaldate
				rename BirthDate 				birthdate
				rename Institution 				institution
				rename PersonType 				persontype
				rename LegalEntityType 			legaltype
				rename Municipality 			municipality
				rename MaritalStatus 			maritalstatus
				rename Occupation 				occupation
				rename Income 					income
				rename LoanType 				loantype
				rename LoanActivityType 		loanactvitytype
				rename LoanPeriod 				loanperiod
				rename Period 					loanduration
				rename PaymentFrequency 		payfreq
				rename Amount 					loanamount
				rename OutstandingAmount 		amountout
				rename Currency 				currency
				rename MaturityDate 			maturity
				rename DisbursementDate 		disbursementdate
				rename DisbursementAmount 		disbursedamount
				rename EntryDateTime 			entrydate
				rename LoanClassification 		loanclass
				rename CollateralValue 			collateralvalue
				rename CollateralUsed 			collateral
				rename LoanPurpose 				loanpurpose
				rename Country 					country
				rename NominalInterestRate 		irate_nominal
				rename EffectiveInterestRate 	irate_effec
				rename Code 					code
				rename CompanySize 				sizeclass
				rename Fund 					fund
				rename FundCoveredPercentage 	fundcoverage
				rename Reprogrammed 			reprogrammed
				rename Insolvency 				insolvency
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
				replace 	 loanperiod = "1" if loanperiod == "Ditor"
				replace 	 loanperiod = "2" if loanperiod == "Mujor"
				replace 	 loanperiod = "3" if loanperiod == "Vjetor"

				destring 	 loanperiod, replace
				label define loanperiod 1 "Daily" 2 "Monthly" 3 "Annual"
				label value  loanperiod loanperiod
				
				gen 		 duration = .											
				replace 	 duration = loanduration * (12 / 365) 	if loanperiod == 1
				replace 	 duration = loanduration 				if loanperiod == 2
				replace 	 duration = loanduration * 12 			if loanperiod == 3		//loan duration in months
				*--------------------------------------------------------------------------------------------------------------------------------->>

				
				**
				*Payment frequency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 payfreq = "1" if payfreq == "Ditore"
				replace 	 payfreq = "2" if payfreq == "Mujore"
				replace 	 payfreq = "3" if payfreq == "Kuartale"
				replace 	 payfreq = "4" if payfreq == "Gjysmevjetore"
				replace 	 payfreq = "5" if payfreq == "Vjetore"
				replace 	 payfreq = "6" if payfreq == "E Parregullt"
				replace 	 payfreq = "7" if payfreq == "E plote"
				replace 	 payfreq = "8" if payfreq == "Sipas kerkeses"
				replace 	 payfreq = "9" if payfreq == "NULL"

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
				replace country = "1" 	if country == "KOSOVA" 		| country == "KOSOVE" 	| country == "KOSOVO" 								///
										 | country == "KOSOVË" 		| country == "KS" 		| country == "Kosova" 		| country == "Kosovar" 	///
										 | country == "Kosove" 		| country == "Kosovo" 	| country == "Kosovë" 		| country == "XK" 		///
										 | country == "xk" 			| country == "Republika e Kosovës"
				replace country = "2" 	if country == "AL" 			| country == "ALBANIA" 	| country == "SHQIPERI" 	| country == "SHQIPRI"
				replace country = "3" 	if country == "MACEDONIA" 	| country == "MK" 		| country == "Macedonia" 	| country == "Maqedoni"
				replace country = "4" 	if country == "TR" 			| country == "TURKEY"
				replace country = "5" 	if country == "SI"
				replace country = "6" 	if country == "MALI I ZI"
				replace country = "7" 	if country == "HR" 			| country == "Croatia (Local Name: Hrvatska)"
				replace country = "8" 	if country == "GB" 			| country == "UNITED KINGDOM"
				replace country = "9" 	if country == "US"
				replace country = "10" 	if country == "DISELDORF" 	| country == "DE"
				replace country = "11" 	if country == "NULL"

				destring 	 country, replace
				label define country 1 "Kosovo"  2 "Albania" 	    3 "Macedonia"      4 "Turkey"   5 "Slovenia" 6 "Montenegro" ///
									 7 "Croatia" 8 "United Kingdom" 9 "United States" 10 "Germany" 11 "N/A"
				label values country country
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				*
				*Size class
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 sizeclass = "1" if sizeclass == "XS"
				replace 	 sizeclass = "2" if sizeclass == "S"
				replace 	 sizeclass = "3" if sizeclass == "M"
				replace 	 sizeclass = "4" if sizeclass == "L"
				replace 	 sizeclass = "5" if sizeclass == "NA" | sizeclass == "NULL" 

				destring 	 sizeclass, replace
				label define sizeclass 1 "Micro" 2 "Small" 3 "Medium" 4 "Large" 5 "N/A"
				label values sizeclass sizeclass
				*--------------------------------------------------------------------------------------------------------------------------------->>

				**
				*Fund coverage
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 fund = "1" if fund == "Fondi Kosovar për Garanci Kreditore"
				replace 	 fund = "2" if fund == "Nuk mbulohet nga fondi"
				replace 	 fund = "3" if fund == "NULL"

				destring 	 fund, replace
				label define fund 1 "Kosovo Credit Guarantee Fund" 2 "Not covered by fund" 3 "N/A"
				label values fund fund
				*--------------------------------------------------------------------------------------------------------------------------------->>

				**
				*Collateral
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 collateral = "2" if collateral == "NULL"
				destring 	 collateral, replace
				label define collateral 0 "No" 1 "Yes" 2 "N/A"
				label values collateral collateral
				*--------------------------------------------------------------------------------------------------------------------------------->>
				
				*
				*Insolvency
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	 insolvency = "2" if insolvency == "Riprogramim"
				replace 	 insolvency = "3" if insolvency == "Ristrukturim"
				replace 	 insolvency = "4" if insolvency == "N/A" 	| insolvency == "NA" 	| insolvency == "NULL" ///
																		| insolvency == "X" 	| insolvency == "x" | insolvency == "" | insolvency == ""
				destring 	 insolvency, replace
				label define insolvency 0 "No" 1 "Yes" 2 "Repogramming" 3 "Restructuring" 4 "N/A"
				label values insolvency insolvency

				**
				*Firms age
				*--------------------------------------------------------------------------------------------------------------------------------->>
				gen 		 birthyear = year(birthdate)
				rename 	 	 birthyear birthyear_creditdata
				bys 		 fuid: egen A = min(birthyear_creditdata)
				replace 	 birthyear_creditdata = A if birthyear_creditdata ==.
				drop 		 A
				gen 		 period  			  = year(approvaldate)
				gen  		 firms_age_creditdata = period - birthyear_creditdata
					
					
				*Other
				*--------------------------------------------------------------------------------------------------------------------------------->>
				replace 	income 			= ""  	if income 			== "NULL"
				replace 	disbursedamount = "" 	if disbursedamount 	== "NULL"
				replace 	collateralvalue = "" 	if collateralvalue 	== "NULL"
				replace 	irate_nominal 	= "" 	if irate_nominal 	== "NULL"
				replace 	irate_effec 	= "" 	if irate_effec 		== "NULL"
				replace 	fundcoverage 	= "" 	if fundcoverage 	== "NULL"
				destring 	income dis* coll* irate* fund*, replace
				
					
				order 			fuid fiscalid procedureid loanid ApprovedMonthYear  period loanamount irate_nominal irate_effec currency disbursedamount amountout disbursementdate 	///
					loanpurpose reprogrammed loantype loanclass loanperiod payfreq loanduration institution country collateral collateralvalue insolvency								/// 
					entrydate approvaldate maturity persontype legaltype sizeclass birthdate municipality income occupation maritalstatus fund fundcoverage

				duplicates drop fuid fiscalid procedureid loanid ApprovedMonthYear  period loanamount irate_nominal irate_effec currency disbursedamount amountout disbursementdate 	///
					loanpurpose reprogrammed loantype loanclass loanperiod payfreq loanduration institution country collateral collateralvalue insolvency							 	/// 
					entrydate approvaldate maturity persontype legaltype sizeclass birthdate municipality income occupation maritalstatus fund fundcoverage, force
				*--------------------------------------------------------------------------------------------------------------------------------->>
				

				**
				*All amounts in Euros
				*--------------------------------------------------------------------------------------------------------------------------------->>
				merge m:1 ApprovedMonthYear using "$data\inter\usd-to-euro-ex.dta", keep (1 3) nogen
		
				replace loanamount   	 = loanamount/exchange_rate  	 if currency == 2	
				replace disbursedamount  = disbursedamount/exchange_rate if currency == 2	
				replace amountout  		 = amountout/exchange_rate 		 if currency == 2	
					
				**
				*Errors
				*--------------------------------------------------------------------------------------------------------------------------------->>
				drop if loanamount == 0 | missing(loanamount) 
				drop if missing(fuid)
				
				keep if period >= 2010
								
				
				************************************>>>> 
				rename 	sizeclass size_creditdata													//same year, different loans and the same firm is registered with distinct sizes
																									//firm A, loan 1-> micro, firm A, loan 2-> small.
				bys 	fuid period:egen A = mode(size_creditdata)
				count 											 if A != size_creditdata			
				gen 	error = 1 								 if A != size_creditdata
				bys 	fuid period: egen max_error = max(error)
				sort 	fuid period
				br 		fuid period size_creditdata A error max_error if max_error == 1
				replace size_creditdata = A  				 if !missing(A)							//for the same year, lets replace firm's size with the mode of firms size for that specific year
				replace size_creditdata= . 				 if size_creditdata != A
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
					foreach var of varlist loanamount disbursedamount {
						if `period' == 2010 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
						if `period' != 2010 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
					}
				}
				format *amount* %15.2fc
				order fuid period loanid 
				sort  fuid period loanid
				compress
				save "$data\inter\Credit Registry.dta", replace
				br fuid period loanid size_creditdata loanamount loanclass loanperiod loanduration maturity fund fundcoverage irate_nominal irate_effec
				count if irate_nominal == 0
		}		
		
		
		
		**
		** Loans collapsed at firm-year level -> panel of firms,
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			use "$data\inter\Credit Registry.dta", clear
		
				**
				*Identifying Loan and Loan with KCGF
				gen 	num_loans 		= 1					if 				loanamount  != .  &  loanamount  	!= 0
				gen 	num_loans_kcgf  = 1 				if fund == 1 &  loanamount  != .  &  loanamount  	!= 0
				
				**
				*First year the firm ever got a loan
				bys 	fuid: egen first_loan = min(period) if 				loanamount  != .  &  loanamount  	!= 0
				bys 	fuid: egen first_kcgf = min(period) if fund == 1 &	loanamount  != .  &  loanamount  	!= 0
				bys 	fuid: egen   A = max(first_loan)
				bys		fuid: egen   B = max(first_kcgf)
				replace first_loan = A
				replace first_kcgf = B

				foreach var of varlist loanamount* disbursedamount* irate* duration {
					gen 	`var'_kcgf 	= `var' if fund == 1
					replace `var'  		= . 	if fund == 1
					
				}
				
				**		
				*Collapsing Loan Data by firm & year
					*Each row shows:
					*-> The average loan amount 
					*-> The total loan amount
					*-> The average interest rate of the loans
				collapse 	(sum)  loanamount* disbursed* num_loans num_loans_kcgf 						 			  ///
							///
							(mean) first_loan first_kcgf  irate*  birthyear_creditdata firms_age_creditdata	duration* ///
							, by (fuid period size_creditdata)
							
					foreach var of varlist *amount* {
						replace `var' = . if `var' == 0
					}		
				format 		*amount* %15.2fc	
				compress
				save 	  "$data\inter\Credit Registry_firm-year-level.dta", replace
		}

		
		
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
					KCGFLoanStatus LoanStatus 
					destring, replace
					rename NoOfEmployees employees
					rename BusinessAnnualTurnover turnover
					gen    productivity = turnover/employees	//sales divided by number of employees

					
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
					rename (ApprovedAmount DisbursementAmount) (loanamount disbursedamount)
					drop	 if ApprovedDate == .	//one observation
					
					
					*---------------------------------------------------------------------------------------------------------------------------------->>
					gen 	group_period = 1 if period <= 2019
					replace group_period = 2 if period >= 2020 & Product != "Economic Recovery Window"
					replace group_period = 3 if period >= 2020 & Product == "Economic Recovery Window"
		
		
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
						foreach var of varlist loanamount disbursedamount turnover productivity {
							if `period' == 2010 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
							if `period' != 2010 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
						}
					}
					
					replace employees = . if employees == 0
					
					format *amount* %15.2fc
					compress
					save "$data\inter\KCGF.dta", replace	
			}
			
			
			
			
			
			
			
			
			
	
