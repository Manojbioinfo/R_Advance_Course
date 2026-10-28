# 🧬 Biostatistics: From Question to Evidence
### 30 Multiple-Choice Questions on TCGA Pan-Cancer Clinical Data

> **How to use this quiz.** Pick one answer, then click **"Show answer"** under each question to check yourself.
> **Score guide:** 27-30 🏆 Excellent · 21-26 👍 Good · 15-20 📘 Review the weak sections · below 15 🔁 Re-read the tutorial.

---

## 🧭 Section 1. Asking the right question

**Q1. Which of these is a *descriptive* research question?**
- A) Does smoking cause pancreatic cancer?
- B) What is the median age at diagnosis in this cohort?
- C) Will this patient survive 5 years?
- D) Does drug X improve survival?

<details><summary>👀 Show answer</summary>

**Answer: B.** It describes the cohort without predicting or claiming cause.

</details>

**Q2. Which question is *predictive*?**
- A) How many patients are female?
- B) Does TP53 expression predict who will die within 3 years?
- C) Does age cause cancer?
- D) What is the mean age?

<details><summary>👀 Show answer</summary>

**Answer: B.** It uses a variable to predict a future outcome.

</details>

**Q3. Which design is needed before using *causal* language?**
- A) A larger table
- B) A colourful plot
- C) A randomised trial or a carefully designed causal analysis
- D) A smaller p-value

<details><summary>👀 Show answer</summary>

**Answer: C.** Causal claims need randomisation or a rigorous causal design.

</details>

---

## 🏷️ Section 2. Know your variable types

**Q4. Gender (female/male) is what type of variable?**
- A) Continuous
- B) Ordinal
- C) Nominal
- D) Interval

<details><summary>👀 Show answer</summary>

**Answer: C.** The categories have no order.

</details>

**Q5. Pathologic stage (I < II < III < IV) is best described as:**
- A) Nominal
- B) Ordinal
- C) Continuous
- D) Binary only

<details><summary>👀 Show answer</summary>

**Answer: B.** The categories are ordered, but not necessarily equally spaced.

</details>

**Q6. Age in years is:**
- A) Nominal
- B) Ordinal
- C) Continuous (numeric)
- D) A string

<details><summary>👀 Show answer</summary>

**Answer: C.** It is a numeric measurement.

</details>

**Q7. Which summary is best for a categorical variable such as cancer type?**
- A) Mean and SD
- B) Counts and percentages
- C) Pearson correlation
- D) Hazard ratio

<details><summary>👀 Show answer</summary>

**Answer: B.** Categories are summarised by counts and proportions.

</details>

---

## 📊 Section 3. Describing the data

**Q8. Which measure of centre is least affected by outliers?**
- A) Mean
- B) Median
- C) Range
- D) Variance

<details><summary>👀 Show answer</summary>

**Answer: B.** The median depends on rank, not extreme values.

</details>

**Q9. A histogram of age is skewed with a long right tail. Usually:**
- A) Mean < median
- B) Mean = median
- C) Mean > median
- D) The median cannot be computed

<details><summary>👀 Show answer</summary>

**Answer: C.** The long right tail pulls the mean up.

</details>

**Q10. Why must you report the denominator (n) with a percentage?**
- A) It makes the table longer
- B) Missing values change what the percentage refers to
- C) R requires it
- D) It is not necessary

<details><summary>👀 Show answer</summary>

**Answer: B.** The denominator defines what the percentage means.

</details>

**Q11. A boxplot shows points beyond the whiskers. These are:**
- A) Always errors that must be deleted
- B) Potential outliers to inspect
- C) The mean
- D) The confidence interval

<details><summary>👀 Show answer</summary>

**Answer: B.** Inspect them first, since they can be real biology.

</details>

---

## 🔔 Section 4. Normality and choosing a test

**Q12. Which test checks whether data are approximately normal?**
- A) Shapiro-Wilk
- B) Log-rank
- C) Chi-square
- D) Fisher

<details><summary>👀 Show answer</summary>

**Answer: A.** Shapiro-Wilk tests normality.

</details>

**Q13. With thousands of patients, Shapiro-Wilk almost always gives p < 0.05. What should you do?**
- A) Ignore plots completely
- B) Also look at a Q-Q plot and histogram
- C) Delete patients until p > 0.05
- D) Use a pie chart

<details><summary>👀 Show answer</summary>

**Answer: B.** Large n makes tiny deviations significant, so check the plots too.

</details>

**Q14. Which plot best checks normality visually?**
- A) Q-Q plot
- B) Pie chart
- C) Kaplan-Meier curve
- D) Heat map

<details><summary>👀 Show answer</summary>

**Answer: A.** Points close to the line suggest normality.

</details>

---

## ⚖️ Section 5. Comparing two groups

**Q15. Compare age between Alive and Dead patients, with roughly normal data and unequal variances. Which test?**
- A) Paired t-test
- B) Welch t-test
- C) Chi-square
- D) Cox model

<details><summary>👀 Show answer</summary>

