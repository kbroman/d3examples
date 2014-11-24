manypoints_canvas_all.js: manypoints_canvas_all.coffee
	coffee -bc $<

web: manypoints_canvas_all.js
	scp *.js *.html broman-9.biostat.wisc.edu:public_html/D3/manypoints/canvas_all/
