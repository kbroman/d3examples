
all: manyboxplots2.js data.json

manyboxplots2.js: manyboxplots2.coffee
	coffee -c manyboxplots2.coffee

data.json: createJSON.R simData.R convert4manyboxplots2.R
	R CMD BATCH createJSON.R

web:
	scp index.html manyboxplots2.coffee manyboxplots2.css manyboxplots2.js data.json broman-2.biostat.wisc.edu:public_html/D3/manyboxplots2/

clean:
	rm manyboxplots2.js data.json
