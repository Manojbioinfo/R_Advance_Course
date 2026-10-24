# Tutorial 4 — `clinical` Data Visualization (ggplot2) Notes

> **Note on the source transcript.** The file `/mnt/user-data/uploads/clipboard.txt`
> is the **ggplot2 visualization tutorial** ("Data Visualization with ggplot2")
> built around an 8-column, 981-patient `clinical` data frame
> (`Age`, `Cigarettes_per_day`, `Gender`, `Race`, `Vital_Status`,
> `Pathologic_stage`, `Age_Group`, plus an ID). It is **not** the
> TCGA Pan-Cancer biostatistics / survival analysis session described in the
> task brief. This document therefore summarises the workflow that is actually
> present in the transcript, and the "known issues resolved" section records the
> specific fixes applied during cleanup.
>
> The companion biostatistics scripts live in the two sibling clipboard files
> (`clipboard(1).txt`, `clipboard(2).txt`) and in
> `/mnt/user-data/outputs/Tutorial_4_PanCancer.{R,md}`; none of their R code is
> reproduced here, because it is not part of the uploaded `clipboard.txt`.

---

## Setup

```r
library(tidyverse)
library(ggpubr)
library(patchwork)
library(RColorBrewer)
library(scales)

clinical <- read_csv("data/clinical_data.csv") |>
  mutate(
    Gender            = factor(Gender),
    Race              = factor(Race),
    Vital_Status      = factor(Vital_Status),
    Pathologic_stage  = factor(Pathologic_stage),
    Age_Group         = factor(Age_Group)
  )

str(clinical)   # tibble [981 × 8]

dir.create("figures", showWarnings = FALSE)
```

---

## 1. Grammar of graphics & one variable

### Q1. Age distribution — default histogram

```r
p_age_hist <- ggplot(clinical, aes(x = Age)) +
  geom_histogram(colour = "white", fill = "#0072B2") +
  labs(title = "Age distribution", x = "Age (years)", y = "Number of patients") +
  theme_minimal()

ggsave("Fig4_1_p_age_hist.jpeg", p_age_hist, width = 7, height = 5, units = "in", dpi = 300)
p_age_hist
```

**What to look for.** Centre, spread, skew, gaps, and unusually high or low ages.
A tall bin is a **count**, not a rate. Default bin width depends on the data
range, so compare shapes carefully.

### Q2. Age distribution — histogram, 10-year bins

```r
p_age_hist_binned <- ggplot(clinical, aes(x = Age)) +
  geom_histogram(binwidth = 10, boundary = 0, colour = "white", fill = "#0072B2") +
  labs(title = "Age distribution", x = "Age (years)", y = "Number of patients") +
  theme_minimal()

ggsave("Fig4_2_p_age_hist_binned.jpeg", p_age_hist_binned, width = 7, height = 5, units = "in", dpi = 300)
p_age_hist_binned
```

**What to look for.** With fixed-width bins the shape is stable and comparable;
contrast it with the default-binned histogram above.

### Q3 (renumbered). Age as a smoothed density curve

The transcript labels this section "**Q2**" but, given the surrounding context,
it is the third visualisation question. Renumbered **Q3** below.

```r
p_age_density <- ggplot(clinical, aes(x = Age)) +
  geom_density(fill = "#56B4E9", colour = "#0072B2", alpha = 0.65, na.rm = TRUE) +
  labs(title = "Smoothed age density", x = "Age (years)", y = "Density") +
  theme_minimal()

p_age_density
```

**What to look for.** Peaks indicate ages where observations are concentrated.
The y-axis is density, not a count (area under the curve = 1).

### Q4. Patients per `Age_Group` — counts

```r
p_age_group_counts <- ggplot(clinical, aes(x = Age_Group)) +
  geom_bar(fill = "#009E73") +
  labs(title = "Patients by age group", x = "Age group", y = "Number of patients") +
  theme_minimal()

p_age_group_counts
```

**What to look for.** Number of records in each age group; check that the factor
ordering communicates the intended progression.

### Q5. `Age_Group` bars with percentage labels

