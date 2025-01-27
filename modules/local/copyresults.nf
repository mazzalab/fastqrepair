process COPYRESULTS {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(repaired_fastq)

    output:
    tuple val(meta), path("*.gz"), emit: renamed_fastq
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix_fastq = task.ext.prefix ?: "${meta.id}"
    """
    # Extract the base name without path or extension
    base_name_fastq=\$(basename "$repaired_fastq" .fastq.gz)
    base_name_fastq=\${base_name_fastq#"$meta.id"}

    # Check if _1_ or _2_ is in the fastq filename
    if [[ "\$base_name_fastq" == *_1_* ]]; then
        new_fastq_file="${prefix_fastq}_1.fastq.gz"
    elif [[ "\$base_name_fastq" == *_2_* ]]; then
        new_fastq_file="${prefix_fastq}_2.fastq.gz"
    elif [[ "\$base_name_fastq" == *_singleton* ]]; then
        new_fastq_file="${prefix_fastq}_unpaired.fastq.gz"
    else
        new_fastq_file="${prefix_fastq}.fastq.gz"
    fi
    # Rename the fastq file
    mv "$repaired_fastq" "\$new_fastq_file"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        collectresults: 1.0.0
    END_VERSIONS
    """
}
