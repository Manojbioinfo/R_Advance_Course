---
title: "Tutorial 4: Biostatistics"
output:
  md_document:
    variant: gfm
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)
```

# Tutorial 4 — Biostatistics: from question to evidence

This tutorial models a defensible story: question → descriptive statistics → assumptions → test choice → effect size and multiplicity → survival analysis. It writes tables to `results/`.

```{r load}
library(tidyverse); library(ggpubr); library(rstatix); library(effectsize); library(car); library(FSA); library(broom); library(survival); library(survminer)
clinical <- read_csv("data/clinical_data.csv", show_col_types=FALSE)
dir.create("results", showWarnings=FALSE); dir.create("figures", showWarnings=FALSE)
clinical <- clinical |> mutate(Vital_Status=factor(Vital_Status), Gender=factor(Gender), Race=factor(Race), Age_Group=factor(Age_Group), Pathologic_stage=factor(Pathologic_stage))
```

## 1. Start with a question and describe the data

**Q1. What is the basic question?** Hint: state population, exposure/group, outcome, and estimand.
```{r q1}
# Example: Is age different between Alive and Dead patients?
clinical |> group_by(Vital_Status) |> summarise(n=n(), mean_age=mean(Age), sd_age=sd(Age), median_age=median(Age), IQR_age=IQR(Age)) |> write_csv("results/descriptive_age_by_vital_status.csv")
```

**Q2. What should be reported for categorical variables?** Hint: counts and percentages.
```{r q2}
desc_cat <- clinical |> count(Race, Vital_Status) |> group_by(Race) |> mutate(percent=100*n/sum(n))
desc_cat |> write_tsv("results/descriptive_race_vital_status.tsv")
```

**Q3. What is the distribution of age?** Hint: use both a histogram and a QQ plot.
```{r q3}
ggplot(clinical, aes(Age)) + geom_histogram(binwidth=5, fill="#0072B2") + theme_minimal()
qq <- ggqqplot(clinical$Age, title="QQ plot: age"); ggsave("figures/age_qq_plot.png", qq, width=6, height=5, dpi=300)
```

## 2. Normality, choice, and tests

**Q4. What does Shapiro–Wilk test here?** Hint: it tests normality, not equality of means.
```{r q4}
shapiro <- clinical |> group_by(Vital_Status) |> shapiro_test(Age)
shapiro |> write_csv("results/shapiro_age_by_vital_status.csv")
```

**Q5. What is a principled choice for two groups?** Hint: inspect plots, sample size, and the estimand; use Welch t-test for means or Wilcoxon for ranks.
```{r q5}
t_welch <- t.test(Age ~ Vital_Status, data=clinical)
w_wilcox <- wilcox.test(Age ~ Vital_Status, data=clinical, exact=FALSE)
tidy(t_welch) |> write_csv("results/welch_t_test_age.csv"); tidy(w_wilcox) |> write_csv("results/wilcoxon_age.csv")
```

**Q6. How large is the two-group difference?** Hint: report standardized mean difference with uncertainty.
```{r q6}
cohen <- effectsize::cohens_d(Age ~ Vital_Status, data=clinical)
write.csv(as.data.frame(cohen), "results/effect_size_cohens_d.csv", row.names=FALSE)
```

**Q7. Do ages vary by pathologic stage?** Hint: ANOVA targets means; Kruskal–Wallis targets rank distributions.
```{r q7}
anova_fit <- aov(Age ~ Pathologic_stage, data=clinical)
kw <- kruskal.test(Age ~ Pathologic_stage, data=clinical)
write.csv(broom::tidy(anova_fit), "results/anova_age_stage.csv", row.names=FALSE); write.csv(broom::tidy(kw), "results/kruskal_age_stage.csv", row.names=FALSE)
```

**Q8. Which stage pairs differ after Kruskal–Wallis?** Hint: use Dunn's test with Holm correction.
```{r q8}
dunn <- FSA::dunnTest(Age ~ Pathologic_stage, data=clinical, method="holm")$res
dunn |> write_csv("results/dunn_age_stage_holm.csv")
```

**Q9. Is smoking related to age?** Hint: choose Pearson for a linear normal-error story or Spearman for monotonic ranks.
```{r q9}
pearson <- cor.test(clinical$Age, clinical$Cigarettes_per_day, method="pearson")
spearman <- cor.test(clinical$Age, clinical$Cigarettes_per_day, method="spearman", exact=FALSE)
write.csv(broom::tidy(pearson), "results/correlation_pearson.csv", row.names=FALSE); write.csv(broom::tidy(spearman), "results/correlation_spearman.csv", row.names=FALSE)
```

**Q10. Is vital status associated with race?** Hint: use chi-square when expected counts are adequate; otherwise Fisher's exact test.
```{r q10}
tab <- table(clinical$Race, clinical$Vital_Status); chi <- suppressWarnings(chisq.test(tab)); fisher <- fisher.test(tab)
write.csv(broom::tidy(chi), "results/chi_square_race_vital.csv", row.names=FALSE); write.csv(broom::tidy(fisher), "results/fisher_race_vital.csv", row.names=FALSE)
```

## 3. Interpret p-values, effects, and multiplicity

**Q11. What does p < 0.05 mean?** Hint: conditional evidence against a null model, not the probability that the null is true.
```{r q11}
# Keep the effect estimate and confidence interval beside every p-value.
```

**Q12. How can several p-values be corrected?** Hint: use Holm for a small family or BH/FDR for discovery-oriented lists.
```{r q12}
pvals <- tibble(test=c("t_test","wilcoxon","pearson","spearman"), p=c(t_welch$p.value,w_wilcox$p.value,pearson$p.value,spearman$p.value)) |> mutate(p_holm=p.adjust(p,"holm"), p_bh=p.adjust(p,"BH"))
pvals |> write_csv("results/multiple_testing_corrections.csv")
```

**Q13. What is a useful reporting sentence?** Hint: combine direction, magnitude, CI, p-value, and context.
```{r q13}
report <- broom::tidy(t_welch) |> mutate(note="Report estimate and 95% CI; do not report p-value alone")
report |> write_csv("results/reporting_template.csv")
```

## 4. Survival analysis: teaching-only simulation warning

No time-to-event column exists in the stated clinical schema. The next section **checks for one** and otherwise creates a clearly labelled simulated follow-up time for teaching only. It is not a clinical result and must not be used for biological conclusions.

**Q14. Is a time-to-event column available?** Hint: search names before modeling.
```{r q14}
time_candidates <- names(clinical)[grepl("time|days|follow|month|survival", names(clinical), ignore.case=TRUE)]
time_candidates
```

**Q15. How can we make a reproducible teaching example when it is absent?** Hint: set a seed, simulate follow-up, and censor Alive patients.
```{r q15}
set.seed(20261019)
if (length(time_candidates)==0) {
  surv_dat <- clinical |> mutate(time_days=round(rexp(n(), rate=1/900)+if_else(Vital_Status=="Dead", 0, 300)), event=as.integer(Vital_Status=="Dead"))
  warning("SIMULATED follow-up only: no time-to-event column exists.")
} else { stop("A time-like column exists; adapt the tutorial explicitly before using it.") }
surv_dat |> select(ID, time_days, event) |> write_csv("results/simulated_survival_teaching_data.csv")
```

**Q16. What does a Kaplan–Meier curve estimate?** Hint: survival probability over follow-up time.
```{r q16}
km <- survfit(Surv(time_days, event) ~ Age_Group, data=surv_dat)
km_plot <- ggsurvplot(km, data=surv_dat, pval=TRUE, risk.table=TRUE, title="Teaching-only simulated Kaplan–Meier")
ggsave("figures/km_simulated_teaching.png", km_plot$plot, width=7, height=6, dpi=300)
```

**Q17. What is the log-rank test?** Hint: it compares observed and expected events across curves.
```{r q17}
logrank <- survdiff(Surv(time_days,event) ~ Age_Group, data=surv_dat)
write.csv(broom::tidy(logrank), "results/logrank_simulated.csv", row.names=FALSE)
```

**Q18. What does a Cox model estimate?** Hint: a hazard ratio adjusted for covariates, under proportional hazards.
```{r q18}
cox <- coxph(Surv(time_days,event) ~ Age_Group + Gender + Race, data=surv_dat)
cox_tidy <- broom::tidy(cox, exponentiate=TRUE, conf.int=TRUE)
cox_tidy |> write_csv("results/cox_simulated_hazard_ratios.csv")
```

**Q19. How can proportional hazards be checked?** Hint: inspect Schoenfeld residual tests.
```{r q19}
ph <- cox.zph(cox); write.csv(as.data.frame(ph$table), "results/cox_ph_assumption.csv")
```

## Quiz (answers are hidden)

<details><summary>1. Does a non-significant p-value prove no effect?</summary>No. It indicates insufficient evidence under the tested model; examine the estimate and confidence interval.</details>

<details><summary>2. When prefer Fisher's exact test?</summary>When expected cell counts are small or the chi-square approximation is unreliable.</details>

<details><summary>3. What is the major limitation of the survival section?</summary>Follow-up time is simulated because the supplied schema has no time-to-event column; conclusions are teaching-only.</details>

<details><summary>4. Why report effect sizes?</summary>They communicate magnitude and precision, which p-values alone do not.</details>
