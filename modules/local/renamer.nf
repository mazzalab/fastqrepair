process RENAMER {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*_repaired.fastq.gz"), emit: renamed_fastq
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def fq1 = fastq[0]
        def fq2 = fastq[1]
        def new_name_fq1 = "${meta.id}_R1_repaired.fastq.gz"
        def new_name_fq2 = "${meta.id}_R2_repaired.fastq.gz"
        def new_name_fqsingle = "${meta.id}_repaired.fastq.gz"

        """
        if [[ ${meta.single_end} ]]; then
            # No second file, treat as single-end
            cp ${fq1} ${new_name_fqsingle}
        elif [[ "${fq1}" == *"_trim_2.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq1="${meta.id}_R2_repaired.fastq.gz"
            cp "${fq1}" "${new_name_fq1}"
        elif [[ "${fq2}" == *"_trim_1.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq2="${meta.id}_R1_repaired.fastq.gz"
            cp "${fq2}" "${new_name_fq2}"
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            renamer: 1.0.0
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fq1 = fastq[0]
    def fq2 = fastq[1]
    def new_name_fq1 = "${meta.id}_R1_repaired.fastq.gz"
    def new_name_fq2 = "${meta.id}_R2_repaired.fastq.gz"
    def new_name_fqsingle = "${meta.id}_repaired.fastq.gz"

    """
    if [[ ${meta.single_end} ]]; then
        touch ${new_name_fqsingle}
    elif [[ "${fq1}" == *"_trim_2.fastq_interleaving.fastq.gz" ]]; then
        new_name_fq1="${meta.id}_R2_repaired.fastq.gz"
        touch "${new_name_fq1}"
    elif [[ "${fq2}" == *"_trim_1.fastq_interleaving.fastq.gz" ]]; then
        new_name_fq2="${meta.id}_R1_repaired.fastq.gz"
        touch "${new_name_fq2}"
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        renamer: 1.0.0
    END_VERSIONS
    """
}
