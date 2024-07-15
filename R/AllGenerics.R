#' @title Save and load MS data objects to and from different file formats
#'
#' @aliases saveMsObject,MsBackend,ANY-method
#' @aliases readMsObject,MsBackend,ANY-method
#'
#' @description
#'
#' The `saveMsObject()` and `readMsObject()` methods allow serializing and
#' restoring/importing mass spectrometry (MS) data objects to and from language
#' agnostic file formats. The type  and configuration of the file format is
#' defined by the second argument to the method, `param`.
#'
#' - `saveMsObject(object, param)`: saves the MS data object `object` to file(s)
#'   in a format defined by `param`.
#'
#' - `readMsObject(object, param)`: `object` defines the type of MS object that
#'   should be returned by the function and `param` the format and file name(s)
#'   from which the data should be restored/imported.
#'
#' @param object for `saveMsObject()`: the MS data object to save, for
#'     `readMsObject()`: the MS data object that should be returned
#'
#' @param param an object defining and (eventually configuring) the file format
#'     and file name or directory to/from which the data object should be
#'     exported/imported.
#'
#' @param ... additional optional arguments. See documentation of respective
#'     method for more information.
#'
#' @return `saveMsObject()` has no return value, `readMsObject` is expected
#'     to return an instance of the class defined with `object`.
#'
#' @author Philippine Louail, Johannes Rainer, Laurent Gatto
#'
#' @exportMethod saveMsObject
#'
#' @exportMethod readMsObject
#'
#' @name saveMsObject

#' @rdname saveMsObject
setGeneric("saveMsObject", function(object, param, ...)
    standardGeneric("saveMsObject"))

#' @rdname saveMsObject
setGeneric("readMsObject", function(object, param, ...)
    standardGeneric("readMsObject"))
