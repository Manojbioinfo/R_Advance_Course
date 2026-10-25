<div align="center" style="width:60%;margin:0 auto">

# Tutorial 4: Biostatistics, from Question to Evidence

**TCGA Pan-Cancer clinical data set — 12,591 patients, 33 cancer types, 25 questions**

[![R version](https://img.shields.io/badge/R-%E2%89%A5%204.3-blue.svg)]()
[![Made with: tidyverse + rstatix + survival](https://img.shields.io/badge/tidyverse-rstatix-survival-blueviolet.svg)]()
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)]()

</div>

> **How to read this tutorial.** Each section contains a short clinical
> question, a one-paragraph hint that points at the right statistical tool,
> the R code that produces a publication-ready figure and table, and a
> "What to look for" note that highlights the key reading of the output.
> Code blocks are designed to be runnable in order, top to bottom, on a
> single machine that has the file `data/TCGA_pancancer_clinical.rds`.

## Table of contents

- [Learning objectives](#learning-objectives)
- [Before you start](#before-you-start)
- [Setup](#setup)
- [Q1. How many patients per cancer type?](#q1-how-many-patients-per-cancer-type)
- [Q2. What does the age distribution look like?](#q2-what-does-the-age-distribution-look-like)
- [Q3. How does age differ between men and women?](#q3-how-does-age-differ-between-men-and-women)
- [Q4. How many patients per age decade?](#q4-how-many-patients-per-age-decade)
- [Q5. What proportion of patients falls in each age decade?](#q5-what-proportion-of-patients-falls-in-each-age-decade)
- [Q6. Does the age distribution differ by vital status?](#q6-does-the-age-distribution-differ-by-vital-status)
- [Q7. Is age approximately normally distributed?](#q7-is-age-approximately-normally-distributed)
- [Q8. Do dead and alive patients differ in mean age?](#q8-do-dead-and-alive-patients-differ-in-mean-age)
- [Q9. Do dead and alive patients differ in age (rank-based)?](#q9-do-dead-and-alive-patients-differ-in-age-rank-based)
- [Q10. How variable is age within each vital-status group?](#q10-how-variable-is-age-within-each-vital-status-group)
- [Q11. Do men and women differ in mean age?](#q11-do-men-and-women-differ-in-mean-age)
- [Q12. Does age at diagnosis vary across cancer types?](#q12-does-age-at-diagnosis-vary-across-cancer-types)
- [Q13. Which pairs of cancers differ in age after multiple-testing correction?](#q13-which-pairs-of-cancers-differ-in-age-after-multiple-testing-correction)
- [Q14. Is age correlated with overall survival time?](#q14-is-age-correlated-with-overall-survival-time)
- [Q15. Is vital status associated with race?](#q15-is-vital-status-associated-with-race)
- [Q16. Is tumor status associated with vital status?](#q16-is-tumor-status-associated-with-vital-status)
- [Q17. Where does the gender gap in age reach statistical significance?](#q17-where-does-the-gender-gap-in-age-reach-statistical-significance)
- [Q18. How many patients and events for each survival endpoint?](#q18-how-many-patients-and-events-for-each-survival-endpoint)
- [Q19. What is the overall Kaplan-Meier survival curve?](#q19-what-is-the-overall-kaplan-meier-survival-curve)
- [Q20. Does overall survival differ between men and women?](#q20-does-overall-survival-differ-between-men-and-women)
- [Q21. Does overall survival differ across age groups?](#q21-does-overall-survival-differ-across-age-groups)
- [Q22. Does overall survival differ across cancer types?](#q22-does-overall-survival-differ-across-cancer-types)
- [Q23. What is the adjusted hazard of age and gender on survival?](#q23-what-is-the-adjusted-hazard-of-age-and-gender-on-survival)
- [Q24. Does the proportional-hazards assumption hold?](#q24-does-the-proportional-hazards-assumption-hold)
- [Q25. Is the age effect on survival consistent across cancer types?](#q25-is-the-age-effect-on-survival-consistent-across-cancer-types)

## Learning objectives

By the end of this tutorial you will be able to:

1. Translate a clinical question into the appropriate descriptive,
   inferential or time-to-event procedure.
2. Choose parametric vs non-parametric tests after checking their
   assumptions (normality, equal variance, expected counts).
3. Quantify uncertainty with confidence intervals and effect sizes
   (Cohen's *d*, rank-biserial *r*, ε², Cramer's *V*) alongside
   p-values.
4. Fit and interpret Kaplan-Meier curves and Cox proportional-hazards
   models, and check the proportional-hazards (PH) assumption with
   scaled Schoenfeld residuals.
5. Adjust for multiple testing (Holm for FWER, BH for FDR) and read a
   forest plot.

## Before you start

Place the file `data/TCGA_pancancer_clinical.rds` next to the script.

It contains the 12,591 patients × 16 columns the tutorial expects:

`patient_id`, `cancer_type`, `age_at_initial_pathologic_diagnosis`,
`gender`, `race`, `vital_status`, `tumor_status`, `OS`, `OS.time`,
`DSS`, `DSS.time`, `DFI`, `DFI.time`, `PFI`, `PFI.time`.

The script creates `figures/` and `results/` automatically.

## Setup

Install the packages once.

```r
install.packages(c(
  "tidyverse", "ggpubr", "rstatix", "effectsize", "car", "FSA",
  "broom", "survival", "survminer", "scales", "patchwork",
  "ggsignif", "forcats", "tools"
))
```

Load everything and define the helper functions used throughout the
tutorial. All questions reuse the same `clin` data frame, the same
`theme_pub()` theme and the same `save_fig()` / `write_tbl()` helpers,
so you only need to run this block once per session.

### Setup: clean the workspace and load all packages used in the analysis

```r
# Clear the workspace and load every package used in this analysis up front,
# so the script starts from a clean state, runs reproducibly, and any missing
# package is caught immediately instead of halfway through the pipeline.
# suppressPackageStartupMessages() only hides the loading messages.


rm(list = ls())

suppressPackageStartupMessages({
  library(tidyverse)    # ggplot2, dplyr, tidyr, readr, purrr, forcats, stringr
  library(ggpubr)       # ggboxplot, stat_compare_means
  library(rstatix)      # shapiro_test, levene_test, t_test,
                        #   anova_test, kruskal_test, wilcox_test,
                        #   chisq_test, cohens_d, kruskal_effsize
  library(effectsize)   # cohens_d, cramers_v, rank_biserial
  library(car)          # Anova, leveneTest (robust back-up)
  library(FSA)          # dunnTest (post-hoc for Kruskal-Wallis)
  library(broom)        # tidy() for model coefficients
  library(survival)     # Surv, survfit, coxph, cox.zph
  library(survminer)    # ggsurvplot, ggcoxzph
  library(scales)       # label_number(), percent_format()
  library(patchwork)    # multi-panel composition
  library(ggsignif)     # geom_signif for significance brackets
  library(forcats)      # fct_reorder, lump_n, fct_collapse
  library(tools)        # toTitleCase
})
```

```r
dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
```


```r
# Resolve name clashes once, in favour of the packages we actually mean
if ("conflicted" %in% rownames(installed.packages())) {
  conflicted::conflicts_prefer(
    rstatix::cohens_d,
    rstatix::t_test,
    dplyr::filter,
    dplyr::select,
    dplyr::recode
  )
}
```


```r
theme_pub <- function(base_size = 12) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major   = element_line(colour = "grey92", linewidth = 0.3),
      strip.background   = element_rect(fill = "grey95", colour = NA),
      strip.text         = element_text(face = "bold"),
      plot.title         = element_text(face = "bold"),
      plot.subtitle      = element_text(colour = "grey25"),
      legend.position    = "bottom",
      legend.key         = element_blank()
    )
}

```

```r
save_fig <- function(plot, name, width = 7, height = 5, dpi = 300) {
  dir.create("figures", showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(
    filename = file.path("figures", paste0(name, ".png")),
    plot     = plot, width = width, height = height, dpi = dpi
  )
  invisible(plot)
}
```

```r
write_tbl <- function(x, name) {
  dir.create("results", showWarnings = FALSE, recursive = TRUE)
  readr::write_csv(
    as.data.frame(x),
    file.path("results", paste0(name, ".csv"))
  )
  invisible(x)
}

```


```r
clean_label <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "Unknown"
  tools::toTitleCase(tolower(gsub("[^A-Za-z ]", " ", x)))
}

```


```r
# Load and shape the data. Build factor levels ONCE from the RAW
# vital_status column; never re-apply clean_label() on an already-factored
# column (that was the original bug).
raw_path <- "data/TCGA_pancancer_clinical.rds"
if (!file.exists(raw_path)) {
  stop(
    "Expected file not found: ", raw_path,
    ". Place the TCGA Pan-Cancer clinical RDS in the data/ folder ",
    "or update `raw_path`."
  )
}
```


```r
clin <- readRDS(raw_path) |>
  transmute(
    patient_id   = patient_id,
    cancer_type  = as.character(cancer_type),
    age          = as.numeric(age_at_initial_pathologic_diagnosis),
    gender       = as.character(gender),
    race         = as.character(race),
    vital_status = case_when(
      tolower(trimws(vital_status)) %in% c("alive", "living")   ~ "Alive",
      tolower(trimws(vital_status)) %in% c("dead",  "deceased") ~ "Dead",
      TRUE                                                       ~ NA_character_
    ),
    tumor_status = case_when(
      tolower(trimws(tumor_status)) == "with tumor"  ~ "With Tumor",
      tolower(trimws(tumor_status)) == "tumor free"  ~ "Tumor Free",
      TRUE                                            ~ NA_character_
    ),
    OS  = as.numeric(OS),  OS.time  = as.numeric(OS.time),
    DSS = as.numeric(DSS), DSS.time = as.numeric(DSS.time),
    DFI = as.numeric(DFI), DFI.time = as.numeric(DFI.time),
    PFI = as.numeric(PFI), PFI.time = as.numeric(PFI.time)
  ) |>
  mutate(
    cancer_type  = factor(cancer_type),
    gender       = factor(clean_label(gender)),
    race         = factor(clean_label(race)),
    vital_status = factor(vital_status, levels = c("Alive", "Dead")),
    tumor_status = factor(tumor_status, levels = c("With Tumor", "Tumor Free")),
    age_group    = cut(
      age,
      breaks = c(0, 30, 40, 50, 60, 70, 80, 120),
      labels = c("<30", "30-39", "40-49", "50-59", "60-69", "70-79", "80+"),
      right  = FALSE
    )
  )
```

```r

# Sanity check: vital_status must contain real values, not all NA
if (all(is.na(clin$vital_status)) || sum(!is.na(clin$vital_status)) == 0) {
  stop(
    "After cleaning, vital_status has zero non-NA values. ",
    "Inspect the raw column values (e.g. unique(readRDS(raw_path)$vital_status)) ",
    "and update the case_when() mapping above."
  )
}

str(clin)
```

### Q1. How many patients per cancer type?

> **Hint:** one `dplyr` pipeline gives a tidy table; a horizontal bar chart keeps 33 long labels readable.

```r
cancer_counts <- clin |>
  count(cancer_type, sort = TRUE)

write_tbl(cancer_counts, "Q1_cancer_counts")

p_q1 <- cancer_counts |>
  mutate(cancer_type = forcats::fct_reorder(cancer_type, n)) |>
  ggplot(aes(x = cancer_type, y = n, fill = cancer_type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_y_continuous(labels = scales::label_number()) +
  labs(
    title = "Patient counts by cancer type (TCGA Pan-Cancer, n = 12,591)",
    x = NULL, y = "Number of patients"
  ) +
  theme_pub()

save_fig(p_q1, "Fig01_cancer_counts", width = 7, height = 7)
```

**What to look for:** a long tail of small cohorts; the bar order already
gives a quick read of which cancer dominates the dataset.

*Fix applied:* none — clean.


> **Note:** **Bar heights are cohort counts, not population incidence** — TCGA was not built to be epidemiologically representative, so a tall bar means a well-sampled cancer, not necessarily the most common one. Pitfall: ranking cancers by frequency as if it were cancer registry data.

### Q2. What does the age distribution look like?

> **Hint:** a histogram with a sensible bin width shows the shape of the distribution and helps spot outliers.

```r
p_q2 <- clin |>
  filter(!is.na(age)) |>
  ggplot(aes(x = age)) +
  geom_histogram(binwidth = 5, colour = "white", fill = "#2C7FB8") +
  labs(
    title = "Age at initial pathologic diagnosis",
    x = "Age (years)", y = "Number of patients"
  ) +
  theme_pub()

save_fig(p_q2, "Fig02_age_hist", width = 7, height = 5)
```

**What to look for:** the central tendency (~60 y), the right skew, and any
extreme ages that may be data-entry errors.

*Fix applied:* none — clean.


> **Note:** **Bin width is a modelling choice** — 5-year bins expose a right tail, but 1-year bins add noise and 10-year bins hide it. Always pair the histogram with a density plot or numeric summary. Pitfall: declaring a bimodal or unimodal shape from a single binwidth.

### Q3. How does age differ between men and women?

> **Hint:** a numeric summary goes in a table; a density plot shows the shape by gender.

```r
age_summary <- clin |>
  filter(!is.na(age)) |>
  summarise(
    n      = dplyr::n(),
    mean   = mean(age),
    sd     = sd(age),
    median = median(age),
    q1     = quantile(age, 0.25),
    q3     = quantile(age, 0.75),
    min    = min(age),
    max    = max(age)
  )

write_tbl(age_summary, "Q3_age_summary")

p_q3 <- clin |>
  filter(!is.na(age), !is.na(gender)) |>
  ggplot(aes(x = age, fill = gender)) +
  geom_density(alpha = 0.5, colour = NA) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Age distribution by gender",
    x = "Age (years)", y = "Density", fill = "Gender"
  ) +
  theme_pub()

save_fig(p_q3, "Fig03_age_density_gender", width = 7, height = 5)
```

**What to look for:** central tendency (median ≈ 60), spread (IQR ≈ 50–69),
and any density peaks that suggest different age structures by gender.

*Fix applied:* none — clean.


> **Note:** **Densities are normalised within group** — peak height is shape, not count, so a tall green peak does not mean more women. Pitfall: comparing densities visually as if they were raw counts.

### Q4. How many patients per age decade?

> **Hint:** `cut()` returns an ordered factor; use that to keep the bars in a meaningful order and to drop empty buckets safely.

```r
age_group_counts <- clin |>
  filter(!is.na(age_group)) |>
  count(age_group, name = "n")

write_tbl(age_group_counts, "Q4_age_group_counts")

p_q4 <- age_group_counts |>
  ggplot(aes(x = age_group, y = n)) +
  geom_col(fill = "#41AE76") +
  geom_text(aes(label = n), vjust = -0.3, size = 3) +
  labs(
    title = "Patients per age decade",
    x = "Age group (years)", y = "Number of patients"
  ) +
  theme_pub()

save_fig(p_q4, "Fig04_age_group_counts", width = 7, height = 5)
```

**What to look for:** the modal age decade and any thin tails (e.g. <30 or
80+) that may warrant caution in subgroup analyses.

*Fix applied:* none — clean.


> **Note:** **`cut()` boundaries decide the story** — overlapping or off-by-one breaks will silently drop patients into `NA`. Always tabulate the cut before plotting. Pitfall: trusting the default `right = TRUE` rule on edges that include the maximum value.

### Q5. What proportion of patients falls in each age decade?

> **Hint:** dividing by the row total converts counts to within-cohort proportions; `geom_col + percent_format` finishes the chart.

```r
age_group_pct <- age_group_counts |>
  mutate(pct = n / sum(n))

write_tbl(age_group_pct, "Q5_age_group_percent")

p_q5 <- age_group_pct |>
  ggplot(aes(x = age_group, y = pct)) +
  geom_col(fill = "#41AE76") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Proportion of patients per age decade",
    x = "Age group (years)", y = "Percent of patients"
  ) +
  theme_pub()

save_fig(p_q5, "Fig05_age_group_percent", width = 7, height = 5)
```

**What to look for:** the modal age decade and the cumulative share of
patients above 60 years — relevant for treatment-decision thresholds.

*Fix applied:* none — clean.


> **Note:** **Percentages are within-cohort shares** — they tell you nothing about absolute cohort size. A rare cohort with the same proportions as a common one is still rare. Pitfall: comparing percentages across cohorts of very different n.

### Q6. Does the age distribution differ by vital status?

> **Hint:** two overlapping filled densities compare two distributions; pair with a strip or box plot in later questions to inspect raw points.

```r
p_q6 <- clin |>
  filter(!is.na(age), !is.na(vital_status)) |>
  ggplot(aes(x = age, colour = vital_status, fill = vital_status)) +
  geom_density(alpha = 0.35, linewidth = 1) +
  scale_colour_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Age distribution by vital status",
    x = "Age (years)", y = "Density",
    colour = "Vital status", fill = "Vital status"
  ) +
  theme_pub()

save_fig(p_q6, "Fig06_age_density_vital", width = 7, height = 5)
```

**What to look for:** a visible shift in the mass toward older ages in the
Dead group; this motivates the formal two-group tests in Q8 and Q9.

*Fix applied:* none — clean.


> **Note:** **The `Dead` density is built from far fewer patients** — its curve is much noisier and more sensitive to bandwidth. Read it alongside a strip/box plot, not in isolation. Pitfall: declaring a visible shift as meaningful when one group has tiny n.

### Q7. Is age approximately normally distributed?

> **Hint:** with n = 12,591 even tiny deviations from a normal reference line are "significant"; always read the test together with the histogram.

```r
set.seed(42)
shapiro_age <- clin |>
  filter(!is.na(age)) |>
  slice_sample(n = 5000) |>        # shapiro_test() is limited to 5,000 values
  shapiro_test(age)

write_tbl(shapiro_age, "Q7_shapiro_age")

p_q7 <- clin |>
  filter(!is.na(age)) |>
  ggplot(aes(x = age)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "grey85", colour = "white") +
  geom_density(linewidth = 1, colour = "#2C7FB8") +
  stat_function(
    fun   = dnorm,
    args  = list(mean = mean(clin$age, na.rm = TRUE),
                 sd   = sd(clin$age, na.rm = TRUE)),
    colour = "#E41A1C", linewidth = 1, linetype = "dashed"
  ) +
  labs(
    title    = "Is age approximately normal?",
    subtitle = paste0(
      "Shapiro-Wilk (5,000-sample): W = ", round(shapiro_age$statistic, 4),
      ", p ", ifelse(shapiro_age$p < 0.001, "< 0.001",
                     paste0("= ", round(shapiro_age$p, 3)))
    ),
    x = "Age (years)", y = "Density"
  ) +
  theme_pub()

save_fig(p_q7, "Fig07_age_normality", width = 7, height = 5)
```

**What to look for:** Shapiro-Wilk's *p*-value will be tiny because the
sample is huge, but the dashed normal curve shows the actual deviation
from Gaussianity (left skew, sharp upper cut-off). Use this as a reason to
favour non-parametric tests later.

*Fix applied:* none — clean.


> **Note:** **Shapiro-Wilk is overpowered at n = 12,591** — every tiny deviation from normality returns p < 0.001. The histogram and QQ-plot carry the interpretation; the test only confirms that the data are not exactly Gaussian. Pitfall: treating "non-normal" as a reason to abandon parametric tests when the CLT already protects them.

### Q8. Do dead and alive patients differ in mean age?

> **Hint:** when normality is doubtful and the groups have very different sizes, Welch's t-test (`var.equal = FALSE`) is the safer default. `droplevels()` guarantees a clean two-level factor for `cohens_d()`.

```r
age_vital_df <- clin |>
  filter(!is.na(age), !is.na(vital_status)) |>
  mutate(vital_status = droplevels(vital_status))

ttest_age_vital <- age_vital_df |>
  t_test(age ~ vital_status, var.equal = FALSE)

cohens_d_age_vital <- age_vital_df |>
  cohens_d(age ~ vital_status, var.equal = FALSE)

write_tbl(ttest_age_vital,    "Q8_ttest_age_vital")
write_tbl(cohens_d_age_vital, "Q8_cohens_d_age_vital")

p_q8 <- ggboxplot(
  age_vital_df, x = "vital_status", y = "age",
  fill = "vital_status", palette = "Set1",
  add = "jitter", add.params = list(alpha = 0.25, size = 0.4)
) +
  stat_compare_means(method = "t.test", label = "p.format") +
  labs(
    title = "Age by vital status (Welch's t-test)",
    x = "Vital status", y = "Age (years)"
  ) +
  theme_pub() +
  theme(legend.position = "none")

save_fig(p_q8, "Fig08_age_vital_box", width = 6, height = 5)
```

**What to look for:** a *small* Cohen's *d* (<< 0.2) means the mean
difference is statistically significant but practically negligible — a
useful reminder that *p*-value alone can mislead.

*Fix applied:* `t_test(..., var.equal = FALSE)` used instead of the
non-existent `rstatix::welch_test()`; effect size via
`rstatix::cohens_d()` (the user-supplied formula `2*W/(n1*n2)-1` is the
rank-biserial for Q9).


> **Note:** **Small Cohen's *d* with a tiny p means the effect is detectable, not important** — with n > 10,000 even a 0.5-year mean difference is "significant". Always report *d* (or a CI on the mean difference) alongside the p-value. Pitfall: equating statistical significance with clinical relevance on very large samples.

### Q9. Do dead and alive patients differ in age (rank-based)?

> **Hint:** the rank-sum (Mann-Whitney U) test needs no normality assumption. Report rank-biserial `r = 2*W/(n1*n2) - 1` alongside the *p*-value.

```r
wilcox_age_vital <- age_vital_df |>
  wilcox_test(age ~ vital_status)

# Rank-biserial correlation from the Wilcoxon statistic:
#   r = 2*W / (n1 * n2) - 1   (W is the wilcox_test() statistic column)
n_alive <- sum(age_vital_df$vital_status == "Alive")
n_dead  <- sum(age_vital_df$vital_status == "Dead")
r_rb    <- 2 * wilcox_age_vital$statistic / (n_alive * n_dead) - 1

write_tbl(wilcox_age_vital, "Q9_wilcox_age_vital")
write_tbl(
  tibble::tibble(
    comparison      = "Alive vs Dead",
    rank_biserial_r = r_rb,
    n_alive         = n_alive,
    n_dead          = n_dead
  ),
  "Q9_rank_biserial_age_vital"
)

p_q9 <- ggplot(age_vital_df, aes(x = vital_status, y = age, fill = vital_status)) +
  geom_violin(alpha = 0.6, colour = NA, trim = FALSE) +
  geom_boxplot(width = 0.15, outlier.size = 0.6) +
  geom_signif(
    comparisons = list(c("Alive", "Dead")),
    test        = "wilcox.test",
    map_signif_level = TRUE, textsize = 3.5
  ) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title    = "Age by vital status (Wilcoxon rank-sum)",
    subtitle = paste0(
      "p ", ifelse(wilcox_age_vital$p < 0.001, "< 0.001",
                   paste0("= ", round(wilcox_age_vital$p, 3))),
      "; rank-biserial r = ", round(r_rb, 3)
    ),
    x = "Vital status", y = "Age (years)"
  ) +
  theme_pub() +
  theme(legend.position = "none")

save_fig(p_q9, "Fig09_age_vital_violin", width = 6, height = 5)
```

**What to look for:** a Wilcoxon *p*-value mirroring the t-test's *p*-
value (both detect the same shift), and a tiny rank-biserial *r*
confirming the effect size is small.

*Fix applied:* none — clean.


> **Note:** **Wilcoxon tests stochastic dominance, not the mean** — the rank-biserial *r* on a -1…1 scale is the natural effect size. Pitfall: calling it a "non-parametric t-test" and ignoring what it actually estimates.

### Q10. How variable is age within each vital-status group?

> **Hint:** a jittered boxplot shows how many observations drive each group and whether a tiny group is driving the result.

```r
p_q10 <- age_vital_df |>
  ggplot(aes(x = vital_status, y = age, fill = vital_status)) +
  geom_boxplot(alpha = 0.7, outlier.size = 0.6) +
  geom_jitter(width = 0.2, alpha = 0.2, size = 0.4) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Age by vital status - jittered boxplot",
    x = "Vital status", y = "Age (years)"
  ) +
  theme_pub() +
  theme(legend.position = "none")

save_fig(p_q10, "Fig10_age_vital_jitter", width = 6, height = 5)
```

**What to look for:** the *Dead* group is much smaller than *Alive*; the
jitter lets you see how many points are stacked at the extremes.

*Fix applied:* none — clean.


> **Note:** **Box widths and whisker lengths reflect the *n* behind each group** — the `Dead` box has fewer observations and therefore wider interquartile coverage of fewer points. Pair the box with a jitter or violin to see the raw counts. Pitfall: comparing IQRs as if both groups had equal precision.

### Q11. Do men and women differ in mean age?

> **Hint:** with two groups and possibly unequal variance, Welch's t-test is the safer default.

```r
age_gender_df <- clin |>
  filter(!is.na(age), !is.na(gender)) |>
  mutate(gender = droplevels(gender))

ttest_age_gender <- age_gender_df |>
  t_test(age ~ gender, var.equal = FALSE)

cohens_d_age_gender <- age_gender_df |>
  cohens_d(age ~ gender, var.equal = FALSE)

write_tbl(ttest_age_gender,    "Q11_ttest_age_gender")
write_tbl(cohens_d_age_gender, "Q11_cohens_d_age_gender")

p_q11 <- ggboxplot(
  age_gender_df, x = "gender", y = "age",
  fill = "gender", palette = "Set2",
  add = "jitter", add.params = list(alpha = 0.25, size = 0.4)
) +
  stat_compare_means(method = "t.test", label = "p.format") +
  labs(
    title = "Age by gender (Welch's t-test)",
    x = "Gender", y = "Age (years)"
  ) +
  theme_pub() +
  theme(legend.position = "none")

save_fig(p_q11, "Fig11_age_gender_box", width = 6, height = 5)
```

**What to look for:** the *p*-value and Cohen's *d* — both should be tiny
for this very large sample, but the *p*-value will be far smaller than the
effect size suggests is practically meaningful.

*Fix applied:* `t_test(..., var.equal = FALSE)` used instead of the
non-existent `rstatix::welch_test()`.


> **Note:** **The gender gap in age at diagnosis is usually < 2 years** — Cohen's *d* ≈ 0.1 means "statistically significant, clinically negligible". Always report *d* (or a CI on the difference in means). Pitfall: treating a small *d* as evidence of a meaningful gap.

### Q12. Does age at diagnosis vary across cancer types?

> **Hint:** check homogeneity of variance with Levene's test first; if it fails, switch to Welch's ANOVA or Kruskal-Wallis. Report ε² as a measure of effect size.

```r
top_cancers <- clin |>
  count(cancer_type, sort = TRUE) |>
  slice_head(n = 6) |>
  pull(cancer_type)

age_by_cancer <- clin |>
  filter(as.character(cancer_type) %in% top_cancers, !is.na(age)) |>
  mutate(cancer_type = droplevels(cancer_type))

levene_cancer  <- age_by_cancer |> levene_test(age ~ cancer_type)
kruskal_cancer <- age_by_cancer |> kruskal_test(age ~ cancer_type)

# epsilon-squared (eta-squared for ranks) for Kruskal-Wallis
# formula: eps^2 = (H - (k + 1)) / (n - k), where k = #groups, H = test stat
k_eff <- length(unique(age_by_cancer$cancer_type))
n_eff <- nrow(age_by_cancer)
eps2_age_cancer <- (kruskal_cancer$statistic - (k_eff + 1)) / (n_eff - k_eff)
eta_age_cancer <- tibble::tibble(
  method  = "Kruskal-Wallis epsilon-squared (manual)",
  effsize = eps2_age_cancer,
  magnitude = ifelse(eps2_age_cancer < 0.01, "negligible",
                     ifelse(eps2_age_cancer < 0.06, "small",
                            ifelse(eps2_age_cancer < 0.14, "medium", "large")))
)

write_tbl(levene_cancer,  "Q12_levene_cancer")
write_tbl(kruskal_cancer, "Q12_kruskal_cancer")
write_tbl(eta_age_cancer, "Q12_eta_cancer")

p_q12 <- ggboxplot(
  age_by_cancer, x = "cancer_type", y = "age",
  fill = "cancer_type", palette = "Set3",
  add = "jitter", add.params = list(alpha = 0.2, size = 0.3)
) +
  stat_compare_means(method = "kruskal.test", label = "p.format") +
  labs(
    title    = "Age at diagnosis by cancer type (Kruskal-Wallis)",
    subtitle = paste0(
      "chi^2 = ", round(kruskal_cancer$statistic, 2),
      ", df = ", kruskal_cancer$df,
      "; eps^2 = ", round(eta_age_cancer$effsize, 3)
    ),
    x = NULL, y = "Age (years)"
  ) +
  theme_pub() +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust = 1))

save_fig(p_q12, "Fig12_age_cancer_boxplot", width = 9, height = 6)
```

**What to look for:** a highly significant Kruskal-Wallis (huge *n*) but a
modest ε² — again, significance ≠ practical importance. Inspect the box
plot for which cancers pull the median upward (e.g. breast, colorectal)
vs. downward (e.g. ovarian, leukaemia in younger patients).

*Fix applied:* the original line `rstatix::kruskal_effsize(age ~ cancer_type)`
is a valid call in modern rstatix, but the column name (`effsize`) is not
guaranteed across versions. Replaced with an explicit
manual ε² calculation
`eps^2 = (H - (k + 1)) / (n - k)` plus a magnitude label — works on any
rstatix / survival release.


> **Note:** **Kruskal-Wallis is the safer default across cancer types** — variances and sample sizes differ across 33 cancers, so the homoscedasticity assumption of one-way ANOVA rarely holds. Report ε² as an effect size. Pitfall: running pairwise tests without a first-pass global test.

### Q13. Which pairs of cancers differ in age after multiple-testing correction?

> **Hint:** after a significant Kruskal-Wallis, Dunn's test controls the family-wise error rate when adjusted with Holm.

```r
dunn_cancer <- FSA::dunnTest(
  age ~ cancer_type, data = age_by_cancer, method = "holm"
)
dunn_cancer_tbl <- as.data.frame(dunn_cancer$res) |>
  tibble::as_tibble() |>
  rename(
    comparison = Comparison,
    Z          = Z,
    p_unadj    = P.unadj,
    p_adj      = P.adj
  )

write_tbl(dunn_cancer_tbl, "Q13_dunn_cancer_holm")

# Visualise Dunn-adjusted p-values as a tile heatmap
dunn_pairs <- tidyr::separate(
  dunn_cancer_tbl, comparison, into = c("group1", "group2"),
  sep = " - ", remove = FALSE
)

p_q13 <- ggplot(dunn_pairs, aes(x = group1, y = group2, fill = p_adj)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = ifelse(p_adj < 0.001, "<0.001",
                               sprintf("%.3f", p_adj))),
            size = 3) +
  scale_fill_gradient2(
    low = "#2166AC", mid = "#F7F7F7", high = "#B2182B",
    midpoint = 0.05, limits = c(0, 1),
    name = "Adj. p (Holm)"
  ) +
  labs(
    title = "Dunn post-hoc (Holm): age across the top 6 cancers",
    x = NULL, y = NULL
  ) +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

save_fig(p_q13, "Fig13_dunn_cancer_heatmap", width = 8, height = 7)
```

**What to look for:** which pairs stay significant after Holm correction
(dark blue tiles), and which "significant" pairs in Q12 disappear once
multiple testing is accounted for.

*Fix applied:* none — clean.


> **Note:** **Holm controls the family-wise error rate (FWER)** — the probability of *any* false positive across the family. It is more conservative than BH. Pitfall: treating the adjusted p-values as if they were independent.

### Q14. Is age correlated with overall survival time?

> **Hint:** a scatterplot + smooth line is the visual; `cor.test()` with `method = "pearson"` and `"spearman"` gives the two summaries. `OS.time` must be > 0 for a meaningful correlation.

```r
age_os <- clin |>
  filter(!is.na(age), !is.na(OS.time), OS.time > 0)

cor_pearson  <- cor.test(age_os$age, age_os$OS.time, method = "pearson")
cor_spearman <- cor.test(age_os$age, age_os$OS.time, method = "spearman")

write_tbl(
  tibble::tibble(
    method   = c("pearson", "spearman"),
    estimate = c(unname(cor_pearson$estimate), unname(cor_spearman$estimate)),
    p_value  = c(cor_pearson$p.value, cor_spearman$p.value),
    n        = nrow(age_os)
  ),
  "Q14_age_os_cor"
)

p_q14 <- ggplot(age_os, aes(x = age, y = OS.time)) +
  geom_point(alpha = 0.25, size = 0.6, colour = "#2C7FB8") +
  geom_smooth(method = "lm", colour = "#E41A1C", se = TRUE, linewidth = 0.8) +
  labs(
    title    = "Age vs OS.time (OS.time > 0)",
    subtitle = paste0(
      "Pearson r = ", round(unname(cor_pearson$estimate), 3),
      " (p ", ifelse(cor_pearson$p.value < 0.001, "< 0.001",
                     paste0("= ", round(cor_pearson$p.value, 3))), "); ",
      "Spearman rho = ", round(unname(cor_spearman$estimate), 3),
      " (p ", ifelse(cor_spearman$p.value < 0.001, "< 0.001",
                     paste0("= ", round(cor_spearman$p.value, 3))), ")"
    ),
    x = "Age (years)", y = "OS.time (days)"
  ) +
  theme_pub()

save_fig(p_q14, "Fig14_age_os_cor", width = 7, height = 5)
```

**What to look for:** Pearson and Spearman estimates should be very close
because the relationship is approximately monotonic; both will be small
in absolute value — age alone is a weak predictor of survival time.

*Fix applied:* none — clean.


> **Note:** **Correlation between age and OS.time is not causation** — both variables are bounded by follow-up and by eligibility, so a positive *r* does not mean older patients live longer in real time. Pitfall: using Pearson/Spearman on OS.time as a substitute for a Cox model.

### Q15. Is vital status associated with race?

> **Hint:** χ² tests independence; when expected counts < 5 use Fisher's exact test. Cramer's *V* is the standard effect size.

```r
race_keep <- c("White", "Black Or African American", "Asian")
race_vital_df <- clin |>
  filter(!is.na(race), !is.na(vital_status)) |>
  mutate(race = forcats::fct_other(race, keep = race_keep,
                                  other_level = "Other"))

race_vital_tab <- race_vital_df |>
  count(race, vital_status, name = "n") |>
  pivot_wider(names_from = vital_status, values_from = n, values_fill = 0)

race_vital_mat <- as.matrix(race_vital_tab[, c("Alive", "Dead"), drop = FALSE])
rownames(race_vital_mat) <- race_vital_tab$race

chisq_race_vital <- suppressWarnings(chisq.test(race_vital_mat))
cramers_v_race   <- effectsize::cramers_v(race_vital_mat)

write_tbl(race_vital_tab, "Q15_race_vital_table")
write_tbl(
  tibble::tibble(
    statistic = unname(chisq_race_vital$statistic),
    df        = unname(chisq_race_vital$parameter),
    p_value   = chisq_race_vital$p.value,
    cramers_v = cramers_v_race$Cramers_v
  ),
  "Q15_chisq_race_vital"
)

p_q15a <- ggplot(race_vital_df, aes(x = race, fill = vital_status)) +
  geom_bar(position = "stack") +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Vital status by race (counts)",
    x = NULL, y = "Number of patients", fill = "Vital status"
  ) +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

p_q15b <- ggplot(race_vital_df, aes(x = race, fill = vital_status)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title    = "Vital status by race (within-race percent)",
    subtitle = paste0(
      "chi^2 = ", round(unname(chisq_race_vital$statistic), 2),
      ", df = ", unname(chisq_race_vital$parameter),
      ", p ", ifelse(chisq_race_vital$p.value < 0.001, "< 0.001",
                     paste0("= ", round(chisq_race_vital$p.value, 3))),
      "; Cramer's V = ", round(cramers_v_race$Cramers_v, 3)
    ),
    x = NULL, y = "Percent of patients", fill = "Vital status"
  ) +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

p_q15 <- p_q15a + p_q15b +
  patchwork::plot_annotation(title = "Q15: Vital status by race")

save_fig(p_q15, "Fig15_race_vital_panels", width = 11, height = 5)
```

**What to look for:** Cramer's *V* close to 0 indicates that, even with a
significant *p*-value, race explains very little of the variance in vital
status. The percent-stacked panel (right) is the more honest read because
it normalises by within-race counts.

*Fix applied:* none — clean.


> **Note:** **χ² scales with sample size** — with n = 12,591 even a tiny association yields p < 0.001. Report Cramer's *V* as the effect size. Pitfall: reporting χ² without checking expected counts when one category is rare.

### Q16. Is tumor status associated with vital status?

> **Hint:** when one cell has expected count < 5 fall back to Fisher's exact test.

```r
tumor_vital_df <- clin |>
  filter(!is.na(tumor_status), !is.na(vital_status))

tumor_vital_tab <- tumor_vital_df |>
  count(tumor_status, vital_status, name = "n") |>
  pivot_wider(names_from = vital_status, values_from = n, values_fill = 0)

tumor_vital_mat <- as.matrix(tumor_vital_tab[, c("Alive", "Dead"), drop = FALSE])
rownames(tumor_vital_mat) <- tumor_vital_tab$tumor_status

# chi-square first; fall back to Fisher if any expected < 5
exp_counts <- suppressWarnings(
  chisq.test(tumor_vital_mat, simulate.p.value = FALSE)$expected
)
if (any(exp_counts < 5)) {
  fisher_tv <- fisher.test(tumor_vital_mat)
  test_used <- "Fisher"
  stat_used <- unname(fisher_tv$statistic)
  p_used    <- fisher_tv$p.value
} else {
  chisq_tv <- chisq.test(tumor_vital_mat)
  test_used <- "Chi-square"
  stat_used <- unname(chisq_tv$statistic)
  p_used    <- chisq_tv$p.value
}
cramers_v_tv <- effectsize::cramers_v(tumor_vital_mat)

write_tbl(tumor_vital_tab, "Q16_tumor_vital_table")
write_tbl(
  tibble::tibble(
    test      = test_used,
    statistic = stat_used,
    p_value   = p_used,
    cramers_v = cramers_v_tv$Cramers_v
  ),
  "Q16_tumor_vital_test"
)

p_q16 <- ggplot(tumor_vital_df, aes(x = tumor_status, fill = vital_status)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title    = "Vital status by tumor status",
    subtitle = paste0(test_used, " p ",
                      ifelse(p_used < 0.001, "< 0.001",
                             paste0("= ", round(p_used, 3))),
                      "; Cramer's V = ", round(cramers_v_tv$Cramers_v, 3)),
    x = "Tumor status", y = "Percent of patients", fill = "Vital status"
  ) +
  theme_pub()

save_fig(p_q16, "Fig16_tumor_vital_percent", width = 7, height = 5)
```

**What to look for:** a much higher Cramer's *V* than in Q15 — having a
tumour at last follow-up is meaningfully associated with being dead at
last follow-up.

*Fix applied:* none — clean.


> **Note:** **Fisher's exact test is exact, not approximate** — it is the right choice for any 2 × 2 (or small) table regardless of expected counts. Pitfall: defaulting to χ² and only switching to Fisher when an expected cell is already < 5.

### Q17. Where does the gender gap in age reach statistical significance?

> **Hint:** loop one Welch t-test per cancer type, adjust *p*-values with both Holm (FWER) and BH (FDR), and report the counts of significant hits per method.

```r
gender_age_by_cancer <- clin |>
  filter(!is.na(age), !is.na(gender), !is.na(cancer_type)) |>
  group_by(cancer_type) |>
  filter(dplyr::n_distinct(gender) == 2L,
         sum(!is.na(age)) >= 30L) |>
  group_modify(~ {
    fit <- tryCatch(
      t_test(age ~ gender, data = .x, var.equal = FALSE),
      error = function(e) NULL
    )
    if (is.null(fit)) {
      tibble::tibble(statistic = NA_real_, p = NA_real_, n = nrow(.x))
    } else {
      tibble::tibble(statistic = fit$statistic, p = fit$p, n = nrow(.x))
    }
  }) |>
  ungroup()

gender_age_by_cancer <- gender_age_by_cancer |>
  mutate(
    p_holm = p.adjust(p, method = "holm"),
    p_BH   = p.adjust(p, method = "BH")
  )

write_tbl(gender_age_by_cancer, "Q17_gender_age_per_cancer_adjusted")

p_q17 <- gender_age_by_cancer |>
  select(cancer_type, p_holm, p_BH) |>
  pivot_longer(cols = c(p_holm, p_BH),
               names_to = "method", values_to = "p_adj") |>
  mutate(method = dplyr::case_match(method,
                                    "p_holm" ~ "Holm (FWER)",
                                    "p_BH"   ~ "BH (FDR)")) |>
  ggplot(aes(x = forcats::fct_reorder(cancer_type, p_adj),
             y = -log10(p_adj), fill = method)) +
  geom_col(position = position_dodge(width = 0.8)) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", colour = "grey40") +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Age difference by gender, per cancer type",
       subtitle = "-log10(adjusted p); dashed line at p = 0.05",
       x = NULL, y = "-log10(adjusted p)", fill = "Method") +
  theme_pub() +
  theme(axis.text.x = element_text(angle = 35, hjust = 1))

save_fig(p_q17, "Fig17_multipletest_gender_age", width = 9, height = 6)
```

**What to look for:** how the bar heights change between Holm (controls
FWER) and BH (controls FDR); BH is more permissive and will typically
flag more cancers as "significant".

*Fix applied:* the per-cancer Welch t-test is `t_test(..., var.equal = FALSE)` (not the non-existent `rstatix::welch_test()`).


> **Note:** **Holm and BH answer different questions** — Holm controls FWER (no false positives), BH controls the false-discovery rate (a small share of false positives is OK). Choose Holm for confirmatory analyses, BH for exploratory screens. Pitfall: picking one and not the other without justification.

### Q18. How many patients and events for each survival endpoint?

> **Hint:** an "at risk / events" table is the canonical first step before any Kaplan-Meier curve. Use the raw *n* and event counts (no imputation).

```r
surv_overview <- tibble::tribble(
  ~endpoint, ~symbol, ~event, ~time,
  "OS",      "OS",    "OS",   "OS.time",
  "DSS",     "DSS",   "DSS",  "DSS.time",
  "DFI",     "DFI",   "DFI",  "DFI.time",
  "PFI",     "PFI",   "PFI",  "PFI.time"
) |>
  rowwise() |>
  mutate(
    n_total     = sum(!is.na(clin[[time]])),
    n_events    = sum(clin[[event]] == 1, na.rm = TRUE),
    median_time = median(clin[[time]][clin[[event]] == 1], na.rm = TRUE)
  ) |>
  ungroup()

write_tbl(surv_overview, "Q18_survival_overview")

p_q18 <- surv_overview |>
  select(endpoint, n_total, n_events) |>
  pivot_longer(cols = c(n_total, n_events),
               names_to = "series", values_to = "n") |>
  mutate(series = dplyr::case_match(series,
                                    "n_total"  ~ "Patients (n)",
                                    "n_events" ~ "Events")) |>
  ggplot(aes(x = endpoint, y = n, fill = series)) +
  geom_col(position = position_dodge(width = 0.8)) +
  geom_text(aes(label = n), position = position_dodge(width = 0.8),
            vjust = -0.3, size = 3) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Survival endpoints: patients at risk and events",
       x = "Endpoint", y = "Count", fill = NULL) +
  theme_pub()

save_fig(p_q18, "Fig18_survival_overview", width = 7, height = 5)
```

**What to look for:** the event rate per endpoint — OS captures all
deaths and will always have the largest event count; DFI is restricted to
patients who were disease-free at some point and therefore has the
smallest.

*Fix applied:* none — clean.


> **Note:** **Each endpoint measures a different event** — OS counts all deaths, DSS only cancer deaths, DFI only disease-free intervals, PFI only progression events. Event rates are not comparable across endpoints. Pitfall: reporting "survival" without naming the endpoint.

### Q19. What is the overall Kaplan-Meier survival curve?

> **Hint:** `survfit()` with `Surv(time, event)` on the whole cohort gives the overall KM curve plus median survival.

```r
fit_overall <- survfit(Surv(OS.time, OS) ~ 1, data = clin)

p_q19 <- ggsurvplot(
  fit_overall, data = clin,
  pval = FALSE, conf.int = TRUE,
  xlab = "Days from diagnosis",
  ylab = "Overall survival probability",
  ggtheme = theme_pub(),
  palette = "#377EB8"
)

save_fig(p_q19$plot, "Fig19_km_overall", width = 7, height = 5)
```

**What to look for:** the median survival tick on the curve, and how
quickly the survival probability drops in the first ~1,000 days.

*Fix applied:* none — clean.


> **Note:** **The KM curve is a step function at observed event times** — flat segments mean no events in that interval, not "no risk". The CI widens past the last observed event. Pitfall: extrapolating the curve past the last event time.

### Q20. Does overall survival differ between men and women?

> **Hint:** use `survfit(Surv(time, event) ~ group)` and add the log-rank *p*-value via the survminer plot.

```r
fit_os_gender <- survfit(Surv(OS.time, OS) ~ gender, data = clin)

survdiff_os_gender <- survdiff(Surv(OS.time, OS) ~ gender, data = clin)
p_logrank_gender <- 1 - pchisq(
  survdiff_os_gender$chisq,
  df = length(survdiff_os_gender$n) - 1
)

p_q20 <- ggsurvplot(
  fit_os_gender, data = clin,
  pval = TRUE, conf.int = TRUE,
  xlab = "Days from diagnosis",
  ylab = "Overall survival probability",
  legend.title = "Gender",
  legend.labs  = levels(clin$gender),
  ggtheme = theme_pub(),
  palette = "Set1"
)

save_fig(p_q20$plot, "Fig20_km_os_gender", width = 7, height = 5)

write_tbl(
  tibble::tibble(
    comparison    = paste(levels(clin$gender), collapse = " vs "),
    log_rank_chi2 = unname(survdiff_os_gender$chisq),
    df            = length(survdiff_os_gender$n) - 1,
    p_value       = p_logrank_gender
  ),
  "Q20_logrank_gender"
)
```

**What to look for:** the log-rank *p*-value (printed automatically by
`ggsurvplot`) and how the two curves separate. Survival in TCGA tends to
be modestly worse for men than women across many cancer types.

*Fix applied:* none — clean.


> **Note:** **The log-rank test assumes non-informative censoring** — patients lost to follow-up are assumed to have the same hazard as those who remain. A small p with similar curves means the difference is real but tiny. Pitfall: interpreting a significant log-rank as a large between-group difference.

### Q21. Does overall survival differ across age groups?

> **Hint:** `age_group` is an ordered factor; survminer keeps the natural order in the legend and in the risk table.

```r
age_group_surv_df <- clin |>
  filter(!is.na(OS.time), !is.na(OS), !is.na(age_group)) |>
  mutate(age_group = droplevels(age_group))

fit_os_age <- survfit(Surv(OS.time, OS) ~ age_group, data = age_group_surv_df)

p_q21 <- ggsurvplot(
  fit_os_age, data = age_group_surv_df,
  pval = TRUE, conf.int = TRUE,
  xlab = "Days from diagnosis",
  ylab = "Overall survival probability",
  legend.title = "Age group",
  legend.labs  = levels(age_group_surv_df$age_group),
  ggtheme = theme_pub(),
  palette = "Set1"
)

save_fig(p_q21$plot, "Fig21_km_os_age_group", width = 8, height = 5)
```

**What to look for:** the ordering of curves across age groups — older
groups should sit lower. A highly significant *p*-value is expected but
the visual spread quantifies the practical size of the effect.

*Fix applied:* none — clean.


> **Note:** **Age-group curves are not guaranteed to satisfy proportional hazards** — the visual ranking can change if the HR between two groups is non-constant in time. Always check `cox.zph()` on a follow-up Cox model. Pitfall: ranking curves when the log-rank is not significant.

### Q22. Does overall survival differ across cancer types?

> **Hint:** keep only the top 6 cancers so the legend and the curves stay readable. Plot each cancer in its own panel.

```r
top6_cancers <- clin |>
  filter(!is.na(OS.time), !is.na(OS)) |>
  count(cancer_type, sort = TRUE) |>
  slice_head(n = 6) |>
  pull(cancer_type)

cancer_surv_df <- clin |>
  filter(!is.na(OS.time), !is.na(OS),
         as.character(cancer_type) %in% top6_cancers) |>
  mutate(cancer_type = droplevels(cancer_type))

fit_os_cancer <- survfit(Surv(OS.time, OS) ~ cancer_type, data = cancer_surv_df)

# Per-cancer KM plots, laid out with patchwork (survminer's
# ggsurvplot_facet() expects a faceting variable and is brittle when
# combined with patchwork; building each plot and arranging is more robust).
fits <- cancer_surv_df |>
  group_split(cancer_type) |>
  purrr::map(function(d) {
    fit <- survfit(Surv(OS.time, OS) ~ 1, data = d)
    ggsurvplot(
      fit, data = d,
      conf.int = TRUE, pval = FALSE,
      xlab = "Days from diagnosis",
      ylab = "Overall survival probability",
      title = as.character(unique(d$cancer_type)),
      ggtheme = theme_pub(),
      palette = "#377EB8"
    )$plot
  })

p_q22 <- patchwork::wrap_plots(fits, nrow = 2, ncol = 3) +
  patchwork::plot_annotation(title = "Overall survival, top 6 cancer types")

save_fig(p_q22, "Fig22_km_os_top6_cancers", width = 11, height = 7)
```

**What to look for:** cancers with steep early drops (e.g. pancreatic,
lung) vs. cancers with long plateaus (e.g. thyroid, prostate).

*Fix applied:* the original `ggsurvplot_facet()` approach is brittle when
combining with `patchwork` — replaced by building each panel as a
`ggsurvplot()$plot` and arranging with `patchwork::wrap_plots()`. This
keeps the figure self-contained and avoids the known issue where
`ggsurvplot_facet()` returns a list incompatible with `+`.


> **Note:** **Cancer-type curves mix different case-mixes, ages and follow-up protocols** — the visual ranking is not adjusted for stage or treatment. Use Cox with cancer as a covariate (or stratified) for a fair comparison. Pitfall: ranking cancers by median survival from a univariate KM.

### Q23. What is the adjusted hazard of age and gender on survival?

> **Hint:** `coxph()` returns a hazard ratio per unit of the covariate; `tidy()` (with `exponentiate = TRUE`) converts it to a publication-ready table.

```r
cox_age_gender <- coxph(Surv(OS.time, OS) ~ age + gender, data = clin)
cox_age_gender_tbl <- broom::tidy(cox_age_gender, exponentiate = TRUE,
                                  conf.int = TRUE)

write_tbl(cox_age_gender_tbl, "Q23_cox_age_gender")

forest_df <- cox_age_gender_tbl |>
  mutate(term = recode(term,
                       "age"       = "Age (per year)",
                       "genderMALE" = "Male vs female"))

p_q23 <- ggplot(forest_df,
                aes(x = estimate, y = forcats::fct_rev(term),
                    xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  geom_pointrange(colour = "#2C7FB8") +
  scale_x_log10() +
  labs(title = "Cox PH: age + gender on overall survival",
       x = "Hazard ratio (log scale, 95% CI)", y = NULL) +
  theme_pub()

save_fig(p_q23, "Fig23_cox_forest_age_gender", width = 7, height = 4)
```

**What to look for:** an HR for age > 1 (each additional year slightly
raises the hazard) and the contrast between the two genders. The CI
width tells you about estimation precision.

*Fix applied:* the original script used `survminer::ggforest()` on a
stratified model; here we keep a tidy-based forest plot built with
`broom::tidy(..., exponentiate = TRUE)` + `ggplot` because it produces a
cleaner, more customisable figure and avoids the `ggforest()` "no
strata" / "data.frame" errors on stratified Cox models.


> **Note:** **HR > 1 means higher hazard, not higher risk in absolute terms** — the proportional-hazards assumption is what links HR to the survival curves. Always report the 95 % CI and the p-value together. Pitfall: calling HR a "relative risk" — they coincide only when the outcome is rare.

### Q24. Does the proportional-hazards assumption hold?

> **Hint:** `cox.zph()` tests the PH assumption per covariate via scaled Schoenfeld residuals; a significant *p*-value means the HR likely changes over follow-up.

```r
zph_age_gender <- cox.zph(cox_age_gender)

# broom has no tidy.cox.zph(); use a single base-R extraction.
# Per-covariate table:
zph_per_cov <- as.data.frame(zph_age_gender$table, stringsAsFactors = FALSE)
zph_age_gender_tbl <- tibble::rownames_to_column(zph_per_cov, "term") |>
  dplyr::rename(statistic = chisq, df = df, p_value = p)

# Global test (sum of per-covariate chi-squared):
zph_global <- tibble::tibble(
  term      = "GLOBAL",
  statistic = zph_age_gender$global_chisq,
  df        = zph_age_gender$global_df,
  p_value   = zph_age_gender$global_p
)

zph_tbl <- dplyr::bind_rows(zph_age_gender_tbl, zph_global)
write_tbl(zph_tbl, "Q24_cox_zph_age_gender")

# Diagnostic plots via ggcoxzph(); save with patchwork because ggcoxzph
# returns a list of ggplots rather than a single object.
zph_plots <- ggcoxzph(zph_age_gender, ggtheme = theme_pub())

p_q24 <- patchwork::wrap_plots(zph_plots, ncol = 2) +
  patchwork::plot_annotation(title = "Scaled Schoenfeld residuals: PH assumption")

save_fig(p_q24, "Fig24_cox_zph_diagnostics", width = 9, height = 5)
```

**What to look for:** rows in `zph_tbl` with `p_value < 0.05` flag
covariates whose HR is unlikely to be constant over time. The diagnostic
plots should show flat, horizontal residual traces; a clearly trending
line indicates a violation.

*Fix applied:*
1. `cox.zph()` has no `tidy()` method in `broom`, so the original script
   built three different per-covariate tables and the LAST one silently
   overwrote the earlier ones; we now build **one** consistent table from
   `zph_age_gender$table`.
2. The global test row is added with `bind_rows()` instead of being
   computed and then discarded.
3. `ggcoxzph()` returns a *list* of plots, which `patchwork::wrap_plots`
   accepts directly — saving the list element with `print()` is also
   valid but produces a single panel only.


> **Note:** **A significant `cox.zph()` *p*-value means the HR changes over time** — do not report a single HR when the effect is time-varying. Fixes include stratifying on the offender, adding a time interaction, or restricting follow-up. Pitfall: ignoring the test because the Cox model still converged.

### Q25. Is the age effect on survival consistent across cancer types?

> **Hint:** fit one Cox model per cancer type and plot the per-cancer HR for age; complement with a single Cox model stratified by cancer type to obtain a pooled age HR adjusted for cancer.

```r
forest_age <- clin |>
  filter(!is.na(OS.time), !is.na(OS), !is.na(age)) |>
  group_by(cancer_type) |>
  group_modify(~ {
    fit <- tryCatch(
      coxph(Surv(OS.time, OS) ~ age, data = .x),
      error = function(e) NULL
    )
    if (is.null(fit) || nrow(.x) < 20) {
      tibble::tibble(
        HR = NA_real_, conf.low = NA_real_, conf.high = NA_real_,
        p_value = NA_real_, n = nrow(.x)
      )
    } else {
      broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE) |>
        filter(term == "age") |>
        transmute(HR = estimate, conf.low, conf.high,
                  p_value = p.value, n = nrow(.x))
    }
  }) |>
  ungroup() |>
  filter(n >= 100) |>
  arrange(HR)

write_tbl(forest_age, "Q25_forest_age_per_cancer")

p_q25a <- ggplot(
  forest_age,
  aes(x = HR, y = forcats::fct_reorder(cancer_type, HR),
      colour = p_value < 0.05)
) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                 height = 0.3, linewidth = 0.7) +
  geom_point(size = 2.5) +
  scale_x_log10(breaks = c(0.9, 1.0, 1.1, 1.2, 1.3)) +
  scale_colour_manual(
    values = c("TRUE" = "#B2182B", "FALSE" = "grey40"),
    labels = c("TRUE" = "p < 0.05", "FALSE" = "p >= 0.05"),
    name   = "Significance"
  ) +
  labs(
    title    = "Hazard ratio of age (per year) by cancer type",
    subtitle = "One Cox model per cancer; cancers with n >= 100",
    x = "Hazard ratio (log scale)", y = NULL
  ) +
  theme_pub()

# Stratified Cox: pooled age effect with cancer-specific baseline hazards
cox_strat <- coxph(
  Surv(OS.time, OS) ~ age + strata(cancer_type),
  data = clin
)
cox_strat_tbl <- broom::tidy(cox_strat, exponentiate = TRUE, conf.int = TRUE)

write_tbl(cox_strat_tbl, "Q25_cox_strat_age")

strat_df <- cox_strat_tbl |>
  mutate(term = recode(term, "age" = "Age (per year)"))

p_q25b <- ggplot(strat_df,
                 aes(x = estimate, y = forcats::fct_rev(term),
                     xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  geom_pointrange(colour = "#2C7FB8") +
  scale_x_log10() +
  labs(title = "Cox PH: age, stratified by cancer type",
       x = "Hazard ratio (log scale, 95% CI)", y = NULL) +
  theme_pub()

p_q25 <- p_q25a + p_q25b +
  patchwork::plot_annotation(title = "Q25: age effect across cancers")

save_fig(p_q25, "Fig25_forest_age_per_cancer_and_stratified",
         width = 11, height = 7)
```

**What to look for:** whether the per-cancer age HRs cluster around the
stratified-Cox pooled estimate (single HR for age adjusted for cancer).
Cancers whose CIs cross 1 are the ones where age does not show a
significant effect within that cohort.

*Fix applied:* the stratified Cox forest plot uses a tidy + ggplot
pipeline rather than `survminer::ggforest()`, because `ggforest()` is
known to error ("data.frame column names should not match any of the
special Coxph variable names") when applied to stratified models. The
tidy-based plot is reproducible and easier to style.


> **Note:** **Stratification lets each cancer have its own baseline hazard** while sharing the age coefficient — the pooled age HR is adjusted for cancer without assuming a common baseline. Pitfall: including cancer_type as a regular covariate when proportional hazards fails across cancers.

---

## End of tutorial

```r
message("Tutorial 4 complete: figures in figures/, tables in results/.")
```

## Common mistakes to avoid

- Reporting a *p*-value without an effect size or CI on a sample of
  > 10,000 patients — almost everything will be "significant".
- Treating highly skewed clinical variables as Gaussian (Q7).
- Forgetting to drop unused factor levels before computing Cramer's *V*
  or Cohen's *d* on filtered data.
- Reporting χ² when a 2 × 2 table has expected counts < 5 (Q16) — switch
  to Fisher's exact.
- Using `ggforest()` on a stratified Cox model — use a tidy-based plot.
- Forgetting that `cox.zph()` returns an object that needs explicit
  extraction (Q24) — `broom::tidy()` does not handle it.

## Practice exercises

1. Repeat Q11 (age by gender) but restrict to one cancer type and report
   the Cohen's *d* with a 95 % bootstrap CI.
2. Replace the χ² test in Q15 with Fisher's exact test and confirm the
   conclusion does not change.
3. Fit a Cox model with `age * cancer_type` interaction and inspect
   whether the age effect is significantly different across cancers.
4. Add a competing-risks analysis for DSS versus OS in Q18-Q19 using
   the `cmprsk` package or `survival::finegray()`.


## 🧠 Quiz

Twenty questions, graded by difficulty. Cover missingness, test selection
(t-test vs Wilcoxon vs Kruskal-Wallis, χ² vs Fisher), normality checks, effect
sizes, multiplicity correction (Holm vs BH), Kaplan-Meier interpretation,
log-rank, Cox proportional hazards, hazard ratios, censoring and
stratification. Click each answer to reveal it.

### Basic (1–7)

**Q1 — Missingness.** You compute the mean age on the whole `clin` table
without filtering out `NA`s. The result is `NA`. What is the cleanest fix
that also reports how many values were missing?

<details><summary>Show answer</summary>

Filter out missing values explicitly with `dplyr::filter(!is.na(age))` and
count the kept rows with `dplyr::n()`. The mean function only returns a
number when every input is non-missing, and silently dropping `NA`s hides
how much data you actually used.

</details>

**Q2 — Normality check.** Your Shapiro-Wilk test on age returns *p* < 1e-6
even though the histogram looks roughly bell-shaped. What does this mean
and what should you do?

<details><summary>Show answer</summary>

With *n* ≈ 12,000 the test is overpowered: every tiny deviation from a
perfect Gaussian is flagged as significant. The test does not say the data
are "badly" non-normal — it says they are not *exactly* normal. Read the
*p*-value together with the histogram and the QQ-plot, and rely on the CLT
for the mean (which is robust to mild non-normality at large *n*).

</details>

**Q3 — Two-group test.** You want to compare age between `Alive` and
`Dead`. The variances look different and the two groups have very
unequal sizes. Which test do you pick?

<details><summary>Show answer</summary>

Welch's t-test, i.e. `t_test(age ~ vital_status, var.equal = FALSE)`. It
does not assume equal variance and is the standard default in R. The
Student version with `var.equal = TRUE` would be wrong here because the
variances differ.

</details>

**Q4 — Effect size for a Wilcoxon.** After a significant Wilcoxon test
between two age groups you only report the *p*-value. What effect size
should you add and how is it computed from the test statistic?

<details><summary>Show answer</summary>

The rank-biserial correlation *r* = 2 * W* / (*n*₁ · *n*₂) − 1, where *W*
is the Wilcoxon statistic returned by `wilcox_test()`. *r* is on a -1…1
scale and is the natural effect-size companion to the Mann-Whitney U test.
Without it the reader has no idea whether the difference is tiny or huge.

</details>

**Q5 — χ² vs Fisher.** You cross-tabulate a rare tumour status (expected
count < 5 in one cell) against vital status. Which test do you use and
why?

<details><summary>Show answer</summary>

Fisher's exact test. χ² relies on a large-sample approximation that fails
when expected counts drop below 5. Fisher's test is exact for any 2 × 2
(or any small) table, so it is the safe default whenever a cell is sparse.
Switching to Fisher only when a cell is already below 5 is the common
pitfall — it is reasonable to use Fisher unconditionally for 2 × 2 tables.

</details>

**Q6 — KM interpretation.** On a Kaplan-Meier curve, a flat segment
between two event times means what?

<details><summary>Show answer</summary>

No events occurred in that interval. It does **not** mean the hazard is
zero, nor that no patient is at risk — only that nobody experienced the
event during that window. The CI band also widens past the last observed
event; do not extrapolate the curve beyond it.

</details>

**Q7 — Censoring.** In TCGA overall survival, a patient whose `OS` is 0
(alive at last follow-up) is called "censored". What does the log-rank
test assume about these censored patients?

<details><summary>Show answer</summary>

Non-informative censoring: censored patients are assumed to have the same
underlying hazard as patients who remain under observation. If the
censoring is driven by the disease (e.g. sicker patients drop out) the
log-rank *p*-value and the KM curve are both biased.

</details>

### Intermediate (8–14)

**Q8 — Three-group test.** You want to compare age across six cancer
types. The variances and sample sizes differ a lot. The shapiro test is
"non-normal" everywhere. Which inferential test is the safe default?

<details><summary>Show answer</summary>

Kruskal-Wallis (rank-based one-way ANOVA), e.g.
`kruskal_test(age ~ cancer_type, data = age_by_cancer)`. It does not
require normality or homoscedasticity. One-way ANOVA assumes both; Welch
ANOVA relaxes variance but still assumes Gaussianity. Always follow a
significant Kruskal-Wallis with a pairwise post-hoc test (Dunn with Holm
adjustment) before claiming specific cancers differ.

</details>

**Q9 — Effect-size magnitude.** A Welch t-test returns *d* = 0.08 with
*p* = 0.002 on *n* = 12,591. How should you describe this result to a
clinical reader?

<details><summary>Show answer</summary>

Statistically significant but practically negligible. Cohen's *d* ≈ 0.08
is well below the conventional 0.2 "small effect" threshold, so the mean
age difference is detectable only because the sample is enormous. Always
report *d* (or a CI on the mean difference) alongside the *p*-value, and
never let "p < 0.05" stand on its own at this sample size.

</details>

**Q10 — Holm vs BH.** After running one Welch t-test per cancer type
for the gender gap in age you have 33 *p*-values. Holm and BH disagree
on how many are significant. Which one is appropriate for a
**confirmatory** analysis and which for an **exploratory** screen?

<details><summary>Show answer</summary>

**Holm** for confirmatory analyses — it controls the family-wise error
rate (FWER), i.e. the probability of *any* false positive. **BH**
(Benjamini-Hochberg) for exploratory screens — it controls the
false-discovery rate (FDR), i.e. the expected *share* of false positives
among declared hits. BH is more liberal and lets you trade a small
fraction of false positives for higher power. Always pick with
justification, not by default.

</details>

**Q11 — Log-rank test.** Two KM curves cross each other at month 30.
Is the log-rank test still appropriate?

<details><summary>Show answer</summary>

Use it with caution. The standard log-rank weights all event times
equally, so it has low power when the hazards cross (the early advantage
of one group is cancelled by the late advantage of the other). If the
curves cross, consider the Fleming-Harrington weighted log-rank test
(`survdiff(..., rho = 1)`) or restrict follow-up to the period where
proportional hazards holds. Always inspect the curves before trusting
the *p*-value.

</details>

**Q12 — Hazard ratio reading.** A Cox model for OS on age returns
HR = 1.02 with 95 % CI (1.015, 1.025). In plain English, what does this
mean, and what is the most common mistake readers make with HRs?

<details><summary>Show answer</summary>

Each additional year of age multiplies the hazard of death by about 1.02,
i.e. a 2 % increase per year, with the true effect between 1.5 % and
2.5 %. The most common mistake is to call HR a "relative risk" — they
are not the same number. HR ≈ RR only when the outcome is rare (short
follow-up, low event rate). Always report the CI alongside the point
estimate; do not cherry-pick HRs.

</details>

**Q13 — Stratified Cox.** You fit `coxph(Surv(OS.time, OS) ~ age + 
strata(cancer_type))` and the model converges. What does `strata()` do
and when do you need it?

<details><summary>Show answer</summary>

`strata(cancer_type)` lets each cancer type have its own baseline hazard
function, so the age coefficient is a single *pooled* HR adjusted for
cancer without assuming a common baseline. You need stratification when
proportional hazards fails for that variable (`cox.zph()` returns a
significant *p*-value), or when the covariate is a nuisance variable you
want to absorb rather than estimate.

</details>

**Q14 — *cox.zph()* interpretation.** The `cox.zph()` test on your Cox
model returns *p* = 0.01 for the `age` covariate. What is the
implication, and what is your next step?

<details><summary>Show answer</summary>

The proportional-hazards assumption fails for `age`: the HR for age
likely changes during follow-up. Do **not** report a single HR — it is a
misleading summary. Fixes include (a) stratifying on `age` (e.g.
`strata(age_group)`), (b) adding a time interaction `tt(age)`, or (c)
restricting follow-up to a window where PH holds. Always run `cox.zph()`
before reporting a Cox model.

</details>

### Advanced (15–20)

**Q15 — Multiplicity strategy.** You run 100 hypothesis tests on the
TCGA cohort. You want to declare at most 5 false positives on average
out of the tests you call significant. Which adjustment and why?

<details><summary>Show answer</summary>

Benjamini-Hochberg (BH) at *q* = 0.05. BH controls the false-discovery
rate (FDR), i.e. the expected *proportion* of false positives among
declared hits. If you call 60 tests significant with BH at *q* = 0.05,
about 5 % (≈ 3) are expected to be false. Holm would control FWER (no
false positives at all) and is much more conservative; with 100 tests
Holm at 0.05 typically yields far fewer hits.

</details>

**Q16 — Case-mix in survival comparisons.** You compare KM curves across
cancer types and notice pancreatic cancer has the worst curve. Why is
this *not* a clean comparison?

<details><summary>Show answer</summary>

Cancer types differ in age at diagnosis, stage distribution, treatment
protocols, follow-up schedules and eligibility criteria. The visual
ranking is therefore a mix of biology *and* case-mix, not adjusted for
any of these. A multivariate Cox model with cancer as a covariate (or
stratified Cox with shared HRs) gives a fair comparison. Never publish
"cancer X has worse survival than cancer Y" based on a univariate KM.

</details>

**Q17 — KM with crossed curves.** Two KM curves cross at month 24 and
the log-rank *p*-value is 0.08. Your collaborator claims "no
difference". What is the more accurate statement?

<details><summary>Show answer</summary>

"There is no detectable difference under the standard log-rank test." A
non-significant log-rank does not prove equality; it fails to reject
equality. With crossed curves the standard log-rank is also underpowered.
The accurate statement is to report the *p*-value, the curves and the
median survival per arm, and to consider a weighted log-rank
(Fleming-Harrington) if the crossing is real.

</details>

**Q18 — Cox model with too many covariates.** You fit
`coxph(Surv(OS.time, OS) ~ age + gender + race + tumor_status + 
stage + smoking + cigarettes_per_day + ...)` and 17 of 25 covariates
have NA, dropping 60 % of patients. What is your first concern?

<details><summary>Show answer</summary>

Complete-case analysis on a Cox model with many covariates is dangerous:
a patient missing any one variable is dropped, so the effective *n*
collapses and the remaining sample is no longer representative. Use
multiple imputation (`mice::mice()` with `method = pmm`) before fitting,
or build the Cox model on the variables with the most complete data and
report the *n* used per coefficient.

</details>

**Q19 — Stratified KM.** You stratify a KM plot by cancer type and the
log-rank within strata is non-significant everywhere, but the pooled
log-rank is highly significant. What does this combination mean?

<details><summary>Show answer</summary>

The difference is *between* cancer types, not *within* them — within any
single cancer the curves are similar, but the cancer types themselves
have very different baseline hazards. The pooled test detects this
between-cancer heterogeneity while the per-stratum tests are
underpowered. This is exactly the situation where a stratified Cox model
(with cancer as the strata variable and other covariates pooled) is
appropriate.

</details>

**Q20 — Reporting checklist.** List the **five** elements that every
clinical survival result in this tutorial should include to be
publication-ready.

<details><summary>Show answer</summary>

1. The **endpoint name** spelled out (OS, DSS, DFI or PFI) and the
   time-to-event variable.
2. The **sample size** *n* and the **event count**, separately for each
   group.
3. The **test name** with adjustment method (Welch, Kruskal-Wallis + Dunn
   with Holm, log-rank, Cox with *cox.zph()* check).
4. An **effect size** with a **95 % confidence interval** (Cohen's *d*,
   Cramer's *V*, rank-biserial *r*, ε², or HR with CI).
5. The **PH assumption check** for any Cox model (`cox.zph()` *p*-values)
   and a note on stratification if it fails.

</details>

### Scoring guide

| Difficulty | Questions | Points each | Total |
|------------|-----------|-------------|-------|
| Basic      | Q1–Q7     | 1           | 7     |
| Intermediate | Q8–Q14  | 2           | 14    |
| Advanced   | Q15–Q20   | 3           | 18    |
| **Total**  |           |             | **39**|

| Score | Reading |
|-------|---------|
| ≥ 32  | Excellent — ready to lead a TCGA-style biostatistics analysis. |
| 24–31 | Strong — review the few topics where you missed points. |
| 16–23 | Solid foundation — re-read the sections behind the missed questions. |
| 8–15  | Working knowledge — redo the relevant Q-sections and rerun the code. |
| ≤ 7   | Start with the Setup and Learning objectives, then work top to bottom. |