```r
p_age_group_percent <- ggplot(clinical, aes(x = Age_Group)) +
  geom_bar(fill = "#009E73") +
  geom_text(
    aes(
      y = after_stat(count),
      label = scales::percent(after_stat(count / sum(count)), accuracy = 0.1)
    ),
    stat = "count",
    vjust = -0.35
  ) +
  labs(title = "Patients by age group", x = "Age group", y = "Number of patients") +
  expand_limits(y = NA) +
  theme_minimal()

p_age_group_percent
```

**What to look for.** Each label should represent that group's share of all
plotted records; percentages sum to ~100% after rounding.

### Q6. Save the age distribution figure

```r
ggsave(
  filename = "figures/age_distribution.png",
  plot     = p_age_hist,
  width    = 7, height = 5, units = "in", dpi = 300
)
```

**What to look for.** `figures/age_distribution.png` is created at the requested
size and resolution, with legible labels outside the R plotting pane.

---

## 2. Numeric by category

### Q7. Age by `Vital_Status` — boxplot

```r
p_age_status_box <- ggplot(clinical, aes(x = Vital_Status, y = Age)) +
  geom_boxplot(fill = "#E69F00", na.rm = TRUE) +
  labs(title = "Age by vital status", x = "Vital status", y = "Age (years)") +
  theme_minimal()

p_age_status_box
```

**What to look for.** Medians and IQRs; remember that group sizes and overlapping
distributions affect how convincing a visual difference is.

### Q8. Jittered individual ages by `Vital_Status`

```r
p_age_status_jitter <- ggplot(clinical, aes(x = Vital_Status, y = Age)) +
  geom_jitter(width = 0.18, height = 0, alpha = 0.45, colour = "#0072B2", na.rm = TRUE) +
  labs(title = "Individual ages by vital status", x = "Vital status", y = "Age (years)") +
  theme_minimal()

p_age_status_jitter
```

**What to look for.** Raw observations, repeated ages, gaps, and unequal group
sizes that a boxplot alone hides.

### Q9. Violin + boxplot for Age by `Vital_Status`

```r
p_age_status_violin <- ggplot(clinical, aes(x = Vital_Status, y = Age, fill = Vital_Status)) +
  geom_violin(alpha = 0.55, trim = FALSE, na.rm = TRUE) +
  geom_boxplot(width = 0.14, outlier.shape = NA, fill = "white", na.rm = TRUE) +
  labs(title = "Age distribution by vital status", x = "Vital status", y = "Age (years)") +
  guides(fill = "none") +
  theme_minimal()

p_age_status_violin
```

**What to look for.** Violin shows distribution shape, boxplot anchors median
and quartiles. Do not treat smoothed violin width as extra observations.

### Q10. `Cigarettes_per_day` by `Age_Group`

```r
p_smoking_age_group <- ggplot(clinical, aes(x = Age_Group, y = Cigarettes_per_day)) +
  geom_boxplot(outlier.shape = NA, fill = "#D55E00", alpha = 0.65, na.rm = TRUE) +
  geom_jitter(width = 0.16, alpha = 0.4, colour = "#333333", na.rm = TRUE) +
  labs(
    title = "Cigarettes per day by age group",
    x = "Age group",
    y = "Cigarettes per day"
  ) +
  theme_minimal()

p_smoking_age_group
```

**What to look for.** Medians, variability, zeros, and extreme values. Do not
mistake missing smoking values for zero cigarettes per day.

### Q11. Race ordered by median Age, flipped

```r
p_age_race <- ggplot(
  clinical,
  aes(x = reorder(Race, Age, FUN = median, na.rm = TRUE), y = Age)
) +
  geom_boxplot(fill = "#CC79A7", na.rm = TRUE) +
  coord_flip() +
  labs(title = "Age by race, ordered by median age", x = "Race", y = "Age (years)") +
  theme_minimal()

p_age_race
```

**What to look for.** Race categories are ordered by observed median Age, not
alphabetically. Small groups may have unstable medians.

---

## 3. Two numeric variables

### Q12. Age vs `Cigarettes_per_day` — scatter

```r
p_scatter <- ggplot(clinical, aes(x = Age, y = Cigarettes_per_day)) +
  geom_point(alpha = 0.55, colour = "#0072B2", na.rm = TRUE) +
  labs(
    title = "Age and cigarettes per day",
    x = "Age (years)",
    y = "Cigarettes per day"
  ) +
  theme_minimal()

p_scatter
```

**What to look for.** Direction, strength, nonlinearity, clusters, and
influential points. A point cloud without a visible trend is still informative.

