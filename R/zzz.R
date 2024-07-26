.onLoad <- function(libname, pkgname) {
    ## requireNamespace("alabaster.base", quietly = TRUE)
    registerValidateObjectFunction("ms_backend_mz_r", validateMzBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readMzBackendMzR)
}
