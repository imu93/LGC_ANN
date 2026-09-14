#!/bin/bash

tRNA
file=$(echo *genomic.fa)
id=$(echo $file | sed -r "s/\..*//g")
tRNAscan-SE -Q -E --score 40 -j ${id}_tRNAscan.gff3 -o ${id}_tRNAs.tbl $file --thread 20
