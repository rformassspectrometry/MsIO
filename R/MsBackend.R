#' readMsObject()/saveMsObject() for the base MsBackend class.
#'
#' @noRd

setMethod("saveMsObject", c("MsBackend", "ANY"), function(object, param) {
    stop("No 'saveMsObject()' method for objects of class '", class(object)[1L],
         "' and argument 'param' of class '", class(param)[1L],
         "' implemented yet.",
         " Please open an issue on 'https://github.com/",
         "RforMassSpectrometry/MsIO' for support.", call. = FALSE)
})

setMethod("readMsObject", c("MsBackend", "ANY"), function(object, param) {
    stop("No 'readMsObject()' method for objects of class '", class(object)[1L],
         "' and argument 'param' of class '", class(param)[1L],
         "' implemented yet.",
         " Please open an issue on 'https://github.com/",
         "RforMassSpectrometry/MsIO' for support.", call. = FALSE)
})
