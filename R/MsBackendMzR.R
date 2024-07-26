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
                                  append = TRUE, row.names = FALSE))
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
