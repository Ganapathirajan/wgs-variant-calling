#!/bin/bash
gatk HaplotypeCaller \
    -R ref/chr1.fa \
    -I results/variants/dedup.bam \
    -O results/variants/raw_variants.vcf \
    --sample-name NA12878 \
    2>&1 | tee logs/gatk.log
