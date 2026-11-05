# R Day 2 Recap

Review the five Day 2 tasks below, then open each answer to check the R code and expected results.

## Question 1

1. Create a directory named `R_day2`.
2. Set `R_day2` as the working directory.
3. Create a new R script named `Example.R` and save it in that folder.
4. Check the working directory and the `Data` folder, then create an `images` folder.

<details>
<summary>Show answer</summary>

```r
dir.create("R_day2")
setwd("R_day2")   # or Session > Set Working Directory in RStudio
# File > New File > R Script, then save as Example.R
getwd()           # should end with .../R_day2
list.files("Data")  # LUAD_clean_data_all_patients.csv
dir.create("images", showWarnings = FALSE)
```

Expected: `getwd()` ends with `.../R_day2`; `list.files("Data")` lists `LUAD_clean_data_all_patients.csv`; an `images` directory is created.

</details>

## Question 2

1. Load tidyverse, dplyr, ggplot2, ggsci, scales, and patchwork.
2. Read `Data/LUAD_clean_data_all_patients.csv`.
3. Print the last row, convert `Pathologic_stage` and `Age_Group` to factors, and inspect the structure.

<details>
<summary>Show answer</summary>

```r
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggsci)
library(scales)
library(patchwork)
data <- read.csv("Data/LUAD_clean_data_all_patients.csv")
tail(data, 1)
data$Pathologic_stage <- factor(data$Pathologic_stage)
data$Age_Group <- factor(data$Age_Group)
str(data)
```

Expected:

- `tail(data, 1)` shows: TCGA-73-4675, 59, Male, European, Dead, Stage IIIA, 2.246575, Young.
- The data frame has 445 observations of 8 variables.
- `Pathologic_stage` has 9 levels.
- `Age_Group` has 2 levels: Old and Young.

</details>

## Question 3

1. Group the data by `Gender` and calculate mean `Age`.
2. Use `geom_bar()` to plot the pathological stages, fill by stage with the NPG style, and rotate the x-axis labels 90 degrees (`angle = 90`, `hjust = 1`, `vjust = 0.5`).
3. Save the plot as a JPEG at 300 dpi.

<details>
<summary>Show answer</summary>

```r
data %>% group_by(Gender) %>% summarise(Mean_age = mean(Age))
p3 <- ggplot(data, aes(x = Pathologic_stage, fill = Pathologic_stage)) +
  geom_bar() +
  scale_fill_npg() +
  labs(title = "Pathologic Stage Distribution (NPG)", x = "Pathologic stage", y = "Number of patients", fill = "Pathologic stage") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
p3
ggsave("images/Fig_Q3_stage_distribution.jpeg", p3, width = 7, height = 5, units = "in", dpi = 300)
```

Expected:

- Mean age: Female 65.3; Male 65.1.
- Stage counts: Stage I 5, Stage IA 130, Stage IB 113, Stage II 1, Stage IIA 48, Stage IIB 58, Stage IIIA 62, Stage IIIB 7, Stage IV 21.
- Stage IB is the second-tallest bar.
- The JPEG is saved in `images/` at 300 dpi.

</details>

## Question 4

1. Inspect the pathological-stage levels and counts.
2. Identify the problematic stage from the bar plot (Stage IB), remove it with `filter()`, and drop unused factor levels with `droplevels()`.
3. Re-plot with `geom_bar()` and `scale_fill_npg(alpha = 0.5)`, then save as a JPEG at 300 dpi.

<details>
<summary>Show answer</summary>

```r
levels(data$Pathologic_stage)
table(data$Pathologic_stage, useNA = "ifany")
clean_data <- data %>% filter(Pathologic_stage != "Stage IB") %>% droplevels()
table(clean_data$Pathologic_stage)
nrow(clean_data)   # 445 - 113 = 332
p4 <- ggplot(clean_data, aes(x = Pathologic_stage, fill = Pathologic_stage)) +
  geom_bar() +
  scale_fill_npg(alpha = 0.5) +
  labs(title = "Pathologic Stage Distribution (cleaned)", x = "Pathologic stage", y = "Number of patients", fill = "Pathologic stage") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
p4
ggsave("images/Fig_Q4_stage_cleaned.jpeg", p4, width = 7, height = 5, units = "in", dpi = 300)
```

