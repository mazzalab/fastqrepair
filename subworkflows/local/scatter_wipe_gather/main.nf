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
    ch_wiper = SCATTER.out.fastq_chunks.flatMap { metaData, filePaths -> filePaths.collect { file -> [metaData, file] } }
    
    WIPER {
        ch_wiper
    }

    ch_gather = Channel.empty()
    ch_gather = WIPER.out.fixed_fastq.map{ metaData, fastq -> tuple( (fastq.baseName =~ /(.+)_chunk/)[0][1], metaData, fastq ) }
                                     .groupTuple()
                                     .map{ basename, metadata, fastq -> tuple(basename, metadata.first(), fastq) }
    
    GATHER {
        ch_gather
    }

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(WIPER.out.versions.first())

    emit:
    fixed_fastq = GATHER.out.fastq_merged_fixed     // channel: [ val(meta), [ .fastq ] ]
    versions    = ch_versions                       // channel: [ versions.yml ]
}

