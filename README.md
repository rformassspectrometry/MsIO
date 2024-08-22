# MsIO

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsIO/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsIO/actions?query=workflow%3AR-CMD-check-bioc)
[![codecov](https://codecov.io/gh/rformassspectrometry/MsIO/graph/badge.svg?token=M4yYzef5mK)](https://codecov.io/gh/rformassspectrometry/MsIO)
[![:name status badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)


The *MsIO* package supports serializing and restoring/importing mass
spectrometry (MS) data objects to and from language agnostic file
formats. Ultimately, this package aims at enabling an easier exchange of data
and results between different software tools and programming languages.

R provides with the `save()` and `load()` functions a possibility to serialize
(and later import) variables and objects to disk, but the data is stored in a
R-specific binary format which is not easily readable by other programming
languages or software tools. Exchange of data and results between programming
languages and tools is however important to avoid the need to re-implement
methodology and algorithms and make the most of existing software to create
powerful analysis workflow.

The *MsIO* package defines generic export/import methods along with *parameter*
objects that allow to select and configure the file format(s). Where possible,
it is integrated with other approaches in
[Bioconductor](https://bioconductor.org) such as the
[*alabaster.base*](https://doi.org/doi:10.18129/B9.bioc.alabaster.base)
package. In particular *MsIO* will integrate with *alabaster.base* providing
`saveObject()` methods for exporting/importing MS specific data objects to JSON
file formats, but, on top of that, supporting serializing MS data objects in
additional different formats and thus supporting specific file formats defined
by other software.

## Currently supported and implemented storage representations

The currently available export/data storage formats along with the respective
*parameter* object to configure the export/import are listed below:

- Export to or import from plain text files. For most objects the data is stored
  in simple tabulator delimited text files. Export/import can be configured with
  the `PlainTextParam` *parameter* class and is supported at present for
  `MsBackendMzR` and `Spectra` objects from the
  [*Spectra*](https://github.com/RforMassSpectrometry/Spectra) package,
  `MsExperiment` objects from the
  [*MsExperiment*](https://github.com/RforMassSpectrometry/MsExperiment) package
  and `XcmsExperiment` objects from the
  [*xcms*](https://github.com/sneumann/xcms) package.


# Contributions

Contributions are highly welcome and should follow the [contribution
guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions).
Also, please check the coding style guidelines in the [RforMassSpectrometry
vignette](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html).


# License

The *MsIO* code is provided under a permissive [Artistic 2.0
license](https://opensource.org/licenses/Artistic-2.0). The
documentation, including the manual pages and the vignettes, are
distributed under a [CC BY-SA
license](https://creativecommons.org/licenses/by-sa/4.0/).
