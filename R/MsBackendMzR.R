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
                  warning("Overwriting already present ",
                          "'ms_backend_data.txt' file")
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
                      old <- common_path(dataStorage(object))
                      dataStoragePaths <- dataStorage(object)
                      normalizedDataStoragePaths <- normalizePath(
                          dataStoragePaths, winslash = "/", mustWork = FALSE)
                      dataStorage(object) <- sub(old, spectraPath,
                                                 normalizedDataStoragePaths)
                  }
              }
              validObject(object)
              object
          })

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
    alabaster.base::saveObjectFile(path, "ms_backend_mz_r",
                                   list(ms_backend_mz_r = list(version = "1.0")))
    message("length peaksVariables ", length(x@peaksVariables))
    x <-  Spectra::dropNaSpectraVariables(x)
    message("length peaksVariables ", length(x@peaksVariables))
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
#' @rdname AlabasterParam
validateMzBackendMzR <- function(path = character(),
                                 metadata = list()) {
    if (!dir.exists(file.path(path, "spectra_data")))
        stop("required directory 'spectra_data' not found in \"", path, "\"")
    if (!dir.exists(file.path(path, "peaks_variables")))
        stop("required directory 'peaks_variables' not found in \"", path, "\"")
}

#' @importFrom alabaster.base altReadObject
#'
#' @importFrom alabaster.base readObject
#'
#' @export readObject
#'
#' @importFrom alabaster.base registerReadObjectFunction
#'
#' @rdname AlabasterParam
readMzBackendMzR <- function(path = character(), metadata = list()) {
    validateMzBackendMzR(path, metadata)
    sdata <- altReadObject(file.path(path, "spectra_data"))
    pvars <- altReadObject(file.path(path, "peaks_variables"))
    message("length pvars ", length(pvars))
    be <- Spectra::MsBackendMzR()
    be@spectraData <- sdata
    be@peaksVariables <- pvars
    be
}
