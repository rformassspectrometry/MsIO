#' @include mzTabParam.R
#' @title Methods to save and load contents of a SummarizedExperiment object
#'
#' @importFrom ProtGenerics spectra
#'
#' @importFrom S4Vectors DataFrame
#'
#' @importFrom methods callNextMethod as
#'
#' @importFrom jsonlite serializeJSON unserializeJSON read_json write_json
#'
#' @noRd
NULL

#' @rdname mzTabParam
setMethod("readMsObject",
 signature(object = "SummarizedExperiment", #need to take care of the dependency.
                    param = "mzTabParam"),
          function(object, param){
          if (!file.exists(path))
                  stop("No file found, please check the path")
          ## ... code to set up import
          return(sumexp)
          })

## Phili: I can take care of in depth UT if needed, and detailed documentation,..
## below is an example on how it should be used by the user
#' ## Load mztab-m file into SummarizedExperiment object
#' param <- mzTabParam(path = ...) ## need to have a file in the package to test
#'
#' sumexp <- readMsObject(SummarizedExperiment(), param)
