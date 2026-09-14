#!/bin/bash

rfamPath=/ceph/users/imartinez/worms_raw/db/rfam_14.10
file=$(echo *.genomic.fa)
echo $file
id=$(echo $file | sed  "s/\..*//")
echo $id
ntb=${id}_deoverlapped.tbl


# I will use cmpress to get the number of nt and bc to use as numeric
# cmpress $rfamPath/Rfam.cm
# estimate genome size with esl-seqstat
gs=$(esl-seqstat $file | grep "^Total" | awk '{print $NF}')
# *2 because we have two strands
gs=$(($gs*2))
# divide by 10000000 beacuse cmscan requires GS in Mb
f=$(echo $gs/1000000 |jq -nf /dev/stdin)
echo $f
# Let's run cmscan over the genome
cmscan -Z $f --cpu 20 --rfam --cut_ga --nohmmonly --tblout ${id}_fmt2.tbl --fmt 2 --clanin $rfamPath/Rfam.clanin $rfamPath/Rfam.cm $file > ${id}.cmscan
echo pred end
grep -v " = " ${id}_fmt2.tbl | grep -v "#" > $ntb
echo "##gff-version 3" > ${id}.infernal.gff3

awk '{ if($12 == "-"){start=$11+1; end=$10+1} else {start=$10; end=$11}; printf "%s\tinfernal\t%s\t%d\t%d\t%7.2f\t%s\t.\tRfamID=%s;description=%s %s %s %s %s %s %s\n" ,$4,$2,start,end,$17    ,$12,$3,$27,$28,$29,$30,$31,$32,$33 }' $ntb >> ${id}.infernal.gff3
