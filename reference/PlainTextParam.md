# Store contents of MS objects as plain text files

The
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
methods with the `PlainTextParam` option enable users to save/load
different type of mass spectrometry (MS) object as a collections of
plain text files in/from a specified folder. This folder, defined with
the `path` parameter, will be created by the `storeResults()` function.
Writing data to a folder that contains already exported data will result
in an error.

All data is exported to plain text files, where possible as tabulator
delimited text files. Data is exported using R's
[`write.table()`](https://rdrr.io/r/utils/write.table.html) function,
thus, the text files will also contain row names (first column) as well
as column names (header). Strings in the text files are quoted. Some
information, in particular the content of *parameter* classes within the
objects, is stored in JSON format instead.

The MS object currently supported for import and export with this
parameter are:

- `MsBackendMzR` object, defined in the
  [*Spectra*](https://bioconductor.org/packages/Spectra) package.

- `MsBackendMetaboLights` object, defined in the
  [*MsBackendMetaboLights*](https://bioconductor.org/packages/MsBackendMetaboLights)
  package.

- `Spectra` object, defined in the
  [*Spectra*](https://bioconductor.org/packages/Spectra) package.

- `MsExperiment` object, defined in the
  [*MsExperiment*](https://bioconductor.org/packages/MsExperiment)
  package.

- `XcmsExperiment` object, defined in the
  [*xcms*](https://bioconductor.org/packages/xcms) package.

See their respective section below for details and formats of the
exported files.

## Usage

``` r
PlainTextParam(path = tempdir())

# S4 method for class 'MsBackendMetaboLights,PlainTextParam'
readMsObject(object, param, offline = FALSE)

# S4 method for class 'MsBackendMzR,PlainTextParam'
saveMsObject(object, param)

# S4 method for class 'MsBackendMzR,PlainTextParam'
readMsObject(object, param, spectraPath = character())

# S4 method for class 'MsExperiment,PlainTextParam'
saveMsObject(object, param)

# S4 method for class 'MsExperiment,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'Spectra,PlainTextParam'
saveMsObject(object, param)

# S4 method for class 'Spectra,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'XcmsExperiment,PlainTextParam'
saveMsObject(object, param)

# S4 method for class 'XcmsExperiment,PlainTextParam'
readMsObject(object, param, ...)
```

## Arguments

- path:

  For `PlainTextParam()`: `character(1)`, defining where the files are
  going to be stored/ should be loaded from. The default is
  `path = tempdir()`.

- object:

  for
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md):
  the MS data object to save, for
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md):
  the MS data object that should be returned

- param:

  an object defining and (eventually configuring) the file format and
  file name or directory to/from which the data object should be
  exported/imported.

- offline:

  For
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  to load MS data as a `MsBackendMetaboLights()`: `logical(1)` to
  evaluate **only** the local file cache. Thus `offline = TRUE` does not
  need an active internet connection, but fails if one of more files are
  not cached locally.

- spectraPath:

  For
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md):
  `character(1)` optionally allowing to define the (absolute) path where
  the spectra files (*data storage files*) can be found. This parameter
  is used for `MsBackendMzR` (see descriptions below) and can be passed
  through `...` also to
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  functions for other classes (such as `Spectra`, `MsExperiment` etc).

- ...:

  Additional parameters passed down to internal functions. E.g.
  parameter `spectraPath` (see above).

## Value

For `PlainTextParam()`: a `PlainTextParam` class.
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
does not return anything but saves the object to collections of
different plain text files to a folder. The
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
method returns the restored data as an instance of the class specified
with parameter `object`.

## On-disk storage for `MsBackendMzR` objects

For `MsBackendMzR` objects, defined in the `Spectra` package, the
following file is stored:

- The backend's
  [`spectraData()`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)
  is stored in a tabular format in a text file named
  *ms_backend_data.txt*. Each row of this tab-delimited text file
  corresponds to a spectrum with its respective metadata in the columns.

## On-disk storage for `MsBackendMetaboLights` objects

The `MsBackendMetaboLights` extends the `MsBackendMzR` backend and hence
the same files are stored. When a `MsBackendMetaboLights` object is
restored, the `mtbls_sync()` function is called to check for presence of
all MS data files and, if missing, re-download them from the
*MetaboLights* repository.

## On-disk storage for `Spectra` objects

For `Spectra` objects, defined in the `Spectra` package, the files
listed below are stored. Any parameter passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
method using its `...` parameter are passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
call of the `Spectra`'s backend.

- The `processingQueueVariables`, `processing`,
  [`processingChunkSize()`](https://rdrr.io/pkg/ProtGenerics/man/processingQueue.html),
  and `backend` class information of the object are stored in a text
  file named *spectra_slots.txt*. Each of these slots is stored such
  that the name of the slot is written, followed by "=" and the content
  of the slot.

- The processing queue of the `Spectra` object, ensuring that any
  spectra data modifications are retained, is stored in a `json` file
  named *spectra_processing_queue.json*. The file is written such that
  each processing step is separated by a line and includes all
  information about the parameters and functions used for the step.

- The `Spectra`'s MS data (i.e. it's backend) is stored/exported using
  the
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  method of the respective backend type. Currently only backends for
  which the
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  method is implemented (see above) are supported.

## On-disk storage for `MsExperiment` objects

For `MsExperiment` objects, defined in the `MsExperiment` package, the
exported data and related text files are listed below. Any parameter
passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
through `...` are passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
calls of the individual MS data object(s) within the `MsExperiment`.

Note that at present
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
with `PlainTextParam` does **not** export the full content of the
`MsExperiment`, i.e. slots `@experimentFiles`, `@qdata`, `@otherData`
and `@metadata` are currently not saved.

- The
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  is stored as a text file named *ms_experiment_sample_data.txt*. Each
  row of this file corresponds to a sample with its respective metadata
  in the columns.

- The links between the sample data and any other data within the
  `MsExperiment` are stored in text files named
  *ms_experiment_sample_data_links\_....txt*, with "..." referring to
  the data slot to which samples are linked. Each file contains the
  mapping between the sample data and the elements in a specific data
  slot (e.g., `Spectra`). The files are tabulator delimited text files
  with two columns of integer values, the first representing the index
  of a sample in the objects
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html),
  the second the index of the assigned element in the respective object
  slot. The table "ms_experiment_element_metadata.txt" contains the
  metadata of each of the available mappings.

- If the `MsExperiment` contains a `Spectra` object with MS data, it's
  content is exported to the same folder using a
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  call on it (see above for details of exporting `Spectra` objects to
  text files).

## On-disk storage for `XcmsExperiment` objects

For `XcmsExperiment` objects, defined in the *xcms* package, the
exported data and related text files are listed below. Any parameter
passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
through `...` are passed to the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
calls of the individual MS data object(s) within the `XcmsExperiment`.

- The chromatographic peak information obtained with
  [`chromPeaks()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html) and
  `chromPeaksData()` is stored in tabular format in the text files
  *xcms_experiment_chrom_peaks.txt* and
  *xcms_experiment_chrom_peak_data.txt*, respectively. The first file's
  rows represent single peaks with their respective metadata in the
  columns (only numeric information). The second file contains arbitrary
  additional information/metadata for each peak (each row being one
  chrom peak).

- The
  [`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
  are stored in a text file named
  *xcms_experiment_feature_definitions.txt*. Additionally, a second file
  named *ms_experiment_feature_peak_index.txt* is generated to connect
  the features with the corresponding chromatographic peaks. Each row of
  the first file corresponds to a feature with its respective metadata
  in the columns. The second file contains the mapping between features
  and chromatographic peaks (one peak ID per row).

- The
  [`processHistory()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
  information of the object is stored to a file named
  *xcms_experiment_process_history.json* in JSON format.

- The `XcmsExperiment` directly extends the `MsExperiment` class, thus,
  any MS data is saved using a call to the `saveMsObject` of the
  `MsExperiment` (see above for more information).

## See also

Other MS object export and import formats.:
[`AlabasterParam`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md),
[`mzTabParam`](https://rformassspectrometry.github.io/MsIO/reference/mzTabParam.md)

## Author

Philippine Louail

## Examples

``` r

## Export and import a `Spectra` object:

library(Spectra)
library(msdata)
fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")
sps <- Spectra(fl)

## Export the object to a temporary directory
d <- file.path(tempdir(), "spectra_example")
saveMsObject(sps, PlainTextParam(d))

## List the exported plain text files:
dir(d)
#>  [1] "OBJECT"                        "_environment.json"            
#>  [3] "backend"                       "metadata"                     
#>  [5] "ms_backend_data.txt"           "processing"                   
#>  [7] "processing_chunk_size"         "processing_queue_variables"   
#>  [9] "spectra_processing_queue.json" "spectra_slots.txt"            

## - ms_backend_data.txt contains the metadata for the MS backend used (a
##   'MsBackendMzR`.
## - spectra_slots.txt contains general information from the Spectra object.

## Import the data again. By using `Spectra()` as first parameter we ensure
## the result is returned as a `Spectra` object.
sps_in <- readMsObject(Spectra(), PlainTextParam(d))
#> backend MsBackendMzR
sps_in
#> MSn data (Spectra) with 7602 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.231         1
#> 2            1     0.351         2
#> 3            1     0.471         3
#> 4            1     0.591         4
#> 5            1     0.711         5
#> ...        ...       ...       ...
#> 7598         1   899.491      7598
#> 7599         1   899.613      7599
#> 7600         1   899.747      7600
#> 7601         1   899.872      7601
#> 7602         1   899.993      7602
#>  ... 27 more variables/columns.
#> 
#> file(s):
#> PestMix1_DDA.mzML

## Check that the data is the same
all.equal(rtime(sps), rtime(sps_in))
#> [1] TRUE
all.equal(intensity(sps), intensity(sps_in))
#> [1] TRUE

## The data got exported *by module*, thus we could also load only a part of
## the exported data, such as just the `MsBackend` used by the `Spectra`:
be <- readMsObject(MsBackendMzR(), PlainTextParam(d))
be
#> MsBackendMzR with 7602 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.231         1
#> 2            1     0.351         2
#> 3            1     0.471         3
#> 4            1     0.591         4
#> 5            1     0.711         5
#> ...        ...       ...       ...
#> 7598         1   899.491      7598
#> 7599         1   899.613      7599
#> 7600         1   899.747      7600
#> 7601         1   899.872      7601
#> 7602         1   899.993      7602
#>  ... 27 more variables/columns.
#> 
#> file(s):
#> PestMix1_DDA.mzML

## The export functionality also ensures that the data/object can be
## completely restored, i.e., for `Spectra` objects also their
## *processing queue* is preserved/stored. To show this we below first
## filter the spectra object by retention time and m/z:

sps_filt <- sps |>
    filterRt(c(400, 600)) |>
    filterMzRange(c(200, 300))
## The filtered object has less spectra
length(sps_filt)
#> [1] 2054
length(sps)
#> [1] 7602
## And also less mass peaks per spectrum
lengths(sps_filt[1:3])
#> [1]   0   0 101
lengths(sps[1:3])
#> [1] 223 211 227

d <- file.path(tempdir(), "spectra_example2")
saveMsObject(sps_filt, PlainTextParam(d))

## The directory contains now an additional file with the processing
## queue of the `Spectra`.
dir(d)
#> [1] "ms_backend_data.txt"           "spectra_processing_queue.json"
#> [3] "spectra_slots.txt"            

## Restoring the object again.
sps_in <- readMsObject(Spectra(), PlainTextParam(d))
#> backend MsBackendMzR

## Both objects have the same processing history
sps_filt
#> MSn data (Spectra) with 2054 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            2   400.088      3242
#> 2            2   400.208      3243
#> 3            1   400.346      3244
#> 4            2   400.498      3245
#> 5            2   400.618      3246
#> ...        ...       ...       ...
#> 2050         2   599.253      5291
#> 2051         2   599.373      5292
#> 2052         1   599.511      5293
#> 2053         1   599.636      5294
#> 2054         2   599.904      5295
#>  ... 34 more variables/columns.
#> 
#> file(s):
#> PestMix1_DDA.mzML
#> Lazy evaluation queue: 1 processing step(s)
#> Processing:
#>  Filter: select retention time [400..600] on MS level(s)  [Wed Nov  5 06:55:37 2025]
#>  Filter: select peaks with an m/z within [200, 300] [Wed Nov  5 06:55:37 2025] 
sps_in
#> MSn data (Spectra) with 2054 spectra in a MsBackendMzR backend:
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            2   400.088      3242
#> 2            2   400.208      3243
#> 3            1   400.346      3244
#> 4            2   400.498      3245
#> 5            2   400.618      3246
#> ...        ...       ...       ...
#> 2050         2   599.253      5291
#> 2051         2   599.373      5292
#> 2052         1   599.511      5293
#> 2053         1   599.636      5294
#> 2054         2   599.904      5295
#>  ... 27 more variables/columns.
#> 
#> file(s):
#> PestMix1_DDA.mzML
#> Lazy evaluation queue: 1 processing step(s)
#> Processing:
#>  Filter: select retention time [400..600] on MS level(s)  [Wed Nov  5 06:55:37 2025]
#>  Filter: select peaks with an m/z within [200, 300] [Wed Nov  5 06:55:37 2025] 

## Same number of spectra
length(sps_filt)
#> [1] 2054
length(sps_in)
#> [1] 2054

## Same number of mass peaks (after filtering)
lengths(sps_filt[1:3])
#> [1]   0   0 101
lengths(sps_in[1:3])
#> [1]   0   0 101
```
