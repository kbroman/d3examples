R_OPTS=--no-save --no-restore --no-init-file --no-site-file # --vanilla, but without --no-environ

anscombe_quartet.json: grab_anscombe.R
	R CMD BATCH $(R_OPTS) $(<F)
