library(Spectra)
library(MsDataHub)
library(MsBackendSql)
library(RSQLite)

s <- Spectra(PestMix1_DDA.mzML())
dbf <- file.path(tempdir(), "pest_mix.sqlite")
s <- setBackend(s, backend = MsBackendOfflineSql(), dbname = dbf,
                drv = SQLite())

test_that("reading/writing MsBackendOfflineSql to txt works", {
    ## Empty object
    p <- file.path(tempdir(), "offline_sql")
    a <- MsBackendOfflineSql()
    saveMsObject(a, PlainTextParam(p))
    fls <- dir(p)
    expect_true(all(c("ms_backend_dbinfo.txt", "ms_backend_spectra_ids.txt",
                      "ms_backend_drv.txt") %in% fls))
    res <- read.table(file.path(p, "ms_backend_dbinfo.txt"), sep = "\t",
                      header = TRUE)
    expect_true(all(is.na(res$value)))
    b <- readMsObject(MsBackendOfflineSql(), PlainTextParam(p))
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## Real data
    a <- s@backend
    unlink(p, recursive = TRUE)
    saveMsObject(a, PlainTextParam(p))
    fls <- dir(p)
    expect_true(all(c("ms_backend_dbinfo.txt", "ms_backend_spectra_ids.txt",
                      "ms_backend_drv.txt") %in% fls))
    res <- read.table(file.path(p, "ms_backend_dbinfo.txt"), sep = "\t",
                      header = TRUE)
    expect_equal(res$key, c("dbname", "user", "host", "port"))
    expect_equal(res$value, c(dbf, "", "", NA_character_))
    b <- readMsObject(MsBackendOfflineSql(), PlainTextParam(p))
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## With data subset.
    a <- a[1:30]
    unlink(p, recursive = TRUE)
    saveMsObject(a, PlainTextParam(p))
    fls <- dir(p)
    b <- readMsObject(MsBackendOfflineSql(), PlainTextParam(p))
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## With cached data
    a$other_col <- 1:30
    unlink(p, recursive = TRUE)
    saveMsObject(a, PlainTextParam(p))
    fls <- dir(p)
    b <- readMsObject(MsBackendOfflineSql(), PlainTextParam(p))
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## Errors.
    unlink(file.path(p, "ms_backend_drv.txt"))
    expect_error(readMsObject(MsBackendOfflineSql(), PlainTextParam(p)),
                 "'ms_backend_drv.txt'")
    unlink(file.path(p, "ms_backend_spectra_ids.txt"))
    expect_error(readMsObject(MsBackendOfflineSql(), PlainTextParam(p)),
                 "'ms_backend_spectra_ids.txt'")
    unlink(file.path(p, "ms_backend_dbinfo.txt"))
    expect_error(readMsObject(MsBackendOfflineSql(), PlainTextParam(p)),
                 "'ms_backend_dbinfo.txt'")
    unlink(p, recursive = TRUE)
})

test_that("reading/writing MsBackendOfflineSql with alabaster works", {
    p <- file.path(tempdir(), "offline_sql")
    ## Empty data
    a <- MsBackendOfflineSql()
    expect_silent(saveObject(a, p))
    fls <- dir(p)
    expect_true(all(c("user", "host", "port", "dbname", "spectra_ids",
                      "local_data", "ms_backend_drv.txt", "nspectra") %in% fls))
    b <- readAlabasterMsBackendOfflineSql(p)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    with_mocked_bindings(
        ".is_ms_backend_sql_installed" = function() FALSE,
        code = expect_error(readAlabasterMsBackendOfflineSql(p),
                            "package 'MsBackendSql'")
    )

    ## Real data
    unlink(p, recursive = TRUE)
    a <- s@backend
    expect_silent(saveObject(a, p))
    fls <- dir(p)
    expect_true(all(c("user", "host", "port", "dbname", "spectra_ids",
                      "local_data", "ms_backend_drv.txt", "nspectra") %in% fls))
    b <- readAlabasterMsBackendOfflineSql(p)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## Real data with subset
    unlink(p, recursive = TRUE)
    a <- a[1:10]
    expect_silent(saveObject(a, p))
    b <- readAlabasterMsBackendOfflineSql(p)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)

    ## Real data with subset and cached data
    unlink(p, recursive = TRUE)
    a$other_col <- 1:10
    expect_silent(saveObject(a, p))
    b <- readAlabasterMsBackendOfflineSql(p)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(b$other_col, 1:10)
    expect_equal(a, b)

    unlink(p, recursive = TRUE)
})

