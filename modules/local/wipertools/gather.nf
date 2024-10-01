process GATHER {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(filename), val(meta), path(fastq_list)

    output:
    tuple val(meta), path("*merged_wiped.fastq.gz"), emit: fastq_merged_fixed
    path "versions.yml"                            , emit: versions

    // when:
    // task.ext.when == null || task.ext.when

    script:
    def args    = task.ext.args ?: ''
    def prefix  = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.0.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    cat ${fastq_list} > ${filename}_merged_wiped.fastq.gz

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
