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
    pth <- file.path( "test_MsExperiment")
    param <- PlainTextParam(path = pth)
    saveMsObject(mse_filt, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(file.path(param@path, "sample_data.txt")))
    expect_true(file.exists(file.path(param@path, "backend_data.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_slots.txt")))
    expect_true(file.exists(file.path(param@path, "spectra_processing_queue.json")))
    pattern <- "sample_data_links_.*\\.txt"
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
    expect_no_error(filterRt(load_mse, c(3000, 3500)))

    ## Check the spectraPath parameter.
    bp <- dataStorageBasePath(mse_filt@spectra)
    ## manually change dataStorage path of backend
    sd <- read.table(file.path(param@path, "backend_data.txt"), header = TRUE)
    sd$dataStorage <- sub("faahKO", "other", sd$dataStorage)
    writeLines("# MsBackendMzR", con = file.path(param@path, "backend_data.txt"))
    write.table(sd,
                file = file.path(param@path, "backend_data.txt"),
                sep = "\t", quote = FALSE,
                append = TRUE, row.names = FALSE)
    expect_error(readMsObject(MsExperiment(), param), "invalid class")
    expect_no_error(readMsObject(MsExperiment(), param, spectraPath = bp))

    param <- PlainTextParam(tempdir())
    expect_error(readMsObject(MsExperiment(), param), "No 'sample_data")
})
