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
    s_load <- readMsObject(object = Spectra(), param)
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

test_that("saveObject,readObject,saveMsObject,readMsObject,Spectra works", {
    pth <- file.path(tempdir(), "spectra_alabaster")

    expect_error(saveObject(Spectra(), path = pth), "available yet")

    ## save/load real object
    s <- sps_dda
    saveObject(s, pth)
    expect_silent(validateAlabasterSpectra(pth))
    expect_error(saveMsObject(s, AlabasterParam(pth)), "Overwriting or saving")
    expect_true(all(c("OBJECT", "backend", "metadata", "processing",
                      "processing_chunk_size", "processing_queue_variables",
                      "spectra_processing_queue.json") %in% dir(pth)))
    res <- readAlabasterSpectra(pth)
    expect_s4_class(res, "Spectra")
    expect_equal(length(res), length(s))
    expect_equal(res@backend, s@backend)
    expect_equal(res@metadata, s@metadata)
    expect_equal(res@processing, s@processing)
    expect_equal(res@processingChunkSize, s@processingChunkSize)
    expect_equal(length(res@processingQueue), length(s@processingQueue))
    expect_equal(res@processingQueueVariables, s@processingQueueVariables)
    expect_equal(mz(res[1:3]), mz(s[1:3]))
    res_2 <- readObject(pth)
    expect_equal(res, res_2)

    ## save/load empty object
    unlink(pth, recursive = TRUE)
    s <- sps_dda[integer()]
    saveObject(s, pth)
    expect_true(all(c("OBJECT", "backend", "metadata", "processing",
                      "processing_chunk_size", "processing_queue_variables",
                      "spectra_processing_queue.json") %in% dir(pth)))
    res <- readObject(pth)
    expect_s4_class(res, "Spectra")
    expect_equal(length(res), length(s))
    expect_equal(res@backend, s@backend)
    expect_equal(res@metadata, s@metadata)
    expect_equal(res@processing, s@processing)
    expect_equal(res@processingChunkSize, s@processingChunkSize)
    expect_equal(length(res@processingQueue), length(s@processingQueue))
    expect_equal(res@processingQueueVariables, s@processingQueueVariables)

    ## move data file
    newp <- file.path(tempdir(), "temp_mzml")
    dir.create(newp)
    newf <- file.path(newp, "a.mzML")
    file.copy(fl, newf)
    s <- Spectra(newf)
    unlink(pth, recursive = TRUE)
    saveObject(s, pth)
    res <- readObject(pth)
    expect_equal(s, res)
    ## move data file.
    newp <- file.path(tempdir(), "temp_mzml2")
    dir.create(newp)
    file.copy(newf, file.path(newp, "a.mzML"))
    unlink(newf)

    expect_error(readObject(pth), "not found")
    res <- readObject(pth, spectraPath = newp)
    res_2 <- readMsObject(Spectra(), AlabasterParam(pth), spectraPath = newp)
    expect_s4_class(res, "Spectra")
    expect_s4_class(res_2, "Spectra")
    expect_true(validObject(res@backend))
    expect_true(validObject(res_2@backend))
    ref <- Spectra(fl)
    expect_equal(length(res), length(ref))
    expect_equal(res@metadata, ref@metadata)
    expect_equal(res@processing, ref@processing)
    expect_equal(res@processingChunkSize, ref@processingChunkSize)
    expect_equal(res@processingQueue, ref@processingQueue)
    expect_equal(res@processingQueueVariables, ref@processingQueueVariables)
    expect_equal(rtime(res), rtime(ref))
    expect_equal(mz(res[1:3]), mz(ref[1:3]))
})
