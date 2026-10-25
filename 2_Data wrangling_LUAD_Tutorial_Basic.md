# 🫁 LUAD (Lung Adenocarcinoma) Data Analysis in R

### A complete beginner-friendly tutorial: base R + tidyverse (dplyr)

---

## 📑 Contents

### 🟦 Part 1: Getting Started

1. [Introduction](#-1-introduction)
2. [Download the Dataset](#-2-download-the-dataset)
3. [Workspace Preparation](#-3-workspace-preparation)
4. [Load Required Libraries](#-4-load-required-libraries)
5. [Load and Inspect the Dataset](#-5-load-and-inspect-the-dataset)

### 🟩 Part 2: Cleaning and Describing the Data

6. [Data Cleaning](#-6-data-cleaning)
7. [Descriptive Statistics](#-7-descriptive-statistics)

### 🟨 Part 3: Visualization and Relationships

8. [Data Visualization](#-8-data-visualization)
9. [Relationship Analysis](#-9-relationship-analysis)
10. [Correlation Analysis](#-10-correlation-analysis)
11. [Boxplots](#-11-boxplots)
12. [Saving Plots](#-12-saving-plots)

### 🟧 Part 4: Data Manipulation with dplyr

13. [Why dplyr? The Pipe](#-13-why-dplyr-the-pipe)
14. [Filter Rows](#-14-filter-rows)
15. [Arrange (Sort) Rows](#-15-arrange-sort-rows)
16. [Select Columns](#-16-select-columns)
17. [Create New Variables with mutate()](#-17-create-new-variables-with-mutate)
18. [Summary Statistics with summarise()](#-18-summary-statistics-with-summarise)
19. [Group-wise Summaries](#-19-group-wise-summaries)
20. [Counting and Chaining Verbs](#-20-counting-and-chaining-verbs)

### 🟥 Part 5: Wrap-up

21. [Reproducibility](#-21-reproducibility)
22. [Conclusion](#-22-conclusion)
23. [Quiz](#-23-quiz)
24. [Quick Reference Cheat Sheet](#-24-quick-reference-cheat-sheet)
---

> 📝 **A note on numbers.** The example outputs below are shown as they appeared in the original lessons. Your own output may differ slightly depending on the version of the CSV file you download. Where a number should be checked against your own file, you will see a ⚠️ **Check your output** box. Always trust what R prints on your screen.

---

# 🟦 PART 1: GETTING STARTED

---

## 📌 1. Introduction

Lung Adenocarcinoma (LUAD) is one of the most common types of lung cancer and a leading cause of cancer-related mortality worldwide. Analyzing clinical and demographic patient data helps identify disease patterns and risk factors, and supports better treatment strategies.

In this tutorial you will work with a real LUAD dataset containing **age, gender, race, vital status, tumor stage, and smoking intensity**.

**🎯 What you will learn**

| Skill | Tools |
|---|---|
| Load and inspect data | `read.csv()`, `head()`, `str()`, `summary()` |
| Clean data | `is.na()`, `factor()` |
| Describe data | `mean()`, `median()`, `table()` |
| Visualize data | `hist()`, `barplot()`, `plot()`, `boxplot()` |
| Measure relationships | `cor()`, `lm()` |
| Manipulate data | `filter()`, `arrange()`, `select()`, `mutate()`, `summarise()`, `group_by()` |

**⏱️ Time needed:** about 60 to 90 minutes.
**📚 Prerequisites:** R and RStudio installed. No prior coding experience is required.

---

## 📥 2. Download the Dataset

The dataset is publicly available.

🔗 **Dataset source:**
https://github.com/Manojbioinfo/R_basic_course/blob/main/Data/LUAD_clean_data_all_patients.csv

**Steps**

1. Open the link above.
2. Click **"Raw"**.
3. Right-click and choose **Save As**.
4. Save the file as `LUAD_clean_data_all_patients.csv`.
5. Place it in your R working directory.

> 💡 **Tip:** Not sure where your working directory is? Run `getwd()` in R. To change it in RStudio, use *Session → Set Working Directory → Choose Directory*.

**📋 Data dictionary**

| Variable | Type | Description |
|---|---|---|
| `ID` | Text | Patient identifier (TCGA barcode) |
| `Age` | Number | Age in years |
| `Gender` | Category | Female / Male |
| `Race` | Category | Ethnic group |
| `Vital_Status` | Category | Alive / Dead |
| `Pathologic_stage` | Category | Tumor stage (Stage I to Stage IV) |
| `Cigarettes_per_day` | Number | Average smoking intensity |
| `Age_Group` | Category | Young / Old |

---

## 🧼 3. Workspace Preparation

**✍️ Write the code in the Editor:**

```r
# Clear workspace
rm(list = ls())
```

**📖 Interpretation:**
This removes every object stored in your current R session. Starting clean avoids conflicts with variables from earlier work. It does **not** delete any files from your computer.

---

## 📦 4. Load Required Libraries

**✍️ Write the code in the Editor:**

```r
# Install (run once only, then keep it commented out)
# install.packages("tidyverse")

# Load the library (run every session)
library(tidyverse)
```

R prints the message below automatically when tidyverse loads:

```
── Attaching core tidyverse packages ───────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.2     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.1

── Conflicts ───────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package to force all conflicts to become errors
```

**📖 Interpretation:**
- `tidyverse` is a collection of packages for data manipulation, analysis, and visualization. It includes **dplyr**, which we use in Part 4.
- The "conflicts" message means `filter()` and `lag()` from dplyr hide functions with the same names in base R's `stats` package. This is normal and almost never causes problems.

> ⚠️ **If you see "there is no package called 'tidyverse'":** run `install.packages("tidyverse")` once, then `library(tidyverse)` again.

---

## 📂 5. Load and Inspect the Dataset

**✍️ Write the code in the Editor:**

```r
# Load dataset
Data <- read.csv("LUAD_clean_data_all_patients.csv")
```

> ⚠️ **If you get "cannot open file":** the file is not in your working directory. Check with `getwd()` and move the file, or set the correct directory.

### 🔍 5.1 Preview with `head()`

```r
head(Data)
```

**🖥️ Output:**

```
           ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA          1.9726027     Young
2 TCGA-NJ-A55R  67   Male European        Alive         Stage IA          0.2739726       Old
3 TCGA-53-A4EZ  63   Male European        Alive        Stage IIA          2.1917808     Young
4 TCGA-44-6777  85 Female European         Dead         Stage IB          3.5068493       Old
5 TCGA-55-6982  79 Female European         Dead        Stage IIB          0.0000000       Old
6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young
```

**📖 Interpretation:**
`head()` shows the first six rows. From this preview we can confirm that the variables are readable and that both numerical and categorical data are present. Always preview your data before analysing it.

### 🔍 5.2 Structure with `str()`

```r
str(Data)
```

**🖥️ Output:**

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

> ⚠️ **Check your output:** the original lesson showed 579 rows in one place and 445 in another. The 445-row version is consistent with the gender and stage tables later on. Run `nrow(Data)` to see how many rows **your** file has, and use that number whenever the text says "445".

**📖 Interpretation:**
The dataset has **445 observations and 8 variables**.

| Type | Variables |
|---|---|
| 🔢 Numerical | `Age`, `Cigarettes_per_day` |
| 🏷️ Categorical | `Gender`, `Race`, `Vital_Status`, `Pathologic_stage`, `Age_Group` |
| 🆔 Identifier | `ID` |

Most categorical variables are stored as text (`chr`) and should be converted to **factors** for proper analysis (see Section 6).

### 🔍 5.3 Summary with `summary()`

```r
summary(Data)
```

**🖥️ Output:**

```
      ID                 Age          Gender              Race           Vital_Status       Pathologic_stage
 Length:445         Min.   :33.0   Length:445         Length:445         Length:445         Length:445
 Class :character   1st Qu.:59.0   Class :character   Class :character   Class :character   Class :character
 Mode  :character   Median :66.0   Mode  :character   Mode  :character   Mode  :character   Mode  :character
                    Mean   :65.2
                    3rd Qu.:72.0
                    Max.   :88.0
 Cigarettes_per_day  Age_Group
 Min.   :0.000      Length:445
 1st Qu.:0.000      Class :character
 Median :1.096      Mode  :character
 Mean   :1.512
 3rd Qu.:2.466
 Max.   :8.438
```

**📖 Interpretation:**

- **Age:** mean **65.2** years, range **33 to 88**. The median (66) is close to the mean, so the distribution is fairly symmetric.
- **Cigarettes per day:** mean **1.51** is higher than median **1.10**, suggesting a **right-skewed** distribution. A minimum of 0 means some patients do not smoke.
- **Categorical variables:** shown only as Length/Class/Mode because they are text. Converting them to factors (next section) will show counts per category.

---

# 🟩 PART 2: CLEANING AND DESCRIBING THE DATA

---

## 🧹 6. Data Cleaning

### 🔍 6.1 Check for missing values

Before any analysis, check whether the dataset contains missing values.

**✍️ Write the code in the Editor:**

```r
# Count missing values in each column
colSums(is.na(Data))
```

**🖥️ Output:**

```
                ID                Age             Gender               Race       Vital_Status   Pathologic_stage Cigarettes_per_day          Age_Group
                 0                  0                  0                  0                  0                  0                  0                  0
```

**📖 Interpretation:**
- Every column shows **0** missing values.
- The dataset is **complete**, so no missing-value cleaning is needed.

> 💡 **How it works:** `is.na(Data)` marks every missing cell as `TRUE`. `colSums()` adds up the `TRUE` values in each column.

### 🔁 6.2 Convert categorical variables to factors

The summary showed that categorical variables are stored as text. Converting them to **factors** lets R treat them as groups.

**✍️ Write the code in the Editor:**

```r
# Convert character columns to factors
Data$Gender           <- factor(Data$Gender)
Data$Race             <- factor(Data$Race)
Data$Vital_Status     <- factor(Data$Vital_Status)
Data$Pathologic_stage <- factor(Data$Pathologic_stage)
Data$Age_Group        <- factor(Data$Age_Group)

# Check the result
summary(Data)
```

**📖 Interpretation:**
After conversion, `summary()` shows the **count per category** instead of just the text length, so group sizes are visible immediately.

> 💡 **Note:** `Data$Age` and `Data $ Age` mean the same thing in R. This tutorial uses the compact form `Data$Age`.

---

## 📊 7. Descriptive Statistics

### 7.1 Mean age

**✍️ Write the code in the Editor:**

```r
mean(Data$Age)
```

**🖥️ Output:**

```
[1] 65.23371
```

### 7.2 Median age

```r
median(Data$Age)
```

**🖥️ Output:**

```
[1] 66
```

### 7.3 Gender frequency

```r
table(Data$Gender)
```

**🖥️ Output:**

```
Female   Male
   247    198
```

> ⚠️ **Check your output:** these counts add up to **445**, which matches the 445-row version of the data. If `nrow(Data)` gives a different number, re-run `table(Data$Gender)` and use your own counts.

### 7.4 Tumor stage frequency

```r
table(Data$Pathologic_stage)
```

**🖥️ Output:**

```
  Stage I   Stage IA   Stage IB   Stage II  Stage IIA  Stage IIB Stage IIIA Stage IIIB   Stage IV
        5        130        113          1         48         58         62          7         21
```

**📖 Interpretation:**
Descriptive statistics summarize the main features of the data:

- The mean (65.2) and median (66) age are close, so age is roughly symmetric.
- Slightly more **females (247)** than **males (198)**.
- Most patients are **early stage** (Stage IA and IB together make up more than half the cohort), while Stage IV is relatively rare.

---

# 🟧 PART 3: VISUALIZATION AND RELATIONSHIPS

---

## 📈 8. Data Visualization

### 8.1 Histogram of age

**✍️ Write the code in the Editor:**

```r
hist(Data$Age,
     col  = "lightblue",
     main = "Age Distribution",
     xlab = "Age")
```

**🖥️ Output:**

<img src="images/LUAD_Pic1.jpg" alt="Histogram of age" width="60%">

### 8.2 Histogram of cigarettes per day

```r
hist(Data$Cigarettes_per_day,
     col  = "tomato",
     main = "Cigarettes per Day Distribution",
     xlab = "Cigarettes per day")
```

**🖥️ Output:**

<img src="images/LUAD_Pic2.jpg" alt="Histogram of cigarettes per day" width="60%">

### 8.3 Bar plot of gender

```r
barplot(table(Data$Gender),
        col  = "pink",
        main = "Gender Distribution")
```

**🖥️ Output:**

<img src="images/LUAD_Pic3.jpg" alt="Bar plot of gender" width="60%">

### 8.4 Bar plot of pathologic stage

```r
# las = 2 rotates the axis labels so they do not overlap
barplot(table(Data$Pathologic_stage),
        col  = "lightgreen",
        main = "Pathologic Stage Distribution",
        las  = 2)
```

**🖥️ Output:**

<img src="images/LUAD_Pic4.jpg" alt="Bar plot of pathologic stage" width="60%">

**📖 Interpretation:**
- **Histograms** show how a numerical variable is spread out.
- **Bar plots** show how many observations fall in each category.
- The cigarettes histogram is skewed to the right, matching what we saw in `summary()`.

---

## 📉 9. Relationship Analysis

### 9.1 Scatter plot

**✍️ Write the code in the Editor:**

```r
plot(Data$Age, Data$Cigarettes_per_day,
     xlab = "Age",
     ylab = "Cigarettes per Day",
     main = "Age vs Smoking")
```

**🖥️ Output:**

<img src="images/LUAD_Pic5.jpg" alt="Scatter plot of age vs smoking" width="60%">

### 9.2 Add a regression line

Run this **immediately after** the scatter plot, while the plot is still open:

```r
abline(lm(Cigarettes_per_day ~ Age, data = Data), col = "red")
```

**🖥️ Output:**

<img src="images/LUAD_Pic6.jpg" alt="Scatter plot with regression line" width="60%">

**📖 Interpretation:**
The scatter plot shows how two numerical variables relate. The red line is the best-fit straight line (`lm()` = linear model). Here it is almost flat, which hints that age and smoking intensity are not strongly related. The next section puts a number on that.

---

## 📊 10. Correlation Analysis

**✍️ Write the code in the Editor:**

```r
cor(Data$Age, Data$Cigarettes_per_day, use = "complete.obs")
```

**🖥️ Output:**

```
[1] 0.04594092
```

**📖 Interpretation:**
Correlation measures the strength and direction of a **linear** association between two numerical variables. It ranges from **-1 to +1**:

| Value | Meaning |
|---|---|
| Close to **+1** | Strong positive relationship |
| Close to **-1** | Strong negative relationship |
| Close to **0** | Little or no linear relationship |

Our result, **0.046**, is very close to 0:

> As age increases, cigarettes per day increase *very slightly*, but the relationship is so weak that there is essentially **no meaningful association**.

> ⚠️ **Two important cautions**
> 1. A weak correlation does not prove the variables are unrelated, only that there is no strong *linear* pattern.
> 2. Correlation never proves **causation**.

---

## 📦 11. Boxplots

### 11.1 Age by pathologic stage

**✍️ Write the code in the Editor:**

```r
boxplot(Age ~ Pathologic_stage, data = Data,
        col  = "orange",
        main = "Age by Pathologic Stage",
        las  = 2)
```

**🖥️ Output:**

<img src="images/LUAD_Pic7.jpg" alt="Boxplot of age by stage" width="60%">

### 11.2 Age by race

```r
boxplot(Age ~ Race, data = Data,
        col  = "purple",
        main = "Age by Race")
```

**🖥️ Output:**

<img src="images/LUAD_Pic8.jpg" alt="Boxplot of age by race" width="60%">

**📖 Interpretation:**
A boxplot shows the **median** (thick line), the **middle 50%** of values (the box), and **outliers** (dots). It is the best simple plot for comparing a numerical variable across groups.

> 💡 **Read the formula:** `Age ~ Race` means "Age as a function of Race", i.e. one box of ages per race group.

---

## 💾 12. Saving Plots

**✍️ Write the code in the Editor:**

```r
# 1. Open an image file
jpeg("luad_plot.jpg", width = 2000, height = 1500, res = 300)

# 2. Draw the plot
boxplot(Age ~ Race, data = Data,
        col  = "purple",
        main = "Age by Race")

# 3. Close the file (always run this!)
dev.off()

# 4. Find where the file was saved
getwd()
```

**📖 Interpretation:**
The plot is saved as `luad_plot.jpg` in your working directory. `dev.off()` closes the file. **Always run it**, or the image will be empty or incomplete.

> 💡 **Tip:** `png()` and `pdf()` work the same way if you prefer a different format.

---

# 🟪 PART 4: DATA MANIPULATION WITH dplyr

So far we used base R. Now we use **dplyr**, which makes data manipulation easier to read and write. It was loaded automatically with `library(tidyverse)`.

---

## 🔗 13. Why dplyr? The Pipe

`dplyr` is built around a small set of **verbs**:

| Verb | What it does | Works on |
|---|---|---|
| `filter()` | Keep rows that meet a condition | Rows |
| `arrange()` | Sort rows | Rows |
| `select()` | Keep or drop columns | Columns |
| `mutate()` | Create or change columns | Columns |
| `summarise()` | Collapse data into summary values | Whole table |
| `group_by()` | Split data into groups | Groups |

### The pipe `%>%`

Throughout Part 4 you will see `%>%`. It means:

> **"Take the result on the left and pass it into the function on the right."**

Read it as **"and then"**.

```r
Data %>% filter(Age > 70) %>% head()
# Take Data, AND THEN keep patients over 70, AND THEN show the first rows
```

Newer R versions also have a built-in pipe `|>` that works the same way for these examples.

---

## 🔍 14. Filter Rows

### 14.1 Keep only female patients

**✍️ Write the code in the Editor:**

```r
female_data <- Data %>%
  filter(Gender == "Female")

head(female_data)
```

**🖥️ Output:**

```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA           1.972603     Young
2 TCGA-44-6777  85 Female European         Dead         Stage IB           3.506849       Old
3 TCGA-55-6982  79 Female European         Dead        Stage IIB           0.000000       Old
4 TCGA-50-6595  74 Female European         Dead       Stage IIIA           0.000000       Old
5 TCGA-71-8520  60 Female    Asian         Dead         Stage IB           0.000000     Young
6 TCGA-97-7553  58 Female European        Alive         Stage IA           1.095890     Young
```

**📖 Interpretation:**
`filter()` keeps only the rows that meet a condition. All rows shown are female, so the filter worked.

> ⚠️ **Common mistake:** use `==` (two equals signs) to **compare**. A single `=` **assigns** a value and gives an error inside `filter()`.

### 14.2 Compare with the full dataset

```r
str(female_data)
```

**🖥️ Output:**

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

**📖 Interpretation:**
**247 of 445 patients are female.** The variables (columns) stay the same. Only the number of rows changes.

### 14.3 Combining conditions

```r
# AND: Female patients who are also Dead (comma or & means AND)
Data %>% filter(Gender == "Female", Vital_Status == "Dead")

# OR: patients older than 70 OR with Stage IV disease
Data %>% filter(Age > 70 | Pathologic_stage == "Stage IV")
```

**🧰 Comparison operators**

| Operator | Meaning |
|---|---|
| `==` | equal to |
| `!=` | not equal to |
| `>`, `<` | greater than, less than |
| `>=`, `<=` | greater or equal, less or equal |
| `&` or `,` | AND |
| `\|` | OR |
| `%in%` | is one of a set, e.g. `Race %in% c("Asian", "African")` |

---

## 🔢 15. Arrange (Sort) Rows

**✍️ Write the code in the Editor:**

```r
sorted_data <- Data %>%
  arrange(Age)

head(sorted_data)
```

**🖥️ Output:**

```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
1 TCGA-44-3917  33 Female European        Alive         Stage IB          0.8767123     Young
2 TCGA-35-4123  38   Male European        Alive         Stage IA          1.0958904     Young
3 TCGA-49-AARO  39 Female  African        Alive         Stage IA          0.0000000     Young
4 TCGA-53-7624  40 Female European         Dead         Stage IV          2.7397260     Young
5 TCGA-L9-A5IP  40 Female  African         Dead         Stage IV          0.0000000     Young
6 TCGA-55-8512  41   Male European         Dead         Stage IV          1.0410959     Young
```

**📖 Interpretation:**
`arrange()` sorts rows from smallest to largest by default, which makes the youngest patients easy to find.

To sort from **largest to smallest**, wrap the variable in `desc()`:

```r
Data %>% arrange(desc(Age)) %>% head()
```

---

## 🎯 16. Select Columns

**✍️ Write the code in the Editor:**

```r
selected_data <- Data %>%
  select(Age, Gender, Pathologic_stage)

head(selected_data)
```

**🖥️ Output:**

```
  Age Gender Pathologic_stage
1  63 Female        Stage IIA
2  67   Male         Stage IA
3  63   Male        Stage IIA
4  85 Female         Stage IB
5  79 Female        Stage IIB
6  60   Male         Stage IA
```

**📖 Interpretation:**
`select()` keeps only the columns you name, which simplifies the dataset for focused analysis.

Drop a column with a minus sign:

```r
Data %>% select(-ID) %>% head()
```

> 💡 **Memory trick:** `filter()` picks **rows**, `select()` picks **columns**.

---

## ➕ 17. Create New Variables with mutate()

**✍️ Write the code in the Editor:**

```r
Data <- Data %>%
  mutate(Age_Group2 = ifelse(Age > 60, "Older", "Younger"))

head(Data)
```

**🖥️ Output:**

```
            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group Age_Group2
1 TCGA-55-A48X  63 Female European        Alive        Stage IIA          1.9726027     Young      Older
2 TCGA-NJ-A55R  67   Male European        Alive         Stage IA          0.2739726       Old      Older
3 TCGA-53-A4EZ  63   Male European        Alive        Stage IIA          2.1917808     Young      Older
4 TCGA-44-6777  85 Female European         Dead         Stage IB          3.5068493       Old      Older
5 TCGA-55-6982  79 Female European         Dead         Stage IIB          0.0000000       Old      Older
6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young    Younger
```

**📖 Interpretation:**
`mutate()` creates a new column from existing ones. Here `Age_Group2` labels patients as **"Older"** if age is above 60 and **"Younger"** otherwise.

> 💡 **Boundary check (row 6):** that patient is exactly 60. Because the rule is `Age > 60` (strictly greater), 60 counts as "Younger". Use `Age >= 60` if you want 60 to be "Older". Always check which side of a cut-off your boundary value falls on.

> 📌 **Note:** we assigned the result back to `Data` (`Data <- Data %>% ...`), so `Data` now has a **new column** `Age_Group2` for the rest of the tutorial. If you do not assign it, the new column is shown but not saved.

---

## 📊 18. Summary Statistics with summarise()

**✍️ Write the code in the Editor:**

```r
Data %>%
  summarise(mean_age = mean(Age, na.rm = TRUE))
```

**🖥️ Output:**

```
  mean_age
1 65.23371
```

**📖 Interpretation:**
`summarise()` collapses the whole dataset into summary values. `na.rm = TRUE` tells R to ignore missing values. This dataset has none, but it is a good habit.

Calculate several statistics at once:

```r
Data %>%
  summarise(
    n          = n(),
    mean_age   = mean(Age),
    median_age = median(Age),
    sd_age     = sd(Age)
  )
```

> 💡 **mutate() vs summarise():** `mutate()` keeps **all rows** and adds a column. `summarise()` **collapses** rows into one summary row.

---

## 👥 19. Group-wise Summaries

**✍️ Write the code in the Editor:**

```r
Data %>%
  group_by(Gender) %>%
  summarise(mean_age = mean(Age, na.rm = TRUE))
```

**🖥️ Output:**

```
# A tibble: 2 × 2
  Gender mean_age
  <fct>     <dbl>
1 Female     65.3
2 Male       65.1
```

> ⚠️ **Check your output:** run the code yourself and use your own values in any report. The two means should average (weighted by group size) to the overall mean of 65.23.

**📖 Interpretation:**
`group_by()` splits the data into groups, and `summarise()` then runs **once per group**. Here it gives the mean age separately for each gender. The two means are very close, so there is no obvious age gap between women and men in this dataset.

---

## 🧰 20. Counting and Chaining Verbs

### 20.1 Count patients per group

**✍️ Write the code in the Editor:**

```r
Data %>% count(Vital_Status)
```

**📖 Interpretation:**
`count()` is a shortcut for `group_by()` plus `n()`. It returns the number of patients in each category.

### 20.2 Chain several verbs

**✍️ Write the code in the Editor:**

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

**📖 Interpretation:**
Read it step by step:

1. Take `Data`
2. **Keep** Stage IV patients
3. **Group** by gender
4. **Count** them and compute mean age
5. **Sort** with the largest group first

Chaining verbs with the pipe keeps the code readable from top to bottom.

---

# 🟫 PART 5: WRAP-UP

---

## 🔧 21. Reproducibility

**✍️ Write the code in the Editor:**

```r
sessionInfo()
```

**🖥️ Output (abridged):**

```
R version 4.5.2 (2025-10-31)
Platform: aarch64-apple-darwin20
Running under: macOS Sequoia 15.7.3

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
 [1] lubridate_1.9.5 forcats_1.0.1   stringr_1.6.0   dplyr_1.2.1     purrr_1.2.1     readr_2.2.0
 [7] tidyr_1.3.2     tibble_3.3.1    ggplot2_4.0.2   tidyverse_2.0.0
```

**📖 Interpretation:**
`sessionInfo()` records your R version, operating system, and package versions. Include it with your analysis so others can reproduce your results.

---

## ✅ 22. Conclusion

This tutorial walked through a complete workflow for analysing LUAD clinical data in R.

**🔑 Key takeaways**

1. **Always inspect first.** `head()`, `str()`, `summary()`, and `colSums(is.na())` reveal problems early.
2. **Convert categories to factors** so R summarizes them properly.
3. **Visualize before testing.** Histograms, bar plots, scatter plots, and boxplots show patterns at a glance.
4. **Correlation is not causation.** The age and smoking correlation was only 0.046, so there is essentially no linear association.
5. **dplyr verbs make code readable.** `filter()`, `arrange()`, `select()`, `mutate()`, `summarise()`, and `group_by()` cover most everyday data tasks.
6. **Document your environment** with `sessionInfo()`.

**🚀 Next steps**

- Make polished plots with **ggplot2**
- Test group differences with `t.test()` or `chisq.test()`
- Explore survival analysis with the `survival` package

---

## 🧠 23. Quiz

Try each question first, then click to reveal the answer.

### Part A: Multiple choice (Getting started, cleaning, and plots)

**Q1. What does `rm(list = ls())` do?**

- A. Deletes the dataset file from your computer
- B. Removes all objects from the R workspace
- C. Restarts R
- D. Closes all plots

<details><summary>Show answer</summary>

**B.** It clears every object in the current workspace. It does not touch files on disk.

</details>

**Q2. Which function shows the first six rows of a dataset?**

- A. `tail()`
- B. `str()`
- C. `head()`
- D. `summary()`

<details><summary>Show answer</summary>

**C.** `head()` shows the first six rows by default. `tail()` shows the last six.

</details>

**Q3. What does `str(Data)` tell you?**

- A. Only the number of rows
- B. The structure: dimensions, variable names, and data types
- C. The correlation between variables
- D. Missing values only

<details><summary>Show answer</summary>

**B.** It reports observations, variables, and the type of each column.

</details>

**Q4. In `summary(Data)`, why were Gender and Race shown only as "Length / Class / Mode"?**

- A. They contain missing values
- B. They are stored as character text, not factors
- C. They are numeric
- D. R cannot summarize categories

<details><summary>Show answer</summary>

**B.** Character columns are not summarized by category. Converting them to factors fixes this.

</details>

**Q5. `colSums(is.na(Data))` returns 0 for every column. What does this mean?**

- A. The data are all zeros
- B. There are no missing values
- C. The file is empty
- D. All columns are numeric

<details><summary>Show answer</summary>

**B.** It counts missing values per column, so all zeros means the dataset is complete.

</details>

**Q6. The mean cigarettes per day (1.51) is higher than the median (1.10). What does this suggest?**

- A. A left-skewed distribution
- B. A symmetric distribution
- C. A right-skewed distribution
- D. An error in the data

<details><summary>Show answer</summary>

**C.** A mean above the median usually means a few high values pull the mean up, which is right skew.

</details>

**Q7. A correlation of 0.046 between age and cigarettes per day indicates:**

- A. A strong positive relationship
- B. A strong negative relationship
- C. A negligible relationship
- D. A perfect relationship

<details><summary>Show answer</summary>

**C.** Values near 0 mean essentially no linear association.

</details>

**Q8. Which plot is best for comparing age across several groups?**

- A. A histogram
- B. A boxplot
- C. A scatter plot
- D. A pie chart

<details><summary>Show answer</summary>

**B.** Boxplots show the median, spread, and outliers for each group side by side.

</details>

**Q9. Why must you run `dev.off()` after `jpeg(...)`?**

- A. To display the plot on screen
- B. To close the file and finish writing the image
- C. To delete the plot
- D. To reset R

<details><summary>Show answer</summary>

**B.** Until the device is closed, the image file may be empty or incomplete.

</details>

**Q10. What is the purpose of `sessionInfo()`?**

- A. To speed up your code
- B. To record R and package versions for reproducibility
- C. To install packages
- D. To clean the data

<details><summary>Show answer</summary>

**B.** It documents the exact environment, so others can reproduce your results.

</details>

### Part B: Multiple choice (dplyr)

**Q11. Which dplyr verb keeps only rows that meet a condition?**

- A. `select()`
- B. `filter()`
- C. `arrange()`
- D. `mutate()`

<details><summary>Show answer</summary>

**B.** `filter()` subsets rows. `select()` subsets columns.

</details>

**Q12. What does the pipe `%>%` do?**

- A. Adds two numbers
- B. Passes the result on its left into the function on its right
- C. Saves a file
- D. Deletes missing values

<details><summary>Show answer</summary>

**B.** It chains steps so you can read code as "do this, then this".

</details>

**Q13. Which operator checks whether Gender equals "Female" inside `filter()`?**

- A. `=`
- B. `==`
- C. `!=`
- D. `<-`

<details><summary>Show answer</summary>

**B.** `==` compares values. `=` assigns, and `!=` means "not equal".

</details>

**Q14. Which code sorts patients from oldest to youngest?**

- A. `arrange(Age)`
- B. `arrange(desc(Age))`
- C. `sort(Age)`
- D. `filter(Age)`

<details><summary>Show answer</summary>

**B.** `arrange()` sorts ascending by default, and `desc()` reverses the order.

</details>

**Q15. What is the main difference between `mutate()` and `summarise()`?**

- A. They are identical
- B. `mutate()` keeps all rows, while `summarise()` collapses rows into summary values
- C. `summarise()` adds columns, while `mutate()` removes them
- D. `mutate()` only works on text

<details><summary>Show answer</summary>

**B.** `mutate()` returns one value per row, and `summarise()` returns one row per group.

</details>

**Q16. A patient aged exactly 60 is labelled "Younger" by `ifelse(Age > 60, "Older", "Younger")`. Why?**

- A. A bug in R
- B. `>` is strict, so 60 is not greater than 60
- C. 60 is a missing value
- D. `ifelse()` ignores whole numbers

<details><summary>Show answer</summary>

**B.** Use `>=` to include 60 in the "Older" group.

</details>

**Q17. What does `group_by(Gender)` do on its own, without `summarise()`?**

- A. Sorts the data
- B. Removes the Gender column
- C. Marks the groups but does not change how the data look
- D. Calculates the mean

<details><summary>Show answer</summary>

**C.** It sets up the grouping, and the next verb (usually `summarise()`) then works per group.

</details>

---

### Part C: True or false

**Q18. A mean and median that are close together suggest a roughly symmetric distribution.**

<details><summary>Show answer</summary>

**True.** In a symmetric distribution the two values are nearly equal.

</details>

**Q19. A weak correlation proves that two variables are unrelated.**

<details><summary>Show answer</summary>

**False.** Correlation only measures *linear* association. A weak value does not rule out a non-linear relationship.

</details>

**Q20. Correlation proves that one variable causes the other.**

<details><summary>Show answer</summary>

**False.** Correlation shows association only, not causation.

</details>

**Q21. `select()` chooses rows and `filter()` chooses columns.**

<details><summary>Show answer</summary>

**False.** It is the reverse: `filter()` chooses rows and `select()` chooses columns.

</details>

**Q22. After `filter(Gender == "Female")`, the number of columns changes.**

<details><summary>Show answer</summary>

**False.** Only the number of rows changes. All 8 columns remain.

</details>

**Q23. A mean age of 65.3 for females versus 65.1 for males proves a meaningful age difference between genders.**

<details><summary>Show answer</summary>

**False.** A 0.2-year gap is tiny. Only a proper statistical test, with an effect size and confidence interval, can say whether a difference is meaningful.

</details>

---

### Part D: Short answer

**Q24. Write one line of code to count how many patients are Alive vs Dead.**

<details><summary>Show answer</summary>

```r
table(Data$Vital_Status)
# or, with dplyr:
Data %>% count(Vital_Status)
```

</details>

**Q25. Write one line of code to find the mean age for each gender.**

<details><summary>Show answer</summary>

```r
tapply(Data$Age, Data$Gender, mean)
# or, with dplyr:
Data %>% group_by(Gender) %>% summarise(mean_age = mean(Age))
```

</details>

**Q26. Write code to keep only patients with Vital_Status "Dead".**

<details><summary>Show answer</summary>

```r
Data %>% filter(Vital_Status == "Dead")
```

</details>

**Q27. Write code to show only the columns `ID` and `Age`.**

<details><summary>Show answer</summary>

```r
Data %>% select(ID, Age)
```

</details>

**Q28. Write code to find the median `Cigarettes_per_day` for each `Vital_Status`.**

<details><summary>Show answer</summary>

```r
Data %>%
  group_by(Vital_Status) %>%
  summarise(median_cigs = median(Cigarettes_per_day))
```

</details>

**Q29. Why should you check for missing values before analysis?**

<details><summary>Show answer</summary>

Missing values can cause errors, bias results, or silently change summary statistics. Checking first tells you whether cleaning is needed.

</details>

---

### Part E: Try it yourself (not scored)

1. Make a boxplot of `Cigarettes_per_day` by `Gender`. Which group smokes more on average?
2. Create a bar plot of `Vital_Status`. What proportion of patients are Dead?
3. Calculate the correlation between `Age` and `Cigarettes_per_day` using `method = "spearman"`. Does it change the conclusion?
4. Create a dataset of male patients aged 70 or older with Stage IV disease. How many are there?
5. Add a column `Heavy_Smoker` that is "Yes" if `Cigarettes_per_day` is above 3 and "No" otherwise, then count each group.
6. Find the mean age and number of patients for each `Pathologic_stage`, sorted from largest group to smallest.

<details><summary>Show hints</summary>

```r
# 1
boxplot(Cigarettes_per_day ~ Gender, data = Data, col = "lightblue")

# 2
barplot(table(Data$Vital_Status), col = c("steelblue", "tomato"))
prop.table(table(Data$Vital_Status))

# 3
cor(Data$Age, Data$Cigarettes_per_day, method = "spearman")

# 4
Data %>%
  filter(Gender == "Male", Age >= 70, Pathologic_stage == "Stage IV") %>%
  nrow()

# 5
Data %>%
  mutate(Heavy_Smoker = ifelse(Cigarettes_per_day > 3, "Yes", "No")) %>%
  count(Heavy_Smoker)

# 6
Data %>%
  group_by(Pathologic_stage) %>%
  summarise(n = n(), mean_age = mean(Age)) %>%
  arrange(desc(n))
```

</details>

---


### 🎯 Scoring guide

Score yourself on the **23 graded items (Q1 to Q23)**: the multiple-choice questions in Parts A and B (Q1 to Q17) and the true/false questions in Part C (Q18 to Q23). Part D (short answer, Q24 to Q29) and Part E (try it yourself) are for practice and are **not scored**.

| Score (out of 23) | Level | What to do next |
|---|---|---|
| 21-23 | 🏆 **Excellent** | You are ready for ggplot2 and statistical testing (`t.test()`, `chisq.test()`). |
| 17-20 | 🥇 **Good** | Solid understanding. Review the sections for the questions you missed, then move on. |
| 12-16 | 🥈 **Fair** | Re-read Sections 6 to 11 (cleaning, descriptive statistics, plots) and Sections 14 to 19 (dplyr verbs), then retry the quiz. |
| 6-11 | 🥉 **Needs practice** | Re-run the code in Sections 5 to 12 yourself in RStudio, then retake the quiz. |
| 0-5 | 🔄 **Start again** | Work through the tutorial from Section 1, typing every code block rather than copying it. |

**💡 Tips for improving your score**

- If you missed questions on **loading and inspecting data** (Q1 to Q5), revisit Sections 3 to 6.
- If you missed questions on **statistics and plots** (Q6 to Q10, Q18 to Q20), revisit Sections 7 to 11.
- If you missed questions on **dplyr** (Q11 to Q17, Q21 to Q23), revisit Sections 13 to 20.

---

## 📌 24. Quick Reference Cheat Sheet

This section was listed in the contents but cut off, so here it is in full.

### Base R essentials

| Task | Code |
|---|---|
| Load a CSV | `Data <- read.csv("file.csv")` |
| First rows | `head(Data)` |
| Structure | `str(Data)` |
| Summary | `summary(Data)` |
| Missing values per column | `colSums(is.na(Data))` |
| Convert to factor | `Data$Gender <- factor(Data$Gender)` |
| Mean / median | `mean(Data$Age)` / `median(Data$Age)` |
| Frequency table | `table(Data$Gender)` |
| Correlation | `cor(Data$Age, Data$Cigarettes_per_day)` |

### Plots

| Plot | Code |
|---|---|
| Histogram | `hist(Data$Age)` |
| Bar plot | `barplot(table(Data$Gender))` |
| Scatter plot | `plot(Data$Age, Data$Cigarettes_per_day)` |
| Regression line | `abline(lm(y ~ x, data = Data))` |
| Boxplot | `boxplot(Age ~ Race, data = Data)` |
| Save a plot | `jpeg("plot.jpg")` ... `dev.off()` |

### dplyr verbs

| Verb | Purpose | Example |
|---|---|---|
| `filter()` | Keep rows | `Data %>% filter(Gender == "Female")` |
| `arrange()` | Sort rows | `Data %>% arrange(desc(Age))` |
| `select()` | Keep columns | `Data %>% select(Age, Gender)` |
| `mutate()` | New column | `Data %>% mutate(New = Age * 2)` |
| `summarise()` | Summary values | `Data %>% summarise(m = mean(Age))` |
| `group_by()` | Split into groups | `Data %>% group_by(Gender) %>% summarise(m = mean(Age))` |
| `count()` | Count per category | `Data %>% count(Race)` |

### Common mistakes to avoid

| ❌ Mistake | ✅ Fix |
|---|---|
| `filter(Gender = "Female")` | Use `==` for comparison |
| Forgetting `dev.off()` after `jpeg()` | Always close the file |
| Running `install.packages()` every session | Install once, then only `library()` |
| Reading a file that is not in the working directory | Check with `getwd()` |
| Assuming correlation means causation | Correlation shows association only |

---

## 🙏 Final Words

Congratulations on completing the tutorial! You can now load, clean, describe, visualize, and manipulate a real clinical dataset in R. The best way to build on this is to **practise on new data**, so try repeating the workflow on a different TCGA cancer cohort.

**📚 Where to go next**

1. **ggplot2:** publication-quality graphics
2. **Statistical tests:** `t.test()`, `chisq.test()`, `wilcox.test()`
3. **Survival analysis:** the `survival` and `survminer` packages
4. **R Markdown / Quarto:** turn your analysis into a shareable report

Happy analysing! 🫁📊

---
