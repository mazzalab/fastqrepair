process GZRT {
    tag "$meta.id"
    label 'process_low'
    container 'docker.io/mazzalab/fastqrepair_nf_env:1.0.1'

    input:
    tuple val(meta), path(fastqgz)

    output:
    tuple val(meta), path("*_recovered.fastq"), emit: fastq
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filename = "${fastqgz.baseName}"
        
    """
    ver_line=""
    if [[ $fastqgz == *.fastq ]] || [[ $fastqgz == *.fq ]]; then
        mv $fastqgz ${filename}_recovered.fastq
    else
        gzrecover -o ${filename}_recovered.fastq ${fastqgz} -v
        soft_line="${task.process}"
        ver_line="gzrt: \$(gzrecover -V |& sed '1!d ; s/gzrecover //')"
    fi

    cat <<-END_VERSIONS > versions.yml
    "\${soft_line}":
        \${ver_line}
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    ver_line=""
    if [[ $fastqgz == *.fastq ]] || [[ $fastqgz == *.fq ]]; then
        touch ${filename}_recovered.fastq
    else
        touch ${filename}_recovered.fastq
        soft_line="${task.process}"
        ver_line="gzrt: \$(gzrecover -V |& sed '1!d ; s/gzrecover //')"
    fi

    cat <<-END_VERSIONS > versions.yml
    "\${soft_line}":
        \${ver_line}
    END_VERSIONS
    """
}
