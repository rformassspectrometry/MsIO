#' @include PlainTextParam.R
#' @title Methods to save and load contents of a XcmsExperiment object
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
          function(object, param, ...) {
              res <- callNextMethod()
              res <- .load_xcmsexperiment(res, path = param@path)
              validObject(res)
              res
          })

#' @noRd
.store_xcmsexperiment <- function(x, path = tempdir()) {
    .export_process_history(x, path = path)
    ## if (xcms::hasChromPeaks(x)) # maybe also export chromPeaks.
    .export_chrom_peaks(x, path)
    if (xcms::hasFeatures(x))
        .export_features(x, path)
}

#' @noRd
.load_xcmsexperiment <- function(x, path = character(),
                                 spectraExport = logical()) {
    x <- as(x, "XcmsExperiment")
    x <- .import_chrom_peaks(x, path)
    x <- .import_process_history(x, path)
    fl <- file.path(path, "xcms_experiment_feature_definitions.txt")
    if (file.exists(fl))
        x <- .import_features(x, path)
    x
}

#' Processing history
#' @noRd
.export_process_history <- function(x, path = character()) {
    ph <- xcms::processHistory(x)
    write_json(serializeJSON(ph),
               file.path(path, "xcms_experiment_process_history.json"))
}

#' @noRd
.import_process_history <- function(x, path = character()) {
    fl <- file.path(path, "xcms_experiment_process_history.json")
    if (!file.exists(fl))
        stop("No \"xcms_experiment_process_history.json\" file found in ", path)
    ph <- unserializeJSON(read_json(fl)[[1L]])
    x@processHistory <- ph
    x
}

#' Chromatographic peaks
#' @noRd
.export_chrom_peaks <- function(x, path = character()) {
    write.table(xcms::chromPeaks(x),
                file = file.path(path, "xcms_experiment_chrom_peaks.txt"),
                sep = "\t")
    write.table(as.data.frame(xcms::chromPeakData(x)), sep = "\t",
                file = file.path(path, "xcms_experiment_chrom_peak_data.txt"))
}

#' @noRd
.import_chrom_peaks <- function(x, path = character()) {
    f <- file.path(path, "xcms_experiment_chrom_peaks.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_chrom_peaks.txt\" file found in ", path)
    pk <- as.matrix(read.table(f, sep = "\t", header = TRUE))
    f <- file.path(path, "xcms_experiment_chrom_peak_data.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_chrom_peak_data.txt\" file found in ", path)
    pkd <- read.table(f, sep = "\t", header = TRUE)
    x@chromPeaks <- pk
    x@chromPeakData <- pkd
    x
}

#' Features
#' @noRd
.export_features <- function(x, path = character()) {
    fts <- x@featureDefinitions
    pkidx <- data.frame(
        feature_index = rep(seq_len(nrow(fts)), lengths(fts$peakidx)),
        peak_index = unlist(fts$peakidx, use.names = FALSE))
    fts$peakidx <- NA
    write.table(
        fts, file = file.path(path, "xcms_experiment_feature_definitions.txt"),
        sep = "\t")
    write.table(
        pkidx, file = file.path(path, "xcms_experiment_feature_peak_index.txt"),
        sep = "\t")
}

#' @noRd
.import_features <- function(x, path = character()) {
    f <- file.path(path, "xcms_experiment_feature_definitions.txt")
    fts <- read.table(f, sep = "\t", header = TRUE)
    f <- file.path(path, "xcms_experiment_feature_peak_index.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_feature_peak_index.txt\" file found in ",
             path)
    pkidx <- read.table(f, sep = "\t", header = TRUE)
    fts$peakidx <- unname(split(pkidx$peak_index, pkidx$feature_index))
    x@featureDefinitions <- fts
    x
}

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "XcmsExperiment", function(x, path, ...) {
    if(!requireNamespace("alabaster.matrix", quietly = TRUE))
        stop("Required package 'alabaster.matrix' missing. Please install and ",
             "try again.", call. = FALSE)
    ## Save the MsExperiment part
    altSaveObject(as(x, "MsExperiment"), path, ...)
    altSaveObject(x@chromPeaks, file.path(path, "chrom_peaks"))
    ## It's a bit odd, but we can only export DataFrame, but not data.frame
    altSaveObject(as(x@chromPeakData, "DataFrame"),
                  file.path(path, "chrom_peak_data"))
    altSaveObject(as(x@featureDefinitions, "DataFrame"),
                  file.path(path, "feature_definitions"))
    .export_process_history(x, path)
    info <- readObjectFile(path)
    info$xcms_experiment <- list(version = "1.0")
    saveObjectFile(path, "xcms_experiment", info)
})

