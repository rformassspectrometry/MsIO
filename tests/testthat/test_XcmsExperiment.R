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

    with_mock(
        "MsIO:::.is_alabaster_matrix_installed" = function() FALSE,
        expect_error(saveObject(XcmsExperiment(), pth), "alabaster.matrix'")
    )
    with_mock(
        "MsIO:::.is_xcms_installed" = function() FALSE,
        expect_error(readAlabasterXcmsExperiment(pth), "xcms'")
    )
    with_mock(
        "MsIO:::.is_ms_experiment_installed" = function() FALSE,
        expect_error(readAlabasterXcmsExperiment(pth), "MsExperiment'")
    )

    ## Empty object.
    m <- XcmsExperiment()
    saveObject(m, pth)
    expect_true(all(c("sample_data", "sample_data_links",
                      "sample_data_links_mcols", "metadata",
                      "experiment_files", "other_data", "chrom_peaks",
                      "chrom_peak_data", "feature_definitions") %in% dir(pth)))
    expect_true(!any(dir(pth) %in% c("spectra", "qdata")))
    expect_silent(validateAlabasterXcmsExperiment(pth))
    res <- readAlabasterXcmsExperiment(pth)
    expect_equal(res, m)

    ## Real object
    m <- xmseg_filt
    expect_error(saveObject(m, pth), "existing path")

    unlink(pth, recursive = TRUE)
    saveObject(m, pth)
    expect_silent(validateAlabasterXcmsExperiment(pth))
    res <- readAlabasterXcmsExperiment(pth)
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
    fl <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
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

test_that(".import_chrom_peaks works", {
    pth <- tempdir()
    expect_error(.import_chrom_peaks(xcmse, pth), "chrom_peaks.txt")
    write.table(chromPeaks(xmse),
                file = file.path(pth, "xcms_experiment_chrom_peaks.txt"),
                sep = "\t")
    expect_error(.import_chrom_peaks(xmse, pth),
                 "chrom_peak_data.txt")
    file.remove(file.path(pth, "xcms_experiment_chrom_peaks.txt"))
})

test_that(".import_features works", {
    pth <- tempdir()
    write.table(
        featureDefinitions(xmse)[, 1:8],
        file = file.path(pth, "xcms_experiment_feature_definitions.txt"),
        sep = "\t")
    expect_error(.import_features(xmse, pth), "feature_peak_index.txt")
})

test_that(".import_process_history works", {
    pth <- tempdir()
    expect_error(.import_process_history(xmse, pth), "process_history.json")
})

test_that("saveMsObject,mzTabParam works", {
    faahko <- loadXcmsData("faahko_sub2")
    faahko <- groupChromPeaks(
        faahko, PeakDensityParam(sampleGroups = rep(1, length(faahko))))

    d <- file.path(tempdir(), "mzt_test")
    dir.create(d, recursive = TRUE)

    ## errors
    expect_error(
        saveMsObject(faahko, mzTabParam(studyId = "test_study", path = d,
                                        sampleDataColumn = "sample_name")),
        "has to correspond to column names of the sampleData()")
    expect_error(saveMsObject(
        faahko, mzTabParam(studyId = "test_study", path = d,
                           sampleDataColumn = c("sample_name","sample_index"))),
        "has to correspond to column names of the sampleData()")
    expect_error(
        saveMsObject(faahko, mzTabParam(studyId = "test_study", path = d,
                                        sampleDataColumn = "sample_index",
                                        optionalFeatureColumns = "other")),
        "'optionalFeatureColumns' have to correspond")
    expect_error(saveMsObject(
        faahko, mzTabParam(studyId = "test_study", path = d,
                           sampleDataColumn = c("sample_index"),
                           optionalFeatureColumns = c("mzmed", "mzmin", "a"))),
        "'optionalFeatureColumns' have to correspond")

    p <- mzTabParam(studyId = "test_study", path = d,
                    sampleDataColumn = "sample_index",
                    optionalFeatureColumns = "peakidx")
    saveMsObject(faahko, p)
    expect_true(file.exists(file.path(d, "test_study.mztab")))
    res <- readLines(file.path(d, "test_study.mztab"))
    expect_true(length(res) > 0L)
    expect_true(length(grep("^MTD", res)) > 0)
    expect_true(length(grep("^SML", res)) > 0)
    expect_true(length(grep("^SMF", res)) > 0)
    ## Check for empty lines
    expect_true(length(grep(c("^MTD|SML|SMF"), res, invert = TRUE)) == 2)

    expect_error(
        saveMsObject(faahko, p), "File \"test_study.mztab\" already exists")

    unlink(d, recursive = TRUE)
})
