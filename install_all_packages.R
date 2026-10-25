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
