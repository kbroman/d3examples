all: lodchart.js test_lodchart.js scanone.json

lodchart.js: lodchart.coffee
	coffee -bc lodchart.coffee

test_lodchart.js: test_lodchart.coffee
	coffee -c test_lodchart.coffee

scanone.json: scanone2json.R create_test_data.R
	R CMD BATCH create_test_data.R

web: all
	scp index.html lodchart.* *.json test_lodchart.* broman-2:public_html/D3/lodchart/
