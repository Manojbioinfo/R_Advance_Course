# Biostatistics Quiz Basic


### Learning objectives

- Match measurement scale, design, estimand and assumptions to a method.
- Summarize categories and continuous data with explicit denominators and missingness.
- Distinguish Welch, rank-based, multi-group, categorical and survival methods.
- Interpret effect sizes, confidence intervals and multiple-testing adjustments.
- Treat observational estimates as associations unless a causal design and assumptions support stronger claims.

### Reproducibility and cautious interpretation

- Input resolution order: in-memory `raw`; `TCGA_RDS_PATH` (default `Data/TCGA_pancancer_clinical.rds`); then `TCGA_CSV_PATH` (default `Data/TCGA_pancancer_clinical.csv`). No automatic imputation, patient deduplication, fabricated variables or fallback clinical measures.
- Repeated samples per patient can violate independence. Identify the analysis unit; do not treat sample rows as independent patients without justification.
- Every result is conditional on observed complete cases for the corresponding variables. Missingness can be informative; report exclusions/denominators.
- No causal conclusions follow from unadjusted tests or regression alone.
- Q29 assumes `OS=1` is death and `OS=0` is censored/alive only after a check against vital status. Confirm the data dictionary and OS.time origin/units. The survival script should not be treated as validated if status coding conflicts or documentation is unavailable.
- The questions remain exactly as supplied; where a named variable is not in the observed schema, the script notes the limitation rather than inventing it.

## Contents

