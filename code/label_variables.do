use "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/firm_year_level.dta", clear

* variables of interest:
* ['Productivity', 'Productivity_t-1', 'Serbian-majority municipality', 'Exporting firm', 'Age', 'Number of employees', 'Market concentration']

label variable Age "Firm age"
label var credit "1 if the firm got a loan this year, 0 otherwise"
label var Productivity "Sales per employee"
label var Productivity_t_1 "Sales per employee at t-1"
label var Serbian_majority_municipality "1 if the firm is located in a Serbian-majority municipality, 0 otherwise"
label var Exporting_firm "1 if the form has non-zero amount of exports, 0 otherwise"
label var import_tx "1 if the form has non-zero amount of imports, 0 otherwise"
label var Number_of_employees "Number of employees"
label var approvedamount_eu_r "Approved loan amount in Euros, deflated"
label var amountout_eu "Outstanding amount in EUR"
label var amountout_eu_r "Outstanding amount in EUR, deflated"
label var onlyexport_tx "1 if firm only exports, 0 otherwise"
label var onlyimport_tx "1 if firm only imports, 0 otherwise"
label var exports_vat "Exported amount"
label var exports_vat_r "Exported amount, deflated"
label var imports_vat "Imported amount"
label var imports_vat_r "Imported amount, deflated"
label var trade_balance "Exported amount minus imported amount"
label var export_sh "Share of exports from total gross turnover (turnover_gross_vat)"
label var exit "1 if firm exits at current period, 0 otherwise"
label var exit_alt "Alternative measure of exit: 1 if deathyear_tx== period, 0 otherwise"
label var exit_emp "Number of employees at the time of exit"
label var exit_turn "turnover (turnover_tx_r) at exit"
label var exiter "dummy that identifies firms that at some point in time will exit."
label var death_year "Year of firm exit"
label var fuid "Firm identifier"
label var period "Year"
label var isic_4d "4-digit sector code"
label var Market_concentration "Sector level market concentration based on turnover"
label var avirate_nominal "Avg. nominal interest rate"
label var avirate_effec "Avg. effective interest rate"
label var duration "Loan duration"
label var approvedamount_eu "Approved amount (EUR)"
label var duration_effec "Effective Loan duration"
label var disbursedamount_eu "Disbursed amount (EUR)"
label var amountout_eu "Outstanding amount (EUR)"
label var duration_effec "Effective Loan duration"
label var kcgf "dummy that identifies firms that have, at any point in time, been funded by KCGF"
label var kcgf_treated "1 if fund has already been applied, 0 otherwise"
*label var credit_sectorsh "Fraction of firms with access to credit"
*label var credit_munish "Fraction of firms with access to credit"
*label var credit_sectormunish "Fraction of firms with access to credit"
*label var credit_sectormunish "Fraction of firms with access to credit"
*label var loans_credit "Total disbursed loans (industry-level)"
*label var loans_credit_tot "Total disbursed loans"
*label var loanscredit_sh "Share of total loans (industry-level)"
*label var lnloans_credit "Log Total disbursed loans (industry-level)"
*label var irate_credit "Avg. nominal interest rate (industry-level)"
*label var irate_credit_tot "Avg. nominal
*label var avloan_credit  "Avg. loan per firm (industry-level)"
*label var lnavloan_credit "Log avg. loan per firm"

*label var gender_pr "Gender of decisionmaker"

*label var tfp "Log TFPR"
*label var lnY "Log Turnover"
*label var lnL "Log Employment"
*label var lnVA "Log Value Added"
*label var age "Age"
*label var age_bis "Age"
*label var ethnicity "Municipality majority"
*label var municipality "Municipality"
*label var nace_class_main "Sector (four-digit level)"
*label var size_tx "Size class"
*label var lnLprod "Log Value added per worker"
*label var lnK_emp "Log Capital stock per worker"




/*
OBS:

Below other variables that seem important and that I do not know the meaning. I added an * to the names which there are several vars.  If you don’t not the meaning of all the list, send me the ones you know, please. Then we can ask Lucio. I think it is important because the more information we have, the better.

Purchases*
Depreciation*
Wage*
costproduc * (total cost of production or cost per product?)
Costgoodsold
Depreciation**
Disbursement*
Duration
GDP*
Income* (only income and grossincome)
Labor*
Turnover*
Import*
Investment*
Nocommerce
Nonopexpense*
*/


save "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/firm_year_level.dta", replace
