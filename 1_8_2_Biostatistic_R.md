<div align="center">

# Tutorial 4: Biostatistics, from Question to Evidence

**TCGA Pan-Cancer clinical + gene-expression data set — 9,672 patients, 30 questions**

[![R >= 4.3](https://img.shields.io/badge/R-%E2%89%A5%204.3-blue.svg)]() [![tidyverse + rstatix + survival](https://img.shields.io/badge/tidyverse-rstatix-survival-blueviolet.svg)]() [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)]()

</div>

> **How to read this tutorial.** Each numbered question has a hint, a prediction prompt, runnable R code, output/figure, and a plain-language interpretation. Open the code boxes in order or run [the complete R script](Tutorial4_30_questions.R) from the project folder. The figures and numeric examples bundled here were generated from a **simulated demonstration dataset** with the same requested structure, because the real RDS was not available in this work session. They are not findings from real TCGA records. Run the script on your real dataset to replace them.

## Table of contents

- [Learning objectives](#learning-objectives)
- [Before you start](#before-you-start)
- [Setup](#setup)
- [Q1. How many rows and columns?](#q1-how-many-rows-and-columns)
- [Q2. What does each row represent, what type is each column?](#q2-what-does-each-row-represent-what-type-is-each-column)
- [Q3. Missing values per column?](#q3-missing-values-per-column)
- [Q4. Are patient IDs unique?](#q4-are-patient-ids-unique)
- [Q5. How many patients per Pathologic_stage?](#q5-how-many-patients-per-pathologicstage)
- [Q6. Mean and median age?](#q6-mean-and-median-age)
- [Q7. Distribution across Gender, Race, Vital_Status (frequency tables).](#q7-distribution-across-gender-race-vitalstatus-frequency-tables)
- [Q8. Distribution of Age: histogram+boxplot.](#q8-distribution-of-age-histogramboxplot)
- [Q9. Unusually high/low ages?](#q9-unusually-highlow-ages)
- [Q10. Mean & median of a gene expression (replacing cigarettes), check NA first.](#q10-mean--median-of-a-gene-expression-replacing-cigarettes-check-na-first)
- [Q11. Is age different between Alive and Dead? boxplot.](#q11-is-age-different-between-alive-and-dead-boxplot)
- [Q12. Is age approx normal within each Vital_Status group? histograms/QQ.](#q12-is-age-approx-normal-within-each-vitalstatus-group-histogramsqq)
- [Q13. Welch t-test or Wilcoxon for age by vital status?](#q13-welch-ttest-or-wilcoxon-for-age-by-vital-status)
- [Q14. Is gene expression different between Alive and Dead? boxplot then suitable test.](#q14-is-gene-expression-different-between-alive-and-dead-boxplot-then-suitable-test)
- [Q15. Does mean age differ across Pathologic_stage? boxplot + one-way ANOVA.](#q15-does-mean-age-differ-across-pathologicstage-boxplot--oneway-anova)
- [Q16. ANOVA residuals normal and spread similar? QQ of residuals.](#q16-anova-residuals-normal-and-spread-similar-qq-of-residuals)
- [Q17. If ANOVA significant, which stages differ per Duncan's test (agricolae::duncan.test, letter groups).](#q17-if-anova-significant-which-stages-differ-per-duncans-test-agricolaeduncantest-letter-groups)
- [Q18. If assumptions not ok, Kruskal-Wallis vs ANOVA.](#q18-if-assumptions-not-ok-kruskalwallis-vs-anova)
- [Q19. If KW significant, which pairs differ? Dunn post-hoc with correction.](#q19-if-kw-significant-which-pairs-differ-dunn-posthoc-with-correction)
- [Q20. Is age associated with gene expression? scatterplot.](#q20-is-age-associated-with-gene-expression-scatterplot)
- [Q21. What correlation is appropriate (Pearson vs Spearman)?](#q21-what-correlation-is-appropriate-pearson-vs-spearman)
- [Q22. Is Vital_Status associated with Gender? contingency table, chi-square/Fisher.](#q22-is-vitalstatus-associated-with-gender-contingency-table-chisquarefisher)
- [Q23. Does proportion of Dead vary across stages? table of proportions (+ stacked bar).](#q23-does-proportion-of-dead-vary-across-stages-table-of-proportions--stacked-bar)
- [Q24. Are some groups too small for reliable comparisons?](#q24-are-some-groups-too-small-for-reliable-comparisons)
- [Q25. How would you report the age comparison Alive vs Dead?](#q25-how-would-you-report-the-age-comparison-alive-vs-dead)
- [Q26. How to report ANOVA + Duncan across stages?](#q26-how-to-report-anova--duncan-across-stages)
- [Q27. Why report effect size/CI as well as p-value? (compute Cohen's d with CI)](#q27-why-report-effect-sizeci-as-well-as-pvalue-compute-cohens-d-with-ci)
- [Q28. Why adjust p-values for many pairwise comparisons? (demonstrate Holm/BH vs raw)](#q28-why-adjust-pvalues-for-many-pairwise-comparisons-demonstrate-holmbh-vs-raw)
- [Q29. Does dataset contain follow-up time and event status? (OS, OS.time)](#q29-does-dataset-contain-followup-time-and-event-status-os-ostime)
- [Q30. Survival differences between groups: Kaplan-Meier + log-rank, plus Cox model adjusting for age/gender.](#q30-survival-differences-between-groups-kaplanmeier--logrank-plus-cox-model-adjusting-for-agegender)

<a id="learning-objectives"></a>

## Learning objectives

By the end, you will be able to:

- Inspect structure, data types, missingness, row units and duplicate patient identifiers.
- Summarize continuous and categorical data and choose two-group, multi-group, association and survival methods.
- Check assumptions, report uncertainty/effect sizes, and adjust for multiple testing.
- Interpret estimates as associations in observational data, not proof of cause.

<a id="before-you-start"></a>

## Before you start

Put `Data/TCGA_pancancer_combined_geneexpression.rds` in the project folder. The expected raw object has 9,672 rows and 51 columns; rows represent sample records. The source variables used here include `sample_barcode`, `patient_id`, `cancer_type`, `BIRC5`, `CDKN2A`, `KRAS`, `MSLN`, `SMAD4`, `TP53`, age, gender, race, AJCC stage, vital status and OS follow-up. In the cleaned `clin` table, age/gender/stage/vital status are named `Age`, `Gender`, `Pathologic_stage`, `Vital_Status`. Text sentinels such as `[Not Available]` become missing values; AJCC stage is collapsed to Stages I–IV. Records with implausible ages outside 18–100 are excluded, and **one record per `patient_id` is retained (first sample in file order)** for patient-level comparisons. This is an explicit choice; change it if your analysis should use sample-level data or a different sample-selection rule. `figures2/` and `results/` are created automatically.

**Column substitutions.** This data set has no `Cigarettes_per_day`, `Age`, `Gender` or `Pathologic_stage` raw columns. Use `age_at_initial_pathologic_diagnosis`, `gender` and `ajcc_pathologic_tumor_stage` for the latter three. Questions 10 and 14 replace cigarettes-per-day with TP53 gene expression; Q20 also uses TP53. Gene-expression values are described as log-like; do not assume a specific scale transformation without the data dictionary.

**Optional mock generator.** `mock_data_generator.R` creates a simulated demo file at the expected path; it is only for practice if you do not yet have the real file. Do not mistake its outputs for TCGA findings.

<a id="setup"></a>

## Setup

Install packages once in R:

```r
install.packages(c("tidyverse","ggpubr","rstatix","effectsize","agricolae","FSA","survival","survminer","broom","scales","patchwork"))
```

The script loads these libraries and defines the common helpers. Its complete setup also reads the expected RDS and creates the cleaned `clin` data frame, including duplicate handling described above.

```r
library(tidyverse); library(ggpubr); library(rstatix); library(effectsize)
library(agricolae); library(FSA); library(survival); library(survminer)
library(broom); library(scales); library(patchwork)
dir.create("figures2", showWarnings=FALSE); dir.create("results", showWarnings=FALSE)
theme_pub <- function() theme_bw() + theme(panel.grid.minor=element_blank())
save_fig <- function(p, name, width=7, height=5)
  ggsave(file.path("figures2", paste0(name, ".png")), p, width=width, height=height, dpi=300)
write_tbl <- function(x, name) readr::write_csv(as.data.frame(x), file.path("results", name))
# Then run Tutorial4_30_questions.R for data import, cleaning, and Q01–Q30.
```

The main script reads the RDS, prepares `clin`, and uses `theme_pub()`, `save_fig()` (PNG, 300 dpi, in `figures2/`) and `write_tbl()` (CSV in `results/`). For survival, event coding is assumed to be `OS=1` event and `OS=0` censored; confirm this, time units and time origin in your data dictionary before interpreting. The script keeps the first sample per patient as stated above.

---

<a id="q1-how-many-rows-and-columns"></a>

## Q1. How many rows and columns?

**Hint.** Use `dim()` for the shape of a rectangular data frame.

**Think first.** Before running: what are the row and column counts?

<details><summary>Show R code</summary>

```r
dim(raw)
write_tbl(as.data.frame(t(dim(raw))), "Q01_dimensions.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Raw data: 9,672 rows × 51 columns (reported schema; confirm with dim(raw)).
```

</details>

<details><summary>Show solution & interpretation</summary>

The requested raw shape is **9,672 × 51**. `dim()` returns rows first and columns second. Confirm your file rather than assuming its dimensions.

**What to look for.** Use `dim()` for the shape of a rectangular data frame.

</details>

<a id="q2-what-does-each-row-represent-what-type-is-each-column"></a>

## Q2. What does each row represent, what type is each column?

**Hint.** Use `str()` or `class()` to inspect record meaning and stored column types. A row is a sample record; patient IDs may repeat.

**Think first.** Before running: do you expect rows to equal patients, or could one patient have multiple samples?

<details><summary>Show R code</summary>

```r
type_tbl <- tibble(column = names(raw), class = vapply(raw, function(x) paste(class(x), collapse = "/"), ""))
print(head(type_tbl, 12)); write_tbl(type_tbl, "Q02_column_types.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Run the matching section in the complete R script for results.
```

</details>

<details><summary>Show solution & interpretation</summary>

A row represents a sample record, not necessarily a unique patient; `patient_id` is the patient-level identifier. Numeric gene columns and age are quantitative; gender, race and vital status are categorical; AJCC stage is ordered categorical. `str(raw)` shows the actual storage classes.

**What to look for.** Use `str()` or `class()` to inspect record meaning and stored column types. A row is a sample record; patient IDs may repeat.

</details>

<a id="q3-missing-values-per-column"></a>

## Q3. Missing values per column?

**Hint.** Use `is.na()` plus a check for text placeholders. Missingness can affect every denominator.

**Think first.** Before running: which variable do you expect to have the most missing values?

<details><summary>Show R code</summary>

```r
miss_tbl <- tibble(column = names(raw), missing = vapply(raw, function(x) sum(is.na(x) | trimws(as.character(x)) %in% c("NA", "[Not Available]", "Not Reported")), 0L))
print(miss_tbl); write_tbl(miss_tbl, "Q03_missing.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Run the matching section in the complete R script for results.
```

</details>

<details><summary>Show solution & interpretation</summary>

The script counts both true `NA` values and common text sentinels. The number missing differs by column and denominator; read `results/Q03_missing.csv` after running. Do not silently treat missing as a biological category.

**What to look for.** Use `is.na()` plus a check for text placeholders. Missingness can affect every denominator.

</details>

<a id="q4-are-patient-ids-unique"></a>

## Q4. Are patient IDs unique?

**Hint.** Use `n_distinct()` and `count()` on `patient_id`. Sample rows are not automatically independent patients.

**Think first.** Before running: what would duplicate patient IDs mean for independence?

<details><summary>Show R code</summary>

```r
id_check <- clin |> summarise(rows=n(), unique_ids=n_distinct(patient_id), duplicate_rows=rows-unique_ids)
print(id_check); write_tbl(id_check, "Q04_id_uniqueness.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Patient IDs in the supplied description: patient_id is present; actual uniqueness is dataset-dependent.
```

</details>

<details><summary>Show solution & interpretation</summary>

The script reports the number of unique IDs and duplicate rows. The requested patient-level analysis keeps the first row per ID. Verify repeated sample records and document a better selection rule if needed.

**What to look for.** Use `n_distinct()` and `count()` on `patient_id`. Sample rows are not automatically independent patients.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q5-how-many-patients-per-pathologicstage"></a>

## Q5. How many patients per Pathologic_stage?

**Hint.** Use a frequency table after collapsing AJCC labels to Stages I–IV; inspect the collapsed labels and missing category.

**Think first.** Before running: which stage do you expect to be most common?

<details><summary>Show R code</summary>

```r
stage_n <- count(clin, Pathologic_stage, .drop=FALSE)
print(stage_n); write_tbl(stage_n, "Q05_stage_counts.csv")
p <- ggplot(stage_n, aes(Pathologic_stage,n)) + geom_col(fill="#2878B5") + labs(x="AJCC pathologic stage",y="Patients") + theme_pub()
save_fig(p,"Q05_stage_counts")
```

</details>

<details><summary>Show figure / output</summary>

![Question 5 output](figures2/Q05_stage_counts.png)

</details>

<details><summary>Show solution & interpretation</summary>

The stage count table and bar chart give the number of retained patients in each collapsed AJCC stage. Missing or unrecognized values are excluded from the stage count; see the table for actual counts.

**What to look for.** Use a frequency table after collapsing AJCC labels to Stages I–IV; inspect the collapsed labels and missing category.

</details>

<a id="q6-mean-and-median-age"></a>

## Q6. Mean and median age?

**Hint.** Use `mean()` and `median()` with `na.rm=TRUE`, while printing the number observed.

**Think first.** Before running: is mean age likely close to the median?

<details><summary>Show R code</summary>

```r
age_summary <- clin |> summarise(n=sum(!is.na(Age)), mean=mean(Age,na.rm=TRUE), median=median(Age,na.rm=TRUE), sd=sd(Age,na.rm=TRUE))
print(age_summary); write_tbl(age_summary,"Q06_age_summary.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
The demonstration generator uses ages centred near 61 years. Calculate n, mean and median on your own run; use real data outputs for reporting.
```

</details>

<details><summary>Show solution & interpretation</summary>

Age is measured in years at diagnosis. The demonstration data were generated around 61 years; that is a simulation design, not a finding. The script prints observed n, mean, median and SD from your data.

**What to look for.** Use `mean()` and `median()` with `na.rm=TRUE`, while printing the number observed.

</details>

<a id="q7-distribution-across-gender-race-vitalstatus-frequency-tables"></a>

## Q7. Distribution across Gender, Race, Vital_Status (frequency tables).

**Hint.** Use `count()` and proportions for each nominal variable. Frequencies are not means.

**Think first.** Before running: predict the largest vital-status group.

<details><summary>Show R code</summary>

```r
freq <- bind_rows(lapply(c("Gender","Race","Vital_Status"), function(v) clin |> count(category=.data[[v]], name="n") |> mutate(variable=v) |> group_by(variable) |> mutate(proportion=n/sum(n)) |> ungroup()))
print(freq); write_tbl(freq,"Q07_frequencies.csv")
p <- ggplot(freq,aes(category,n,fill=variable))+geom_col(show.legend=FALSE)+facet_wrap(~variable,scales="free_x")+labs(x=NULL,y="Patients")+theme_pub()+theme(axis.text.x=element_text(angle=35,hjust=1))
save_fig(p,"Q07_category_distributions",10,4.5)
```

</details>

<details><summary>Show figure / output</summary>

![Question 7 output](figures2/Q07_category_distributions.png)

</details>

<details><summary>Show solution & interpretation</summary>

The frequency table reports counts and within-variable proportions for gender, race and vital status. Compare distributions using their own denominators; race categories and missingness should be reported as stored after cleaning.

**What to look for.** Use `count()` and proportions for each nominal variable. Frequencies are not means.

</details>

<a id="q8-distribution-of-age-histogramboxplot"></a>

## Q8. Distribution of Age: histogram+boxplot.

**Hint.** Use a histogram for shape and a boxplot for median, spread and potential extremes.

**Think first.** Before running: does age look symmetric or skewed?

<details><summary>Show R code</summary>

```r
p1 <- ggplot(clin,aes(Age))+geom_histogram(binwidth=5,fill="#2878B5",colour="white",na.rm=TRUE)+labs(x="Age at diagnosis (years)",y="Patients")+theme_pub()
p2 <- ggplot(clin,aes(x=1,y=Age))+geom_boxplot(fill="#81B9D8",na.rm=TRUE)+labs(x=NULL,y="Age at diagnosis (years)")+theme_pub()+theme(axis.text.x=element_blank(),axis.ticks.x=element_blank())
save_fig(p1 | p2,"Q08_age_distribution",10,4)
```

</details>

<details><summary>Show figure / output</summary>

![Question 8 output](figures2/Q08_age_distribution.png)

</details>

<details><summary>Show solution & interpretation</summary>

The histogram reveals the shape; the boxplot shows median, interquartile range and potential extremes. The simulation generator uses a plausible broad age range; inspect your actual plot rather than inferring normality from a summary.

**What to look for.** Use a histogram for shape and a boxplot for median, spread and potential extremes.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q9-unusually-highlow-ages"></a>

## Q9. Unusually high/low ages?

**Hint.** Use the 1.5×IQR rule as a screening flag only. Investigate flagged records; do not delete automatically.

**Think first.** Before running: what counts as unusual is a prompt for checking, not an automatic error.

<details><summary>Show R code</summary>

```r
age_flags <- clin |> summarise(n=sum(!is.na(Age)), q1=quantile(Age,.25,na.rm=TRUE), q3=quantile(Age,.75,na.rm=TRUE), low=q1-1.5*(q3-q1), high=q3+1.5*(q3-q1), flagged=sum(Age<low|Age>high,na.rm=TRUE), min=min(Age,na.rm=TRUE), max=max(Age,na.rm=TRUE))
print(age_flags); write_tbl(age_flags,"Q09_age_flags.csv")
p<-ggplot(clin,aes(x="All patients",y=Age))+geom_boxplot(fill="#81B9D8",outlier.colour="#D1495B",na.rm=TRUE)+theme_pub()+labs(x=NULL,y="Age at diagnosis",title="Tukey-flagged points are prompts to check, not automatic errors")
save_fig(p,"Q09_age_extremes")
```

</details>

<details><summary>Show figure / output</summary>

![Question 9 output](figures2/Q09_age_extremes.png)

</details>

<details><summary>Show solution & interpretation</summary>

Tukey flags are points outside 1.5×IQR fences. A flag does not prove a mistake. Check source values and plausibility; the displayed range and flagged count are computed from the retained cohort.

**What to look for.** Use the 1.5×IQR rule as a screening flag only. Investigate flagged records; do not delete automatically.

</details>

<a id="q10-mean--median-of-a-gene-expression-replacing-cigarettes-check-na-first"></a>

## Q10. Mean & median of a gene expression (replacing cigarettes), check NA first.

**Hint.** The dataset has no cigarette variable. Use TP53 expression, first count non-missing values, then summarize.

**Think first.** Before running: predict whether TP53 mean and median are similar.

<details><summary>Show R code</summary>

```r
gene_summary <- clin |> summarise(n=sum(!is.na(TP53)), missing=sum(is.na(TP53)), mean=mean(TP53,na.rm=TRUE), median=median(TP53,na.rm=TRUE))
print(gene_summary); write_tbl(gene_summary,"Q10_TP53_summary.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
TP53 is numeric and includes simulated missing values in the optional generator. Exact mean/median vary with the real data.
```

</details>

<details><summary>Show solution & interpretation</summary>

TP53 replaces cigarettes because there is no cigarettes-per-day column. The script checks observed/missing counts and estimates the requested summary/test. Expression units are relative to the dataset’s processing; do not label them as cigarettes or raw counts.

**What to look for.** The dataset has no cigarette variable. Use TP53 expression, first count non-missing values, then summarize.

</details>

<a id="q11-is-age-different-between-alive-and-dead-boxplot"></a>

## Q11. Is age different between Alive and Dead? boxplot.

**Hint.** A boxplot shows center and spread; compare groups with Welch t-test or a rank test, not the picture alone.

**Think first.** Before running: predict which vital-status group may have a higher median age.

<details><summary>Show R code</summary>

```r
p<-ggplot(clin,aes(Vital_Status,Age,fill=Vital_Status))+geom_boxplot(na.rm=TRUE)+scale_fill_manual(values=c(Alive="#59A14F",Dead="#E15759"))+labs(x="Vital status",y="Age at diagnosis (years)")+theme_pub()+theme(legend.position="none")
save_fig(p,"Q11_age_vital_status")
print(clin |> group_by(Vital_Status) |> summarise(n=sum(!is.na(Age)),median=median(Age,na.rm=TRUE),.groups="drop"))
```

</details>

<details><summary>Show figure / output</summary>

![Question 11 output](figures2/Q11_age_vital_status.png)

</details>

<details><summary>Show solution & interpretation</summary>

Compare the medians, spreads and overlap in the boxplot, then use the appropriate inferential test. In the simulated demo, mean age was 60.44 years for Alive (n=7,690) and 62.35 for Dead (n=1,640); these are generated-example figures, not real TCGA results. The deduplication and plausible-age filter alter denominators.

**What to look for.** A boxplot shows center and spread; compare groups with Welch t-test or a rank test, not the picture alone.

</details>

<a id="q12-is-age-approx-normal-within-each-vitalstatus-group-histogramsqq"></a>

## Q12. Is age approx normal within each Vital_Status group? histograms/QQ.

**Hint.** Compare each group’s histogram and normal Q-Q plot. With large samples, small deviations are visible; judge their size and the analysis goal.

**Think first.** Before running: do you expect the tails to match a normal curve?

<details><summary>Show R code</summary>

```r
p<-ggplot(clin |> filter(!is.na(Age)),aes(Age))+geom_histogram(aes(y=after_stat(density)),binwidth=5,fill="#81B9D8",colour="white")+geom_density(colour="#D1495B")+facet_wrap(~Vital_Status)+theme_pub()+labs(x="Age",y="Density")
qq<-ggplot(clin |> filter(!is.na(Age)),aes(sample=Age))+stat_qq(size=.7,alpha=.45)+stat_qq_line(colour="#D1495B")+facet_wrap(~Vital_Status,scales="free")+theme_pub()+labs(x="Theoretical normal quantile",y="Sample quantile")
save_fig(p/qq,"Q12_age_normality",9,7)
```

</details>

<details><summary>Show figure / output</summary>

![Question 12 output](figures2/Q12_age_normality.png)

</details>

<details><summary>Show solution & interpretation</summary>

Histograms and Q-Q plots assess approximate normality separately in Alive and Dead groups. Curvature at tails suggests deviation; large samples make formal normality tests over-sensitive. The Welch test is often robust for mean comparisons, especially with similar sample sizes.

**What to look for.** Compare each group’s histogram and normal Q-Q plot. With large samples, small deviations are visible; judge their size and the analysis goal.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q13-welch-ttest-or-wilcoxon-for-age-by-vital-status"></a>

## Q13. Welch t-test or Wilcoxon for age by vital status?

**Hint.** Welch t-test compares means without equal-variance assumption; Wilcoxon compares distributions/ranks. Inspect shape and state which quantity you target.

**Think first.** Before running: which test’s target (mean or rank distribution) best matches your question?

<details><summary>Show R code</summary>

```r
d<-drop_na(clin,Age,Vital_Status)
welch<-t.test(Age~Vital_Status,data=d,var.equal=FALSE)
wilcox<-wilcox.test(Age~Vital_Status,data=d,exact=FALSE)
print(welch); print(wilcox); write_tbl(broom::tidy(welch),"Q13_welch.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Welch and Wilcoxon test results are written to results/Q13_welch.csv and printed; use the sample's result, not the demo description.
```

</details>

<details><summary>Show solution & interpretation</summary>

Welch t-test targets a difference in group means and does not require equal variance. Wilcoxon is a rank-based distribution comparison. Use the plots and study question to choose, and report the test actually selected; neither test is causal.

**What to look for.** Welch t-test compares means without equal-variance assumption; Wilcoxon compares distributions/ranks. Inspect shape and state which quantity you target.

</details>

<a id="q14-is-gene-expression-different-between-alive-and-dead-boxplot-then-suitable-test"></a>

## Q14. Is gene expression different between Alive and Dead? boxplot then suitable test.

**Hint.** Use a boxplot and a test suited to the distribution. TP53 replaces cigarettes because no cigarettes-per-day column exists.

**Think first.** Before running: predict whether TP53 expression differs by vital status.

<details><summary>Show R code</summary>

```r
p<-ggplot(clin,aes(Vital_Status,TP53,fill=Vital_Status))+geom_boxplot(na.rm=TRUE)+scale_fill_manual(values=c(Alive="#59A14F",Dead="#E15759"))+theme_pub()+theme(legend.position="none")+labs(x="Vital status",y="TP53 expression (log-like units)")
save_fig(p,"Q14_TP53_vital_status")
test<-wilcox.test(TP53~Vital_Status,data=clin,exact=FALSE); print(test); write_tbl(broom::tidy(test),"Q14_TP53_wilcoxon.csv")
```

</details>

<details><summary>Show figure / output</summary>

![Question 14 output](figures2/Q14_TP53_vital_status.png)

</details>

<details><summary>Show solution & interpretation</summary>

TP53 replaces cigarettes because there is no cigarettes-per-day column. The script checks observed/missing counts and estimates the requested summary/test. Expression units are relative to the dataset’s processing; do not label them as cigarettes or raw counts.

**What to look for.** Use a boxplot and a test suited to the distribution. TP53 replaces cigarettes because no cigarettes-per-day column exists.

</details>

<a id="q15-does-mean-age-differ-across-pathologicstage-boxplot--oneway-anova"></a>

## Q15. Does mean age differ across Pathologic_stage? boxplot + one-way ANOVA.

**Hint.** Use one-way ANOVA for mean age across stages, with independent observations and residual assumptions checked.

**Think first.** Before running: predict whether stage means differ, and what might confound this comparison.

<details><summary>Show R code</summary>

```r
aov_fit<-aov(Age~Pathologic_stage,data=clin)
print(summary(aov_fit)); write_tbl(broom::tidy(aov_fit),"Q15_anova.csv")
p<-ggplot(clin,aes(Pathologic_stage,Age))+geom_boxplot(fill="#81B9D8",na.rm=TRUE)+theme_pub()+labs(x="AJCC pathologic stage",y="Age at diagnosis")
save_fig(p,"Q15_age_by_stage")
```

</details>

<details><summary>Show figure / output</summary>

![Question 15 output](figures2/Q15_age_by_stage.png)

</details>

<details><summary>Show solution & interpretation</summary>

For the simulation, stage sample sizes before any row filtering were I 2,103; II 2,946; III 2,628; IV 1,533. Age group means in that simulated set are close (about 60.5–61.0 years). These illustrative summaries are not patient findings. Check ANOVA assumptions and interpret post-hoc comparisons only after the omnibus result. Duncan’s test is relatively liberal; consider reporting its familywise limitations. Kruskal–Wallis tests rank distributions, not specifically means.

**What to look for.** Use one-way ANOVA for mean age across stages, with independent observations and residual assumptions checked.

</details>

<a id="q16-anova-residuals-normal-and-spread-similar-qq-of-residuals"></a>

## Q16. ANOVA residuals normal and spread similar? QQ of residuals.

**Hint.** Use a residual Q-Q plot for approximate normality and Levene’s test for similar group variances.

**Think first.** Before running: what pattern would make the residual Q-Q plot concerning?

<details><summary>Show R code</summary>

```r
res<-residuals(aov_fit); qqdat<-data.frame(res=res)
p<-ggplot(qqdat,aes(sample=res))+stat_qq(alpha=.4)+stat_qq_line(colour="#D1495B")+theme_pub()+labs(x="Theoretical quantile",y="ANOVA residual quantile")
save_fig(p,"Q16_anova_residual_qq")
print(rstatix::levene_test(clin,Age~Pathologic_stage))
```

</details>

<details><summary>Show figure / output</summary>

![Question 16 output](figures2/Q16_anova_residual_qq.png)

</details>

<details><summary>Show solution & interpretation</summary>

For the simulation, stage sample sizes before any row filtering were I 2,103; II 2,946; III 2,628; IV 1,533. Age group means in that simulated set are close (about 60.5–61.0 years). These illustrative summaries are not patient findings. Check ANOVA assumptions and interpret post-hoc comparisons only after the omnibus result. Duncan’s test is relatively liberal; consider reporting its familywise limitations. Kruskal–Wallis tests rank distributions, not specifically means.

**What to look for.** Use a residual Q-Q plot for approximate normality and Levene’s test for similar group variances.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q17-if-anova-significant-which-stages-differ-per-duncans-test-agricolaeduncantest-letter-groups"></a>

## Q17. If ANOVA significant, which stages differ per Duncan's test (agricolae::duncan.test, letter groups).

**Hint.** Only if the omnibus comparison warrants follow-up, use agricolae Duncan groups. Shared letters mean no detected difference under that procedure.

**Think first.** Before running: Duncan’s letters are pairwise group summaries, not causal claims.

<details><summary>Show R code</summary>

```r
if (summary(aov_fit)[[1]][["Pr(>F)"]][1] < .05) { duncan<-agricolae::duncan.test(aov_fit,"Pathologic_stage",group=TRUE); print(duncan$groups); write_tbl(duncan$groups,"Q17_duncan_letters.csv") } else message("ANOVA not significant: Duncan follow-up not run.")
```

</details>

<details><summary>Show figure / output</summary>

```text
Duncan group letters are printed and saved to results/Q17_duncan_letters.csv when the omnibus analysis and package permit.
```

</details>

<details><summary>Show solution & interpretation</summary>

For the simulation, stage sample sizes before any row filtering were I 2,103; II 2,946; III 2,628; IV 1,533. Age group means in that simulated set are close (about 60.5–61.0 years). These illustrative summaries are not patient findings. Check ANOVA assumptions and interpret post-hoc comparisons only after the omnibus result. Duncan’s test is relatively liberal; consider reporting its familywise limitations. Kruskal–Wallis tests rank distributions, not specifically means.

**What to look for.** Only if the omnibus comparison warrants follow-up, use agricolae Duncan groups. Shared letters mean no detected difference under that procedure.

</details>

<a id="q18-if-assumptions-not-ok-kruskalwallis-vs-anova"></a>

## Q18. If assumptions not ok, Kruskal-Wallis vs ANOVA.

**Hint.** Kruskal–Wallis is a rank-based alternative when ANOVA assumptions are poor; it does not test equality of means.

**Think first.** Before running: what assumption failure would make you prefer the rank-based test?

<details><summary>Show R code</summary>

```r
print(kruskal.test(Age~Pathologic_stage,data=clin)); print(summary(aov_fit)[[1]])
# Compare assumptions and target; do not select a test only by p-value.
```

</details>

<details><summary>Show figure / output</summary>

```text
Kruskal–Wallis and ANOVA outputs are printed for comparison.
```

</details>

<details><summary>Show solution & interpretation</summary>

For the simulation, stage sample sizes before any row filtering were I 2,103; II 2,946; III 2,628; IV 1,533. Age group means in that simulated set are close (about 60.5–61.0 years). These illustrative summaries are not patient findings. Check ANOVA assumptions and interpret post-hoc comparisons only after the omnibus result. Duncan’s test is relatively liberal; consider reporting its familywise limitations. Kruskal–Wallis tests rank distributions, not specifically means.

**What to look for.** Kruskal–Wallis is a rank-based alternative when ANOVA assumptions are poor; it does not test equality of means.

</details>

<a id="q19-if-kw-significant-which-pairs-differ-dunn-posthoc-with-correction"></a>

## Q19. If KW significant, which pairs differ? Dunn post-hoc with correction.

**Hint.** Use Dunn pairwise comparisons after a Kruskal–Wallis result and adjust the family of p-values (Holm here).

**Think first.** Before running: why adjust when comparing all stage pairs?

<details><summary>Show R code</summary>

```r
kw<-kruskal.test(Age~Pathologic_stage,data=clin); print(kw)
if (requireNamespace("FSA",quietly=TRUE)) { dunn<-FSA::dunnTest(Age~Pathologic_stage,data=clin,method="holm")$res; print(dunn); write_tbl(dunn,"Q19_dunn_holm.csv") }
p<-ggplot(clin,aes(Pathologic_stage,Age))+geom_boxplot(fill="#81B9D8",na.rm=TRUE)+theme_pub()+labs(x="AJCC stage",y="Age")
save_fig(p,"Q19_dunn_stage_pairs")
```

</details>

<details><summary>Show figure / output</summary>

![Question 19 output](figures2/Q19_dunn_stage_pairs.png)

</details>

<details><summary>Show solution & interpretation</summary>

For the simulation, stage sample sizes before any row filtering were I 2,103; II 2,946; III 2,628; IV 1,533. Age group means in that simulated set are close (about 60.5–61.0 years). These illustrative summaries are not patient findings. Check ANOVA assumptions and interpret post-hoc comparisons only after the omnibus result. Duncan’s test is relatively liberal; consider reporting its familywise limitations. Kruskal–Wallis tests rank distributions, not specifically means.

**What to look for.** Use Dunn pairwise comparisons after a Kruskal–Wallis result and adjust the family of p-values (Holm here).

</details>

<a id="q20-is-age-associated-with-gene-expression-scatterplot"></a>

## Q20. Is age associated with gene expression? scatterplot.

**Hint.** A scatterplot reveals form, outliers and non-linearity before calculating a correlation.

**Think first.** Before running: would you expect a straight-line relation?

<details><summary>Show R code</summary>

```r
p<-ggplot(clin,aes(Age,TP53))+geom_point(alpha=.25,size=1,na.rm=TRUE)+geom_smooth(method="loess",se=FALSE,colour="#D1495B",na.rm=TRUE)+theme_pub()+labs(x="Age at diagnosis",y="TP53 expression")
save_fig(p,"Q20_age_TP53_scatter")
```

</details>

<details><summary>Show figure / output</summary>

![Question 20 output](figures2/Q20_age_TP53_scatter.png)

</details>

<details><summary>Show solution & interpretation</summary>

A trend line and scatter cloud indicate whether the relationship looks linear, monotonic, curved or dominated by outliers. Pearson is suitable for a roughly linear relationship; Spearman is useful for a monotonic but non-normal association. The script prints both for comparison; select and report the one justified before emphasizing its p-value.

**What to look for.** A scatterplot reveals form, outliers and non-linearity before calculating a correlation.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q21-what-correlation-is-appropriate-pearson-vs-spearman"></a>

## Q21. What correlation is appropriate (Pearson vs Spearman)?

**Hint.** Pearson targets linear association and is sensitive to outliers; Spearman targets monotonic rank association.

**Think first.** Before running: are outliers or non-linearity plausible?

<details><summary>Show R code</summary>

```r
d<-drop_na(clin,Age,TP53)
cor.test(d$Age,d$TP53,method="spearman",exact=FALSE) |> broom::tidy() |> print()
cor.test(d$Age,d$TP53,method="pearson") |> broom::tidy() |> print()
```

</details>

<details><summary>Show figure / output</summary>

```text
Pearson and Spearman estimates and confidence intervals are printed.
```

</details>

<details><summary>Show solution & interpretation</summary>

A trend line and scatter cloud indicate whether the relationship looks linear, monotonic, curved or dominated by outliers. Pearson is suitable for a roughly linear relationship; Spearman is useful for a monotonic but non-normal association. The script prints both for comparison; select and report the one justified before emphasizing its p-value.

**What to look for.** Pearson targets linear association and is sensitive to outliers; Spearman targets monotonic rank association.

</details>

<a id="q22-is-vitalstatus-associated-with-gender-contingency-table-chisquarefisher"></a>

## Q22. Is Vital_Status associated with Gender? contingency table, chi-square/Fisher.

**Hint.** Use a 2×2 contingency table and expected counts; choose Fisher’s exact test if expected cells are sparse.

**Think first.** Before running: which expected cell count would make chi-square questionable?

<details><summary>Show R code</summary>

```r
tab<-table(clin$Vital_Status,clin$Gender); print(tab); write_tbl(as.data.frame.matrix(tab),"Q22_vital_gender_table.csv")
if (any(chisq.test(tab)$expected<5)) print(fisher.test(tab)) else print(chisq.test(tab))
```

</details>

<details><summary>Show figure / output</summary>

```text
Contingency table and selected chi-square/Fisher test are printed.
```

</details>

<details><summary>Show solution & interpretation</summary>

Use expected cell counts to choose Pearson chi-square or Fisher exact test. Report the table, denominator, and an association effect (e.g., odds ratio or Cramér’s V), not only a p-value. A statistical association is not evidence that gender causes survival status.

**What to look for.** Use a 2×2 contingency table and expected counts; choose Fisher’s exact test if expected cells are sparse.

</details>

<a id="q23-does-proportion-of-dead-vary-across-stages-table-of-proportions--stacked-bar"></a>

## Q23. Does proportion of Dead vary across stages? table of proportions (+ stacked bar).

**Hint.** Calculate proportions within stage (not across the whole table) and show them in a 100% stacked bar chart.

**Think first.** Before running: compare proportions within each stage, not raw counts alone.

<details><summary>Show R code</summary>

```r
prop<-clin |> filter(!is.na(Pathologic_stage),!is.na(Vital_Status)) |> count(Pathologic_stage,Vital_Status) |> group_by(Pathologic_stage) |> mutate(proportion=n/sum(n)) |> ungroup()
print(prop); write_tbl(prop,"Q23_dead_proportions.csv")
p<-ggplot(prop,aes(Pathologic_stage,proportion,fill=Vital_Status))+geom_col()+scale_y_continuous(labels=scales::percent)+scale_fill_manual(values=c(Alive="#59A14F",Dead="#E15759"))+theme_pub()+labs(x="AJCC stage",y="Within-stage proportion")
save_fig(p,"Q23_dead_by_stage")
```

</details>

<details><summary>Show figure / output</summary>

![Question 23 output](figures2/Q23_dead_by_stage.png)

</details>

<details><summary>Show solution & interpretation</summary>

The stacked chart and table show within-stage proportions. In the simulated data, dead proportions rise across stages by design; actual estimates, uncertainty and missingness must be obtained from your run. Counts alone can be misleading when stage sizes differ.

**What to look for.** Calculate proportions within stage (not across the whole table) and show them in a 100% stacked bar chart.

</details>

<a id="q24-are-some-groups-too-small-for-reliable-comparisons"></a>

## Q24. Are some groups too small for reliable comparisons?

**Hint.** Print the number in every stage-by-gender cell. Tiny samples give unstable estimates and wide uncertainty.

**Think first.** Before running: what minimum group size would make you cautious?

<details><summary>Show R code</summary>

```r
sizes<-clin |> count(Pathologic_stage,Gender, name="n")
print(sizes); write_tbl(sizes,"Q24_group_sizes.csv")
# Flag very small cells for caution; a threshold is a teaching aid, not a law.
print(filter(sizes,n<10))
```

</details>

<details><summary>Show figure / output</summary>

```text
Stage-by-gender cell counts are printed; counts below 10 are flagged as a caution, not an absolute rule.
```

</details>

<details><summary>Show solution & interpretation</summary>

The script flags cells with fewer than 10 observations as a practical warning. This is not a universal cutoff. Small groups produce uncertain estimates; combine categories only when clinically justified, not to obtain significance.

**What to look for.** Print the number in every stage-by-gender cell. Tiny samples give unstable estimates and wide uncertainty.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

<a id="q25-how-would-you-report-the-age-comparison-alive-vs-dead"></a>

## Q25. How would you report the age comparison Alive vs Dead?

**Hint.** Report group n, mean and SD, mean difference, 95% CI, t statistic, degrees of freedom and p-value.

**Think first.** Before running: write a sentence with direction, uncertainty and units.

<details><summary>Show R code</summary>

```r
d<-drop_na(clin,Age,Vital_Status)
fit<-t.test(Age~Vital_Status,data=d); print(broom::tidy(fit))
print(d |> group_by(Vital_Status) |> summarise(n=n(),mean=mean(Age),sd=sd(Age),.groups="drop"))
```

</details>

<details><summary>Show figure / output</summary>

```text
Welch estimate, 95% CI and group means/SDs are computed on complete cases.
```

</details>

<details><summary>Show solution & interpretation</summary>

A clear report includes group n, mean ± SD (or median and IQR), mean difference in years, 95% CI, Welch t, df and p-value. The means in the simulated demo are 60.44 vs 62.35 years, a difference of about 1.91 years (Alive minus Dead = −1.91); treat this strictly as a simulated illustration.

**What to look for.** Report group n, mean and SD, mean difference, 95% CI, t statistic, degrees of freedom and p-value.

</details>

<a id="q26-how-to-report-anova--duncan-across-stages"></a>

## Q26. How to report ANOVA + Duncan across stages?

**Hint.** Report the omnibus F test, degrees of freedom, p-value, group means and Duncan letter groups; describe limitations.

**Think first.** Before running: what would shared letter labels mean?

<details><summary>Show R code</summary>

```r
print(summary(aov_fit)); if (exists("duncan")) print(duncan$groups)
# Report F(df1, df2), p, group summaries and Duncan letters; explain shared letters.
```

</details>

<details><summary>Show figure / output</summary>

```text
ANOVA omnibus output and Duncan letters are printed when available.
```

</details>

<details><summary>Show solution & interpretation</summary>

Report F and its degrees of freedom, p-value, each stage’s mean/SD and Duncan letters. Groups sharing one or more letters were not separated by this procedure. Avoid saying the stage caused age differences; cross-cancer stage categories may not be fully comparable.

**What to look for.** Report the omnibus F test, degrees of freedom, p-value, group means and Duncan letter groups; describe limitations.

</details>

<a id="q27-why-report-effect-sizeci-as-well-as-pvalue-compute-cohens-d-with-ci"></a>

## Q27. Why report effect size/CI as well as p-value? (compute Cohen's d with CI)

**Hint.** Cohen’s d expresses a standardized mean difference and its interval; a p-value alone does not show size or precision.

**Think first.** Before running: can a tiny effect be precise in a large sample?

<details><summary>Show R code</summary>

```r
d<-drop_na(clin,Age,Vital_Status)
es<-effectsize::cohens_d(Age~Vital_Status,data=d, pooled_sd=TRUE, ci=.95)
print(es); write_tbl(es,"Q27_cohens_d_ci.csv")
```

</details>

<details><summary>Show figure / output</summary>

```text
Cohen's d and its 95% confidence interval are printed and saved to results/Q27_cohens_d_ci.csv.
```

</details>

<details><summary>Show solution & interpretation</summary>

Cohen’s d expresses the group difference in pooled-SD units. Its confidence interval shows uncertainty; a small p-value alone does not show clinical importance. State group order because it determines the sign.

**What to look for.** Cohen’s d expresses a standardized mean difference and its interval; a p-value alone does not show size or precision.

</details>

<a id="q28-why-adjust-pvalues-for-many-pairwise-comparisons-demonstrate-holmbh-vs-raw"></a>

## Q28. Why adjust p-values for many pairwise comparisons? (demonstrate Holm/BH vs raw)

**Hint.** When many hypotheses are tested, some small p-values occur by chance. Compare unadjusted, Holm and BH values on a clearly labelled teaching example.

**Think first.** Before running: which correction is more conservative in this demonstration?

<details><summary>Show R code</summary>

```r
pv<-c(.001,.012,.026,.041,.16,.31) # reproducible teaching example, not cohort p-values
adj<-tibble(comparison=paste0("Pair ",seq_along(pv)),raw_p=pv,Holm=p.adjust(pv,"holm"),BH=p.adjust(pv,"BH"))
print(adj); write_tbl(adj,"Q28_adjustment_demo.csv")
p<-adj |> pivot_longer(-comparison,names_to="method",values_to="p") |> ggplot(aes(comparison,p,colour=method,group=method))+geom_point()+geom_line()+geom_hline(yintercept=.05,linetype=2)+scale_y_log10()+theme_pub()+labs(x="Illustrative pair",y="p-value (log scale)")
save_fig(p,"Q28_multiple_testing")
```

</details>

<details><summary>Show figure / output</summary>

![Question 28 output](figures2/Q28_multiple_testing.png)

</details>

<details><summary>Show solution & interpretation</summary>

The plotted p-values are a clearly labelled **toy demonstration**, not values calculated from patient data. Holm controls family-wise error; Benjamini–Hochberg controls false-discovery rate under its assumptions. Adjust the complete planned comparison family and report both method and adjusted values.

**What to look for.** When many hypotheses are tested, some small p-values occur by chance. Compare unadjusted, Holm and BH values on a clearly labelled teaching example.

</details>

<a id="q29-does-dataset-contain-followup-time-and-event-status-os-ostime"></a>

## Q29. Does dataset contain follow-up time and event status? (OS, OS.time)

**Hint.** Check event coding and follow-up time: `OS` is event indicator (1 event, 0 censored) and `OS.time` is follow-up in days in the assumed schema. Verify the data dictionary.

**Think first.** Before running: how many events and censored records do you expect?

<details><summary>Show R code</summary>

```r
surv_check<-clin |> summarise(n=n(),missing_time=sum(is.na(OS.time)),missing_status=sum(is.na(OS)),events=sum(OS==1,na.rm=TRUE),censored=sum(OS==0,na.rm=TRUE))
print(surv_check); write_tbl(surv_check,"Q29_survival_inventory.csv")
print(table(clin$OS,clin$Vital_Status,useNA="ifany"))
```

</details>

<details><summary>Show figure / output</summary>

```text
A survival inventory counts usable time, event and censored records; the OS-by-vital-status cross-tab checks the coding.
```

</details>

<details><summary>Show solution & interpretation</summary>

The data schema includes OS (event indicator) and OS.time (days). Confirm `OS=1` means event and `OS=0` means right-censored; check consistency with `Vital_Status`. The generator was constructed with event values aligned to Alive/Dead, while real datasets may differ.

**What to look for.** Check event coding and follow-up time: `OS` is event indicator (1 event, 0 censored) and `OS.time` is follow-up in days in the assumed schema. Verify the data dictionary.

</details>

<a id="q30-survival-differences-between-groups-kaplanmeier--logrank-plus-cox-model-adjusting-for-agegender"></a>

## Q30. Survival differences between groups: Kaplan-Meier + log-rank, plus Cox model adjusting for age/gender.

**Hint.** Kaplan–Meier curves with risk table and log-rank compare groups unadjusted. Cox model reports adjusted hazard ratios; verify PH assumptions and event coding.

**Think first.** Before running: why must censoring and event definitions be correct?

<details><summary>Show R code</summary>

```r
sd<-clin |> filter(OS %in% c(0,1),is.finite(OS.time),OS.time>=0,!is.na(Pathologic_stage),!is.na(Age),!is.na(Gender))
km<-survival::survfit(survival::Surv(OS.time,OS)~Pathologic_stage,data=sd)
print(survival::survdiff(survival::Surv(OS.time,OS)~Pathologic_stage,data=sd))
g<-survminer::ggsurvplot(km,data=sd,risk.table=TRUE,pval=TRUE,conf.int=TRUE)
km_panel<-survminer::arrange_ggsurvplots(g,print=FALSE); save_fig(km_panel,"Q30_km_curve",8,7)
cox<-survival::coxph(survival::Surv(OS.time,OS)~Pathologic_stage+Age+Gender,data=sd); print(summary(cox)); write_tbl(broom::tidy(cox,exponentiate=TRUE,conf.int=TRUE),"Q30_cox_table.csv")
forest<-survminer::ggforest(cox,data=sd); print(forest); save_fig(forest,"Q30_cox_forest",8,5)
```

</details>

<details><summary>Show figure / output</summary>

![Question 30 Kaplan–Meier curve](figures2/Q30_km_curve.png)

The complete script saves the adjusted Cox forest plot as `figures2/Q30_cox_forest.png` and the coefficient table as `results/Q30_cox_table.csv` after running on your data.

</details>

<details><summary>Show solution & interpretation</summary>

The KM plot is stratified by pathologic stage and includes numbers at risk. The log-rank test is unadjusted. The Cox model adjusts for age and gender and reports hazard ratios with 95% CIs. Verify proportional hazards and event definition before interpretation; the alive/dead status cannot be used as an explanatory group for OS if it is exactly the event itself.

**What to look for.** Kaplan–Meier curves with risk table and log-rank compare groups unadjusted. Cox model reports adjusted hazard ratios; verify PH assumptions and event coding.

</details>

> **Pause and think.** Which assumption or data-quality check changed how you would explain the result? What additional covariate or design feature would make the next analysis more credible?

## Summary of what you learned

You inspected the data before analysis, chose methods based on outcome type and assumptions, displayed uncertainty, adjusted multiple comparisons, and distinguished association from causation. Re-run the script on the real RDS and replace every demo result with its output.

## Common mistakes

- Treating sample rows as independent people when `patient_id` repeats.
- Treating placeholder text as a meaningful category or hiding missing denominators.
- Deleting outliers just because a boxplot flags them.
- Choosing a test from a p-value or normality test alone.
- Describing rank-based tests as tests of means.
- Reporting p-values without effect sizes, intervals, or group counts.
- Using raw percentages with different denominators, or failing to adjust many comparisons.
- Assuming survival event coding, follow-up units or stage comparability without checking documentation.
- Treating simulated examples as real patient evidence or interpreting observational associations causally.

## License

This tutorial text and original code are offered under the MIT License. The dataset retains its own source license and privacy conditions; this statement does not alter them.

---

*Demonstration-output note: bundled figures were created from a seeded simulated dataset in this sandbox. The real user RDS was not mounted. Generated mock values and plots are for code illustration only; regenerate everything with the actual dataset before use.*

