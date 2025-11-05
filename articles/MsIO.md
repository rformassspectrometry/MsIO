# Storage Modes of MS Data Objects

**Package**: *[MsIO](https://bioconductor.org/packages/3.23/MsIO)*  
**Authors**: Johannes Rainer \[aut, cre\] (ORCID:
<https://orcid.org/0000-0002-6977-7147>), Philippine Louail \[aut\]
(ORCID: <https://orcid.org/0009-0007-5429-6846>), Laurent Gatto \[ctb\]
(ORCID: <https://orcid.org/0000-0002-1520-2268>)  
**Compiled**: Wed Nov 5 06:55:40 2025

## Introduction

Data objects in R can be serialized to disk in R’s *Rds* format using
the base R [`save()`](https://rdrr.io/r/base/save.html) function and
re-imported using the [`load()`](https://rdrr.io/r/base/load.html)
function. This R-specific binary data format can however not be used or
read by other programming languages preventing thus the exchange of R
data objects between software or programming languages. The *MsIO*
package provides functionality to export and import mass spectrometry
data objects in various storage formats aiming to facilitate data
exchange between software. This includes, among other formats, also
storage of data objects using Bioconductor’s
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
package.

For export or import of MS data objects, the
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
and
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
functions can be used. For
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md),
the first parameter is the MS data object that should be stored, for
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
it defines type of MS object that should be restored (returned). The
second parameter `param` defines and configures the storage format of
the MS data. The currently supported formats and the respective
parameter objects are:

- `PlainTextParam`: storage of data in plain text file format.
- `AlabasterParam`: storage of MS data using Bioconductor’s
  *[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
  framework based files in HDF5 and JSON format.
- `mzTabParam`: export of LC-MS analysis results in *mzTab-M* format.
  Currently only `XcmsExperiment` is supported.

These storage formats are described in more details in the following
sections.

An example use of these functions and parameters:
`saveMsObject(x, param = PlainTextParam(storage_path))` to store an MS
data object assigned to a variable `x` to a directory `storage_path`
using the plain text file format. To restore the data (assuming `x` was
an instance of a `MsExperiment` class):
`readMsObject(MsExperiment(), param = PlainTextParam(storage_path))`.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
`BiocManager::install("RforMassSpectrometry/MsIO")` to install this
package.

For import or export of MS data objects installation of additional
Bioconductor packages might be needed:

- *[Spectra](https://bioconductor.org/packages/3.23/Spectra)* (with
  `BiocManager::install("Spectra")`) for import or export of `Spectra`
  or `MsBackendMzR` objects.
- *[MsExperiment](https://bioconductor.org/packages/3.23/MsExperiment)*
  (with `BiocManager::install("MsExperiment")`) for import or export of
  `MsExperiment` objects.
- *[xcms](https://bioconductor.org/packages/3.23/xcms)* (with
  `BiocManager::install("xcms")`) for import or export of
  `XcmsExperiment` objects (result objects of *xcms*-based
  preprocessing).

## Plain text file format

Storage of MS data objects in *plain* text format aims to support an
easy exchange of data, and in particular analysis results, with external
software, such as
[MS-DIAL](https://systemsomicslab.github.io/compms/msdial/main.html) or
[mzmine3](http://mzmine.github.io/download.md). In most cases, the data
is stored as tabulator delimited text files simplifying the use of the
data and results across multiple programming languages, or their import
into spreadsheet applications. MS data objects stored in plain text
format can also be fully re-imported into R providing thus an
alternative, and more flexible, object serialization approach than the R
internal *Rds*/*RData* format.

Below we create a MS data object (`MsExperiment`) representing the data
from two raw MS data files and assign sample annotation information to
these data files.

``` r

library(MsIO)
library(MsExperiment)

fls <- dir(system.file("TripleTOF-SWATH", package = "msdata"),
           full.names = TRUE)
mse <- readMsExperiment(
    fls,
    sampleData = data.frame(name = c("Pestmix1 DDA", "Pestmix SWATH"),
                            mode = c("DDA", "SWATH")))
mse
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (5626) MS2 (10975) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 16601 element(s).

We can export this data object to plain text files using *MsIO*’s
[`saveMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
function in combination with the `PlainTextParam` parameter object. The
path to the directory to which the data should be stored can be defined
with the `path` parameter of `PlainTextParam`. With the call below we
store the MS data object to a temporary directory.

``` r

d <- file.path(tempdir(), "ms_experiment_export")
saveMsObject(mse, PlainTextParam(path = d))
```

The data was exported to a set of text files that we list below:

``` r

dir(d)
```

    ## [1] "ms_backend_data.txt"                        
    ## [2] "ms_experiment_link_mcols.txt"               
    ## [3] "ms_experiment_sample_data_links_spectra.txt"
    ## [4] "ms_experiment_sample_data.txt"              
    ## [5] "spectra_processing_queue.json"              
    ## [6] "spectra_slots.txt"

Each text file contains information about one particular *slot* of the
MS data object. See the
[`?PlainTextParam`](https://rformassspectrometry.github.io/MsIO/reference/PlainTextParam.md)
help for a description of the files and their respective formats. We can
restore the MS data object again using the
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
function, specifying the type of object we want to restore (and which
was stored to the respective directory) with the first parameter of the
function and the data storage format with the second. In our example we
use
[`MsExperiment()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
as first parameter and `PlainTextParam` as second. The MS data of our
`MsExperiment` data object was represented by a `Spectra` object, thus,
to import the data we need in addition to load the
*[Spectra](https://bioconductor.org/packages/3.23/Spectra)* package.

``` r

library(Spectra)
mse_in <- readMsObject(MsExperiment(), PlainTextParam(d))
mse_in
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (5626) MS2 (10975) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 16601 element(s).

Note that at present *MsIO* does **not** support storage of the full MS
data (i.e. the individual mass peaks’ *m/z* and intensity values) to
plain text file. *MsIO* supports storage of *on-disk* data
objects/representations (such as the `MsBackendMzR` object) to plain
text formats. The `Spectra` object that is used to represent the MS data
of our example `MsExperiment` object uses a `MsBackendMzR` backend and
thus we were able to export and import its data. Due to its on-disk data
mode, this type of backend retrieves the MS data on-the-fly from the
original data files and hence we only need to store the MS metadata and
the location of the original data files. Thus, also with the restored MS
data object we have full access to the MS data:

``` r

spectra(mse_in) |>
    head() |>
    intensity()
```

    ## NumericList of length 6
    ## [[1]] 0.0307632219046354 0.163443520665169 ... 0.507792055606842
    ## [[2]] 0.124385602772236 0.306980639696121 ... 0.752154946327209
    ## [[3]] 0.140656530857086 0.194816112518311 ... 0.455461025238037
    ## [[4]] 0.0389336571097374 0.357547700405121 ... 0.478326231241226
    ## [[5]] 0.124386593699455 0.054143700748682 ... 0.251276850700378
    ## [[6]] 0.0940475389361382 0.247442871332169 ... 0.10762557387352

However, ff the location of the original MS data files was changed
(e.g. if the files or the stored object was moved to a different
location or file system), the new location of these files would be
needed to be specified with parameter `spectraPath`
(e.g. `readMsObject(MsExperiment(), PlainTextParam(d), spectraPath = <path to new location>)`).

Generally, `saveMsData()` stores the MS data objects in a modular way,
i.e. the content of each component or slot is exported to its own data
file. The storage directory of our example `MsExperiment` contains thus
multiple data files:

``` r

dir(d)
```

    ## [1] "ms_backend_data.txt"                        
    ## [2] "ms_experiment_link_mcols.txt"               
    ## [3] "ms_experiment_sample_data_links_spectra.txt"
    ## [4] "ms_experiment_sample_data.txt"              
    ## [5] "spectra_processing_queue.json"              
    ## [6] "spectra_slots.txt"

This modularity allows also to load only parts of the original data. We
can for example also load only the `Spectra` object representing the MS
experiment’s MS data.

``` r

s <- readMsObject(Spectra(), PlainTextParam(d))
s
```

    ## MSn data (Spectra) with 16601 spectra in a MsBackendMzR backend:
    ##         msLevel     rtime scanIndex
    ##       <integer> <numeric> <integer>
    ## 1             1     0.231         1
    ## 2             1     0.351         2
    ## 3             1     0.471         3
    ## 4             1     0.591         4
    ## 5             1     0.711         5
    ## ...         ...       ...       ...
    ## 16597         2   899.527      8995
    ## 16598         2   899.624      8996
    ## 16599         2   899.721      8997
    ## 16600         2   899.818      8998
    ## 16601         2   899.915      8999
    ##  ... 27 more variables/columns.
    ## 
    ## file(s):
    ## PestMix1_DDA.mzML
    ## PestMix1_SWATH.mzML

Or even only the `MsBackendMzR` that is used by the `Spectra` object to
represent the MS data.

``` r

be <- readMsObject(MsBackendMzR(), PlainTextParam(d))
be
```

    ## MsBackendMzR with 16601 spectra
    ##         msLevel     rtime scanIndex
    ##       <integer> <numeric> <integer>
    ## 1             1     0.231         1
    ## 2             1     0.351         2
    ## 3             1     0.471         3
    ## 4             1     0.591         4
    ## 5             1     0.711         5
    ## ...         ...       ...       ...
    ## 16597         2   899.527      8995
    ## 16598         2   899.624      8996
    ## 16599         2   899.721      8997
    ## 16600         2   899.818      8998
    ## 16601         2   899.915      8999
    ##  ... 27 more variables/columns.
    ## 
    ## file(s):
    ## PestMix1_DDA.mzML
    ## PestMix1_SWATH.mzML

## *alabaster*-based formats

The [alabaster framework](https://github.com/ArtifactDB/alabaster.base)
and related Bioconductor package
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
implements methods to save a variety of R/Bioconductor objects to
on-disk representations based on standard file formats like HDF5 and
JSON. This ensures that Bioconductor objects can be easily read from
other languages like Python and Javascript. With `AlabasterParam`,
*MsIO* supports export of MS data objects into these storage formats.
Below we export our example `MsExperiment` to a storage directory using
the alabaster format.

``` r

d <- file.path(tempdir(), "ms_experiment_export_alabaster")
saveMsObject(mse, AlabasterParam(path = d))
```

The contents of the storage folder is listed below:

``` r

dir(d, recursive = TRUE)
```

    ##  [1] "_environment.json"                             
    ##  [2] "experiment_files/OBJECT"                       
    ##  [3] "experiment_files/x/list_contents.json.gz"      
    ##  [4] "experiment_files/x/OBJECT"                     
    ##  [5] "metadata/list_contents.json.gz"                
    ##  [6] "metadata/OBJECT"                               
    ##  [7] "OBJECT"                                        
    ##  [8] "other_data/list_contents.json.gz"              
    ##  [9] "other_data/OBJECT"                             
    ## [10] "sample_data_links_mcols/basic_columns.h5"      
    ## [11] "sample_data_links_mcols/OBJECT"                
    ## [12] "sample_data_links/list_contents.json.gz"       
    ## [13] "sample_data_links/OBJECT"                      
    ## [14] "sample_data_links/other_contents/0/array.h5"   
    ## [15] "sample_data_links/other_contents/0/OBJECT"     
    ## [16] "sample_data/basic_columns.h5"                  
    ## [17] "sample_data/OBJECT"                            
    ## [18] "spectra/backend/OBJECT"                        
    ## [19] "spectra/backend/peaks_variables/contents.h5"   
    ## [20] "spectra/backend/peaks_variables/OBJECT"        
    ## [21] "spectra/backend/spectra_data/basic_columns.h5" 
    ## [22] "spectra/backend/spectra_data/OBJECT"           
    ## [23] "spectra/metadata/list_contents.json.gz"        
    ## [24] "spectra/metadata/OBJECT"                       
    ## [25] "spectra/OBJECT"                                
    ## [26] "spectra/processing_chunk_size/contents.h5"     
    ## [27] "spectra/processing_chunk_size/OBJECT"          
    ## [28] "spectra/processing_queue_variables/contents.h5"
    ## [29] "spectra/processing_queue_variables/OBJECT"     
    ## [30] "spectra/processing/contents.h5"                
    ## [31] "spectra/processing/OBJECT"                     
    ## [32] "spectra/spectra_processing_queue.json"

In contrast to the plain text format described in the previous section,
that stores all data files into a single directory, the alabaster export
is structured hierarchically into sub-folders by the MS data object’s
slots/components.

To restore the object we use the
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
function with an `AlabasterParam` parameter objects to define the used
data storage format.

``` r

mse_in <- readMsObject(MsExperiment(), AlabasterParam(d))
mse_in
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (5626) MS2 (10975) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 16601 element(s).

Also for this format, we can load parts of the data separately. We can
load the MS data as a `Spectra` object from the respective subfolder of
the data storage directory:

``` r

s <- readMsObject(Spectra(), AlabasterParam(file.path(d, "spectra")))
s
```

    ## MSn data (Spectra) with 16601 spectra in a MsBackendMzR backend:
    ##         msLevel     rtime scanIndex
    ##       <integer> <numeric> <integer>
    ## 1             1     0.231         1
    ## 2             1     0.351         2
    ## 3             1     0.471         3
    ## 4             1     0.591         4
    ## 5             1     0.711         5
    ## ...         ...       ...       ...
    ## 16597         2   899.527      8995
    ## 16598         2   899.624      8996
    ## 16599         2   899.721      8997
    ## 16600         2   899.818      8998
    ## 16601         2   899.915      8999
    ##  ... 34 more variables/columns.
    ## 
    ## file(s):
    ## PestMix1_DDA.mzML
    ## PestMix1_SWATH.mzML

The import/export functionality is completely compatible with
Bioconductor’s alabaster framework and hence allows also to read the
whole, or parts of the data directly using alabaster’s
[`readObject()`](https://rformassspectrometry.github.io/MsIO/reference/AlabasterParam.md)
method. The full `MsExperiment` is restored importing the full directory
(i.e. providing the path to the directory containing the full export
with the function’s `path` parameter).

``` r

mse_in <- readObject(path = d)
mse_in
```

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (5626) MS2 (10975) 
    ##  Experiment data: 2 sample(s)
    ##  Sample data links:
    ##   - spectra: 2 sample(s) to 16601 element(s).

Alternatively, by providing a path to one of the MS object’s components,
it is possible to read only specific parts of the data. Below we read
the sample annotation information as a `DataFrame` from the
*sample_data* subfolder:

``` r

readObject(path = file.path(d, "sample_data"))
```

    ## DataFrame with 2 rows and 3 columns
    ##                              name        mode spectraOrigin
    ##                       <character> <character>   <character>
    ## PestMix1_DDA.mzML   Pestmix1 D...         DDA /__w/_temp...
    ## PestMix1_SWATH.mzML Pestmix SW...       SWATH /__w/_temp...

## Loading data from *MetaboLights*

The *MetaboLights* database contains a large collection of metabolomics
datasets. By creating a `MetaboLightsParam` object, you can load data
from this database by providing the desired MetaboLights ID. The dataset
will be loaded as an `MsExperiment` object. This object will have a
`sampleData` slot that contains the sample information combined with the
selected assay’s information. One `MsExperiment` object can be created
from one assay. The spectra information in the `MsExperiment` object
will be populated from the derived files available in the database. For
more details on how the spectral data is handled, refer to this
[vignette](https://rformassspectrometry.github.io/MsBackendMetaboLights/articles/MsBackendMetaboLights.html)

Below, we demonstrate how to load the *small* dataset with the ID:
*MTBLS575*. We also use the `assayName` parameter to specify which assay
we want to load, and the `filePattern` parameter to indicate which assay
files to load. It is recommended to adjust these settings according to
your specific study.

``` r

library(MsExperiment())
# Prepare parameter
param <- MetaboLightsParam(mtblsId = "MTBLS575",
                           assayName = paste0("a_MTBLS575_POS_INFEST_CTRL_",
                                              "mass_spectrometry.txt"),
                           filePattern = "cdf$")

# Load MsExperiment object
mse <- readMsObject(MsExperiment(), param)
```

Next, we examine the
[`sampleData()`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)
of our `mse` object:

``` r

sampleData(mse)
```

    ## DataFrame with 6 rows and 30 columns
    ##     Sample Name Protocol REF Protocol REF.1
    ##     <character>  <character>    <character>
    ## 1     PB130_co1   Extraction  Chromatogr...
    ## 2     PB130_co2   Extraction  Chromatogr...
    ## 3     PB130_co3   Extraction  Chromatogr...
    ## 4 PB130_sesa...   Extraction  Chromatogr...
    ## 5 PB130_sesa...   Extraction  Chromatogr...
    ## 6 PB130_sesa...   Extraction  Chromatogr...
    ##   Parameter Value[Chromatography Instrument] Parameter Value[Column model]
    ##                                  <character>                   <character>
    ## 1                              Waters ACQ...                 ACQUITY UP...
    ## 2                              Waters ACQ...                 ACQUITY UP...
    ## 3                              Waters ACQ...                 ACQUITY UP...
    ## 4                              Waters ACQ...                 ACQUITY UP...
    ## 5                              Waters ACQ...                 ACQUITY UP...
    ## 6                              Waters ACQ...                 ACQUITY UP...
    ##   Parameter Value[Column type] Protocol REF.2 Parameter Value[Scan polarity]
    ##                    <character>    <character>                    <character>
    ## 1                reverse ph...  Mass spect...                       positive
    ## 2                reverse ph...  Mass spect...                       positive
    ## 3                reverse ph...  Mass spect...                       positive
    ## 4                reverse ph...  Mass spect...                       positive
    ## 5                reverse ph...  Mass spect...                       positive
    ## 6                reverse ph...  Mass spect...                       positive
    ##   Parameter Value[Instrument] Parameter Value[Ion source] Term Source REF
    ##                   <character>                 <character>     <character>
    ## 1               Waters SYN...               electrospr...              MS
    ## 2               Waters SYN...               electrospr...              MS
    ## 3               Waters SYN...               electrospr...              MS
    ## 4               Waters SYN...               electrospr...              MS
    ## 5               Waters SYN...               electrospr...              MS
    ## 6               Waters SYN...               electrospr...              MS
    ##   Term Accession Number Parameter Value[Mass analyzer] Raw_Spectral_Data_File
    ##             <character>                    <character>            <character>
    ## 1         http://pur...                  quadrupole...          FILES/PB13...
    ## 2         http://pur...                  quadrupole...          FILES/PB13...
    ## 3         http://pur...                  quadrupole...          FILES/PB13...
    ## 4         http://pur...                  quadrupole...          FILES/PB13...
    ## 5         http://pur...                  quadrupole...          FILES/PB13...
    ## 6         http://pur...                  quadrupole...          FILES/PB13...
    ##   Protocol REF.3 Protocol REF.4 Metabolite Assignment File Source Name
    ##      <character>    <character>                <character> <character>
    ## 1  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 2  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 3  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 4  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 5  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ## 6  Data trans...  Metabolite...              m_MTBLS575...    MBG-CSIC
    ##   Characteristics[Organism] Term Source REF.1 Term Accession Number.1
    ##                 <character>       <character>             <character>
    ## 1                  Zea mays         NCBITAXON           http://pur...
    ## 2                  Zea mays         NCBITAXON           http://pur...
    ## 3                  Zea mays         NCBITAXON           http://pur...
    ## 4                  Zea mays         NCBITAXON           http://pur...
    ## 5                  Zea mays         NCBITAXON           http://pur...
    ## 6                  Zea mays         NCBITAXON           http://pur...
    ##   Characteristics[Variant] Term Source REF.2 Term Accession Number.2
    ##                <character>       <character>             <character>
    ## 1            Zea mays s...               EFO           http://pur...
    ## 2            Zea mays s...               EFO           http://pur...
    ## 3            Zea mays s...               EFO           http://pur...
    ## 4            Zea mays s...               EFO           http://pur...
    ## 5            Zea mays s...               EFO           http://pur...
    ## 6            Zea mays s...               EFO           http://pur...
    ##   Characteristics[Organism part] Term Accession Number.3 Protocol REF.5
    ##                      <character>             <character>    <character>
    ## 1                  stem inter...           http://pur...  Sample col...
    ## 2                  stem inter...           http://pur...  Sample col...
    ## 3                  stem inter...           http://pur...  Sample col...
    ## 4                  stem inter...           http://pur...  Sample col...
    ## 5                  stem inter...           http://pur...  Sample col...
    ## 6                  stem inter...           http://pur...  Sample col...
    ##   Factor Value[Genotype] Factor Value[Infestation]
    ##              <character>               <character>
    ## 1                  PB130                   Control
    ## 2                  PB130                   Control
    ## 3                  PB130                   Control
    ## 4                  PB130             Sesamia in...
    ## 5                  PB130             Sesamia in...
    ## 6                  PB130             Sesamia in...
    ##   Factor Value[Biological Replicate]
    ##                            <integer>
    ## 1                                  1
    ## 2                                  2
    ## 3                                  3
    ## 4                                  1
    ## 5                                  2
    ## 6                                  3

We observe that a large number of columns are present. Several
parameters are available in the
[`readMsObject()`](https://rformassspectrometry.github.io/MsIO/reference/saveMsObject.md)
function to simplify the `sampleData`. Setting `keepOntology = FALSE`
will remove columns related to ontology terms, while
`keepProtocol = FALSE` will remove columns related to protocol
information. The `simplify = TRUE` option (the default) removes NAs and
merges columns with different names but duplicate contents. You can set
`simplify = FALSE` to retain all columns. Below, we load the object
again, this time simplifying the `sampleData`:

``` r

mse <- readMsObject(MsExperiment(), param, keepOntology = FALSE,
                    keepProtocol = FALSE, simplify = TRUE)
```

Now, if we examine the `sampleData` information:

``` r

sampleData(mse)
```

    ## DataFrame with 6 rows and 10 columns
    ##     Sample Name Raw_Spectral_Data_File Metabolite Assignment File Source Name
    ##     <character>            <character>                <character> <character>
    ## 1     PB130_co1          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 2     PB130_co2          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 3     PB130_co3          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 4 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 5 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ## 6 PB130_sesa...          FILES/PB13...              m_MTBLS575...    MBG-CSIC
    ##   Characteristics[Organism] Characteristics[Variant]
    ##                 <character>              <character>
    ## 1                  Zea mays            Zea mays s...
    ## 2                  Zea mays            Zea mays s...
    ## 3                  Zea mays            Zea mays s...
    ## 4                  Zea mays            Zea mays s...
    ## 5                  Zea mays            Zea mays s...
    ## 6                  Zea mays            Zea mays s...
    ##   Characteristics[Organism part] Factor Value[Genotype]
    ##                      <character>            <character>
    ## 1                  stem inter...                  PB130
    ## 2                  stem inter...                  PB130
    ## 3                  stem inter...                  PB130
    ## 4                  stem inter...                  PB130
    ## 5                  stem inter...                  PB130
    ## 6                  stem inter...                  PB130
    ##   Factor Value[Infestation] Factor Value[Biological Replicate]
    ##                 <character>                          <integer>
    ## 1                   Control                                  1
    ## 2                   Control                                  2
    ## 3                   Control                                  3
    ## 4             Sesamia in...                                  1
    ## 5             Sesamia in...                                  2
    ## 6             Sesamia in...                                  3

We can see that it is much simpler.

## Session information

``` r

sessionInfo()
```

    ## R Under development (unstable) (2025-10-31 r88977)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.3 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ## [1] Spectra_1.21.0      BiocParallel_1.45.0 S4Vectors_0.49.0   
    ## [4] BiocGenerics_0.57.0 generics_0.1.4      MsExperiment_1.13.0
    ## [7] ProtGenerics_1.43.0 MsIO_0.0.11         BiocStyle_2.39.0   
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] DBI_1.2.3                   httr2_1.2.1                
    ##  [3] rlang_1.1.6                 magrittr_2.0.4             
    ##  [5] clue_0.3-66                 matrixStats_1.5.0          
    ##  [7] MsBackendMetaboLights_1.5.1 compiler_4.6.0             
    ##  [9] RSQLite_2.4.3               systemfonts_1.3.1          
    ## [11] vctrs_0.6.5                 reshape2_1.4.4             
    ## [13] stringr_1.6.0               crayon_1.5.3               
    ## [15] pkgconfig_2.0.3             MetaboCoreUtils_1.19.0     
    ## [17] fastmap_1.2.0               dbplyr_2.5.1               
    ## [19] XVector_0.51.0              rmarkdown_2.30             
    ## [21] ragg_1.5.0                  purrr_1.2.0                
    ## [23] bit_4.6.0                   xfun_0.54                  
    ## [25] MultiAssayExperiment_1.37.0 cachem_1.1.0               
    ## [27] jsonlite_2.0.0              progress_1.2.3             
    ## [29] blob_1.2.4                  rhdf5filters_1.23.0        
    ## [31] DelayedArray_0.37.0         Rhdf5lib_1.33.0            
    ## [33] prettyunits_1.2.0           parallel_4.6.0             
    ## [35] cluster_2.1.8.1             R6_2.6.1                   
    ## [37] bslib_0.9.0                 stringi_1.8.7              
    ## [39] GenomicRanges_1.63.0        jquerylib_0.1.4            
    ## [41] Rcpp_1.1.0                  Seqinfo_1.1.0              
    ## [43] bookdown_0.45               SummarizedExperiment_1.41.0
    ## [45] knitr_1.50                  IRanges_2.45.0             
    ## [47] BiocBaseUtils_1.13.0        Matrix_1.7-4               
    ## [49] igraph_2.2.1                tidyselect_1.2.1           
    ## [51] abind_1.4-8                 yaml_2.3.10                
    ## [53] codetools_0.2-20            curl_7.0.0                 
    ## [55] lattice_0.22-7              tibble_3.3.0               
    ## [57] plyr_1.8.9                  withr_3.0.2                
    ## [59] Biobase_2.71.0              evaluate_1.0.5             
    ## [61] desc_1.4.3                  BiocFileCache_3.1.0        
    ## [63] alabaster.schemas_1.11.0    pillar_1.11.1              
    ## [65] BiocManager_1.30.26         filelock_1.0.3             
    ## [67] MatrixGenerics_1.23.0       ncdf4_1.24                 
    ## [69] hms_1.1.4                   alabaster.base_1.11.1      
    ## [71] glue_1.8.0                  alabaster.matrix_1.7.8     
    ## [73] lazyeval_0.2.2              tools_4.6.0                
    ## [75] QFeatures_1.21.0            mzR_2.45.0                 
    ## [77] fs_1.6.6                    rhdf5_2.55.4               
    ## [79] grid_4.6.0                  tidyr_1.3.1                
    ## [81] MsCoreUtils_1.21.0          HDF5Array_1.39.0           
    ## [83] cli_3.6.5                   rappdirs_0.3.3             
    ## [85] textshaping_1.0.4           S4Arrays_1.11.0            
    ## [87] dplyr_1.1.4                 AnnotationFilter_1.35.0    
    ## [89] sass_0.4.10                 digest_0.6.37              
    ## [91] SparseArray_1.11.1          htmlwidgets_1.6.4          
    ## [93] memoise_2.0.1               htmltools_0.5.8.1          
    ## [95] pkgdown_2.1.3.9000          lifecycle_1.0.4            
    ## [97] h5mread_1.3.0               bit64_4.6.0-1              
    ## [99] MASS_7.3-65
