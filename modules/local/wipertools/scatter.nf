process SCATTER {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*_chunk.*.fastq"), emit: fastq_chunks
    path "versions.yml"                     , emit: versions

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def filename = "${fastq.baseName}"
        def VERSION = '1.0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

        """
        split -a3 -l ${params.chunk_size} --numeric-suffixes=1 --additional-suffix .fastq ${fastq} ${filename}_chunk.

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
        """

    stub:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def filename = "${fastq.baseName}"
        def VERSION = '1.0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

        """
        touch ${filename}_chunk.001.fastq
        touch ${filename}_chunk.002.fastq

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
        """
}
