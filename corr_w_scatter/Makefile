
all: corr_w_scatter.js data.json

corr_w_scatter.js: corr_w_scatter.coffee
	coffee -c corr_w_scatter.coffee

example_data.RData: example_data.R
	R CMD BATCH example_data.R

data.json: createJSON.R example_data.RData
	R CMD BATCH createJSON.R

web: all
	scp index.html corr_w_scatter.coffee corr_w_scatter.css corr_w_scatter.js data.json broman-2.biostat.wisc.edu:public_html/D3/corr_w_scatter/

clean:
	rm corr_w_scatter.js data.json *.Rout
