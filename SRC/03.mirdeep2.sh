#!/bin/bash

threads=10
genome=/home/isaac/storage/Data/KAREN_FILES/genome/caenorhabditis_macrosperma.nxCaeMacr1.1.genomic.fa
fqDir=/home/isaac/storage/Data/KAREN_FILES/sRNA/fastq
outdir=mirdeep2

mkdir -p "$outdir"
cd "$outdir"

# miRBase release 23
wget https://www.mirbase.org/download/CURRENT/mature.fa.gz
wget https://www.mirbase.org/download/CURRENT/hairpin.fa.gz

# Extract C. elegans miRNAs
extract_miRNAs mature.fa.gz cel > mature_cel.fa
extract_miRNAs hairpin.fa.gz cel > hairpin_cel.fa

# Extract H. bakeri miRNAs
extract_miRNAs mature.fa.gz hpo > mature_hbr.fa
extract_miRNAs hairpin.fa.gz hpo > hairpin_hbr.fa

# Combine related-species mature miRNAs
cat mature_cel.fa mature_hbr.fa > mature_other.fa

# Genome index
bowtie-build "$genome" bacteriophora


sample=$(basename "$fq" .fastq.gz)

mapper.pl "$fq" \
        -e \
        -h \
        -j \
        -l 18 \
        -p bacteriophora \
        -s "${sample}_collapsed.fa" \
        -t "${sample}_vs_genome.arf" \
        -v

miRDeep2.pl \
        "${sample}_collapsed.fa" \
        "$genome" \
        "${sample}_vs_genome.arf" \
        none \
        mature_other.fa \
        hairpin_cel.fa \
        -t C.elegans \
        -P \
        > "${sample}_miRDeep2.log" 2>&1
