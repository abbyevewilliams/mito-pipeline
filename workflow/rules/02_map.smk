
# Index reference

rule bwa_index:
    input:
        ref=lambda wildcards: config["reference_genomes"][wildcards.species]
    output:
        multiext(lambda wildcards: config["reference_genomes"][wildcards.species],
                 ".0123", ".amb", ".ann", ".bwt.2bit.64", ".pac")
    log:
        "results/logs/bwa_index/{species}.log"
    wrapper:
        "v5.8.2/bio/bwa-mem2/index"


# Map all reads to the reference

rule bwa_map:
        input:
            reads="results/03_combined/{sample}.fastq.gz"
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
        "results/04_mapped/{sample}.sam",
    output:
        results/05_filt/bam="{sample}.bam",
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


