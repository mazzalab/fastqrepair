process RENAMER {
    tag "$meta_fastq.id"
    label 'process_single'

    input:
    tuple val(meta_fastq), path(fastq)
    tuple val(meta_report), path(report)

    output:
    tuple val(meta_fastq) , path("*_repaired.fastq.gz"), emit: renamed_fastq
    tuple val(meta_report), path("*_report.txt"), emit: renamed_report
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta_fastq.id}"
        def fq1 = fastq[0]
        def fq2 = fastq[1]

        def new_name_fq1 = "${meta_fastq.id}_R1_repaired.fastq.gz"
        def new_name_fq2 = "${meta_fastq.id}_R2_repaired.fastq.gz"
        def new_name_fqsingle = "${meta_fastq.id}_repaired.fastq.gz"
        def is_single_end_fq = "${meta_fastq.single_end}".toBoolean()

        def rep1 = report[0]
        def rep2 = report[1]
        def new_name_rep1 = "${meta_report.id}_R1_report.txt"
        def new_name_rep2 = "${meta_report.id}_R2_report.txt"
        def new_name_repsingle = "${meta_report.id}_report.txt"
        def is_single_end_report = "${meta_report.single_end}".toBoolean()

        """
        # Rename FASTQ files
        if [[ ${is_single_end_fq} = true ]]; then
            # No second file, treat as single-end
            cp ${fq1} ${new_name_fqsingle}
        elif [[ "${fq1}" == *"trim_2.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq1="${meta_fastq.id}_R2_repaired.fastq.gz"
            new_name_fq2="${meta_fastq.id}_R1_repaired.fastq.gz"
            cp "${fq1}" "${new_name_fq1}"
            cp "${fq2}" "${new_name_fq2}"
        elif [[ "${fq1}" == *"trim_1.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq2="${meta_fastq.id}_R2_repaired.fastq.gz"
            new_name_fq1="${meta_fastq.id}_R1_repaired.fastq.gz"
            cp "${fq1}" "${new_name_fq1}"
            cp "${fq2}" "${new_name_fq2}"
        fi

        # Rename REPORT files
        if [[ ${is_single_end_report} = true ]]; then
            cp ${rep1} ${new_name_repsingle}
        elif [[ "${rep1}" == *"R2.fastq_recovered_merged_report.txt" ]]; then
            new_name_rep1="${meta_report.id}_R2_report.txt"
            new_name_rep2="${meta_report.id}_R1_report.txt"
            cp "${rep1}" "${new_name_rep1}"
            cp "${rep2}" "${new_name_rep2}"
        elif [[ "${rep1}" == *"R1.fastq_recovered_merged_report.txt" ]]; then
            new_name_rep2="${meta_report.id}_R2_report.txt"
            new_name_rep1="${meta_report.id}_R1_report.txt"
            cp "${rep1}" "${new_name_rep1}"
            cp "${rep2}" "${new_name_rep2}"
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            renamer: 1.0.0
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta_fastq.id}"
    def fq1 = fastq[0]
    def fq2 = fastq[1]
    def new_name_fq1 = "${meta_fastq.id}_R1_repaired.fastq.gz"
    def new_name_fq2 = "${meta_fastq.id}_R2_repaired.fastq.gz"
    def new_name_fqsingle = "${meta_fastq.id}_repaired.fastq.gz"

    """
        if [[ ${is_single_end_fq} = true ]]; then
            # No second file, treat as single-end
            touch ${new_name_fqsingle}
        elif [[ "${fq1}" == *"trim_2.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq1="${meta_fastq.id}_R2_repaired.fastq.gz"
            new_name_fq2="${meta_fastq.id}_R1_repaired.fastq.gz"
            touch "${new_name_fq1}"
            touch "${new_name_fq2}"
        elif [[ "${fq1}" == *"trim_1.fastq_interleaving.fastq.gz" ]]; then
            new_name_fq2="${meta_fastq.id}_R2_repaired.fastq.gz"
            new_name_fq1="${meta_fastq.id}_R1_repaired.fastq.gz"
            touch "${new_name_fq1}"
            touch "${new_name_fq2}"
        fi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            renamer: 1.0.0
        END_VERSIONS
        """
}
