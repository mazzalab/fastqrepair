process SCATTER {
    tag "$meta.id"
    label 'process_single'
    
    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*_chunk.*.fastq"), emit: fastq_chunks
    path "versions.yml"                     , emit: versions

    // when:
    // task.max_cpus > 1

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        def filename = "${fastq.baseName}"
        def VERSION = '1.0.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

        """
        split -a3 -l ${params.chunk_size} --numeric-suffixes=1 --additional-suffix .fastq ${fastq} ${filename}_chunk.

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            wipertools: $VERSION
        END_VERSIONS
    """

    // stub:
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    // // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    // //               Have a look at the following examples:
    // //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    // //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    // """
    // touch ${prefix}.bam

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     fastqwiper: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    // """
}