Expected: `clean_data` has 332 rows and 8 pathological-stage levels; Stage IB is gone. NPG assigns colours in level order, so colours shift after removing Stage IB (normal). The JPEG is saved in `images/` at 300 dpi.

</details>

## Question 5

1. Combine the Q3 and Q4 plots side by side with patchwork.
2. Tag the panels A and B.
3. Save the combined plot as a JPEG at 300 dpi and as a PDF.

<details>
<summary>Show answer</summary>

```r
combined <- p3 + p4 + plot_annotation(tag_levels = "A")
combined
ggsave("images/Fig_Q5_combined.jpeg", combined, width = 14, height = 5, units = "in", dpi = 300)
ggsave("images/Fig_Q5_combined.pdf", combined, width = 14, height = 5)
```

Expected: panel A shows 9 stages and panel B shows 8 stages; the JPEG and PDF files are saved in `images/`.

</details>

## Complete script

Run this combined script from the parent directory that contains the `Data` folder. The RStudio menu steps for creating and saving `Example.R` are included as comments.

```r
dir.create("R_day2")
setwd("R_day2")   # or Session > Set Working Directory in RStudio
# File > New File > R Script, then save as Example.R
getwd()           # should end with .../R_day2
list.files("Data")  # LUAD_clean_data_all_patients.csv
dir.create("images", showWarnings = FALSE)

library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggsci)
library(scales)
library(patchwork)
data <- read.csv("Data/LUAD_clean_data_all_patients.csv")
tail(data, 1)
data$Pathologic_stage <- factor(data$Pathologic_stage)
data$Age_Group <- factor(data$Age_Group)
str(data)

data %>% group_by(Gender) %>% summarise(Mean_age = mean(Age))
p3 <- ggplot(data, aes(x = Pathologic_stage, fill = Pathologic_stage)) +
  geom_bar() +
  scale_fill_npg() +
  labs(title = "Pathologic Stage Distribution (NPG)", x = "Pathologic stage", y = "Number of patients", fill = "Pathologic stage") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
p3
ggsave("images/Fig_Q3_stage_distribution.jpeg", p3, width = 7, height = 5, units = "in", dpi = 300)

levels(data$Pathologic_stage)
table(data$Pathologic_stage, useNA = "ifany")
clean_data <- data %>% filter(Pathologic_stage != "Stage IB") %>% droplevels()
table(clean_data$Pathologic_stage)
nrow(clean_data)   # 445 - 113 = 332
p4 <- ggplot(clean_data, aes(x = Pathologic_stage, fill = Pathologic_stage)) +
  geom_bar() +
  scale_fill_npg(alpha = 0.5) +
  labs(title = "Pathologic Stage Distribution (cleaned)", x = "Pathologic stage", y = "Number of patients", fill = "Pathologic stage") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
p4
ggsave("images/Fig_Q4_stage_cleaned.jpeg", p4, width = 7, height = 5, units = "in", dpi = 300)

combined <- p3 + p4 + plot_annotation(tag_levels = "A")
combined
ggsave("images/Fig_Q5_combined.jpeg", combined, width = 14, height = 5, units = "in", dpi = 300)
ggsave("images/Fig_Q5_combined.pdf", combined, width = 14, height = 5)
```

| Key function/operator | Use in this recap |
|---|---|
| `dir.create()` | Create the project and image directories. |
| `setwd()` | Set the working directory. |
| `library()` | Load R packages. |
| `read.csv()` | Read the clinical phenotype CSV. |
| `factor()` | Convert columns to categorical factors. |
| `group_by()` / `summarise()` | Group rows and calculate a summary statistic. |
| `geom_bar()` | Draw stage-count bar plots. |
| `scale_fill_npg()` | Apply the NPG palette, including adjusted alpha. |
| `filter()` | Remove Stage IB records. |
| `droplevels()` | Drop the unused Stage IB factor level. |
| `ggsave()` | Save plots as JPEG or PDF files. |
| patchwork `+` | Combine plots and add panel tags. |

## Recap summary

- Set up the `R_day2` working directory and save an R script as `Example.R`.
- Load the packages and clinical phenotype CSV, then inspect and factor the relevant variables.
- Summarise age by gender and visualise pathological-stage counts with NPG colours.
- Remove Stage IB, drop its unused factor level, and compare the cleaned plot with the original.
- Combine and save the plots in JPEG and PDF formats.

