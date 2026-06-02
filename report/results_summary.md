# P3 WGS Variant Calling — Results Summary

## Pipeline Results

| Step | Input | Output | Key Metric |
|------|-------|--------|-----------|
| FastQC | 9.3GB FASTQ | HTML reports | Quality confirmed |
| Trimmomatic | 68.8M read pairs | 53.3M clean pairs | 77.48% retained |
| BWA-MEM | 53.3M pairs | 6.9GB BAM | 28.45% mapped to chr1 |
| Picard | 6.9GB BAM | 7.2GB dedup BAM | 6.07% dup rate |
| GATK | 7.2GB BAM | 120MB VCF | 609,255 raw variants |
| Filtering | 609,255 variants | 401,716 PASS SNPs | 76.3% passed |
| SnpEff | 401,716 SNPs | Annotated VCF | 43 HIGH impact |

## Top Genes (SnpEff)

| Gene | Variants | Function |
|------|----------|----------|
| CAMTA1 | 7,343 | Calcium-binding transcription factor |
| KAZN | 2,366 | Cytoskeletal protein |
| EIF4G3 | 1,707 | Translation initiation factor |
| RERE | 1,304 | Chromatin remodelling |
| EPHB2 | 1,232 | Receptor tyrosine kinase |

## Impact Breakdown

| Impact | Count |
|--------|-------|
| MODIFIER | 88,723 |
| MODERATE | 1,698 |
| HIGH | 43 |
