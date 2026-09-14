# Genome Annotation of *Heterorhabditis bacteriophora*

En esta práctica vamos a realizar la anotación estructural del genoma de *Heterorhabditis bacteriophora*.

## Objetivos

Identificar y anotar:

- Elementos repetitivos
- Genes codificantes de proteínas
- RNA ribosomal (rRNA)
- Transfer RNA (tRNA)
- Otros RNA no codificantes (ncRNA)
- microRNA (miRNA)

La anotación combinará evidencia genómica, transcriptómica y de homología.

---

## 1. Genoma

El ensamblaje utilizado es:

```text
nxHetBact1.1.genomic.fa
```

Este archivo contiene la secuencia ensamblada del genoma de *H. bacteriophora* y será utilizado como referencia durante las diferentes etapas.

---

## 2. Elementos repetitivos

Los elementos repetitivos pueden representar una fracción importante de los genomas eucariontes. Utilizaremos RepeatModeler para identificar familias de repeticiones de novo y RepeatMasker para localizarlas y enmascararlas.

### 2.1 RepeatModeler

```bash
BuildDatabase     -name nxHetBact1     nxHetBact1.1.genomic.fa

RepeatModeler     -database nxHetBact1     -LTRStruct     -threads 8
```

RepeatModeler genera una biblioteca de familias de elementos repetitivos. Uno de los principales resultados es:

```text
nxHetBact1-families.fa
```

### 2.2 RepeatMasker

```bash
RepeatMasker     -pa 2     -s     -lib nxHetBact1-families.fa     -xsmall     -gff     -dir repeatmasker     nxHetBact1.1.genomic.fa
```

| Parámetro | Descripción |
|---|---|
| `-pa 2` | Número de procesadores utilizados |
| `-s` | Búsqueda sensible |
| `-lib` | Biblioteca de repeticiones utilizada |
| `-xsmall` | Produce un genoma soft-masked |
| `-gff` | Genera resultados en formato GFF |
| `-dir` | Directorio de resultados |

El genoma soft-masked será utilizado en etapas posteriores de la anotación.

---

## 3. Evidencia transcriptómica

La evidencia de RNA-seq permite identificar regiones transcritas, exones y splice junctions.

Utilizaremos STAR para alinear las lecturas RNA-seq contra el genoma.

### 3.1 Generación del índice de STAR

```bash
STAR     --runThreadN 12     --runMode genomeGenerate     --genomeDir /home/isaac/LCG_ANN/GENOME     --genomeFastaFiles nxHetBact1.1.genomic.fa.masked     --genomeSAindexNbases 10
```

| Parámetro | Descripción |
|---|---|
| `--runThreadN` | Número de hilos utilizados |
| `--runMode genomeGenerate` | Genera el índice del genoma |
| `--genomeDir` | Directorio donde se almacena el índice |
| `--genomeFastaFiles` | Genoma utilizado |
| `--genomeSAindexNbases` | Tamaño del índice suffix array |

---

## 4. STAR Pass 1

En Pass 1, STAR alinea las lecturas RNA-seq e identifica splice junctions.

El archivo principal generado es:

```text
SJ.out.tab
```

```bash
STAR     --runThreadN 10     --genomeDir "$gnmDir"     --readFilesCommand gzip -dc     --outFileNamePrefix "${pass1}/${out}_p1"     --outFilterType BySJout     --outFilterMultimapNmax 50     --alignSJoverhangMin 5     --alignSJDBoverhangMin 1     --outFilterMismatchNmax 999     --outFilterMismatchNoverLmax 0.3     --outFilterMismatchNoverReadLmax 0.1     --alignIntronMin 21     --alignIntronMax 20000     --alignMatesGapMax 20000     --genomeLoad NoSharedMemory     --outMultimapperOrder Random     --outSAMmultNmax 10     --outSAMtype None     --outSAMmode None     --clip5pNbases 0 0     --clip3pAdapterMMp .1 .1     --clip3pAdapterSeq AGATCGGAAGAGCACACGT AGATCGGAAGAGCACACGT     --readFilesIn "$read1" "$read2"
```

