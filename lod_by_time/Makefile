
all: lod_by_time.js all_lod.json

lod_by_time.js: lod_by_time.coffee
	coffee -c lod_by_time.coffee

all_lod.json: R/grab_all_lod.R R/spal.RData R/out.RData
	cd R;R CMD BATCH grab_all_lod.R

web: all
	scp index.html lod_by_time.coffee lod_by_time.css lod_by_time.js all_lod.json broman-2.biostat.wisc.edu:public_html/D3/lod_by_time/
