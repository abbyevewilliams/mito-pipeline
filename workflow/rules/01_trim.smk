
# Helper functions

def get_paired_reads(sample):
    return samples[sample].get("paired_reads", [])

def get_unpaired_reads(sample):
    return samples[sample].get("unpaired_reads", [])

# Run pre-trimming FastQC

rule fastqc_initial:
    input:
        lambda wildcards: wildcards.sample_path
    output:
        html="results/01_qc/fastqc_initial/{sample_path}.html",
        zip="results/01_qc/fastqc_initial/{sample_path}.zip"
    log:
        "results/logs/fastqc_initial/{sample_path}.log",
    wrapper:
        "v7.0.0/bio/fastqc"

# Remove adapters from single end reads

rule adapterremoval_se:
    input:
        sample=lambda wildcards: samples[wildcards.sample]["unpaired_reads"]
    output:
        fq="results/02_trimmed/se/{sample}.fastq.gz",                               # trimmed reads
        discarded="results/02_trimmed/se/{sample}.discarded.fastq.gz",              # reads that did not pass filters
    log:
        "results/logs/adapterremoval/se/{sample}.log"
	params:
		extra="--mm 3 --minquality 30 --trimns --minlength 25",			 # same params as NZ greyling paper
    wrapper:
        "v7.0.0/bio/adapterremoval"

# Remove adapters from paired end reads

rule adapterremoval_pe:
    input:
        sample=[
            lambda wc: f"{wc.basename}_R1.fastq.gz", 
            lambda wc: lambda wc: f"{wc.basename}_R2.fastq.gz"
                ]
    output:
        collapsed="results/02_trimmed/pe/{sample}.collapsed.fastq.gz",              # overlapping mate-pairs which have been merged into a single read
        collapsed_trunc="results/02_trimmed/pe/{sample}.collapsed_trunc.fastq.gz",  # collapsed reads that were quality trimmed
    log:
        "results/logs/adapterremoval/pe/{sample}.log"
    params:
		extra="--mm 3 --minquality 30 --trimns --minlength 25 --collapse --collapse-deterministic",			 # same params as NZ greyling paper
    wrapper:
        "v7.0.0/bio/adapterremoval"

# FastQC after trimming

rule fastqc_post_trim:
    input:
        lambda wildcards: (
            f"results/trimmed/se/{wildcards.sample}.fastq.gz"
            if wildcards.read_type == "se"
            else f"results/trimmed/pe/{wildcards.sample}.{wildcards.collapsed_type}.fastq.gz"
        )
    output:
        html="results/01_qc/fastqc_post_trim/{read_type}/{sample}_{collapsed_type}.html",
        zip="results/01_qc/fastqc_post_trim/{read_type}/{sample}_{collapsed_type}.zip"
    log:
        "logs/fastqc_post_trim/{read_type}/{sample}_{collapsed_type}.log"
    wrapper:
        "v7.0.0/bio/fastqc"

# Combine all reads together, SE + collapsed PE

rule combine_reads:
    input:
        pe_collapsed = "results/02_trimmed/pe/{sample}.collapsed.fastq.gz",
        pe_collapsed_trunc = "results/02_trimmed/pe/{sample}.collapsed_trunc.fastq.gz",
        se_trimmed = "results/02_trimmed/se/{sample}.fastq.gz"
    output:
        combined = "results/03_combined/{sample}.fastq.gz"
    shell:
        """
        zcat {input.pe_collapsed} {input.pe_collapsed_trunc} {input.se_trimmed} | gzip > {output.combined}
        """