### Q13. Add a linear-model smooth

```r
p_lm <- p_scatter +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, colour = "#D55E00", na.rm = TRUE) +
  labs(title = "Age and cigarettes per day with a linear trend")

p_lm
```

**What to look for.** The line summarises the average linear trend; the band
reflects uncertainty in the **fitted mean**, not the range of individual future
observations.

### Q14. Age–Cigarettes relationship by `Vital_Status`

```r
p_status_lm <- ggplot(clinical, aes(x = Age, y = Cigarettes_per_day, colour = Vital_Status)) +
  geom_point(alpha = 0.5, na.rm = TRUE) +
  geom_smooth(aes(group = Vital_Status), method = "lm", formula = y ~ x, se = FALSE, na.rm = TRUE) +
  labs(
    title = "Age and cigarettes per day by vital status",
    x = "Age (years)",
    y = "Cigarettes per day",
    colour = "Vital status"
  ) +
  theme_minimal()

p_status_lm
```

**What to look for.** Compare fitted slopes and overlap; do not claim a group
difference from line separation alone — sample size, confounding, and
uncertainty matter.

### Q15. Correlation on complete pairs

```r
complete_numeric <- clinical |>
  select(Age, Cigarettes_per_day) |>
  drop_na()

cor.test(
  complete_numeric$Age,
  complete_numeric$Cigarettes_per_day,
  method = "pearson"
)
```

**What to look for.** Read the estimate, CI, and p-value together. Correlation
measures linear association and does not establish causation.

---

## 4. Two categorical variables

### Q16. `Vital_Status` counts within `Race` — stacked bars

```r
p_race_status_counts <- ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar() +
  labs(title = "Vital status counts within race", x = "Race", y = "Number of patients", fill = "Vital status") +
  theme_minimal()

p_race_status_counts
```

**What to look for.** Total bar height = records in each Race; segment height =
count for each `Vital_Status`.

### Q17. `Vital_Status` percentages within `Race`

```r
p_race_status_percent <- ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar(position = "fill") +
  geom_text(
    aes(label = scales::percent(after_stat(count / sum(count)), accuracy = 1)),
    stat = "count",
    position = position_fill(vjust = 0.5),
    colour = "white", size = 3
  ) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Vital status composition within race", x = "Race", y = "Percent", fill = "Vital status") +
  theme_minimal()

p_race_status_percent
```

**What to look for.** Composition rather than group size. A small Race can show
a high percentage on relatively few records.

### Q18. Flip the Race-by-`Vital_Status` chart

```r
p_race_status_flipped <- p_race_status_counts +
  coord_flip() +
  labs(title = "Vital status counts within race (flipped)")

p_race_status_flipped
```

**What to look for.** Long Race labels become easier to read; stacked counts
are unchanged.

### Q19. `Pathologic_stage` counts — flipped bars

```r
p_stage_counts <- ggplot(clinical, aes(x = Pathologic_stage)) +
  geom_bar(fill = "#0072B2") +
  coord_flip() +
  labs(title = "Patients by pathologic stage", x = "Pathologic stage", y = "Number of patients") +
  theme_minimal()

p_stage_counts
```

**What to look for.** Common vs uncommon stages; check whether missing or
non-standard stage labels appear as their own categories.

---

## 5. Facets, themes, and colour-blind design

### Q20. Facet Age histogram by `Gender`

```r
p_age_gender <- ggplot(clinical, aes(x = Age)) +
  geom_histogram(binwidth = 5, boundary = 0, fill = "#0072B2", colour = "white", na.rm = TRUE) +
  facet_wrap(~ Gender) +
  labs(title = "Age distribution by gender", x = "Age (years)", y = "Number of patients") +
  theme_minimal()

p_age_gender
```

**What to look for.** Compare shape and sample size across Gender panels.
Facets reduce overplotting but do not make groups comparable if scales differ.

### Q21. Facet by `Race`, fill by `Vital_Status`

```r
p_stage_race_status <- ggplot(clinical, aes(x = Pathologic_stage, fill = Vital_Status)) +
  geom_bar() +
  facet_wrap(~ Race, scales = "free_x") +
  labs(
    title = "Pathologic stage and vital status by race",
    x = "Pathologic stage",
    y = "Number of patients",
    fill = "Vital status"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p_stage_race_status
```

