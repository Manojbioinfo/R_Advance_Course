
# Tutorial 4 — Inspecting and Joining TCGA Pan-Cancer Data

This section loads the gene-expression and clinical RDS files, inspects their structure, removes exact duplicate rows, and joins them using `sample_barcode`.

The reported data contain six gene-expression columns: **BIRC5, CDKN2A, KRAS, MSLN, SMAD4, and TP53**. The dimensions shown below are the results reported from this workflow; rerunning the code on different versions of the files may produce different values.

## 1. Load packages and data

```r
rm(list = ls())

library(tidyverse)
library(scales)
library(ggpubr)

data1 <- readRDS("Data/Pan_geneexp_clean.rds")
data2 <- readRDS("Data/TCGA_pancancer_clinical.rds")
```

## 2. Inspect the data

Check the first rows, dimensions, and column names before joining.

```r
head(data1)
head(data2)

dim(data1)
dim(data2)

colnames(data1)
colnames(data2)
```

The reported dimensions are:

```text
data1: 11069 rows × 7 columns
data2: 12591 rows × 45 columns
```

The expression table includes `sample_barcode` and the six gene columns. The clinical table preview shows `patient_id`; inspect its full column names to confirm whether it also contains `sample_barcode`.

```r
intersect(colnames(data1), colnames(data2))
```

Reported output:

```text
[1] "sample_barcode"
```

This identifies `sample_barcode` as the shared column used for the join.

## 3. Remove exact duplicate rows

`distinct()` removes rows that are identical across all columns. It does not necessarily make `sample_barcode` unique, so check for repeated barcodes before interpreting the join.

```r
data1_clean <- data1 %>% distinct()
data2_clean <- data2 %>% distinct()

# Check whether each barcode occurs only once in each table
anyDuplicated(data1_clean$sample_barcode)
anyDuplicated(data2_clean$sample_barcode)

# Count rows and unique barcodes
nrow(data1_clean)
nrow(data2_clean)

n_distinct(data1_clean$sample_barcode)
n_distinct(data2_clean$sample_barcode)
```

## 4. Join by `sample_barcode`

An `inner_join()` keeps rows with matching `sample_barcode` values in both tables.

```r
data3 <- inner_join(
  data1_clean,
  data2_clean,
  by = "sample_barcode"
)
```

Inspect the joined data:

```r
dim(data3)
head(data3)
colnames(data3)
```

The reported joined dimensions are:

```text
data3: 9672 rows × 51 columns
```

The 51 columns are consistent with combining 7 expression-table columns and 45 clinical-table columns, with the shared `sample_barcode` appearing once.

## 5. Check the join results

Compare the number of joined rows with the number of shared barcodes. If either input contains repeated barcodes, a join may produce more than one row per barcode.

```r
shared_barcodes <- intersect(
  data1_clean$sample_barcode,
  data2_clean$sample_barcode
)

length(shared_barcodes)
nrow(data3)

# Check for repeated barcodes in the joined table
anyDuplicated(data3$sample_barcode)
```

If the join produces repeated barcodes, inspect them before continuing:

```r
data3 %>%
  count(sample_barcode, sort = TRUE) %>%
  filter(n > 1)
```

## What to note

- `inner_join()` retains only barcodes found in both tables; rows without a match are excluded.
- `distinct()` removes exact duplicate rows, but does not guarantee one row per barcode.
- The reported dimensions are **11,069 × 7** for `data1`, **12,591 × 45** for `data2`, and **9,672 × 51** for `data3`.
- Confirm that `sample_barcode` represents the intended observation unit and that repeated barcodes are handled appropriately before downstream analysis.

## Next step

After verifying the joined rows and barcode multiplicity, define the specific clinical or biological question for the next analysis section.
