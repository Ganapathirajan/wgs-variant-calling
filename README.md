# Variant Calling WGS Pipeline

![Pipeline](https://img.shields.io/badge/Pipeline-WGS%20Variant%20Calling-blue)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)
![Tools](https://img.shields.io/badge/Tools-BWA%20%7C%20GATK4%20%7C%20Picard%20%7C%20SnpEff-green)
![Dataset](https://img.shields.io/badge/Dataset-NA12878%20%281000%20Genomes%29-orange)

A end-to-end whole genome sequencing (WGS) variant calling pipeline following GATK Best Practices. Identifies SNPs and indels from human genomic DNA using the gold-standard NA12878 reference sample.

---

## Project Overview

| Field | Details |
|---|---|
| **Project Type** | Bioinformatics / Genomics |
| **Domain** | Whole Genome Sequencing (WGS) |
| **Goal** | Identify SNPs and indels from human DNA |
| **Dataset** | NA12878 — 1000 Genomes Project (SRR098401) |
| **Reference Genome** | hg38 chr1 (UCSC) |
| **Output** | Annotated VCF file |

---

## Dataset

**Sample: NA12878 (HG001)**

NA12878 is the most extensively sequenced human genome in history. It is used as the gold standard for validating variant calling pipelines because:

- Sequenced 100+ times by multiple institutions worldwide
- Genome in a Bottle (GIAB) Consortium has published a verified truth set of known variants
- Results can be benchmarked against ground truth using tools like `hap.py`
- Used in all official GATK Best Practices documentation and benchmarks
- Collected from a female individual of Utah/European ancestry (CEPH collection)

**Accession:** SRR098401 — Paired-end Illumina WGS  
**Raw data size:** ~9.3 GB compressed (68.8 million read pairs)  
**Reference subset:** chr1 only (for compute efficiency on local machine)

---

## Pipeline Architecture

```
Raw FASTQ (SRR098401)
       │
       ▼
  ┌─────────┐
  │  FastQC  │  ──► QC Reports (HTML)
  └─────────┘
       │
       ▼
  ┌─────────────┐
  │ Trimmomatic  │  ──► Cleaned paired reads (77.48% retained)
  └─────────────┘
       │
       ▼
  ┌──────────┐
  │  BWA-MEM  │  ──► Aligned reads (SAM stream)
  └──────────┘
       │
       ▼
  ┌────────────────┐
  │ SAMtools sort  │  ──► Coordinate-sorted BAM
  │ SAMtools index │  ──► BAM index (.bai)
  └────────────────┘
       │
       ▼
  ┌──────────────────────┐
  │ Picard MarkDuplicates │  ──► Deduplicated BAM (6.07% dup rate)
  └──────────────────────┘
       │
       ▼
  ┌────────────────────┐
  │ GATK HaplotypeCaller│  ──► Raw variants VCF
  └────────────────────┘
       │
       ▼
  ┌────────────────┐
  │ GATK FilterVariants│  ──► Filtered SNPs VCF
  └────────────────┘
       │
       ▼
  ┌────────┐
  │ SnpEff  │  ──► Annotated VCF (gene names, functional impact)
  └────────┘
```

---

## Tools

### FastQC `v0.12.1`
Quality control on raw sequencing reads before processing.

Checks: per-base quality scores (Phred), adapter contamination, GC content bias, duplication rate, read length distribution. Outputs HTML report for visual inspection.

### Trimmomatic `v0.40`
Adapter trimming and quality filtering of raw reads.

```
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10   Remove Illumina TruSeq adapters
LEADING:3                              Trim low-quality bases from 5' end
TRAILING:3                             Trim low-quality bases from 3' end
SLIDINGWINDOW:4:15                     Sliding window quality trimming
MINLEN:36                              Discard reads shorter than 36bp
```

**Result:** 77.48% paired reads retained, 12.11% dropped (low quality/short)

### BWA-MEM `v0.7.19`
DNA sequence aligner using Burrows-Wheeler transformation.

Used for WGS alignment because it handles long reads (>70bp) better than alternatives, is optimized for human genome scale, and is the aligner officially recommended in GATK Best Practices. Unlike HISAT2 (used in RNA-seq), BWA-MEM is not splice-aware — correct for genomic DNA alignment.

Read Group tags (`@RG`) are embedded at alignment time, which are required by GATK for sample identification downstream.

### SAMtools `v1.23.1`
BAM file processing — coordinate sorting and indexing.

GATK requires reads to be sorted by genomic coordinate (not alignment order). The `.bai` index enables random access into the BAM file without full sequential reads.

### Picard MarkDuplicates `v3.4.0`
PCR duplicate identification and flagging.

During library preparation, PCR amplification creates multiple identical copies of the same original DNA fragment. Counting these as independent observations inflates variant allele frequencies and creates false positives. Picard identifies duplicate read pairs by their start coordinates and flags them so GATK ignores them during variant calling.

**Result:** 6.07% duplicate rate (excellent — anything under 20% is acceptable)

### GATK HaplotypeCaller `v4.6.2.0`
Core variant calling engine.

Operates in three stages:
1. Identifies active regions where reads deviate from the reference
2. Locally reassembles reads using a De Bruijn graph to reconstruct haplotypes
3. Calculates likelihood scores for each possible genotype and emits variants

The local reassembly step is what distinguishes GATK from simpler pileup-based callers (e.g., bcftools mpileup) — it catches complex variants and indels that pileup approaches miss.

Output: raw VCF containing all candidate variants with quality annotations (QUAL, DP, GQ, AD).

### SnpEff `v5.4.0c`
Functional annotation of variants.

Translates VCF coordinates into biological context: which gene is affected, what type of mutation (synonymous / missense / nonsense / frameshift / splice-site), predicted functional impact (HIGH / MODERATE / LOW / MODIFIER), and HGVS notation for clinical reporting compatibility.

---

## Repository Structure

```
p3_variantcalling/
├── data/
│   ├── SRR098401_1.fastq.gz          ← Raw reads R1
│   ├── SRR098401_2.fastq.gz          ← Raw reads R2
│   ├── trimmed_R1.fastq.gz           ← Trimmed reads R1
│   ├── trimmed_R1_unpaired.fastq.gz  ← Unpaired trimmed R1
│   ├── trimmed_R2.fastq.gz           ← Trimmed reads R2
│   └── trimmed_R2_unpaired.fastq.gz  ← Unpaired trimmed R2
├── ref/
│   ├── chr1.fa                       ← hg38 chr1 reference
│   ├── chr1.fa.fai                   ← SAMtools index
│   ├── chr1.dict                     ← GATK sequence dictionary
│   └── chr1.fa.bwt/.sa/.ann/...      ← BWA indexes
├── results/
│   ├── variants/
│   │   ├── aligned_sorted.bam        ← BWA-MEM output (6.9G)
│   │   ├── aligned_sorted.bam.bai    ← BAM index
│   │   ├── dedup.bam                 ← Picard deduplicated (7.2G)
│   │   ├── dedup.bam.bai             ← Dedup BAM index
│   │   ├── dedup_metrics.txt         ← Duplication metrics
│   │   ├── raw_variants.vcf          ← GATK output
│   │   ├── filtered_snps.vcf         ← Quality filtered SNPs
│   │   └── annotated.vcf             ← SnpEff annotated
│   └── plots/
│       ├── SRR098401_1_fastqc.html   ← FastQC R1 report
│       └── SRR098401_2_fastqc.html   ← FastQC R2 report
└── logs/
    ├── trimmomatic.log
    ├── bwa.log
    ├── picard.log
    └── gatk.log
```

---

## Key Results

| Step | Metric | Value |
|---|---|---|
| Raw reads | Total read pairs | 68,796,416 |
| Trimmomatic | Pairs retained | 77.48% |
| Trimmomatic | Pairs dropped | 12.11% |
| BWA-MEM | Mapping rate (chr1 only) | 28.45% |
| BWA-MEM | Properly paired | 24.11% |
| Picard | Duplicate rate | 6.07% |
| Picard | Estimated library size | 156,433,290 |

> **Note on 28% mapping rate:** Expected result — reference contains chr1 only (~8% of human genome). Reads from all other chromosomes have no mapping target. This is by design for compute efficiency.

---

## Environment Setup

```bash
# Accept Anaconda TOS
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create environment
conda create -n variantcalling_env \
    -c bioconda -c conda-forge \
    bwa samtools gatk4 picard snpeff \
    fastqc trimmomatic -y

conda activate variantcalling_env
```

### Verified Tool Versions
```
bwa          0.7.19
samtools     1.23.1
gatk4        4.6.2.0
picard       3.4.0
snpeff       5.4.0c
fastqc       0.12.1
trimmomatic  0.40
```

---

## Reproduction Steps

### Phase 0 — Download Reference
```bash
mkdir -p ~/p3_variantcalling/{data,ref,results/{variants,plots},logs}
cd ~/p3_variantcalling/ref

wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr1.fa.gz
gunzip chr1.fa.gz

bwa index chr1.fa
samtools faidx chr1.fa
gatk CreateSequenceDictionary -R chr1.fa
```

### Phase 1 — Download Data
```bash
cd ~/p3_variantcalling/data
fastq-dump --split-files --gzip SRR098401
```

### Phase 2 — Quality Control
```bash
cd ~/p3_variantcalling

fastqc data/SRR098401_1.fastq.gz \
       data/SRR098401_2.fastq.gz \
       -o results/plots/ -t 2
```

### Phase 3 — Trimming
```bash
trimmomatic PE \
    data/SRR098401_1.fastq.gz \
    data/SRR098401_2.fastq.gz \
    data/trimmed_R1.fastq.gz data/trimmed_R1_unpaired.fastq.gz \
    data/trimmed_R2.fastq.gz data/trimmed_R2_unpaired.fastq.gz \
    ILLUMINACLIP:$CONDA_PREFIX/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
    2>&1 | tee logs/trimmomatic.log
```

### Phase 4 — Alignment
```bash
bwa mem \
    -t 4 \
    -R "@RG\tID:SRR098401\tSM:NA12878\tPL:ILLUMINA\tLB:lib1" \
    ref/chr1.fa \
    data/trimmed_R1.fastq.gz \
    data/trimmed_R2.fastq.gz \
    2> logs/bwa.log | \
    samtools sort -@ 4 -o results/variants/aligned_sorted.bam

samtools index results/variants/aligned_sorted.bam
```

### Phase 5 — Mark Duplicates
```bash
picard MarkDuplicates \
    -I results/variants/aligned_sorted.bam \
    -O results/variants/dedup.bam \
    -M results/variants/dedup_metrics.txt \
    --VALIDATION_STRINGENCY SILENT \
    2>&1 | tee logs/picard.log

samtools index results/variants/dedup.bam
```

### Phase 6 — Variant Calling
```bash
gatk HaplotypeCaller \
    -R ref/chr1.fa \
    -I results/variants/dedup.bam \
    -O results/variants/raw_variants.vcf \
    --sample-name NA12878 \
    2>&1 | tee logs/gatk.log
```

### Phase 7 — Annotation (SnpEff)
```bash
snpEff hg38 results/variants/raw_variants.vcf \
    > results/variants/annotated.vcf \
    2>&1 | tee logs/snpeff.log
```

---

## Skills Demonstrated

- WGS data acquisition and preprocessing
- GATK Best Practices pipeline implementation
- PCR duplicate identification and removal (Picard)
- Variant calling from genomic DNA (GATK HaplotypeCaller)
- VCF file format handling and interpretation
- Functional variant annotation (SnpEff)
- Large-scale data processing (9GB+ input files)
- Conda environment management for reproducibility
- Pipeline logging and QC at every step

---

## References

- GATK Best Practices — Broad Institute: https://gatk.broadinstitute.org/hc/en-us/articles/360035535932
- 1000 Genomes Project: https://www.internationalgenome.org/
- Genome in a Bottle Consortium (NA12878 truth set): https://www.nist.gov/programs-projects/genome-bottle
- BWA-MEM: Li H. (2013) Aligning sequence reads, clone sequences and assembly contigs with BWA-MEM
- Picard: https://broadinstitute.github.io/picard/
- SnpEff: Cingolani et al. (2012) A program for annotating and predicting the effects of single nucleotide polymorphisms

---

## License

MIT License — free to use, modify, and distribute with attribution.
