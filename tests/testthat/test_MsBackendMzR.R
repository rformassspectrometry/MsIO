library(Spectra)

sciex_file <- normalizePath(
    dir(system.file("sciex", package = "msdata"), full.names = TRUE))
sciex_mzr <- backendInitialize(MsBackendMzR(), files = sciex_file)

test_that("saveMsObject,readMsObject,PlainTextParam,MsBackendMzR works", {
    b <- sciex_mzr
    pth <- file.path(tempdir(), "test_backend")
    param <- PlainTextParam(path = pth)
    saveMsObject(b, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path, "ms_backend_data.txt")))
    ## Loading data again
    b_load <- readMsObject(object = MsBackendMzR(), param)
    expect_true(inherits(b_load, "MsBackendMzR"))
    expect_equal(peaksVariables(b), peaksVariables(b_load))
    b <- dropNaSpectraVariables(b)
    expect_equal(b@spectraData, b_load@spectraData)
    expect_equal(mz(b[1:20]), mz(b_load[1:20]))

    ## Check the spectraPath parameter.
    bp <- dataStorageBasePath(b)
    ## manually change dataStorage path of backend
    sd <- read.table(file.path(param@path, "ms_backend_data.txt"),
                     sep = "\t", header = TRUE)
    sd$dataStorage <- sub("msdata", "other", sd$dataStorage)
    writeLines("# MsBackendMzR",
               con = file.path(param@path, "ms_backend_data.txt"))
    write.table(sd,
                file = file.path(param@path, "ms_backend_data.txt"),
                sep = "\t", quote = FALSE,
                    append = TRUE, row.names = FALSE)
    expect_error(readMsObject(MsBackendMzR(), param), "invalid class")
    expect_no_error(readMsObject(MsBackendMzR(), param, spectraPath = bp))
    param <- PlainTextParam(tempdir())
    expect_error(readMsObject(MsBackendMzR(), param), "No 'backend_data")

    ## check for empty backend
    b_empty <- MsBackendMzR()
    pth <- file.path(tempdir(), "test_backend_empty")
    param <- PlainTextParam(path = pth)
    saveMsObject(b_empty, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path, "ms_backend_data.txt")))
    expect_no_error(readMsObject(object = MsBackendMzR(), param))
    res <- readMsObject(MsBackendMzR(), param)
    expect_s4_class(res, "MsBackendMzR")
    expect_true(length(res) == 0)
})

test_that("saveObject,readObject,MsBackendMzR works", {
    b <- sciex_mzr
    pth <- file.path(tempdir(), "save_object_ms_backend_mz_r")
    saveObject(b, pth)
    res <- dir(pth)
    expect_true(length(res) > 0)
    expect_true(all(c("OBJECT", "spectra_data", "peaks_variables") %in% res))

    ## validateMzBackendMzR
    expect_error(MsIO:::validateMzBackendMzR("some_path"), "required directory")
    expect_silent(MsIO:::validateMzBackendMzR(pth))

    ## readMzBackendMzR
    expect_error(MsIO:::readMzBackendMzR("some_path"), "required directory")
    res <- MsIO:::readMzBackendMzR(pth)
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(length(b), length(res))

    ## readObject
    res <- readObject(pth)
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(b@peaksVariables, res@peaksVariables)
    expect_equal(mz(b), mz(res))
    expect_equal(res@spectraData, b@spectraData[, colnames(res@spectraData)])
})
