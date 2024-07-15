test_that("saveMsObject,readMsObject,PlainTextParam,MsBackendMzR works", {
    b <- sciex_mzr
    pth <- file.path(tempdir(), "test")
    param <- PlainTextParam(path = pth)
    saveMsObject(b, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path, "backend_data.txt")))
    ## Loading data again
    b_load <- readMsObject(object = MsBackendMzR(), param)
    expect_true(inherits(b_load, "MsBackendMzR"))
    b <- dropNaSpectraVariables(b)
    expect_equal(b@spectraData, b_load@spectraData)
    expect_equal(peaksVariables(b), peaksVariables(b_load))
    expect_equal(mz(b[1:20]), mz(b_load[1:20]))

    ## Check the spectraPath parameter.
    bp <- dataStorageBasePath(b)
    ## manually change dataStorage path of backend
    sd <- read.table(file.path(param@path, "backend_data.txt"), sep = "\t", header = TRUE)
    sd$dataStorage <- sub("msdata", "other", sd$dataStorage)
    write.table(sd, file = file.path(param@path, "backend_data.txt"),
                sep = "\t", quote = FALSE, row.names = FALSE)
    A <- readMsObject(MsBackendMzR(), param)
    expect_error(validObject(A), "invalid class")
    A <- readMsObject(MsBackendMzR(), param, spectraPath = bp)
    expect_true(validObject(A))
    param <- PlainTextParam(tempdir())
    expect_error(readMsObject(MsBackendMzR(), param), "No 'backend_data")
})
