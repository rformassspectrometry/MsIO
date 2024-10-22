#' @rdname PlainTextParam
setMethod("readMsObject", signature(object = "MsBackendMetaboLights",
                                    param = "PlainTextParam"),
          function(object, param, offline = FALSE) {
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (!file.exists(fl))
                  stop("No 'backend_data.txt' file found in the provided path.")
              l2 <- readLines(fl, n = 2)
              if (l2[1] != "# MsBackendMetaboLights")
                  stop("Invalid class in 'ms_backend_data.txt' file.",
                  "Should run with object = ", l2[1])
              if (length(l2) > 1L) {
                  data <- read.table(file = fl, sep = "\t", header = TRUE)
                  rownames(data) <- NULL
                  slot(object, "spectraData", check = FALSE) <- DataFrame(data)
                  MsBackendMetaboLights::mtbls_sync(object, offline = offline)
              }
              validObject(object)
              object
          })

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "MsBackendMetaboLights", function(x, path, ...) {
    .save_object_spectra_data(x, path, object = "ms_backend_metabo_lights")
})

#' @noRd
#'
#' @importFrom methods slot<-
readAlabasterMsBackendMetaboLights <- function(path = character(),
                                               metadata = list(),
                                               offline = FALSE) {
    if (!.is_spectra_installed())
        stop("Required package 'Spectra' missing. Please install ",
             "and try again.", call. = FALSE)
    if (!.is_ms_backend_metabo_lights_installed())
        stop("Required package 'MsBackendMetaboLights' missing. ",
             "Please install and try again.", call. = FALSE)
    validateAlabasterMsBackendMzR(path, metadata)
    sdata <- altReadObject(file.path(path, "spectra_data"))
    pvars <- altReadObject(file.path(path, "peaks_variables"))
    be <- MsBackendMetaboLights::MsBackendMetaboLights()
    slot(be, "spectraData", check = FALSE) <- sdata
    slot(be, "peaksVariables", check = FALSE) <- pvars
    MsBackendMetaboLights::mtbls_sync(be, offline = offline)
    validObject(be)
    be
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "MsBackendMetaboLights",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "MsBackendMetaboLights",
                                    param = "AlabasterParam"),
          function(object, param, offline = FALSE) {
              readAlabasterMsBackendMetaboLights(path = param@path,
                                                 offline = offline)
          })
