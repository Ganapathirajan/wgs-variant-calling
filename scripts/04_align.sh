#!/bin/bash
mkdir -p results/variants logs
bwa mem -t 4 \
    -R "@RG\tID:SRR098401\tSM:NA12878\tPL:ILLUMINA\tLB:lib1" \
    ref/chr1.fa \
    data/trimmed_R1.fastq.gz data/trimmed_R2.fastq.gz \
    2> logs/bwa.log | \
    samtools sort -@ 4 -o results/variants/aligned_sorted.bam
samtools index results/variants/aligned_sorted.bam
