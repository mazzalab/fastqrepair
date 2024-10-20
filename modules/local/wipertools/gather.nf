process GATHER {
    tag "$meta.id"
    label 'process_single'
    container 'docker.io/mazzalab/fastqrepair_nf_env:1.0.1'

    input:
        tuple val(filename), val(meta), path(fastq_list)
        tuple val(filename), val(meta), path(report_list)

    output:
        tuple val(meta), path("*merged_wiped.fastq.gz"), emit: fastq_merged_fixed
        tuple val(meta), path("*merged_report.txt")    , emit: report_merged
        path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def args    = task.ext.args ?: ''
        def prefix  = task.ext.prefix ?: "${meta.id}"
        def VERSION = '1.0.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

        """
        cat ${fastq_list} > ${filename}_merged_wiped.fastq.gz
        wipertools summarygather -s ${report_list} -f ${filename}_merged_report.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
        """

    stub:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def VERSION = '1.0.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

        """
        gzip < /dev/null > ${filename}_merged_wiped.fastq.gz
        touch ${filename}_merged_report.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
        """
}
