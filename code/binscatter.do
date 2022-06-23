use "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/firm_year_level.dta", clear

* variables of interest: 
* ['Productivity', 'Productivity_t-1', 'Serbian-majority municipality', 'Exporting firm', 'Age', 'Number of employees', 'Market concentration']


binscatter kcgf Number_of_employees
graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/firm_size.png", replace

binscatter kcgf Age, line(qfit)
graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/age.png", replace

*binscatter participation Exporting_firm
*graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/exporting_firm.png", *replace

binscatter kcgf Productivity
graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/productivity.png", replace

binscatter kcgf Productivity_t_1
graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/productivity_lag1.png", replace

binscatter kcgf Market_concentration
graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/market_concentration.png", replace

*binscatter participation Serbian_majority_municipality
*graph export "/Users/simonneumeyer/Dropbox/ie_kosovo/data/output/graphs/binscatter_plots/ethnicity.png", replace

