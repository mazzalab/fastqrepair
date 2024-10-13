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
    def new_name_fq1="${meta.id}_R1_repaired.fastq.gz"
    def new_name_fq2="${meta.id}_R2_repaired.fastq.gz"

    //Check if it's a _1 or _2 files and rename to R1 or R2
    """
    if [[ $fq1 == *_trim_2.fastq_interleaving.fastq.gz ]]; then
        new_name_fq1='${meta.id}_R2_repaired.fastq.gz}'
    fi
    cp '${fq1}' '${new_name_fq1}'

    if [[ $fq2 == *_trim_1.fastq_interleaving.fastq.gz ]]; then
        new_name_fq2='${meta.id}_R1_repaired.fastq.gz}'
    fi
    cp '${fq2}' '${new_name_fq2}'


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        renamer: 1.0.0
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
    //     renamer: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    // """
}
