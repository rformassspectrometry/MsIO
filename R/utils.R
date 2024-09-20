.is_alabaster_matrix_installed <- function() {
    requireNamespace("alabaster.matrix", quietly = TRUE)
}

.is_spectra_installed <- function() {
    requireNamespace("Spectra", quietly = TRUE)
}

.is_alabaster_se_installed <- function() {
    requireNamespace("alabaster.se", quietly = TRUE)
}

.is_ms_experiment_installed <- function() {
    requireNamespace("MsExperiment", quietly = TRUE)
}

.is_ms_backend_metabo_lights_installed <- function() {
    requireNamespace("MsBackendMetaboLights", quietly = TRUE)
}

.is_xcms_installed <- function() {
    requireNamespace("xcms", quietly = TRUE)
}
