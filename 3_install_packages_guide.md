# 📦 R Package Installation Guide
## TCGA Biostatistics, Data Visualization, and RNA-seq Tutorials

This guide explains how to install and verify the R packages used in the tutorials.

The installer works on **Windows, macOS, and Linux**. It can be run again safely: packages that are already installed are skipped.

---

## 📑 Contents

1. [Introduction](#-1-introduction)
2. [Prerequisites](#-2-prerequisites)
3. [Create the Installation Script](#-3-create-the-installation-script)
4. [Run the Installer](#-4-run-the-installer)
5. [What the Script Installs](#-5-what-the-script-installs)
6. [Verify the Installation](#-6-verify-the-installation)
7. [Troubleshooting](#-7-troubleshooting)
8. [Project Folders and Version Report](#-8-project-folders-and-version-report)

---

## 📌 1. Introduction

The installer sets up the R packages needed for:

- Data handling and visualization
- Statistical tests and effect sizes
- Survival analysis
- Heatmaps and reports
- RNA-seq differential expression and enrichment analysis

It installs packages from **CRAN** and **Bioconductor**.

> **Note:** Package installation may take some time, particularly for RNA-seq packages and their dependencies. An internet connection is required.

---

## 🧰 2. Prerequisites

1. Install **R 4.3.0 or newer** if possible.
2. Open RStudio or the R console.
3. Make sure your computer has an internet connection.
4. Choose a project folder where you want the tutorial files and output folders to be created.

Check your R version:

```r
R.version.string
```

---

## 📝 3. Create the Installation Script

Create a new R script named `install_all_packages.R`.

Copy the complete code below into that file and save it.

```r
# =============================================================================
# install_all_packages.R
# One-shot installer for TCGA biostatistics, visualization, and RNA-seq tutorials
# Works on Windows, macOS, and Linux. Safe to re-run.
# =============================================================================

# ---- 0. Settings ------------------------------------------------------------

options(repos = c(CRAN = "https://cloud.r-project.org"))
options(timeout = max(600, getOption("timeout")))

# ---- 1. Package lists -------------------------------------------------------

# Core data handling and plotting
cran_pkgs <- c(
  "tidyverse", "scales", "patchwork", "RColorBrewer", "viridis",
  "colorspace", "ggsci", "ggrepel", "forcats",

  # Statistics and effect sizes
  "ggpubr", "rstatix", "effectsize", "car", "FSA", "broom", "ggsignif",

  # Survival analysis
  "survival", "survminer",

  # Heatmaps and reporting
  "pheatmap", "rmarkdown", "knitr"
)

# RNA-seq and enrichment analysis
bioc_pkgs <- c(
  "DESeq2", "apeglm", "clusterProfiler", "org.Hs.eg.db", "enrichplot"
)

all_pkgs <- c(cran_pkgs, bioc_pkgs)

# ---- 2. Check R version -----------------------------------------------------

if (getRversion() < "4.3.0") {
  warning(
    "R ", getRversion(),
    " detected. R 4.3.0 or newer is recommended."
  )
}

# ---- 3. Install CRAN packages -----------------------------------------------

missing_cran <- setdiff(
  cran_pkgs,
  rownames(installed.packages())
)

if (length(missing_cran) > 0) {
  message(
    "Installing from CRAN: ",
    paste(missing_cran, collapse = ", ")
  )

  install.packages(missing_cran, dependencies = TRUE)
} else {
  message("All CRAN packages are already installed.")
}

# ---- 4. Install Bioconductor packages ---------------------------------------

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

missing_bioc <- setdiff(
  bioc_pkgs,
  rownames(installed.packages())
)

if (length(missing_bioc) > 0) {
  message(
    "Installing from Bioconductor: ",
    paste(missing_bioc, collapse = ", ")
  )

  BiocManager::install(
    missing_bioc,
    ask = FALSE,
    update = FALSE
  )
} else {
  message("All Bioconductor packages are already installed.")
}

# ---- 5. Verify that every package loads -------------------------------------

failed <- character(0)

for (p in all_pkgs) {
  ok <- suppressWarnings(
    suppressPackageStartupMessages(
      require(p, character.only = TRUE, quietly = TRUE)
    )
  )

  if (!ok) {
    failed <- c(failed, p)
  }
}

if (length(failed) == 0) {
  message(
    "\nAll ", length(all_pkgs),
    " requested packages installed and loaded successfully."
  )
} else {
  message("\nThese packages failed to install or load:")
  message("  ", paste(failed, collapse = ", "))
  message(
    "Check the installation messages, resolve any errors, ",
    "and re-run the script."
  )
}

# ---- 6. Version report ------------------------------------------------------

pkg_versions <- data.frame(
  package = all_pkgs,
  version = vapply(
    all_pkgs,
    function(p) {
      if (requireNamespace(p, quietly = TRUE)) {
        as.character(packageVersion(p))
      } else {
        "NOT INSTALLED"
      }
    },
    character(1)
  ),
  row.names = NULL
)

print(pkg_versions, row.names = FALSE)

# ---- 7. Create project folders and save the version report ------------------

for (d in c("data", "figures", "results", "results_rnaseq")) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}

write.csv(
  pkg_versions,
  file = "results/package_versions.csv",
  row.names = FALSE
)

message("\nProject folders ready:")
message("  data/")
message("  figures/")
message("  results/")
message("  results_rnaseq/")
message("Version report saved to results/package_versions.csv")
```

---

## ▶️ 4. Run the Installer

### Option A: Run it in RStudio

1. Open RStudio.
2. Open the folder you chose for your tutorial project.
3. Open `install_all_packages.R`.
4. Click **Source** to run the complete script, or run the script from the console:

```r
source("install_all_packages.R")
```

### Option B: Run it from the R console

First, set your working directory to the folder containing the script. Replace the example path with your own folder.

```r
setwd("path/to/your/project")
source("install_all_packages.R")
```

To check the current working directory:

```r
getwd()
```

> **Important:** The folders created by the script are placed inside the current working directory. Make sure it is your intended project folder before running the installer.

---

## 📚 5. What the Script Installs

| Category | Packages |
|---|---|
| Data handling and plotting | `tidyverse`, `scales`, `patchwork`, `RColorBrewer`, `viridis`, `colorspace`, `ggsci`, `ggrepel`, `forcats` |
| Statistics and effect sizes | `ggpubr`, `rstatix`, `effectsize`, `car`, `FSA`, `broom`, `ggsignif` |
| Survival analysis | `survival`, `survminer` |
| Heatmaps and reporting | `pheatmap`, `rmarkdown`, `knitr` |
| RNA-seq and enrichment | `DESeq2`, `apeglm`, `clusterProfiler`, `org.Hs.eg.db`, `enrichplot` |

The script also installs `BiocManager` if it is not already available. This package manages Bioconductor installations.

---

## ✅ 6. Verify the Installation

After the script finishes, check the version report:

```r
read.csv("results/package_versions.csv")
```

You can also test a package directly:

```r
library(tidyverse)
library(DESeq2)
library(clusterProfiler)
```

If a package reports `NOT INSTALLED` or fails to load, read the console messages to identify the specific error.

---

## 🛠️ 7. Troubleshooting

### Installation is taking a long time

RNA-seq packages have many dependencies. Keep R running and allow the installation to finish. A slow connection may increase the installation time.

### A package fails to install

Run the relevant installation command separately to see the full error:

```r
install.packages("tidyverse")
```

For a Bioconductor package:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install("DESeq2", ask = FALSE, update = FALSE)
```

### R is out of date

Check your version:

```r
R.version.string
```

Updating R may resolve compatibility problems. After updating R, you may need to reinstall packages in the new R library.

### System dependencies are missing

Some packages may require operating-system tools or libraries, especially on Linux. Read the specific error message and install the required system dependencies for your operating system.

### A package is installed but will not load

Try:

```r
packageVersion("tidyverse")
sessionInfo()
```

Restart R and retry. If the error persists, use the exact error message to investigate the issue.

> **Important:** The script reports whether packages can be loaded, but this does not guarantee that every package function or analysis will work with every dataset.

---

## 📁 8. Project Folders and Version Report

The script creates these folders in your current working directory:

```text
your_project/
├── install_all_packages.R
├── data/
├── figures/
├── results/
│   └── package_versions.csv
└── results_rnaseq/
```

- `data/` — datasets used in the tutorials
- `figures/` — plots and visualizations
- `results/` — general analysis results and package-version report
- `results_rnaseq/` — RNA-seq analysis outputs
- `results/package_versions.csv` — installed package versions, useful for reproducibility

---

## 🎉 Installation Complete

Once all requested packages install and load successfully, you can continue to the data-cleaning, statistical-analysis, visualization, survival-analysis, and RNA-seq tutorials.

**Tip:** Keep `install_all_packages.R` and `results/package_versions.csv` with your project so you can document and reproduce your analysis environment.
