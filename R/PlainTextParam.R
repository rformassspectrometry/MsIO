#' @title Store contents of MS objects as plain text files
#'
#' @name PlainTextParam
#'
#' @export
#'
#' @family MS object export and import formats.
#'
#' @description
#'
#' The `saveMsObject()` and `readMsObject()` methods with the `PlainTextParam`
#' option enable users to save/load different type of mass spectrometry (MS)
#' object as a collections of plain text files in/from a specified folder.
#' This folder, defined with the `path` parameter, will be created by the
#' `storeResults()` function. Writing data to a folder that contains already
#' exported data will result in an error.
#'
#' All data is exported to plain text files, where possible as tabulator
#' delimited text files. Data is exported using R's [write.table()] function,
#' thus, the text files will also contain row names (first column) as well as
#' column names (header). Strings in the text files are quoted. Some
#' information, in particular the content of *parameter* classes within the
#' objects, is stored in JSON format instead.
#'
#' The MS object currently supported for import and export with this parameter
#' are:
#'
#' - `MsBackendMzR` object, defined in the
#'   ([Spectra](https://bioconductor.org/packages/Spectra)) package.
#' - `Spectra` object, defined in the
#'   ([Spectra](https://bioconductor.org/packages/Spectra)) package.
#' - `MsExperiment` object, defined in the
#'   ([MsExperiment](https://bioconductor.org/packages/MsExperiment)) package.
#' - `XcmsExperiment` object, defined in the
#'   ([xcms](https://bioconductor.org/packages/xcms)) package.
#'
#' See their respective section below for details and formats of the
#' exported files.
#'
#' @param path For `PlainTextParam()`: `character(1)`, defining where the files
#'   are going to be stored/ should be loaded from. The default is
#'   `path = tempdir()`.
#'
#' @param spectraPath For `readMsObject()`: `character(1)` optionally allowing
#'   to define the (absolute) path where the spectra files (*data storage
#'   files*) can be found. This parameter is passed to the `loadResults()`
#'   method of the MsBackend().
#'
#' @param ... Additional parameters passed down to internal functions. E.g.
#'   parameter `spectraPath` (see above).
#'
#' @inheritParams saveMsObject
#'
#' @return For `PlainTextParam()`: a `PlainTextParam` class. `saveMsObject()`
#' does not return anything but saves the object to collections of different
#' plain text files to a folder. The `readMsObject()` method returns the
#' restored data as an instance of the class specified with parameter `object`.
#'
#'
#' @section On-disk storage for `MsBackendMzR` objects:
#'
#' For `MsBackendMzR` objects, defined in the `Spectra` package, the following
#' file is stored:
#'
#' - The backend's `spectraData()` is stored in a tabular format in a text file
#'   named *ms_backend_data.txt*. Each row of this tab-delimited text file
#'   corresponds to a spectrum with its respective metadata in the columns.
#'
#' @section On-disk storage for `Spectra` objects:
#'
#' For `Spectra` objects, defined in the `Spectra` package, the files listed
#' below are stored. Any parameter passed to the `saveMsObject()` method using
#' its `...` parameter are passed to the `saveMsObject()` call of the
#' `Spectra`'s backend.
#'
#' - The `processingQueueVariables`, `processing`, `processingChunkSize()`, and
#'   `backend` class information of the object are stored in a text file named
#'   *spectra_slots.txt*. Each of these slots is stored such that the name of
#'   the slot is written, followed by "=" and the content of the slot.
#'
#' - The processing queue of the `Spectra` object, ensuring that any spectra
#'   data modifications are retained, is stored in a `json` file named
#'   *spectra_processing_queue.json*. The file is written such that each
#'   processing step is separated by a line and includes all information about
#'   the parameters and functions used for the step.
#'
#' - The `Spectra`'s MS data (i.e. it's backend) is stored/exported using
#'   the `saveMsObject()` method of the respective backend type. Currently
#'   only backends for which the `saveMsObject()` method is implemented (see
#'   above) are supported.
#'
#'
#' @section On-disk storage for `MsExperiment` objects:
#'
#' For `MsExperiment` objects, defined in the `MsExperiment` package, the
#' exported data and related text files are listed below. Any parameter passed
#' to the `saveMsObject()` through `...` are passed to the `saveMsObject()`
#' calls of the individual MS data object(s) within the `MsExperiment`.
#'
#' Note that at present `saveMsObject()` with `PlainTextParam` does **not**
#' export the full content of the `MsExperiment`, i.e. slots `@experimentFiles`,
#' `@qdata`, `@otherData` and `@metadata` are currently not saved.
#'
#' - The `sampleData()` is stored as a text file named
#'   *ms_experiment_sample_data.txt*. Each row of this file corresponds to a
#'   sample with its respective metadata in the columns.
#'
#' - The links between the sample data and any other data within the
#'   `MsExperiment` are stored in text files named
#'   *ms_experiment_sample_data_links_....txt*,
#'   with "..." referring to the data slot to which samples are linked.
#'   Each file contains the mapping between the sample data and the elements in
#'   a specific data slot (e.g., `Spectra`). The files are tabulator delimited
#'   text files with two columns of integer values, the first representing the
#'   index of a sample in the objects `sampleData()`, the second the index of
#'   the assigned element in the respective object slot.
#'   The table "ms_experiment_element_metadata.txt" contains the metadata of
#'   each of the available mappings.
#'
#' - If the `MsExperiment` contains a `Spectra` object with MS data, it's
#'   content is exported to the same folder using a `saveMsObject()` call on
#'   it (see above for details of exporting `Spectra` objects to text files).
#'
#'
#'
#' @section On-disk storage for `XcmsExperiment` objects:
#'
#' For `XcmsExperiment` objects, defined in the *xcms* package, the exported
#' data and related text files are listed below. Any parameter passed
#' to the `saveMsObject()` through `...` are passed to the `saveMsObject()`
#' calls of the individual MS data object(s) within the `XcmsExperiment`.
#'
#' - The chromatographic peak information obtained with `chromPeaks()` and
#'   `chromPeaksData()` is stored in tabular format in the text files
#'   *xcms_experiment_chrom_peaks.txt* and
#'   *xcms_experiment_chrom_peak_data.txt*, respectively. The first file's
#'   rows represent single peaks with their respective metadata in the columns
#'   (only numeric information). The second file contains arbitrary additional
#'   information/metadata for each peak (each row being one chrom peak).
#'
#' - The `featureDefinitions()` are stored in a text file named
#'   *xcms_experiment_feature_definitions.txt*. Additionally, a second file
#'   named *ms_experiment_feature_peak_index.txt* is generated to connect the
#'   features with the corresponding chromatographic peaks. Each row of the
#'   first file corresponds to a feature with its respective metadata in the
#'   columns. The second file contains the mapping between features and
#'   chromatographic peaks (one peak ID per row).
#'
#' - The `processHistory()` information of the object is stored to a
#'   file named *xcms_experiment_process_history.json* in JSON format.
#'
#' - The `XcmsExperiment` directly extends the `MsExperiment` class, thus,
#'   any MS data is saved using a call to the `saveMsObject` of the
#'   `MsExperiment` (see above for more information).
#'
#'
#' @author Philippine Louail
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @examples
#'
#' ## Export and import a `Spectra` object:
#'
#' library(Spectra)
#' library(msdata)
#' fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")
#' sps <- Spectra(fl)
#'
#' ## Export the object to a temporary directory
#' d <- file.path(tempdir(), "spectra_example")
#' saveMsObject(sps, PlainTextParam(d))
#'
#' ## List the exported plain text files:
#' dir(d)
#'
#' ## - ms_backend_data.txt contains the metadata for the MS backend used (a
#' ##   'MsBackendMzR`.
#' ## - spectra_slots.txt contains general information from the Spectra object.
#'
#' ## Import the data again. By using `Spectra()` as first parameter we ensure
#' ## the result is returned as a `Spectra` object.
#' sps_in <- readMsObject(Spectra(), PlainTextParam(d))
#' sps_in
#'
#' ## Check that the data is the same
#' all.equal(rtime(sps), rtime(sps_in))
#' all.equal(intensity(sps), intensity(sps_in))
#'
#' ## The data got exported *by module*, thus we could also load only a part of
#' ## the exported data, such as just the `MsBackend` used by the `Spectra`:
#' be <- readMsObject(MsBackendMzR(), PlainTextParam(d))
#' be
#'
#' ## The export functionality also ensures that the data/object can be
#' ## completely restored, i.e., for `Spectra` objects also their
#' ## *processing queue* is preserved/stored. To show this we below first
#' ## filter the spectra object by retention time and m/z:
#'
#' sps_filt <- sps |>
#'     filterRt(c(400, 600)) |>
#'     filterMzRange(c(200, 300))
#' ## The filtered object has less spectra
#' length(sps_filt)
#' length(sps)
#' ## And also less mass peaks per spectrum
#' lengths(sps_filt[1:3])
#' lengths(sps[1:3])
#'
#' d <- file.path(tempdir(), "spectra_example2")
#' saveMsObject(sps_filt, PlainTextParam(d))
#'
#' ## The directory contains now an additional file with the processing
#' ## queue of the `Spectra`.
#' dir(d)
#'
#' ## Restoring the object again.
#' sps_in <- readMs
NULL

#' @noRd
setClass("PlainTextParam",
         slots = c(path = "character"),
         contains = "Param",
         prototype = prototype(
             path = character()),
         validity = function(object) {
             msg <- NULL
             if (length(object@path) != 1)
                 msg <- c("'path' has to be a character string of length 1")
             msg
         })

#' @rdname PlainTextParam
#'
#' @export
PlainTextParam <- function(path = tempdir()) {
    new("PlainTextParam", path = path)
}