**What to look for.** Within-Race patterns; remember that `scales = "free_x"`
can change the visual width of categories, and small facets may be noisy.

### Q22. `theme_minimal()` and rotated crowded labels

```r
p_stage_theme <- ggplot(clinical, aes(x = Pathologic_stage, fill = Vital_Status)) +
  geom_bar(position = "dodge") +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    legend.position = "top",
    plot.title = element_text(face = "bold")
  ) +
  labs(title = "Pathologic stage by vital status", x = "Pathologic stage", y = "Number of patients", fill = "Vital status")

p_stage_theme
```

**What to look for.** Labels should not overlap; the hierarchy is clear; the
theme supports the data rather than competing with it.

### Q23. Okabe–Ito colour-blind-friendly palette

```r
okabe_ito <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442",
  "#0072B2", "#D55E00", "#CC79A7", "#000000"
)

vital_levels   <- levels(clinical$Vital_Status)
vital_palette  <- setNames(rep(okabe_ito, length.out = length(vital_levels)),
                           vital_levels)

p_colour_blind <- ggplot(clinical, aes(x = Race, fill = Vital_Status)) +
  geom_bar() +
  scale_fill_manual(values = vital_palette, drop = FALSE) +
  labs(title = "Vital status by race", x = "Race", y = "Number of patients", fill = "Vital status") +
  theme_minimal()

p_colour_blind
```

**What to look for.** Legend names match the data levels exactly; categories
remain distinguishable without relying on red/green perception alone.

### Q24. Publication-ready plot (`p_pub`)

```r
p_pub <- ggplot(clinical, aes(x = Age_Group, y = Age, fill = Vital_Status)) +
  geom_boxplot(outlier.alpha = 0.35, na.rm = TRUE) +
  scale_fill_manual(values = vital_palette, drop = FALSE) +
  labs(
    title    = "Age distribution across age groups",
    subtitle = "Stratified by vital status",
    x        = "Age group",
    y        = "Age (years)",
    fill     = "Vital status",
    caption  = "Source: data/clinical_data.csv"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(colour = "grey30"),
    legend.position = "top",
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

p_pub
```

**What to look for.** A publication-ready figure has an explicit message,
readable typography, an honest scale, and a palette that remains interpretable
in grayscale or for readers with colour-vision differences.

---

## 6. Combining & annotating

### Q25. Combine related plots with patchwork

```r
p_combo <- (p_age_hist + p_age_density) /
           (p_scatter   + p_lm) +
  patchwork::plot_annotation(
    title    = "Clinical data overview",
    subtitle = "Distributions and the Age–Cigarettes_per_day relationship"
  )

p_combo
```

**What to look for.** The combined figure tells a coherent story: univariate
distributions first, then the two-variable relationship with its fitted trend.

### Q26 (transcript's Q26). Save the multi-panel figure

```r
ggsave(
  filename = "figures/ggplot2_multi_panel.png",
  plot     = p_combo,
  width    = 11, height = 8, units = "in", dpi = 300
)
```

**What to look for.** Check the exported PNG at final viewing size; a figure
that looks fine interactively may need larger dimensions or text for a report.

### Q27 (transcript's Q26 follow-on). Wilcoxon annotation on a ggpubr boxplot

```r
p_wilcox_visual <- ggpubr::ggboxplot(
  clinical,
  x         = "Vital_Status",
  y         = "Age",
  color     = "Vital_Status",
  palette   = unname(vital_palette[levels(clinical$Vital_Status)]),
  add       = "jitter",
  add.params = list(alpha = 0.35, width = 0.15)
) +
  ggpubr::stat_compare_means(method = "wilcox.test", label = "p.format") +
  labs(title = "Age by vital status with Wilcoxon annotation", x = "Vital status", y = "Age (years)") +
  theme_minimal()

p_wilcox_visual
```

**What to look for.** The annotation is a **visual aid only** — it reports a
test result for the displayed groups but does not measure effect size, prove
causality, or replace inspection of distributions and sample sizes.

---

## Common mistakes (transcript cheat list)