---

## 5. STAR Pass 2

En Pass 2 utilizamos los splice junctions identificados en todas las muestras durante Pass 1.

Primero combinamos los archivos:

```bash
cat pass1/*p1SJ.out.tab > pass1/all_SJ.out.tab
```

Después utilizamos el archivo combinado como evidencia:

```bash
STAR     --runThreadN 10     --genomeDir "$gnmDir"     --readFilesCommand gzip -dc     --outFileNamePrefix "${pass2}/${out}_p2"     --outFilterType BySJout     --outFilterMultimapNmax 10     --alignSJoverhangMin 5     --alignSJDBoverhangMin 3     --outFilterMismatchNoverLmax 0.3     --outFilterMismatchNoverReadLmax 0.1     --alignIntronMin 5     --alignIntronMax 20000     --alignMatesGapMax 20000     --genomeLoad NoSharedMemory     --outMultimapperOrder Random     --outSAMmultNmax 50     --outSAMtype BAM Unsorted     --outReadsUnmapped Fastx     --outSAMmode Standard     --clip5pNbases 0 0     --clip3pAdapterMMp .1 .1     --clip3pAdapterSeq AGATCGGAAGAGCACACGT AGATCGGAAGAGCGTCGTG     --sjdbFileChrStartEnd "${pass1}/all_SJ.out.tab"     --readFilesIn "$read1" "$read2"     --outSAMstrandField intronMotif
```

Los archivos BAM generados constituyen una fuente de evidencia transcriptómica para la predicción de genes.

---

## 6. Identificación de rRNA

Utilizaremos Barrnap para identificar genes de RNA ribosomal.

```bash
barrnap     --kingdom euk     --threads 10     nxHetBact1.1.genomic.fa     > nxHetBact1_barrnap.gff3
```

| Parámetro | Descripción |
|---|---|
| `--kingdom euk` | Utiliza modelos para organismos eucariontes |
| `--threads 10` | Número de hilos utilizados |
| `genome.fa` | Genoma analizado |
| `> *.gff3` | Guarda las predicciones en formato GFF3 |

Resultado:

```text
nxHetBact1_barrnap.gff3
```

---

## 7. Identificación de tRNA

Los genes de tRNA serán identificados utilizando tRNAscan-SE:

```bash
tRNAscan-SE     -Q     -E     --score 40     -j nxHetBact_tRNAscan.gff3     -o nxHetBact_tRNAs.tbl     nxHetBact1.1.genomic.fa     --thread 20
```

Resultados principales:

```text
nxHetBact_tRNAscan.gff3
nxHetBact_tRNAs.tbl
```

---

## 8. Identificación de otros ncRNA

Para identificar otros RNA no codificantes utilizaremos Infernal junto con Rfam.

Rfam contiene modelos de covarianza que incorporan información de secuencia y estructura para identificar familias de ncRNA.

```bash
cmscan     -Z $f     --cpu 20     --rfam     --cut_ga     --nohmmonly     --tblout ${id}_fmt2.tbl     --fmt 2     --clanin $rfamPath/Rfam.clanin     $rfamPath/Rfam.cm     $file     > ${id}.cmscan
```

Los resultados se convierten posteriormente a GFF3:

```text
nxHetBact.infernal.gff3
```

---

## 9. Identificación de miRNA

Para identificar miRNA utilizaremos miRDeep2 y secuencias de referencia de miRBase.

Utilizaremos información de especies relacionadas con *H. bacteriophora*, incluyendo *Caenorhabditis elegans* y *Heterorhabditis bacteriophora*.

### 9.1 Secuencias de referencia

```bash
wget https://www.mirbase.org/download/CURRENT/mature.fa.gz
wget https://www.mirbase.org/download/CURRENT/hairpin.fa.gz
```

Extraemos las secuencias de *C. elegans*:

```bash
extract_miRNAs mature.fa.gz cel > mature_cel.fa
extract_miRNAs hairpin.fa.gz cel > hairpin_cel.fa
```

