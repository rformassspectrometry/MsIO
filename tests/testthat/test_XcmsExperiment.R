library(xcms)

xmse <- loadXcmsData()
xmseg_filt <- filterMzRange(xmse, c(200, 500))
xmseg_filt <- filterRt(xmseg_filt, c(3000, 4000))


test_that("saveMsObject,readMsObject,PlainTextParam,XcmsExperiment works", {
    pth = file.path(tempdir(), "test_xcmsexp")
    param <- PlainTextParam(path = pth)
    saveMsObject(xmseg_filt, param = param)
    expect_true(dir.exists(pth))
    expect_true(file.exists(
        file.path(param@path, "ms_experiment_sample_data.txt")))
    expect_true(file.exists(
        file.path(param@path, "ms_backend_data.txt")))
    expect_true(file.exists(
        file.path(param@path, "spectra_slots.txt")))
    expect_true(file.exists(
        file.path(param@path, "spectra_processing_queue.json")))
    expect_true(file.exists(
        file.path(param@path, "xcms_experiment_process_history.json")))
    expect_true(file.exists(
        file.path(param@path, "xcms_experiment_chrom_peaks.txt")))
    expect_true(file.exists(
        file.path(param@path, "xcms_experiment_chrom_peak_data.txt")))
    expect_true(file.exists(
        file.path(param@path, "xcms_experiment_feature_definitions.txt")))
    expect_true(file.exists(
        file.path(param@path, "xcms_experiment_feature_peak_index.txt")))

    ## load data again
    ## This error is not thrown with rcmdcheck::rcmdcheck()
    ## expect_error(readMsObject(new("XcmsExperiment"), param), "load the library")
    ## library(Spectra)
    load_xmse <- readMsObject(new("XcmsExperiment"), param)
    expect_true(inherits(load_xmse, "XcmsExperiment"))
    expect_equal(xmseg_filt@featureDefinitions,
                 load_xmse@featureDefinitions)
    expect_equal(featureValues(xmseg_filt), featureValues(load_xmse))
    expect_equal(adjustedRtime(xmseg_filt), adjustedRtime(load_xmse))
    expect_no_error(filterRt(load_xmse, c(3000, 3500)))
    expect_equal(xmseg_filt@chromPeaks, load_xmse@chromPeaks)
    expect_equal(xmseg_filt@chromPeakData, load_xmse@chromPeakData)
    expect_equal(xmseg_filt@sampleData, load_xmse@sampleData)
    expect_equal(length(xmseg_filt@processHistory), length(load_xmse@processHistory))
    expect_equal(xmseg_filt@processHistory[[1L]], load_xmse@processHistory[[1L]])
    expect_equal(xmseg_filt@processHistory[[2L]], load_xmse@processHistory[[2L]])
    expect_equal(xmseg_filt@processHistory[[3L]], load_xmse@processHistory[[3L]])
    expect_equal(xmseg_filt@processHistory[[4L]], load_xmse@processHistory[[4L]])
    expect_equal(xmseg_filt@processHistory[[5L]], load_xmse@processHistory[[5L]])
    ## The 6th param object contains functions for which the comparison fails
    ## because of the name/namespace mentioned. See e.g.
    ## xmseg_filt@processHistory[[6]]@param load_xmse@processHistory[[6]]@param

    ## Check the spectraPath parameter.
    bp <- dataStorageBasePath(xmseg_filt@spectra)
    ## manually change dataStorage path of backend
    sd <- read.table(file.path(param@path, "ms_backend_data.txt"),
                     header = TRUE)
    sd$dataStorage <- sub("faahKO", "other", sd$dataStorage)
    writeLines(
        "# MsBackendMzR", con = file.path(param@path, "ms_backend_data.txt"))
    write.table(sd,
                file = file.path(param@path, "ms_backend_data.txt"),
                sep = "\t", quote = TRUE, append = TRUE)
    expect_error(readMsObject(new("XcmsExperiment"), param), "invalid class")
    expect_no_error(readMsObject(XcmsExperiment(),
                                 param, spectraPath = bp))

    param <- PlainTextParam(tempdir())
    expect_error(readMsObject(XcmsExperiment(), param),
                 "No 'ms_experiment_sample_data")

    ## Export an empty object.
    a <- XcmsExperiment()
    pth = file.path(tempdir(), "test_xcmsexp_empty")
    param <- PlainTextParam(path = pth)
    saveMsObject(a, param)
    res <- readMsObject(XcmsExperiment(), param)
    expect_equal(nrow(chromPeaks(a)), nrow(chromPeaks(res)))
    expect_equal(colnames(chromPeaks(a)), colnames(chromPeaks(res)))
    expect_equal(nrow(chromPeakData(a)), nrow(chromPeakData(res)))
    expect_equal(colnames(chromPeakData(a)), colnames(chromPeakData(res)))
    expect_equal(a@featureDefinitions, res@featureDefinitions)
    expect_equal(a@processHistory, res@processHistory)
})
