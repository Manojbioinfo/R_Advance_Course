# Tutorial 4: Biostatistics, from Question to Evidence

This tutorial follows one defensible story: **question → describe → check assumptions → choose a test → effect size and multiplicity → survival analysis**. Tables are written to `results/` and figures to `figures/`.

## Table of contents

1. [Learning objectives](#learning-objectives)
2. [Before you start](#before-you-start)
3. [Test-selection cheat sheet](#test-selection-cheat-sheet)
4. [Section 1: Start with a question and describe the data](#section-1-start-with-a-question-and-describe-the-data)
5. [Section 2: Normality, choice, and tests](#section-2-normality-choice-and-tests)
6. [Section 3: Interpret p-values, effects, and multiplicity](#section-3-interpret-p-values-effects-and-multiplicity)
7. [Section 4: Survival analysis (teaching only)](#section-4-survival-analysis-teaching-only)
8. [Common mistakes](#common-mistakes)
9. [Practice exercises](#practice-exercises)
10. [Quiz](#quiz)

## Learning objectives

By the end you will be able to:

- State a question in terms of population, groups, outcome, and estimand.
- Describe numeric and categorical variables correctly.
- Check assumptions and choose between parametric and non-parametric tests.
- Report effect sizes and confidence intervals beside every p-value.
- Correct for multiple testing.
- Run and interpret Kaplan-Meier curves, log-rank tests, and a Cox model.

## Before you start

Run the setup script first, and place `clinical_data.csv` in `data/`.

```r
library(tidyverse); library(ggpubr); library(rstatix); library(effectsize)
library(car); library(FSA); library(broom); library(survival); library(survminer)

clinical <- read_csv("data/clinical_data.csv", show_col_types = FALSE)
dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

clinical <- clinical |>
  mutate(Vital_Status = factor(Vital_Status), Gender = factor(Gender),
         Race = factor(Race), Age_Group = factor(Age_Group),
         Pathologic_stage = factor(Pathologic_stage))

glimpse(clinical)
```

## Test-selection cheat sheet

| Question | Data | Parametric | Non-parametric |
|---|---|---|---|
| Two groups, numeric outcome | numeric ~ 2 groups | Welch t-test | Wilcoxon rank-sum |
| 3+ groups, numeric outcome | numeric ~ 3+ groups | ANOVA | Kruskal-Wallis + Dunn |
| Two numeric variables | numeric, numeric | Pearson | Spearman |
| Two categorical variables | table | Chi-square | Fisher's exact |
| Time to event | time + event | Cox model | Log-rank |

## Section 1: Start with a question and describe the data

### Q1. What is the basic question?

**Hint:** State the population, groups, outcome, and estimand.

```r
# Example question: Is age different between Alive and Dead patients?
desc_age <- clinical |>
  group_by(Vital_Status) |>
  summarise(n = n(), mean_age = mean(Age), sd_age = sd(Age),
            median_age = median(Age), IQR_age = IQR(Age))
desc_age
write_csv(desc_age, "results/descriptive_age_by_vital_status.csv")
```

**What to look for:** Report mean and SD for symmetric data, median and IQR for skewed data.

### Q2. What should be reported for categorical variables?

**Hint:** Counts and percentages.

```r
desc_cat <- clinical |>
  count(Race, Vital_Status) |>
  group_by(Race) |>
  mutate(percent = round(100 * n / sum(n), 1))
desc_cat
write_tsv(desc_cat, "results/descriptive_race_vital_status.tsv")
```

**What to look for:** Percentages within each Race row, with the counts beside them.

### Q3. What is the distribution of age?

**Hint:** Use both a histogram and a QQ plot.

```r
ggplot(clinical, aes(Age)) +
  geom_histogram(binwidth = 5, fill = "#0072B2", colour = "white") +
  theme_minimal()

qq <- ggqqplot(clinical$Age, title = "QQ plot: age")
qq
ggsave("figures/age_qq_plot.png", qq, width = 6, height = 5, dpi = 300)
```

**What to look for:** Points close to the diagonal suggest approximate normality.

## Section 2: Normality, choice, and tests

### Q4. What does Shapiro-Wilk test?

**Hint:** It tests normality, not equality of means.

```r
shapiro <- clinical |> group_by(Vital_Status) |> shapiro_test(Age)
shapiro
write_csv(shapiro, "results/shapiro_age_by_vital_status.csv")
```

**What to look for:** With large samples, tiny departures give small p-values. Combine with the QQ plot.

### Q5. What is a principled choice for two groups?

**Hint:** Welch t-test compares means, Wilcoxon compares rank distributions.

```r
t_welch  <- t.test(Age ~ Vital_Status, data = clinical)
w_wilcox <- wilcox.test(Age ~ Vital_Status, data = clinical, exact = FALSE)
tidy(t_welch)
tidy(w_wilcox)
write_csv(tidy(t_welch),  "results/welch_t_test_age.csv")
write_csv(tidy(w_wilcox), "results/wilcoxon_age.csv")
```

**What to look for:** Report the estimate and 95% CI, not only the p-value.

### Q6. How large is the two-group difference?

**Hint:** Report a standardized mean difference with its uncertainty.

```r
cohen <- effectsize::cohens_d(Age ~ Vital_Status, data = clinical)
cohen
write.csv(as.data.frame(cohen), "results/effect_size_cohens_d.csv", row.names = FALSE)
```

**What to look for:** Rough guide: 0.2 small, 0.5 medium, 0.8 large. Judge relevance by the clinical context.

### Q7. Do ages vary by pathologic stage?

**Hint:** ANOVA targets means, Kruskal-Wallis targets rank distributions.

```r
anova_fit <- aov(Age ~ Pathologic_stage, data = clinical)
kw <- kruskal.test(Age ~ Pathologic_stage, data = clinical)
summary(anova_fit)
kw
write.csv(broom::tidy(anova_fit), "results/anova_age_stage.csv", row.names = FALSE)
write.csv(broom::tidy(kw), "results/kruskal_age_stage.csv", row.names = FALSE)
```

**What to look for:** A significant omnibus test says some difference exists, not which groups differ.

### Q8. Which stage pairs differ after Kruskal-Wallis?

**Hint:** Use Dunn's test with Holm correction.

```r
dunn <- FSA::dunnTest(Age ~ Pathologic_stage, data = clinical, method = "holm")$res
head(dunn)
write_csv(dunn, "results/dunn_age_stage_holm.csv")
```

**What to look for:** Use the adjusted p-value column (`P.adj`), not the raw `P.unadj`.

### Q9. Is smoking related to age?

**Hint:** Pearson for linear relationships, Spearman for monotonic ones.

```r
pearson  <- cor.test(clinical $ Age, clinical $ Cigarettes_per_day, method = "pearson")
spearman <- cor.test(clinical $ Age, clinical $ Cigarettes_per_day, method = "spearman", exact = FALSE)
pearson
spearman
write.csv(broom::tidy(pearson),  "results/correlation_pearson.csv",  row.names = FALSE)
write.csv(broom::tidy(spearman), "results/correlation_spearman.csv", row.names = FALSE)
```

**What to look for:** Correlation is not causation. Check the scatterplot for outliers first.

### Q10. Is vital status associated with race?

**Hint:** Chi-square when expected counts are adequate, otherwise Fisher's exact test.

```r
tab <- table(clinical $ Race, clinical $ Vital_Status)
tab
chi <- suppressWarnings(chisq.test(tab))
chi$expected   # check: are expected counts mostly >= 5?
fisher <- tryCatch(fisher.test(tab, simulate.p.value = TRUE, B = 10000),
                   error = function(e) NULL)
write.csv(broom::tidy(chi), "results/chi_square_race_vital.csv", row.names = FALSE)
if (!is.null(fisher)) write.csv(broom::tidy(fisher), "results/fisher_race_vital.csv", row.names = FALSE)
```

**What to look for:** If many expected counts are below 5, trust Fisher over chi-square.

## Section 3: Interpret p-values, effects, and multiplicity

### Q11. What does p < 0.05 mean?

**Hint:** It is conditional evidence against a null model, not the probability the null is true.

```r
# Keep the effect estimate and confidence interval beside every p-value.
```

**What to look for:** A small p-value does not mean a large or important effect.

### Q12. How can several p-values be corrected?

**Hint:** Holm for a small family of tests, Benjamini-Hochberg (BH) for discovery lists.

```r
pvals <- tibble(
  test = c("t_test", "wilcoxon", "pearson", "spearman"),
  p = c(t_welch $ p.value, w_wilcox $ p.value, pearson $ p.value, spearman $ p.value)
) |>
  mutate(p_holm = p.adjust(p, "holm"), p_bh = p.adjust(p, "BH"))
pvals
write_csv(pvals, "results/multiple_testing_corrections.csv")
```

**What to look for:** Corrected values are always at least as large as raw values.

### Q13. What is a useful reporting sentence?

**Hint:** Combine direction, magnitude, CI, p-value, and context.

```r
report <- broom::tidy(t_welch) |>
  mutate(note = "Report estimate and 95% CI; do not report p-value alone")
report
write_csv(report, "results/reporting_template.csv")
```

**What to look for:** Example: "Dead patients were X years older (95% CI a to b; Welch p = Y)."

## Section 4: Survival analysis (teaching only)

> **Warning.** The stated clinical schema has no time-to-event column. If none is found, the code below creates a clearly labelled **simulated** follow-up time for teaching. It is not a clinical result and must not be used for biological conclusions.

### Q14. Is a time-to-event column available?

**Hint:** Search column names before modelling.

```r
time_candidates <- names(clinical)[grepl("time|days|follow|month|survival",
                                         names(clinical), ignore.case = TRUE)]
time_candidates
```

**What to look for:** An empty result (`character(0)`) means no real follow-up data exists.

### Q15. How do we make a reproducible teaching example when it is absent?

**Hint:** Set a seed, simulate follow-up, and censor Alive patients.

```r
set.seed(20261019)
if (length(time_candidates) == 0) {
  surv_dat <- clinical |>
    mutate(time_days = round(rexp(n(), rate = 1/900) + if_else(Vital_Status == "Dead", 0, 300)),
           event = as.integer(Vital_Status == "Dead"))
  message("SIMULATED follow-up only: no time-to-event column exists.")
} else {
  message("A time-like column exists: ", paste(time_candidates, collapse = ", "),
          ". Build time_days and event from it before continuing.")
}
if (exists("surv_dat")) {
  write_csv(surv_dat |> select(any_of(c("ID", "time_days", "event"))),
            "results/SIMULATED_survival_teaching_data.csv")
}
```

**What to look for:** Every output from here on is labelled SIMULATED.

### Q16. What does a Kaplan-Meier curve estimate?

**Hint:** Survival probability over follow-up time.

```r
km <- survfit(Surv(time_days, event) ~ Age_Group, data = surv_dat)
km_plot <- ggsurvplot(km, data = surv_dat, pval = TRUE, risk.table = TRUE,
                      title = "SIMULATED teaching-only Kaplan-Meier")
km_plot
ggsave("figures/SIMULATED_km_teaching.png", km_plot$plot, width = 7, height = 6, dpi = 300)
```

**What to look for:** Tick marks are censored patients. The risk table shows who remains at each time.

### Q17. What is the log-rank test?

**Hint:** It compares observed and expected events across curves.

```r
logrank <- survdiff(Surv(time_days, event) ~ Age_Group, data = surv_dat)
logrank
write.csv(data.frame(chisq = logrank $ chisq,
                     p = 1 - pchisq(logrank $ chisq, length(logrank$n) - 1)),
          "results/SIMULATED_logrank.csv", row.names = FALSE)
```

**What to look for:** A small p-value means the curves differ somewhere, not at which time.

### Q18. What does a Cox model estimate?

**Hint:** A hazard ratio adjusted for covariates, assuming proportional hazards.

```r
cox <- coxph(Surv(time_days, event) ~ Age_Group + Gender + Race, data = surv_dat)
cox_tidy <- broom::tidy(cox, exponentiate = TRUE, conf.int = TRUE)
cox_tidy
write_csv(cox_tidy, "results/SIMULATED_cox_hazard_ratios.csv")
```

**What to look for:** HR > 1 means higher hazard than the reference group. Check that the CI excludes 1.

### Q19. How can proportional hazards be checked?

**Hint:** Inspect Schoenfeld residual tests.

```r
ph <- cox.zph(cox)
ph
write.csv(as.data.frame(ph$table), "results/SIMULATED_cox_ph_assumption.csv")
```

**What to look for:** Small p-values suggest the proportional-hazards assumption is violated.

## Common mistakes

- Reporting p-values without effect sizes or confidence intervals.
- Treating "not significant" as "no effect".
- Running many tests without correction.
- Using chi-square when expected counts are small.
- Presenting simulated survival output as a real finding.
- Choosing the test after seeing which one gives p < 0.05.

## Practice exercises

1. Repeat Q5 for age by `Gender`, and report the estimate, CI, and effect size.
2. Compare `Cigarettes_per_day` across `Age_Group` with Kruskal-Wallis plus Dunn (Holm).
3. Test whether `Gender` is associated with `Vital_Status`, and justify chi-square vs Fisher.

## Quiz

<details><summary>1. Does a non-significant p-value prove no effect?</summary>

No. It indicates insufficient evidence under the tested model. Examine the estimate and confidence interval.

</details>

<details><summary>2. When prefer Fisher's exact test?</summary>

When expected cell counts are small or the chi-square approximation is unreliable.

</details>

<details><summary>3. What is the major limitation of the survival section?</summary>

Follow-up time is simulated because the supplied schema has no time-to-event column, so conclusions are teaching-only.

</details>

<details><summary>4. Why report effect sizes?</summary>

They communicate magnitude and precision, which p-values alone do not.

</details>
