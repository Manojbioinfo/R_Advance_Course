### Setup

Run this once from the course root folder.

```r
# 1. CRAN packages
cran <- c(
  "tidyverse",
  "ggpubr",
  "patchwork",
  "RColorBrewer",
  "scales",
  "survival",
  "survminer",
  "rstatix",
  "effectsize",
  "car",
  "FSA",
  "broom",
  "ggrepel",
  "pheatmap",
  "rmarkdown",
  "knitr"
)

install.packages(
  setdiff(cran, rownames(installed.packages())),
  repos = "https://cloud.r-project.org"
)

# 2. BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

# 3. Bioconductor packages
bioc <- c(
  "DESeq2",
  "clusterProfiler",
  "org.Hs.eg.db",
  "enrichplot",
  "apeglm"
)

BiocManager::install(
  setdiff(bioc, rownames(installed.packages())),
  ask = FALSE,
  update = FALSE
)

# 4. Create project folders
dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)
dir.create("results_rnaseq", showWarnings = FALSE)

message("Setup complete. Place clinical_data.csv and expression_counts.csv in data/.")
```
