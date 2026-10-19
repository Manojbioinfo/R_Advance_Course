# 🫁 LUAD Data Manipulation using dplyr (Basic Tutorial)

---

## 📑 Contents

1. [Load Library](#-1-load-library)
2. [Load Dataset](#-2-load-dataset)
3. [Explore Dataset](#-3-explore-dataset)
4. [Filter Data](#-4-filter-data-only-female-patients)
5. [Explore Female Dataset](#-5-explore-female-dataset)
6. [Arrange Data](#-6-arrange-data-sort-by-age)
7. [Select Specific Columns](#-7-select-specific-columns)
8. [Create New Variable](#-8-create-new-variable-mutate)
9. [Summary Statistics](#-9-summary-statistics)
10. [Group-wise Summary](#-10-group-wise-summary)
11. [Bonus: Counting and Combining Verbs](#-11-bonus-counting-and-combining-verbs)
12. [Conclusion](#-conclusion)
13. [Quiz](#-quiz)

---

## 📌 1. Load Library

**Write the code in the Editor:**

```r
library(dplyr)
```

**Interpretation:**
`dplyr` is the core package for data manipulation in R. Its main verbs are `filter()`, `arrange()`, `select()`, `mutate()`, `summarise()`, and `group_by()`.

> 💡 **The pipe `%>%`:** Throughout this tutorial you will see `%>%`. It means "take the result on the left and pass it into the function on the right". Read it as "and then". Newer R versions also support the native pipe `|>`, which works the same way for these examples.

---

## 📂 2. Load Dataset

**Write the code in the Editor:**

```r
Data <- read.csv("LUAD_clean_data_all_patients.csv")
```

**Interpretation:**
Reads the CSV file into a data frame called `Data`. Make sure the file is in your working directory (check with `getwd()`).

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
Displays the first few rows of the dataset to understand variable layout and sample values. Helps confirm correct data loading and detect any obvious issues.

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
Shows the structure of the dataset, including variable types and number of observations (**445 patients, 8 variables**). Reveals that categorical variables are stored as character and may require conversion to factors.

---

## 🔍 4. Filter Data (Only Female Patients)

**Write the code in the Editor:**

```r
female_data <- Data %>%
  filter(Gender == "Female")
```

**Interpretation:**
`filter()` keeps only the rows that meet a condition. Here it extracts female patients for subgroup analysis.

> ⚠️ **Common mistake:** Use `==` (two equals signs) to compare. A single `=` assigns a value and will give an error inside `filter()`.

You can combine conditions:

```r
# Female patients who are also Dead
Data %>% filter(Gender == "Female", Vital_Status == "Dead")

# Patients older than 70 OR with Stage IV disease
Data %>% filter(Age > 70 | Pathologic_stage == "Stage IV")
```

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
Shows the structure of the filtered dataset (**247 of 445 patients are female**) and allows comparison with the full dataset. The variables stay the same, and only the number of rows changes.

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
```

**Interpretation:**
Sorts the dataset in ascending order of age, making it easier to identify the youngest patients.

To sort from oldest to youngest, wrap the variable in `desc()`:

```r
Data %>% arrange(desc(Age)) %>% head()
```

---

## 🎯 7. Select Specific Columns

**Write the code in the Editor:**

```r
selected_data <- Data %>%
  select(Age, Gender, Pathologic_stage)

head(selected_data)
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
`select()` keeps only the columns you name, reducing dataset complexity for focused analysis.

You can also drop columns with a minus sign:

```r
Data %>% select(-ID) %>% head()
```

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
5 TCGA-55-6982  79 Female European         Dead         Stage IIB          0.0000000       Old      Older
6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young    Younger
```

**Interpretation:**
`mutate()` creates a new column from existing ones. Here `Age_Group2` labels patients as "Older" if age is above 60 and "Younger" otherwise.

> 💡 **Note on row 6:** The patient is exactly 60. Because the rule is `Age > 60` (strictly greater), a 60-year-old is labelled "Younger". Use `Age >= 60` if you want 60 to count as "Older". Always check which side of the cut-off your boundary value falls on.

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
`summarise()` collapses the data into summary values. Here it calculates the overall average age. `na.rm = TRUE` tells R to ignore missing values (this dataset has none, but it is a good habit).

You can calculate several statistics at once:

```r
Data %>%
  summarise(
    n          = n(),
    mean_age   = mean(Age),
    median_age = median(Age),
    sd_age     = sd(Age)
  )
```

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
`group_by()` splits the data into groups, and `summarise()` is then applied to each group. Here it gives the mean age separately for female and male patients.

---

## 🧰 11. Bonus: Counting and Combining Verbs

### Count patients per group

**Write the code in the Editor:**

```r
Data %>% count(Vital_Status)
```

**Interpretation:**
`count()` is a shortcut for `group_by()` plus `n()`. It returns the number of patients in each category.

### Chain several verbs together

**Write the code in the Editor:**

```r
Data %>%
  filter(Pathologic_stage == "Stage IV") %>%
  group_by(Gender) %>%
  summarise(
    n        = n(),
    mean_age = mean(Age)
  ) %>%
  arrange(desc(n))
```

**Interpretation:**
This reads as: take the data, keep Stage IV patients, group by gender, count them and compute mean age, then sort with the largest group first. Chaining verbs with the pipe keeps the code readable from top to bottom.

---

## ✅ Conclusion

This tutorial demonstrated basic data manipulation using the **dplyr** package: filtering, sorting, selecting variables, creating new variables, and summarizing data, both overall and by group.

Comparing the full dataset with the female subset shows how filtering changes sample size (445 to 247) while keeping the same variables. The group-wise summary showed very similar mean ages for females (65.3) and males (65.1), a difference too small to suggest a meaningful age gap. Testing whether such differences are statistically meaningful is a job for the next tutorial.

---

## 🧠 Quiz

Try each question first, then click to reveal the answer.

### Part A: Multiple choice

**Q1. Which dplyr verb keeps only rows that meet a condition?**

- A. `select()`
- B. `filter()`
- C. `arrange()`
- D. `mutate()`

<details><summary>Show answer</summary>

**B.** `filter()` subsets rows. `select()` subsets columns.

</details>

**Q2. What does the pipe `%>%` do?**

- A. Adds two numbers
- B. Passes the result on its left into the function on its right
- C. Saves a file
- D. Deletes missing values

<details><summary>Show answer</summary>

**B.** It chains steps so you can read code as "do this, then this".

</details>

**Q3. Which operator checks whether Gender equals "Female" inside `filter()`?**

- A. `=`
- B. `==`
- C. `!=`
- D. `<-`

<details><summary>Show answer</summary>

**B.** `==` compares values. `=` assigns, and `!=` means "not equal".

</details>

**Q4. Which code sorts patients from oldest to youngest?**

- A. `arrange(Age)`
- B. `arrange(desc(Age))`
- C. `sort(Age)`
- D. `filter(Age)`

<details><summary>Show answer</summary>

**B.** `arrange()` sorts ascending by default, and `desc()` reverses the order.

</details>

**Q5. Which verb creates a new column?**

- A. `summarise()`
- B. `select()`
- C. `mutate()`
- D. `group_by()`

<details><summary>Show answer</summary>

**C.** `mutate()` adds or modifies columns while keeping all rows.

</details>

**Q6. What is the main difference between `mutate()` and `summarise()`?**

- A. They are identical
- B. `mutate()` keeps all rows, while `summarise()` collapses rows into summary values
- C. `summarise()` adds columns, while `mutate()` removes them
- D. `mutate()` only works on text

<details><summary>Show answer</summary>

**B.** `mutate()` returns one value per row, and `summarise()` returns one row per group.

</details>

**Q7. A patient aged exactly 60 is labelled "Younger" by `ifelse(Age > 60, "Older", "Younger")`. Why?**

- A. A bug in R
- B. `>` is strict, so 60 is not greater than 60
- C. 60 is a missing value
- D. `ifelse()` ignores whole numbers

<details><summary>Show answer</summary>

**B.** Use `>=` to include 60 in the "Older" group.

</details>

**Q8. What does `group_by(Gender)` do on its own, without `summarise()`?**

- A. Sorts the data
- B. Removes the Gender column
- C. Marks the groups but does not change how the data look
- D. Calculates the mean

<details><summary>Show answer</summary>

**C.** It sets up the grouping, and the next verb (usually `summarise()`) then works per group.

</details>

---

### Part B: True or false

**Q9. `select()` chooses rows and `filter()` chooses columns.**

<details><summary>Show answer</summary>

**False.** It is the reverse: `filter()` chooses rows and `select()` chooses columns.

</details>

**Q10. After `filter(Gender == "Female")`, the number of columns changes.**

<details><summary>Show answer</summary>

**False.** Only the number of rows changes. All 8 columns remain.

</details>

**Q11. A mean age of 65.3 for females versus 65.1 for males proves a meaningful age difference between genders.**

<details><summary>Show answer</summary>

**False.** A 0.2-year gap is tiny. Only a proper statistical test, with an effect size and confidence interval, can say whether a difference is meaningful.

</details>

---

### Part C: Short answer

**Q12. Write code to keep only patients with Vital_Status "Dead".**

<details><summary>Show answer</summary>

```r
Data %>% filter(Vital_Status == "Dead")
```

</details>

**Q13. Write code to show only the columns `ID` and `Age`.**

<details><summary>Show answer</summary>

```r
Data %>% select(ID, Age)
```

</details>

**Q14. Write code to count how many patients are in each Race category.**

<details><summary>Show answer</summary>

```r
Data %>% count(Race)
```

</details>

**Q15. Write code to find the median Cigarettes_per_day for each Vital_Status.**

<details><summary>Show answer</summary>

```r
Data %>%
  group_by(Vital_Status) %>%
  summarise(median_cigs = median(Cigarettes_per_day))
```

</details>

---

### Part D: Try it yourself

1. Create a dataset of male patients aged 70 or older with Stage IV disease. How many are there?
2. Add a new column `Heavy_Smoker` that is "Yes" if `Cigarettes_per_day` is above 3 and "No" otherwise. Then count how many patients fall in each group.
3. Find the mean age and the number of patients for each `Pathologic_stage`, sorted from the largest group to the smallest.

<details><summary>Show hints</summary>

```r
# 1
Data %>%
  filter(Gender == "Male", Age >= 70, Pathologic_stage == "Stage IV") %>%
  nrow()

# 2
Data %>%
  mutate(Heavy_Smoker = ifelse(Cigarettes_per_day > 3, "Yes", "No")) %>%
  count(Heavy_Smoker)

# 3
Data %>%
  group_by(Pathologic_stage) %>%
  summarise(n = n(), mean_age = mean(Age)) %>%
  arrange(desc(n))
```

</details>

---

### 🎯 Scoring guide

| Score (of 11 graded items, Q1-Q11) | Level |
|---|---|
| 10-11 | Excellent, ready for ggplot2 |
| 8-9 | Good, review the verbs you missed |
| 5-7 | Fair, re-read sections 4-10 |
| 0-4 | Re-run the tutorial from the start |
