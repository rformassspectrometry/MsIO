#' @title Store contents of MS objects as plain text files
#'
#' @name PlainTextParam
#'
#' @export
#'
#' @family Ms object export and import formats.
#'
#' @description
#'
#' The `saveMsObject()` and `readMsObject()` methods with the `PlainTextParam`
#' option enable users to save/load different type of Ms object as a
#' collections of plain text files in/from a specified folder. This folder,
#' defined with the `path` parameter, will be created by the `storeResults()`
#' function. Any previous exports eventually present in that folder will be
#' overwritten.
#'
#' The Ms object currently supported for import and export wwith this parameter
#' are :
#'
#' - [`MsBackendMzR`] object
#' - [`Spectra`] object
#'
#' @param path For `PlainTextParam()`: `character(1)`, defining where the files
#'   are going to be stored/ should be loaded from. The default is
#'   `path = tempdir()`.
#'
#' @param spectraPath For `readMsObject()`: `character(1)` optionally allowing to
#'   define the (absolute) path where the spectra files (*data storage files*)
#'   can be found. This parameter is passed to the `loadResults()` method of
#'   the [MsBackend()].
#'
#' @inheritParams saveMsObject
#'
#' @return For `PlainTextParam()`: a `PlainTextParam` class. `saveMsObject()`
#' does not return anything but saves the object to collections of different
#' plain text files to a folder. The `readMsObject()` method returns the
#' restored data as an instance of the class specified with parameter `object`.
#'
#' @author Philippine Louail
#'
#' @importFrom methods new
#'
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
