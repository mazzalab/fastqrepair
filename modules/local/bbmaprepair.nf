process BBMAPREPAIR {
    tag "$meta.id"
    label 'process_single'

    container 'docker.io/mazzalab/fastqrepair_nf_env:1.0.1'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*_interleaving.fastq.gz"), emit: interleaved_fastq
    path("*_singletons.fastq.gz")                   , emit: singletons_fastq
    path("*_repair.log")                            , emit: log
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def infastq1 = fastq[0]
    def infastq2 = fastq[1]
    def outfastq1 = infastq1.baseName
    def outfastq2 = infastq2.baseName
        
    """
    repair.sh qin=${params.qin} in=${fastq[0]} in2=${fastq[1]} out=${outfastq1}_interleaving.fastq.gz out2=${outfastq2}_interleaving.fastq.gz outsingle=${fastq[0].baseName}_singletons.fastq.gz 2> ${fastq[0].baseName}_repair.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bbmaprepair: \$(repair.sh --version |& sed '1!d ; s/repair.sh //')
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
    //     bbmaprepair: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    // """
}
