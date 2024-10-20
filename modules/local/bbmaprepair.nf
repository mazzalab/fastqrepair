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
        repair.sh qin=${params.qin} in=${infastq1} in2=${infastq2} out=${outfastq1}_interleaving.fastq.gz out2=${outfastq2}_interleaving.fastq.gz outsingle=${fastq[0].baseName}_singletons.fastq.gz 2> ${fastq[0].baseName}_repair.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            repair.sh: \$(bbversion.sh)
        END_VERSIONS
    """

    stub:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"

        def infastq1 = fastq[0]
        def infastq2 = fastq[1]
        def outfastq1 = infastq1.baseName
        def outfastq2 = infastq2.baseName
        """
        touch ${outfastq1}_interleaving.fastq.gz
        touch ${outfastq2}_interleaving.fastq.gz
        touch ${fastq[0].baseName}_singletons.fastq.gz
        touch ${fastq[0].baseName}_repair.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            repair.sh: \$(bbversion.sh)
        END_VERSIONS
    """
}
