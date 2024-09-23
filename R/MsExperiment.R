#' @include PlainTextParam.R
#' @title Methods to save and load contents of a MsExperiment object
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
              sdata <- object@sampleData
              if (!length(sdata)) # initialize with empty data frame
                  sdata <- DataFrame(sample_name = character())
              write.table(as.data.frame(sdata), sep = "\t",
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
                      sdl@elementMetadata, sep = "\t", quote = TRUE,
                      file = file.path(param@path,
                                       "ms_experiment_link_mcols.txt"))
              }
              ## call export of individual other objects (not MsExperiment data)
              if (length(spectra(object)))
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
              sd <- read.table(fl, sep = "\t", header = TRUE)
              object@sampleData <- DataFrame(sd, row.names = NULL)

              ## read spectra
              if (file.exists(file.path(param@path, "spectra_slots.txt")))
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
                                   sep = "\t", header = TRUE)
                  mcols(object@sampleDataLinks) <- DataFrame(
                      em, row.names = NULL)
              }

              validObject(object)
              object
          })

################################################################################
##
## alabaster saveObject/readObject
##
################################################################################
#' @rdname AlabasterParam
setMethod("saveObject", "MsExperiment", function(x, path, ...) {
    ## Check requirements before saving
    if (inherits(x@qdata, "QFeatures"))
        stop("Saving of an 'MsExperiment' with an object of type 'QFeatures'",
             " in the qdata slot is currently not supported.", call. = FALSE)
    if (inherits(x@qdata, "SummarizedExperiment") &&
        !requireNamespace("alabaster.se", quietly = TRUE))
        stop("Required package 'alabaster.se' for export of ",
             "'SummarizedExperiment' objects missing. Please install and ",
             "try again.", call. = FALSE)
    if (length(x@sampleDataLinks) > 0 &&
        !requireNamespace("alabaster.matrix", quietly = TRUE))
        stop("Required package 'alabaster.matrix' missing. Please install and ",
             "try again.", call. = FALSE)
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    saveObjectFile(path, "ms_experiment",
                   list(spectra = list(version = "1.0")))
    if (length(x@spectra))
        tryCatch({
            do.call(altSaveObject,
                    list(x = x@spectra, path = file.path(path, "spectra")))
        }, error = function(e) {
            stop("failed to save '@spectra' of ", class(x)[1L], "\n - ",
                 e$message, call. = FALSE)
        })
    altSaveObject(x@sampleData, path = file.path(path, "sample_data"))
    altSaveObject(x@sampleDataLinks,path = file.path(path, "sample_data_links"))
    altSaveObject(x@sampleDataLinks@elementMetadata,
                  path = file.path(path, "sample_data_links_mcols"))
    altSaveObject(x@metadata, path = file.path(path, "metadata"))
    if (length(x@qdata))
        altSaveObject(x@qdata, path = file.path(path, "qdata"))
    altSaveObject(x@experimentFiles, path = file.path(path, "experiment_files"))
    ## - otherData: call saveObject and hope for the best.
    tryCatch({
        do.call(altSaveObject,
                list(x = x@otherData, path = file.path(path, "other_data")))
    }, error = function(e) {
        stop("failed to save '@otherData' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
})

validateAlabasterMsExperiment <- function(path = character(),
                                          metadata = list()) {
    .check_directory_content(path, c("sample_data", "sample_data_links",
                                     "sample_data_links_mcols", "metadata",
                                     "experiment_files", "other_data"))
}

#' @importFrom alabaster.base readObjectFile
readAlabasterMsExperiment <- function(path = character(), metadata = list(),
                                      ...) {
    if (!requireNamespace("MsExperiment", quietly = TRUE))
        stop("Required package 'MsExperiment' missing. Please install ",
             "and try again.", call. = FALSE)
    validateAlabasterMsExperiment(path, metadata)
    res <- MsExperiment::MsExperiment()
    if (file.exists(file.path(path, "spectra")))
        res@spectra <- altReadObject(file.path(path, "spectra"), ...)
    else res@spectra <- NULL
    i <- altReadObject(file.path(path, "sample_data"))
    res@sampleData <- i
    i <- as(lapply(altReadObject(file.path(path, "sample_data_links")),
                   as.matrix), "SimpleList")
    i@elementMetadata <- altReadObject(
        file.path(path, "sample_data_links_mcols"))
    res@sampleDataLinks <- i
    i <- altReadObject(file.path(path, "metadata"))
    res@metadata <- i
    if (file.exists(file.path(path, "qdata"))) {
        qdata_obj <- readObjectFile(file.path(path, "qdata"))
        if (qdata_obj$type[1L] == "summarized_experiment") {
            if (!requireNamespace("alabaster.se", quietly = TRUE))
                stop("Required package 'alabaster.se' not available. Please ",
                     "install and try again.", call. = FALSE)
            i <- altReadObject(file.path(path, "qdata"))
        } else stop("Data of type \"", qdata_obj$type, "\" can currently not ",
                    "be imported.")
        res@qdata <- i
    } else res@qdata <- NULL
    i <- altReadObject(file.path(path, "experiment_files"))
    res@experimentFiles <- i
    i <- as(altReadObject(file.path(path, "other_data")), "SimpleList")
    res@otherData <- i
    validObject(res)
    res
}

#' @rdname AlabasterParam
setMethod("saveMsObject", signature(object = "MsExperiment",
                                    param = "AlabasterParam"),
          function(object, param) {
              if (file.exists(param@path))
                  stop("Overwriting or saving to an existing directory is not",
                       " supported. Please remove the directory defined with",
                       " parameter `path` first.")
              saveObject(object, param@path)
          })

#' @rdname AlabasterParam
setMethod("readMsObject", signature(object = "MsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterMsExperiment(path = param@path, ...)
          })


################################################################################
##
## MetaboLights readMsObject
##
################################################################################
#' @rdname MetaboLightsParam
#' @importFrom utils menu
setMethod("readMsObject",
          signature(object = "MsExperiment",
                    param = "MetaboLightsParam"),
          function(object, param, keepOntology = TRUE, keepProtocol = TRUE,
                   simplify = TRUE, ...) {
              if (!requireNamespace("MsBackendMetaboLights", quietly = TRUE)) {
                  stop("Required package 'MsBackendMetaboLights' is missing. ",
                       "Please install it and try again.", call. = FALSE)
              }
              pth <- MsBackendMetaboLights::mtbls_ftp_path(param@mtblsId)
              all_fls <- MsBackendMetaboLights::mtbls_list_files(param@mtblsId)

              ## Extract and read assay files
              assays <- all_fls[grepl("^a_", all_fls)]
              if (length(param@assayName) > 0)
                  selected_assay <- param@assayName
              else {
                  if (length(assays) == 1) {
                      selected_assay <- assays
                      message("Only one assay file found:", selected_assay, "\n")
                  } else {
                      message("Multiple assay files found:\n")
                      selection <- menu(assays,
                                        title = paste("Please choose the assay",
                                                      "file you want to use:"))
                      selected_assay <- assays[selection]
                  }
              }

              assay_data <- read.table(paste0(pth, selected_assay),
                                       header = TRUE, sep = "\t",
                                       check.names = FALSE)

              ## Extract and read sample info files
              s_files <- all_fls[grepl("^s_", all_fls)]
              sample_info <- read.table(paste0(pth, s_files),
                                        header = TRUE, sep = "\t",
                                        check.names = FALSE)

              # merging
              ord <- match(assay_data$`Sample Name`, sample_info$`Sample Name`)
              merged_data <- cbind(assay_data, sample_info[ord, ])
              if (keepProtocol || keepOntology || simplify)
                  merged_data <- .clean_merged(x = merged_data,
                                               keepProtocol = keepProtocol,
                                               keepOntology = keepOntology,
                                               simplify = simplify)

              ## Assemble object
              object@spectra <- Spectra::Spectra(mtblsId = param@mtblsId,
                                                 source = MsBackendMetaboLights::MsBackendMetaboLights(),
                                                 assayName = selected_assay,
                                                 filePattern = param@filePattern)

              ## sample to spectra link
              fl <- object@spectra@backend@spectraData[1, "derived_spectral_data_file"]
              nme <- colnames(merged_data)[which(merged_data[1, ] == fl)]
              merged_data <- merged_data[grepl(param@filePattern,
                                               merged_data[, nme]), ]
              nme <- gsub(" ", "_", nme) #use concatenate instead ?
              object@sampleData <- DataFrame(merged_data, check.names = FALSE)
              object <- MsExperiment::linkSampleData(object,
                                                     with = paste0("sampleData.",
                                                                nme,
                                                                "= spectra.derived_spectral_data_file"))
              validObject(object)
              object
          })


#####HELPERS

#' Function that takes the extra parameters and clean the metadata if asked by
#' the user.
#'
#' @noRd
.clean_merged <- function(x, keepProtocol, keepOntology, simplify) {
    # remove ontology
    if (!keepOntology)
        x <- x[, -which(grepl("Term", names(x))), drop = FALSE]

    # remove protocol
    if (!keepProtocol)
        x <- x[, -which(grepl("Protocol|Parameter", names(x))),  drop = FALSE]

    # remove duplicated columns contents and NAs
    if (simplify) {
        x <- x[, !duplicated(as.list(x)), drop = FALSE]
        x <- x[, colSums(is.na(x)) != nrow(x), drop = FALSE]
    }
    return(x)
}

