#!/bin/bash

# Number of CPU threads
threads=8
let rm_threads=$threads/4

# Genome FASTA
gPATH=/home/isaac/LCG_ANN/GENOME
genome=${gPATH}/nxHetBact1.1.genomic.fa

# Output directory
outdir=repeat_annotation

mkdir -p "$outdir"
cd "$outdir"


BuildDatabase \
    -name nxHetBact1 \
    $genome

RepeatModeler \
    -database nxHetBact1 \
    -LTRStruct \
    -threads $threads


RepeatMasker \
    -pa $rm_threads \
    -s \
    -lib nxHetBact1-families.fa \
    -xsmall \
    -gff \
    -dir repeatmasker \
    $genome


echo "RepeatModeler and RepeatMasker completed."
