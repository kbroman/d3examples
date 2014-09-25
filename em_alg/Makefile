
all: em_alg.js data.json
.PHONY: all web

# R_OPTS: --vanilla without --no-environ
R_OPTS=--no-save --no-restore --no-init-file --no-site-file

%.js: %.coffee
	coffee -bc $^

data.json: create_data.R
	R CMD BATCH ${R_OPTS} $^

web: all
	scp index.html em_alg.js data.json broman-2.biostat.wisc.edu:public_html/D3/em_alg/
