# Tutorial 3 — Data visualization with ggplot2

A practical, static Markdown tutorial for learning the **grammar of graphics** with a 579-row clinical dataset. You will build plots one layer at a time, compare distributions and associations, and finish by combining and annotating figures.

## Contents

- [Learning objectives](#learning-objectives)
- [Before you start](#before-you-start)
- [Cheat sheet](#cheat-sheet)
- [Grammar of graphics & one variable](#grammar-of-graphics--one-variable)
- [Numeric by category](#numeric-by-category)
- [Two numeric variables](#two-numeric-variables)
- [Two categorical variables](#two-categorical-variables)
- [Facets, themes, and colour-blind design](#facets-themes-and-colour-blind-design)
- [Combining & annotating](#combining--annotating)
- [Common mistakes](#common-mistakes)
- [Practice exercises](#practice-exercises)
- [Reflection](#reflection)

## Learning objectives

By the end, you should be able to:

- Map variables to aesthetics such as x, y, colour, fill, and facets.
- Choose geoms that match numeric and categorical variables.
- Compare counts, proportions, distributions, and associations.
- Use scales, themes, palettes, and annotations to improve communication.
- Combine plots into a coherent, reproducible figure.

## Before you start

> **Setup:** Run the following code from the project root. It expects `data/clinical_data.csv` and creates a `figures/` folder for saved images. The dataset should contain `Age`, `Cigarettes_per_day`, `Gender`, `Race`, `Vital_Status`, `Pathologic_stage`, and `Age_Group`.

```r
library(tidyverse)
library(ggpubr)
library(patchwork)
library(scales)

clinical <- read_csv("data/clinical_data.csv", show_col_types = FALSE) |>
  mutate(
    Vital_Status = factor(Vital_Status),
    Gender = factor(Gender),
    Race = factor(Race),
    Pathologic_stage = factor(Pathologic_stage),
    Age_Group = factor(Age_Group)
  )

dir.create("figures", showWarnings = FALSE)
glimpse(clinical)
```

The examples use `tidyverse`, `ggpubr`, `patchwork`, and `scales`. Install any missing packages once with `install.packages(c("tidyverse", "ggpubr", "patchwork", "scales"))`.

## Cheat sheet

| Variable type | Useful plot | Common geom(s) |
|---|---|---|
| One numeric variable | Distribution | `geom_histogram()`, `geom_density()` |
| One categorical variable | Counts or proportions | `geom_bar()` |
| Numeric by category | Group comparison | `geom_boxplot()`, `geom_violin()`, `geom_jitter()` |
| Two numeric variables | Association | `geom_point()`, `geom_smooth()` |
| Two categorical variables | Composition | `geom_bar(position = "fill")` |
| Any plot split by a variable | Small multiples | `facet_wrap()` |

---

## 🎨 Grammar of graphics & one variable

### Q1. What is a ggplot object made from?

Identify the data, aesthetic mapping, geometry, scale, and theme.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_age_hist <- ggplot(clinical, aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "#0072B2", colour = "white") +
  labs(title = "Age distribution", x = "Age (years)", y = "Count")
p_age_hist
```

**What to look for:** Look for how `ggplot()` supplies data and mappings, while geoms, scales, and themes build the visual result.

### Q2. How does age vary as a smooth distribution?

Use a density curve instead of histogram bins.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_age_density <- ggplot(clinical, aes(x = Age)) +
  geom_density(fill = "#56B4E9", alpha = 0.6) +
  labs(title = "Smoothed age distribution", x = "Age (years)", y = "Density") +
  theme_minimal()
p_age_density
```

**What to look for:** Look for peaks, spread, and possible skew in the age distribution.

### Q3. Which age group is more common?

Count the observations in each categorical level.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_age_group <- ggplot(clinical, aes(x = Age_Group, fill = Age_Group)) +
  geom_bar() +
  scale_fill_manual(values = c("Young" = "#009E73", "Old" = "#E69F00")) +
  labs(title = "Patients by age group", x = "Age group", y = "Count") +
  theme_minimal() +
  guides(fill = "none")
p_age_group
```

**What to look for:** Look for the taller bar; it represents the more frequent age group.

### Q4. Can you label a bar chart with percentages?

Compute each bar's share of the full sample and format the y-axis as percentages.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_age_group_pct <- ggplot(clinical, aes(x = Age_Group)) +
  geom_bar(aes(y = after_stat(count / sum(count)), group = 1, fill = Age_Group)) +
  scale_y_continuous(labels = scales::label_percent()) +
  scale_fill_manual(values = c("Young" = "#009E73", "Old" = "#E69F00")) +
  labs(title = "Age-group composition", x = "Age group", y = "Percent") +
  theme_minimal() +
  guides(fill = "none")
p_age_group_pct
```

**What to look for:** Check that the bars sum to 100% and that the labels are proportions rather than raw counts.

### Q5. How would you save a plot?

Pass a file path, plot object, dimensions, and resolution to `ggsave()`.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggsave(
  filename = "figures/age_distribution.png",
  plot = p_age_density,
  width = 7,
  height = 5,
  dpi = 300
)
```

**What to look for:** The saved file should preserve the plot's intended dimensions and readable text.

---

## 📊 Numeric by category

### Q6. Does age differ by vital status?

Compare distributions with a boxplot.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_age_status <- ggplot(clinical, aes(x = Vital_Status, y = Age, fill = Vital_Status)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Age by vital status", x = "Vital status", y = "Age (years)") +
  theme_minimal() +
  guides(fill = "none")
p_age_status
```

**What to look for:** Compare medians, interquartile ranges, whiskers, and potential outliers across status groups.

### Q7. How can you show individual observations?

Add jitter with low opacity so overlapping points remain visible.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Vital_Status, y = Age, colour = Vital_Status)) +
  geom_jitter(width = 0.15, alpha = 0.35) +
  labs(title = "Individual ages by vital status", x = "Vital status", y = "Age (years)") +
  theme_classic() +
  guides(colour = "none")
```

**What to look for:** Look for clustering, overlap, and observations that are hidden by a summary-only plot.

### Q8. What does a violin reveal that a boxplot may hide?

Combine a violin with a narrow boxplot.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Vital_Status, y = Age, fill = Vital_Status)) +
  geom_violin(trim = FALSE, alpha = 0.6) +
  geom_boxplot(width = 0.12, outlier.shape = NA) +
  labs(title = "Age distributions by vital status", x = "Vital status", y = "Age (years)") +
  theme_minimal() +
  guides(fill = "none")
```

**What to look for:** The violin shape highlights density and multimodality, while the boxplot gives familiar summary statistics.

### Q9. Is smoking intensity different by age group?

Use `Cigarettes_per_day` as the numeric outcome.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Age_Group, y = Cigarettes_per_day, fill = Age_Group)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.2) +
  labs(title = "Smoking intensity by age group", x = "Age group", y = "Cigarettes per day") +
  theme_minimal() +
  guides(fill = "none")
```

**What to look for:** Compare the typical smoking intensity and the amount of within-group variability.

### Q10. How can you reorder categories by a numeric summary?

Reorder race levels by the median age and flip the coordinates.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = reorder(Race, Age, FUN = median), y = Age)) +
  geom_boxplot(fill = "#0072B2", alpha = 0.75) +
  coord_flip() +
  labs(title = "Age distributions ordered by median", x = "Race", y = "Age (years)") +
  theme_minimal()
```

**What to look for:** The category order should make median differences easier to compare than alphabetical order.

---

## 📈 Two numeric variables

### Q11. Are cigarettes per day associated with age?

Map one numeric variable to each axis.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_scatter <- ggplot(clinical, aes(x = Age, y = Cigarettes_per_day)) +
  geom_point(alpha = 0.55, colour = "#0072B2") +
  labs(title = "Age and smoking intensity", x = "Age (years)", y = "Cigarettes per day") +
  theme_minimal()
p_scatter
```

**What to look for:** Look for direction, strength, curvature, clusters, and unusual observations.

### Q12. How would you add a linear model and confidence band?

Add `geom_smooth(method = "lm")` to the scatter plot.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_lm <- p_scatter +
  geom_smooth(method = "lm", se = TRUE, colour = "#D55E00")
p_lm
```

**What to look for:** The fitted line summarizes the linear trend; the shaded band represents model uncertainty around the mean trend.

### Q13. Can you colour the relationship by vital status?

Map `colour` inside `aes()` and fit separate lines by group.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Age, y = Cigarettes_per_day, colour = Vital_Status)) +
  geom_point(alpha = 0.55) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Age and smoking intensity by vital status", x = "Age (years)", y = "Cigarettes per day") +
  theme_minimal()
```

**What to look for:** Compare the group-specific patterns, while remembering that fitted lines describe association rather than causation.

### Q14. What is the Pearson correlation?

Run `cor.test()` on complete pairs of numeric observations.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
complete_numeric <- clinical |>
  select(Age, Cigarettes_per_day) |>
  drop_na()
cor.test(complete_numeric$Age, complete_numeric$Cigarettes_per_day, method = "pearson")
```

**What to look for:** Read the correlation estimate, confidence interval, and p-value together; statistical significance is not effect size.

---

## 🧩 Two categorical variables

### Q15. How is vital status distributed within each race?

Use stacked bars to count status within race.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar() +
  labs(title = "Vital status counts by race", x = "Race", y = "Count", fill = "Vital status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

**What to look for:** Compare both the total bar heights and the composition of each race group.

### Q16. How do proportions compare across race?

Set `position = "fill"` and format the y-axis as percentages.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(title = "Vital status proportions within race", x = "Race", y = "Percent", fill = "Vital status") +
  theme_minimal()
```

**What to look for:** Every bar should reach 100%; compare the relative shares rather than the sample sizes.

### Q17. Can you make the comparison horizontal?

Reuse the proportional bar chart and add `coord_flip()`.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar(position = "fill") +
  coord_flip() +
  scale_x_discrete(limits = rev(levels(clinical$Race))) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(title = "Vital status proportions within race", x = "Race", y = "Percent", fill = "Vital status") +
  theme_minimal()
```

**What to look for:** Horizontal labels are often easier to read when category names are long or numerous.

### Q18. Which stage counts are largest?

Count `Pathologic_stage` and flip the coordinates.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Pathologic_stage, fill = Vital_Status)) +
  geom_bar() +
  coord_flip() +
  labs(title = "Patients by pathologic stage", x = "Pathologic stage", y = "Count", fill = "Vital status") +
  theme_minimal()
```

**What to look for:** Identify the most common stages and note whether their status composition appears similar or different.

---

## 🖌️ Facets, themes, and colour-blind design

### Q19. How does the age distribution vary by sex?

Facet a histogram by `Gender` and suppress the redundant fill legend.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Age, fill = Gender)) +
  geom_histogram(binwidth = 5) +
  facet_wrap(~ Gender) +
  guides(fill = "none") +
  labs(title = "Age distributions by gender", x = "Age (years)", y = "Count") +
  theme_minimal()
```

**What to look for:** Compare the shapes and ranges across panels using consistent axes.

### Q20. How can you show age patterns by race and vital status?

Facet by race and fill the histograms by vital status.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Age, fill = Vital_Status)) +
  geom_histogram(binwidth = 5, position = "identity", alpha = 0.5) +
  facet_wrap(~ Race) +
  labs(title = "Age by race and vital status", x = "Age (years)", y = "Count", fill = "Vital status") +
  theme_bw()
```

**What to look for:** Use the common axes to compare distributions across race panels without over-interpreting sparse groups.

### Q21. Which theme improves a dense categorical plot?

Try a restrained theme and rotate crowded x-axis labels.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggplot(clinical, aes(x = Pathologic_stage, y = Age, fill = Vital_Status)) +
  geom_boxplot() +
  labs(title = "Age by pathologic stage and vital status", x = "Pathologic stage", y = "Age (years)", fill = "Vital status") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

**What to look for:** A theme should improve legibility without competing with the data; label rotation is useful but not a substitute for sensible ordering.

### Q22. Can you use a colour-blind-friendly palette?

Use Okabe–Ito colours and derive names from the actual factor levels.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
okabe <- setNames(
  c("#0072B2", "#D55E00"),
  levels(clinical$Vital_Status)
)

ggplot(clinical, aes(x = Vital_Status, y = Age, fill = Vital_Status)) +
  geom_boxplot() +
  scale_fill_manual(values = okabe) +
  labs(title = "Age by vital status", x = "Vital status", y = "Age (years)", fill = "Vital status") +
  theme_classic()
```

**What to look for:** Check that each status level has the intended colour and that the contrast remains clear without relying on hue alone.

---

## 🧱 Combining & annotating

### Q23. How do you make a figure publication-ready?

Add informative labels, a caption, and a restrained theme to the previously defined model plot.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_pub <- p_lm +
  labs(
    title = "Age and smoking intensity",
    subtitle = "Linear trend with 95% confidence band",
    x = "Age (years)",
    y = "Cigarettes per day",
    caption = "Clinical teaching dataset"
  ) +
  theme_classic(base_size = 12)
p_pub
```

**What to look for:** A publication-ready figure makes the variables, units, uncertainty, and context explicit.

### Q24. Can you combine several panels?

Use `patchwork` to arrange the density, scatter, and model plots.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_combo <- (p_age_density | p_scatter) / p_lm +
  plot_annotation(title = "Clinical overview")
p_combo
```

**What to look for:** Check that each panel contributes a distinct view and that the combined figure has a coherent visual story.

### Q25. How do you save the multi-panel figure?

Pass the patchwork object to `ggsave()` with a larger canvas.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
ggsave(
  filename = "figures/ggplot2_multi_panel.png",
  plot = p_combo,
  width = 11,
  height = 8,
  dpi = 300
)
```

**What to look for:** The output should be large enough for all panels, labels, and the shared title to remain readable.

### Q26. How would you preview a group-comparison annotation?

Use `stat_compare_means()` as a visual aid, not as a substitute for a prespecified analysis.

> **Hint:** Use the prompt and inspect the relevant visual encoding before changing the code.

```r
p_annotation <- ggboxplot(
  clinical,
  x = "Vital_Status",
  y = "Age",
  color = "Vital_Status",
  add = "jitter"
) +
  stat_compare_means(method = "wilcox.test") +
  labs(title = "Age by vital status", x = "Vital status", y = "Age (years)") +
  theme_minimal()
p_annotation
```

**What to look for:** Treat the annotation as exploratory context and report the study design, estimand, and assumptions separately.

---

## Common mistakes

- Mapping a constant inside `aes()` instead of setting it outside, or doing the reverse when you want a legend.
- Comparing raw counts when group sizes differ; use `position = "fill"` for within-group proportions.
- Forgetting `drop_na()` before a correlation or model when missing pairs are present.
- Using a palette whose names do not match the factor levels; derive manual names from `levels()`.
- Overplotting every point without transparency or jitter.
- Treating a fitted line or p-value as evidence of causation.

## Practice exercises

Try these without looking for an answer key:

1. Recreate Q1 with a different bin width and explain how the story changes.
2. Add a median marker to the Q6 boxplot using a summary layer.
3. Make a proportional bar chart of `Pathologic_stage` by `Vital_Status`.
4. Facet the Q11 scatter plot by `Race` and compare the slopes visually.
5. Choose one plot and export a version with a descriptive filename and caption.

## Reflection

A useful visualization states the population, variable roles, graphical encoding, uncertainty, and limitations. Ask whether the plot answers the question, whether the scale is honest, and whether missingness or sparse groups could change the interpretation. Avoid implying causation from an observational plot.

