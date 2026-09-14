#!/bin/bash

# Define variables
threads=10
gFile=nxHetBact1.1.genomic.fa.masked
gnmDir=/home/isaac/LCG_ANN/GENOME  # Directory containing the STAR genome index
fqDir=/home/isaac/LCG_ANN/FASTQ_mRNA

cd $fqDir

for read1 in *_1.fastq.gz; do

    # Identify corresponding Read 2
    read2=${read1/_1.fastq.gz/_2.fastq.gz}

    # Generate output sample name by removing the extension
    out=$(echo $read1 | sed 's/\..*//')

    echo $out

    STAR \
    
    # Number of CPU threads to use
    --runThreadN $threads \

    # Directory containing the genome index generated with STAR --runMode genomeGenerate
    --genomeDir $gnmDir \

    # Command used to decompress gzipped FASTQ files
    --readFilesCommand gzip -dc \

    # Prefix for STAR output files
    --outFileNamePrefix ${out}_p1 \

    # Filter type based on splice-junction evidence
    # DEFAULT: Normal filtering is not BySJout
    --outFilterType BySJout \

    # Maximum number of loci to which a read can map
    # DEFAULT: 10
    # Here: allow up to 50 multimapping loci
    --outFilterMultimapNmax 50 \

    # Minimum overhang for non-canonical splice junctions
    # DEFAULT: 5
    --alignSJoverhangMin 5 \

    # Minimum overhang for splice junctions supported by the genome annotation
    # DEFAULT: 3
    # Here: more permissive, allowing junctions supported by only 1 bp
    --alignSJDBoverhangMin 1 \

    # Maximum absolute number of mismatches allowed per read
    # DEFAULT: 10
    # 999 effectively removes this absolute mismatch limit;
    # the relative mismatch filters below still apply
    --outFilterMismatchNmax 999 \

    # Maximum fraction of mismatches relative to the read length
    # DEFAULT: 0.3
    --outFilterMismatchNoverLmax 0.3 \

    # Maximum fraction of mismatches relative to the mapped read length
    # DEFAULT: 1.0
    # Here: requires at least ~90% of the read to match
    --outFilterMismatchNoverReadLmax 0.1 \

    # Minimum allowed intron length
    # DEFAULT: 21 bp
    --alignIntronMin 21 \

    # Maximum allowed intron length
    # Here: maximum intron size is 20 kb
    --alignIntronMax 20000 \

    # Maximum allowed gap between mates in paired-end reads
    # Here: mates can be separated by up to 20 kb
    --alignMatesGapMax 20000 \

    # Do not load the genome into shared memory
    # DEFAULT: NoSharedMemory
    --genomeLoad NoSharedMemory \

    # Randomize the order in which multimapping alignments are reported
    # Useful when downstream analysis only retains a subset of multimappers
    --outMultimapperOrder Random \

    # Maximum number of multimapping alignments reported per read
    # DEFAULT: -1 (report all)
    --outSAMmultNmax 10 \

    # Do not generate SAM/BAM alignment output
    --outSAMtype None \

    # Do not generate SAM alignment output
    --outSAMmode None \

    # Number of nucleotides to clip from the 5' end of Read 1 and Read 2
    # DEFAULT: 0 0
    --clip5pNbases 0 0 \

    # Maximum fraction of mismatches allowed in the adapter sequence
    # Here: 10% mismatch tolerance for adapter detection
    --clip3pAdapterMMp .1 .1 \

    # 3' adapter sequences to detect and remove
    # Illumina TruSeq adapter
    --clip3pAdapterSeq AGATCGGAAGAGCACACGT AGATCGGAAGAGCACACGT \

    # Paired-end FASTQ files
    --readFilesIn $read1 $read2

done
