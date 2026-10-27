
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
```

```r
#                 sample_barcode BIRC5 CDKN2A  KRAS  MSLN SMAD4  TP53
#TCGA-OR-A5J1-01 TCGA-OR-A5J1-01  5.66   8.06  9.91  1.55 10.27  9.14
#TCGA-OR-A5J2-01 TCGA-OR-A5J2-01  6.11   9.42 10.04  0.49 10.55  7.38
#TCGA-OR-A5J3-01 TCGA-OR-A5J3-01  5.78   6.75  9.88  0.00  9.53  9.90
#TCGA-OR-A5J5-01 TCGA-OR-A5J5-01  9.61  10.35  9.22  0.00  9.42 10.19
#TCGA-OR-A5J6-01 TCGA-OR-A5J6-01  2.87   6.75  8.51  0.00  9.40  8.95
#TCGA-OR-A5J7-01 TCGA-OR-A5J7-01  9.78   8.87  8.69  0.49  9.63  9.47
```
```r
head(data2)
```
```r
# A tibble: 6 × 45
#   patient_id   cancer_type age_at_initial_pathologic_d…¹ gender race  ajcc_pathologic_tumo…² clinical_stage
#   <chr>        <chr>                               <dbl> <chr>  <chr> <chr>                  <chr>         
# 1 TCGA-OR-A5J1 ACC                                    58 MALE   WHITE Stage II               NA            
# 2 TCGA-OR-A5J2 ACC                                    44 FEMALE WHITE Stage IV               NA            
# 3 TCGA-OR-A5J3 ACC                                    23 FEMALE WHITE Stage III              NA            
# 4 TCGA-OR-A5J4 ACC                                    23 FEMALE WHITE Stage IV               NA            
# 5 TCGA-OR-A5J5 ACC                                    30 MALE   WHITE Stage III              NA            
# 6 TCGA-OR-A5J6 ACC                                    29 FEMALE BLAC… Stage II               NA            
# ℹ abbreviated names: ¹​age_at_initial_pathologic_diagnosis, ²​ajcc_pathologic_tumor_stage
# ℹ 38 more variables: histological_type <chr>, histological_grade <chr>,
#   initial_pathologic_dx_year <dbl>, menopause_status <chr>, birth_days_to <dbl>, vital_status <chr>,
#   tumor_status <chr>, last_contact_days_to <dbl>, death_days_to <dbl>, cause_of_death <chr>,
#   new_tumor_event_type <chr>, new_tumor_event_site <chr>, new_tumor_event_site_other <chr>,
#   new_tumor_event_dx_days_to <dbl>, treatment_outcome_first_course <chr>, margin_status <chr>,
#   residual_tumor <chr>, OS <dbl>, OS.time <dbl>, DSS <dbl>, DSS.time <dbl>, DFI <dbl>, DFI.time <dbl>, …
```

```r
intersect(colnames(data1), colnames(data2))
```
```r
#"sample_barcode"
```

The reported intersection contained only `"sample_barcode"`. The clinical `head()` output reportedly showed `patient_id`. These observations are a reason to inspect the complete schemas: `head()` displays only a few rows (and, for wide objects, may not reveal every column), so `patient_id` may coexist with a `sample_barcode` column. Confirm the actual names and values in both loaded objects before choosing a key.

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
