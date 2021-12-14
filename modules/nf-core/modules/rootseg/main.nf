// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ROOTSEG {
    //tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "ghcr.io/waseju/rts:latest"

    input:
    path(brightfields)

    output:
    
    //tuple val(meta), path("*.html"), emit: html
    path("*predictions") , emit: predictions

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    wget https://zenodo.org/record/5181261/files/model.ckpt
    rts_package -i $brightfields -o predictions -m model.ckpt
    """

}
