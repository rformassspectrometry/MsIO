# Changelog

## Version 0.0

### Changes in 0.0.11

- Fix error message/check for
  [`mzTabParam()`](https://rformassspectrometry.github.io/MsIO/reference/mzTabParam.md)
  export of `XcmsExperiment`.
- Use the internal `.retry()` function from *MsBackendMetaboLights* to
  retry downloading from EBI’s ftp server.
- Avoid duplicated export of `"mzmed"`, `"rtmin"`, `"rtmed"` and
  `"rtmax"` `featureData()` columns in mzTab-M export.
- Fix definition of *study_variables* for the SML array in mzTab-M
  export.

### Changes in 0.0.10

- Re-use the
  [`Spectra::dataStorageBasePath()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
  method to update/set the base path to the data storage files to read
  `MsBackendMzR` objects. This fixes a bug in
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  for
  [`AlabasterParam()`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md):
  if the saved object has backslash in the paths to the raw file, the
  `spectraPath` replacment does not work as intended in Linux system.
  [issue](https://github.com/rformassspectrometry/MsIO/issues/30)
  [\#30](https://github.com/RforMassSpectrometry/MsIO/issues/30)
- Ensure SampleData rownames are retained in
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  for `PlainTextParam`.

### Changes in 0.0.9

- Fix bug in
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  for `MetaboLightsParam`: mapping between samples and spectra could
  fail for some MetaboLights data set if a `filePattern` was defined.

### Changes in 0.0.8

- Fix bug in
  [`readObject()`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md)
  for `MsBackendMetaboLights` that would not update/fix the local path
  to the cached data files.

### Changes in 0.0.7

- Add `saveObject()` for `MsBackendMetaboLights`.

### Changes in 0.0.6

- Expand unit tests.

### Changes in 0.0.5

- Add *MetaboLights*
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  method for `MsExpriment()` objects.

### Changes in 0.0.4

- Add *alabaster* `saveObject()` and
  [`readObject()`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md)
  methods as well as
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  and
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  methods with `AlabasterParam` param for `MsBackendMzR`, `Spectra`,
  `MsExperiment` and `XcmsExperiment` objects.

### Changes in 0.0.3

- Implement
  [`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  and
  [`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
  with `PlainTextParam` for `MsBackendMzR`, `Spectra`, `MsExperiment`
  and `XcmsExperiment`.

### Changes in 0.0.2

- Refactor code for text-based import and export of MS data objects.
