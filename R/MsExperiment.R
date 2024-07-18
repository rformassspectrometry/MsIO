#'@include PlainTextParam.R
#'@title Methods to save and load contents of a MsExperiment object
#'
#' @description
#'
#' For `MsExperiment`, the exported data and related text files are:
#'
#' - The backend's [spectraData()] stored in a tabular format in a text file
#'   named *backend_data.txt*.
#'
#' - The `processingQueueVariables`, `processing`, `processingChunkSize()` and
#'   `backend` class information of the object stored in a text file named
#'   *spectra_slots.txt*.
#'
#' - The processing queue of the `Spectra` object, ensuring that any spectra
#'   data modifications are retained. It is stored in a `json` file named
#'   *spectra_processing_queue.json*.
#'
#' - The [sampleData()] stored as a text file named *sample_data.txt*.
#'
#' @author Philippine Louail
#'
#' @importFrom ProtGenerics spectra
#'
#' @importFrom S4Vectors DataFrame
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
              write.table(as.data.frame(MsExperiment::sampleData(object)), sep = "\t",
                          file = file.path(param@path,
                                           "sample_data.txt"))
              ## call export of individual other objects (not MsExperiment data)
              saveMsObject(spectra(object), param)
              ## at some point also chromatograms, etc.
          }
)

#' @rdname PlainTextParam
setMethod("readMsObject",
          signature(object = "MsExperiment",
                    param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              fl <- file.path(param@path, "sample_data.txt")
              if (!file.exists(fl))
                  stop("No 'sample_data.txt' file found in the provided path.")
              sd <- read.table(fl, sep = "\t")
              rownames(sd) <- NULL #read.table force numbering of rownames
              sd <- DataFrame(sd)
              s <- readMsObject(Spectra::Spectra(), param, spectraPath = spectraPath)
              object@spectra <- s
              object@sampleData <- sd
              validObject(object)
              object
          })