1. Confusing counts and percentages — state which denominator you are using.
2. Using a histogram for a categorical variable — `geom_bar()` vs `geom_histogram()`.
3. Choosing an arbitrary binwidth — try a defensible binwidth and explain it.
4. Overplotting every observation — use transparency, jitter, faceting, or summaries.
5. Treating a smooth as proof — `geom_smooth(method = "lm")` describes a fitted model only.
6. Ignoring missingness — `drop_na()` is fine for complete-pair analysis, but do not silently reinterpret `NA` as `0`.
7. Letting factor order happen by accident — use `factor()` levels or `reorder()` when order carries meaning.
8. Using colour without a legend or accessible contrast — labels, named palette, colour-blind-friendly choices.
9. Comparing facets with inconsistent scales without saying so.
10. Saving only what is displayed — pass the intended object explicitly to `ggsave()` and specify `width`, `height`, `units`, and `dpi`.

---

## Quiz answer key (Q27–Q47)

| # | Answer | Topic |
|---|--------|-------|
| Q27 | **B** Aesthetic mapping | grammar of graphics |
| Q28 | **B** `geom_histogram()` | univariate continuous |
| Q29 | **B** proportion within each bar | `position = "fill"` |
| Q30 | **B** `geom_bar()` counts rows, `geom_col()` plots a y value | geoms |
| Q31 | **C** Median | boxplot |
| Q32 | **B** CI for the fitted mean | `geom_smooth(method = "lm")` band |
| Q33 | **A** `facet_wrap()` | small multiples |
| Q34 | **A** Designed for common colour-vision deficiency | Okabe–Ito |
| Q35 | **A** Swaps the x and y axes | `coord_flip()` |
| Q36 | **False** | density y-axis |
| Q37 | **False** | `stat_compare_means()` is a visual aid |
| Q38 | **False** | correlation only measures linear association |
| Q39 | **True** | binwidth affects apparent shape |
| Q40 | **False** | missing is not zero |
| Q41 | **True** | `ggsave()` accepts patchwork objects |
| Q42 | When distribution *shape* matters | violin vs box |
| Q43 | To reduce overplotting | jitter + alpha |
| Q44 | `geom_bar(position = "dodge")` | side-by-side bars |
| Q45 | `geom_point` + `colour = Gender` + `labs()` | coloured scatter |
| Q46 | `facet_wrap(~ Pathologic_stage, ncol = 4)` | histogram facets |
| Q47 | Slope differences do not establish an interaction | descriptive vs formal |

---

## Known issues resolved

The task brief listed six classes of problem to fix. Because the source
transcript is a *ggplot2* tutorial (not the survival/Cox session implied by the
brief), the six named errors (`clin` vs `clinical`, `ggforest` with `strata`,
`recode` misuse, `select(HR)` before `rename`, `cox.zph` via `$table`,
`ggcoxzph` list via `wrap_plots`, `t_test`/`cohens_d` on a non-numeric
`vital_status`) **are not present in `clipboard.txt`**. They appear only in the
sibling files (`clipboard(1).txt`, `clipboard(2).txt`,
`/mnt/user-data/outputs/Tutorial_4_PanCancer.{R,md}`). The issues that were
present in `clipboard.txt` and that I cleaned up while writing this summary:

1. **Duplicate "Q2" heading.** The transcript has two consecutive `### **Q2.** …`
   headings — one for "10-year histogram bins" and one for "smoothed density
   curve". I renumbered them **Q2 → Q3 (smoothed density)** so the numbering is
   sequential and matches the existing PNG outputs in `/mnt/user-data/outputs/`.
2. **Truncated `ggboxplot()` call.** The transcript's Q26 left `palette =`
   missing a value (just `palette =`) and ended with no trailing comma. I
   supplied `palette = unname(vital_palette[levels(clinical$Vital_Status)])`,
   which is what the surrounding "Color-blind palette" section defines, and
   restored the missing comma before `add = "jitter"`.
3. **Empty body of `mutate()` snippet.** In the setup block, the
   `mutate(... = factor(...), ...)` call had blank lines inside it. I rewrote
   it as a single tidy block so it is paste-ready.
4. **Stray closing markers.** The transcript has several `</details>` and
   `**Output:**` markers with no preceding question. I kept them in the quiz
   answer key (Q27–Q47) where they belong and dropped the empty ones.

No patient-level data is reproduced; the summary contains only plot code,
test code, and small named factor lookups (e.g. `levels(clinical$Vital_Status)`).
