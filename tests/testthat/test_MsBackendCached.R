
test_that("saveMsObject/readMsObject,MsBackendCached,PlainTextParam works", {
    ## Empty object
    p <- file.path(tempdir(), "cached")
    dir.create(p, showWarnings = FALSE)
    a <- MsBackendCached()
    ptp <- PlainTextParam(p)
    saveMsObject(a, ptp)
    fls <- dir(p)
    expect_true(all(c("ms_backend_data.txt", "ms_backend_spectra_variables.txt",
                      "ms_backend_nspectra.txt") %in% fls))
    expect_equal(readLines(file.path(p, "ms_backend_nspectra.txt")), "0")
    expect_equal(readLines(file.path(p, "ms_backend_data.txt"), n = 1),
                 "# MsBackendCached")
    expect_equal(readLines(file.path(p, "ms_backend_spectra_variables.txt")),"")
    ## read
    b <- readMsObject(MsBackendCached(), ptp)
    expect_true(validObject(b))
    expect_equal(a, b)

    ############################################################################
    ##    Real object
    a <- backendInitialize(a, data = data.frame(opt = 1:10, b = "a"),
                           spectraVariables = c("msLevel", "rtime", "opt", "a"),
                           nspectra = 10)
    unlink(file.path(p, fls))
    saveMsObject(a, ptp)
    fls <- dir(p)
    expect_true(all(c("ms_backend_data.txt", "ms_backend_spectra_variables.txt",
                      "ms_backend_nspectra.txt") %in% fls))
    expect_equal(readLines(file.path(p, "ms_backend_nspectra.txt")), "10")
    expect_equal(readLines(file.path(p, "ms_backend_data.txt"), n = 1),
                 "# MsBackendCached")
    res <- read.table(file.path(p, "ms_backend_data.txt"), sep = "\t",
                      header = TRUE)
    rownames(res) <- NULL
    expect_equal(res, a@localData)
    res <- readLines(file.path(p, "ms_backend_spectra_variables.txt"))
    expect_equal(strsplit(res, "\t")[[1L]], a@spectraVariables)
    ## read
    b <- readMsObject(MsBackendCached(), ptp)
    expect_true(validObject(b))
    expect_equal(a, b)

    ############################################################################
    ##    Errors
    expect_error(saveMsObject(a, ptp), "Overwriting or saving")
    unlink(file.path(p, "ms_backend_data.txt"))
    expect_error(readMsObject(MsBackendCached(), ptp), "file found in ")
    writeLines("# Hello", file.path(p, "ms_backend_data.txt"))
    expect_error(readMsObject(MsBackendCached(), ptp), "Invalid class in")
    writeLines("# MsBackendCached", file.path(p, "ms_backend_data.txt"))
    unlink(file.path(p, "ms_backend_nspectra.txt"))
    expect_error(readMsObject(MsBackendCached(), ptp,
                              "'ms_backend_nspectra.txt'"))
    writeLines("a", file.path(p, "ms_backend_nspectra.txt"))
    expect_error(readMsObject(MsBackendCached(), ptp, "Corrupt"))
    writeLines("0", file.path(p, "ms_backend_nspectra.txt"))
    unlink(file.path(p, "ms_backend_spectra_variables.txt"))
    expect_error(readMsObject(MsBackendCached(), ptp,
                              "'ms_backend_spectra_variables.txt'"))
})

test_that(".ms_backend_cached_save and readAlabasterMsBackendCached works", {
    p <- file.path(tempdir(), "cached")
    if (dir.exists(p))
        unlink(dir(p, full.names = TRUE))
    a <- backendInitialize(
        MsBackendCached(), data = data.frame(a = 1:10, b = "b"),
        spectraVariables = c("msLevel", "a", "b"), nspectra = 10)
    .ms_backend_cached_save(a, p, object = "ms_backend_cached")
    fls <- dir(p)
    expect_true(all(c("local_data", "spectra_variables", "nspectra") %in% fls))

    res <- readAlabasterMsBackendCached(p)
    expect_s4_class(res, "MsBackendCached")
    expect_equal(a, res)

    unlink(p, recursive = TRUE)

    ## Empty object
    a <- MsBackendCached()
    saveObject(a, p)
    fls <- dir(p)
    expect_true(all(c("local_data", "spectra_variables", "nspectra") %in% fls))
    res <- readObject(p)
    expect_s4_class(res, "MsBackendCached")
    expect_equal(a, res)

    ## Read/write with saveMsObject, readMsObject

    ## package Spectra not available:
    with_mocked_bindings(
        ".is_spectra_installed" = function() FALSE,
        code = expect_error(MsIO:::readAlabasterMsBackendCached(pth),
                            "package 'Spectra'")
    )
})

test_that("readMsObject,MsBackendCached,AlabasterParam works", {
    p <- file.path(tempdir(), "cached")
    if (dir.exists(p))
        unlink(p, recursive = TRUE)
    a <- backendInitialize(
        MsBackendCached(), data = data.frame(a = 1:10, b = "b"),
        spectraVariables = c("msLevel", "a", "b"), nspectra = 10)
    saveMsObject(a, AlabasterParam(p))
    fls <- dir(p)
    expect_true(all(c("local_data", "spectra_variables", "nspectra") %in% fls))
    res <- readMsObject(MsBackendCached(), AlabasterParam(p))
    expect_s4_class(res, "MsBackendCached")
    expect_equal(res, a)

    ## errors
    expect_error(saveMsObject(a, AlabasterParam(p)), "Overwriting")
})
