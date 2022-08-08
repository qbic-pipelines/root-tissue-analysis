// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ROOTSEG_PRED {
    //tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtarootseg:dev"

    input:
    path(brightfields)

    output:

    //tuple val(meta), path("*.html"), emit: html
    path("*pred") , emit: pred

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    wget https://zenodo.org/record/6937290/files/mark1-PHDFM-u2net-model.ckpt
    rts-pred -i $brightfields -o pred -m mark1-PHDFM-u2net-model.ckpt --suffix ""
    """

}

process ROOTSEG_UNCERT {
    //tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtarootseg:dev"

    input:
    path(brightfields)

    output:

    //tuple val(meta), path("*.html"), emit: html
    path("*pred_uncert") , emit: pred_uncert

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    wget https://zenodo.org/record/6937290/files/mark1-PHDFM-u2net-model.ckpt
    rts-pred-uncert -i $brightfields -o pred_uncert -m mark1-PHDFM-u2net-model.ckpt --suffix ""  -t 10
    """

}

process ROOTSEG_GGCAM {
    //tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }
    container "qbicpipelines/rtarootseg:dev"

    input:
    path(brightfields)

    output:

    //tuple val(meta), path("*.html"), emit: html
    path("*pred_ggcam") , emit: pred_ggcam

    //path  "*.version.txt"          , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    //def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    wget https://zenodo.org/record/6937290/files/mark1-PHDFM-u2net-model.ckpt
    rts-feat-imp -i $brightfields -o pred_ggcam -m mark1-PHDFM-u2net-model.ckpt --suffix "" -t 0
    rts-feat-imp -i $brightfields -o pred_ggcam -m mark1-PHDFM-u2net-model.ckpt --suffix "" -t 1
    rts-feat-imp -i $brightfields -o pred_ggcam -m mark1-PHDFM-u2net-model.ckpt --suffix "" -t 2
    rts-feat-imp -i $brightfields -o pred_ggcam -m mark1-PHDFM-u2net-model.ckpt --suffix "" -t 3
    rts-feat-imp -i $brightfields -o pred_ggcam -m mark1-PHDFM-u2net-model.ckpt --suffix "" -t 4
    """

}
