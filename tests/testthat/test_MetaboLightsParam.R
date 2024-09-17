library(MsExperiment)
test_that("Object build properly", {
    expect_error(MetaboLightsParam(mtblsId = ")Qn"), "must start")
    ## Study with only one assay: MTBLS10035
    param <- MetaboLightsParam(mtblsId = "MTBLS39")
    expect_is(param, "MetaboLightsParam")
    res <- readMsObject(MsExperiment(), param)
    expect_is(res, "MsExperiment")
    expect_is(res@sampleData, "DataFrame")

    ## Test keepOntology and keepProtocol
    res_filtered <- readMsObject(MsExperiment(), param,
                                 keepOntology = FALSE,
                                 keepProtocol = FALSE)
    expect_lt(ncol(res_filtered@sampleData), ncol(res@sampleData))

    ## Test simplify flag removes columns with NAs and duplicated columns
    expect_true(all(colSums(is.na(res@sampleData)) != nrow(res@sampleData)))
    expect_true(any(duplicated(as.list(res@sampleData))) == FALSE)
})

test_that("interactive session works", {
    ## Testing interactive sesh
    mock_param <- MetaboLightsParam(mtblsId = "MTBLS575")
    menu <- NULL
    with_mocked_bindings(
        menu = function(choices, title = NULL) { 3 },
        {
            result <- readMsObject(MsExperiment(), mock_param)
        }
    )
    expect_true(nrow(result@sampleData) == 6)
    expect_true(ncol(result@sampleData) == 30)
})

