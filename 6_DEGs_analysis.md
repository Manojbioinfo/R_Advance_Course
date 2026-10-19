# Tutorial 5: RNA-seq Differential Expression, Pathways, and Reproducibility

This tutorial takes you from a raw count matrix to differentially expressed genes (DEGs) and pathway results. It expects two files in `data/`:

- `expression_counts.csv`: genes in rows, **raw integer counts** in columns (TCGA barcodes as column names)
- `clinical_data.csv`: one row per patient with `ID`, `Age`, `Race`, `Vital_Status`

It keeps tumour aliquots (sample type `01`), matches the first 12 barcode characters to clinical `ID`, and fits the design `~ Age_scaled + Race + Vital_Status`. Tables are written to `results_rnaseq/` and plots to `figures/`.

## Table of contents

1. [Learning objectives](#learning-objectives)
2. [Pipeline overview](#pipeline-overview)
3. [Before you start](#before-you-start)
4. [Part 1: Match samples to phenotype](#part-1-match-samples-to-phenotype)
5. [Part 2: Filter and model](#part-2-filter-and-model)
6. [Part 3: Quality control and exploration](#part-3-quality-control-and-exploration)
7. [Part 4: Differential expression results](#part-4-differential-expression-results)
8. [Part 5: Pathway analysis](#part-5-pathway-analysis)
9. [Part 6: Reproducibility](#part-6-reproducibility)
10. [Common mistakes](#common-mistakes)
11. [Practice exercises](#practice-exercises)
12. [Quiz](#quiz)

## Learning objectives

By the end you will be able to:

- Match TCGA barcodes to clinical patients without silent sample swaps.
- Filter low-count genes and fit a DESeq2 model with covariates.
- Explore data with PCA and library-size checks.
- Extract shrunken log2 fold changes and call DEGs with FDR and effect-size thresholds.
- Draw volcano, MA, and heatmap figures.
- Run over-representation analysis (ORA) and GSEA, and state their limitations.
- Record the software environment for reproducibility.

## Pipeline overview

| Step | Question | Output |
|---|---|---|
| 1 | Which columns are tumours, and who are the patients? | matched counts + phenotype |
| 2 | Which genes have enough counts to model? | filtered matrix |
| 3 | Does the data look sane? | PCA, library sizes |
| 4 | Which genes differ by vital status? | DEG tables, volcano, MA, heatmap |
| 5 | Which pathways are enriched? | GO, KEGG, GSEA tables |
| 6 | Can someone reproduce this? | session info |

## Before you start

```r
library(tidyverse); library(DESeq2); library(apeglm); library(ggrepel)
library(pheatmap); library(clusterProfiler); library(org.Hs.eg.db); library(enrichplot)

dir.create("figures", showWarnings = FALSE)
dir.create("results_rnaseq", showWarnings = FALSE)

clinical   <- read_csv("data/clinical_data.csv", show_col_types = FALSE)
counts_raw <- read_csv("data/expression_counts.csv", show_col_types = FALSE)

stopifnot(all(c("ID", "Age", "Race", "Vital_Status") %in% names(clinical)))

gene_col  <- names(counts_raw)[1]
count_mat <- counts_raw |> column_to_rownames(gene_col) |> as.matrix()
mode(count_mat) <- "numeric"

dim(count_mat)   # genes x samples
```

**What to look for:** Thousands of genes (rows) and one column per sample. If the row names are not gene symbols, the pathway steps will not map correctly.

## Part 1: Match samples to phenotype

### Q1. What is the sample unit, and how do barcodes match?

**Hint:** The participant is the first 12 barcode characters. The sample type is at positions 14-15, and `01` means primary tumour.

```r
barcodes    <- colnames(count_mat)
sample_type <- substr(barcodes, 14, 15)
table(sample_type)   # how many tumour (01), normal (11), etc.

tumour <- sample_type == "01"
stopifnot(any(tumour))

tumour_barcodes <- barcodes[tumour]
patient_ids     <- substr(tumour_barcodes, 1, 12)

# Keep one tumour aliquot per patient so IDs stay unique
dup <- duplicated(patient_ids)
cat("Dropping", sum(dup), "duplicate tumour aliquots\n")
tumour_barcodes <- tumour_barcodes[!dup]
patient_ids     <- patient_ids[!dup]
```

**What to look for:** Most TCGA cohorts are mostly `01`. A few duplicated patients are normal. A large number of drops deserves investigation.

### Q2. How do we align columns to phenotype safely?

**Hint:** Match explicitly and use `stopifnot()` so a sample swap cannot pass silently.

```r
pheno <- clinical |>
  mutate(ID = as.character(ID)) |>
  filter(ID %in% patient_ids) |>
  distinct(ID, .keep_all = TRUE)

# Keep only patients present in both tables
common <- intersect(patient_ids, pheno $ ID)
cat(length(common), "of", length(patient_ids), "tumour patients have clinical data\n")

keep_idx        <- patient_ids %in% common
tumour_barcodes <- tumour_barcodes[keep_idx]
patient_ids     <- patient_ids[keep_idx]
pheno           <- pheno[match(patient_ids, pheno $ ID), , drop = FALSE]

count_mat <- count_mat[, tumour_barcodes, drop = FALSE]
colnames(count_mat) <- patient_ids

stopifnot(identical(colnames(count_mat), pheno $ ID), ncol(count_mat) == nrow(pheno))

pheno <- pheno |>
  mutate(Age_scaled   = as.numeric(scale(Age)),
         Race         = factor(Race),
         Vital_Status = factor(Vital_Status)) |>
  as.data.frame()
rownames(pheno) <- pheno $ ID

# Set Alive as the reference so a positive log2FC means higher in Dead
if ("Alive" %in% levels(pheno $ Vital_Status)) {
  pheno $ Vital_Status <- relevel(pheno $ Vital_Status, ref = "Alive")
}
table(pheno $ Vital_Status)
```

**What to look for:** Both groups should have enough samples. Very small groups give unstable results.

## Part 2: Filter and model

### Q3. Why filter low-count genes?

**Hint:** Require a modest count in enough samples to reduce noise. DESeq2 needs integer counts.

```r
count_mat <- round(count_mat)

keep <- rowSums(count_mat >= 10) >= max(3, ceiling(0.1 * ncol(count_mat)))
count_filt <- count_mat[keep, , drop = FALSE]

cat("Kept", nrow(count_filt), "of", nrow(count_mat), "genes\n")
write_csv(tibble(gene = rownames(count_filt)), "results_rnaseq/filtered_genes.csv")
```

**What to look for:** Typically a third to two thirds of genes survive. Filtering also reduces the multiple-testing burden.

### Q4. What is the DESeq2 model?

**Hint:** Reference levels matter. Always inspect them before interpreting coefficients.

```r
dds <- DESeqDataSetFromMatrix(countData = count_filt, colData = pheno,
                              design = ~ Age_scaled + Race + Vital_Status)
dds <- dds[rowSums(counts(dds)) > 0, ]
dds <- DESeq(dds)

resultsNames(dds)
writeLines(resultsNames(dds), "results_rnaseq/results_names.txt")
```

**What to look for:** A coefficient like `Vital_Status_Dead_vs_Alive`. The name tells you the direction of the comparison.

## Part 3: Quality control and exploration

### Q5. Are library sizes reasonable?

**Hint:** Very uneven library sizes can drive technical differences.

```r
lib <- tibble(sample = colnames(dds), total_counts = colSums(counts(dds))) |>
  left_join(pheno |> select(ID, Vital_Status), by = c("sample" = "ID"))

p_lib <- ggplot(lib, aes(total_counts / 1e6, fill = Vital_Status)) +
  geom_histogram(bins = 30, alpha = .8) +
  theme_minimal() + labs(x = "Total counts (millions)", y = "Samples")
p_lib
ggsave("figures/rnaseq_library_sizes.png", p_lib, width = 7, height = 5, dpi = 300)
```

**What to look for:** A fairly tight spread. Extreme outliers deserve a closer look.

### Q6. What does variance-stabilizing transformation show?

**Hint:** PCA is exploratory. Label it as such and do not over-interpret.

```r
vsd <- vst(dds, blind = FALSE)

pca <- plotPCA(vsd, intgroup = c("Vital_Status", "Race")) + theme_minimal()
pca
ggsave("figures/rnaseq_pca.png", pca, width = 8, height = 6, dpi = 300)
```

**What to look for:** Do samples separate by vital status, or by something technical or demographic? Clear separation by an unexpected factor is a warning sign.

## Part 4: Differential expression results

### Q7. How do we extract a shrunken contrast?

**Hint:** Use `resultsNames(dds)` to find the coefficient, never guess.

```r
status_name <- grep("^Vital_Status", resultsNames(dds), value = TRUE)
if (length(status_name) != 1) {
  stop("Expected exactly one Vital_Status coefficient; inspect resultsNames(dds).")
}
status_name

res <- results(dds, name = status_name)

# apeglm shrinkage preferred; "normal" is a fallback
res_shrunk <- tryCatch(
  lfcShrink(dds, coef = status_name, type = "apeglm"),
  error = function(e) lfcShrink(dds, coef = status_name, type = "normal")
)

res_df <- as.data.frame(res_shrunk) |>
  rownames_to_column("gene") |>
  arrange(padj)

head(res_df)
write_csv(res_df, "results_rnaseq/deseq2_all_results.csv")
```

**What to look for:** Shrinkage pulls noisy fold changes toward zero, which makes ranking more reliable than raw estimates.

### Q8. Which genes are DEGs?

**Hint:** Pre-declare both an FDR threshold and a fold-change threshold.

```r
degs <- res_df |>
  filter(!is.na(padj), padj < 0.05, abs(log2FoldChange) >= 1) |>
  mutate(direction = if_else(log2FoldChange > 0, "up", "down"))

table(degs$direction)
write_csv(degs, "results_rnaseq/deseq2_DEGs_padj005_absLFC1.csv")
```

**What to look for:** With few DEGs, consider relaxing the fold-change threshold. Decide this before looking at results, not after.

### Q9. How do we visualize the volcano?

**Hint:** Label only a small set of significant genes to keep it readable.

```r
volc <- res_df |>
  mutate(sig = !is.na(padj) & padj < .05 & abs(log2FoldChange) >= 1,
         label = if_else(sig & rank(padj, ties.method = "first") <= 15, gene, NA_character_),
         neglog10 = -log10(pmax(padj, .Machine$double.xmin)))

pvolc <- ggplot(volc, aes(log2FoldChange, neglog10, colour = sig)) +
  geom_point(alpha = .6) +
  geom_text_repel(aes(label = label), na.rm = TRUE, max.overlaps = 20) +
  scale_colour_manual(values = c(`FALSE` = "grey70", `TRUE` = "#D55E00")) +
  theme_minimal() +
  labs(title = "DESeq2 volcano plot", x = "Shrunken log2 fold change",
       y = "-log10 adjusted p-value", colour = "DEG")
pvolc
ggsave("figures/rnaseq_volcano.png", pvolc, width = 8, height = 6, dpi = 300)
```

**What to look for:** The strongest hits sit top-left and top-right.

### Q10. What does an MA plot show?

**Hint:** It plots fold change against mean expression and reveals expression-dependent bias.

```r
png("figures/rnaseq_ma_plot.png", width = 2400, height = 1800, res = 300)
plotMA(res_shrunk, ylim = c(-4, 4), main = "MA plot (shrunken LFC)")
dev.off()

plotMA(res_shrunk, ylim = c(-4, 4), main = "MA plot (shrunken LFC)")
```

**What to look for:** The cloud should be centred on zero. Very low-expression genes show wide scatter.

### Q11. What does a heatmap of top genes show?

**Hint:** Heatmaps show transformed expression with annotations, not raw count tests.

```r
top <- intersect(head(degs$gene, 30), rownames(assay(vsd)))

if (length(top) > 1) {
  pheatmap(assay(vsd)[top, , drop = FALSE],
           scale = "row",
           annotation_col = pheno[, c("Vital_Status", "Race"), drop = FALSE],
           show_colnames = FALSE,
           filename = "figures/rnaseq_top_genes_heatmap.png")
} else {
  message("Fewer than 2 DEGs: heatmap skipped.")
}
```

**What to look for:** Do samples cluster by vital status? Often they only partly do, which is normal for clinical outcomes.

## Part 5: Pathway analysis

### Q12. How do gene symbols map to Entrez IDs?

**Hint:** Mapping is many-to-many and incomplete. Report how many mapped.

```r
map <- bitr(degs$gene, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Hs.eg.db) |>
  distinct(SYMBOL, .keep_all = TRUE)

cat(nrow(map), "of", nrow(degs), "DEGs mapped to Entrez IDs\n")
write_csv(map, "results_rnaseq/gene_symbol_entrez_mapping.csv")
```

**What to look for:** Some symbols will not map. This is normal, but report the fraction.

### Q13. What pathways are enriched among up and down genes?

**Hint:** Run GO BP and KEGG separately by direction, with all tested genes as the background universe.

```r
# Background = every gene that was tested
universe_map <- bitr(res_df $ gene, fromType = "SYMBOL", toType = "ENTREZID",
                     OrgDb = org.Hs.eg.db) |> distinct(SYMBOL, .keep_all = TRUE)
universe <- unique(universe_map $ ENTREZID)

run_ora <- function(symbols, prefix) {
  ids <- unique(map $ ENTREZID[map $ SYMBOL %in% symbols])
  if (length(ids) < 5) { message(prefix, ": too few genes for ORA"); return(NULL) }

  ego <- enrichGO(ids, universe = universe, OrgDb = org.Hs.eg.db, keyType = "ENTREZID",
                  ont = "BP", pAdjustMethod = "BH", readable = TRUE)
  ekegg <- tryCatch(enrichKEGG(ids, universe = universe, organism = "hsa",
                               pAdjustMethod = "BH"),
                    error = function(e) NULL)

  if (!is.null(ego))   write_csv(as.data.frame(ego),   paste0("results_rnaseq/GO_BP_", prefix, ".csv"))
  if (!is.null(ekegg)) write_csv(as.data.frame(ekegg), paste0("results_rnaseq/KEGG_", prefix, ".csv"))
  list(go = ego, kegg = ekegg)
}

up   <- degs |> filter(direction == "up")   |> pull(gene)
down <- degs |> filter(direction == "down") |> pull(gene)

ora_up   <- run_ora(up,   "up")
ora_down <- run_ora(down, "down")

if (!is.null(ora_up $ go) && nrow(as.data.frame(ora_up $ go)) > 0) {
  dotplot(ora_up$go, showCategory = 10) + ggtitle("GO BP: up in Dead")
}
```

**What to look for:** Enrichment depends on annotation coverage and the background you choose. Treat results as hypotheses.

### Q14. What is GSEA, and why use the full ranked list?

**Hint:** Rank by a signed statistic, which avoids an arbitrary DEG cutoff.

```r
ranks <- res_df |>
  filter(!is.na(stat), !duplicated(gene)) |>
  arrange(desc(stat))

gene_list <- ranks $ stat
names(gene_list) <- ranks $ gene

rank_map <- bitr(names(gene_list), fromType = "SYMBOL", toType = "ENTREZID",
                 OrgDb = org.Hs.eg.db) |> distinct(SYMBOL, .keep_all = TRUE)

gene_list <- gene_list[rank_map $ SYMBOL]
names(gene_list) <- rank_map $ ENTREZID
gene_list <- sort(gene_list, decreasing = TRUE)

if (length(gene_list) >= 10) {
  gsea <- gseGO(geneList = gene_list, OrgDb = org.Hs.eg.db, keyType = "ENTREZID",
                ont = "BP", verbose = FALSE)
  write_csv(as.data.frame(gsea), "results_rnaseq/GSEA_GO_BP.csv")

  if (nrow(as.data.frame(gsea)) > 0) {
    p_gsea <- dotplot(gsea, showCategory = 15)
    p_gsea
    ggsave("figures/rnaseq_gsea_dotplot.png", p_gsea, width = 9, height = 7, dpi = 300)
  }
}
```

**What to look for:** Positive enrichment scores mean the pathway is enriched among genes higher in Dead, negative among genes higher in Alive.

## Part 6: Reproducibility

### Q15. How do we record the environment?

**Hint:** Save session info and the key analysis parameters alongside results.

```r
writeLines(capture.output(sessionInfo()), "results_rnaseq/session_info.txt")

params <- tibble(
  parameter = c("design", "min_count_filter", "padj_threshold", "lfc_threshold", "n_samples", "n_genes_tested"),
  value     = c("~ Age_scaled + Race + Vital_Status", ">=10 counts in >=10% samples (min 3)",
                "0.05", "1", ncol(dds), nrow(dds))
)
params
write_csv(params, "results_rnaseq/analysis_parameters.csv")
```

**What to look for:** Anyone reading `results_rnaseq/` should be able to see exactly how the numbers were produced.

## Common mistakes

- Feeding normalized or log-transformed values to DESeq2 instead of raw counts.
- Misaligned samples between the count matrix and phenotype table.
- Interpreting a coefficient without checking the reference level.
- Choosing thresholds after looking at the DEG list.
- Running enrichment against the whole genome rather than the tested genes.
- Reading enrichment as proof of mechanism.

## Practice exercises

1. Repeat the analysis with a stricter threshold (`padj < 0.01`, `|log2FC| >= 1.5`). How does the DEG count change?
2. Add `Gender` to the design and compare the top 20 genes with the original model.
3. Run `enrichGO()` with `ont = "MF"` instead of `"BP"` and compare the top terms.

## Quiz

<details><summary>1. Why must counts be raw integers?</summary>

DESeq2 models count distributions, and transformed or normalized values are not valid count input.

</details>

<details><summary>2. Why align phenotype explicitly?</summary>

A column swap can produce plausible-looking but invalid biology.

</details>

<details><summary>3. What does padj control?</summary>

An adjusted false-discovery criterion across the tested gene family, under the selected correction.

</details>

<details><summary>4. Why inspect resultsNames?</summary>

Coefficient names depend on factor levels and design, so inspecting avoids extracting the wrong contrast.

</details>

<details><summary>5. What are ORA and GSEA limitations?</summary>

They depend on annotation coverage, gene universe and ranking choices, dependence among genes, and multiple-testing control. Enrichment is not causation.

</details>
