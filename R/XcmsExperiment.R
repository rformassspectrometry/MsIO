#'@title Methods to save and load contents of a XcmsExperiment object
#'
#' @author Philippine Louail
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

#' @rdname PlainTextParam
setMethod("saveMsObject",
          signature(object = "XcmsExperiment",
                    param = "PlainTextParam"),
          function(object, param) {
              callNextMethod()
              .store_xcmsexperiment(x = object, path = param@path)
          }
)

#' @rdname PlainTextParam
setMethod("readMsObject",
          signature(object = "XcmsExperiment",
                    param = "PlainTextParam"),
          function(object, param, spectraPath = character()) {
              res <- callNextMethod()
              res <- .load_xcmsexperiment(res, path = param@path)
              validObject(res)
              res
          })

#' @noRd
.store_xcmsexperiment <- function(x, path = tempdir()) {
    .export_process_history(x, path = path)
    if (xcms::hasChromPeaks(x))
        .export_chrom_peaks(x, path)
    if (xcms::hasFeatures(x))
        .export_features(x, path)
}


#' @noRd
.load_xcmsexperiment <- function(x, path = character(),
                                 spectraExport = logical()){
    x <- as(x, "XcmsExperiment")
    fl <- file.path(path, "chrom_peaks.txt")
    x <- .import_chrom_peaks(x, path)
    fl <- file.path(path, "process_history.json")
    if (file.exists(fl))
        x <- .import_process_history(x, fl)
    else stop("No \"process_history.json\" file found in ", path)
    fl <- file.path(path, "feature_definitions.txt")
    if (file.exists(fl))
        x <- .import_features(x, path)
    x
}

#' Processing history
#' @noRd
.export_process_history <- function(x, path = character()) {
    ph <- xcms::processHistory(x)
    write_json(serializeJSON(ph), file.path(path, "process_history.json"))
}

#' @noRd
.import_process_history <- function(x, file = character()) {
    ph <- unserializeJSON(read_json(file)[[1L]])
    x@processHistory <- ph
    x
}

#' Chromatographic peaks
#' @noRd
.export_chrom_peaks <- function(x, path = character()) {
    write.table(xcms::chromPeaks(x), file = file.path(path, "chrom_peaks.txt"),
                sep = "\t")
    write.table(as.data.frame(xcms::chromPeakData(x)), sep = "\t",
                file = file.path(path, "chrom_peak_data.txt"))
}

#' @noRd
.import_chrom_peaks <- function(x, path = character()) {
    f <- file.path(path, "chrom_peaks.txt")
    pk <- as.matrix(read.table(f, sep = "\t"))
    f <- file.path(path, "chrom_peak_data.txt")
    if (!file.exists(f))
        stop("No \"chrom_peak_data.txt\" file found in ", path)
    pkd <- read.table(f, sep = "\t")
    x@chromPeaks <- pk
    x@chromPeakData <- pkd
    x
}

#' Features
#' @noRd
.export_features <- function(x, path = character()) {
    fts <- xcms::featureDefinitions(x)
    pkidx <- data.frame(
        feature_index = rep(seq_len(nrow(fts)), lengths(fts$peakidx)),
        peak_index = unlist(fts$peakidx, use.names = FALSE))
    fts$peakidx <- NA
    write.table(fts, file = file.path(path, "feature_definitions.txt"),
                sep = "\t")
    write.table(pkidx, file = file.path(path, "feature_peak_index.txt"),
                sep = "\t")
}

#' @noRd
.import_features <- function(x, path = character()) {
    f <- file.path(path, "feature_definitions.txt")
    fts <- read.table(f, sep = "\t")
    f <- file.path(path, "feature_peak_index.txt")
    if (!file.exists(f))
        stop("No \"feature_peak_index.txt\" file found in ", path)
    pkidx <- read.table(f, sep = "\t")
    fts$peakidx <- unname(split(pkidx$peak_index, pkidx$feature_index))
    x@featureDefinitions <- fts
    x
}
