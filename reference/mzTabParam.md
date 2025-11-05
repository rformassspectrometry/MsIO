# Store xcms preprocessing results to a file in mzTab-M format

The
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
methods with the `mzTabParam` option enable users to save/load
`XcmsExperiment` objects in Mz-Tab-m file format. Mainly the metadata
(MTD) and Small molecule feature (SMF) tables will represent the
`XcmsExperiment`. More specifically,
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
of the object will be stored in the metadata section (MTD) along with
the user-inputed `studyId` and `polarity`. The
[`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
will be stored in the small molecule feature (SMF) section but by
default only the `mzmed`, `rtmed`, `rtmin` and `rtmax` are exported.
More info avaialble in
[`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
can be exported by specifying the `optionalFeatureColumns` parameter.
The
[`featureValues()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-peak-grouping-results.html)
will also be stored in the small molecule feature (SMF) section.

The small molecule summary section (SML) will be filled with `null`
values as no annotation and identification of compound is performed in
`xcms`.

Writing data to a folder that contains already exported data will result
in an error.

## Usage

``` r
mzTabParam(
  studyId = character(),
  polarity = c("positive", "negative"),
  sampleDataColumn = character(),
  path = tempdir(),
  optionalFeatureColumns = character(),
  ...
)

# S4 method for class 'XcmsExperiment,mzTabParam'
saveMsObject(object, param)
```

## Arguments

- studyId:

  `character(1)` Will be both the `filename` of the object saved in
  mzTab-M format and the `mzTab-ID` in the file.

- polarity:

  `character(1)` Describes the polarity of the experiment. Two inputs
  are possible, "positive" (default) or "negative".

- sampleDataColumn:

  `character` with the column name(s) of the
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  of the `XcmsExperiment` object that should be exported to the mzTab-M
  file. Defaults to `sampleDataColumn = character()`. At least one
  column in
  [`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
  has to be specified.

- path:

  `character(1)` Define where the file is going to be stored. The
  default is `path = tempdir()`.

- optionalFeatureColumns:

  `character` with optional column names from
  [`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
  that should be exported. Defaults to
  `optionalFeatureColumns = character()`. Feature columns `"mzmed"`,
  `"rtmed"`, `"rtmin"` and `"rtmax"` are always exported.

- ...:

  additional optional arguments. See documentation of respective method
  for more information.

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

## Slots

- `dots`:

  Correspond to any optional parameters to be passed to the
  [`featureValues()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-peak-grouping-results.html)
  function. (e.g. parameters `method` or `value`).

## Note

This function was build so that the output fit the recommendation of
mzTab-M file format version 2.0. These can be found
[here](http://hupo-psi.github.io/mzTab/2_0-metabolomics-release/mzTab_format_specification_2_0-M_release.md).

## References

Hoffmann N, Rein J, Sachsenberg T, Hartler J, Haug K, Mayer G, Alka O,
Dayalan S, Pearce JTM, Rocca-Serra P, Qi D, Eisenacher M, Perez-Riverol
Y, Vizcaino JA, Salek RM, Neumann S, Jones AR. mzTab-M: A Data Standard
for Sharing Quantitative Results in Mass Spectrometry Metabolomics. Anal
Chem. 2019 Mar 5;91(5):3302-3310. doi: 10.1021/acs.analchem.8b04310.
Epub 2019 Feb 13. PMID: 30688441; PMCID: PMC6660005.

## See also

Other MS object export and import formats.:
[`AlabasterParam`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md),
[`PlainTextParam`](https://rformassspectrometry.github.io/MsIO/reference/PlainTextParam.md)

## Author

Philippine Louail, Johannes Rainer

## Examples

``` r
## Load a test data set with detected peaks, of class `XcmsExperiment`
library(xcms)
test_xcms <- loadXcmsData()

## Define param
param <- mzTabParam(studyId = "test",
                    polarity = "positive",
                    sampleDataColumn = "sample_type")

## Save as a mzTab-M file
saveMsObject(test_xcms, param)
```
