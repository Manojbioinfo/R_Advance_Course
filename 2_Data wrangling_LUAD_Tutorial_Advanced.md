
# 🫁 LUAD Data Manipulation using dplyr (Basic Tutorial)

---

## 📌 1. Load Library
**Write the code in the Editor:**  
```r
library(dplyr)
```

---

## 📂 2. Load Dataset
**Write the code in the Editor:**  
```r
Data <- read.csv("LUAD_clean_data_all_patients.csv")
```

---

## 🔍 3. Explore Dataset
**Write the code in the Editor:**  
```r
head(Data)
```
**Output:**   
```
           ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA          1.9726027     Young
2 TCGA-NJ-A55R  67   Male European        Alive         Stage IA          0.2739726       Old
3 TCGA-53-A4EZ  63   Male European        Alive        Stage IIA          2.1917808     Young
4 TCGA-44-6777  85 Female European         Dead         Stage IB          3.5068493       Old
5 TCGA-55-6982  79 Female European         Dead        Stage IIB          0.0000000       Old
6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young
```


**Interpretation:**  
Displays the first few rows of the dataset to understand variable layout and sample values.  
Helps confirm correct data loading and detect any obvious issues.

---
**Write the code in the Editor:**  
```r
str(Data)
```
**Output:**   
```
'data.frame':	445 obs. of  8 variables:
 $ ID                : chr  "TCGA-55-A48X" "TCGA-NJ-A55R" "TCGA-53-A4EZ" "TCGA-44-6777" ...
 $ Age               : int  63 67 63 85 79 60 65 54 74 61 ...
 $ Gender            : chr  "Female" "Male" "Male" "Female" ...
 $ Race              : chr  "European" "European" "European" "European" ...
 $ Vital_Status      : chr  "Alive" "Alive" "Alive" "Dead" ...
 $ Pathologic_stage  : chr  "Stage IIA" "Stage IA" "Stage IIA" "Stage IB" ...
 $ Cigarettes_per_day: num  1.973 0.274 2.192 3.507 0 ...
 $ Age_Group         : chr  "Young" "Old" "Young" "Old" ...
```


**Interpretation:**  
Shows the structure of the dataset, including variable types and number of observations.  
Reveals that categorical variables are stored as character and may require conversion to factors.

---

## 🔍 4. Filter Data (Only Female Patients)
**Write the code in the Editor:**  
```r
female_data <- Data %>%
  filter(Gender == "Female")
```

**Interpretation:**  
This extracts only female patients from the dataset for subgroup analysis.

---

## 🔍 5. Explore Female Dataset
**Write the code in the Editor:**  
```r
head(female_data)
```
**Output:**   
```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA           1.972603     Young
2 TCGA-44-6777  85 Female European         Dead         Stage IB           3.506849       Old
3 TCGA-55-6982  79 Female European         Dead        Stage IIB           0.000000       Old
4 TCGA-50-6595  74 Female European         Dead       Stage IIIA           0.000000       Old
5 TCGA-71-8520  60 Female    Asian         Dead         Stage IB           0.000000     Young
6 TCGA-97-7553  58 Female European        Alive         Stage IA           1.095890     Young
```


**Interpretation:**  
Displays the first few rows of the female-only dataset to verify successful filtering.

---
**Write the code in the Editor:**  
```r
str(female_data)
```
**Output:**   
```
'data.frame':	247 obs. of  8 variables:
 $ ID                : chr  "TCGA-55-A48X" "TCGA-44-6777" "TCGA-55-6982" "TCGA-50-6595" ...
 $ Age               : int  63 85 79 74 60 58 62 58 66 80 ...
 $ Gender            : chr  "Female" "Female" "Female" "Female" ...
 $ Race              : chr  "European" "European" "European" "European" ...
 $ Vital_Status      : chr  "Alive" "Dead" "Dead" "Dead" ...
 $ Pathologic_stage  : chr  "Stage IIA" "Stage IB" "Stage IIB" "Stage IIIA" ...
 $ Cigarettes_per_day: num  1.97 3.51 0 0 0 ...
 $ Age_Group         : chr  "Young" "Old" "Old" "Old" ...
```


**Interpretation:**  
Shows the structure of the filtered dataset and allows comparison with the full dataset.  
This helps identify differences in sample size and confirms that variables remain consistent.

---

## 🔢 6. Arrange Data (Sort by Age)
**Write the code in the Editor:**  
```r
sorted_data <- Data %>%
  arrange(Age)
head(sorted_data)
```
**Output:**   
```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-44-3917  33 Female European        Alive         Stage IB          0.8767123     Young
2 TCGA-35-4123  38   Male European        Alive         Stage IA          1.0958904     Young
3 TCGA-49-AARO  39 Female  African        Alive         Stage IA          0.0000000     Young
4 TCGA-53-7624  40 Female European         Dead         Stage IV          2.7397260     Young
5 TCGA-L9-A5IP  40 Female  African         Dead         Stage IV          0.0000000     Young
6 TCGA-55-8512  41   Male European         Dead         Stage IV          1.0410959     Young
> 
```

**Interpretation:**  
Sorts the dataset in ascending order of age, making it easier to identify youngest and oldest patients.

---

## 🎯 7. Select Specific Columns
**Write the code in the Editor:**  
```r
selected_data <- Data %>%
  select(Age, Gender, Pathologic_stage)
```

```r
head(selected_data )
```
**Output:**   
```
 Age Gender Pathologic_stage
1  63 Female        Stage IIA
2  67   Male         Stage IA
3  63   Male        Stage IIA
4  85 Female         Stage IB
5  79 Female        Stage IIB
6  60   Male         Stage IA
```

**Interpretation:**  
Keeps only relevant variables for focused analysis and reduces dataset complexity.

---

## ➕ 8. Create New Variable (Mutate)
**Write the code in the Editor:**  
```r
Data <- Data %>%
  mutate(Age_Group2 = ifelse(Age > 60, "Older", "Younger"))
head(Data)
```
**Output:**   
```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group Age_Group2
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA          1.9726027     Young      Older
2 TCGA-NJ-A55R  67   Male European        Alive         Stage IA          0.2739726       Old      Older
3 TCGA-53-A4EZ  63   Male European        Alive        Stage IIA          2.1917808     Young      Older
4 TCGA-44-6777  85 Female European         Dead         Stage IB          3.5068493       Old      Older
5 TCGA-55-6982  79 Female European         Dead        Stage IIB          0.0000000       Old      Older
6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young    Younger

```
**Interpretation:**  
Creates a new categorical variable that groups patients based on age.

---

## 📊 9. Summary Statistics
**Write the code in the Editor:**  
```r
Data %>%
  summarise(mean_age = mean(Age, na.rm = TRUE))
```
**Output:**   
```
  mean_age
1 65.23371
```

**Interpretation:**  
Calculates the overall average age of patients in the dataset.

---

## 📊 10. Group-wise Summary
**Write the code in the Editor:**  
```r
Data %>%
  group_by(Gender) %>%
  summarise(mean_age = mean(Age, na.rm = TRUE))
```
**Output:**   
```
# A tibble: 2 × 2
  Gender mean_age
  <chr>     <dbl>
1 Female     65.3
2 Male       65.1
```

**Interpretation:**  
Calculates the mean age separately for male and female patients, enabling comparison between groups.

---

## ✅ Conclusion  

This tutorial demonstrated basic data manipulation using the **dplyr** package, including filtering, sorting, selecting variables, creating new variables, and summarizing data.  
Additionally, comparing the full dataset with the female subset helps in understanding subgroup-specific patterns, which is important in healthcare data analysis.
