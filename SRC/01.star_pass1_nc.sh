#!/bin/bash

# Define variables
threads=10
gFile=nxHetBact1.1.genomic.fa.masked
gnmDir=/home/isaac/LCG_ANN/GENOME
fqDir=/home/isaac/LCG_ANN/FASTQ_mRNA

cd "$fqDir"

for read1 in *_1.fastq.gz; do

    read2=${read1/_1.fastq.gz/_2.fastq.gz}
    out=$(echo "$read1" | sed 's/\..*//')

    echo "$out"

    # STAR alignment
    STAR \
        --runThreadN "$threads" \
        --genomeDir "$gnmDir" \
        --readFilesCommand gzip -dc \
        --outFileNamePrefix "${out}_p1" \
        --outFilterType BySJout \
        --outFilterMultimapNmax 50 \
        --alignSJoverhangMin 5 \
        --alignSJDBoverhangMin 1 \
        --outFilterMismatchNmax 999 \
        --outFilterMismatchNoverLmax 0.3 \
        --outFilterMismatchNoverReadLmax 0.1 \
        --alignIntronMin 21 \
        --alignIntronMax 20000 \
        --alignMatesGapMax 20000 \
        --genomeLoad NoSharedMemory \
        --outMultimapperOrder Random \
        --outSAMmultNmax 10 \
        --outSAMtype None \
        --outSAMmode None \
        --clip5pNbases 0 0 \
        --clip3pAdapterMMp .1 .1 \
        --clip3pAdapterSeq AGATCGGAAGAGCACACGT AGATCGGAAGAGCACACGT \
        --readFilesIn "$read1" "$read2"

done
