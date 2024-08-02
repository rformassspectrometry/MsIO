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

    ## specifying the spectra path
    pth <- file.path(tempdir(), "mzml_file")
    dir.create(pth)
    newf <- file.path(pth, basename(sciex_file[1L]))
    if (file.copy(sciex_file[1L], newf)) {
        b <- backendInitialize(MsBackendMzR(), newf)
        pth <- file.path(tempdir(), "save_object_ms_backend_mz_r_2")
        saveObject(b, pth)
        ref <- readObject(pth)
        ## Move the original data file
        newpath <- file.path(tempdir(), "mzml_file_2")
        dir.create(newpath)
        newf2 <- file.path(newpath, basename(sciex_file[1L]))
        file.copy(newf, newf2)
        if (file.remove(newf)) {
            expect_error(readObject(pth), "not found")
            expect_error(validObject(ref), "not found")
            res <- readObject(pth, spectraPath = newpath)
            expect_equal(rtime(res), rtime(ref))
            expect_equal(mz(res[1:10]), mz(sciex_mzr[1:10]))
        }
    }
})

test_that(".mz_backend_mzr_update_storage_path works", {
    x <- sciex_mzr
    res <- .mz_backend_mzr_update_storage_path(x, "/new/path")
    expect_true(all(grepl("^/new/path", res$dataStorage)))
    expect_error(validObject(res), "not found")
})

test_that("saveMsObject,readMsObject,MsBackendMzR,AlabasterParam works", {
    x <- backendInitialize(MsBackendMzR(), sciex_file[2L])
    pth <- tempdir()
    expect_error(saveMsObject(x, AlabasterParam(pth)), "Overwriting")

    pth <- file.path(pth, "save_object_ms_backend_mz_r")
    if (file.exists(pth))
        unlink(pth, recursive = TRUE)
    saveMsObject(x, AlabasterParam(pth))
    expect_true(all(c("OBJECT", "peaks_variables", "spectra_data") %in%
                    dir(pth)))
    res <- readMsObject(MsBackendMzR(), AlabasterParam(pth))
    expect_equal(res@spectraData, x@spectraData)
    expect_equal(spectraData(res), spectraData(x))
    expect_equal(res@peaksVariables, x@peaksVariables)
})
