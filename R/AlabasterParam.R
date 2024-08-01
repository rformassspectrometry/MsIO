#' @title Store MS data objects using the alabaster framework
#'
#' @name AlabasterParam
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
#' @author Johannes Rainer, Philippine Louail
NULL