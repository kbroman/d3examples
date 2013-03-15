#!/bin/bash
# simple shell script to run R to create csv file with lod scores: lod.csv

R CMD BATCH --no-save create_csv.R Rout.txt
