test_that(".onLoad works", {
    expect_true(
        alabaster.base:::deregister_validate_function("ms_backend_mz_r"))
    expect_false(
        alabaster.base:::deregister_validate_function("ms_backend_mz_r"))
    reg <- alabaster.base:::read.registry$registry
    reg$ms_backend_mz_r <- NULL
    reg$spectra <- NULL
    reg$ms_experiment_files <- NULL
    reg$ms_experiment <- NULL
    reg$xcms_experiment <- NULL
    assign("registry", reg, envir = alabaster.base:::read.registry)
    expect_false(any(names(alabaster.base:::read.registry$register) %in%
                     c("ms_backend_mz_r", "ms_experiment_files",
                       "ms_experiment", "xcms_experiment")))
    .onLoad()
    expect_true(all(c("ms_backend_mz_r", "ms_experiment_files",
                      "ms_experiment", "xcms_experiment") %in%
                    names(alabaster.base:::read.registry$registry)))

    expect_true(
        alabaster.base:::deregister_validate_function("ms_backend_mz_r"))
    .onLoad()
})
