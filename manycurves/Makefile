
all: manycurves.js curves.json

R/curves.RData: R/prep_data.R R/rep1_rev.csv
	cd R;R CMD BATCH prep_data.R

curves.json: R/curves.RData R/grab_data.R
	cd R;R CMD BATCH grab_data.R

manycurves.js: manycurves.coffee
	coffee -c manycurves.coffee

web:
	scp index.html manycurves.coffee manycurves.css manycurves.js curves.json broman-2.biostat.wisc.edu:public_html/D3/manycurves/
