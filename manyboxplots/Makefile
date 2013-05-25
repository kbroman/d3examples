
all: manyboxplots.js hypo.json

manyboxplots.js: manyboxplots.coffee
	coffee -c manyboxplots.coffee

hypo.json: R/grab_data.R R/F2.mlratio.hypo.RData
	cd R;R CMD BATCH grab_data.R

web: all
	scp index.html manyboxplots.coffee manyboxplots.css manyboxplots.js hypo.json broman-2.biostat.wisc.edu:public_html/D3/manyboxplots/
