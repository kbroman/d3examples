
all: cistrans.js data/insulin_eqtl.json data/probe_data/probe10002171767.json cistrans_rev.coffee

cistrans.js: cistrans.coffee
	coffee -c cistrans.coffee

cistrans_rev.js: cistrans_rev.coffee
	coffee -c cistrans_rev.coffee

data/insulin_eqtl.json: R/grab_data.R R/annot.amit_rev.RData R/maxlod.islet.RData R/aligned_geno_with_pmap.RData R/islet_mlratio_final.RData
	cd R;R CMD BATCH grab_data.R

data/probe_data/probe10002171767.json: R/grab_lod_curves.R R/annot.amit_rev.RData R/maxlod.islet.RData R/islet_mlratio_final.RData R/scanone.islet.RData R/aligned_geno_with_pmap.RData 
	cd R;R CMD BATCH grab_lod_curves.R

web:
	scp index.html cistrans.coffee cistrans.css cistrans.js cistrans_rev.coffee cistrans_rev.css cistrans_rev.js index_rev.html broman-2.biostat.wisc.edu:public_html/D3/cistrans/
