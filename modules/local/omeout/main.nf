// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process OMEOUT {
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
    path("*ome_output") , emit: omeout

    script:
    def software = getSoftwareName(task.process)
    """
    mkdir ome_output
    ome_output.py --imgs "$images/" --ratios "$ratios/" --segs "$predictions/" --output ./ome_output
    """

}

process OMEOUT_UNCERT {
    //tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtastat:dev"

    input:
    path(images)
    path(pred_uncert)

    output:
    path("*ome_output_uncert") , emit: omeout

    script:
    def software = getSoftwareName(task.process)
    """
    mkdir ome_output_uncert
    ome_output_uncert.py --imgs "$images/" --uncert "$pred_uncert/" --output ./ome_output_uncert
    """

}

process OMEOUT_GGCAM {
    //tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtastat:dev"

    input:
    path(images)
    path(pred_ggcam)

    output:
    path("*ome_output_ggcam") , emit: omeout

    script:
    def software = getSoftwareName(task.process)
    """
    mkdir ome_output_ggcam
    ome_output_ggcam.py --imgs "$images/" --ggcam "$pred_ggcam/" --output ./ome_output_ggcam
    """

}
