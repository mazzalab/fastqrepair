include { WIPER   } from '../../../modules/local/wipertools/wipe'
include { SCATTER } from '../../../modules/local/wipertools/scatter'
include { GATHER  } from '../../../modules/local/wipertools/gather'


workflow SCATTER_WIPE_GATHER {

    take:
    ch_fastq // channel: [ val(meta), [ .fastq ] ]

    main:

    SCATTER {
        ch_fastq
    }

    ch_wiper = Channel.empty()
    ch_wiper = SCATTER.out.fastq_chunks.flatMap { metaData, filePaths -> filePaths instanceof List ? filePaths.collect { files -> [metaData, files] } : [[metaData, filePaths]] }

    WIPER {
        ch_wiper
    }

    ch_fastq_gather  = Channel.empty()
    ch_report_gather = Channel.empty()
    ch_fastq_gather  = WIPER.out.fixed_fastq.map{ metaData, fastq -> tuple( (fastq.baseName =~ /(.+)_chunk/)[0][1], metaData, fastq ) }
                                     .groupTuple()
                                     .map{ basename, metadata, fastq -> tuple(basename, metadata.first(), fastq) }
    ch_report_gather = WIPER.out.report.map{ metaData, report -> tuple( (report.baseName =~ /(.+)_chunk/)[0][1], metaData, report ) }
                                       .groupTuple()
                                       .map{ basename, metadata, report -> tuple(basename, metadata.first(), report) }
    GATHER(
        ch_fastq_gather,
        ch_report_gather
    )

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(WIPER.out.versions.first())

    emit:
    fixed_fastq = GATHER.out.fastq_merged_fixed     // channel: [ val(meta), [ .fastq ] ]
    report      = GATHER.out.report_merged          // channel: [ val(meta), [ .txt ] ]
    versions    = ch_versions                       // channel: [ versions.yml ]
}

