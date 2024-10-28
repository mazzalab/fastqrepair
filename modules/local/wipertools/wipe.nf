process WIPER {
    tag "$meta.id"
    label 'process_single'
    container 'docker.io/mazzalab/fastqrepair_nf_env:1.0.1'

    input:
        tuple val(meta), path(fastq)

    output:
        tuple val(meta), path("*_wiped.fastq.gz"), emit: fixed_fastq
        tuple val(meta), path("*_report.txt")    , emit: report
        path "versions.yml"                      , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def filename = "${fastq.baseName}"
        def VERSION = '1.0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
        def log_freq = (params.chunk_size / 100 as Integer) * 10
        log_freq = log_freq == 0 ? 1 : log_freq

        """
        wipertools fastqwiper -i $fastq -o ${filename}_wiped.fastq.gz -f ${log_freq} -a ${params.alphabet} -l ${filename}_report.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
        """

    stub:
        def args = task.ext.args ?: ''
        def filename = "${fastq.baseName}"
        def VERSION = '1.0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
        """
        touch ${filename}_wiped.fastq.gz
        touch ${filename}_report.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
    """
}
