.onLoad <- function(libname, pkgname) {
    ## requireNamespace("alabaster.base", quietly = TRUE)
    registerValidateObjectFunction("ms_backend_mz_r",
                                   validateAlabasterMsBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readAlabasterMsBackendMzR)
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
    registerValidateObjectFunction("xcms_experiment",
                                   validateAlabasterXcmsExperiment)
    registerReadObjectFunction("xcms_experiment",
                               readAlabasterXcmsExperiment)
}
