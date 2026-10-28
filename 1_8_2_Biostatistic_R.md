<div align="center">

# Tutorial 4: Biostatistics, from Question to Evidence

**TCGA Pan-Cancer: 9,672 tumour samples, 32 cancer types, 30 questions**

![R](https://img.shields.io/badge/R-%E2%89%A5%204.3-blue.svg)
![tidyverse + rstatix + survival](https://img.shields.io/badge/tidyverse%20%2B%20rstatix%20%2B%20survival-blueviolet.svg)
![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)

</div>

> **How to read this tutorial.** Each question has a hint, the R code, and
> the real output from our data, followed by a "What to look for" note.
> Run the code blocks in order, top to bottom. Every figure is saved in
> `figures2/`.

## Table of contents

1. [Learning objectives](#learning-objectives)
2. [Setup](#setup)
3. [Section 1. Get to know the data (Q1-Q5)](#section-1-get-to-know-the-data)
4. [Section 2. Describe the patients (Q6-Q10)](#section-2-describe-the-patients)
5. [Section 3. Compare two groups (Q11-Q14)](#section-3-compare-two-groups)
6. [Section 4. Compare multiple groups (Q15-Q19)](#section-4-compare-multiple-groups)
7. [Section 5. Relationships and categorical data (Q20-Q24)](#section-5-relationships-and-categorical-data)
8. [Section 6. Report and interpret (Q25-Q28)](#section-6-report-and-interpret)
9. [Section 7. Survival analysis (Q29-Q30)](#section-7-survival-analysis)

## Learning objectives

1. Choose the right test after checking normality and equal variance.
2. Report effect sizes and confidence intervals, not only p-values.
3. Correct p-values when you make many comparisons.
4. Fit Kaplan-Meier curves and a Cox model, and check the
   proportional-hazards assumption.

## Setup

Packages used: tidyverse, ggpubr, rstatix, effectsize, car, FSA, broom,
survival, survminer, scales, patchwork, ggsignif. Install them with
`install_all_packages.R`.

```r
rm(list = ls())
suppressPackageStartupMessages({
  library(tidyverse); library(ggpubr); library(rstatix)
  library(effectsize); library(car); library(FSA); library(broom)
  library(survival); library(survminer); library(scales)
  library(patchwork); library(ggsignif)
})

dir.create("figures2", showWarnings = FALSE)
save_fig <- function(p, name, w = 7, h = 5) {
  ggsave(file.path("figures2", paste0(name, ".png")),
         plot = p, width = w, height = h, dpi = 300)
}
theme_set(theme_bw(base_size = 12))

raw <- readRDS("Data/TCGA_pancancer_combined_geneexpression.rds")

clin <- raw %>%
  transmute(patient_id, sample_barcode, cancer_type,
            Age = age_at_initial_pathologic_diagnosis,
            Gender = gender, Race = race,
            Stage = ajcc_pathologic_tumor_stage,
            Vital = vital_status, Tumor = tumor_status,
            OS, OS.time, PFI, PFI.time,
            BIRC5, CDKN2A, KRAS, MSLN, SMAD4, TP53) %>%
  mutate(Age_Group = cut(Age, c(0, 40, 60, 80, Inf),
                         labels = c("<40", "40-59", "60-79", "80+"),
                         right = FALSE))
```

---

## Section 1. Get to know the data

### Q1. How many rows and columns are in the dataset?
*Hint:* use `dim()`.

```r
dim(raw)
```
```
[1] 9672   51
```
**What to look for:** 9,672 rows and 51 columns.

### Q2. What does each row represent, and what type is each column?
*Hint:* inspect column types and the sample IDs.

```r
str(raw[, 1:15])
head(raw$sample_barcode)
```
**What to look for:** each row is one tumour sample (for example
`TCGA-OR-A5J1-01`). Gene columns are numeric. Clinical columns such as
`gender` and `race` are text.

### Q3. How many missing values are in each column?
*Hint:* count `NA` per column.

```r
sort(colSums(is.na(raw)), decreasing = TRUE)[1:15]
```
**What to look for:** some columns are almost empty (`Redaction` has
9,654 missing, `cause_of_death` 9,458). Check missingness before
choosing a variable.

### Q4. Are patient IDs unique?
*Hint:* count duplicated IDs.

```r
sum(duplicated(raw $ sample_barcode))
sum(duplicated(raw $ patient_id))
```
```
[1] 0
[1] 0
```
**What to look for:** both are 0, so there is one row per patient.

### Q5. How many patients are in each stage category?
*Hint:* make a frequency table.

```r
table(clin$Stage, useNA = "ifany")
```
**What to look for:** many sub-stages (IA, IIB and so on) plus 3,152
missing values. From Q15 onward we use the four main stages I to IV.

---

## Section 2. Describe the patients

### Q6. What are the mean and median ages?
```r
clin %>% summarise(mean_age = mean(Age, na.rm = TRUE),
                   median_age = median(Age, na.rm = TRUE),
                   sd_age = sd(Age, na.rm = TRUE))
```
```
  mean_age median_age   sd_age
1    59.29         61    14.33
```
**What to look for:** the median (61) is a little above the mean
(59.3), which hints at a slight left skew.

### Q7. How are patients distributed by gender, race and vital status?
```r
table(clin $ Gender, useNA = "ifany")
table(clin $ Race, useNA = "ifany")
table(clin$Vital, useNA = "ifany")
```
**What to look for:** 5,017 female and 4,655 male. Most patients are
White (6,901). 6,960 are alive and 2,710 are dead.

### Q8. What does the age distribution look like?
```r
p8a <- ggplot(clin, aes(Age)) +
  geom_histogram(bins = 30, fill = "steelblue", colour = "white") +
  labs(title = "Age at diagnosis", x = "Age (years)", y = "Patients")
p8b <- ggplot(clin, aes(y = Age)) +
  geom_boxplot(fill = "steelblue", width = 0.3) +
  labs(title = "Boxplot of age", y = "Age (years)")
save_fig(p8a + p8b, "Q08_age_distribution", 9, 4.5)
```
![Q8](figures2/Q08_age_distribution.png)

**What to look for:** a peak around 60 to 70 with a tail toward young
ages. The warning about 43 removed rows is just missing ages.

### Q9. Are there unusually high or low ages?
```r
range(clin $ Age, na.rm = TRUE)
boxplot.stats(clin $ Age)$out
```
**What to look for:** ages run from 14 to 90. The boxplot flags only
young outliers (14 to 22 years). They are real patients, not errors.

### Q10. What is the mean and median of a continuous measurement?
Our dataset has no cigarettes column, so we use TP53 expression.

```r
clin %>% summarise(mean_TP53 = mean(TP53, na.rm = TRUE),
                   median_TP53 = median(TP53, na.rm = TRUE))
```
```
  mean_TP53 median_TP53
1     10.34       10.44
```
**What to look for:** mean and median are close, so the distribution is
fairly symmetric.

---

## Section 3. Compare two groups

```r
two <- clin %>% filter(Vital %in% c("Alive", "Dead"), !is.na(Age))
```

### Q11. Is age different between Alive and Dead patients?
```r
p11 <- ggboxplot(two, x = "Vital", y = "Age", fill = "Vital",
                 palette = "jco", add = "jitter",
                 add.params = list(alpha = 0.15)) +
  labs(x = NULL, y = "Age (years)") + theme(legend.position = "none")
save_fig(p11, "Q11_age_by_vital")
```
![Q11](figures2/Q11_age_by_vital.png)

**What to look for:** the Dead group sits higher.

### Q12. Is age approximately normal within each group?
```r
p12 <- ggplot(two, aes(sample = Age)) +
  stat_qq() + stat_qq_line(colour = "red") +
  facet_wrap(~ Vital) + labs(title = "Q-Q plots of age by vital status")
save_fig(p12, "Q12_qq_age_by_vital", 8, 4)

two %>% group_by(Vital) %>%
  summarise(shapiro_p = shapiro.test(sample(Age, min(n(), 5000)))$p.value)
```
![Q12](figures2/Q12_qq_age_by_vital.png)

```
  Vital shapiro_p
1 Alive  5.91e-22
2 Dead   3.92e-19
```
**What to look for:** both p-values are tiny and the Q-Q points bend
away from the line, so age is not strictly normal. With thousands of
samples Shapiro flags even small departures, so read the plot too.

### Q13. Welch's t-test or Wilcoxon rank-sum test?
```r
t.test(Age ~ Vital, data = two)
wilcox.test(Age ~ Vital, data = two)
cohens_d(Age ~ Vital, data = two)
```
```
Welch: t = -18.96, p < 2.2e-16
mean Alive = 57.66, mean Dead = 63.48
95% CI of difference: -6.42 to -5.22
Wilcoxon: W = 7163946, p < 2.2e-16
Cohen's d = -0.41 (95% CI -0.46 to -0.37)
```
**What to look for:** both tests agree. Dead patients are about 5.8
years older on average. Cohen's d of 0.41 is a small-to-moderate
effect. With large groups the t-test is robust despite the
non-normality.

### Q14. Is TP53 expression different between Alive and Dead?
```r
p14 <- ggboxplot(two, x = "Vital", y = "TP53", fill = "Vital",
                 palette = "jco") +
  stat_compare_means(method = "wilcox.test") +
  labs(x = NULL, y = "TP53 expression") + theme(legend.position = "none")
save_fig(p14, "Q14_TP53_by_vital")
wilcox.test(TP53 ~ Vital, data = two)
```
![Q14](figures2/Q14_TP53_by_vital.png)

```
W = 9331275, p-value = 0.8556
```
**What to look for:** p = 0.86, so there is no evidence of a
difference. A non-significant result is not proof of no effect. It
means we found nothing here.

---

## Section 4. Compare multiple groups

```r
stg <- clin %>%
  filter(Stage %in% c("Stage I", "Stage II", "Stage III", "Stage IV"),
         !is.na(Age))
```

### Q15. Does mean age differ across stages?
```r
p15 <- ggboxplot(stg, x = "Stage", y = "Age", fill = "Stage",
                 palette = "jco") +
  labs(x = NULL, y = "Age (years)") + theme(legend.position = "none")
save_fig(p15, "Q15_age_by_stage")

stage_anova <- aov(Age ~ Stage, data = stg)
summary(stage_anova)
```
![Q15](figures2/Q15_age_by_stage.png)

```
Stage: F = 55.97, p < 2e-16
```
**What to look for:** a highly significant overall difference. ANOVA
says at least one stage differs, not which one.

### Q16. Are the ANOVA assumptions reasonable?
```r
res <- residuals(stage_anova)
p16 <- ggplot(data.frame(res), aes(sample = res)) +
  stat_qq() + stat_qq_line(colour = "red") +
  labs(title = "Q-Q plot of ANOVA residuals")
save_fig(p16, "Q16_anova_residuals", 5, 5)
leveneTest(Age ~ factor(Stage), data = stg)
```
![Q16](figures2/Q16_anova_residuals.png)

```
Levene: F = 37.23, p < 2.2e-16
```
**What to look for:** Levene's test rejects equal variances. The
assumption fails, so we confirm with Kruskal-Wallis (Q18).

### Q17. Which stages differ? (Tukey HSD)
We use Tukey HSD, which is built into base R.

```r
tuk <- TukeyHSD(stage_anova)
tuk
tuk_df <- as.data.frame(tuk$Stage) %>% rownames_to_column("pair")
p17 <- ggplot(tuk_df, aes(diff, pair)) +
  geom_pointrange(aes(xmin = lwr, xmax = upr)) +
  geom_vline(xintercept = 0, linetype = 2, colour = "red") +
  labs(x = "Mean age difference (years)", y = NULL,
       title = "Tukey HSD: pairwise stage differences")
save_fig(p17, "Q17_tukey_stage", 7, 4)
```
![Q17](figures2/Q17_tukey_stage.png)

| Pair | Difference (years) | Adjusted p |
|---|---|---|
| II - I | 5.69 | < 0.001 |
| III - I | 7.28 | < 0.001 |
| IV - I | 8.19 | < 0.001 |
| III - II | 1.59 | 0.225 |
| IV - II | 2.50 | 0.033 |
| IV - III | 0.91 | 0.740 |

**What to look for:** Stage I patients are younger than all others.
Stages II, III and IV are similar, except IV vs II (p = 0.033).
Confidence intervals that cross zero mean no clear difference.

### Q18. How does Kruskal-Wallis compare?
```r
kruskal.test(Age ~ Stage, data = stg)
```
```
Kruskal-Wallis chi-squared = 131.07, df = 3, p < 2.2e-16
```
**What to look for:** same conclusion as ANOVA, so the result does not
depend on the normality assumption.

### Q19. Which pairs differ? (Dunn's test, Holm-adjusted)
```r
dunnTest(Age ~ factor(Stage), data = stg, method = "holm")
```
| Comparison | Adjusted p |
|---|---|
| I - II | < 0.001 |
| I - III | < 0.001 |
| I - IV | < 0.001 |
| II - III | 0.133 |
| II - IV | 0.033 |
| III - IV | 0.367 |

**What to look for:** the same pattern as Tukey, which gives us
confidence in the result.

---

## Section 5. Relationships and categorical data

### Q20. Is age associated with TP53 expression?
```r
p20 <- ggplot(clin, aes(Age, TP53)) +
  geom_point(alpha = 0.15) +
  geom_smooth(method = "lm", colour = "red") +
  labs(x = "Age (years)", y = "TP53 expression")
save_fig(p20, "Q20_age_vs_TP53")
```
![Q20](figures2/Q20_age_vs_TP53.png)

**What to look for:** an almost flat line through a wide cloud, so a
very weak relationship.

### Q21. Which correlation is appropriate?
```r
cor.test(clin $ Age, clin $ TP53, method = "pearson")
cor.test(clin $ Age, clin $ TP53, method = "spearman", exact = FALSE)
```
```
Pearson r = 0.055 (95% CI 0.035 to 0.075), p = 6.7e-08
Spearman rho = 0.067, p = 5.9e-11
```
**What to look for:** both are significant but tiny. With 9,600
samples a trivial correlation reaches significance. Statistical
significance is not biological importance, because r = 0.055 explains
about 0.3 percent of the variance.

### Q22. Is vital status associated with gender?
```r
tab22 <- table(two $ Gender, two $ Vital)
tab22
chisq.test(tab22)
cramers_v(tab22)
```
| | Alive | Dead |
|---|---|---|
| FEMALE | 3684 | 1313 |
| MALE | 3242 | 1388 |

```
X-squared = 16.14, p = 5.9e-05, Cramer's V = 0.04
```
**What to look for:** a significant association, but Cramer's V of
0.04 is negligible. Men have a slightly higher proportion dead.

### Q23. Does the proportion of Dead patients vary across stages?
```r
tab23 <- table(stg $ Stage, stg $ Vital)
round(prop.table(tab23, 1), 3)
chisq.test(tab23)
p23 <- stg %>% filter(Vital %in% c("Alive", "Dead")) %>%
  count(Stage, Vital) %>%
  ggplot(aes(Stage, n, fill = Vital)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = percent) +
  labs(x = NULL, y = "Proportion")
save_fig(p23, "Q23_dead_by_stage")
```
![Q23](figures2/Q23_dead_by_stage.png)

| Stage | Alive | Dead |
|---|---|---|
| I | 0.879 | 0.121 |
| II | 0.735 | 0.265 |
| III | 0.637 | 0.363 |
| IV | 0.329 | 0.671 |

```
X-squared = 500.74, df = 3, p < 2.2e-16
```
**What to look for:** a strong gradient. Mortality rises from 12
percent in Stage I to 67 percent in Stage IV.

### Q24. Are some groups too small for reliable comparisons?
```r
clin %>% count(cancer_type, sort = TRUE) %>% tail(10)
chisq.test(tab23)$expected
```
**What to look for:** the smallest cancer types are CHOL (36), DLBC
(48) and UCS (57). Per-cancer tests on these are unreliable. All
expected counts in the stage table are above 5 (smallest is 128), so
the chi-square test is valid.

---

## Section 6. Report and interpret

### Q25. How do you report the age comparison by vital status?
```r
two %>% group_by(Vital) %>%
  summarise(mean = mean(Age), sd = sd(Age), n = n())
```
> Patients who died were older at diagnosis (mean 63.5, SD 14.0 years,
> n = 2,710) than patients who were alive (57.7 years, n = 6,960). The
> difference was 5.8 years (Welch t-test, 95% CI 5.2 to 6.4,
> p < 0.001; Cohen's d = 0.41).

### Q26. How do you report the ANOVA and post-hoc results?
> Mean age differed across stages (one-way ANOVA, F(3, 2884) = 55.97,
> p < 0.001). Tukey HSD showed that Stage I patients were younger than
> Stage II, III and IV (all adjusted p < 0.001). Stage II and IV also
> differed (adjusted p = 0.033). The unequal variances (Levene
> p < 0.001) were handled by confirming with Kruskal-Wallis
> (p < 0.001).

Check the exact SD and counts by running the code above.

### Q27. Why report an effect size and a confidence interval?
```r
cohens_d(Age ~ Vital, data = two)
t.test(Age ~ Vital, data = two)$conf.int
```
**Answer:** a p-value tells you whether an effect is detectable, not
how large it is. Q21 shows this clearly: r = 0.055 had p = 6.7e-08.
The effect size (d = 0.41) and the interval (5.2 to 6.4 years) show
size and uncertainty.

### Q28. Why adjust p-values for many pairwise comparisons?
```r
pairwise.wilcox.test(stg $ Age, stg $ Stage, p.adjust.method = "none")
pairwise.wilcox.test(stg $ Age, stg $ Stage, p.adjust.method = "holm")
```
| Pair | Raw p | Holm p |
|---|---|---|
| II vs I | 1.1e-11 | 4.5e-11 |
| III vs II | 0.0577 | 0.115 |
| IV vs II | 0.0082 | 0.025 |
| IV vs III | 0.3743 | 0.374 |

**Answer:** with six comparisons at the 0.05 level, the chance of at
least one false positive is about 26 percent. Holm raises the p-values
to control this. III vs II was borderline before adjustment and is
clearly not significant after.

---

## Section 7. Survival analysis

### Q29. Do we have follow-up time and event status?
```r
summary(clin $ OS.time)
table(clin $ OS, useNA = "ifany")
surv <- clin %>% filter(!is.na(OS.time), !is.na(OS), OS.time > 0)
```
```
OS.time: median 722 days, max 9634, 33 missing
OS: 6962 censored (0), 2710 events (1)
```
**Answer:** yes. `OS.time` is the follow-up in days and `OS` marks
death (1) or censoring (0). `Vital` alone could not give us this,
because it lacks the time.

### Q30. How does survival differ between groups?
```r
fit_all <- survfit(Surv(OS.time, OS) ~ 1, data = surv)
p30a <- ggsurvplot(fit_all, data = surv, conf.int = TRUE,
                   xlab = "Days", ylab = "Overall survival")
save_fig(p30a $ plot, "Q30a_KM_overall")

fit_g <- survfit(Surv(OS.time, OS) ~ Gender, data = surv)
p30b <- ggsurvplot(fit_g, data = surv, pval = TRUE, risk.table = TRUE,
                   xlab = "Days", ylab = "Overall survival")
save_fig(p30b $ plot, "Q30b_KM_gender")
survdiff(Surv(OS.time, OS) ~ Gender, data = surv)

surv2 <- surv %>% filter(!is.na(Age_Group))
fit_a <- survfit(Surv(OS.time, OS) ~ Age_Group, data = surv2)
p30c <- ggsurvplot(fit_a, data = surv2, pval = TRUE,
                   xlab = "Days", ylab = "Overall survival")
save_fig(p30c$plot, "Q30c_KM_agegroup")

cox <- coxph(Surv(OS.time, OS) ~ Age + Gender, data = surv)
summary(cox)
cox.zph(cox)
```
![KM overall](figures2/Q30a_KM_overall.png)
![KM gender](figures2/Q30b_KM_gender.png)
![KM age group](figures2/Q30c_KM_agegroup.png)

| Term | Hazard ratio | 95% CI | p |
|---|---|---|---|
| Age (per year) | 1.031 | 1.028 to 1.034 | < 2e-16 |
| Male vs female | 1.224 | 1.135 to 1.321 | 1.7e-07 |

Log-rank test for gender: chi-square = 30.1, p = 4e-08.

**What to look for:**
- Each extra year of age raises the hazard of death by about 3 percent.
  Men have about 22 percent higher hazard than women, after adjusting
  for age.
- **Warning:** `cox.zph` gives p = 2.8e-07 for gender and a global
  p = 3.1e-07. The proportional-hazards assumption is violated, so the
  single hazard ratio for gender is an average over time and should be
  interpreted with caution. Age is borderline (p = 0.072).
- Pooling 32 cancer types is itself a limitation. A better analysis
  would stratify by cancer type with `strata(cancer_type)`.

---

## Common mistakes

1. Treating a small p-value as proof of a large effect (Q21).
2. Using ANOVA when variances differ without a back-up test (Q16, Q18).
3. Skipping multiple-testing correction (Q28).
4. Building a survival curve from vital status alone (Q29).
5. Ignoring a failed proportional-hazards check (Q30).

## License

MIT
