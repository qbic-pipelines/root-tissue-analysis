// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process RTSSTAT {
    //tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtastat:dev"

    input:
    path(images)
    path(ratios)
    path(predictions)

    output:
    path("*omeout") , emit: omeout

    script:
    def software = getSoftwareName(task.process)
    """
    mkdir omeout
    ome_output.py --imgs "$images/" --ratios "$ratios/" --segs "$predictions/" --output ./omeout
    """

}
