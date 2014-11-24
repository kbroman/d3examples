manypoints_svg.js: manypoints_svg.coffee
	coffee -bc $<

web: manypoints_svg.js
	scp *.js *.html broman-9.biostat.wisc.edu:public_html/D3/manypoints/svg/
