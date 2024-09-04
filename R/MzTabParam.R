#' @title Store xcms preprocessing results to a file in mzTab-M format.
#'
#' @name MzTabParam
#'
#' @export
#'
#' @inheritParams saveMsObject
#'
#' @family MS object export and import formats.
#'
#' @description
#' The `saveMsObject()` and `readMsObject()` methods with the `MzTabParam`
#' option enable users to save/load `XcmsExperiment` objects in Mz-Tab-m
#' file format. Mainly the metadata (MTD) and Small molecule feature (SMF)
#' tables will represent the `XcmsExperiment`. More specifically, `sampleData()`
#' of the object will be stored in the metadata section (MTD) along with the
#' user-inputed `studyId`  and `polarity`. The `featureDefinitions()` will be
#' stored in the small molecule feature (SMF) section but by default only the
#' `mzmed`, `rtmed`, `rtmin` and `rtmax` are exported. More info avaialble in
#' `featureDefinitions()` can be exported by specifying the
#' `optionalFeatureColumns` parameter. The `featureValues()` will also be
#' stored in the small molecule feature (SMF) section.
#'
#' The small molecule summary section (SML) will be filled with `null` values
#' as no annotation and identification of compound is performed in `xcms`.
#'
#' Writing data to a folder that contains already exported data will result in
#' an error.
#'
#' @param studyId `character(1)` Will be both the `filename` of the object
#' saved in .mztabm format and the `mzTab-ID` in the file.
#'
#' @param polarity `character(1)` Describes the polarity of the experiment. Two
#' inputs are possible, "positive" (default) or "negative".
#'
#' @param sampleDataColumn `character` strings corresponding to the column
#' name(s) of the `sampleData()` of the `XcmsExperiment` object with the
#' different *variables* of the experiment, for example it could be
#' *"phenotype"*, *"sample_type"*, etc...
#'
#' @param path `character(1)` Define where the file is going to be stored. The
#' default will be `tempdir()`.
#'
#' @param optionalFeatureColumns Optional columns from `featureDefinitions()`
#' that should be exported too. For example it could be *"ms_level"*,
#' *"npeaks"*, etc...
#'
#' @slot dots Correspond to any optional parameters to be passed
#' to the `featureValues()` function. (e.g. parameters `method` or `value`).
#'
#'
#' @note
#' This function was build so that the output fit the recommendation of
#' Mz-Tab-m file format version 2.0. These can be found here:
#' (http://hupo-psi.github.io/mzTab/2_0-metabolomics-release/mzTab_format_specification_2_0-M_release.html)
#'
#' @references
#'
#' Hoffmann N, Rein J, Sachsenberg T, Hartler J, Haug K, Mayer G, Alka O,
#' Dayalan S, Pearce JTM, Rocca-Serra P, Qi D, Eisenacher M, Perez-Riverol Y,
#' Vizcaino JA, Salek RM, Neumann S, Jones AR. mzTab-M: A Data Standard for
#' Sharing Quantitative Results in Mass Spectrometry Metabolomics. Anal Chem.
#' 2019 Mar 5;91(5):3302-3310. doi: 10.1021/acs.analchem.8b04310. Epub 2019 Feb
#' 13. PMID: 30688441; PMCID: PMC6660005.
#'
#' @author Philippine Louail, Johannes Rainer
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @examples
#' ## Load a test data set with detected peaks, of class `XcmsExperiment`
#' library(xcms)
#' test_xcms <- loadXcmsData()
#'
#' ## Define param
#' param <- MzTabParam(studyId = "test",
#'                     polarity = "positive",
#'                     sampleDataColumn = "sample_type")
#'
#' ## Save as a .mzTabm file
#' saveMsObject(test_xcms, param)
#'
NULL

#' @noRd
setClass("MzTabParam",
         slots = c(studyId = "character",
                   polarity = "character",
                   sampleDataColumn = "character",
                   path = "character",
                   optionalFeatureColumns = "character",
                   dots = "list"
         ),
         contains = "Param",
         prototype = prototype(
             studyId = character(),
             polarity =  character(),
             sampleDataColumn = character(),
             path = character(),
             optionalFeatureColumns = character(),
             dots = list()
         ),
         validity = function(object) {
             msg <- NULL
             if(length(object@studyId) != 1)
                 msg <- c("'studyId' has to be a character string of length 1")
             if(length(object@polarity) != 1)
                 msg <- c(msg, "'polarity' has to be a character string ",
                 "of length 1")
             if(length(object@sampleDataColumn) == 0)
                 msg <- c(msg, "'sampleDataColumn' cannot be empty")
             if (length(object@path) != 1)
                 msg <- c(msg, "'path' has to be a character string of ",
                 "length 1")
             msg
         })

#' @rdname MzTabParam
#'
#' @export
MzTabParam <- function(studyId = character(),
                       polarity = c("positive", "negative"),
                       sampleDataColumn = character(),
                       path = tempdir(),
                       optionalFeatureColumns = character(), ...) {
    polarity <- match.arg(polarity)
    new("MzTabParam", studyId = studyId, polarity = polarity,
        sampleDataColumn = sampleDataColumn, path = path,
        optionalFeatureColumns = optionalFeatureColumns, dots = list(...))
}
