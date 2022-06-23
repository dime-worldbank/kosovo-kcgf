use "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/firm_year_level_no_nans.dta", clear

destring isic_4d, replace
*xtset fuid period
reg participation ethnicity export_tx age employees_tx hh_labor_sector i.isic_4d i.period, vce(robust)
