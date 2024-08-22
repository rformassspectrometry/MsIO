test_that("saveObject,readObject,MsExperimentFiles works", {
    library(MsExperiment)
    a <- MsExperimentFiles()

    fl <- tempfile()
    saveObject(a, path = fl)
    expect_true(all(c("OBJECT", "x") %in% dir(fl)))
    expect_silent(MsIO:::validateAlabasterMsExperimentFiles(fl))
    res <- readAlabasterMsExperimentFiles(fl)
    expect_s4_class(res, "MsExperimentFiles")
    expect_equal(a, res)

    a <- MsExperimentFiles(list(some_file = "a.txt",
                                some_other_file = c("b.txt", "c.txt")))
    unlink(fl, recursive = TRUE)
    saveObject(a, path = fl)
    expect_silent(validateAlabasterMsExperimentFiles(fl))
    res <- readObject(fl)
    res <- readAlabasterMsExperimentFiles(fl)
    expect_s4_class(res, "MsExperimentFiles")
    expect_equal(a, res)
})
