.onLoad <- function(libname, pkgname) {
    ## requireNamespace("alabaster.base", quietly = TRUE)
    registerValidateObjectFunction("ms_backend_mz_r",
                                   validateAlabasterMzBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readAlabasterMzBackendMzR)
    registerValidateObjectFunction("spectra", validateAlabasterSpectra)
    registerReadObjectFunction("spectra", readAlabasterSpectra)
}
