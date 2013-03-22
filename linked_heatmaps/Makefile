
all: linked_heatmaps.js loglik.json

linked_heatmaps.js: linked_heatmaps.coffee
	coffee -c linked_heatmaps.coffee

loglik.json: R/all_loglik.RData R/ll2json.R
	cd R;R CMD BATCH ll2json.R

web:
	scp index.html linked_heatmaps.coffee linked_heatmaps.css linked_heatmaps.js loglik.json broman-2:public_html/D3/linked_heatmaps/
