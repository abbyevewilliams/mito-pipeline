# Run mapdamage2

rule mapdamage2:
    input:
        ref=lambda wildcards: config["reference_genomes"][samples[wildcards.sample]["species"]],
        bam="results/06_dedup/{sample}.bam",
    output:
        log="results/07_mapdamage/{sample}/Runtime_log.txt",  # output folder is infered from this file, so it needs to be the same folder for all output files
        GtoA3p="results/07_mapdamage/{sample}/3pGtoA_freq.txt",
        CtoT5p="results/07_mapdamage/{sample}/5pCtoT_freq.txt",
        dnacomp="results/07_mapdamage/{sample}/dnacomp.txt",
        frag_misincorp="results/07_mapdamage/{sample}/Fragmisincorporation_plot.pdf",
        len="results/07_mapdamage/{sample}/Length_plot.pdf",
        lg_dist="results/07_mapdamage/{sample}/lgdistribution.txt",
        misincorp="results/07_mapdamage/{sample}/misincorporation.txt",
        rescaled_bam="results/07_mapdamage/{sample}/{sample}.rescaled.bam" # uncomment if you want the rescaled BAM file
    log:
        "results/logs/07_mapdamage/{sample}.log"
    params:
        extra="--rescale"
    wrapper:
        "v5.8.0/bio/mapdamage2"

# Index rescaled bam file
rule samtools_index_rescaled:
    input:
        "results/07_mapdamage/{sample}/{sample}.rescaled.bam"
    output:
        "results/07_mapdamage/{sample}/{sample}.rescaled.bam.bai"
    log:
        "results/logs/samtools_index_rescaled/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/index"