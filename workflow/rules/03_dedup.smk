# Deduplicate using DeDup

rule dedup:
    input:
        "results/05_filt/{sample}.bam"
    output:
        bam=temp("results/06_dedup/{sample}.bam")
    conda: 
        "../../envs/dedup.yaml"
    log:
        "results/logs/dedup/{sample}.log"
    shell:
        """
        export _JAVA_OPTIONS="-Xmx90G"
        bam={output.bam}
        mkdir -p $(dirname $bam)
        dedup -i {input.bam} -m -o $(dirname $bam);
        mv ${{bam%%.bam}}_rmdup.bam $bam

        """

# Sort deduped bam file
rule samtools_sort_dedup:
    input:
        "results/06_dedup/{sample}.bam",
    output:
        "results/06_dedup/{sample}.sorted.bam",
    log:
        "results/logs/samtools_sort_dedup/{sample}.log",
    wrapper:
        "v5.8.3/bio/samtools/sort"

# Index deduped bam file
rule samtools_index_dedup:
    input:
        "results/06_dedup/{sample}.sorted.bam"
    output:
        "results/06_dedup/{sample}.sorted.bam.bai"
    log:
        "results/logs/samtools_index_dedup/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/index"