validateAlabasterXcmsExperiment <- function(path = character(),
                                            metadata = list()) {
    validateAlabasterMsExperiment(path)
    .check_directory_content(
        path, c("chrom_peaks", "chrom_peak_data", "feature_definitions",
                "xcms_experiment_process_history.json"))
}

readAlabasterXcmsExperiment <- function(path = character(), metadata = list(),
                                      ...) {
    if (!requireNamespace("xcms", quietly = TRUE))
        stop("Required package 'xcms' missing. Please install ",
             "and try again.", call. = FALSE)
    if (!requireNamespace("MsExperiment", quietly = TRUE))
        stop("Required package 'MsExperiment' missing. Please install ",
             "and try again.", call. = FALSE)
    validateAlabasterXcmsExperiment(path, metadata)

    metadata$type <- "ms_experiment"
    res <- altReadObject(path, metadata = metadata, ...)
    res <- as(res, "XcmsExperiment")
    res <- .import_process_history(res, path)
    x <- altReadObject(file.path(path, "chrom_peaks"))
    res@chromPeaks <- as.matrix(x)
    x <- altReadObject(file.path(path, "chrom_peak_data"))
    res@chromPeakData <- as(x, "data.frame")
    x <- altReadObject(file.path(path, "feature_definitions"))
    res@featureDefinitions <- as(x, "data.frame")
    validObject(res)
    res
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "XcmsExperiment",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "XcmsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterXcmsExperiment(path = param@path, ...)
          })

################################################################################
##
## MzTabParam
##
################################################################################
#' @rdname MzTabParam
setMethod("saveMsObject",
          signature(object = "XcmsExperiment",
                    param = "MzTabParam"),
          function(object, param){
              if(!param@sampleDataColumn %in% colnames(object@sampleData))
                  stop("'sampleDataColumn' has to correspond to column names",
                       "of the sampleData() table")
              if(length(param@optionalFeatureColumns) != 0)
                  if(!param@optionalFeatureColumns %in% colnames(object@featureDefinitions))
                      stop("'optionalFeatureColumns' have to correspond to",
                           "column names of the featureDefinitions() table")

              var_list <- unique(.mztab_study_variables(object@sampleData,
                                                        param@sampleDataColumn))
              fl <- file.path(param@path, paste0(param@studyId, ".mztab"))
              if (file.exists(fl))
                  stop("File ", basename(fl), " already exists. ")
              con <- file(fl, open = "at")
              on.exit(close(con))

              mtd <- .mztab_metadata(object, study_id = param@studyId,
                                     polarity = param@polarity,
                                     col_phenotype = param@sampleDataColumn)
              .mztab_export(mtd, con)
              writeLines("", con)

              sml <- .mztab_small_molecule_summary(n_sample = length(object),
                                                   var_list = var_list)
              .mztab_export(sml, con)
              writeLines("", con)

              smf <- do.call(.mztab_small_molecule_feature,
                             c(list(object = object,
                                    opt_columns = param@optionalFeatureColumns),
                               param@dots))
              .mztab_export(smf, con)
          })


### Helper functions

