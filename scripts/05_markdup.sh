#!/bin/bash
picard MarkDuplicates \
    -I results/variants/aligned_sorted.bam \
    -O results/variants/dedup.bam \
    -M results/variants/dedup_metrics.txt \
    --VALIDATION_STRINGENCY SILENT \
    2>&1 | tee logs/picard.log
samtools index results/variants/dedup.bam
