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

test_that("saveObject,readObject,XcmsExperiment works", {
    pth <- file.path(tempdir(), "xcms_experiment_alabaster")

    ## Empty object.
    m <- XcmsExperiment()
    saveObject(m, pth)
    expect_true(all(c("sample_data", "sample_data_links",
                      "sample_data_links_mcols", "metadata",
                      "experiment_files", "other_data", "chrom_peaks",
                      "chrom_peak_data", "feature_definitions") %in% dir(pth)))
    expect_true(!any(dir(pth) %in% c("spectra", "qdata")))
    expect_silent(MsIO:::validateAlabasterXcmsExperiment(pth))
    res <- MsIO:::readAlabasterXcmsExperiment(pth)
    expect_equal(res, m)

    ## Real object
    m <- xmseg_filt
    expect_error(saveObject(m, pth), "existing path")

    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    expect_silent(MsIO:::validateAlabasterXcmsExperiment(pth))
    res <- MsIO:::readAlabasterXcmsExperiment(pth)
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(res@chromPeaks, m@chromPeaks)
    expect_equal(res@chromPeakData, m@chromPeakData)
    expect_equal(res@featureDefinitions, m@featureDefinitions)
    expect_equal(length(res@processHistory), length(m@processHistory))
    expect_equal(res@processHistory[[1L]], m@processHistory[[1L]])
    expect_equal(res@processHistory[[2L]], m@processHistory[[2L]])
    expect_equal(res@processHistory[[3L]], m@processHistory[[3L]])
    expect_equal(res@processHistory[[4L]], m@processHistory[[4L]])
    expect_equal(res@processHistory[[5L]], m@processHistory[[5L]])
    expect_equal(class(res@processHistory[[6L]]), class(m@processHistory[[6L]]))

    expect_equal(mz(spectra(res)[1:10]), mz(spectra(m)[1:10]))
})

test_that("saveMsObject,XcmsExperiment,AlabasterParam works", {
    expect_error(saveMsObject(XcmsExperiment(), AlabasterParam(tempdir())),
                 "Overwriting")
    pth <- file.path(tempdir(), "xcms_experiment_alabaster")
    if (file.exists(pth))
        unlink(pth, recursive = TRUE)

    ## Simulate moving data files.
    fl <- system.file('cdf/KO/ko15.CDF', package = "faahKO")
    fl_new <- tempfile()
    file.copy(fl, fl_new)
    library(MsExperiment)
    m <- readMsExperiment(
        fl_new, sampleData = data.frame(name = "a", index = 1))
    m <- findChromPeaks(m, param = CentWaveParam())
    expect_true(hasChromPeaks(m))
    saveMsObject(m, AlabasterParam(pth))
    ref <- readMsObject(XcmsExperiment(), AlabasterParam(pth))
    expect_equal(m, ref)

    ## move the data file to a new location.
    d_new <- file.path(tempdir(), "temp_file_location")
    dir.create(d_new, recursive = TRUE)
    file.copy(fl_new, file.path(d_new, basename(fl_new)))
    unlink(fl_new)
    expect_error(validObject(m@spectra@backend), "not found")

    expect_error(readMsObject(XcmsExperiment(),
                              AlabasterParam(pth)), "not found")
    m_in <- readMsObject(XcmsExperiment(), AlabasterParam(pth),
                         spectraPath = d_new)
    expect_s4_class(m_in, "XcmsExperiment")
    expect_equal(chromPeaks(m_in), chromPeaks(m))
    ## Check that access to MS data works
    expect_true(length(mz(spectra(m_in)[1L])) > 0)
})
