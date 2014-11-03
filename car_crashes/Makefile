all: data.json car_crashes.js

.PHONY: all

R_OPTS=--no-save --no-restore --no-init-file --no-site-file

data.json: data2json.R proper_data.R data.R
	R CMD BATCH ${R_OPTS} $<

%.js: %.coffee
	coffee -bc $<

web: all
	scp data.json index.html car_crashes.css car_crashes.js broman-10.biostat.wisc.edu:public_html/D3/car_crashes
