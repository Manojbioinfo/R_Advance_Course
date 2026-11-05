# R Day 2 Recap

Review the five Day 2 tasks below, then open each answer to check the R code and expected results.

## Question 1

1. Create a directory named `R_day2`.

<details>
<summary>Show hint</summary>

Use `dir.create()` with the folder name in quotes. Run it from the parent folder that contains `Data`, and run it before `setwd()`.

</details>

<details>
<summary>Show answer</summary>

```r
dir.create("R_day2")
```

</details>


2. Set `R_day2` as the working directory.

<details>
<summary>Show hint</summary>

Use `setwd()` with the folder name, or Session > Set Working Directory in RStudio. Run it only once, otherwise R looks for `R_day2/R_day2`.

</details>

<details>
<summary>Show answer</summary>

```r
setwd("R_day2")
# or Session > Set Working Directory in RStudio
```

</details>


3. Create a new R script named `Example.R` and save it in that folder.

<details>
<summary>Show hint</summary>

Use File > New File > R Script, then save it as `Example.R` while you are inside `R_day2`. Check that the file appears in the Files pane.

</details>

<details>
<summary>Show answer</summary>

```r
# File > New File > R Script, then save as Example.R
```

</details>


4. Check the working directory and the `Data` folder, then create an `images` folder.

<details>
<summary>Show hint</summary>

`getwd()` should end with `R_day2`. If `list.files("Data")` is empty, `Data` is one level up, so use `"../Data"` or copy it in. `showWarnings = FALSE` stops the warning if `images` already exists.

</details>

<details>
<summary>Show answer</summary>

```r
getwd()           # should end with .../R_day2
list.files("Data")  # LUAD_clean_data_all_patients.csv
dir.create("images", showWarnings = FALSE)
```

Expected: `getwd()` ends with `.../R_day2`; `list.files("Data")` lists `LUAD_clean_data_all_patients.csv`; an `images` directory is created.

</details>

## Question 2

1. Load tidyverse, dplyr, ggplot2, ggsci, scales, and patchwork.

<details>
<summary>Show hint</summary>

Use one `library()` call per package. If R says a package is not found, run `install.packages("name")` first, then load it again.

</details>

<details>
<summary>Show answer</summary>

```r
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggsci)
library(scales)
library(patchwork)
```

</details>


2. Read `Data/LUAD_clean_data_all_patients.csv`.

<details>
<summary>Show hint</summary>

Use `read.csv()` with the path in quotes and assign the result to `data`. A "cannot open file" error means the working directory is wrong, so check `getwd()`.

</details>

<details>
<summary>Show answer</summary>

```r
data <- read.csv("Data/LUAD_clean_data_all_patients.csv")
```

</details>


3. Print the last row, convert `Pathologic_stage` and `Age_Group` to factors, and inspect the structure.

<details>
<summary>Show hint</summary>

`tail(data, 1)` gives the last row only. Convert with `factor()` and assign back to the same column, otherwise nothing changes. Then use `str(data)` to check: 445 obs. of 8 variables, 9 stage levels, 2 age-group levels.

</details>

<details>
<summary>Show answer</summary>

```r
tail(data, 1)
data $ Pathologic_stage <- factor(data $ Pathologic_stage)
data $ Age_Group <- factor(data $ Age_Group)
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

<details>
<summary>Show hint</summary>

Pipe `data` into `group_by(Gender)`, then `summarise()`. Name the result `Mean_age` so it does not shadow the original `Age` column. Expect Female 65.3 and Male 65.1.

</details>

<details>
<summary>Show answer</summary>

```r
data %>% group_by(Gender) %>% summarise(Mean_age = mean(Age))
```

</details>


2. Use `geom_bar()` to plot the pathological stages, fill by stage with the NPG style, and rotate the x-axis labels 90 degrees (`angle = 90`, `hjust = 1`, `vjust = 0.5`).

<details>
<summary>Show hint</summary>

Put `x` and `fill` inside `aes()`, both set to `Pathologic_stage`. `geom_bar()` counts rows itself, so give it no y. Add `scale_fill_npg()` for the palette and rotate labels with `theme(axis.text.x = element_text(...))`. Each `+` goes at the end of a line, not the start.

</details>

<details>
<summary>Show answer</summary>

```r
p3 <- ggplot(data, aes(x = Pathologic_stage, fill = Pathologic_stage)) +
  geom_bar() +
  scale_fill_npg() +
  labs(title = "Pathologic Stage Distribution (NPG)", x = "Pathologic stage", y = "Number of patients", fill = "Pathologic stage") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
