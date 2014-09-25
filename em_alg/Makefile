
all: panelutil.js scatterplot.js test_scatterplot.js data.json

# R_OPTS: --vanilla without --no-environ
R_OPTS=--no-save --no-restore --no-init-file --no-site-file

%.js: %.coffee
	coffee -bc $^

data.json: create_data.R
	R CMD BATCH ${R_OPTS} $^
