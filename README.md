# MsIO

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)  
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsIO/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsIO/actions?query=workflow%3AR-CMD-check-bioc)  
[![codecov](https://codecov.io/gh/rformassspectrometry/MsIO/graph/badge.svg?token=M4yYzef5mK)](https://codecov.io/gh/rformassspectrometry/MsIO)  
[![:name status badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)  
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)

---

## Overview

**MsIO** provides flexible, language-agnostic import and export capabilities for mass spectrometry (MS) data objects in R. It facilitates interoperability by supporting various open file formats such as JSON, HDF5, plain text, and domain-specific standards like **mzTab-M** or **MetaboLights** archives.

While R’s native `save()`/`load()` functions allow object serialization, they rely on R-specific binary formats, making cross-platform data exchange difficult. **MsIO** addresses this by introducing standardized file formats and programmatic interfaces, simplifying integration between R-based tools and external software ecosystems.

---

## Key Features

- 📦 Export/import **MS data objects** across interoperable file formats  
- 🧩 Modular design via S4 **parameter classes** and generic methods  
- 🔄 Integration with [Bioconductor](https://bioconductor.org) packages like **Spectra**, **MsExperiment**, **xcms**, and **alabaster.base**  
- 🔧 Support for plain text, JSON+HDF5, mzTab-M, and MetaboLights repository data

---

## Package Architecture

### Generic Methods

- `saveMsObject(object, param)`  
- `readMsObject(object, param)`

These methods delegate the actual file handling based on the class of the supplied `param` object (e.g., `PlainTextParam`, `AlabasterParam`).

### Parameter Classes

Each format is encapsulated in a dedicated S4 class:

| Class               | Purpose                                  |
|---------------------|------------------------------------------|
| `PlainTextParam`     | Text-based tabular storage               |
| `AlabasterParam`     | HDF5/JSON archival via alabaster         |
| `mzTabParam`         | Export to mzTab-M (MS metabolomics)      |
| `MetaboLightsParam`  | Import from MetaboLights repository      |

Corresponding logic is implemented in dedicated `R/` files (e.g. `XcmsExperiment.R`, `Spectra.R`), with new formats expected to follow the same structure.

---

## Supported Formats

### ✅ Plain Text (`PlainTextParam`)
- Tab-delimited export/import for key objects:
  - `MsBackendMzR`, `Spectra` (from [Spectra](https://github.com/RforMassSpectrometry/Spectra))
  - `MsExperiment` (from [MsExperiment](https://github.com/RforMassSpectrometry/MsExperiment))
  - `XcmsExperiment` (from [xcms](https://github.com/sneumann/xcms))

### ✅ Alabaster (`AlabasterParam`)
- Structured archival using HDF5 and JSON (via [`alabaster.base`](https://doi.org/doi:10.18129/B9.bioc.alabaster.base))
- Compatible with `MsExperiment`, `Spectra`, `XcmsExperiment`, etc.

### ✅ mzTab-M Export (`mzTabParam`)
- Export of `XcmsExperiment` preprocessing results to **mzTab-M** (HUPO PSI metabolomics standard)

### ✅ MetaboLights (`MetaboLightsParam`)
- Import of complete experiments (including raw MS files) from [MetaboLights](https://www.ebi.ac.uk/metabolights/)

---

## Planned Features & Contributions Welcome

Future development directions include:

- 🔄 **Import mzTab-M** into `SummarizedExperiment`  
- 🔄 **Import mzTab-M** into `QFeatures`  
- 🔄 **Generic ISA-tab** import integration (if justified)

We welcome and encourage contributions — see below for how to get involved!

---

## Contributing

We appreciate contributions of all kinds — from bug fixes and tests to documentation and new format support.

If you're planning to contribute:

1. Read our [contribution guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions)
2. Follow the [RforMassSpectrometry style guide](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html)
3. Fork the repo, create a branch, implement your changes, and submit a pull request
4. For new formats, implement:
   - A `*Param` S4 class
   - A `readMsObject()` and/or `saveMsObject()` method
   - Tests in `tests/testthat/`
---

## License

This package is licensed under the **Artistic 2.0 License**:  
📄 [https://opensource.org/licenses/Artistic-2.0](https://opensource.org/licenses/Artistic-2.0)

Documentation (manuals, vignettes) is licensed under **CC BY-SA 4.0**:  
📄 [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/)