p3
```

</details>


3. Save the plot as a JPEG at 300 dpi.

<details>
<summary>Show hint</summary>

Use `ggsave()` with the file path inside `images/`, the plot object, a width and height, `units = "in"`, and `dpi = 300`. Make sure `images/` exists first.

</details>

<details>
<summary>Show answer</summary>

```r
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

<details>
<summary>Show hint</summary>

`levels()` lists the categories and `table()` counts them. Use `useNA = "ifany"` so missing values show up. Stage IB should have 113 patients.

</details>

<details>
<summary>Show answer</summary>

```r
levels(data $ Pathologic_stage)
table(data $ Pathologic_stage, useNA = "ifany")
```

</details>


2. Identify the problematic stage from the bar plot (Stage IB), remove it with `filter()`, and drop unused factor levels with `droplevels()`.

<details>
<summary>Show hint</summary>

Use `filter(Pathologic_stage != "Stage IB")`, spelled exactly as in the data. Then pipe into `droplevels()`, or the empty Stage IB slot stays in the plot. Save into a new object (`clean_data`) so `data` stays intact, and check that `nrow(clean_data)` is 332.

</details>

<details>
<summary>Show answer</summary>

```r
clean_data <- data %>% filter(Pathologic_stage != "Stage IB") %>% droplevels()
table(clean_data$Pathologic_stage)
nrow(clean_data)   # 445 - 113 = 332
```

</details>


3. Re-plot with `geom_bar()` and `scale_fill_npg(alpha = 0.5)`, then save as a JPEG at 300 dpi.

<details>
<summary>Show hint</summary>

Build the same plot as Q3 but with `clean_data`, not `data`, and use `scale_fill_npg(alpha = 0.5)`. Save with `ggsave()` at 300 dpi. Colours shifting is normal, because NPG assigns colours in level order.

</details>

<details>
<summary>Show answer</summary>

```r
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

<details>
<summary>Show hint</summary>

`p3` and `p4` must already exist, so run Q3 and Q4 first. Adding them with `p3 + p4` places them side by side.

</details>

<details>
<summary>Show answer</summary>

```r
combined <- p3 + p4
```

</details>


2. Tag the panels A and B.

<details>
<summary>Show hint</summary>

Add `plot_annotation(tag_levels = "A")` to the combined plot with `+`.

</details>

<details>
<summary>Show answer</summary>

```r
combined <- p3 + p4 + plot_annotation(tag_levels = "A")
combined
```

</details>


3. Save the combined plot as a JPEG at 300 dpi and as a PDF.

<details>
<summary>Show hint</summary>

Use two `ggsave()` calls on the combined object. Make the figure wide (for example `width = 14, height = 5`) so the panels are not squashed. PDF is vector-based, so it does not need `dpi`. Confirm both files with `list.files("images")`.

</details>

<details>
<summary>Show answer</summary>

```r
ggsave("images/Fig_Q5_combined.jpeg", combined, width = 14, height = 5, units = "in", dpi = 300)
ggsave("images/Fig_Q5_combined.pdf", combined, width = 14, height = 5)
```

Expected: panel A shows 9 stages and panel B shows 8 stages; the JPEG and PDF files are saved in `images/`.

</details>
