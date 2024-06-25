test_that("storeResults,loadResults,PlainTextParam,MsBackendMzR works", {
    pth <- file.path(tempdir(), "test")
    param <- PlainTextParam(path = pth)
    storeResults(sciex_mzr, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path, "backend_data.txt")))
    ## Loading data again
    b_load <- loadResults(object = MsBackendMzR(), param)
    expect_true(inherits(b_load, "MsBackendMzR"))
    sciex_mzr <- dropNaSpectraVariables(sciex_mzr)
    expect_equal(sciex_mzr@spectraData, b_load@spectraData)
    expect_equal(peaksVariables(sciex_mzr), peaksVariables(b_load))
    expect_equal(mz(sciex_mzr[1:20]), mz(b_load[1:20]))

    ## Check the spectraPath parameter.
    bp <- dataStorageBasePath(sciex_mzr)
    ## manually change dataStorage path of backend
    sd <- read.table(file.path(param@path, "backend_data.txt"), header = TRUE)
    sd$dataStorage <- sub("faahKO", "other", sd$dataStorage)
    write.table(sd, file = file.path(param@path, "backend_data.txt"),
                sep = "\t", quote = FALSE, row.names = FALSE)
    A <- loadResults(MsBackendMzR(), param)
    expect_error(validObject(A), "invalid class")
    A <- loadResults(MsBackendMzR(), param, spectraPath = bp)
    expect_true(validObject(A))
    param <- PlainTextParam(tempdir())
    expect_error(loadResults(MsBackendMzR(), param), "No 'backend_data")
})
