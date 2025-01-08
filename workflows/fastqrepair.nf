/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { TRIMMOMATIC            } from '../modules/nf-core/trimmomatic/main'
include { GZRT                   } from '../modules/nf-core/gzrt/main'
include { BBMAP_REPAIR            } from '../modules/nf-core/bbmap/repair/main'
// include { SCATTER_WIPE_GATHER    } from '../subworkflows/local/scatter_wipe_gather/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_fastqrepair_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FASTQREPAIR {
    take:
    ch_samplesheet // channel: samplesheet read in from --input
    // TODO: add integrity check in samplesheet (i.e., check that paired fastq files on each line have the same extensions: .gz or .fastq, .fq)

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // branch .gz and non gz files
    ch_samplesheet.branch { map, fq ->
        gz_files: fq.first().getExtension() == 'gz'
        non_gz_files: true
    } .set { ch_fastq_ext }

    // Recover corrupted gz files
    GZRT (
        ch_fastq_ext.gz_files
    )

    // Join recovered gz files with non-gz files
    GZRT.out.recovered.concat(ch_fastq_ext.non_gz_files) .set { ch_recovered_fastq }
    ch_recovered_fastq.view()

    // // Sort single from paired-end reads
    // GZRT.out.recovered.branch { m,v ->
    //     single_end: m.single_end == true
    //     paired_end: true
    // } .set { ch_decoupled }




    // // Make fastq compliant and wipe bad characters
    // SCATTER_WIPE_GATHER (
    //     GZRT.out.fastqrecovered
    // )

    // // Run if PAIRED-END reads only!
    // SCATTER_WIPE_GATHER.out.fixed_fastq
    //     .branch {
    //         single_end: it[0].single_end == true
    //         paired_end: it[0].single_end == false
    //     }
    //     .set { filtered_ch }

    // // Remove unpaired reads and reads shorter than 20 nt
    // TRIMMOMATIC (
    //     filtered_ch.paired_end.groupTuple()
    // )

    // // Settle reads pairing (re-pair)
    // BBMAPREPAIR {
    //     TRIMMOMATIC.out.trimmed_reads
    // }


    // // Rename final FASTQ and REPORT files and move them into the "pickup" folder
    // RENAMER (
    //     filtered_ch.single_end.concat(BBMAPREPAIR.out.interleaved_fastq),
    //     SCATTER_WIPE_GATHER.out.report.groupTuple()
    // )

    // Assess QC of all fastq files (both single and paired end)
    // FASTQC (
    //     // RENAMER.out.renamed_fastq
    //     GZRT.out.fastqrecovered
    // )
    // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})

    // ch_versions = ch_versions.mix(
    //     GZRT.out.versions.first(),
    //     // SCATTER_WIPE_GATHER.out.versions.first(),
    //     // TRIMMOMATIC.out.versions.first(),
    //     // BBMAPREPAIR.out.versions.first(),
    //     FASTQC.out.versions.first()
    // )

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf-core_fastqrepair_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    // MULTIQC (
    //     ch_multiqc_files.collect(),
    //     ch_multiqc_config.toList(),
    //     ch_multiqc_custom_config.toList(),
    //     ch_multiqc_logo.toList(),
    //     [],
    //     []
    // )

    // emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    emit:multiqc_report = [] // To be replaced by the line above
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
