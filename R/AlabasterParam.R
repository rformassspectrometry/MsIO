#' @include PlainTextParam.R
#'
#' @title Store MS data objects using the alabaster framework
#'
#' @aliases readObject
#'
#' @aliases saveObject,MsExperimentFiles-method
#'
#' @name AlabasterParam
#'
#' @family MS object export and import formats.
#'
#' @description
#'
#' The [*alabaster* framework](https://github.com/ArtifactDB/alabaster.base)
#' provides the methodology to save R objects to on-disk representations/
#' storage modes which are programming language independent (in contrast to
#' e.g. R's RDS files). By using standard file formats such as JSON and HDF5,
#' alabaster ensures that the data can also be read and imported by other
#' programming languages such as Python or Javascript. This improves
#' interoperability between application ecosystems.
#'
#' The *alabaster* package defines the [saveObject()] and [readObject()]
#' methods. Implementations of these methods are available for the following
#' classes hence allowing to use `saveObject()` and `readObject()` directly on
#' these objects:
#'
#' - `MsBackendMzR`, defined in the
#'   [*Spectra*](https://bioconductor.org/packages/Spectra) package.
#' - `MsBackendMetaboLights`, defined in the
#'   [*MsBackendMetaboLights*](https://github.com/RforMassSpectrometry/MsBackendMetaboLights)
#'   package.
#' - `Spectra`, defined in the
#'   [*Spectra*](https://bioconductor.org/packages/Spectra) package.
#' - `MsExperiment`, defined in the
#'   [*MsExperiment*](https://bioconductor.org/packages/MsExperiment) package.
#' - `XcmsExperiment`, defined in the
#'   [*xcms*](https://bioconductor.org/packages/xcms) package.
#'
#' In addition, the *MsIO* package defines the `AlabasterParam` which can be
#' used to write or read MS objects using the `saveMsObject()` and
#' `readMsObject()` methods. This allows additional configurations and
#' customizations to the export or import process. It is thus for example
#' possible to specify the path to the original MS data files for *on-disk* MS
#' representations such as the `MsBackendMzR` which enables to import a stored
#' object even if either the object or the original MS data files have been
#' moved to a different directory or file system.
#'
#' Importantly, it is only possible to save **one object in one directory**. To
#' overwrite an existing stored object in a folder, that folder has to be
#' deleted beforehand.
#'
#' Details and properties for the *alabaster*-based storage modes for the
#' various supported MS data objects are listed in the following sections.
#'
#' @param path `character(1)` with the name of the directory where the MS data
#'     object should be saved to or from which it should be restored.
#'     Importantly, path should point to a **new** folder, i.e. a directory
#'     that **does not already exist**.
#'
#' @param x MS data object to export. Can be one of the supported classes
#'     listed below.
#'
#' @param spectraPath For `readMsObject()`: `character(1)` optionally allowing
#'     to define the (absolute) path where the spectra files (*data storage
#'     files*) can be found. This parameter is used for `MsBackendMzR` (see
#'     descriptions below) and can be passed through `...` also to
#'     `readMsObject()` functions for other classes (such as `Spectra`,
#'     `MsExperiment` etc).
#'
#' @param offline For `readMsObject()` and `readObject()` to load MS data as a
#'     `MsBackendMetaboLights()`: `logical(1)` to evaluate the local file cache
#'     and only load local files. Thus `offline = TRUE` does not need an active
#'     internet connection, but fails if one of more files are not cached
#'     locally.
#'
#' @param ... optional additional parameters passed to the downstream
#'     functions, such as for example `spectraPath` described above.
#'
#' @inheritParams saveMsObject
#'
#' @return For `AlabasterParam()`: an instance of `AlabasterParam` class. For
#'     `readObject()` the exported object in the specified path (depending on
#'     the type of object defined in the *OBJECT* file in the path. For
#'     `readMsObject()` the exported data object, defined with the function's
#'     first parameter, from the specified path. `saveObject()` and
#'     `saveMsObject()` don't return anything.
#'
#'
#' @section On-disk storage for `MsBackendMzR` objects:
#'
#' `MsBackendMzR` objects can be exported or imported using the
#' `saveMsObject()` or `readMsObject()` functions to and from *alabaster*-based
#' storage modes using the `AlabasterParam` parameter object. Alternatively
#' *alabaster*'s `saveObject()` and `readObject()` can be used. The parameter
#' `spectraPath` allows to define an alternative path to the original
#' data files (in case these were moved). This parameter can be passed as
#' additional parameter to both the `readObject()` as well as the
#' `readMsObject()` methods.
#'
#' The format of the folder contents follows the *alabaster* format: a file
#' *OBJECT* (in JSON format) defines the type of object that was stored in the
#' directory while the object's data, for `MsBackendMzR`, is stored in
#' sub-folders *peaks_variables* (a `character` with the names of the peaks
#' variables of the object) and *spectra_data* (the metadata for all spectra).
#' Each sub-folder contains also an *OBJECT* file defining the object's type
#' and an additional file (in HDF5 format) containing the data. See examples
#' below for details.
#'
#'
#' @section On-disk storage for `MsBackendMetaboLights` objects:
#'
#' The `MsBackendMetaboLights` extends the `MsBackendMzR` backend and hence the
#' same files are stored. When a `MsBackendMetaboLights` object is restored,
#' the `mtbls_sync()` function is called to check for presence of all MS data
#' files and, if missing, re-download them from the *MetaboLights* repository
#' (if parameter `offline = FALSE` is used).
#'
#'
#' @section On-disk storage for `Spectra` objects:
#'
#' `Spectra` objects can be exported/imported using `saveMsObject()` and
#' `readMsObject()` with an `AlabasterParam`, or using the `saveObject()`
#' and `readObject()` functions. Both read functions allow to pass additional
#' parameters (such as `spectraPath`) to the import function for the
#' `Spectra`'s backend.
#'
#' The content of the folder with the stored `Spectra` data contains the
#' *OBJECT* file defining the type of the object stored in that directory and
#' the *spectra_processing_queue.json* file that contains the *processing queue*
#' of the `Spectra` objects. All other slots of the object are saved in
#' *alabaster* format into their respective sub-directories: *backend* for the
#' `MsBackend` (see also `MsBackendMzR` above), *metadata* for the metadata
#' slot, *processing* for the processing log, *processing_chunk_size* with
#' the size for chunk-wise processing and *processing_queue_variables* for
#' spectra/peaks variables that are needed for the processing queue.
#'
#'
#' @section On-disk storage for `MsExperiment` objects:
#'
#' `MsExperiment` is a container for various (different) MS data objects
#' related to the same *experiment*. It is a very flexible object that can, but
#' does not must contain actual MS data in form of e.g. a `Spectra` object.
#' For the alabaster-based disk storage of an `MsExperiment`, each of the
#' object's slots gets exported separately into its own subfolder within the
#' object's directory (defined with parameter `path`). For the export of the
#' individual slots, the respective `saveObject()` method is used. Similar to
#' all other objects listed here, `MsExperiment` can be stored using either
#' `saveObject()` or `saveMsObject` (with `AlabasterParam`) and *restored*
#' using `readObject()` or `readMsObject()` (with `MsExperiment()` passed as
#' the first parameter and `AlabasterParam` as second). The read functions
#' support passing additional parameters to the import function(s) for object's
#' MS data object(s), such as the `spectraPath` parameter described above
#' through `...`.
#'
#' The content of the folder with the stored `MsExperiment` data contains a
#' file `OBJECT` (in JSON format, with the type of class defined as
#' `"ms_experiment"`) and subfolders for the various slots, each saved to disk
#' using the data type-specific `saveObject()` function:
#'
#' - `@sampleData`: `DataFrame` stored into a folder named *sample_data*.
#' - `@sampleDataLinks`: the `List` is stored into a folder named
#'   *sample_data_links*, its *metadata columns* `DataFrame` (i.e. `mcols()`
#'   of the `List`) into a folder named *sample_data_links_mcols*.
#' - `@spectra`: if not `NULL, a `Spectra` object stored into a folder with
#'   the name *spectra* (using `saveObject()` of `Spectra` objects described
#'   above). This requires the *alabaster.se* package to be installed.
#'   If the value of the `@spectra` slot is `NULL` no directory *spectra* is
#'   created.
#' - `@experimentFiles`: `MsExperimentFiles` object saved using `saveObject()`
#'   into a folder named *experiment_files*. `MsExperimentFiles` are saved as
#'   a named list of `character` strings.
#' - `@qdata`: if not `NULL`, the object in this slot (either a `QFeatures` or
#'   `SummarizedExperiment`) is stored into a folder with the name *qdata*
#'   using the `saveObject()` method of the respective object. If the value for
#'   the `@qdata` slot is `NULL` the folder *qdata* is not created. At present,
#'   export of `QFeatures` objects is not supported!
#' - `@otherData`: `List` data is saved into a folder named *other_data*.
#' - `@metadata`: `List` data is saved into a filder named *metadata*.
#'
#' Note that the data type of the `assays` of imported (previously stored)
#' `SummarizedExperiment` objects are of type `ReloadedMatrix`.
#'
#'
#' @section On-disk storage for `XcmsExperiment` objects:
#'
#' `XcmsExperiment` objects extend the `MsExperiment` object and contain in
#' addition the results of a preprocessing of the MS data using the *xcms*
#' package. These objects can be exported/imported in the formats used for
#' *alabaster*-based storage using the `saveObject()` and `readObject()`
#' functions as well as using `saveMsObject()` and `readMsObject()` with
#' an `AlabasterParam` parameter object. As with all other methods, additional
#' parameters can be passed with the `...` parameter (such as the
#' `spectraData` parameter for import of a `MsBackendMzR` discussed above).
#' The storage directory contains all files and folders created by the export
#' of the `MsExperiment` (see above) and in addition the specific results
#' of *xcms* from the respective slots of the object:
#'
#' - `@chromPeaks`: this numeric matrix is stored in a folder names
#'   *chrom_peaks*.
#' - `@chromPeakData`: this `data.frame` is first converted to a `DataFrame`
#'   and then stored to a folder *chrom_peak_data* (in the *alabaster* format
#'   for `DataFrame`).
#' - `@featureDefinitions`: this `data.frame` is first converted to a
#'   `DataFrame` and then stored to a folder *feature_definitions* (also in
#'   *alabaster* format for `DataFrame`).
#' - `@processHistory`: the list of `ProcessHistory` objects is stored in JSON
#'   format to a file *xcms_experiment_process_history.json*.
#'
#'
#' @author Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ########
#' ## Export and import a `MsBackendMzR` object:
#' ####
#'
#' library(Spectra)
#' library(msdata)
#' fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")
#' be <- backendInitialize(MsBackendMzR(), fl)
#' be
#'
#' ## Export the object to a temporary directory using the alabaster framework;
#' ## the equivalent command using the parameter object would be
#' ## `saveMsObject(be, AlabasterParam(d))`.
#' d <- file.path(tempdir(), "ms_backend_mzr_example")
#' saveObject(be, d)
#'
#' ## List the content of the folder
#' dir(d, recursive = TRUE)
#'
#' ## The data can be imported again using alabaster's readObject() function
#' be_in <- readObject(d)
#' be_in
#'
#' ## Alternatively, the data could be restored also using
#' be_in <- readMsObject(MsBackendMzR(), AlabasterParam(d))
#'
#' all.equal(mz(be), mz(be_in))
#'
#'
#' ########
#' ## Export and import of `Spectra` objects:
#' ####
#'
#' ## Create a `Spectra` object with a `MsBackendMzR` backend.
#' s <- Spectra(fl)
#'
#' ## Define the folder to which to export and export the object
#' d <- file.path(tempdir(), "spectra_example")
#' saveMsObject(s, AlabasterParam(d))
#'
#' ## List the content of the directory
#' dir(d, recursive = TRUE)
#'
#' ## Restore the `Spectra` object again
#' s_in <- readMsObject(Spectra(), AlabasterParam(d))
#' s_in
#'
#' ## Alternatively, it would also be possible to just import the
#' ## `MsBackendMzR` of the `Spectra`:
#' be_in <- readMsObject(MsBackendMzR(), AlabasterParam(file.path(d, "backend")))
#' be_in
#'
#'
#' ########
#' ## Export and import of `MsExperiment` objects:
#' ####
#'
#' library(MsExperiment)
#'
#' ## Create a new `MsExperiment` with sample data and our previously defined
#' ## `Spectra` as its MS data
#' m <- MsExperiment(
#'     sampleData = data.frame(name = c("a", "b"), index = 1:2),
#'     spectra = s)
#' m
#'
#' d <- file.path(tempdir(), "ms_experiment_example")
#' saveObject(m, d)
#'
#' ## List directory content
#' dir(d)
#'
#' ## Restore the stored object
#' m_in <- readObject(d)
#'
#' m_in
#'
#'
#' ########
#' ## Export and import of `XcmsExperiment` objects:
#' ####
#'
#' ## `XcmsExperiment` objects extend `MsExperiment` to represent all
#' ## data of an MS experiment and contain in addition the results
#' ## of the preprocessing of the data with the *xcms* package. Below
#' ## we load the *xcms* package and load an example result object from that
#' ## package.
#' library(xcms)
#' x <- loadXcmsData()
#' x
#'
#' ## Store this result object to a folder
#' d <- file.path(tempdir(), "xcms_experiment_example")
#' saveMsObject(x, AlabasterParam(d))
#'
#' dir(d)
#'
#' ## Restore the data; eventually needed additional parameters, such as
#' ## `spectraPath` to restore a `MsBackendMzR` if the original data files
#' ## have been moved, could be passed with the `...` parameter of
#' ## `readMsExperiment()`.
#' x_in <- readMsObject(XcmsExperiment(), AlabasterParam(d))
#' x_in
NULL

#' @noRd
setClass("AlabasterParam",
         contains = "PlainTextParam")

#' @rdname AlabasterParam
#'
#' @export
AlabasterParam <- function(path = tempdir()) {
    new("AlabasterParam", path = path)
}