#' @description
#'
#' Create the metadata `matrix` (MTD). Use the .MTD static object as a basis.
#'
#' @noRd
.mztab_metadata <- function(object, study_id, polarity, col_phenotype) {
    n_sample <- length(object)
    seq_sample <- seq_len(n_sample)
    base <- .MTD
    base[base == "replace_id"]  <- study_id
    msrun <- cbind(
        name = paste0("ms_run[", seq_sample, "]-location"),
        value = paste0("file:///", xcms::fileNames(object)),
        order = .prefix_zero(seq_sample)
    )
    if (polarity == "positive") {
        pol <- cbind(
            name = paste0("ms_run[", seq_sample, "]-scan_polarity[1]"),
            value = "[MS, MS:1000130, positive scan, ]",
            order = .prefix_zero(seq_sample))
    } else {
        pol <- cbind(
            name = paste0("ms_run[", seq_sample, "]-scan_polarity[1]"),
            value = "[MS, MS:1000129, negative scan, ]",
            order = .prefix_zero(seq_sample))
    }
    msrun <- rbind(msrun, pol)
    msrun <- msrun[order(msrun[, "order"]), c("name", "value")]

    assay <- cbind(
        name = paste0("assay[", seq_sample, "]"),
        value = paste(seq_sample, "assay"),
        order = .prefix_zero(seq_sample)
    )
    assay_ref <- cbind(
        name = paste0("assay[", seq_sample, "]-ms_run_ref"),
        value = paste0("ms_run[", seq_sample, "]"),
        order = .prefix_zero(seq_sample)
    )
    assay <- rbind(assay, assay_ref)
    assay <- assay[order(assay[, "order"]), c("name", "value")]

    var <- .mztab_study_variable_entries(object@sampleData, col_phenotype)

    mtd <- rbind(
        base[1:4, ],
        msrun,
        assay,
        var,
        base[5:nrow(base), ]
    )
    mtd <- cbind(id = "MTD", mtd)

    gsub("\\\\", "/", mtd)
}

#' @description
#'
#' Create the *empty* small molecule summary (SML) `matrix`.
#' Use the .SML static object as a basis
#'
#' @noRd
#'
#' @examples
#'
#' .mztab_small_molecule_summary(5, c(1, 2, 3))
.mztab_small_molecule_summary <- function(n_sample, var_list) {
    sml <- c(.SML, paste0("abundance_assay[", seq_len(n_sample) ,"]"),
             paste0("abundance_study_variable[",
                    seq_len(length(var_list)) ,"]"),
             paste0("abundance_variation_study_variable[",
                    seq_len(length(var_list)) ,"]"))
    sml <- rbind(sml, c("SML", "1", rep("null", length(sml) - 2L)))
    sml[2,12] <- 4 ##this is a bit random but  reliability is a necessary thing
    ##for now, remove when can.
    sml
}

#' @description
#'
#' Create the small molecule feature (SMF) `matrix` One row is one feature
#' defined in xcms. Use the .SMF static object.
#' object as a basis.
#'read
#' @noRd
#'
#' @param object `XcmsExperiment`.
#'
#' @param opt_columns `character` defining optional columns in
#'     `featureDefinitions` that should be exported too.
#'
#' @param ... optional parameters for the `featureValues` call.
.mztab_small_molecule_feature <- function(object, opt_columns = character(),
                                          ...) {
    fts <- object@featureDefinitions
    smf <- matrix(data = "null", ncol = length(.SMF), nrow = nrow(fts),
                  dimnames = list(character(), .SMF))
    smf[, "SFH"] <- "SMF"
    smf[, "SMF_ID"] <- seq_len(nrow(fts))
    smf[, "exp_mass_to_charge"] <- as.character(fts$mzmed, digits = 18)
    smf[, "retention_time_in_seconds"] <- as.character(fts$rtmed, digits = 15)
    smf[, "retention_time_in_seconds_start"] <- as.character(fts$rtmin,
                                                             digits = 15)
    smf[, "retention_time_in_seconds_end"] <- as.character(fts$rtmax,
                                                           digits = 15)

    fvals <- xcms::featureValues(object, ...)
    colnames(fvals) <- paste0("abundance_assay[", seq_len(ncol(fvals)), "]")
    fvals <- apply(fvals, 2L, as.character, digits = 15)
    fvals[is.na(fvals)] <- "null"

    smf <- cbind(smf, fvals)

    if (length(opt_columns)) {
        tmp <- do.call(
            cbind, lapply(opt_columns,
                          function(z) {
                              if (z == "peakidx") {
                                  vapply(fts[, z], paste0, character(1),
                                         collapse = "| ")
                              } else as.character(fts[, z], digits = 15)
                          }))
        colnames(tmp) <- paste0("opt_", opt_columns)
        smf <- cbind(smf, tmp)
    }
    smf <- rbind(colnames(smf), smf)
    unname(smf)
}

