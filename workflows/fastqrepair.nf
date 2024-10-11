/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { TRIMMOMATIC            } from '../modules/nf-core/trimmomatic/main'
include { GZRT                   } from '../modules/local/gzrt'
include { BBMAPREPAIR            } from '../modules/local/bbmaprepair'
include { SCATTER_WIPE_GATHER    } from '../subworkflows/local/scatter_wipe_gather/main'

include { paramsSummaryMap       } from 'plugin/nf-validation'
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

    main:
    ch_versions = Channel.empty()
    ch_decoupled = Channel.empty()

    // Decouple paired-end reads
    ch_decoupled = ch_samplesheet.flatMap { metaData, filePaths -> filePaths.collect { file -> [metaData, file] } }
    
    // Recover fastq.gz and skip *.fastq or *.fq
    GZRT (
        ch_decoupled
    )
    
    // Make fastq compliant and wipe bad characters
    SCATTER_WIPE_GATHER (
        GZRT.out.fastq
    )

    // Run if PAIRED-END reads only!
    SCATTER_WIPE_GATHER.out.fixed_fastq
        .branch {
            single_end: it[0].single_end == true
            paired_end: it[0].single_end == false
        }
        .set { filtered_ch }

    // Remove unpaired reads and reads shorter than 20 nt
    TRIMMOMATIC (
        filtered_ch.paired_end.groupTuple()
    )

    // Settle reads pairing (re-pair)
    BBMAPREPAIR {
        TRIMMOMATIC.out.trimmed_reads
    }

    // Assess QC
    // FASTQC (
    //     BBMAPREPAIR.out.interleaved_fastq
    // )


    // ch_versions = ch_versions.mix(GZRT.out.versions.first())  //FASTQC.out.versions.first(), 

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_pipeline_software_fastqrepair_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    

    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
