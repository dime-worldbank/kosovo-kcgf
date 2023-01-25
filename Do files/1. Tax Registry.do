

	*__________________________________________________________________________________________________________________________________________*
	**

	*TAX REGISTRY DATASET SHARED BY THE GOVERNMENT OF KOSOVO - > FORMAL FIRMS
	
	/*
		In the following code, I do not exclude any outliers in terms of total sales, number of employees, sales per employee.		
	*/
	
		forvalues year = 2011(1)2021{
			import 	excel using "$data\raw\BB.xlsx", sheet(`year') clear 
			
			tempfile `year'
			save    ``year''
		}
			
			
	
		**
		*------------------------------------------------------------------------------------------------------------------------------------->>
		import 	delimited using "$data\raw\Tax Registry.csv", clear 
		
		//The dataset is a panel -> fuid (firm identification) and period (year in the Tax Registry)
		br cd_10	cd_17	cd_28	cd_66	cd_74	cd_77	cd_78
			**
			*Section of activities, employees and exports amount
			*---------------------------------------------------------------------------------------------------------------------------------->>
			rename 	(vat_11 		activitydivision activitysection numberofemployedpersons cd_74				) ///
					(exports_amount	divisionid		 sectionid        employees				 operational_profit ) 


			**
			*Total imports
			*---------------------------------------------------------------------------------------------------------------------------------->>
			egen 	imports_amount = rowtotal(vat_31  vat_33  vat_35  vat_37), missing 				//firm purchases that are imported -guess does not include investment (Matias Belacin comment)

			
			**
			*Correction of activity, division and sector. (Matias Belacin and Lucio Castro WB)
			*---------------------------------------------------------------------------------------------------------------------------------->>
			replace activityid 		= "-9999"    															 if (activityid   	== "xxxx"  		| activityid == "")
			replace divisionid 		= "-99" 																 if  activityid 	== "-9999"
			replace sectionid  		= "NA"  																 if  activityid   	== "-9999"
			replace activity   		= "NA" 																     if  activityid   	== "-9999"
			replace division   		= "NA" 																	 if  activityid   	== "-9999"
			replace section    		= "NA" 																	 if  activityid   	== "-9999"
			replace section   		= "PROFESSIONAL, SCIENTIFIC AND TECHNICAL ACTIVITIES" 					 if (sectionid		== "XX" 		& activityid == "7112")
			replace sectionid 		= "M" 																	 if (sectionid 		== "XX" 		& activityid == "7112")
			replace divisionid  	= "47"		 															 if (sectionid 		== "XX" 		& activityid == "4754")
			replace division 		= "Retail trade, except of motor vehicles and motorcycles" 				 if  division 		== "Unknown" 	& (sectionid == "XX" 	& activityid == "4754")
			replace section 		= "WHOLESALE AND RETAIL TRADE; REPAIR OF MOTOR VEHICLES AND MOTORCYCLES" if  section 		== "" 		 	& (sectionid == "XX" 	& activityid == "4754")
			replace sectionid 		= "G" 																	 if (sectionid 		== "XX" 		& activityid == "4754")
			
			destring activityid divisionid, replace
			labmask	 activityid			, values(activity)
			labmask  divisionid			, values(division)
			gen sec_activity = ""
			
			replace sec_activity = "Tertiary" 		if section == "WHOLESALE AND RETAIL TRADE; REPAIR OF MOTOR VEHICLES AND MOTORCYCLES"
			replace sec_activity = "Tertiary" 		if section == "ACCOMMODATION AND FOOD SERVICE ACTIVITIES"
			replace sec_activity = "Quaternary" 	if section == "PROFESSIONAL, SCIENTIFIC AND TECHNICAL ACTIVITIES"
			replace sec_activity = "Secondary" 		if section == "MANUFACTURING"
			replace sec_activity = "Primary" 		if section == "MINING AND QUARRYING"
			replace sec_activity = "Tertiary" 		if section == "OTHER SERVICE ACTIVITIES"
			replace sec_activity = "Tertiary" 		if section == "FINANCIAL AND INSURANCE ACTIVITIES"
			replace sec_activity = "Secondary" 		if section == "CONSTRUCTION"
			replace sec_activity = "Tertiary" 		if section == "INFORMATION AND COMMUNICATION"
			replace sec_activity = "Tertiary" 		if section == "TRANSPORTATION AND STORAGE"
			replace sec_activity = "Tertiary" 		if section == "ADMINISTRATIVE AND SUPPORT SERVICE ACTIVITIES"
			replace sec_activity = "Quaternary" 	if section == "EDUCATION"

			replace sec_activity = "Tertiary" 		if section == "HUMAN HEALTH AND SOCIAL WORK ACTIVITIES"
			replace sec_activity = "Primary" 		if section == "AGRICULTURE, FORESTRY AND FISHING"
			replace sec_activity = "Tertiary" 		if section == "ARTS, ENTERTAINMENT AND RECREATION"
			replace sec_activity = "Tertiary" 		if section == "PUBLIC ADMINISTRATION AND DEFENCE; COMPULSORY SOCIAL SECURITY"
			replace sec_activity = "Tertiary" 		if section == "REAL ESTATE ACTIVITIES"
			replace sec_activity = "" 				if section == "NA"
			replace sec_activity = "Secondary" 		if section == "WATER SUPPLY; SEWERAGE, WASTE MANAGEMENT AND REMEDIATION ACTIVITIES"
			replace sec_activity = "Secondary" 		if section == "ELECTRICITY, GAS, STEAM AND AIR CONDITIONING SUPPLY"
			replace sec_activity = "Tertiary" 		if section == "ACTIVITIES OF HOUSEHOLDS AS EMPLOYERS; U0NDIFFERENTIATED GOODS- AND SERVICES-PRODUCING ACTIVITIES OF HOUSEHOLDS FOR OWN USE"

			gen 	sec_activityid = 1 if sec_activity == "Primary"
			replace sec_activityid = 2 if sec_activity == "Secondary"
			replace sec_activityid = 3 if sec_activity == "Tertiary"
			replace sec_activityid = 4 if sec_activity == "Quaternary"
			labmask   sec_activityid			, values(sec_activity)
			drop 	 activity division
			*---------------------------------------------------------------------------------------------------------------------------------->>

			
			**
			*Size, in terms of number of employees 
			*---------------------------------------------------------------------------------------------------------------------------------->>
			gen		size 			= .
			replace size 			= 1 if employees <  10 
			replace size 			= 2 if employees >= 10  & employees 		< 50
			replace size 			= 3 if employees >= 50  & employees 		< 250
			replace size 			= 4 if employees >= 250 & !missing(employees)
			label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)"
			label 	values size size
			
			**Lots of 0s and missings. Check the variable "sme"
			*---------------------------------------------------------------------------------------------------------------------------------->>
			
			
			**
			*Import or export firm 
			*---------------------------------------------------------------------------------------------------------------------------------->>
			gen 	export_tx 		= exports_amount > 0 & exports_amount != .
			gen 	import_tx 		= imports_amount > 0 & imports_amount != .
			label 	define export_tx 1 "Export firm" 0 "No export firm"
			label 	define import_tx 1 "Import firm" 0 "No import firm"
			label	val export_tx export_tx
			label 	val import_tx import_tx

			
			**
			*Firms age
			*---------------------------------------------------------------------------------------------------------------------------------->>
			gen 	error = birthyear > period								//firms birth year > period, it does not make sense. 
			bys 	fuid period: egen firstyearpanel = min(period)		
			replace birthyear = firstyearpanel 			if error == 1		//for when the previous error happens, lets consider the birth year the first year of the firm in the panel. 
			gen 	firms_age = period - birthyear
			drop	firstyearpanel error
			
			
			**
			*Death year (year the firm stops operating)
			*---------------------------------------------------------------------------------------------------------------------------------->>
			replace  deathyear = substr(deathyear, -9,4)					//year the firm closed according to Tax Registry
			destring deathyear, replace
			
			
			**
			*Serbian maiority
			*---------------------------------------------------------------------------------------------------------------------------------->>
			gen 		 ethnicity = 0 
			foreach 	 munid in 12 14 23 28 29 34 35 36 37 3 {
				replace  ethnicity = 1 if municipalityid == `munid'
			}
			label define ethnicity 0 "Non-Serbian majority" 1 "Serbian majority"
			label values ethnicity ethnicity		


			*---------------------------------------------------------------------------------------------------------------------------------->>
			format *amount*  salaries* turnover* %15.2fc
			
			
			**
			*Dropping variables we do not need
			*---------------------------------------------------------------------------------------------------------------------------------->>
			drop ///
			 frameperiod year_* vat_* cd_* pd_* qs_* is_*
			
			egen 	group_sme = group(sme)
			
			*---------------------------------------------------------------------------------------------------------------------------------->>
			compress
			sort fuid period
			save "$data\inter\Tax Registry.dta", replace
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
