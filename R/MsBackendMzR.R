#'@include PlainTextParam.R
#'@title Methods to save and load contents of an MsBackendMzR object
#'
#' @author Philippine Louail
#'
#' @importFrom ProtGenerics dataStorage dataStorage<-
#'
#' @importFrom utils read.table write.table
#'
#' @importFrom MsCoreUtils common_path
#'
#' @importFrom S4Vectors DataFrame
#'
#' @importFrom methods validObject
#'
#' @noRd
NULL

#' @rdname PlainTextParam
setMethod("saveMsObject", signature(object = "MsBackendMzR",
                                    param = "PlainTextParam"),
          function(object, param) {
              dir.create(path = param@path,
                         recursive = TRUE,
                         showWarnings = FALSE)
              object <-  Spectra::dropNaSpectraVariables(object)
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (file.exists(fl))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              if (nrow(object@spectraData))
                  suppressWarnings(
                      write.table(object@spectraData,
                                  file = fl, sep = "\t", quote = TRUE,
                                  append = TRUE))
          })

#' @rdname PlainTextParam
setMethod("readMsObject", signature(object = "MsBackendMzR",
                                   param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (!file.exists(fl))
                  stop("No 'backend_data.txt' file found in the provided path.")
              l2 <- readLines(fl, n = 2)
              if (l2[1] != "# MsBackendMzR")
                  stop("Invalid class in 'ms_backend_data.txt' file.",
                  "Should run with object = ", l2[1])
              if (length(l2) > 1L) {
                  data <- read.table(file = fl, sep = "\t", header = TRUE)
                  rownames(data) <- NULL
                  object@spectraData <- DataFrame(data)
                  if (length(spectraPath) > 0) {
                      object <- .ms_backend_mzr_update_storage_path(
                          object, spectraPath)
                  }
              }
              validObject(object)
              object
          })

.ms_backend_mzr_update_storage_path <- function(x, spectraPath = character()) {
    if (!length(x)) return(x)
    old <- common_path(dataStorage(x))
    dataStoragePaths <- dataStorage(x)
    normalizedDataStoragePaths <- normalizePath(
        dataStoragePaths, winslash = "/", mustWork = FALSE)
    spectraPath <- normalizePath(spectraPath, winslash = "/", mustWork = FALSE)
    x@spectraData$dataStorage <- sub(old, spectraPath,
                                     normalizedDataStoragePaths)
    x
}

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @importMethodsFrom alabaster.base saveObject
#'
#' @importFrom alabaster.base saveObjectFile
#'
#' @importFrom alabaster.base altSaveObject
#'
#' @exportMethod saveObject
#'
#' @rdname AlabasterParam
setMethod("saveObject", "MsBackendMzR", function(x, path, ...) {
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    saveObjectFile(path, "ms_backend_mz_r",
                   list(ms_backend_mz_r =list(version = "1.0")))
    tryCatch({
        do.call(altSaveObject,
                list(x = x@spectraData, path = file.path(path, "spectra_data")))
    }, error = function(e) {
        stop("failed to save 'spectraData' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    tryCatch({
        do.call(altSaveObject,
                list(x = x@peaksVariables,
                     path = file.path(path, "peaks_variables")))
    }, error = function(e) {
        stop("failed to save 'peaksVariables' of ", class(x)[1L], "\n - ",
             e$message)
    })
})

#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @noRd
validateAlabasterMsBackendMzR <- function(path = character(),
                                          metadata = list()) {
    .check_directory_content(path, c("spectra_data", "peaks_variables"))
}

#' @importFrom alabaster.base altReadObject
#'
#' @importFrom alabaster.base readObject
#'
#' @importFrom alabaster.base registerReadObjectFunction
#'
#' @export readObject
#'
#' @noRd
readAlabasterMsBackendMzR <- function(path = character(), metadata = list(),
                                      spectraPath = character()) {
    if (!.is_spectra_installed())
        stop("Required package 'Spectra' missing. Please install ",
             "and try again.", call. = FALSE)
    validateAlabasterMsBackendMzR(path, metadata)
    sdata <- altReadObject(file.path(path, "spectra_data"))
    pvars <- altReadObject(file.path(path, "peaks_variables"))
    be <- Spectra::MsBackendMzR()
    be@spectraData <- sdata
    be@peaksVariables <- pvars
    if (length(spectraPath) > 0)
        be <- .ms_backend_mzr_update_storage_path(be, spectraPath)
    validObject(be)
    be
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "MsBackendMzR",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "MsBackendMzR",
                                   param = "AlabasterParam"),
          function(object, param, spectraPath = character()) {
              readAlabasterMsBackendMzR(path = param@path,
                                        spectraPath = spectraPath)
          })
