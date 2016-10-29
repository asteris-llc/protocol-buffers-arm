#!/bin/bash 

# generate converge graphs

for file in *.hcl; do
    converge graph --local ${file} | dot -Tpng -o graphs/$(basename ${file} .hcl).png
done
