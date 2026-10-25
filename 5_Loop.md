# 🔁 Loops in R: for, while, repeat, and Better Alternatives

A complete beginner tutorial. Every example runs on its own, and the R script `Loops_in_R.R` contains all the code.

---

## 📑 Table of Contents

1. [What is a Loop?](#-1-what-is-a-loop)
2. [The for Loop](#-2-the-for-loop)
3. [Looping Over Different Things](#-3-looping-over-different-things)
4. [break and next](#-4-break-and-next)
5. [if / else Inside a Loop](#-5-if--else-inside-a-loop)
6. [Storing Results (Pre-allocation)](#-6-storing-results-pre-allocation)
7. [Looping Over Data Frame Rows](#-7-looping-over-data-frame-rows)
8. [The while Loop](#-8-the-while-loop)
9. [The repeat Loop](#-9-the-repeat-loop)
10. [for vs while vs repeat](#-10-for-vs-while-vs-repeat)
11. [Better Than Loops: Vectorization and apply](#-11-better-than-loops-vectorization-and-apply)
12. [Speed Comparison](#-12-speed-comparison)
13. [Common Mistakes](#-13-common-mistakes)
14. [Which One Should I Use?](#-14-which-one-should-i-use)
15. [Conclusion](#-15-conclusion)
16. [Quiz](#-16-quiz)

---

## 📌 1. What is a Loop?

A **loop** repeats a block of code several times, so you do not have to copy and paste the same lines.

R has three loop types:

| Loop | Use it when |
|---|---|
| `for` | You know **how many times** (or over **which items**) to repeat |
| `while` | You repeat **until a condition becomes FALSE** |
| `repeat` | You repeat **forever** until you call `break` |

---

## 🔢 2. The for Loop

**Write the code in the Editor:**

```r
for (i in 1:5) {
  print(i)
}
```

**Output:**

```
[1] 1
[1] 2
[1] 3
[1] 4
[1] 5
```

**Interpretation:**
The counter `i` takes each value of `1:5` in turn, and R runs everything between `{ }` once per value.

- `i` is only a convention (short for *iteration*). Any name works.
- **Nested loops** need different counter names.
- The loop always runs through the **whole sequence** (unless you use `break`).

### Counting down and changing the counter

```r
# Count down (the last number IS included in R)
for (i in 5:1) {
  print(i)
}
```
**Output**
```r
#[1] 1
#[1] 2
#[1] 3
#[1] 4
#[1] 5
```

```r
# Use the counter in a calculation
for (i in 1:5) {
  print(i + 1)
}
```
**Output**
```r
# [1] 2
# [1] 3
# [1] 4
# [1] 5
# [1] 6
```


> ⚠️ **Empty sequences:** `1:length(x)` goes wrong when `x` is empty (it gives `1, 0`). Use `seq_along(x)` instead, which gives nothing for an empty vector.

---

## 🧺 3. Looping Over Different Things

You can loop over **positions** or over the **values themselves**.

```r
fruits <- c("apple", "banana", "cherry")

# Loop over the values
for (x in fruits) {
  print(x)
}
```


**Output:**
```
#[1] "apple"
#[1] "banana"
#[1] "cherry"

```

```r
# Loop over positions (needed when you want the index)
for (i in seq_along(fruits)) {
  print(paste(i, "=", fruits[i]))
}
```

**Output:**

```
#[1] "1 = apple"
#[1] "2 = banana"
#[1] "3 = cherry"
```

**Interpretation:**
Use `for (x in vector)` when you only need the values, and `for (i in seq_along(vector))` when you also need the position.

---

## ⛔ 4. break and next

```r
fruits <- c("apple", "banana", "cherry")

# break: stop the loop completely
for (x in fruits) {
  if (x == "cherry") {
    break
  }
  print(x)
}
```

```r
#[1] "apple"
#[1] "banana"
```

```
# next: skip this iteration, continue with the next
for (x in fruits) {
  if (x == "banana") {
    next
  }
  print(x)
}
```

**Output:**

```r
#[1] "apple"
#[1] "cherry"
```

| Keyword | Effect |
|---|---|
| `break` | Ends the loop immediately |
| `next` | Skips the rest of this pass and moves to the next value |

---

## 🔀 5. if / else Inside a Loop

```r
dice <- 1:6

for (x in dice) {
  if (x == 6) {
    print(paste("The dice number is", x, "- Yahtzee!"))
  } else {
    print(paste("The dice number is", x, "- Not Yahtzee"))
  }
}
```

**Output:**
```r
# [1] "The dice number is 1 - Not Yahtzee"
# [1] "The dice number is 2 - Not Yahtzee"
# [1] "The dice number is 3 - Not Yahtzee"
# [1] "The dice number is 4 - Not Yahtzee"
# [1] "The dice number is 5 - Not Yahtzee"
# [1] "The dice number is 6 - Yahtzee!"
```

**Interpretation:**
`if` / `else` lets each pass make a **decision**. The `else` part is optional.

---

## 📦 6. Storing Results (Pre-allocation)

A loop usually needs somewhere to **save its output**. Create the container first, with the right size, then fill it.

```r
# Square the numbers 1 to 5
squares <- numeric(5)          # empty numeric vector of length 5

for (i in 1:5) {
  squares[i] <- i^2
}

squares
```

**Output:**

```
[1]  1  4  9 16 25
```

> ⚠️ **Do not grow a vector inside a loop** with `x <- c(x, new_value)`. R copies the whole vector every time, which becomes very slow for large loops. Pre-allocate with `numeric(n)`, `character(n)`, or `vector("list", n)`.

### Storing in a list

```r
results <- vector("list", 3)

for (i in 1:3) {
  results[[i]] <- i * 10
}

results
```


**Output**
```r
# [[1]]
# [1] 10
#
# [[2]]
# [1] 20
#
# [[3]]
# [1] 30
```


---

## 🧾 7. Looping Over Data Frame Rows

**Create the example data:**

```r
set.seed(123)
patients <- data.frame(
  ID     = 1:8,
  Age    = c(45, 67, 59, 72, 38, 81, 55, 63),
  Weight = round(rnorm(8, mean = 70, sd = 10), 1)
)
patients
```

```r
# ID Age Weight
# 1  1  45   64.4
# 2  2  67   67.7
# 3  3  59   85.6
# 4  4  72   70.7
# 5  5  38   71.3
# 6  6  81   87.2
# 7  7  55   74.6
# 8  8  63   57.3
```




### Example: classify each patient by age

```r
patients $ Group <- NA                       # create the empty column first

for (i in 1:nrow(patients)) {
  if (patients $ Age[i] >= 65) {
    patients $ Group[i] <- "Older"
  } else {
    patients $ Group[i] <- "Younger"
  }
}

patients
```


```r
# patients
#   ID Age Weight   Group
# 1  1  45   64.4 Younger
# 2  2  67   67.7   Older
# 3  3  59   85.6 Younger
# 4  4  72   70.7   Older
# 5  5  38   71.3 Younger
# 6  6  81   87.2   Older
# 7  7  55   74.6 Younger
# 8  8  63   57.3 Younger
```

**Interpretation:**
1. `nrow(patients)` gives the number of rows, so the loop visits every patient.
2. `patients$Age[i]` reads row `i`, and the result is **assigned back** into row `i`.
3. Always **work on a copy** of important data, so a mistake never damages the original.

> 💡 **Check your loop.** Compare the loop result to a result you trust, for example `table(patients$Group)` or the vectorized version in Section 11.

---

## ⏳ 8. The while Loop

A `while` loop keeps running **as long as its condition is TRUE**. You use it when you do **not know in advance** how many repeats are needed.

```r
i <- 0
while (i < 5) {
  i <- i + 1
  print(i)
}
```

**Output:**

```
#[1] 1
#[1] 2
#[1] 3
#[1] 4
#[1] 5
```

**Interpretation:**
Before each pass R checks `i < 5`. When it becomes FALSE, the loop stops.

> ⚠️ **Infinite loop danger:** something inside the loop **must change** the condition (here `i <- i + 1`). If not, the loop never ends. In RStudio, press **Esc** (or the red stop button) to cancel.

### A practical while example

How many years until an investment doubles at 7% growth?

```r
money <- 1000
years <- 0

while (money < 2000) {
  money <- money * 1.07
  years <- years + 1
}

years
round(money, 2)
```

**Output:**

```
#[1] 11
#[1] 2104.85
```

**Interpretation:**
We could not use a `for` loop here, because we did not know the number of years beforehand. We only knew the **stopping condition** (reach 2000).

---

## ♾️ 9. The repeat Loop

A `repeat` loop has **no condition**. It runs forever until you tell it to `break`.

```r
count <- 0

repeat {
  count <- count + 1
  print(count)
  if (count == 3) {
    break
  }
}
```

**Output:**

```
#[1] 1
#[1] 2
#[1] 3
```

**Interpretation:**
`repeat` is useful when the stopping check belongs in the **middle** of the loop. It is rarely needed. A `while` loop does the same job in most cases.

---

## ⚖️ 10. for vs while vs repeat

| Feature | `for` | `while` | `repeat` |
|---|---|---|---|
| Number of repeats | **Known** in advance | **Unknown** | **Unknown** |
| Stops when | Sequence ends | Condition becomes FALSE | You call `break` |
| Condition checked | No condition (a sequence) | **Before** each pass | Only where you write it |
| Risk of infinite loop | Very low | **Medium** | **High** |
| Typical use | Go through items or rows | Repeat until a goal is met | Rare, custom stopping |
| Counter managed by R? | **Yes** (automatic) | **No** (you update it) | **No** (you update it) |

### The same task in all three loops

Print the numbers 1 to 3:

```r
# for
for (i in 1:3) {
  print(i)
}
```
```r
# [1] 1
# [1] 2
# [1] 3
```

```r
# while
i <- 1
while (i <= 3) {
  print(i)
  i <- i + 1
}
```
```r
# [1] 1
# [1] 2
# [1] 3
```

```r
# repeat
i <- 1
repeat {
  print(i)
  i <- i + 1
  if (i > 3) break
}
```

```r
# [1] 1
# [1] 2
# [1] 3
```

**Interpretation:**
All three give the same output, but notice the differences. The `for` loop is the shortest and safest, because R manages the counter. The `while` and `repeat` loops need you to **set up and update the counter yourself**.

### Rule of thumb

- **Know the items or count?** Use `for`.
- **Know only the stopping goal?** Use `while`.
- **Need to stop from inside?** Use `repeat` with `break`.

---

## 🚀 11. Better Than Loops: Vectorization and apply

In R, many tasks do **not need a loop**. Vectorized code is shorter, faster, and less error-prone.

### Vectorization

```r
x <- 1:5

# Loop version
squares <- numeric(5)
for (i in 1:5) squares[i] <- x[i]^2

# Vectorized version (no loop)
squares <- x^2
squares
```

The classification from Section 7 also needs no loop:

```r
patients $ Group2 <- ifelse(patients $ Age >= 65, "Older", "Younger")
```

### The apply family

```r
# lapply returns a list
lapply(1:3, function(a) a * 10)

# sapply returns a vector
sapply(1:3, function(a) a * 10)

# apply works on rows (1) or columns (2) of a matrix or data frame
apply(patients[, c("Age", "Weight")], 2, mean)
```

**Output of `sapply`:**

```
[1] 10 20 30
```

| Function | Returns | Use for |
|---|---|---|
| `lapply()` | List | Run a function on each element |
| `sapply()` | Vector (simplified) | Same, but a tidy vector |
| `apply()` | Vector or matrix | Rows or columns of a matrix |
| `tapply()` | Vector | A function by group |

> 💡 **Habit to build:** after writing a loop, ask yourself if a vectorized line or `sapply()` can do the same job.

---

## ⏱️ 12. Speed Comparison

```r
n <- 1e6
x <- runif(n)

# Loop
system.time({
  out <- numeric(n)
  for (i in 1:n) out[i] <- x[i] * 2
})

# Vectorized
system.time({
  out2 <- x * 2
})
```

**Typical output (your numbers will differ):**

```
   user  system elapsed 
  0.040   0.000   0.040     # loop
   user  system elapsed 
  0.002   0.000   0.002     # vectorized
```

**Interpretation:**
The vectorized version is usually many times faster. For small data the difference is invisible, but it matters for large datasets.

---

## ⚠️ 13. Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| `for (i in 1:length(x))` with empty `x` | Runs with `i = 1, 0` | Use `seq_along(x)` |
| Growing a vector with `c()` in a loop | Very slow | Pre-allocate with `numeric(n)` |
| Forgetting to update the `while` counter | Infinite loop | Change the condition inside the loop |
| Editing the original data in a loop | Hard to undo | Work on a copy |
| Missing values in `if (x == 1)` | Error: missing value where TRUE/FALSE needed | Use `!is.na(x) && x == 1` |
| Using the same counter in nested loops | Loops interfere | Use different names (`i`, `j`) |
| Using a loop when `x * 2` works | Slower, longer code | Vectorize |

---

## 🧭 14. Which One Should I Use?

```
Can the task be done with a vectorized function or sapply()?
   YES -> Use that (shortest, fastest)
   NO  -> Do you know how many times or which items?
            YES -> for loop
            NO  -> Do you know a stopping condition?
                     YES -> while loop
                     NO  -> repeat loop with break
```

---

## ✅ 15. Conclusion

- A **for** loop repeats over a known sequence, and R manages the counter.
- A **while** loop repeats until a condition becomes FALSE, so you manage the counter.
- A **repeat** loop runs until you `break`, and is rarely needed.
- Use `break` to stop and `next` to skip.
- **Pre-allocate** result containers and use `seq_along()` for safe indexing.
- Prefer **vectorization** and **apply** functions when possible, and always check your loop against a result you trust.

---

## 🧠 16. Quiz

### Part A: Multiple choice

**Q1. Which loop is best when you know exactly how many times to repeat?**

- A. `while`
- B. `for`
- C. `repeat`
- D. `if`

<details><summary>Show answer</summary>

**B.** The `for` loop runs over a known sequence.

</details>

**Q2. What does `next` do?**

- A. Stops the whole loop
- B. Skips the current iteration and continues
- C. Restarts the loop
- D. Prints the next value

<details><summary>Show answer</summary>

**B.** `break` stops the loop, while `next` only skips one pass.

</details>

**Q3. What happens if you forget `i <- i + 1` in a `while (i < 5)` loop?**

- A. It runs once
- B. It gives an error
- C. It runs forever (infinite loop)
- D. It runs 5 times

<details><summary>Show answer</summary>

**C.** The condition never changes, so it never becomes FALSE.

</details>

**Q4. Why is `seq_along(x)` safer than `1:length(x)`?**

- A. It is faster
- B. It handles empty vectors correctly
- C. It sorts the vector
- D. It removes NA values

<details><summary>Show answer</summary>

**B.** For an empty `x`, `1:length(x)` gives `1, 0`, but `seq_along(x)` gives nothing.

</details>

**Q5. Which function returns a list?**

- A. `sapply()`
- B. `lapply()`
- C. `apply()`
- D. `sum()`

<details><summary>Show answer</summary>

**B.** `lapply()` returns a list, and `sapply()` simplifies to a vector.

</details>

### Part B: Short answer

**Q6. Which loop would you choose to find how many years until money doubles, and why?**

<details><summary>Show answer</summary>

A `while` loop, because the number of years is unknown. Only the stopping condition (money reaches the target) is known.

</details>

**Q7. Why pre-allocate a result vector before a loop?**

<details><summary>Show answer</summary>

Growing a vector with `c()` copies it on every pass, which is slow. Pre-allocating (`numeric(n)`) creates it once at the right size.

</details>

**Q8. Rewrite this loop without a loop: `for (i in 1:5) y[i] <- x[i] * 2`**

<details><summary>Show answer</summary>

`y <- x * 2`. Arithmetic in R is vectorized.

</details>

**Q9. What is the difference between `lapply()` and `sapply()`?**

<details><summary>Show answer</summary>

`lapply()` always returns a list, while `sapply()` tries to simplify the result to a vector or matrix.

</details>

**Q10. Name one situation where a loop is still a good choice.**

<details><summary>Show answer</summary>

When each step depends on the previous one (simulations, recursive calculations), or when you need a `while` loop with an unknown number of repeats.

</details>
