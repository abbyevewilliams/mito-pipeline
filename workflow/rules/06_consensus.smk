
# Generate consensus based on aligned BAM files

rule angsd_consensus:
    input:
        bam="results/07_mapdamage/{sample}/{sample}.rescaled.bam",
        ref=lambda wildcards: config["reference_genomes"][samples[wildcards.sample]["species"]]
    output:
        fasta="results/09_consensus/{sample}.fa"
    params:
        minmapq=25,
        minbaseq=20,
        mindepth=3
    log:
        "results/logs/angsd/{sample}.log"
    container:
        "docker://quay.io/biocontainers/angsd:0.940--hf5e1c6e_3"
    shell:
        """
        angsd -i {input.bam} \
              -doFasta 2 \
              -doCounts 1 \
              -setMinDepth {params.mindepth} \
              -minMapQ {params.minmapq} \
              -minQ {params.minbaseq} \
              -out consensus/{wildcards.sample} \
              -ref {input.ref} \
              > {log} 2>&1
        """