**Answer: B.** Welch does not assume equal variances.

</details>

**Q16. The same comparison, but the data are clearly skewed. Which test?**
- A) Wilcoxon rank-sum
- B) Paired t-test
- C) ANOVA
- D) Pearson

<details><summary>👀 Show answer</summary>

**Answer: A.** It is rank-based and needs no normality assumption.

</details>

**Q17. The same patients are measured before and after treatment. Which test family applies?**
- A) Independent-samples tests
- B) Paired tests
- C) Chi-square
- D) Log-rank

<details><summary>👀 Show answer</summary>

**Answer: B.** Paired data are not independent.

</details>

**Q18. Cohen's *d* = -0.41 means:**
- A) A small-to-moderate difference between group means
- B) The p-value is 0.41
- C) 41% of patients died
- D) No difference

<details><summary>👀 Show answer</summary>

**Answer: A.** The group means differ by about 0.4 standard deviations.

</details>

---

## 🧮 Section 6. Three or more groups

**Q19. Compare mean age across Stage I, II, III and IV. Which test, if assumptions hold?**
- A) One-way ANOVA
- B) Paired t-test
- C) Fisher
- D) Spearman

<details><summary>👀 Show answer</summary>

**Answer: A.** One-way ANOVA compares 3 or more means.

</details>

**Q20. If the ANOVA assumptions fail, the best alternative is:**
- A) Kruskal-Wallis
- B) Shapiro-Wilk
- C) Log-rank
- D) A pie chart

<details><summary>👀 Show answer</summary>

**Answer: A.** It is the rank-based multi-group alternative.

</details>

**Q21. A significant Kruskal-Wallis result is followed by:**
- A) Dunn's post-hoc test with p-value adjustment
- B) Nothing, you are finished
- C) A paired t-test without correction
- D) A histogram

<details><summary>👀 Show answer</summary>

**Answer: A.** It finds which pairs differ, with multiple-testing correction.

</details>

**Q22. Why do we adjust p-values in many pairwise comparisons?**
- A) To make p-values smaller
- B) To control the rising chance of false positives
- C) To increase sample size
- D) To remove outliers

<details><summary>👀 Show answer</summary>

**Answer: B.** Many tests inflate the false-positive rate.

</details>

---

## 🔗 Section 7. Relationships and associations

**Q23. Age versus TP53 expression: the relationship is monotone but not linear. Which correlation?**
- A) Pearson
- B) Spearman
- C) Cramer's V
- D) Hazard ratio

<details><summary>👀 Show answer</summary>

**Answer: B.** Spearman captures monotone rank association.

</details>

**Q24. A correlation of r = 0.05 with p < 0.001 in 9,000 patients suggests:**
- A) A strong relationship
- B) Statistically detectable but practically tiny
- C) Causation
- D) A data error

<details><summary>👀 Show answer</summary>

**Answer: B.** Large n detects tiny effects, so always check the effect size.

</details>

**Q25. Is vital status (Alive/Dead) associated with gender? Which test?**
- A) t-test
- B) Chi-square test
- C) Pearson correlation
- D) Kaplan-Meier

<details><summary>👀 Show answer</summary>

**Answer: B.** Both variables are categorical.

</details>

**Q26. Some expected cell counts in a 2x2 table are below 5. Use:**
- A) Fisher's exact test
- B) Welch t-test
- C) ANOVA
- D) Log-rank

<details><summary>👀 Show answer</summary>

**Answer: A.** Fisher's test is exact and suits sparse tables.

</details>

---

## ⏳ Section 8. Survival analysis

**Q27. Why is `Vital_Status` alone not enough for a survival curve?**
- A) It has too many levels
- B) It lacks follow-up time
- C) It is numeric
- D) It has no missing values

<details><summary>👀 Show answer</summary>

**Answer: B.** Survival analysis needs time plus an event indicator.

</details>

**Q28. Patients still alive at last follow-up are called:**
- A) Outliers
- B) Censored
- C) Controls
- D) Duplicates

<details><summary>👀 Show answer</summary>

**Answer: B.** We know they survived at least that long, but not their final outcome.

</details>

**Q29. Which test compares Kaplan-Meier curves between two or more groups?**
- A) Shapiro-Wilk
- B) Log-rank test
- C) Wilcoxon paired
- D) ANOVA

<details><summary>👀 Show answer</summary>

**Answer: B.** The log-rank test compares survival curves.

</details>

**Q30. A Cox model gives HR = 1.5 for a variable. The interpretation is:**
- A) 50% lower hazard
- B) 50% higher hazard of the event
- C) No effect
- D) Survival is 1.5 years longer

<details><summary>👀 Show answer</summary>

**Answer: B.** An HR above 1 means a higher hazard.

</details>

---

## 📈 Score yourself

| Score | Level |
|-------|-------|
| 27-30 | 🏆 Excellent |
| 21-26 | 👍 Good |
| 15-20 | 📘 Review weak sections |
| < 15 | 🔁 Re-read the tutorial |
