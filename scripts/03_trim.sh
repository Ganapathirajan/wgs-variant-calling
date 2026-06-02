#!/bin/bash
trimmomatic PE \
    data/SRR098401_1.fastq.gz data/SRR098401_2.fastq.gz \
    data/trimmed_R1.fastq.gz data/trimmed_R1_unpaired.fastq.gz \
    data/trimmed_R2.fastq.gz data/trimmed_R2_unpaired.fastq.gz \
    ILLUMINACLIP:$CONDA_PREFIX/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
    2>&1 | tee logs/trimmomatic.log