test_that("readObject dispatches to MsBackendOfflineSql, not MsBackendCached", {
    p <- file.path(tempdir(), "offline_sql")

    ## Empty data
    unlink(p, recursive = TRUE)
    a <- MsBackendOfflineSql()
    saveObject(a, p)
    res <- readObject(p)
    expect_s4_class(res, "MsBackendOfflineSql")
    expect_equal(a, res)

    ## Real data
    unlink(p, recursive = TRUE)
    a <- s@backend
    saveObject(a, p)
    res <- readObject(p)
    expect_s4_class(res, "MsBackendOfflineSql")
    expect_equal(a, res)

    unlink(p, recursive = TRUE)
})

test_that("saveMsObject/readMsObject MsBackendOfflineSql and AlabasterParam", {
    p <- file.path(tempdir(), "offline_sql")

    ## Empty data
    unlink(p, recursive = TRUE)
    a <- MsBackendOfflineSql()
    ap <- AlabasterParam(p)
    expect_silent(saveMsObject(a, ap))
    expect_error(saveMsObject(a, ap), "Overwriting")
    b <- readMsObject(MsBackendOfflineSql(), ap)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)
    b <- readMsObject(MsBackendCached(), ap)
    expect_s4_class(b, "MsBackendCached")
    expect_equal(a@localData, b@localData)

    ## Real data
    unlink(p, recursive = TRUE)
    a <- s@backend
    expect_silent(saveMsObject(a, ap))
    b <- readMsObject(MsBackendOfflineSql(), ap)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)
    b <- readMsObject(MsBackendCached(), ap)
    expect_s4_class(b, "MsBackendCached")
    expect_equal(a@spectraVariables, b@spectraVariables)

    ## Real data with subset
    unlink(p, recursive = TRUE)
    a <- a[1:10]
    expect_silent(saveMsObject(a, ap))
    b <- readMsObject(MsBackendOfflineSql(), ap)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)
    b <- readMsObject(MsBackendCached(), ap)
    expect_s4_class(b, "MsBackendCached")
    expect_equal(a@spectraVariables, b@spectraVariables)

    ## Real data with subset and cached data
    unlink(p, recursive = TRUE)
    a$other_col <- 1:10
    expect_silent(saveMsObject(a, ap))
    b <- readMsObject(MsBackendOfflineSql(), ap)
    expect_s4_class(b, "MsBackendOfflineSql")
    expect_equal(a, b)
    b <- readMsObject(MsBackendCached(), ap)
    expect_s4_class(b, "MsBackendCached")
    expect_equal(a@localData, b@localData)

    unlink(p, recursive = TRUE)

    ## Save the Spectra with the backend.
    unlink(p, recursive = TRUE)
    expect_silent(saveMsObject(s, ap))
    b <- readMsObject(Spectra(), ap)
    expect_s4_class(b, "Spectra")
    expect_equal(mz(s), mz(b))
    expect_s4_class(b@backend, "MsBackendOfflineSql")
    b <- readObject(p)
    expect_s4_class(b, "Spectra")
    expect_equal(mz(s), mz(b))
    expect_s4_class(b@backend, "MsBackendOfflineSql")
    unlink(p, recursive = TRUE)
})

unlink(dbf)
