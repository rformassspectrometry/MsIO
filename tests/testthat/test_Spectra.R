library(Spectra)

fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML",
                  package = "msdata")
sps_dda <- Spectra(fl)
## add processingQueueVariables to test export
sps_dda@processingQueueVariables <- c(sps_dda@processingQueueVariables, "rtime")
sps_dda <- filterMzRange(sps_dda, c(200,300))
sps_dda <- filterRt(sps_dda, c(200, 700)) ## to ensure subsetted object would work

test_that("saveMsObject,readMsObject,PlainTextParam,Spectra works", {
    s <- sps_dda
    pth <- file.path(tempdir(), "test_spectra")
    ## param test
    param <- PlainTextParam(path = pth)
    param2 <- PlainTextParam()
    expect_false(is.null(param2))
    expect_error(new("PlainTextParam", path = c(tempdir(), tempdir())))
    saveMsObject(s, param = param)
    expect_true(file.exists(file.path(param@path, "ms_backend_data.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_slots.txt")))
    expect_true(file.exists(file.path(param@path,
                                      "spectra_processing_queue.json")))

    ## Loading data again
    s_load <- readMsObject(object = Spectra(), param) # for this test dataset we have error when validating the backend object
    expect_true(inherits(s_load, "Spectra"))
    expect_true(inherits(s_load@backend, "MsBackendMzR"))
    ## Check spectra content
    expect_equal(length(s@processingQueue), length(s_load@processingQueue))
    expect_equal(s@processingQueue[[1L]]@ARGS, s_load@processingQueue[[1L]]@ARGS)
    expect_equal(s@processingQueueVariables, s_load@processingQueueVariables)
    expect_equal(s@processing, s_load@processing)
    expect_equal(processingChunkSize(s), processingChunkSize(s_load))
    ## Check backend data
    expect_equal(s@backend@peaksVariables, s_load@backend@peaksVariables)
    s <- dropNaSpectraVariables(s)
    expect_equal(s@backend@spectraData, s_load@backend@spectraData)
    ## Expect same actual content
    expect_equal(rtime(s), rtime(s_load))
    expect_equal(mz(s[1:10]), mz(s_load[1:10]))
    expect_no_error(filterRt(s_load, c(3000, 3500)))

    ## Errors
    param <- PlainTextParam(file.path(tempdir()))
    expect_error(readMsObject(Spectra(), param), "No 'spectra_slots")

    ## Unsupported backend
    s2 <- setBackend(s, MsBackendMemory())
    expect_error(saveMsObject(s2, param = param), "MsBackendMemory")

    ## check empty spectra
    s <- filterRt(s, c(900, 1000))
    expect_true(length(s) == 0)
    pth <- file.path(tempdir(), "test_spectra_empty")
    param <- PlainTextParam(path = pth)
    saveMsObject(s, param = param)
    expect_true(file.exists(file.path(param@path, "ms_backend_data.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_slots.txt")))
    expect_true(file.exists(file.path(param@path,
                                      "spectra_processing_queue.json")))
    expect_no_error(readMsObject(object = Spectra(), param))
    s_load <- readMsObject(object = Spectra(), param)
    expect_equal(length(s), length(s_load))
})
