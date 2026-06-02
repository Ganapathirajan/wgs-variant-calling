#!/bin/bash
# Filter SNPs
gatk SelectVariants -R ref/chr1.fa -V results/variants/raw_variants.vcf \
    --select-type-to-include SNP -O results/variants/raw_snps.vcf

gatk VariantFiltration -R ref/chr1.fa -V results/variants/raw_snps.vcf \
    --filter-expression "QD < 2.0" --filter-name "QD2" \
    --filter-expression "FS > 60.0" --filter-name "FS60" \
    --filter-expression "MQ < 40.0" --filter-name "MQ40" \
    --filter-expression "SOR > 3.0" --filter-name "SOR3" \
    -O results/variants/filtered_snps.vcf

# Annotate with SnpEff
snpEff hg38 results/variants/filtered_snps.vcf \
    > results/variants/annotated.vcf \
    2>&1 | tee logs/snpeff.log
