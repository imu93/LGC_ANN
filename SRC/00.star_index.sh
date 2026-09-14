#!/usr/local/bin


# Define variables
threads=12
gFile=nxHetBact1.1.genomic.fa.masked
gnmDir=/home/isaac/LCG_ANN/GENOME # Genome index this is the index dir


STAR --runThreadN $threads \
     --runMode genomeGenerate \
     --genomeDir $gnmDir \
     --genomeFastaFiles $gFile \
     --genomeSAindexNbases 10
