#' @include PlainTextParam.R
#' @title Methods to save and load contents of a Spectra object
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
#'
#' @importFrom methods getFunction
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
              ## Check if the library to load the backend class is available.
              ## This should also enable backends that are defined in other
              ## packages than Spectra. Accessing directly the "globalenv" to
              ## ensure we can access functions/classes there.
              fun <- getFunction(variables[["backend"]], mustFind = FALSE,
                                 where = topenv(globalenv()))
              if (!length(fun))
                  stop("Can not create an instance of the MsBackend class \"",
                       variables[["backend"]], "\". Please first load the ",
                       "library that provides this class and try again.",
                       call. = FALSE)
              b <- readMsObject(fun(), param, ...)
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
    write_json(serializeJSON(pq),
               file.path(path, "spectra_processing_queue.json"))
}

#' @noRd
.import_spectra_processing_queue <- function(x, file = character()) {
    x@processingQueue <- unserializeJSON(read_json(file)[[1L]])
    x
}

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "Spectra", function(x, path, ...) {
    if (!existsMethod("saveObject", class(x@backend)[1L]))
        stop("No method to save a backend of type \"", class(x@backend)[1L],
             "\" available yet")
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    saveObjectFile(path, "spectra",
                   list(spectra =list(version = "1.0")))
    tryCatch({
        do.call(altSaveObject,
                list(x = x@backend, path = file.path(path, "backend")))
    }, error = function(e) {
        stop("failed to save 'backend' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    .export_spectra_processing_queue(x, path = path)
    altSaveObject(x@processingQueueVariables,
                  path = file.path(path, "processing_queue_variables"))
    altSaveObject(x@processing, path = file.path(path, "processing"))
    altSaveObject(x@metadata, path = file.path(path, "metadata"))
    altSaveObject(x@processingChunkSize,
                  path = file.path(path, "processing_chunk_size"))
})

validateAlabasterSpectra <- function(path = character(),
                                     metadata = list()) {
    .check_directory_content(path, c("backend", "processing_queue_variables",
                                     "spectra_processing_queue.json",
                                     "processing", "metadata",
                                     "processing_chunk_size"))
}

readAlabasterSpectra <- function(path = character(), metadata = list(),
                                 ...) {
    if (!requireNamespace("Spectra", quietly = TRUE))
        stop("Required package 'Spectra' missing. Please install ",
             "and try again.", call. = FALSE)

    validateAlabasterSpectra(path, metadata)
    s <- Spectra::Spectra()
    s@backend <- altReadObject(file.path(path, "backend"), ...)
    s <- .import_spectra_processing_queue(
        s, file.path(path, "spectra_processing_queue.json"))
    s@processingQueueVariables <- altReadObject(file.path(
        path, "processing_queue_variables"))
    s@processing <- altReadObject(file.path(path, "processing"))
    s@metadata <- altReadObject(file.path(path, "metadata"))
    s@processingChunkSize <- altReadObject(
        file.path(path, "processing_chunk_size"))
    validObject(s)
    s
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "Spectra",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "Spectra",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterSpectra(path = param@path, ...)
          })
