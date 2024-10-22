## Tests for the MsBackendMetaboLights backend.

library(Spectra)
library(MsBackendMetaboLights)

be_mtbls <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                              filePattern = "63A.cdf", offline = FALSE)

test_that("readMsObject,PlainTextParam,MsBackendMetaboLights works", {
    pth <- file.path(tempdir(), "test_backend_ml")
    saveMsObject(be_mtbls, PlainTextParam(pth))

    ## read
    res <- readMsObject(MsBackendMetaboLights(), PlainTextParam(pth),
                        offline = TRUE)
    expect_true(validObject(res))
    expect_equal(rtime(be_mtbls), rtime(res))
    expect_equal(mz(be_mtbls), mz(res))

    ## Clean cache first to check errors etc.
    bfc <- BiocFileCache::BiocFileCache()
    BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)

    ## read again offline throws error
    expect_error(readMsObject(MsBackendMetaboLights(), PlainTextParam(pth),
                              offline = TRUE), "No locally cached")

    ## read re-downloading the data
    res <- readMsObject(MsBackendMetaboLights(), PlainTextParam(pth),
                        offline = FALSE)
    expect_true(validObject(res))
    expect_equal(rtime(be_mtbls), rtime(res))
    expect_equal(mz(be_mtbls), mz(res))

    unlink(pth, recursive = TRUE)

    pth <- file.path(tempdir(), "test_backend_ml")
    dir.create(pth)
    expect_error(readMsObject(MsBackendMetaboLights(), PlainTextParam(pth)),
                 "found in the provided path.")
    writeLines("# Some line\nnext line\nthird line\n",
               con = file.path(pth, "ms_backend_data.txt"))
    expect_error(readMsObject(MsBackendMetaboLights(), PlainTextParam(pth)),
                 "Invalid class in")
})

test_that("saveObject,readObject,MsBackendMetaboLights works", {
    b <- be_mtbls
    pth <- file.path(tempdir(), "save_object_ms_backend_metabo_lights")
    saveObject(b, pth)
    res <- dir(pth)
    expect_true(length(res) > 0)
    expect_true(all(c("OBJECT", "spectra_data", "peaks_variables") %in% res))
    res <- readObject(pth, offline = TRUE)
    expect_true(validObject(res))
    expect_equal(rtime(res), rtime(b))
    expect_equal(mz(res[1:10]), mz(b[1:10]))
    ## Clear cache and repeat, syncing the data
    bfc <- BiocFileCache::BiocFileCache()
    BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)
    res <- readObject(pth)
    expect_true(validObject(res))
    expect_equal(rtime(res), rtime(b))
    expect_equal(mz(res[1:10]), mz(b[1:10]))

    ## readAlabasterMsBackendMzR
    expect_error(readAlabasterMsBackendMetaboLights("some_path"),
                 "required file/directory")
    res <- readAlabasterMsBackendMetaboLights(pth, offline = TRUE)
    expect_s4_class(res, "MsBackendMetaboLights")
    expect_equal(length(b), length(res))
    expect_true(validObject(res))

    ## package Spectra not available:
    with_mock(
        "MsIO:::.is_spectra_installed" = function() FALSE,
        expect_error(MsIO:::readAlabasterMsBackendMetaboLights(pth),
                     "package 'Spectra'")
    )
    ## package Spectra not available:
    with_mock(
        "MsIO:::.is_ms_backend_metabo_lights_installed" = function() FALSE,
        expect_error(MsIO:::readAlabasterMsBackendMetaboLights(pth),
                     "package 'MsBackendMetaboLights'")
    )
    unlink(pth, recursive = TRUE)
})

test_that("saveMsObject,readMsObject,MsBackendMetaboLights works", {
    b <- be_mtbls
    pth <- file.path(tempdir(), "save_object_ms_backend_metabo_lights")
    prm <- AlabasterParam(pth)
    saveMsObject(b, param = prm)
    expect_error(saveMsObject(b, param = prm), "Overwriting or")

    res <- readMsObject(MsBackendMetaboLights(), prm, offline = TRUE)
    expect_s4_class(res, "MsBackendMetaboLights")
    expect_equal(length(b), length(res))
    expect_true(validObject(res))
    expect_equal(mz(res[1:10]), mz(b[1:10]))

    unlink(pth, recursive = TRUE)
})
