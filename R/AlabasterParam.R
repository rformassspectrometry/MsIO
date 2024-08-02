#' @include PlainTextParam.R
#'
#' @title Store MS data objects using the alabaster framework
#'
#' @aliases readObject
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
#' - `Spectra`, defined in the
#'   [*Spectra*](https://bioconductor.org/packages/Spectra) package.
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
#'   to define the (absolute) path where the spectra files (*data storage
#'   files*) can be found. This parameter is used for `MsBackendMzR` (see
#'   descriptions below) and can be passed through `...` also to
#'   `readMsObject()` functions for other classes (such as `Spectra`,
#'   `MsExperiment` etc).
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
#' @section On-disk storage for `Spectra` objects:
#'
#' `Spectra` objects can be exported/imported using `saveMsObject()` and
#' `readMsObject()` with an `AlabasterParam`, or using the `saveObject()`
#' and `readObject()` functions. Both read functions allow to pass additional
#' parameters (such as `spectraPath`) to the function to read the backend.
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
#' @author Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ## Export and import a `MsBackendMzR` object:
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
#' ## Export and import of `Spectra` objects:
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
