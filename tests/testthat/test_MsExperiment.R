library(MsExperiment)
library(faahKO)
library(Spectra)

faahko_3_files <- c(system.file('cdf/KO/ko15.CDF', package = "faahKO"),
                    system.file('cdf/KO/ko16.CDF', package = "faahKO"),
                    system.file('cdf/KO/ko18.CDF', package = "faahKO"))
fls <- normalizePath(faahko_3_files)
df <- data.frame(mzML_file = basename(fls),
                 dataOrigin = fls,
                 sample = c("ko15", "ko16", "ko18"))
mse <- readMsExperiment(spectraFiles = fls, sampleData = df)
## add processingQueueVariables to test export
mse_filt <- filterMzRange(mse, c(200, 500))
mse_filt <- filterRt(mse_filt, c(3000, 3500))

test_that("saveMsObject,readMsObject,PlainTextParam,MsExperiment works", {
    pth <- file.path(tempdir(), "test_MsExperiment")
    param <- PlainTextParam(path = pth)
    saveMsObject(mse_filt, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path,
                                      "ms_experiment_sample_data.txt")))
    expect_true(file.exists(file.path(param@path, "ms_backend_data.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_slots.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_processing_queue.json")))
    pattern <- "ms_experiment_sample_data_links_.*\\.txt"
    expect_true(length(list.files(param@path, pattern = pattern)) > 0)
    ## Loading data again
    load_mse <- readMsObject(object = MsExperiment(), param)
    expect_true(inherits(load_mse, "MsExperiment"))
    expect_equal(sampleData(mse_filt), sampleData(load_mse))
    expect_equal(mse_filt@sampleDataLinks, load_mse@sampleDataLinks)
    a <- spectra(mse_filt)
    b <- spectra(load_mse)
    expect_equal(length(a@processingQueue), length(b@processingQueue))
    expect_equal(a@processingQueue[[1L]]@ARGS, b@processingQueue[[1L]]@ARGS)
    expect_equal(rtime(a), rtime(b))
    expect_equal(mz(a[1:10]), mz(b[1:10]))
    expect_no_error(filterRt(load_mse, c(3000, 3500)))

    param <- PlainTextParam(tempdir())
    expect_error(readMsObject(MsExperiment(), param),
                 "No 'ms_experiment_sample_data")

    ## Export of object without links
    mse_2 <- MsExperiment(spectra = spectra(mse), sampleData = sampleData(mse))
    pth <- file.path(tempdir(), "test_MsExperiment2")
    param <- PlainTextParam(path = pth)
    saveMsObject(mse_2, param = param)
    load_mse <- readMsObject(object = MsExperiment(), param)
    expect_true(inherits(load_mse, "MsExperiment"))
    expect_equal(sampleData(mse_2), sampleData(load_mse))
    expect_equal(mse_2@sampleDataLinks, load_mse@sampleDataLinks)

    ## Export an empty MsExperiment
    a <- MsExperiment()
    pth <- file.path(tempdir(), "text_msexperiment_empty")
    param <- PlainTextParam(path = pth)
    saveMsObject(a, param = param)
    res <- readMsObject(MsExperiment(), param = param)
    expect_true(nrow(sampleData(res)) == nrow(sampleData(a)))
    res@sampleData <- a@sampleData
    expect_equal(res, a)
})

