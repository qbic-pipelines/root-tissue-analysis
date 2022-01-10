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
    container "ghcr.io/waseju/rtsstat:latest"

    input:
    path(metadata)
    path(ratios)
    path(predictions)

    output:

    //tuple val(meta), path("*.html"), emit: html
    path("boxplot_*.pdf") , emit: boxplot
    path("ratios.csv") , emit: ratios

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    rtsstat.py --meta "$metadata/metadata.csv" --ratios "$ratios/" --segs "$predictions/"
    """

}
