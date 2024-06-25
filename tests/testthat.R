library(testthat)
library("Spectra")
library(MsIO)

# Backend object

sciex_file <- normalizePath(
    dir(system.file("sciex", package = "msdata"), full.names = TRUE))
sciex_mzr <- backendInitialize(MsBackendMzR(), files = sciex_file)

test_check("MsIO")
