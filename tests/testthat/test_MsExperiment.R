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