#' @description
#'
#' Define the `character` vector with all study variables.
#'
#' @param x `data.frame` with sample annotations
#'
#' @param variable `character` with the column name(s) containing the study
#'     variables.
#'
#' @return `character` with the study variables, being a concatenation of
#'     the column name `"|"` and the value of the variable.
#'
#' @noRd
#'
#' @examples
#'
#' x <- data.frame(sex = c("male", "female", "female", "male", "male"),
#'                 group = c("case", "case", "control", "case", "control"))
#'
#' .mztab_study_variables(x, variable = c("sex", "group"))
#'
#' .mztab_study_variables(x, "sex")
.mztab_study_variables <- function(x = data.frame(), variable = character(),
                                   sep = ":") {
    do.call(cbind, lapply(variable, function(z) paste0(z, sep, x[, z])))
}

#' @description
#'
#' Create a `matrix` with the *study_variable* metadata content based.
#'
#' @param x `data.frame` representing the `sampleData` of the `MsExperiment`.
#'
#' @param variable `character` defining the columns in `x` containing the
#'     sample variables.
#'
#' @return `character` `matrix` (two columns) with the result.
#'
#' @noRd
#'
#' @examples
#'
#' .mztab_study_variable_entries(x, "sex")
#'
#' .mztab_study_variable_entries(x, c("group", "sex"))
.mztab_study_variable_entries <- function(x, variable, sep = "| ") {
    svar <- .mztab_study_variables(x, variable)
    unique_svar <- unique(as.vector(svar))
    res <- matrix(character(), ncol = 2, nrow = 0,
                  dimnames = list(character(), c("name", "value")))
    for (i in seq_along(unique_svar)) {
        idx <- which(svar == unique_svar[i], arr.ind = TRUE)
        res <- rbind(
            res,
            matrix(ncol = 2,
                   c(paste0("study_variable[", i, "]"),
                     paste0("study_variable[", i, "]-description"),
                     paste0("study_variable[", i, "]-assay_refs"),
                     paste0(unique_svar[i]),
                     paste0("Sample in column ", unique_svar[i]),
                     paste0("assay[", idx[, "row"], "]", collapse = sep)
                   )))
    }
    res
}

#' @noRd
.prefix_zero <- function(x) {
    sprintf(paste0("%0", ceiling(log10(max(x) + 1)), "d"), x)
}

#' @noRd
.mztab_export <- function(x, con) {
    x <- apply(x, 1L, paste0, collapse = "\t")
    writeLines(x, con)
}

### Static objects

.MTD <- cbind(
    name = c("mzTab-version",
             "mzTab-ID",
             "software[1]",
             "quantification_method",
             "cv[1]-label",
             "cv[1]-full_name",
             "cv[1]-version",
             "cv[1]-uri",
             "cv[2]-label",
             "cv[2]-full_name",
             "cv[2]-version",
             "cv[2]-uri",
             "database[1]",
             "database[1]-prefix",
             "database[1]-version",
             "database[1]-uri",
             "small_molecule-quantification_unit",
             "small_molecule_feature-quantification_unit",
             "small_molecule-identification_reliability"),
    value = c("2.0.0-M",
              "replace_id",
              "[MS, MS:1001582, XCMS, 3.1.1]",
              "[MS, MS:1001834, LC-MS label-free quantitation analysis, ]",
              "MS",
              "PSI-MS controlled vocabulary",
              "4.1.138",
              "https://raw.githubusercontent.com/HUPO-PSI/psi-ms-CV/master/psi-ms.obo",
              "PRIDE",
              "PRIDE PRoteomics IDEntifications (PRIDE) database controlled vocabulary",
              "16:10:2023 11:38",
              "https://www.ebi.ac.uk/ols/ontologies/pride",
              "[,, \"no database\", null ]",
              "null",
              "Unknown",
              "null",
              "[PRIDE, PRIDE:0000330, Arbitrary quantification unit, ]",
              "[PRIDE, PRIDE:0000330, Arbitrary quantification unit, ]",
              "[MS, MS:1002896, compound identification confidence level, ]"))

.SML <- c("SMH", "SML_ID","SMF_ID_REFS", "database_identifier",
          "chemical_formula", "smiles", "inchi", "chemical_name",
          "uri", "theoretical_neutral_mass", "adduct_ions", "reliability",
          "best_id_confidence_measure", "best_id_confidence_value")

.SMF <- c("SFH", "SMF_ID","SME_ID_REFS", "SME_ID_REF_ambiguity_code",
          "adduct_ion", "isotopomer", "exp_mass_to_charge", "charge",
          "retention_time_in_seconds", "retention_time_in_seconds_start",
          "retention_time_in_seconds_end")
