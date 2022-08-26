	
	/*
	*________________________________________________________________________________________________________________________________* 
	**
	MASTER do file for the Analysis of the Kosovo Credit Guarantee Fund. 
	**
	*________________________________________________________________________________________________________________________________* 
	
	Author: Vivian Amorim
	vivianamorim5@gmail.com/vamorim@worldbank.org
	Last Update: August 2022
	
	**
	**
	The effects Kosovo Credit Guarantee Fund and descriptive statistics
	**
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	The KCGF
	**
	*--------------------------------------------------------------------------------------------------------------------------------*

		According to Tax Registry Data, in 2015, Kosovo had 37.3 thousand active firms, and more than 90% were classified as micro-enterprises.
		Less than 25% of these firms had access to credit, whereas the percentage reaches 70% for medium and large firms. 

		The average sales per employee of micro firms are three times lower than the one presented by small, medium, and large firms. 
		Also, micro-firms are more likely to stop their operations. While nearly 20% of active micro firms in 2015 ended up stopping 
		their operations between 2016 and 2018, 4\% of medium and large firms did so
			
		As expected, firms with no credit history are less likely to get loans. In 2015, nearly 75% of micro firms with no loans 
		did not have access to lending in the previous five years as well. For the ones that were able to get a loan, the average annual 
		interest rate is 4 percentage points higher than the one applied to medium and large firms (11% versus 7%).
		
		In this context, the Kosovo Ministry of Trade and Industry, with the support of the US Agency for International Development, 
		created the Kosovo Credit Guarantee Fund (KCGF). KCGF is a credit guarantee facility issuing portfolio loan guarantees to 
		financial institutions to cover up to 50\% of the risk of loans to micro, small, and medium enterprises (MSMEs). 
		KCGF aims to support the private sector by increasing access to finance by MSMEs, which might lead to job-creating, 
		increase production, improve the trade balance, and enhance opportunities for under-served economic sectors.
		  
		The borrower benefits from potentially preferential interest rates, collateral reduction, and faster processing time for loan applications.  
		The partner financial institutions have a reduction in credit risk, as well as capital relief and credit portfolio growth.  
	   
		Since 2016, 11 thousand loans have been covered by KCGF, totaling more than 455 million euros.
		
		KCGF eligibility
		- Firms with less than 250 employees (MSMEs). 
		- Private owned MSMEs. 
		- At least 50\% owned by private citizens or permanent residents of Kosovo.
		- Firms with business registration and fiscal numbers (formal firms).
		
		To had access to Tax Registry and Credit Registry Data to investigate the impact of KCGF on firms' productivity, total sales and employment. 
		
		
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	Folder structure, C:\Users\wb495845\OneDrive - WBG\Kosovo\DataWork
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		*Data -> raw folder -> files: 
		
				- KCGF.xlxs. File shared by the Kosovo Credit Guarantee Fund. It has data on loans covered by the fund.
				
				- LoanApplications-Final.xlsx. File shared by the Central Bank. It has data on loans approved to the firms in Kosovo.
				
				- Tax Registry.csv. File shared by the Tax authority of Kososo. It has data on employment, sales, and other
				firms' characteristics.
				
				- usd-to-euro. File that contains the exchange rate USD, EUR
				
			   -> inter and final folders -> all the files in these folders are created after running the do files. 
		
		*Output -> folders for  figures and tables 
	
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	This master do file runs the following codes: 
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		**
		**
		- 1. Tax Registry.do
			
			Several characteristics of firms in Kosovo: sector of activity, municipality, employment, sales, whether the firm imports/exports, etc
				
		- 2. Credit Registry & KCGF.do
		
			All loans approved to firms in Kosovo. Loan amount, duration, interest rates. 
		
		- 3. Setting up the IE Data.do 
		
			Merging Tax Registry and Credit Registry Data -> we create a panel of firms in Kosovo.
		
		- 4. Descriptives.do
		
			Figures and Tables showing firms' characteristics, and descriptive statistics of KCGG and non-KCGF loans. 
		
		- 5. IE.do
			
			Estimate of the impact of KCGF on firms' productivity, employment, sales and probability of stopping operations. 
	
	
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Installing Packages and Standardize Settings
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	   Installing packages needed to run all dofiles called by this master dofile. */
	   ieboilstart, version(15)          	
	   `r(version)' 
	   set more off, permanently 
	   local user_commands ietoolkit rdrobust
	   foreach command of local user_commands   {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
	   }		

		**Figure settings
		graph set window fontface "Times"
		set scheme s1mono
		
		**Others
		set matsize 11000
        set level   95
		set seed    740592
		
		clear all
		mata: mata clear 
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Preparing Folder Paths
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	   * Users
	   * -------------------------*
	   * Vivian                  1    
	   * Next User               2    

	   *Set this value to the user currently using this file
	   global user  1
		   
		 if $user == 1 {
			global projectfolder 		"C:\Users\wb495845\OneDrive - WBG\Kosovo\DataWork" 
			global firmdynamics			"C:\Users\wb495845\OneDrive - WBG\Kosovo\IFC_Firm Dynamics and Productivity"
			global data		    	 	"$projectfolder\data"
			global output        		"$projectfolder\output"
			global code_firmdynamics	"$firmdynamics\do files"
			global data_firmdynamics	"$firmdynamics\data"
			global dofiles       	 	"C:\Users\wb495845\OneDrive - WBG\Documents\GitHub\kosovo-kcgf\Do files"
		}

	/*
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Run the do-files
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		do "$dofiles\1. Tax Registry.do"
		do "$dofiles\2. Credit Registry & KCGF.do"
		do "$dofiles\3. Setting up the IE Data.do"
		do "$dofiles\4. Descriptives.do"
		do "$dofiles\5. IE.do"
