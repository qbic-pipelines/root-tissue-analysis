/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowNfroot.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.ratioconv_config]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_ratioconv_config        = file("$projectDir/assets/ratioconv_config.yaml", checkIfExists: true)
ch_ratioconv_custom_config = params.ratioconv_config ? Channel.fromPath(params.ratioconv_config) : Channel.empty()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


//
// MODULE: Local to the pipeline
//
include { GET_SOFTWARE_VERSIONS } from '../modules/local/get_software_versions' addParams( options: [publish_files : ['tsv':'']] )

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK } from '../subworkflows/local/input_check' addParams( options: [:] )

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/


//
// MODULE: Installed directly from nf-core/modules
//
include { ROOTSEG_PRED  } from '../modules/local/rootseg/main'
include { ROOTSEG_UNCERT  } from '../modules/local/rootseg/main'
include { ROOTSEG_GGCAM  } from '../modules/local/rootseg/main'
include { RTSSTAT  } from '../modules/local/rtsstat/main'
include { RATIOCONV } from '../modules/local/ratioconv/main'
include { OMEOUT } from '../modules/local/omeout/main'
include { OMEOUT_UNCERT } from '../modules/local/omeout/main'
include { OMEOUT_GGCAM } from '../modules/local/omeout/main'



/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def ratioconv_report = []

workflow NFROOT {

    ch_software_versions = Channel.empty()

    //
    // SUBWORKFLOW:
    //
    INPUT_CHECK (
        ch_input
    )

    //
    // MODULE:
    //
    RATIOCONV (
        INPUT_CHECK.out.reads
    )

    ROOTSEG_PRED (
        RATIOCONV.out.brightfields
    )

    ROOTSEG_UNCERT (
        RATIOCONV.out.brightfields
    )

    ROOTSEG_GGCAM (
        RATIOCONV.out.brightfields
    )

    OMEOUT (
        RATIOCONV.out.brightfields,
        RATIOCONV.out.ratios,
        ROOTSEG_PRED.out.pred
    )

    OMEOUT_UNCERT(
        RATIOCONV.out.brightfields,
        ROOTSEG_UNCERT.out.pred_uncert
    )

    OMEOUT_GGCAM(
        RATIOCONV.out.brightfields,
        ROOTSEG_GGCAM.out.pred_ggcam
    )

    RTSSTAT(
        INPUT_CHECK.out.reads,
        RATIOCONV.out.ratios,
        RATIOCONV.out.brightfields,
        ROOTSEG_PRED.out.pred,
        OMEOUT.out.omeout,
        OMEOUT_UNCERT.out.omeout,
        OMEOUT_GGCAM.out.omeout
    )

    
    //ch_software_versions = ch_software_versions.mix(ROOTSEG_PRED.out.version.first().ifEmpty(null))

    //
    // MODULE: Pipeline reporting
    //
    ch_software_versions
        .map { it -> if (it) [ it.baseName, it ] }
        .groupTuple()
        .map { it[1][0] }
        .flatten()
        .collect()
        .set { ch_software_versions }

    GET_SOFTWARE_VERSIONS (
        ch_software_versions.map { it }.collect()
    )

    //
    // MODULE: RatioConv
    //
    workflow_summary    = WorkflowNfroot.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    ch_ratioconv_files = Channel.empty()
    ch_ratioconv_files = ch_ratioconv_files.mix(Channel.from(ch_ratioconv_config))
    ch_ratioconv_files = ch_ratioconv_files.mix(ch_ratioconv_custom_config.collect().ifEmpty([]))
    ch_ratioconv_files = ch_ratioconv_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_ratioconv_files = ch_ratioconv_files.mix(GET_SOFTWARE_VERSIONS.out.yaml.collect())
    //ch_ratioconv_files = ch_ratioconv_files.mix(ROOTSEG_PRED.out.zip.collect{it[1]}.ifEmpty([]))

    // RATIOCONV (
    //    ch_ratioconv_files.collect()
    //)
    //ratioconv_report       = RATIOCONV.out.report.toList()
    //ch_software_versions = ch_software_versions.mix(RATIOCONV.out.version.ifEmpty(null))
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, ratioconv_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
========================================================================================
    THE END
========================================================================================
*/
