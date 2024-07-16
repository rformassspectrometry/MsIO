library(Spectra)

test_that("saveMsObject,MsBackend,ANY fails", {
    be <- MsBackendMemory()
    expect_error(saveMsObject(be, param = "A"),
                 "objects of class 'MsBackendMemory'")
})

test_that("readMsObject,MsBackend,ANY fails", {
    be <- MsBackendMemory()
    expect_error(readMsObject(be, param = "A"),
                 "objects of class 'MsBackendMemory'")
})
