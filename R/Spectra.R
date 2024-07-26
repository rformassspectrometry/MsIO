#'@include PlainTextParam.R
#'@title Methods to save and load contents of a Spectra object
#'
#' @author Philippine Louail
#'
#' @importFrom jsonlite serializeJSON write_json unserializeJSON read_json
#'
#' @importFrom stats setNames
#'
#' @importFrom methods existsMethod validObject
#'
#' @noRd
NULL

#' @rdname PlainTextParam
setMethod("saveMsObject", signature(object = "Spectra",
                                    param = "PlainTextParam"),
          function(object, param) {
              dir.create(path = param@path,
                         recursive = TRUE,
                         showWarnings = FALSE)
              if (!existsMethod("saveMsObject", c(class(object@backend)[1L],
                                                  "PlainTextParam")))
                  stop("Can not store a 'Spectra' object with backend '",
                       class(object@backend)[1L], "'")
              saveMsObject(object@backend, param = param)
              .export_spectra_processing_queue(object, path = param@path)
              .export_spectra_slots(object, path = param@path)
          })

#' @rdname PlainTextParam
setMethod("readMsObject", signature(object = "Spectra",
                                   param = "PlainTextParam"),
          function(object, param, ...) {
              fl  <- file.path(param@path, "spectra_slots.txt")
              if (!file.exists(fl))
                  stop("No 'spectra_slots.txt' file found in ", param@path)
              fls  <- readLines(fl)
              var_names <- sub(" =.*", "", fls)
              var_values <- sub(".* = ", "", fls)
              variables <- setNames(var_values, var_names)
              if (!existsMethod("readMsObject", c(variables[["backend"]],
                                                 "PlainTextParam")))
                  stop("Can not read a 'Spectra' object with backend '",
                       variables["backend"], "'")
              b <- readMsObject(
                  object = do.call(what = variables[["backend"]],
                                   args = list()), param = param, ...)
              object@backend <- b
              object@processingQueueVariables <- unlist(
                  strsplit(variables[["processingQueueVariables"]],
                           "|", fixed = TRUE))
              object@processing <- unlist(
                  strsplit(variables[["processing"]], "|" , fixed = TRUE))
              object@processingChunkSize <- as.numeric(
                  variables[["processingChunkSize"]])
              fl <- file.path(param@path, "spectra_processing_queue.json")
              if (file.exists(fl))
                  object <- .import_spectra_processing_queue(object, file = fl)
              validObject(object)
              object
          })

#' Spectra slots
#' @description
#'
#' Export the `processingQueueVariables`, `processing` and
#' `processingChunkSize` slots of a `Spectra` object to a text file.
#' The class of the backend is also saved.
#'
#' @param x  `Spectra`
#'
#' @noRd
.export_spectra_slots <-function(x, path = character()){
    con <- file(file.path(path, "spectra_slots.txt"), open = "wt")
    on.exit(close(con))
    pq <- x@processingQueueVariables
    writeLines(paste0("processingQueueVariables = ", paste(pq, collapse = "|")),
               con = con)
    p <- x@processing
    writeLines(paste0("processing = ", paste(p, collapse = "|")), con = con)
    writeLines(paste0("processingChunkSize = ",
                      Spectra::processingChunkSize(x)), con = con)
    writeLines(paste0("backend = ", class(x@backend)[1L]), con = con)
}

#' Processing queue
#' @param x  `Spectra`
#'
#' @noRd
.export_spectra_processing_queue <- function(x, path = character()) {
    pq <- x@processingQueue
    if (length(pq))
        write_json(serializeJSON(pq),
                   file.path(path, "spectra_processing_queue.json"))
}

#' @noRd
.import_spectra_processing_queue <- function(x, file = character()) {
    x@processingQueue <- unserializeJSON(read_json(file)[[1L]])
    x
}
