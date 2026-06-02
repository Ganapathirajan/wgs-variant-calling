#!/bin/bash
mkdir -p data ref
# Download reference
wget -P ref/ https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr1.fa.gz
gunzip ref/chr1.fa.gz
bwa index ref/chr1.fa
samtools faidx ref/chr1.fa
gatk CreateSequenceDictionary -R ref/chr1.fa
# Download data
fastq-dump --split-files --gzip SRR098401 --outdir data/
