#'@title Method to save and load content of an MsBackend object
#'
#'
#' @description
#'
#' Import/export of the MS data depends on the respective implementation of
#' the respective `MsBackend` object.
#'
#' For `MsBackendMzR`, the exported data and related text files are:
#'
#' - The backend's [spectraData()] stored in a tabular format in a text file
#'   named *backend_data.txt*.
#'
#' @author Philippine Louail
#'
#' @importFrom Spectra processingChunkSize dropNaSpectraVariables Spectra MsBackendMzR
#'
#' @importFrom utils read.table write.table
#'
#' @importFrom MsCoreUtils common_path
#'
#'
NULL

#### Need to try to switch to use albaster for the DataFrame export
#' @rdname PlainTextParam
setMethod("saveMsObject", signature(object = "MsBackendMzR",
                                    param = "PlainTextParam"),
          function(object, param) {
              dir.create(path = param@path,
                         recursive = TRUE,
                         showWarnings = FALSE)
              object <-  dropNaSpectraVariables(object)
              fl <- file.path(param@path, "backend_data.txt")
              if (file.exists(fl))
                  warning("Overwriting already present 'backend_data.txt' file")
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              suppressWarnings(
                  write.table(object@spectraData,
                              file = fl, sep = "\t", quote = FALSE,
                              append = TRUE, row.names = FALSE))
          })

#' @rdname PlainTextParam
setMethod("loadMsObject", signature(object = "MsBackendMzR",
                                   param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              b <- MsBackendMzR()
              fl <- file.path(param@path, "backend_data.txt")
              if (!file.exists(fl))
                  stop("No 'backend_data.txt' file found in the provided path.")
              data <- read.table(file = fl, sep = "\t", header = TRUE)
              rownames(data) <- NULL
              data <- DataFrame(data)
              b@spectraData <- data
              if (length(spectraPath) > 0) {
                  old <- common_path(dataStorage(b))
                  ## if (nchar(old) > 0)
                  ##     old <- paste0(old, "/")
                  dataStorage(b) <- sub(old, spectraPath, dataStorage(b))
              }
              b
          })
