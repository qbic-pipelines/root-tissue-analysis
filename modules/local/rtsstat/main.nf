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
    path(metadata)
    path(ratios)
    path(brightfield)
    path(predictions)
    path(omeout)
    path(omeout_uncert)
    path(omeout_ggcam)

    output:

    //tuple val(meta), path("*.html"), emit: html
    path("ratios.tsv") , emit: ratios
    path("reporting.html") , emit: report

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    rtsstat.py --meta "$metadata/metadata.csv" --ratios "$ratios/" --segs "$predictions/"
    cp /reporting.ipynb ./report_wo_par.ipynb
    papermill -p ratio_img_path $ratios/ -p pred_path $predictions/ -p img_path $brightfield/ -p ome_output_path $omeout/ -p ome_output_uncert_path $omeout_uncert/ -p ome_output_ggcam_path $omeout_ggcam/ report_wo_par.ipynb reporting.ipynb
    jupyter nbconvert --to html --execute reporting.ipynb --no-input
    """

}