test_that("saveObject,MsExperiment,readAlabasterMsExperiment etc works", {
    ## Alabaster MsExperiment save/read functions.
    pth <- file.path(tempdir(), "ms_experiment_alabaster")

    ## Empty object.
    m <- MsExperiment()
    saveObject(m, pth)
    expect_true(all(c("sample_data", "sample_data_links",
                      "sample_data_links_mcols", "metadata",
                      "experiment_files", "other_data") %in% dir(pth)))
    expect_true(!any(dir(pth) %in% c("spectra", "qdata")))
    expect_silent(MsIO:::validateAlabasterMsExperiment(pth))
    res <- MsIO:::readAlabasterMsExperiment(pth)
    expect_equal(res, m)

    ## Non-empty object with SampleDataLinks and Spectra
    m <- mse_filt
    expect_error(saveObject(m, pth), "existing")
    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    expect_true(all(c("sample_data", "sample_data_links", "spectra",
                      "sample_data_links_mcols", "metadata",
                      "experiment_files", "other_data") %in% dir(pth)))
    expect_true(!any(dir(pth) %in% c("qdata")))
    res <- readObject(pth)
    expect_s4_class(res, "MsExperiment")
    expect_equal(res@metadata, m@metadata)
    expect_equal(res@experimentFiles, m@experimentFiles)
    expect_equal(res@otherData, m@otherData)
    expect_equal(res@qdata, m@qdata)
    expect_equal(res@sampleData, m@sampleData)
    expect_equal(res@sampleDataLinks, m@sampleDataLinks)
    expect_equal(length(res@spectra), length(m@spectra)) # processingQueue differs
    expect_equal(mz(res@spectra[1:10]), mz(m@spectra[1:10]))

    ## Non-empty object with SummarizedExperiment
    library(SummarizedExperiment)
    se <- SummarizedExperiment(
        assays = list(raw = matrix(rnorm(100), ncol = 5)),
        colData = data.frame(name = c("a", "b", "c", "d", "e")),
        rowData = data.frame(feature = 1:20))
    m@qdata <- se
    expect_true(validObject(m))
    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    expect_true(all(c("sample_data", "sample_data_links", "spectra",
                      "sample_data_links_mcols", "metadata", "qdata",
                      "experiment_files", "other_data") %in% dir(pth)))
    res <- MsIO:::readAlabasterMsExperiment(pth)
    expect_s4_class(res, "MsExperiment")
    expect_equal(assayNames(res@qdata), assayNames(se))
    expect_equal(rowData(res@qdata), rowData(se))
    expect_equal(colData(res@qdata), colData(se))
    expect_equal(assay(res@qdata)[[1L]], assay(se)[[1L]])

    ## Non-empty object with MsExperimentFiles
    m@experimentFiles <- MsExperimentFiles(
        list(data = c(a = "a.txt", b = "b.txt"), annotation = "ann.txt"))
    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    res <- readObject(pth)
    expect_equal(res@experimentFiles, m@experimentFiles)

    ## Non-empty otherData
    m@otherData <- SimpleList(se = se, other = 1:4)
    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    res <- readObject(pth)
    expect_equal(names(res@otherData), names(m@otherData))
    expect_s4_class(res@otherData[[1L]], "SummarizedExperiment")
    expect_equal(dim(assay(res@otherData[[1L]])), dim(assay(se)))
    expect_equal(as.numeric(assay(res@otherData[[1L]])), as.numeric(assay(se)))
})

test_that("saveMsObject,MsExperiment,AlabasterParam works", {
    expect_error(saveMsObject(MsExperiment(), AlabasterParam(tempdir())),
                 "Overwriting")
    pth <- file.path(tempdir(), "ms_experiment_alabaster")
    if (file.exists(pth))
        unlink(pth, recursive = TRUE)

    fl <- system.file('cdf/KO/ko15.CDF', package = "faahKO")
    fl_new <- tempfile()
    file.copy(fl, fl_new)
    m <- readMsExperiment(
        fl_new, sampleData = data.frame(name = "a", index = 1))
    saveMsObject(m, AlabasterParam(pth))
    ## move the data file to a new location.
    d_new <- file.path(tempdir(), "temp_file_location")
    dir.create(d_new, recursive = TRUE)
    file.copy(fl_new, file.path(d_new, basename(fl_new)))
    unlink(fl_new)
    expect_error(validObject(m@spectra@backend), "not found")
    expect_error(readMsObject(MsExperiment(), AlabasterParam(pth)), "not found")
    m_in <- readMsObject(MsExperiment(), AlabasterParam(pth),
                         spectraPath = d_new)
    expect_s4_class(m_in, "MsExperiment")
    expect_equal(mz(spectra(m_in)[1:10]), mz(spectra(mse[1L])[1:10]))
})
