# 📦 Installing All R Packages for the TCGA Tutorials

A one-shot installer for every R package used in the **TCGA biostatistics**, **colour**, and **RNA-seq** tutorials. Works on Windows, macOS, and Linux.

---

## 📑 Contents

1. [Introduction](#-1-introduction)
2. [Before You Start](#-2-before-you-start)
3. [Package Overview](#-3-package-overview)
4. [The Full Installer Script](#-4-the-full-installer-script)
5. [How to Run It](#-5-how-to-run-it)
6. [Script Explained Step by Step](#-6-script-explained-step-by-step)
7. [Expected Output](#-7-expected-output)
8. [Troubleshooting](#-8-troubleshooting)
9. [Quick Quiz](#-9-quick-quiz)
10. [Conclusion](#-10-conclusion)

---

## 📌 1. Introduction

This script installs **every R package** used across the TCGA biostatistics, colour, and RNA-seq tutorials in one go. It is a one-time setup step you run before working through the other tutorials.

- ✅ **Cross-platform:** Windows, macOS, and Linux.
- ✅ **Safe to re-run:** it skips packages that are already installed.
- ✅ **Self-verifying:** it loads every package at the end and prints a clear success or failure message.

**Write the code in the Editor:**

Nothing to type here — this tutorial is a single R script. Save it as `install_all_packages.R` and run it.

**Interpretation:**
You should run this script in a **fresh, empty working directory** that will become your project folder for the TCGA tutorials. The script will create four sub-folders for you (`data/`, `figures/`, `results/`, `results_rnaseq/`) and save a version report.

---

## 📥 2. Before You Start

Make sure the following are ready before you run the installer:

| Requirement | Notes |
|---|---|
| **R version 4.3 or newer** | Recommended. Older R will work but emit a warning. Check with `getRversion()` in the R console. |
| **Internet connection** | The script downloads packages from CRAN and Bioconductor. |
| **Windows: Rtools** | Needed to compile packages from source. Install the version that matches your R version from [CRAN](https://cran.r-project.org/bin/windows/Rtools/). |
| **macOS: Xcode Command Line Tools** | Run `xcode-select --install` in the Terminal once. Needed for compiling packages from source. |
| **Linux: system libraries** | Common dev libraries such as `libcurl`, `libssl`, `libxml2`, and `libz` are usually required. On Debian/Ubuntu: `sudo apt install libcurl4-openssl-dev libssl-dev libxml2-dev libz-dev`. |

**Write the code in the Editor:**

```r
# Check your R version
getRversion()
```

**Interpretation:**
If the printed version is below `4.3.0`, consider upgrading R from [CRAN](https://cran.r-project.org/) before installing the packages — some of the newer packages assume a recent R.

---

## 📊 3. Package Overview

The installer uses **two sources**: **CRAN** (the central R archive) for general-purpose packages, and **Bioconductor** for the bioinformatics / RNA-seq packages.

> 💡 **Note:** Packages such as `DESeq2`, `apeglm`, `clusterProfiler`, `org.Hs.eg.db`, and `enrichplot` come from **Bioconductor**, not CRAN. They are installed via `BiocManager`, **not** with `install.packages()`.

### 🟦 CRAN packages (21 total)

**Core data handling and plotting**

| Package | One-line description |
|---|---|
| `tidyverse` | A collection of packages for data manipulation (`dplyr`), plotting (`ggplot2`), and tidy data. |
| `scales` | Nice axis labels, percent formats, and colour scales for ggplot2. |
| `patchwork` | Combine multiple ggplot2 plots into one figure with `+` and `/`. |
| `RColorBrewer` | Curated palette of colour schemes for maps and figures. |
| `viridis` | Perceptually uniform colour scales (great for heatmaps). |
| `colorspace` | Colour-space-based palettes and tools for colour-blind safety. |
| `ggsci` | Scientific journal-themed palettes (Nature, Lancet, NEJM, …). |
| `ggrepel` | Non-overlapping text labels for scatter plots. |
| `forcats` | Tools for working with categorical variables (factors). |

**Statistics and effect sizes**

| Package | One-line description |
|---|---|
| `ggpubr` | Publication-ready plots with statistical tests built in. |
| `rstatix` | Pipe-friendly statistical tests (`t_test()`, `wilcox_test()`, …). |
| `effectsize` | Compute standardised effect sizes (Cohen's d, η², Cramér's V, …). |
| `car` | Companion to Applied Regression — `Anova()`, `leveneTest()`, diagnostics. |
| `FSA` | Fisheries stock assessment methods; includes `dunnTest()` post-hoc test. |
| `broom` | Tidy model outputs: `tidy()`, `glance()`, `augment()`. |
| `ggsignif` | Significance bars on ggplot2 plots. |

**Survival analysis**

| Package | One-line description |
|---|---|
| `survival` | Core survival-analysis routines: `Surv()`, `survfit()`, `coxph()`. |
| `survminer` | `ggsurvplot()` and helpers for drawing Kaplan–Meier curves. |

**Heatmaps and reporting**

| Package | One-line description |
|---|---|
| `pheatmap` | Pretty heatmaps with clustering and annotation bars. |
| `rmarkdown` | Dynamic R documents, slides, and reports. |
| `knitr` | Backend for `rmarkdown` — runs R code chunks and weaves output. |

### 🟥 Bioconductor packages (5 total)

**RNA-seq and enrichment analysis**

| Package | One-line description |
|---|---|
| `DESeq2` | Differential expression analysis for RNA-seq counts. |
| `apeglm` | Bayesian shrinkage for DESeq2 log fold changes. |
| `clusterProfiler` | Functional enrichment (GO, KEGG) for gene lists. |
| `org.Hs.eg.db` | Human gene annotation database (Entrez IDs, symbols, …). |
| `enrichplot` | Visualisations for enrichment results (dot plots, networks, …). |

---

## 📜 4. The Full Installer Script

Save the block below as **`install_all_packages.R`** in your project folder (e.g. `tcga_tutorials/`).

**Write the code in the Editor:**

```r
# =============================================================================
# install_all_packages.R
# One-shot installer for the TCGA biostatistics, colour, and RNA-seq tutorials
# Works on Windows, macOS, and Linux. Safe to re-run: it skips installed packages.
# =============================================================================

# ---- 0. Settings ------------------------------------------------------------
options(repos = c(CRAN = "https://cloud.r-project.org"))
options(timeout = max(600, getOption("timeout")))   # large downloads on slow networks

# ---- 1. Package lists -------------------------------------------------------
cran_pkgs <- c(
  # Core data handling and plotting
  "tidyverse", "scales", "patchwork", "RColorBrewer", "viridis",
  "colorspace", "ggsci", "ggrepel", "forcats",
  # Statistics and effect sizes
  "ggpubr", "rstatix", "effectsize", "car", "FSA", "broom", "ggsignif",
  # Survival analysis
  "survival", "survminer",
  # Heatmaps and reporting
  "pheatmap", "rmarkdown", "knitr"
)

bioc_pkgs <- c(
  # RNA-seq and enrichment analysis
  "DESeq2", "apeglm", "clusterProfiler", "org.Hs.eg.db", "enrichplot"
)

all_pkgs <- c(cran_pkgs, bioc_pkgs)

# ---- 2. Check R version -----------------------------------------------------
if (getRversion() < "4.3.0") {
  warning("R ", getRversion(), " detected. R 4.3 or newer is recommended.")
}

# ---- 3. Install CRAN packages -----------------------------------------------
missing_cran <- setdiff(cran_pkgs, rownames(installed.packages()))
if (length(missing_cran) > 0) {
  message("Installing from CRAN: ", paste(missing_cran, collapse = ", "))
  install.packages(missing_cran, dependencies = TRUE)
} else {
  message("All CRAN packages already installed.")
}

# ---- 4. Install Bioconductor packages ---------------------------------------
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
missing_bioc <- setdiff(bioc_pkgs, rownames(installed.packages()))
if (length(missing_bioc) > 0) {
  message("Installing from Bioconductor: ", paste(missing_bioc, collapse = ", "))
  BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
} else {
  message("All Bioconductor packages already installed.")
}

# ---- 5. Verify every package loads ------------------------------------------
failed <- character(0)
for (p in all_pkgs) {
  ok <- suppressWarnings(suppressPackageStartupMessages(
    require(p, character.only = TRUE, quietly = TRUE)
  ))
  if (!ok) failed <- c(failed, p)
}

if (length(failed) == 0) {
  message("\n✅ All ", length(all_pkgs), " packages installed and loaded successfully.")
} else {
  message("\n❌ These packages failed to install or load:")
  message("   ", paste(failed, collapse = ", "))
  message("   Re-run this script, or install them one at a time to see the error.")
}

# ---- 6. Version report ------------------------------------------------------
pkg_versions <- data.frame(
  package = all_pkgs,
  version = vapply(all_pkgs, function(p) {
    if (requireNamespace(p, quietly = TRUE)) {
      as.character(packageVersion(p))
    } else {
      "NOT INSTALLED"
    }
  }, character(1)),
  row.names = NULL
)
print(pkg_versions, row.names = FALSE)

# ---- 7. Create project folders and save the version report -----------------
for (d in c("data", "figures", "results", "results_rnaseq")) {
  dir.create(d, showWarnings = FALSE)
}
write.csv(pkg_versions, "results/package_versions.csv", row.names = FALSE)
message("\nProject folders ready: data/, figures/, results/, results_rnaseq/")
message("Version report saved to results/package_versions.csv")
```

**Interpretation:**
The script is split into **seven clearly labelled sections** (see the next chapter for a line-by-line walkthrough). It is intentionally idempotent: re-running it on a machine that already has the packages will print "All CRAN/Bioconductor packages already installed." and finish in seconds.

---

## ▶️ 5. How to Run It

You can run the script in two ways.

**Option A — from the R console (recommended):**

```r
source("install_all_packages.R")
```

**Option B — in RStudio:**

1. Open `install_all_packages.R`.
2. Click the **Source** button (top-right of the editor pane), or press **Ctrl+Shift+S** (Windows/Linux) / **Cmd+Shift+S** (macOS).

The console will stream progress messages. The first run can take **5–20 minutes** depending on your network and how many packages need to be compiled from source.

**Write the code in the Editor:**

Nothing to write — just run the script as above.

**Interpretation:**
Use `source()` rather than copy-pasting the whole file into the console: it lets R report errors with line numbers and keeps a clean history. After the script finishes, leave RStudio open and start the next tutorial — all packages will be available via `library()`.

---

## 🔍 6. Script Explained Step by Step

This section walks through each block of the installer.

### Step 0 — Settings

```r
options(repos = c(CRAN = "https://cloud.r-project.org"))
options(timeout = max(600, getOption("timeout")))
```

Picks the **CRAN cloud mirror** (fast and global) and raises the download timeout to at least 600 seconds, so big packages do not abort on slow networks.

**Interpretation:**
If you are behind a corporate proxy, replace the URL with your local CRAN mirror, e.g. `"https://cran.r-project.org"` or a country mirror.

### Step 1 — Package lists

Two vectors: `cran_pkgs` (21 packages) and `bioc_pkgs` (5 packages). They are concatenated into `all_pkgs` so we can verify and report on all 26 in one pass.

**Interpretation:**
Keep these lists the single source of truth. If a future tutorial needs an extra package, **add it to one of these vectors** rather than calling `install.packages()` separately.

### Step 2 — R version check

If R is older than 4.3, a warning is printed. The script does **not** abort — older R will usually still work.

### Step 3 — CRAN install

```r
missing_cran <- setdiff(cran_pkgs, rownames(installed.packages()))
```

Computes which CRAN packages are not yet installed, then installs only those. `dependencies = TRUE` also pulls in the packages each one needs.

**Interpretation:**
This is the **safe-to-re-run** guarantee: on a second run, `missing_cran` is empty and the installer says "All CRAN packages already installed." in a split second.

### Step 4 — Bioconductor install

First checks whether `BiocManager` itself is installed; if not, installs it from CRAN. Then installs the missing Bioconductor packages with `BiocManager::install(..., ask = FALSE, update = FALSE)`. The `ask = FALSE` flag is what makes the script run unattended; `update = FALSE` avoids touching packages you already have.

**Interpretation:**
> 💡 Bioconductor has its own release cycle that is **not** synchronised with CRAN. Always go through `BiocManager::install()` for Bioconductor packages — calling `install.packages("DESeq2")` will fail.

### Step 5 — Verification

For every package in `all_pkgs`, the script tries to `require()` it. Packages that fail to load are collected into `failed`. A single success / failure message is printed at the end.

**Interpretation:**
Even if `install.packages()` returns silently, a package may still fail to load (e.g. because of a missing system library on Linux). The verification loop catches that.

### Step 6 — Version report

Builds a small data frame with one row per package and prints it to the console. The same data frame is saved to `results/package_versions.csv` in Step 7.

**Interpretation:**
The CSV is your **reproducibility receipt**: commit it to your project or paste it into a methods section so reviewers know exactly which package versions produced your results.

### Step 7 — Project folders and report save

Creates four folders in your working directory:

- `data/` — input datasets (e.g. TCGA CSVs)
- `figures/` — exported plots
- `results/` — tables, model outputs, the version report
- `results_rnaseq/` — RNA-seq specific outputs (DESeq2 results, enrichment tables)

The version report is written to `results/package_versions.csv`.

---

## 🎉 7. Expected Output

When everything works, the console will show:

```
Installing from CRAN: tidyverse, scales, patchwork, ...
Installing from Bioconductor: DESeq2, apeglm, clusterProfiler, ...

✅ All 26 packages installed and loaded successfully.

   package            version
1  tidyverse          2.0.0
2  scales             1.3.0
3  patchwork          1.2.0
4  RColorBrewer       1.1.3
5  viridis            0.6.5
6  colorspace         2.1.0
7  ggsci              3.0.0
8  ggrepel            0.9.5
9  forcats            1.0.0
10 ggpubr             0.6.0
... (and so on for all 26)

Project folders ready: data/, figures/, results/, results_rnaseq/
Version report saved to results/package_versions.csv
```

- **26 packages** in total: **21 from CRAN** + **5 from Bioconductor**.
- Four folders created in the working directory: `data/`, `figures/`, `results/`, `results_rnaseq/`.
- One CSV written: `results/package_versions.csv`.

**Write the code in the Editor:**

Nothing to write — just look at the console output above.

**Interpretation:**
The exact version numbers will depend on the day you run the script (CRAN and Bioconductor are continuously updated). What matters is that **all 26 rows say something other than `NOT INSTALLED`**.

---

## 🛠️ 8. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `package 'X' failed to install` | A dependency is missing or a binary is not available for your R version. | Re-run the script (it is safe); if it still fails, install that one package alone to see the full error, e.g. `install.packages("X")`. |
| Compilation error on **Windows** (e.g. "Rtools not found") | Rtools is missing or the wrong version is installed. | Install Rtools matching your R version from [CRAN](https://cran.r-project.org/bin/windows/Rtools/), restart R, re-run. |
| Compilation error on **macOS** (e.g. "clang: command not found") | Xcode Command Line Tools are missing. | Run `xcode-select --install` in the Terminal, restart R, re-run. |
| `Bioconductor version 'X.Y' is not available` (or similar version mismatch) | Your Bioconductor version is out of sync with your R version. | Update BiocManager from CRAN, then call `BiocManager::install(version = "3.18")` (or whatever matches your R) before re-running the script. |
| `cannot open file '.../library/...': Permission denied` | Your R library folder is owned by another user. | Either run R as the user who owns the library, or set a personal library: `R.home(component = "library")`, then `install.packages(...)` will use it. |
| Download hangs / times out | Slow or unstable internet, or corporate firewall. | Re-run the script (it picks up where it left off). If it keeps timing out, raise the timeout further (e.g. 1200) in Step 0, or use a closer CRAN mirror. |
| First `library(DESeq2)` takes a long time | DESeq2 loads many compiled routines on first use. | This is normal and happens once per R session. Subsequent loads are fast. |

**Write the code in the Editor:**

```r
# See where your personal library lives
.libPaths()
```

**Interpretation:**
If `.libPaths()` returns paths you cannot write to, that is the source of "Permission denied" errors — either fix the permissions or call `.libPaths(new = "your/writable/path")` at the top of the script.

---

## ❓ 9. Quick Quiz


### Part A: Multiple choice

**Q1. Where do `DESeq2`, `clusterProfiler`, and `org.Hs.eg.db` come from?**

- A. CRAN
- B. GitHub
- C. Bioconductor
- D. They ship with base R

<details><summary>Show answer</summary>

**C.** They come from Bioconductor and are installed with `BiocManager::install()`, **not** `install.packages()`.

</details>

**Q2. Why is it safe to run `install_all_packages.R` a second time?**

- A. It deletes all packages first and reinstalls them
- B. It only installs packages that are missing
- C. It runs in a separate R session
- D. It is not safe to re-run

<details><summary>Show answer</summary>

**B.** Each install block computes `setdiff(pkgs, installed.packages())` first and skips packages that are already present, so only missing packages are installed.

</details>

**Q3. Where is the version report saved?**

- A. `figures/package_versions.png`
- B. `data/versions.txt`
- C. `results/package_versions.csv`
- D. It is only printed to the console

<details><summary>Show answer</summary>

**C.** It is saved to `results/package_versions.csv`. It records the exact version of every installed package, which is your reproducibility receipt.

</details>

---

### Part B: True or False

**Q4. If you have R older than 4.3.0, the script stops with an error.**

<details><summary>Show answer</summary>

**False.** The script only prints a **warning**. Older R will usually still work, but R 4.3 or newer is recommended.

</details>

**Q5. `BiocManager` must be installed before any Bioconductor package can be installed.**

<details><summary>Show answer</summary>

**True.** The script installs `BiocManager` first (if missing), then uses it to install `DESeq2`, `apeglm`, `clusterProfiler`, `org.Hs.eg.db`, and `enrichplot`.

</details>

---
### Part C: Select all that apply

**Q6. Which of these folders does the script create? (choose all that apply)**

- A. `data/`
- B. `figures/`
- C. `results/`
- D. `scripts/`
- E. `results_rnaseq/`

<details><summary>Show answer</summary>

**A, B, C and E.** The script creates `data/`, `figures/`, `results/`, and `results_rnaseq/`. It does **not** create `scripts/`.

</details>

---

### Part D: Fill in the blank

**Q7. The function that installs Bioconductor packages is `BiocManager::________()`.**

<details><summary>Show answer</summary>

**install**, as in `BiocManager::install()`.

</details>

**Q8. The function used to record package versions for reproducibility in the main LUAD tutorial is `________()`.**

<details><summary>Show answer</summary>

**sessionInfo**, as in `sessionInfo()`. In this script, the version table is built with `packageVersion()` and saved to a CSV file.

</details>


### Part E: Try it yourself

1. Add a new CRAN package (for example `"janitor"`) to the script, re-run it, and check that **only** the new package gets installed.
2. Open `results/package_versions.csv` and find the version of `DESeq2` that you installed.
3. Deliberately misspell one package name in `cran_pkgs`, re-run the script, and read the message in the **failed** section. What does it tell you?

<details><summary>Show hints</summary>

```r
# 1. Add the package name to the cran_pkgs vector, then run:
source("install_all_packages.R")

# 2. Read the version report in R
read.csv("results/package_versions.csv")

# 3. The failed packages are listed at the end:
# ❌ These packages failed to install or load:
```
</details>



## ✅ 10. Conclusion

You now have a single, cross-platform script that installs every package needed for the TCGA biostatistics, colour, and RNA-seq tutorials, verifies the install, prints a version report, and creates the project folders.

- **26 packages total** (21 CRAN + 5 Bioconductor).
- **One command** to run everything: `source("install_all_packages.R")`.
- **One file** to keep for reproducibility: `results/package_versions.csv`.

When the success line appears — `✅ All 26 packages installed and loaded successfully.` — you are ready to move on to the first analysis tutorial. 🎉
