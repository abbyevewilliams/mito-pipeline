
# Index references

rule bwa_mem2_index_dodo:
    input:
        config["reference_genomes"]["dodo"]
    output:
        multiext(config["reference_genomes"]["dodo"], ".0123", ".amb", ".ann", ".bwt.2bit.64", ".pac")
    log:
        "results/logs/bwa_index/dodo.log"
    wrapper:
        "v7.0.0/bio/bwa-mem2/index"

rule bwa_mem2_index_solitaire:
    input:
        config["reference_genomes"]["solitaire"]
    output:
        multiext(config["reference_genomes"]["solitaire"], ".0123", ".amb", ".ann", ".bwt.2bit.64", ".pac")
    log:
        "results/logs/bwa_index/solitaire.log"
    wrapper:
        "v7.0.0/bio/bwa-mem2/index"

# Map all reads to the reference

rule bwa_map:
    input:
            reads="results/03_combined/{sample}.fastq.gz",
            idx=lambda wildcards: multiext(
            config["reference_genomes"][samples[wildcards.sample]["species"]],
            ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123"
        )
    output:
        "results/04_mapped/{sample}.bam"
    log:
        "results/logs/bwa_map/{sample}.log"
    params:
        sort="samtools"
    wrapper:
        "v5.8.0/bio/bwa-mem2/mem"

# Filter reads for quality > 25

rule filter_mapped:
    input:
        "results/04_mapped/{sample}.bam",
    output:
        "results/05_filt/{sample}.bam",
    log:
        "results/logs/filter_mapped/{sample}.log",
    params:
        extra="--min-MQ 25",  # optional params string
    wrapper:
        "v7.0.0/bio/samtools/view"

# Index the filtered bam file

rule samtools_index:
    input:
        "results/05_filt/{sample}.bam"
    output:
        "results/05_filt/{sample}.bam.bai"
    log:
        "results/logs/samtools_index/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/index"


