
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

# A tibble: 6 × 45
#  patient_id   cancer_type age_at_initial_pathologic_d…¹ gender race  ajcc_pathologic_tumo…² clinical_stage
#  <chr>        <chr>                               <dbl> <chr>  <chr> <chr>                  <chr>         
#1 TCGA-OR-A5J1 ACC                                    58 MALE   WHITE Stage II               NA            
#2 TCGA-OR-A5J2 ACC                                    44 FEMALE WHITE Stage IV               NA            
#3 TCGA-OR-A5J3 ACC                                    23 FEMALE WHITE Stage III              NA            
#4 TCGA-OR-A5J4 ACC                                    23 FEMALE WHITE Stage IV               NA            
#5 TCGA-OR-A5J5 ACC                                    30 MALE   WHITE Stage III              NA            
#6 TCGA-OR-A5J6 ACC                                    29 FEMALE BLAC… Stage II               NA            
# ℹ abbreviated names: ¹​age_at_initial_pathologic_diagnosis, ²​ajcc_pathologic_tumor_stage
# ℹ 38 more variables: histological_type <chr>, histological_grade <chr>,
#   initial_pathologic_dx_year <dbl>, menopause_status <chr>, birth_days_to <dbl>, vital_status <chr>,
#   tumor_status <chr>, last_contact_days_to <dbl>, death_days_to <dbl>, cause_of_death <chr>,
#   new_tumor_event_type <chr>, new_tumor_event_site <chr>, new_tumor_event_site_other <chr>,
#   new_tumor_event_dx_days_to <dbl>, treatment_outcome_first_course <chr>, margin_status <chr>,
#   residual_tumor <chr>, OS <dbl>, OS.time <dbl>, DSS <dbl>, DSS.time <dbl>, DFI <dbl>, DFI.time <dbl>, …
```

```r
dim(data1)
#11069     7

dim(data2)
#12591    45
```

```r
colnames(data1)
#[1] "sample_barcode" "BIRC5"          "CDKN2A"         "KRAS"           "MSLN"           "SMAD4"         
#[7] "TP53"  


colnames(data2)

# [1] "patient_id"                          "cancer_type"                        
# [3] "age_at_initial_pathologic_diagnosis" "gender"                             
# [5] "race"                                "ajcc_pathologic_tumor_stage"        
# [7] "clinical_stage"                      "histological_type"                  
# [9] "histological_grade"                  "initial_pathologic_dx_year"         
#[11] "menopause_status"                    "birth_days_to"                      
#[13] "vital_status"                        "tumor_status"                       
#[15] "last_contact_days_to"                "death_days_to"                      
#[17] "cause_of_death"                      "new_tumor_event_type"               
#[19] "new_tumor_event_site"                "new_tumor_event_site_other"         
#[21] "new_tumor_event_dx_days_to"          "treatment_outcome_first_course"     
#[23] "margin_status"                       "residual_tumor"                     
#[25] "OS"                                  "OS.time"                            
#[27] "DSS"                                 "DSS.time"                           
#[29] "DFI"                                 "DFI.time"                           
#[31] "PFI"                                 "PFI.time"                           
#[33] "Redaction"                           "sample_barcode"                     
#[35] "sample_type"                         "primary_disease"                    
#[37] "Subtype_Immune_Model_Based"          "Subtype_mRNA"                       
#[39] "Subtype_DNAmeth"                     "Subtype_protein"                    
#[41] "Subtype_miRNA"                       "Subtype_CNA"                        
#[43] "Subtype_Integrative"                 "Subtype_other"                      
#[45] "Subtype_Selected"                   
```

The The reported dimensions are:

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


dim(data1_clean)
#11069     7
dim(data2_clean)
#[1] 11081    45
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


After verifying the joined rows and barcode multiplicity, define the specific clinical or biological question for the next analysis section.
