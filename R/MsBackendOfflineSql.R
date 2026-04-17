## MsBackendSql::MsBackendOfflineSql
## Information needed to serialize:
## - @driver: database driver. Should serialize the class (and package?)
## - @dbname: database name, just a character
## - @user: database user, character. can be NULL/empty
## - @password: we DON'T want to store that. This should be a parameter to the
##   import function.
## - @host: character we can export.
## - @port: integer.
## - @spectraIds: integer()
## - @.tables: `list` - gets initialized by `backendInitialize()`.

#' @rdname PlainTextParam
setMethod("saveMsObject", signature(object = "MsBackendOfflineSql",
                                    param = "PlainTextParam"),
          function(object, param) {
              callNextMethod() # Save MsBackendCached content.
              info <- data.frame(
                  key = c("dbname", "user", "host", "port"),
                  value = c(ifelse(length(object@dbname), object@dbname, ""),
                            ifelse(length(object@user), object@user, ""),
                            ifelse(length(object@host), object@host, ""),
                            object@port))
              write.table(info, file.path(param@path, "ms_backend_dbinfo.txt"),
                          quote = TRUE, sep = "\t", row.names = FALSE)
              write.table(data.frame(spectra_id = object@spectraIds),
                          file.path(param@path, "ms_backend_spectra_ids.txt"),
                          sep = "\t", row.names = FALSE)
              .sql_save_driver(object@driver, param@path)
          })

#' @rdname PlainTextParam
setMethod("readMsObject", signature(object = "MsBackendOfflineSql",
                                   param = "PlainTextParam"),
          function(object, param, password = character()) {
              parent <- .read_ms_backend_cached_text(
                  param@path, "MsBackendOfflineSql") # get MsBackendCached data
              fl <- file.path(param@path, "ms_backend_dbinfo.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_dbinfo.txt' file found in the path")
              info <- read.table(fl, header = TRUE, sep = "\t")
              dbname <- as.character(info$value[info$key == "dbname"])
              user <- as.character(info$value[info$key == "user"])
              host <- as.character(info$value[info$key == "host"])
              port <- suppressWarnings(
                  as.integer(info$value[info$key == "port"]))
              if (is.na(dbname) || dbname == "") dbname <- character()
              if (is.na(user) || user == "") user <- character()
              if (is.na(host) || host == "") host <- character()
              fl <- file.path(param@path, "ms_backend_spectra_ids.txt")
              if (!file.exists(fl))
                  stop("No 'ms_backend_spectra_ids.txt' file found in the path")
              sids <- as.integer(read.table(fl, header = TRUE)[, 1L])
              drv <- .sql_load_driver(param@path)
              if (!is.null(drv))
                  object <- Spectra::backendInitialize(
                                         object, drv = drv, dbname = dbname,
                                         user = user, password = password,
                                         host = host, port = port)
              object@spectraIds <- sids
              object@localData <- parent@localData
              object@nspectra <- parent@nspectra
              object@spectraVariables <- parent@spectraVariables
              validObject(object)
              object
          })

.sql_save_driver <- function(x, path) {
    cl <- class(x)
    if (cl != "NULL") {
        cl <- paste0(attr(cl, "package"), "::", cl[1L])
    } else cl <- ""
    writeLines(cl, file.path(path, "ms_backend_drv.txt"))
}

.sql_load_driver <- function(path) {
    fl <- file.path(path, "ms_backend_drv.txt")
    if (!file.exists(fl))
        stop("No 'ms_backend_drv.txt' file found in the path")
    drv <- readLines(fl, n = 1)
    if (is.na(drv) || drv == "") {
        NULL
    } else {
        drv <- strsplit(drv, "::", fixed = TRUE)[[1L]]
        requireNamespace(drv[1L])
        new(drv[2L])
    }
}

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "MsBackendOfflineSql", function(x, path, ...) {
    altSaveObject(as(x, "MsBackendCached"), path, ...)
    info <- readObjectFile(path)
    info$ms_backend_offline_sql <- list(version = "1.0")
    saveObjectFile(path, "ms_backend_offline_sql", info)
    tryCatch({
        do.call(altSaveObject,
                list(x = x@dbname, path = file.path(path, "dbname")))
        do.call(altSaveObject,
                list(x = x@user, path = file.path(path, "user")))
        do.call(altSaveObject,
                list(x = x@host, path = file.path(path, "host")))
        do.call(altSaveObject,
                list(x = x@port, path = file.path(path, "port")))
    }, error = function(e) {
        stop("failed to save data base information of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    tryCatch({
        do.call(altSaveObject,
                list(x = x@spectraIds,
                     path = file.path(path, "spectra_ids")))
    }, error = function(e) {
        stop("failed to save 'spectraIds' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
    ## database driver; have to cheat.
    .sql_save_driver(x@driver, path)
})

validateAlabasterMsBackendOfflineSql <- function(path = character(),
                                                 metadata = list()) {
    .check_directory_content(path, c("dbname", "user", "host", "port",
                                     "spectra_ids","ms_backend_drv.txt"))
}

.is_ms_backend_sql_installed <- function() {
    requireNamespace("MsBackendSql", quietly = TRUE)
}

readAlabasterMsBackendOfflineSql <- function(path = character(),
                                             metadata = list(),
                                             password = character()) {
    if (!.is_ms_backend_sql_installed())
        stop("Required package 'MsBackendSql' missing. Please install ",
             "and try again.", call. = FALSE)
    validateAlabasterMsBackendOfflineSql(path, metadata)
    metadata$type <- "ms_backend_cached"
    parent <- altReadObject(path, metadata = metadata)
    dbname <- altReadObject(file.path(path, "dbname"))
    user <- altReadObject(file.path(path, "user"))
    host <- altReadObject(file.path(path, "host"))
    port <- altReadObject(file.path(path, "port"))
    sids <- altReadObject(file.path(path, "spectra_ids"))
    drv <- .sql_load_driver(file.path(path))
    object <- MsBackendSql::MsBackendOfflineSql()
    if (!is.null(drv))
        object <- Spectra::backendInitialize(
                               object, drv = drv, user = user, host = host,
                               password = password, dbname = dbname,
                               port = port)
    object@spectraIds <- sids
    object@localData <- parent@localData
    object@nspectra <- parent@nspectra
    object@spectraVariables <- parent@spectraVariables
    validObject(object)
    object
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "MsBackendOfflineSql",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "MsBackendOfflineSql",
                                    param = "AlabasterParam"),
          function(object, param, password = character()) {
              readAlabasterMsBackendOfflineSql(path = param@path,
                                               password = password)
          })
