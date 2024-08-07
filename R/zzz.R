.onLoad <- function(libname, pkgname) {
    ## requireNamespace("alabaster.base", quietly = TRUE)
    registerValidateObjectFunction("ms_backend_mz_r",
                                   validateAlabasterMzBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readAlabasterMzBackendMzR)
    registerValidateObjectFunction("spectra", validateAlabasterSpectra)
    registerReadObjectFunction("spectra", readAlabasterSpectra)
    registerValidateObjectFunction("ms_experiment_files",
                                   validateAlabasterMsExperimentFiles)
    registerReadObjectFunction("ms_experiment_files",
                               readAlabasterMsExperimentFiles)
    registerValidateObjectFunction("ms_experiment",
                                   validateAlabasterMsExperiment)
    registerReadObjectFunction("ms_experiment",
                               readAlabasterMsExperiment)
}
