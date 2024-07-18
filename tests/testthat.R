library(testthat)
library(Spectra)
library(MsExperiment)
library(faahKO)
library(MsIO)

# BackendMzR object
sciex_file <- normalizePath(
    dir(system.file("sciex", package = "msdata"), full.names = TRUE))
sciex_mzr <- backendInitialize(MsBackendMzR(), files = sciex_file)

# Spectra object
fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML",
                  package = "msdata")
sps_dda <- Spectra(fl)
## add processingQueueVariables to test export
sps_dda@processingQueueVariables <- c(sps_dda@processingQueueVariables, "rtime")
sps_dda <- filterMzRange(sps_dda, c(200,300))
sps_dda <- filterRt(sps_dda, c(200, 700)) ## to ensure subsetted object would work

# MsExperiment object (any easier way ?)
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

test_check("MsIO")
