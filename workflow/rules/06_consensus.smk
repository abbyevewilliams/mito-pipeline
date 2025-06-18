
# Generate consensus based on aligned BAM files

rule angsd_consensus:
    input:
        bam="results/mapdamage/{sample}.bam",
        ref="reference/mito.fasta"
    output:
        fasta="consensus/{sample}.fa"
    params:
        minmapq=25,
        minbaseq=20,
        mindepth=3
    log:
        "logs/angsd/{sample}.log"
    container:
		angsd_container
    shell:
        """
        angsd -i {input.bam} \
              -doFasta 2 \
              -doCounts 1 \
              -setMinDepth {params.mindepth} \
              -minMapQ {params.minmapq} \
              -minQ {params.minbaseq} \
              -r MT \
              -out consensus/{wildcards.sample} \
              -ref {input.ref} \
              > {log} 2>&1
        """