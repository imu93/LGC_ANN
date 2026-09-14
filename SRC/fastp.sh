#!/bin/bash

for file in *.fastq.gz; do
outfile=$(echo $file | sed 's/.fastq.gz/.trimmed.fastq.gz/')
fastp \
    -i $file \
    -o $outfile \
    --adapter_sequence TGGAATTCTCGGGTGCCAAGGAA \
    --cut_mean_quality 20 \
    --length_required 18 \
    --thread 10 \
    --json sample.fastp.json \
    --html ${file}.fastp.html
done
