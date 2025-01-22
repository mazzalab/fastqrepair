process COPYREPORTS {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(report)

    output:
    tuple val(meta), path("*.report"), emit: renamed_report
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix_report = task.ext.prefix ?: "${meta.id}"
    """
    # Extract the base name without path or extension
    base_name_report=\$(basename "$report" .report)

    # Check if _1_ or _2_ is in the report filename
    if [[ "\$base_name_report" == *_1_* ]]; then
        new_report_file="${prefix_report}_1.report"
    elif [[ "\$base_name_report" == *_2_* ]]; then
        new_report_file="${prefix_report}_2.report"
    else
        new_report_file="${prefix_report}.report"
    fi
    # Rename the report file
    mv "$report" "\$new_report_file"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        collectreports: 1.0.0
    END_VERSIONS
    """
}
