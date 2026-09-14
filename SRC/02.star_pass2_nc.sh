#!/bin/bash

threads=10
gnmDir=/home/isaac/storage/Data/KAREN_FILES/star/genome
fqDir=/home/isaac/storage/Data/KAREN_FILES/star/fastq
pass1=pass1
pass2=pass2

cd "$fqDir"
mkdir -p "$pass2"

# Combine splice junctions from all PASS 1 samples
cat ${pass1}/*p1SJ.out.tab > ${pass1}/all_SJ.out.tab

for read1 in *_1.fastq.gz; do

    read2=${read1/_1.fastq.gz/_2.fastq.gz}
    out=$(echo "$read1" | sed 's/\..*//')

    echo "Running STAR PASS 2 for: $out"

    STAR \
        --runThreadN "$threads" \
        --genomeDir "$gnmDir" \
        --readFilesCommand gzip -dc \
        --outFileNamePrefix "${pass2}/${out}_p2" \
        --outFilterType BySJout \
        --outFilterMultimapNmax 10 \
        --alignSJoverhangMin 5 \
        --alignSJDBoverhangMin 3 \
        --outFilterMismatchNoverLmax 0.3 \
        --outFilterMismatchNoverReadLmax 0.1 \
        --alignIntronMin 5 \
        --alignIntronMax 20000 \
        --alignMatesGapMax 20000 \
        --genomeLoad NoSharedMemory \
        --outMultimapperOrder Random \
        --outSAMmultNmax 50 \
        --outSAMtype BAM Unsorted \
        --outReadsUnmapped Fastx \
        --outSAMmode Standard \
        --clip5pNbases 0 0 \
        --clip3pAdapterMMp .1 .1 \
        --clip3pAdapterSeq AGATCGGAAGAGCACACGT AGATCGGAAGAGCGTCGTG \
        --sjdbFileChrStartEnd "${pass1}/all_SJ.out.tab" \
        --readFilesIn "$read1" "$read2" \
        --outSAMstrandField intronMotif

done
