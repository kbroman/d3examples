
all: linked_heatmaps.js loglik.json

linked_heatmaps.js: linked_heatmaps.coffee
	coffee -c linked_heatmaps.coffee

loglik.json: R/all_loglik.RData R/ll2json.R
	cd R;R CMD BATCH ll2json.R
