#!/bin/bash
mkdir -p results/plots
fastqc data/SRR098401_1.fastq.gz data/SRR098401_2.fastq.gz -o results/plots/ -t 2
