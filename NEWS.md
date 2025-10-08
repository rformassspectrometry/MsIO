# Version 0.0

## Changes in 0.0.10

- Re-use the `Spectra::dataStorageBasePath()` method to update/set the base path
  to the data storage files to read `MsBackendMzR` objects.

## Changes in 0.0.9

- Fix bug in `readMsObject()` for `MetaboLightsParam`: mapping between samples
  and spectra could fail for some MetaboLights data set if a `filePattern`
  was defined.

## Changes in 0.0.8

- Fix bug in `readObject()` for `MsBackendMetaboLights` that would not
  update/fix the local path to the cached data files.

## Changes in 0.0.7

- Add `saveObject()` for `MsBackendMetaboLights`.

## Changes in 0.0.6

- Expand unit tests.

## Changes in 0.0.5

- Add *MetaboLights* `readMsObject()` method for `MsExpriment()` objects.

## Changes in 0.0.4

- Add *alabaster* `saveObject()` and `readObject()` methods as well as
  `saveMsObject()` and `readMsObject()` methods with `AlabasterParam` param for
  `MsBackendMzR`, `Spectra`, `MsExperiment` and `XcmsExperiment` objects.

## Changes in 0.0.3

- Implement `saveMsObject()` and `readMsObject()` with `PlainTextParam` for
  `MsBackendMzR`, `Spectra`, `MsExperiment` and `XcmsExperiment`.

## Changes in 0.0.2

- Refactor code for text-based import and export of MS data objects.
