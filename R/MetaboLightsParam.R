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
#' providing its unique study `mtblsId`. This function is particularly useful
#' for importing metabolomics data into an `MsExperiment` object for further
#' analysis in the R environment.
#' It is important to note that at present it is only possible to *read*
#' (import) data from MetaboLights, but not to *save* data to MetaboLights.
#'
#' If the study contains multiple assays, the user will be prompted to select
#' which assay to load. The resulting `MsExperiment` object will include a
#' `sampleData` slot populated with data extracted from the selected assay.
#'
#' Users can define how to filter this `sampleData` table by specifying a few
#' parameters. The `keepOntology` parameter is set to `TRUE` by default, meaning
#' that all ontology-related columns are retained. If set to `FALSE`, they are
#' removed. If ontology columns are kept, some column names may be duplicated and
#' therefore numbered. The order of these columns is important, as it reflects the
#' assay and sample information available in MetaboLights.
#'
#' The `keepProtocol` parameter is also set to `TRUE` by default, meaning that
#' all columns related to protocols are kept. If set to `FALSE`, they are removed.
#' The `simplify` parameter (default `simplify = TRUE`) allows to define
#' whether duplicated columns or columns containing only missing values should
#' be removed. In the case of duplicated content, only the first occurring
#' column will be retained.
#'
#' Further filtering can be performed using the `filePattern` parameter of the
#' `MetaboLightsParam` object. The default for this parameter is
#' `"mzML$|CDF$|cdf$|mzXML$"`, which corresponds to the supported raw data file
#' types.
#'
#' @param mtblsId `character(1)` The MetaboLights study ID, which should
#' start with "MTBL". This identifier uniquely specifies the study within the
#' MetaboLights database.
#'
#' @param assayName `character(1)` The name of the assay to load. If the study
#' contains multiple assays and this parameter is not specified, the user will
#' be prompted to select which assay to load.
#'
#' @param filePattern `character(1)` A regular expression pattern to filter the
#' raw data files associated with the selected assay. The default value is
#' `"mzML$|CDF$|cdf$|mzXML$"`, corresponding to the supported raw data file
#' types.
#'
#' @param keepOntology `logical(1)` Whether to keep columns related to ontology
#' in the `sampleData` parameter. Default is `TRUE`.
#'
#' @param keepProtocol `logical(1)` Whether to keep columns related to protocols
#' information in the `sampleData` parameter. Default is `TRUE`.
#'
#' @param simplify `logical(1)` Whether to simplify the `sampleData` table by
#' removing columns filled with NAs or duplicated content. Default is `TRUE`.
#'
#' @inheritParams saveMsObject
#'
#' @returns An `MsExperiment` object with the `sampleData` parameter populated using
#' MetaboLights sample and assay information. The spectra data is represented
#' as a `MsBackendMetabolights` object, generated from the raw data files
#' associated with the selected assay of the specified MetaboLights ID
#' (`mtblsId`).
#'
#' @author Philippine Louail
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @examples
#'
#' library(MsExperiment)
#' # Load a study with the mtblsId "MTBLS39" and selecting specific file pattern
#' # as well as removing ontology and protocol information in the metadata.
#' param <- MetaboLightsParam(mtblsId = "MTBLS39", filePattern = "63A.cdf")
#' ms_experiment <- readMsObject(MsExperiment(), param , keepOntology = FALSE,
#'                               keepProtocol = FALSE)
#'
#' @seealso
#' - `MsExperiment` object, defined in the
#'   ([MsExperiment](https://bioconductor.org/packages/MsExperiment)) package.
#'
#' - `MsBackendMetaboLights` object, defined in the
#'  ([MsBackendMetaboLights](https://github.com/rformassspectrometry/MsBackendMetaboLights))
#'  repository.
#'
#' - [MetaboLights](https://www.ebi.ac.uk/metabolights/index) for accessing
#'   the MetaboLights database.
#'
NULL

#' @noRd
setClass("MetaboLightsParam",
         slots = c(mtblsId = "character",
                   assayName = "character",
                   filePattern = "character"),
         contains = "Param",
         prototype = list(
             mtblsId = character(1),
             assayName = character(1),
             filePattern = character(1)
         ),
         validity = function(object) {
             msg <- NULL
             if (!grepl("^MTBLS", object@mtblsId))
                 msg <- c("'mtblsId' must start with 'MTBLS'")
             msg
         })

#' @rdname MetaboLightsParam
#'
#' @export
MetaboLightsParam <- function(mtblsId = character(), assayName = character(),
                              filePattern = "mzML$|CDF$|cdf$|mzXML$"){
    new("MetaboLightsParam", mtblsId = mtblsId, assayName = assayName,
        filePattern = filePattern)
}
