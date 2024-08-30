library(MsExperiment)
test_that("Param is defined properly", {
    expect_error(MetaboLightsParam(studyId = ")Qn"), "must start")
    #study with only one assay: MTBLS10035
    param <- MetaboLightsParam(studyId = "MTBLS10035")
    expect_is(param, "MetaboLightsParam")
    res <- readMsObject(MsExperiment(), param)
    expect_is(res, "MsExperiment")
    expect_is(res@sampleData, "DataFrame")

    #also test a ID that does not work MTBLXXXX
    param_test <- MetaboLightsParam(studyId = "MTBLXXXX")
    expect_error(readMsObject(MsExperiment(), param_test), "No assay files")

    # testing interactive sesh
    mock_param <- MetaboLightsParam(studyId = "MTBLS8735")
    menu <- NULL
    with_mocked_bindings(
        menu = function(choices, title = NULL) { 2 },
        {
            result <- readMsObject(MsExperiment(), mock_param)
        }
    )
    expect_true(nrow(result@sampleData) == 10)
    expect_true(ncol(result@sampleData) == 44)
})
