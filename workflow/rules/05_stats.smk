
# Calculate depth
rule samtools_depth:
    input:
        bams="results/07_mapdamage/{sample}/{sample}.rescaled.bam" if MAPDAMAGE_RESCALE else "results/06_dedup/{sample}.bam"
    output:
        "results/08_stats/{sample}.depth"
    log:
        "results/logs/samtools_depth/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/depth"

# Calculate stats
rule samtools_stats:
    input:
        bam="results/07_mapdamage/{sample}/{sample}.rescaled.bam" if MAPDAMAGE_RESCALE else "results/06_dedup/{sample}.bam"
    output:
        "results/08_stats/{sample}.stats"
    log:
        "results/logs/samtools_stats/{sample}.log"
    wrapper:
        "v5.8.0/bio/samtools/stats"

#Summarise key stats across all samples
rule summarise_samtools_stats:
    input:
        stats_files=expand("results/08_stats/{sample}.stats", sample=SAMPLES)
    output:
        "results/08_stats/mapping_summary.txt"
    shell:
        """
        echo -e "Sample\tTotal_Reads\tMapped_Reads\tPercent_Mapped\tError_Rate\tAvg_Quality" > {output}
        for stats_file in {input.stats_files}; do
            sample=$(basename "$stats_file" .stats)
            total_reads=$(grep "raw total sequences:" "$stats_file" | cut -f 3)
            mapped_reads=$(grep "reads mapped:" "$stats_file" | head -n 1 | cut -f 3)
            error_rate=$(grep "error rate:" "$stats_file" | cut -f 3)
            avg_quality=$(grep "average quality:" "$stats_file" | cut -f 3)
            percent_mapped=$(awk -v mapped="$mapped_reads" -v total="$total_reads" 'BEGIN {{ if (total>0) print (mapped/total)*100; else print 0 }}')
            echo -e "$sample\t$total_reads\t$mapped_reads\t$percent_mapped\t$error_rate\t$avg_quality" >> {output}
        done
        """

# Calculate average depth for each sample
rule compute_average_depth:
    input:
        depth_files=expand("results/08_stats/{sample}.depth", sample=SAMPLES)
    output:
        "results/08_stats/avg_depth.txt"
    shell:
        """
        echo -e "Sample\tAverage_Depth" > {output}
        for depth_file in {input.depth_files}; do
            sample=$(basename "$depth_file" .depth)
            avg_depth=$(awk '{{sum+=$3}} END {{if (NR>0) print sum/NR; else print 0}}' "$depth_file")
            echo -e "$sample\t$avg_depth" >> {output}
        done
        """
