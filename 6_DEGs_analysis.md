---
title: "Tutorial 5: RNA-seq DESeq2 and Pathway Analysis"
output:
  md_document:
    variant: gfm
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)
```

# Tutorial 5 — RNA-seq differential expression, pathways, and reproducibility

This tutorial expects `data/expression_counts.csv` (genes in rows, raw integer counts in columns) and `data/clinical_data.csv`. It keeps tumour aliquots (`-01`), matches a barcode's first 12 characters to clinical `ID`, and uses `Age + Race + Vital_Status` as the design. All biological outputs go to `results_rnaseq/`; plots go to `figures/`.

```{r load}
library(tidyverse); library(DESeq2); library(apeglm); library(ggrepel); library(pheatmap); library(clusterProfiler); library(org.Hs.eg.db); library(enrichplot)
dir.create("figures", showWarnings=FALSE); dir.create("results_rnaseq", showWarnings=FALSE)
clinical <- read_csv("data/clinical_data.csv", show_col_types=FALSE)
counts_raw <- read_csv("data/expression_counts.csv", show_col_types=FALSE)
stopifnot(all(c("ID","Age","Race","Vital_Status") %in% names(clinical)))
gene_col <- names(counts_raw)[1]; count_mat <- counts_raw |> column_to_rownames(gene_col) |> as.matrix()
mode(count_mat) <- "numeric"
```

## Question 1 — What is the sample unit and how do barcodes match?

**Hint:** TCGA participant identity is the first 12 barcode characters; sample type is encoded in positions 14–15.
```{r q1}
barcodes <- colnames(count_mat)
tumour <- grepl("-01[A-Z]?-", barcodes) | grepl("-01", barcodes)
# Robustly retain barcodes whose sample portion starts with 01.
sample_type <- substr(barcodes, 14, 15)
tumour <- sample_type == "01"
stopifnot(any(tumour))
tumour_barcodes <- barcodes[tumour]
patient_ids <- substr(tumour_barcodes, 1, 12)
pheno <- clinical |> mutate(ID=as.character(ID)) |> filter(ID %in% patient_ids) |> distinct(ID, .keep_all=TRUE)
pheno <- pheno[match(patient_ids, pheno$ID),,drop=FALSE]
stopifnot(!anyNA(pheno$ID), identical(pheno$ID, patient_ids))
```

## Question 2 — How do we align columns to phenotype safely?

**Hint:** explicit matching plus `stopifnot()` prevents silent sample swaps.
```{r q2}
count_mat <- count_mat[, tumour_barcodes, drop=FALSE]
colnames(count_mat) <- patient_ids
stopifnot(identical(colnames(count_mat), pheno$ID), ncol(count_mat)==nrow(pheno))
pheno <- pheno |> mutate(Age_scaled=as.numeric(scale(Age)), Race=factor(Race), Vital_Status=factor(Vital_Status)) |> as.data.frame()
rownames(pheno) <- pheno$ID
```

## Question 3 — Why filter low-count genes?

**Hint:** require a modest count in enough samples to reduce noise, then use integer counts in DESeq2.
```{r q3}
count_mat <- round(count_mat)
keep <- rowSums(count_mat >= 10) >= max(3, ceiling(0.1*ncol(count_mat)))
count_filt <- count_mat[keep,,drop=FALSE]
write_csv(tibble(gene=rownames(count_filt), kept=TRUE), "results_rnaseq/filtered_genes.csv")
```

## Question 4 — What is the DESeq2 model?

**Hint:** the reference levels matter; inspect them before interpreting coefficients.
```{r q4}
dds <- DESeqDataSetFromMatrix(countData=count_filt, colData=pheno, design=~ Age_scaled + Race + Vital_Status)
dds <- dds[rowSums(counts(dds)) > 0,]
dds <- DESeq(dds)
writeLines(resultsNames(dds), "results_rnaseq/results_names.txt")
```

## Question 5 — What does variance-stabilizing transformation show?

**Hint:** PCA is exploratory and should be labelled as such.
```{r q5}
vsd <- vst(dds, blind=FALSE)
pca <- plotPCA(vsd, intgroup=c("Vital_Status","Race")) + theme_minimal()
ggsave("figures/rnaseq_pca.png", pca, width=8, height=6, dpi=300)
```

## Question 6 — How do we extract a shrunken contrast?

**Hint:** use `resultsNames(dds)` rather than guessing the coefficient name.
```{r q6}
status_name <- grep("Vital_Status", resultsNames(dds), value=TRUE)[1]
if (is.na(status_name) || is.null(status_name)) stop("No Vital_Status coefficient found; inspect resultsNames(dds).")
res <- results(dds, name=status_name)
# apeglm is preferred when its coefficient is available; normal shrinkage is a fallback for teaching environments.
res_shrunk <- tryCatch(lfcShrink(dds, coef=status_name, type="apeglm"), error=function(e) lfcShrink(dds, coef=status_name, type="normal"))
res_df <- as.data.frame(res_shrunk) |> rownames_to_column("gene") |> arrange(padj)
write_csv(res_df, "results_rnaseq/deseq2_all_results.csv")
```

## Question 7 — Which genes are DEGs?

**Hint:** predeclare both an FDR threshold and a biological fold-change threshold.
```{r q7}
degs <- res_df |> filter(!is.na(padj), padj < 0.05, abs(log2FoldChange) >= 1) |> mutate(direction=if_else(log2FoldChange>0,"up","down"))
write_csv(degs, "results_rnaseq/deseq2_DEGs_padj005_absLFC1.csv")
```

## Question 8 — How do we visualize the volcano?

**Hint:** label only a small set of significant genes to keep the plot readable.
```{r q8}
volc <- res_df |> mutate(sig=!is.na(padj) & padj<.05 & abs(log2FoldChange)>=1, label=if_else(sig & rank(padj, ties.method="first")<=15, gene, NA_character_), neglog10=-log10(pmax(padj, .Machine$double.xmin)))
pvolc <- ggplot(volc, aes(log2FoldChange, neglog10, colour=sig)) + geom_point(alpha=.6) + geom_text_repel(aes(label=label), na.rm=TRUE, max.overlaps=20) + scale_colour_manual(values=c(`FALSE`="grey70", `TRUE`="#D55E00")) + theme_minimal() + labs(title="DESeq2 volcano plot", x="Shrunken log2 fold change", y="-log10 adjusted p-value")
ggsave("figures/rnaseq_volcano.png", pvolc, width=8, height=6, dpi=300)
```

## Question 9 — What does a heatmap of top genes show?

**Hint:** heatmaps display transformed expression and sample annotations, not raw count tests.
```{r q9}
top <- head(degs$gene, 30); top <- intersect(top, rownames(assay(vsd)))
if(length(top)>1) pheatmap(assay(vsd)[top,,drop=FALSE], annotation_col=pheno[,c("Vital_Status","Race"),drop=FALSE], filename="figures/rnaseq_top_genes_heatmap.png")
```

## Question 10 — How do gene symbols map to Entrez IDs?

**Hint:** mapping is many-to-many and incomplete; report how many mapped.
```{r q10}
map <- bitr(degs$gene, fromType="SYMBOL", toType="ENTREZID", OrgDb=org.Hs.eg.db) |> distinct(SYMBOL, .keep_all=TRUE)
write_csv(map, "results_rnaseq/gene_symbol_entrez_mapping.csv")
```

## Question 11 — What pathways are enriched among up/down genes?

**Hint:** run GO BP and KEGG separately by direction, and save tables.
```{r q11}
run_ora <- function(symbols, prefix) {
  ids <- unique(map$ENTREZID[map$SYMBOL %in% symbols])
  if(length(ids)<5) return(NULL)
  ego <- enrichGO(ids, OrgDb=org.Hs.eg.db, keyType="ENTREZID", ont="BP", pAdjustMethod="BH", readable=TRUE)
  ekegg <- tryCatch(enrichKEGG(ids, organism="hsa", pAdjustMethod="BH"), error=function(e) NULL)
  if(!is.null(ego)) write_csv(as.data.frame(ego), paste0("results_rnaseq/GO_BP_",prefix,".csv"))
  if(!is.null(ekegg)) write_csv(as.data.frame(ekegg), paste0("results_rnaseq/KEGG_",prefix,".csv"))
  list(go=ego,kegg=ekegg)
}
up <- degs |> filter(direction=="up") |> pull(gene); down <- degs |> filter(direction=="down") |> pull(gene)
ora_up <- run_ora(up,"up"); ora_down <- run_ora(down,"down")
```

## Question 12 — What is GSEA and why use the full ranked list?

**Hint:** rank by a signed statistic, avoiding an arbitrary DEG cutoff.
```{r q12}
ranks <- res_df |> filter(!is.na(stat), !duplicated(gene)) |> arrange(desc(stat))
gene_list <- ranks$stat; names(gene_list) <- ranks$gene
rank_map <- bitr(names(gene_list), fromType="SYMBOL", toType="ENTREZID", OrgDb=org.Hs.eg.db) |> distinct(SYMBOL, .keep_all=TRUE)
gene_list <- gene_list[rank_map$SYMBOL]; names(gene_list) <- rank_map$ENTREZID; gene_list <- sort(gene_list, decreasing=TRUE)
if(length(gene_list)>=10) { gsea <- gseGO(geneList=gene_list, OrgDb=org.Hs.eg.db, keyType="ENTREZID", ont="BP", verbose=FALSE); write_csv(as.data.frame(gsea), "results_rnaseq/GSEA_GO_BP.csv"); if(nrow(as.data.frame(gsea))>0) ggsave("figures/rnaseq_gsea_dotplot.png", dotplot(gsea, showCategory=15), width=9, height=7, dpi=300) }
```

## Quiz (answers hidden)

<details><summary>1. Why must counts be raw integers?</summary>DESeq2 models count distributions; transformed or normalized values are not valid count input.</details>
<details><summary>2. Why align phenotype explicitly?</summary>Because a column swap can produce plausible-looking but invalid biology.</details>
<details><summary>3. What does padj control?</summary>An adjusted false-discovery criterion across the tested gene family, under the selected correction.</details>
<details><summary>4. Why inspect resultsNames?</summary>Coefficient names depend on factor levels and design; inspecting avoids extracting the wrong contrast.</details>
<details><summary>5. What are ORA and GSEA limitations?</summary>They depend on annotation coverage, gene universe/ranking choices, dependence among genes, and multiple-testing control; enrichment is not causation.</details>
