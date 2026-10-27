
# Tutorial 4 — Inspecting and joining TCGA pancreatic data

> **Next step (placeholder):** After confirming the join key and row multiplicity, continue with the intended downstream analysis. No downstream analysis is specified here.

This note records the R workflow and dimensions as reported, then explains what the merge does and how to check the key before relying on the result. The `.rds` data files are not included here, so the printed dimensions below are reported observations, not results re-run for this tutorial.

## 1. Load packages and read the data

```r
library(tidyverse)
library(scales)
library(ggpubr)

data1 <- readRDS("Data/Pan_geneexp_clean.rds")
data2 <- readRDS("Data/TCGA_pancancer_clinical.rds")
```

## 2. Inspect tables and candidate key

```r
head(data1)
head(data2)

intersect(colnames(data1), colnames(data2))
```

The reported intersection contained only `"sample_barcode"`. The clinical `head()` output reportedly showed `patient_id`. These observations are a reason to inspect the complete schemas: `head()` displays only a few rows (and, for wide objects, may not reveal every column), so `patient_id` may coexist with a `sample_barcode` column. Confirm the actual names and values in both loaded objects before choosing a key.

```r
names(data1)
names(data2)
dim(data1)
dim(data2)

"sample_barcode" %in% names(data1)
"sample_barcode" %in% names(data2)
"patient_id" %in% names(data1)
"patient_id" %in% names(data2)

# Review types, missing values, and example values for candidate identifiers
str(data1[c(intersect(c("sample_barcode", "patient_id"), names(data1)))])
str(data2[c(intersect(c("sample_barcode", "patient_id"), names(data2)))])
```

If either candidate key is absent from a table, do not join on it. If `patient_id` is the intended biological unit but expression data only have `sample_barcode`, identify and validate a sample-to-patient mapping rather than treating the two identifiers as interchangeable.

## 3. The observed base R merge

The reported code was:

```r
data3 = merge(data1, data2, "sample_barcode")
dim(data3)
```

Reported dimensions:

```text
data1: 11069 rows × 7 columns
data2: 12591 rows × 45 columns
data3: 11131 rows × 51 columns
```

In base R, the third actual argument in `merge(data1, data2, "sample_barcode")` binds to `by`, not `by.x`. `merge.data.frame()` defaults `by.x = by` and `by.y = by`; therefore this call uses `sample_barcode` as the key on both tables. With the default `all = FALSE`, it returns matching rows (an inner/equi-join), and the join key appears once in the result. The reported 51 columns are consistent with 7 + 45 − 1 shared key column.

The reported 11,131 joined rows exceed the 11,069 rows in `data1`. That can happen when matching keys are duplicated in one or both tables, which multiplies joined rows. It means the output size alone does not establish a one-row-per-sample result. Preserve these numbers as the observed output, but investigate key availability and multiplicity before interpreting `data3`.

## 4. Diagnose the key and row multiplication

```r
# Key existence and missing values
stopifnot("sample_barcode" %in% names(data1),
          "sample_barcode" %in% names(data2))

sum(is.na(data1$sample_barcode))
sum(is.na(data2$sample_barcode))

# Number of rows per key; inspect keys occurring more than once
dup1 <- data1 %>% count(sample_barcode, name = "n_data1") %>% filter(n_data1 > 1)
dup2 <- data2 %>% count(sample_barcode, name = "n_data2") %>% filter(n_data2 > 1)

nrow(dup1)
head(dup1)
nrow(dup2)
head(dup2)

# Compare distinct and overlapping keys
n_distinct(data1$sample_barcode)
n_distinct(data2$sample_barcode)
length(intersect(data1$sample_barcode, data2$sample_barcode))
```

Also check whether identifiers have compatible types and formatting (for example, whitespace, case, or barcode suffixes). Do not silently normalize identifiers; first confirm the appropriate convention for these source files.

## 5. Join explicitly after confirming the schema

If both tables genuinely contain `sample_barcode` and that is the intended linkage, use an explicit key. The following is the tidyverse equivalent of the observed inner merge:

```r
data3_by_sample <- inner_join(
  data1,
  data2,
  by = "sample_barcode"
)
```

For a one-row-per-sample analysis, check uniqueness before the join and fail early if the assumption is not met:

```r
stopifnot(!anyNA(data1$sample_barcode), !anyNA(data2$sample_barcode))
stopifnot(!anyDuplicated(data1$sample_barcode),
          !anyDuplicated(data2$sample_barcode))

data3_by_sample <- inner_join(
  data1,
  data2,
  by = "sample_barcode",
  relationship = "one-to-one"
)
```

If repeats are expected (for example, multiple clinical records per sample), do not apply the one-to-one assertion. Determine what one row represents, resolve or retain repeated records intentionally, and state the intended relationship. Keep the duplicate-key diagnostics as part of that decision.

If the actual schema instead has expression rows keyed by `sample_barcode` and clinical rows keyed only by `patient_id`, these columns do **not** form a direct join. Obtain a verified mapping with one row per sample-to-patient relationship, then join through it. For example, assuming a validated table named `sample_patient_map` with those two columns:

```r
stopifnot(all(c("sample_barcode", "patient_id") %in% names(sample_patient_map)),
          "patient_id" %in% names(data2),
          "sample_barcode" %in% names(data1))

expression_with_patient <- inner_join(
  data1,
  sample_patient_map,
  by = "sample_barcode"
)
data3_by_patient <- inner_join(
  expression_with_patient,
  data2,
  by = "patient_id"
)
```

`sample_patient_map` is a required input to this alternative, not a supplied or inferred dataset. Check its provenance and duplicate mappings; do not manufacture a mapping by matching unrelated barcode strings.

## 6. Validate the result

After selecting the verified join path, inspect the result and compare row counts with the key diagnostics:

```r
dim(data3_by_sample)  # or dim(data3_by_patient), for the verified alternative
names(data3_by_sample)
head(data3_by_sample)

# How many input keys did not find a partner?
anti_join(data1 %>% distinct(sample_barcode),
          data2 %>% distinct(sample_barcode),
          by = "sample_barcode")
anti_join(data2 %>% distinct(sample_barcode),
          data1 %>% distinct(sample_barcode),
          by = "sample_barcode")
```

Use the sample-barcode validation block only when that key exists in both inputs. The final row count depends on the verified key and its duplicate structure; do not assume it must equal the reported 11,131 rows when changing the join or correcting the source data.