- [Q1. What should I decide before choosing a test?](#q1-what-should-i-decide-before-choosing-a-test)
- [Q2. What are descriptive, predictive, and causal questions?](#q2-what-are-descriptive-predictive-and-causal-questions)
- [Q3. What is nominal data?](#q3-what-is-nominal-data)
- [Q4. What is ordinal data?](#q4-what-is-ordinal-data)
- [Q5. What is quantitative data?](#q5-what-is-quantitative-data)
- [Q6. What is interval versus ratio scale?](#q6-what-is-interval-versus-ratio-scale)
- [Q7. What is the shape of the example dataset?](#q7-what-is-the-shape-of-the-example-dataset)
- [Q8. Why is CA 19-9 a useful teaching example?](#q8-why-is-ca-19-9-a-useful-teaching-example)
- [Q9. How should categorical data be summarized?](#q9-how-should-categorical-data-be-summarized)
- [Q10. How should continuous data be summarized?](#q10-how-should-continuous-data-be-summarized)
- [Q11. What do mean, median, and mode describe?](#q11-what-do-mean-median-and-mode-describe)
- [Q12. What do SD and IQR describe?](#q12-what-do-sd-and-iqr-describe)
- [Q13. How can I inspect missingness?](#q13-how-can-i-inspect-missingness)
- [Q14. Should I fill missing values with the mean?](#q14-should-i-fill-missing-values-with-the-mean)
- [Q15. What should I do with an outlier?](#q15-what-should-i-do-with-an-outlier)
- [Q16. Which graph suits which data?](#q16-which-graph-suits-which-data)
- [Q17. How do I check normality and variance assumptions?](#q17-how-do-i-check-normality-and-variance-assumptions)
- [Q18. How do I compare two independent groups on a continuous outcome?](#q18-how-do-i-compare-two-independent-groups-on-a-continuous-outcome)
- [Q19. How do I compare paired continuous measurements?](#q19-how-do-i-compare-paired-continuous-measurements)
- [Q20. How do I compare three or more independent groups on a continuous outcome?](#q20-how-do-i-compare-three-or-more-independent-groups-on-a-continuous-outcome)
- [Q21. How do I assess correlation and categorical association?](#q21-how-do-i-assess-correlation-and-categorical-association)
- [Q22. How do I compare a clinical measure such as tumour size across stages?](#q22-how-do-i-compare-a-clinical-measure-such-as-tumour-size-across-stages)
- [Q23. What does a p-value mean?](#q23-what-does-a-p-value-mean)
- [Q24. What does a confidence interval add?](#q24-what-does-a-confidence-interval-add)
- [Q25. Why do effect sizes and multiplicity matter?](#q25-why-do-effect-sizes-and-multiplicity-matter)
- [Q26. Which post-hoc test should follow one-way ANOVA?](#q26-which-post-hoc-test-should-follow-one-way-anova)
- [Q27. What is confounding?](#q27-what-is-confounding)
- [Q28. What is overfitting?](#q28-what-is-overfitting)
- [Q29. When can survival analysis be performed?](#q29-when-can-survival-analysis-be-performed)
- [Q30. What belongs in a transparent report?](#q30-what-belongs-in-a-transparent-report)

---

### Q1. What should I decide before choosing a test?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Check whether the unit is patient or sample and whether the proposed question is descriptive, predictive or causal. The supplied cohort is observational.

**Try first.** What is your estimand: a count, difference, association or intervention effect? Write it down before opening the tests.

</details>

<details><summary>Show code example</summary>

```r
# Before testing: define population, comparison, outcome, estimand, analysis unit, and objective.
analysis_question <- list(population="TCGA records; specify the target", comparison="EDIT", outcome="EDIT", estimand="EDIT", unit="patient or sample?", objective="descriptive/predictive/causal")
str(analysis_question)
```

For the complete defensive implementation, see the matching Q01 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q01_analysis_plan.txt`](results/Q01_analysis_plan.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Check whether the unit is patient or sample and whether the proposed question is descriptive, predictive or causal. The supplied cohort is observational.

</details>

### Q2. What are descriptive, predictive, and causal questions?

<details><summary>Hint and active-learning prompt</summary>


**Try first.** Before interpreting: predict one limitation of this cohort and say what extra design would be needed for causal language.

</details>

<details><summary>Show code example</summary>

```r
cat("Rows:", nrow(raw), "Columns:", ncol(raw), "\n"); str(raw); head(raw)
```

For the complete defensive implementation, see the matching Q02 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q02_design_and_data.txt`](results/Q02_design_and_data.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** A dataset description is not a patient outcome. Multiple samples per patient or selection into TCGA can limit interpretation.

</details>

### Q3. What is nominal data?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Nominal categories have no intrinsic order. Keep missing as its own reported count and state the denominator.

**Try first.** Predict which gender category is most frequent, then compare counts and percentages. Why are numeric codes not means?

</details>

<details><summary>Show code example</summary>

```r
tab <- as.data.frame(table(trimws(as.character(raw$gender)), useNA="ifany"))
names(tab) <- c("gender", "n")
tab$percent_of_all_rows <- 100 * tab$n / nrow(raw)
```

For the complete defensive implementation, see the matching Q03 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q03_gender_nominal.csv`](results/Q03_gender_nominal.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Nominal categories have no intrinsic order. Keep missing as its own reported count and state the denominator.

</details>

### Q4. What is ordinal data?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Stage is ordinal only if the coding supports an order; it is not necessarily equally spaced, and cross-cancer staging systems may differ.

**Try first.** List the observed stage labels, order them using clinical documentation, and note if labels may differ across cancers.

</details>

<details><summary>Show code example</summary>

```r
stage <- trimws(as.character(raw$ajcc_pathologic_tumor_stage))
table(stage, useNA="ifany")
# Verify order and meaning in documentation; do not alphabetize as if ordinal.
```

For the complete defensive implementation, see the matching Q04 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q04_stage_levels.csv`](results/Q04_stage_levels.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Stage is ordinal only if the coding supports an order; it is not necessarily equally spaced, and cross-cancer staging systems may differ.

</details>

### Q5. What is quantitative data?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** A numeric representation is not proof of ratio-scale meaning. Gene values may be normalized or transformed.

**Try first.** Pick an age or gene column. Predict its valid range and units before checking the numeric summary.

</details>

<details><summary>Show code example</summary>

```r
# Summarize only numeric age and gene-expression fields; check units/transforms.
summary(raw$age_at_initial_pathologic_diagnosis)
summary(raw$TP53)
```

For the complete defensive implementation, see the matching Q05 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q05_quantitative_summary.csv`](results/Q05_quantitative_summary.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** A numeric representation is not proof of ratio-scale meaning. Gene values may be normalized or transformed.

</details>

### Q6. What is interval versus ratio scale?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Storage class does not define measurement scale. For transformed expression, verify transformation and units before ratio interpretations.

**Try first.** For age and one gene, decide whether zero is meaningful; contrast that with category codes.

</details>

<details><summary>Show code example</summary>

```r
data.frame(variable=names(raw), storage_class=vapply(raw, function(x) paste(class(x),collapse="/"), character(1)), n_missing=vapply(raw, function(x) sum(is.na(x)), numeric(1)))
```

For the complete defensive implementation, see the matching Q06 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q06_type_inventory.csv`](results/Q06_type_inventory.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Storage class does not define measurement scale. For transformed expression, verify transformation and units before ratio interpretations.

</details>

### Q7. What is the shape of the example dataset?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Do not silently drop repeat samples. If records are not independent, patient-level standard errors/tests need a justified strategy.

**Try first.** Predict whether rows equal patients. Compare rows, unique patient IDs and sample barcodes; inspect duplicates.

</details>

<details><summary>Show code example</summary>

```r
dim(raw); names(raw); str(raw)
length(unique(na.omit(raw$patient_id)))
sum(duplicated(na.omit(raw$patient_id)))
```

For the complete defensive implementation, see the matching Q07 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q07_data_shape.csv`](results/Q07_data_shape.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Do not silently drop repeat samples. If records are not independent, patient-level standard errors/tests need a justified strategy.

</details>

### Q8. Why is CA 19-9 a useful teaching example?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** CA 19-9 was not part of the supplied schema. The optional gene summary is not a clinical tumor marker and cannot answer a CA19-9 question.

**Try first.** The question names CA 19-9. Is that column actually present? Choose a provided gene only as a clearly different example.

</details>

<details><summary>Show code example</summary>

```r
# CA 19-9 is not in the supplied schema. Script summarizes the first available supplied gene as a distinct teaching example.
x <- as.numeric(raw$TP53)
summary(x); hist(x, breaks=30) # only if TP53 is numeric
```

For the complete defensive implementation, see the matching Q08 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q08_marker_summary.csv`](results/Q08_marker_summary.csv) (created when the script runs; not included as a precomputed result).

![Q8 figure](figures2/Fig08_gene_marker.png)

Figure file: [`figures2/Fig08_gene_marker.png`](figures2/Fig08_gene_marker.png) (created when the script runs).

**Interpret after running.** CA 19-9 was not part of the supplied schema. The optional gene summary is not a clinical tumor marker and cannot answer a CA19-9 question.

</details>

### Q9. How should categorical data be summarized?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Cohort sampling counts are not cancer incidence or population prevalence.

**Try first.** Predict the largest cancer category. Compare raw counts with within-table percentages and denominators.

</details>

<details><summary>Show code example</summary>

```r
tab <- as.data.frame(table(raw$cancer_type, useNA="ifany")); names(tab) <- c("cancer_type","n")
tab$percent_all_rows <- 100*tab$n/nrow(raw)
```

For the complete defensive implementation, see the matching Q09 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q09_cancer_type_counts.csv`](results/Q09_cancer_type_counts.csv) (created when the script runs; not included as a precomputed result).

![Q9 figure](figures2/Fig09_cancer_counts.png)

Figure file: [`figures2/Fig09_cancer_counts.png`](figures2/Fig09_cancer_counts.png) (created when the script runs).

**Interpret after running.** Cohort sampling counts are not cancer incidence or population prevalence.

</details>

### Q10. How should continuous data be summarized?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Report units and observed n. Mean/SD and median/IQR answer different distribution summaries.

**Try first.** Predict whether mean and median age will differ. Check n and missingness before interpreting either.

</details>

<details><summary>Show code example</summary>

```r
x <- as.numeric(raw$age_at_initial_pathologic_diagnosis)
c(n_observed=sum(is.finite(x)), mean=mean(x,na.rm=TRUE), sd=sd(x,na.rm=TRUE), median=median(x,na.rm=TRUE), IQR=IQR(x,na.rm=TRUE))
```

For the complete defensive implementation, see the matching Q10 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q10_age_summary.csv`](results/Q10_age_summary.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Report units and observed n. Mean/SD and median/IQR answer different distribution summaries.

</details>

### Q11. What do mean, median, and mode describe?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Ties can produce multiple modes; rounding/age-at-diagnosis recording makes the mode sensitive to measurement granularity.

**Try first.** Find the most frequent recorded age(s). Does a sample mode make sense for a nearly continuous measurement?

</details>

<details><summary>Show code example</summary>

```r
x <- as.numeric(raw$age_at_initial_pathologic_diagnosis); x <- x[is.finite(x)]
tab <- table(x); names(tab)[tab==max(tab)] # one or more sample modes
```

For the complete defensive implementation, see the matching Q11 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q11_central_tendency.csv`](results/Q11_central_tendency.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Ties can produce multiple modes; rounding/age-at-diagnosis recording makes the mode sensitive to measurement granularity.

</details>

### Q12. What do SD and IQR describe?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** SD is tied to the mean and tail values; IQR covers the middle half. Compare with group sizes and units.

**Try first.** Compare within-gender SD and IQR. Which measure is less sensitive to extreme ages?

</details>

<details><summary>Show code example</summary>

```r
aggregate(age_at_initial_pathologic_diagnosis ~ gender, raw, function(x) c(n=sum(is.finite(x)), sd=sd(x,na.rm=TRUE), IQR=IQR(x,na.rm=TRUE)))
```

For the complete defensive implementation, see the matching Q12 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q12_age_dispersion_by_gender.csv`](results/Q12_age_dispersion_by_gender.csv) (created when the script runs; not included as a precomputed result).

![Q12 figure](figures2/Fig12_age_by_gender.png)

Figure file: [`figures2/Fig12_age_by_gender.png`](figures2/Fig12_age_by_gender.png) (created when the script runs).

**Interpret after running.** SD is tied to the mean and tail values; IQR covers the middle half. Compare with group sizes and units.

</details>

### Q13. How can I inspect missingness?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Percent missing alone does not identify MCAR/MAR/MNAR. Analysis denominators differ by variable.

**Try first.** Which column is most missing? Does that explain why values are missing?

</details>

<details><summary>Show code example</summary>

```r
miss <- data.frame(variable=names(raw), n_missing=vapply(raw,function(x)sum(is.na(x)),numeric(1)), percent_missing=100*vapply(raw,function(x)mean(is.na(x)),numeric(1)))
miss[order(-miss$percent_missing),]
```

For the complete defensive implementation, see the matching Q13 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q13_missingness.csv`](results/Q13_missingness.csv) (created when the script runs; not included as a precomputed result).

![Q13 figure](figures2/Fig13_missingness.png)

Figure file: [`figures2/Fig13_missingness.png`](figures2/Fig13_missingness.png) (created when the script runs).

**Interpret after running.** Percent missing alone does not identify MCAR/MAR/MNAR. Analysis denominators differ by variable.

</details>

### Q14. Should I fill missing values with the mean?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Single mean imputation generally suppresses variability and understates uncertainty; the script deliberately does not impute.

**Try first.** Predict how mean-imputing age would affect variance and group differences. Do not implement it.

</details>

<details><summary>Show code example</summary>

```r
# No imputation is performed. Quantify observed and missing values first.
colSums(is.na(raw))
# Avoid single mean imputation; consider a justified analysis and sensitivity checks.
```

For the complete defensive implementation, see the matching Q14 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q14_imputation_decision.csv`](results/Q14_imputation_decision.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Single mean imputation generally suppresses variability and understates uncertainty; the script deliberately does not impute.

</details>

### Q15. What should I do with an outlier?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** IQR fences are review flags, not grounds for deletion. Check units/data entry and consider sensitivity analyses.

**Try first.** Review the flagged ages against source records and clinical plausibility. Would you exclude them without evidence?

</details>

<details><summary>Show code example</summary>

```r
x <- raw$age_at_initial_pathologic_diagnosis; q <- quantile(x,c(.25,.75),na.rm=TRUE);
fences <- q + c(-1.5,1.5)*diff(q); fences
# Flags invite source/unit review; never automatically delete.
```

For the complete defensive implementation, see the matching Q15 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q15_age_outlier_flags.csv`](results/Q15_age_outlier_flags.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** IQR fences are review flags, not grounds for deletion. Check units/data entry and consider sensitivity analyses.

</details>

### Q16. Which graph suits which data?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Plots complement methods, not validate the design. Show group sizes/denominators and units.

**Try first.** Choose one plot for a category, one numeric variable and one numeric-by-group comparison. What could each hide?

</details>

<details><summary>Show code example</summary>

```r
# Categorical: bar plot. Numeric: histogram. Numeric by group: boxplot.
# Numeric pairs: scatterplot. Label units and show group denominators.
```

For the complete defensive implementation, see the matching Q16 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q16_graph_guide.txt`](results/Q16_graph_guide.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Plots complement methods, not validate the design. Show group sizes/denominators and units.

</details>

### Q17. How do I check normality and variance assumptions?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Shapiro is sampled at at most 5,000 residuals; Fligner-Killeen checks spread. Visual diagnostics and independence matter too.

**Try first.** Inspect residuals and group spreads. Predict whether a formal Shapiro p-value will be sensitive in a large sample.

</details>

<details><summary>Show code example</summary>

```r
d <- raw[complete.cases(raw[,c("gender","age_at_initial_pathologic_diagnosis")]),]
fit <- lm(age_at_initial_pathologic_diagnosis ~ factor(gender), data=d)
plot(fitted(fit), residuals(fit)); abline(h=0,lty=2)
fligner.test(age_at_initial_pathologic_diagnosis ~ gender, data=d)
```

For the complete defensive implementation, see the matching Q17 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q17_age_diagnostics.csv`](results/Q17_age_diagnostics.csv) (created when the script runs; not included as a precomputed result).

![Q17 figure](figures2/Fig17_age_diagnostics.png)

Figure file: [`figures2/Fig17_age_diagnostics.png`](figures2/Fig17_age_diagnostics.png) (created when the script runs).

**Interpret after running.** Shapiro is sampled at at most 5,000 residuals; Fligner-Killeen checks spread. Visual diagnostics and independence matter too.

</details>

### Q18. How do I compare two independent groups on a continuous outcome?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Script runs only for exactly two groups with adequate data. Wilcoxon is not generally a test of medians unless shapes are similar.

**Try first.** State which two recorded groups you compare, then contrast Welch mean difference with Wilcoxon ranks.

</details>

<details><summary>Show code example</summary>

```r
d <- raw[complete.cases(raw[,c("gender","age_at_initial_pathologic_diagnosis")]),]
t.test(age_at_initial_pathologic_diagnosis ~ factor(gender), data=d) # Welch by default
wilcox.test(age_at_initial_pathologic_diagnosis ~ factor(gender), data=d, exact=FALSE)
```

For the complete defensive implementation, see the matching Q18 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q18_welch_age_gender.csv`](results/Q18_welch_age_gender.csv) (created when the script runs; not included as a precomputed result).

![Q18 figure](figures2/Fig12_age_by_gender.png)

Figure file: [`figures2/Fig12_age_by_gender.png`](figures2/Fig12_age_by_gender.png) (created when the script runs).

**Interpret after running.** Script runs only for exactly two groups with adequate data. Wilcoxon is not generally a test of medians unless shapes are similar.

</details>

### Q19. How do I compare paired continuous measurements?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** No supplied before/after pair is established. Similar membership by cancer type is not pairing.

**Try first.** Can you name two true repeated numeric measures on the same people? If not, why must paired inference stop?

</details>

<details><summary>Show code example</summary>

```r
# No verified paired before/after measurements are supplied. Do not use a paired test
# without measurements linked within the same person/pair.
```

For the complete defensive implementation, see the matching Q19 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q19_paired_data_note.txt`](results/Q19_paired_data_note.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** No supplied before/after pair is established. Similar membership by cancer type is not pairing.

</details>

### Q20. How do I compare three or more independent groups on a continuous outcome?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Welch ANOVA relaxes equal variances; Kruskal–Wallis compares ranks/distributions. Stage may not be comparable across cancers.

**Try first.** Before reading p-values, inspect stage group sizes and distributions. Would a mean or rank estimand suit your question?

</details>

<details><summary>Show code example</summary>

```r
d <- raw[complete.cases(raw[,c("ajcc_pathologic_tumor_stage","age_at_initial_pathologic_diagnosis")]),]
oneway.test(age_at_initial_pathologic_diagnosis ~ factor(ajcc_pathologic_tumor_stage), data=d, var.equal=FALSE)
kruskal.test(age_at_initial_pathologic_tumor_stage ~ factor(ajcc_pathologic_tumor_stage), data=d)
```

For the complete defensive implementation, see the matching Q20 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q20_age_by_stage_tests.csv`](results/Q20_age_by_stage_tests.csv) (created when the script runs; not included as a precomputed result).

![Q20 figure](figures2/Fig20_age_by_stage.png)

Figure file: [`figures2/Fig20_age_by_stage.png`](figures2/Fig20_age_by_stage.png) (created when the script runs).

**Interpret after running.** Welch ANOVA relaxes equal variances; Kruskal–Wallis compares ranks/distributions. Stage may not be comparable across cancers.

</details>

### Q21. How do I assess correlation and categorical association?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Pearson captures linear association; Spearman captures monotone rank association. Chi-square needs adequate expected cell counts.

**Try first.** For age versus a numeric gene, predict direction and nonlinearity. For gender versus vital status, inspect expected counts.

</details>

<details><summary>Show code example</summary>

```r
cor.test(as.numeric(raw$age_at_initial_pathologic_diagnosis), as.numeric(raw$TP53), method="spearman", exact=FALSE)
# Also see the script output for gender x vital_status; inspect sparse expected counts.
```

For the complete defensive implementation, see the matching Q21 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q21_numeric_correlations.csv`](results/Q21_numeric_correlations.csv) (created when the script runs; not included as a precomputed result).

![Q21 figure](figures2/Fig21_age_gene_scatter.png)

Figure file: [`figures2/Fig21_age_gene_scatter.png`](figures2/Fig21_age_gene_scatter.png) (created when the script runs).

**Interpret after running.** Pearson captures linear association; Spearman captures monotone rank association. Chi-square needs adequate expected cell counts.

</details>

### Q22. How do I compare a clinical measure such as tumour size across stages?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** The script reports the unavailable clinical measure transparently. Age by stage is not tumor-size-by-stage.

**Try first.** Is tumor size in the verified input? Identify a suitable field and units if you have documentation; do not replace it with age.

</details>

<details><summary>Show code example</summary>

```r
# The supplied schema has no stated tumor-size measurement. Do not substitute age.
# Verify an actual measure, units, cancer-specific comparability and missingness first.
```

For the complete defensive implementation, see the matching Q22 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q22_unavailable_measure_note.txt`](results/Q22_unavailable_measure_note.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** The script reports the unavailable clinical measure transparently. Age by stage is not tumor-size-by-stage.

</details>

### Q23. What does a p-value mean?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** It is not P(null true), chance the result is random, or a measure of clinical importance.

**Try first.** In your own words, what does p=.01 mean under a null model? What does it not mean?

</details>

<details><summary>Show code example</summary>

```r
# Interpret p conditional on the null model and assumptions; it is not an effect size
# and not the probability that the null is true.
```

For the complete defensive implementation, see the matching Q23 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q23_p_value_note.txt`](results/Q23_p_value_note.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** It is not P(null true), chance the result is random, or a measure of clinical importance.

</details>

### Q24. What does a confidence interval add?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** A confidence interval communicates estimate precision on its original scale; interpret alongside units and meaningful thresholds.

**Try first.** Find the Welch CI in Q18. Would the same estimate be clinically important at every plausible value?

</details>

<details><summary>Show code example</summary>

```r
# For an estimable two-group age comparison, t.test() reports a Welch mean difference CI.
# Report the estimate and interval, not a p-value alone.
```

For the complete defensive implementation, see the matching Q24 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q24_confidence_interval_note.txt`](results/Q24_confidence_interval_note.txt) (created when the script runs; not included as a precomputed result).

**Interpret after running.** A confidence interval communicates estimate precision on its original scale; interpret alongside units and meaningful thresholds.

</details>

### Q25. Why do effect sizes and multiplicity matter?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Holm controls family-wise error; BH controls expected false discovery proportion. The script labels its example family exploratory.

**Try first.** Define the family of tests before comparing Holm and BH. Which error rate matters for your use?

</details>

<details><summary>Show code example</summary>

```r
p.adjust(c(p1,p2), method="holm") # family-wise error control
p.adjust(c(p1,p2), method="BH")   # false-discovery-rate control
# Define the hypothesis family before applying either method.
```

For the complete defensive implementation, see the matching Q25 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q25_illustrative_multiplicity.csv`](results/Q25_illustrative_multiplicity.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Holm controls family-wise error; BH controls expected false discovery proportion. The script labels its example family exploratory.

</details>

### Q26. Which post-hoc test should follow one-way ANOVA?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Tukey is common for all-pairs family-wise control. Duncan is less conservative; choosing the test by desired significance is improper.

**Try first.** After an omnibus ANOVA, what pairwise claims do you need? Compare Tukey with Duncan’s error protection.

</details>

<details><summary>Show code example</summary>

```r
fit <- aov(age_at_initial_pathologic_diagnosis ~ factor(ajcc_pathologic_tumor_stage), data=raw)
TukeyHSD(fit)
# Duncan is optional (agricolae), less conservative; script checks for package.
```

For the complete defensive implementation, see the matching Q26 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q26_tukey_age_stage.csv`](results/Q26_tukey_age_stage.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Tukey is common for all-pairs family-wise control. Duncan is less conservative; choosing the test by desired significance is improper.

</details>

### Q27. What is confounding?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Adjustment is not causal by itself. Model assumptions, selection, mediator/collider status and unmeasured confounding matter.

**Try first.** Name a plausible common cause of age/stage and recorded vital status. Would adjusting automatically make the estimate causal?

</details>

<details><summary>Show code example</summary>

```r
# Script fits observed vital status ~ age + gender (+ stage where supported).
# Inspect complete-case N, event definition and coefficient CIs in results/Q27...csv.
```

For the complete defensive implementation, see the matching Q27 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q27_adjusted_logistic_association.csv`](results/Q27_adjusted_logistic_association.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Adjustment is not causal by itself. Model assumptions, selection, mediator/collider status and unmeasured confounding matter.

</details>

### Q28. What is overfitting?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Avoid overfitting, data-driven variable selection and leakage. Validate predictive models on suitable held-out/resampled data.

**Try first.** How many independent events support each model parameter? What would you do if sparse?

</details>

<details><summary>Show code example</summary>

```r
# Check candidate predictors and missingness before deciding model complexity.
# For survival models, information is driven by event counts and parameter count.
```

For the complete defensive implementation, see the matching Q28 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q28_model_candidate_availability.csv`](results/Q28_model_candidate_availability.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Avoid overfitting, data-driven variable selection and leakage. Validate predictive models on suitable held-out/resampled data.

</details>

### Q29. When can survival analysis be performed?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** The script assumes OS=1 death, OS=0 censored/alive only if values are binary and crosswalk is not contradictory. Review Q29_os_coding_check.csv and documentation. KM/log-rank are unadjusted; Cox checks proportional hazards. Never infer event meaning solely from a variable name.

**Try first.** Before fitting: verify the observed OS values, vital-status crosswalk, event meaning, time origin and units. What does censoring mean?

</details>

<details><summary>Show code example</summary>

```r
# Script requires OS coded exactly 0/1, compares its event coding with vital_status,
# then fits Surv(OS.time, OS), KM/log-rank by gender, and adjusted Cox.
# Verify 1=death, 0=censored and OS.time origin/units in documentation first.
```

For the complete defensive implementation, see the matching Q29 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q29_logrank_gender.csv`](results/Q29_logrank_gender.csv) (created when the script runs; not included as a precomputed result).

![Q29 figure](figures2/Fig29_km_os_gender.png)

Figure file: [`figures2/Fig29_km_os_gender.png`](figures2/Fig29_km_os_gender.png) (created when the script runs).

**Interpret after running.** The script assumes OS=1 death, OS=0 censored/alive only if values are binary and crosswalk is not contradictory. Review Q29_os_coding_check.csv and documentation. KM/log-rank are unadjusted; Cox checks proportional hazards. Never infer event meaning solely from a variable name.

</details>

### Q30. What belongs in a transparent report?

<details><summary>Hint and active-learning prompt</summary>

**Hint.** Check the reproducibility checklist. Avoid causal wording and do not upload protected patient-level data.

**Try first.** Draft a one-paragraph results report including n, events, effect/CI, test, missingness, assumptions and limitation.

</details>

<details><summary>Show code example</summary>

```r
sessionInfo()
# Report cohort definition, unit, missingness, methods, estimates/CIs, diagnostics,
# multiplicity and data-use limitations.
```

For the complete defensive implementation, see the matching Q30 section of `tutorial_30_questions.R`. It handles missing values and small groups, and saves results under `results/`.

</details>

<details><summary>Show outputs and interpretation prompts</summary>

- Script artifact: [`results/Q30_reproducibility.csv`](results/Q30_reproducibility.csv) (created when the script runs; not included as a precomputed result).

**Interpret after running.** Check the reproducibility checklist. Avoid causal wording and do not upload protected patient-level data.

</details>

---

## Reporting checklist

- [ ] Describe source cohort, inclusion, analysis unit (patient/sample), and variable definitions/units.
- [ ] Give the analysis-specific denominator, missing-data handling, and event counts where relevant.
- [ ] Match method and estimand to design; describe diagnostics/assumptions.
- [ ] Report an interpretable effect and 95% confidence interval, not just a p-value.
- [ ] Define the multiple-testing family and adjustment.
- [ ] For survival: name OS, validate 1=death/0=censored, state time origin and units, give n/events, report KM/log-rank and adjusted Cox with PH check.
- [ ] Clearly label exploratory observational associations; do not claim causality.
- [ ] Protect patient data and follow source permissions.

## Expected generated files

The R script creates a range of question-numbered CSV/TXT artifacts in `results/` and optional PNG figures in `figures2/`. It also writes `Q30_reproducibility.csv` and a reporting checklist. If data fields/packages are unavailable, look for `Qxx_note.txt` or an on-screen message; skipped calculations are not silently replaced.

## Package note

Only base R is necessary for most summaries/tests. `ggplot2` is optional for figures and `survival` optional for Q29. `agricolae` is optional for Duncan post-hoc comparison. Install missing packages with `install.packages("packageName")` in R. Do not treat missing-package skips as completed analysis.
