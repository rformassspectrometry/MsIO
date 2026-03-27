#' @rdname PlainTextParam
setMethod("saveMsObject", signature(object = "MsBackendCached",
                                    param = "PlainTextParam"),
          function(object, param) {
              dir.create(path = param@path,
                         recursive = TRUE,
                         showWarnings = FALSE)
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (file.exists(fl))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              writeLines(paste0("# ", class(object)[1L]), con = fl)
              if (nrow(object@localData))
                  suppressWarnings(write.table(
                      object@localData, file = fl, sep = "\t", quote = TRUE,
                      append = TRUE))
              fl <- file.path(param@path, "ms_backend_nspectra.txt")
              writeLines(as.character(object@nspectra), fl)
              fl <- file.path(param@path, "ms_backend_spectra_variables.txt")
              writeLines(paste0(object@spectraVariables, collapse = "\t"), fl)
          })

#' @rdname PlainTextParam
setMethod("readMsObject", signature(object = "MsBackendCached",
                                   param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              fl <- file.path(param@path, "ms_backend_data.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_data.txt' file found in the path.")
              l2 <- readLines(fl, n = 2)
              if (l2[1] != "# MsBackendCached")
                  stop("Invalid class in 'ms_backend_data.txt' file. ",
                       "Should run with object = ", l2[1])
              if (length(l2) > 1L) {
                  data <- read.table(file = fl, sep = "\t", header = TRUE)
                  rownames(data) <- NULL
              } else data <- data.frame()
              fl <- file.path(param@path, "ms_backend_nspectra.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_nspectra.txt' found in the path")
              n <- as.integer(readLines(fl)[1L])
              if (is.na(n)) stop("Corrupt 'ms_backend_nspectra.txt' file")
              fl <- file.path(param@path,"ms_backend_spectra_variables.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_spectra_variables.txt' ",
                       "found in the provided path")
              sv <- strsplit(readLines(fl)[1L], "\t")[[1L]]
              Spectra::backendInitialize(object, data = data, nspectra = n,
                                         spectraVariables = sv)
          })

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "MsBackendCached", function(x, path, ...) {
    .ms_backend_cached_save(x, path, object = "ms_backend_cached")
})

.ms_backend_cached_save <- function(x, path, object, version = "1.0") {
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    l <- list(list(version = version))
    names(l) <- object
    saveObjectFile(path, object, l)
    tryCatch({
        do.call(altSaveObject,
                list(x = x@localData, path = file.path(path, "local_data")))
    }, error = function(e) {
        stop("failed to save 'localData' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    tryCatch({
        do.call(altSaveObject,
                list(x = x@nspectra,
                     path = file.path(path, "nspectra")))
    }, error = function(e) {
        stop("failed to save 'nspectra' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    tryCatch({
        do.call(altSaveObject,
                list(x = x@spectraVariables,
                     path = file.path(path, "spectra_variables")))
    }, error = function(e) {
        stop("failed to save 'spectraVariables' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
}

validateAlabasterMsBackendCached <- function(path = character(),
                                             metadata = list()) {
    .check_directory_content(path, c("spectra_variables", "nspectra",
                                     "local_data"))
}

readAlabasterMsBackendCached <- function(path = character(),
                                         metadata = list()) {
    if (!.is_spectra_installed())
        stop("Required package 'Spectra' missing. Please install ",
             "and try again.", call. = FALSE)
    validateAlabasterMsBackendCached(path, metadata)
    ld <- as.data.frame(altReadObject(file.path(path, "local_data")))
    sv <- altReadObject(file.path(path, "spectra_variables"))
    n <- altReadObject(file.path(path, "nspectra"))
    be <- Spectra::MsBackendCached()
    Spectra::backendInitialize(be, data = ld, spectraVariables = sv,
                               nspectra = n)
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "MsBackendCached",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "MsBackendCached",
                                   param = "AlabasterParam"),
          function(object, param, spectraPath = character()) {
              readAlabasterMsBackendCached(path = param@path)
          })
