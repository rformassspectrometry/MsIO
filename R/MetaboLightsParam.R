#' @title Load content from a MetaboLights study
#'
#' @name MetaboLightsParam
#'
#' @export
#'
#' @family MS object export and import formats
#'
#' @description
#'
#' The `MetaboLightsParam` class and the associated `readMsObject()` method
#' allow users to load an `MsExperiment` object from a study in the
#' MetaboLights database (https://www.ebi.ac.uk/metabolights/index) by
#' providing its unique study `studyId`. This function is particularly useful
#' for importing metabolomics data into an `MsExperiment` object for further
#' analysis within the R environment. It's important to note that this method
#' can *only* be used for import into an R environement using `readMsObject()`.
#' It cannot be used with the `saveMsObject()` method.
#'
#' If the study contains multiple assays, the user will be prompted to select
#' which assay to load. The resulting `MsExperiment` object will include a
#' `sampleData` slot populated with data extracted from the selected assay.
#' Columns in the `sampleData` that contain only `NA` values are automatically
#' removed, and an additional column is added to track the injection index.
#'
#' @param studyId `character(1)` The MetaboLights study studyId, which should
#' start with "MTBL". This identifier uniquely specifies the study within the
#' MetaboLights database.
#'
#' @inheritParams saveMsObject
#'
#' @returns (for now ?) A `MsExperiment` object with only the sampleData slots
#' filled (will be updated when MetaboLightsBackend available ?).
#'
#' @author Philippine Louail
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @examples
#' library(MsExperiment)
#' # Load a study with the studyId "MTBLS10035"
#' param <- MetaboLightsParam(studyId = "MTBLS10035")
#' ms_experiment <- readMsObject(MsExperiment(), param)
#'
#' @seealso
#' - `MsExperiment` object, defined in the
#'   ([MsExperiment](https://bioconductor.org/packages/MsExperiment)) package.
#' - [MetaboLights](https://www.ebi.ac.uk/metabolights/index) for accessing
#'   the MetaboLights database.
#'
NULL

#' @noRd
setClass("MetaboLightsParam",
         slots = c(studyId = "character"),
         contains = "Param",
         prototype = list(
             studyId = character(1)
         ),
         validity = function(object) {
             msg <- NULL
             if (!grepl("^MTBLS", object@studyId))
                 msg <- c("'studyId' must start with 'MTBLS'")
             msg
         })

#' @rdname MetaboLightsParam
#'
#' @export
MetaboLightsParam <- function(studyId = character(1)) {
    new("MetaboLightsParam", studyId = studyId)
}
