all: script.js double_slider.js

%.js: %.coffee
	coffee -bc $<

web: all
	scp index.html *.js style.css broman-8.biostat.wisc.edu:Website/D3/d3doubleslider/
