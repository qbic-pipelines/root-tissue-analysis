// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process RATIOCONV {
    //tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }
    container "qbicpipelines/rtaratioconv:dev"
    containerOptions "--network=none"

    input:
    path input

    output:
    path("*ratios") , emit: ratios
    path("*brightfields") , emit: brightfields

    script:
    def software = getSoftwareName(task.process)
    """
    cp /home/ratio_macro.ijm ./
    mkdir output
    xvfb-run -a fiji-linux64 --run ratio_macro.ijm 'inDir="$input/",outDir="output/"'
    mkdir ratios
    mkdir brightfields
    mv output/*_ratio.tif ratios/
    mv output/*.tif brightfields/
    """
}
