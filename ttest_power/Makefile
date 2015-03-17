all: ttest_power.js distributions.js

%.js: %.coffee
	coffee -bc $(<F)

web: ttest_power.js distributions.js
	scp index.html ttest_power.css *.js broman-10:public_html/D3/ttest_power/
