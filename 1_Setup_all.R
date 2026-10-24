# =============================================================================
# install_all_packages.R
# One-shot installer for the TCGA biostatistics and colour tutorials
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
  "DESeq2", "clusterProfiler", "org.Hs.eg.db", "enrichplot", "apeglm"
)

# ---- 2. Helper: install only what is missing --------------------------------
install_missing <- function(pkgs) {
  missing <- setdiff(pkgs, rownames(installed.packages()))
  if (length(missing) == 0) {
    message("All CRAN packages already installed.")
    return(invisible(character(0)))
  }
  message("Installing from CRAN: ", paste(missing, collapse = ", "))
  install.packages(missing, dependencies = TRUE)
  invisible(missing)
}

# ---- 3. Check R version -----------------------------------------------------
if (getRversion() < "4.3.0") {
  warning("R ", getRversion(), " detected. R 4.3 or newer is recommended.")
}

# ---- 4. Install CRAN packages -----------------------------------------------
install_missing(cran_pkgs)

# ---- 5. Install Bioconductor packages ---------------------------------------
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

# ---- 6. Verify everything loads ---------------------------------------------
all_pkgs <- c(cran_pkgs, bioc_pkgs)
failed <- character(0)
for (p in all_pkgs) {
  ok <- suppressWarnings(suppressPackageStartupMessages(
    requireNamespace(p, quietly = TRUE)
  ))
  if (!ok) failed <- c(failed, p)
}

if (length(failed) == 0) {
  message("\n✅ All ", length(all_pkgs), " packages installed and loadable.")
} else {
  message("\n❌ These packages failed to install or load:")
  message("   ", paste(failed, collapse = ", "))
  message("   Try re-running this script, or install them one at a time to see the error.")
}

# ---- 7. Create project folders ----------------------------------------------
for (d in c("data", "figures", "results", "results_rnaseq")) {
  dir.create(d, showWarnings = FALSE)
}
message("Project folders ready: data/, figures/, results/, results_rnaseq/")
