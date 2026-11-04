<div align="center" style="width:60%;margin:0 auto">

# 🎨 Color Palettes in R: From Basic Colors to Publication-Ready Figures

</div>

> A step-by-step tutorial: start with basic R colors, learn `ggplot2` and `ggsci`, then choose palettes that suit different journals and fields.

---

## 📑 Table of Contents

1. [Setup](#1-setup)
2. [Basic colors in R](#2-basic-colors-in-r)
3. [Colors in base R plots](#3-colors-in-base-r-plots)
4. [Colors in ggplot2](#4-colors-in-ggplot2)
5. [Introducing ggsci](#5-introducing-ggsci)
6. [Journal palettes](#6-journal-palettes)
7. [Palettes for other fields](#7-palettes-for-other-fields)
8. [Continuous palettes](#8-continuous-palettes)
9. [Choosing a palette for a publication](#9-choosing-a-palette-for-a-publication)
10. [Checking your palette](#10-checking-your-palette)
11. [Quick reference](#11-quick-reference)

---

## 1. Setup

Install the packages once:

```r
install.packages(c("ggplot2", "ggsci", "scales", "RColorBrewer", "viridis", "colorspace"))
```

Load them in each session:

```r
library(ggplot2)
library(ggsci)
library(scales)
library(RColorBrewer)
library(viridis)
library(colorspace)
```

We'll use the built-in `mpg` dataset (fuel economy of cars) throughout:

```r
head(mpg)
```

---

## 2. Basic colors in R

R knows about 657 named colors. Use a name directly, or a hex code such as `"#E64B35"`.

```r
# The first ten named colors
head(colors(), 10)

# How a named color is stored as red, green, and blue values
col2rgb("steelblue")
```

Preview colors with `show_col()` from `scales`:

```r
show_col(c("firebrick", "steelblue", "forestgreen", "gold"))
```

A palette is just a vector of colors:

```r
my_colors <- c("#1B9E77", "#D95F02", "#7570B3")
show_col(my_colors)
```

Base R can also generate palettes of any length:

```r
rainbow(5)
heat.colors(5)
```

> ⚠️ `rainbow()` is hard to read in black and white and not colour-blind safe. Avoid it for publication figures.

---

## 3. Colors in base R plots

Base R uses `col` for points, lines, and bars.

```r
counts <- table(mpg$class)

barplot(
  counts,
  col = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A",
          "#66A61E", "#E6AB02", "#A6761D"),
  las = 2,
  main = "Cars by class"
)
```

---

## 4. Colors in ggplot2

In `ggplot2`, color is mapped to a variable with `aes()`. The scale function controls which colors are used.

```r
# Fill a bar chart by class
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() +
  theme_minimal(base_size = 12) +
  labs(title = "Default ggplot2 colors", x = NULL, y = "Count") +
  theme(legend.position = "none")
```

Set colors by hand with `scale_fill_manual()`:

```r
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() +
  scale_fill_manual(values = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A",
                               "#66A61E", "#E6AB02", "#A6761D")) +
  theme_minimal(base_size = 12) +
  labs(title = "Hand-picked colors", x = NULL, y = "Count") +
  theme(legend.position = "none")
```

The general pattern:

| Data type | Function |
|---|---|
| Categories (fill) | `scale_fill_manual()` |
| Categories (points/lines) | `scale_colour_manual()` |
| Continuous gradient | `scale_colour_gradient()` |

---

## 5. Introducing ggsci

`ggsci` provides palettes inspired by scientific journals, data-visualisation tools, and some sci-fi and TV shows. Each palette has a **scale** function for ggplot2 and a **generator** function (`pal_*()`) for raw hex codes.

```r
# Scale functions for ggplot2
scale_fill_npg()
scale_colour_npg()

# Generator function: returns hex codes
pal_npg()(9)
```

Naming pattern:

```r
scale_colour_<palette>()   # points, lines
scale_fill_<palette>()     # bars, areas, tiles
pal_<palette>()(n)         # hex codes
```

Compare the NPG palette against the default:

```r
p_default <- ggplot(mpg, aes(class, fill = class)) +
  geom_bar() +
  theme_minimal(base_size = 12) +
  labs(title = "Default", x = NULL, y = "Count") +
  theme(legend.position = "none")

p_npg <- p_default +
  scale_fill_npg() +
  labs(title = "NPG (ggsci)")

p_default
p_npg
```

---

## 6. Journal palettes

Each journal palette is named after the publication. These are the most common:

```r
# Nature Publishing Group
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_npg() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "NPG", x = NULL, y = "Count")

# AAAS (Science)
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_aaas() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "AAAS", x = NULL, y = "Count")

# NEJM
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_nejm() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "NEJM", x = NULL, y = "Count")

# Lancet
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_lancet() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "Lancet", x = NULL, y = "Count")

# JAMA
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_jama() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "JAMA", x = NULL, y = "Count")
```

Compare the palettes side by side:

```r
show_col(pal_npg()(7),    labels = FALSE)
show_col(pal_aaas()(7),   labels = FALSE)
show_col(pal_nejm()(7),   labels = FALSE)
show_col(pal_lancet()(7), labels = FALSE)
show_col(pal_jama()(7),   labels = FALSE)
```

> ⚠️ Journal palettes are chosen for look, not accessibility. Check colour-blind safety before submission (see [Section 10](#10-checking-your-palette)).

---

## 7. Palettes for other fields

`ggsci` also includes palettes from data-visualisation tools and genomics:

```r
# D3.js (categorical)
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_d3() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "D3", x = NULL, y = "Count")

# UCSC Genome Browser (genomics)
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_ucscgb() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "UCSC Genome Browser", x = NULL, y = "Count")

# UChicago
ggplot(mpg, aes(class, fill = class)) +
  geom_bar() + scale_fill_uchicago() +
  theme_minimal(base_size = 12) + theme(legend.position = "none") +
  labs(title = "UChicago", x = NULL, y = "Count")
```

Some palettes have variants. For example, D3 has several sets of categories:

```r
pal_d3("category10")(10)
pal_d3("category20")(20)
```

---

## 8. Continuous palettes

For numeric data, use a gradient. The `viridis` palettes are perceptually uniform and colour-blind friendly.

```r
ggplot(mpg, aes(displ, hwy, colour = cty)) +
  geom_point(size = 3) +
  scale_colour_viridis_c() +
  theme_minimal(base_size = 12) +
  labs(title = "Sequential gradient (viridis)",
       x = "Engine displacement (L)", y = "Highway MPG", colour = "City MPG")
```

For data with a meaningful midpoint, use a diverging gradient:

```r
ggplot(mpg, aes(displ, hwy, colour = hwy - mean(hwy))) +
  geom_point(size = 3) +
  scale_colour_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0) +
  theme_minimal(base_size = 12) +
  labs(title = "Diverging gradient",
       x = "Engine displacement (L)", y = "Highway MPG", colour = "Difference from mean")
```

> ⚠️ Use a diverging palette only when the data has a natural centre (such as zero or a mean). Otherwise use a sequential palette.

---

## 9. Choosing a palette for a publication

Match the palette to your data and the target venue:

| Your data | Suggested palette | Why |
|---|---|---|
| Categories, medical journal | `scale_fill_nejm()` or `scale_fill_jama()` | Journal style |
| Categories, general science | `scale_fill_npg()` or `scale_fill_aaas()` | Journal style |
| Categories, colour-blind safe | Okabe-Ito (see Section 10) | Accessible for all readers |
| Numeric, sequential | `scale_colour_viridis_c()` | Uniform, prints well |
| Numeric, diverging | `scale_colour_gradient2()` | Clear midpoint |
| Genomics | `scale_fill_ucscgb()` or `scale_fill_igv()` | Familiar to the field |

**General tips:**

- **Check the journal's guidelines.** Some require greyscale-safe figures or specific colour modes.
- **Keep it consistent.** Use the same colour for the same category across all figures in a paper.
- **Limit the number of colours.** Most readers can separate about 6 to 8 categories. Beyond that, combine small groups or use facets.

---

## 10. Checking your palette

**Greyscale check** (will the categories still differ when printed in black and white?):

```r
pal <- pal_npg()(7)
show_col(pal)
show_col(colorspace::desaturate(pal))
```

**Colour-blind check.** Not all `ggsci` palettes are colour-blind safe. For a safe choice, use the Okabe-Ito palette:

```r
okabe_ito <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442",
  "#0072B2", "#D55E00", "#CC79A7", "#000000"
)

show_col(okabe_ito)

ggplot(mpg, aes(class, fill = class)) +
  geom_bar() +
  scale_fill_manual(values = okabe_ito) +
  theme_minimal(base_size = 12) +
  labs(title = "Okabe-Ito (colour-blind safe)", x = NULL, y = "Count") +
  theme(legend.position = "none")
```

---

## 11. Quick reference

| Goal | Code |
|---|---|
| See a palette | `show_col(pal_npg()(9))` |
| Journal fill | `+ scale_fill_npg()` |
| Journal colour | `+ scale_colour_npg()` |
| Manual colours | `+ scale_fill_manual(values = c(...))` |
| Continuous gradient | `+ scale_colour_viridis_c()` |
| Diverging gradient | `+ scale_colour_gradient2(midpoint = 0)` |
| Colour-blind safe | `+ scale_fill_manual(values = okabe_ito)` |
| Greyscale check | `show_col(colorspace::desaturate(pal))` |

---

### Notes

- Confirm the function names against your installed version with `ls("package:ggsci")`, since the package changes over time.
- Check each target journal's author guidelines before submission.
- I have not run this code in an R session. Run it once from top to bottom to catch version differences.