Las secuencias de *H. bacteriophora* se extraen utilizando el identificador correspondiente de miRBase:

```bash
extract_miRNAs mature.fa.gz <species_code> > mature_hbr.fa
extract_miRNAs hairpin.fa.gz <species_code> > hairpin_hbr.fa
```

Combinamos las secuencias maduras:

```bash
cat mature_cel.fa mature_hbr.fa > mature_other.fa
```

### 9.2 Mapping de small RNA

Construimos un índice Bowtie:

```bash
bowtie-build nxHetBact1.1.genomic.fa bacteriophora
```

Los reads de small RNA se procesan y alinean utilizando `mapper.pl`:

```bash
mapper.pl "$fq"     -e     -h     -j     -l 18     -p bacteriophora     -s "${sample}_collapsed.fa"     -t "${sample}_vs_genome.arf"     -v
```

Finalmente ejecutamos miRDeep2:

```bash
miRDeep2.pl     "${sample}_collapsed.fa"     "$genome"     "${sample}_vs_genome.arf"     none     mature_other.fa     none     -t H.bacteriophora     -P     > "${sample}_miRDeep2.log" 2>&1
```

miRDeep2 utiliza los small RNA, sus alineamientos al genoma y las secuencias de referencia para identificar candidatos a miRNA.

---

## 10. Predicción de genes codificantes

La predicción de genes codificantes combinará diferentes fuentes de evidencia:

- Evidencia de RNA-seq
- Evidencia de proteínas
- Predicción ab initio
- Evidencia de especies relacionadas

Utilizaremos BRAKER para generar modelos génicos.

Los BAM de RNA-seq obtenidos durante STAR Pass 2 deben estar ordenados e indexados:

```bash
samtools sort sample_p2Aligned.out.bam     -o sample_p2.sorted.bam

samtools index sample_p2.sorted.bam
```

Los BAM pueden proporcionarse como evidencia transcriptómica:

```bash
braker.pl     --genome nxHetBact1.1.genomic.fa.masked     --bam sample1_p2.sorted.bam sample2_p2.sorted.bam     --softmasking
```

BRAKER integra la evidencia disponible para producir modelos de genes.

---

## 11. Integración de la anotación

Al finalizar las diferentes etapas tendremos archivos de anotación correspondientes a distintas clases de elementos:

```text
RepeatMasker
Barrnap
tRNAscan-SE
Infernal/Rfam
miRDeep2
BRAKER
```

Cada herramienta identifica una clase diferente de elementos genómicos. Estos resultados deberán integrarse para obtener una anotación estructural completa del genoma.

---

## 12. Evaluación de la anotación

La anotación final debe evaluarse antes de considerarse completa.

Algunos aspectos que podemos analizar son:

- Número total de genes
- Número de exones
- Número de intrones
- Longitud de genes
- Longitud de exones e intrones
- Distribución de genes a lo largo del genoma
- Genes con evidencia transcriptómica
- Genes con evidencia de homología
- Elementos repetitivos
- rRNA
- tRNA
- Otros ncRNA
- miRNA
- Completitud de los modelos génicos

---

## Pipeline general

```text
                         Genome
                           |
                           v
                    RepeatModeler
                           |
                           v
                     RepeatMasker
                           |
                           v
                    Soft-masked genome
                           |
             +-------------+-------------+
             |                           |
             v                           v
          RNA-seq                      ncRNA
             |                           |
             v                +----------+----------+
         STAR Pass 1          |          |          |
             |              rRNA       tRNA      Infernal
             v
      Splice junctions
             |
             v
         STAR Pass 2
             |
             v
      RNA-seq evidence
             |
             +--------------------+
                                  |
                                  v
                           Gene prediction
                                  |
                                  v
                                BRAKER
                                  |
                                  v
                       Structural annotation
                                  |
                                  v
                       Annotation evaluation
```

El resultado final será una anotación estructural del genoma de *Heterorhabditis bacteriophora* que integre genes codificantes, RNA no codificante y elementos repetitivos.
