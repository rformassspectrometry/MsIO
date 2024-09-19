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

test_that(".clean_merged function works correctly", {
    tbc <- data.frame(
        Protocol_A = c(1, 2, 3),
        Term_B = c("ontology1", "ontology2", "ontology3"),
        Parameter_C = c(10, 20, 30),
        Term_D = c("ontology1", "ontology2", "ontology3"),
        Data_E = c(NA, NA, NA),
        Duplicate_F = c(1, 2, 3),
        stringsAsFactors = FALSE
    )
    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = TRUE,
                            simplify = FALSE)
    expect_equal(names(result), names(tbc))

    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = FALSE, simplify = FALSE)
    expect_equal(names(result), c("Protocol_A", "Parameter_C", "Data_E",
                                  "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE,
                            keepOntology = TRUE, simplify = FALSE)
    expect_equal(names(result), c("Term_B", "Term_D", "Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = FALSE)
    expect_equal(names(result), c("Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = TRUE, keepOntology = TRUE,
                            simplify = TRUE)
    expect_equal(names(result), c("Protocol_A", "Term_B", "Parameter_C"))


    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = TRUE)
    expect_equal(names(result), "Duplicate_F")
})


