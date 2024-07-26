#'@include PlainTextParam.R
#'@title Methods to save and load contents of a MsExperiment object
#'
#' @author Philippine Louail
#'
#' @importFrom ProtGenerics spectra
#'
#' @importFrom S4Vectors DataFrame SimpleList
#'
#' @noRd
NULL

#' @rdname PlainTextParam
setMethod("saveMsObject",
          signature(object = "MsExperiment",
                    param = "PlainTextParam"),
          function(object, param){
              dir.create(path = param@path,
                         recursive = TRUE,
                         showWarnings = FALSE)
              ## sample data
              write.table(as.data.frame(object@sampleData), sep = "\t",
                          file = file.path(param@path,
                                           "ms_experiment_sample_data.txt"))

              ## sample data links
              sdl <- object@sampleDataLinks
              if (length(sdl) > 0) {
                  lapply(names(sdl), function(x){
                      fl <- file.path(
                          param@path,
                          paste0("ms_experiment_sample_data_links_", x, ".txt"))
                      write.table(sdl[[x]], file = fl, row.names = FALSE,
                                  col.names = FALSE, sep = "\t")
                  })
                  write.table(
                      sdl@elementMetadata, sep = "\t", row.names = FALSE,
                      file = file.path(param@path,
                                       "ms_experiment_link_mcols.txt"))
              }
              ## call export of individual other objects (not MsExperiment data)
              saveMsObject(spectra(object), param)
              ## at some point also chromatograms, etc.
          }
)

#' @rdname PlainTextParam
#'
#' @importMethodsFrom S4Vectors mcols<-
setMethod("readMsObject",
          signature(object = "MsExperiment",
                    param = "PlainTextParam"),
          function(object, param, ...) {
              ## read sample data
              fl <- file.path(param@path, "ms_experiment_sample_data.txt")
              if (!file.exists(fl))
                  stop("No 'ms_experiment_sample_data.txt' file found in ",
                       "the provided path.")
              sd <- read.table(fl, sep = "\t")
              object@sampleData <- DataFrame(sd, row.names = NULL)

              ## read spectra
              object@spectra <- readMsObject(Spectra::Spectra(), param, ...)

              ## sample data links
              fl <- list.files(
                  param@path,
                  pattern = "ms_experiment_sample_data_links_.*\\.txt",
                  full.names = TRUE)
              if (length(fl) > 0) {
                  n <- gsub("ms_experiment_sample_data_links_|\\.txt", "",
                            basename(fl))
                  sdl <- lapply(fl, function(x) {
                      unname(as.matrix(read.table(x, sep = "\t")))
                  })
                  names(sdl) <- n
                  object@sampleDataLinks <- SimpleList(sdl)
                  em <- read.table(file.path(param@path,
                                             "ms_experiment_link_mcols.txt"),
                                   sep = "\t", row.names = NULL, header = TRUE)
                  mcols(object@sampleDataLinks) <- DataFrame(
                      em, row.names = NULL)
              }

              validObject(object)
              object
          })
