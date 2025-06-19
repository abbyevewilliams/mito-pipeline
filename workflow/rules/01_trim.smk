# Run pre-trimming FastQC

rule fastqc_initial:
    input:
        "{sample_file}"
    output:
        html="results/01_qc/fastqc_initial/{sample_file}.html",
        zip="results/01_qc/fastqc_initial/{sample_file}.zip"
    log:
        "results/logs/fastqc_initial/{sample_file}.log",
    wrapper:
        "v7.0.0/bio/fastqc"

# Remove adapters from single end reads

rule adapterremoval_se:
    input:
        sample=lambda wc: f"Data/{wc.file}_R1.fastq.gz"
    output:
        fq="results/02_trimmed/se/{sample}--{file}.fastq.gz",                               # trimmed reads
        discarded="results/02_trimmed/se/{sample}--{file}.discarded.fastq.gz"              # reads that did not pass filters
    log:
        "results/logs/adapterremoval/se/{sample}--{file}.log"
    params:
        extra="--mm 3 --minquality 30 --trimns --minlength 25"              # same params as NZ greyling paper
    wrapper:
        "v7.0.0/bio/adapterremoval"

# Remove adapters from paired end reads

rule adapterremoval_pe:
    input:
        sample=lambda wc: [f"Data/{wc.file}_R1.fastq.gz", f"Data/{wc.file}_R2.fastq.gz"]
    output:
        collapsed="results/02_trimmed/pe/{sample}--{file}.collapsed.fastq.gz",              # overlapping mate-pairs which have been merged into a single read
        collapsed_trunc="results/02_trimmed/pe/{sample}--{file}.collapsed_trunc.fastq.gz"  # collapsed reads that were quality trimmed
    log:
        "results/logs/adapterremoval/pe/{sample}_{file}.log"
    params:
        extra="--mm 3 --minquality 30 --trimns --minlength 25 --collapse --collapse-deterministic" # same params as NZ greyling paper
    wrapper:
        "v7.0.0/bio/adapterremoval"

# FastQC after trimming

rule fastqc_post_trim_se:
    input:
        "results/02_trimmed/se/{sample}--{file}.fastq.gz"
    output:
        html="results/01_qc/fastqc_post_trim/se/{sample}--{file}.html",
        zip="results/01_qc/fastqc_post_trim/se/{sample}--{file}.zip"
    log:
        "results/logs/fastqc_post_trim/se/{sample}--{file}.log"
    wrapper:
        "v7.0.0/bio/fastqc"

rule fastqc_post_trim_pe:
    input:
        "results/02_trimmed/pe/{sample}--{file}.{collapsed_type}.fastq.gz"
    output:
        html="results/01_qc/fastqc_post_trim/pe/{sample}--{file}.{collapsed_type}.html",
        zip="results/01_qc/fastqc_post_trim/pe/{sample}--{file}.{collapsed_type}.zip"
    log:
        "results/logs/fastqc_post_trim/pe/{sample}--{file}--{collapsed_type}.log"
    wrapper:
        "v7.0.0/bio/fastqc"

# Combine all reads together, SE + collapsed PE

def get_files(wildcards):
    # Get all collapsed files for this sample
    collapsed_files = []
    collapsed_trunc_files = []
    unpaired_files = []
    for file in samples[wildcards.sample].get("paired_reads", []):
        collapsed_files.append(f"results/02_trimmed/pe/{wildcards.sample}--{file}.collapsed.fastq.gz")
        collapsed_trunc_files.append(f"results/02_trimmed/pe/{wildcards.sample}--{file}.collapsed_trunc.fastq.gz")
    for file in samples[wildcards.sample].get("unpaired_reads", []):
        unpaired_files.append(f"results/02_trimmed/se/{wildcards.sample}--{file}.fastq.gz")
    return collapsed_files, collapsed_trunc_files, unpaired_files

rule combine_reads:
    input:
        pe_collapsed = lambda wc: get_files(wc)[0],
        pe_collapsed_trunc = lambda wc: get_files(wc)[1],
        se_trimmed = lambda wc: get_files(wc)[2]
    output:
        combined = "results/03_combined/{sample}.fastq.gz"
    shell:
        """
        zcat {input.pe_collapsed} {input.pe_collapsed_trunc} {input.se_trimmed} | gzip > {output.combined}
        """