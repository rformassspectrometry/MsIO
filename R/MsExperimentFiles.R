#' @include PlainTextParam.R
################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
setMethod("saveObject", "MsExperimentFiles", function(x, path, ...) {
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    alabaster.base::saveObjectFile(path, "ms_experiment_files",
                                   list(spectra = list(version = "1.0")))
    altSaveObject(as(x, "SimpleCharacterList"), file.path(path, "x"))
})

validateAlabasterMsExperimentFiles <- function(path = character(),
                                               metadata = list()) {
    .check_directory_content(path, c("x"))
}

readAlabasterMsExperimentFiles <- function(path = character(),
                                           metadata = list(), ...) {
    requireNamespace("MsExperiment", quietly = TRUE)
    validateAlabasterMsExperimentFiles(path, metadata)
    res <- as(altReadObject(file.path(path, "x")), "SimpleCharacterList")
    as(res, "MsExperimentFiles")
}
