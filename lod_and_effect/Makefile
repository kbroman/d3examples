
all: lod_and_effect.js insulinlod.json

lod_and_effect.js: lod_and_effect.coffee
	coffee -c lod_and_effect.coffee

insulinlod.json: R/grab_data.R R/aligned_geno_with_pmap.RData R/lipomics_final_rev2.RData
	cd R;R CMD BATCH grab_data.R

web: all
	scp index.html lod_and_effect.coffee lod_and_effect.css lod_and_effect.js insulinlod.json broman-2.biostat.wisc.edu:public_html/D3/lod_and_effect/
