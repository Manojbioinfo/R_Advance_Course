# 🎨 The Complete Guide to Color Palettes in R

> A practical, copy-paste-ready tutorial: from base R colors to `ggplot2`, `RColorBrewer`, `viridis`, `scico`, `paletteer`, and the full `ggsci` collection.

---


### 🌈 General Color Inspiration

| Resource | Description | Link |
| :--- | :--- | :--- |
| **Coolors: 2-Color Palettes** | Trending two-color combinations. | [Open →](https://coolors.co/palettes/trending/2%20colors) |
| **Coolors: 3-Color Palettes** | Trending three-color combinations. | [Open →](https://coolors.co/palettes/trending/3%20colors) |
| **Coolors: Halloween** | Popular Halloween palettes. | [Open →](https://coolors.co/palettes/popular/halloween) |
| **Coolors: Christmas** | Popular Christmas palettes. | [Open →](https://coolors.co/palettes/popular/christmas) |
| **Adobe Color Wheel** | Build palettes with color harmony rules. | [Open →](https://color.adobe.com/create/color-wheel) |
| **2Colors (Colorion)** | Curated two-color combinations, duotone palettes, and contrast-ready pairs for UI/UX design. | [Open →](https://2colors.colorion.co/) |



## 📊 R Color Palettes & Color Codes

| Resource | Description | Link |
| :--- | :--- | :--- |
| **R-Charts Color Guide** | Complete list of 657 named colors in R with HEX and RGB codes, with one-click copy. | [Open R-Charts →](https://r-charts.com/colors/) |
| **Emil Hvitfeldt R Palettes** | Comprehensive interactive gallery of color palettes across the entire R ecosystem (ggplot2, paletteer). | [Explore Palettes →](https://emilhvitfeldt.github.io/r-color-palettes/) |
| **ColorBrewer 2.0** | Perceptually balanced sequential, diverging, and qualitative palettes for R (`RColorBrewer`). | [Open ColorBrewer →](https://colorbrewer2.org/) |
| **R Graph Gallery Color Finder** | Searchable tool to explore and pick color palettes designed specifically for data visualization in R. | [Open Palette Finder →](https://r-graph-gallery.com/color-palette-finder) |
| **ggsci Documentation** | Official site for scientific journal and sci-fi themed palettes for ggplot2. | [Open ggsci →](https://nanx.me/ggsci/) |
| **ggsci iTerm Preview** | Single-page preview of all 400+ iTerm color schemes available in ggsci. | [Open Preview →](https://nanx.me/ggsci-iterm/) |

---

## 📦 R Packages for Color Palettes

| Package | Description | Palette Types |
| :--- | :--- | :--- |
| **`ggsci`** | Scientific journal, tech-brand, and sci-fi palettes (NPG, AAAS, NEJM, Lancet, JAMA, D3, Star Trek, Futurama, and more). | Discrete + continuous |
| **`RColorBrewer`** | Cartography-grade palettes designed by Cynthia Brewer. | Sequential, diverging, qualitative |
| **`viridis`** | Perceptually uniform palettes: `magma`, `plasma`, `inferno`, `mako`, `rocket`, `turbo`. | Sequential / qualitative |
| **`scico`** | Scientific Colour Maps (`batlow`, `roma`, `bamako`, `hawaii`). | Sequential, diverging, cyclic |
| **`rcartocolor`** | CARTOColors (`PurpOr`, `Temps`, `Prism`). | Sequential, diverging, qualitative |
| **`ggokabeito`** | Okabe-Ito colorblind-safe palette. | Qualitative |
| **`MetBrewer` / `MoMAColors`** | Palettes inspired by works at the Met and MoMA. | All types |
| **`paletteer`** | One interface to access thousands of palettes from many packages. | All types |
| **`wesanderson`, `ghibli`, `tayloRswift`, `NatParksPalettes`** | Fun, themed palettes (movies, music, national parks). | Mostly discrete |

---

## 📑 Table of Contents

1. [The 3 Core Types of Palettes](#1-the-3-core-types-of-palettes)
2. [Base R Colors](#2-base-r-colors)
3. [Defining Your Own Palette](#3-defining-your-own-palette)
4. [RColorBrewer](#4-rcolorbrewer)
5. [viridis](#5-viridis)
6. [scico (Scientific Colour Maps)](#6-scico-scientific-colour-maps)
7. [Okabe-Ito (Colorblind Safe)](#7-okabe-ito-colorblind-safe)
8. [paletteer: One Interface for Everything](#8-paletteer-one-interface-for-everything)
9. [Custom and Corporate Palettes](#9-custom-and-corporate-palettes)
10. [Fun and Artsy Palettes](#10-fun-and-artsy-palettes)
11. [ggsci: Complete Guide](#11-ggsci-complete-guide)
12. [Accessibility Testing](#12-accessibility-testing)
13. [Quick Decision Guide](#13-quick-decision-guide)

---

## 1. The 3 Core Types of Palettes

Before picking colors, identify what kind of data you have.

| Type | Data Nature | Color Behavior | Examples |
| :--- | :--- | :--- | :--- |
| **Sequential** | Low → high values (ordered) | One hue or related hues, light → dark | `Blues`, `YlOrRd`, `viridis` |
| **Diverging** | Values around a meaningful midpoint (negative / zero / positive) | Two contrasting hues meeting at a neutral middle | `RdBu`, `RdYlBu`, `roma` |
| **Qualitative** | Distinct categories, no order | Distinct hues with similar lightness | `Set1`, `Dark2`, Okabe-Ito |

> ⚠️ **Do not use diverging palettes for non-diverging data.** If flipper length ranges from 170 to 230 mm, there is no natural center, so a diverging palette makes the middle value look like a "faded" special point. Use a sequential palette instead.

---

## 2. Base R Colors

In its simplest form, a palette in R is a **vector of colors**, as named colors or hex codes.

```r
# The default palette
palette()
#[1] "black"   "#DF536B" "#61D04F" "#2297E6" "#28E2E5" "#CD0BBC" "#F5C710" "gray62" 
```

<img src="color/Fig_col_1.jpeg" alt="Bar plot of pathologic stage" width="80%">

```r
# Reset to default if you changed it earlier
palette("default")

# All 657 built-in color names
head(colors(), 10)
# [1] "white"         "aliceblue"     "antiquewhite"  "antiquewhite1" "antiquewhite2" "antiquewhite3" "antiquewhite4" "aquamarine"    "aquamarine1"   "aquamarine2"  
```
<img src="color/Fig_col_2.jpeg" alt="Bar plot of pathologic stage" width="80%">


### Built-in gradient palettes (`grDevices`)

```r
rainbow(6)
# [1] "#FF0000" "#FFFF00" "#00FF00" "#00FFFF" "#0000FF" "#FF00FF"
```
<img src="color/Fig_col_3.jpeg" alt="Bar plot of pathologic stage" width="80%">

```r
heat.colors(6)
#[1] "#FF0000" "#FF4000" "#FF8000" "#FFBF00" "#FFFF00" "#FFFF80"
```
<img src="color/Fig_col_4.jpeg" alt="Bar plot of pathologic stage" width="80%">


```r
terrain.colors(6)
#[1] "#00A600" "#63C600" "#E6E600" "#EAB64E" "#EEB99F" "#F2F2F2"
```

<img src="color/Fig_col_5.jpeg" alt="Bar plot of pathologic stage" width="80%">

```r

topo.colors(6)
#[1] "#4C00FF" "#00E5FF" "#00FF4D" "#E6FF00" "#FFFF00" "#FFE0B3"
```
<img src="color/Fig_col_6.jpeg" alt="Bar plot of pathologic stage" width="80%">

```r
cm.colors(6)
#[1] "#80FFFF" "#AAFFFF" "#D5FFFF" "#FFD5FF" "#FFAAFF" "#FF80FF"
```

<img src="color/Fig_col_7.jpeg" alt="Bar plot of pathologic stage" width="80%">

```r

# rainbow() lets you adjust saturation (s) and value (v)
rainbow(6, s = 0.5)
#[1] "#FF8080" "#FFFF80" "#80FF80" "#80FFFF" "#8080FF" "#FF80FF"
```
<img src="color/Fig_col_8.jpeg" alt="Bar plot of pathologic stage" width="80%">

> ⚠️ `rainbow()` is rarely a good choice: it prints poorly in black and white and is hard to read for colorblind viewers (see [Accessibility Testing](#12-accessibility-testing)).

---


## 3. RColorBrewer

Cynthia Brewer designed these palettes for maps, but they work great for any chart.

```r
install.packages("RColorBrewer")
library(RColorBrewer)

# Show every palette
# Top = sequential, middle = qualitative, bottom = diverging
display.brewer.all()

```
<img src="color/Fig_col_9.jpeg" alt="Bar plot of pathologic stage" width="80%">


```r
# Show only colorblind-friendly palettes
display.brewer.all(colorblindFriendly = TRUE)

```

<img src="color/Fig_col_10.jpeg" alt="Bar plot of pathologic stage" width="80%">



## 4. Using Color Palettes for Publication-Ready Images

```r
data=read.csv("Data/LUAD_clean_data_all_patients.csv")
head(data)
```

```r

#            ID Age Gender     Race Vital_Status Pathologic_stage Cigarettes_per_day Age_Group
# 1 TCGA-55-A48X  63 Female European        Alive        Stage IIA          1.9726027     Young
# 2 TCGA-NJ-A55R  67   Male European        Alive         Stage IA          0.2739726       Old
# 3 TCGA-53-A4EZ  63   Male European        Alive        Stage IIA          2.1917808     Young
# 4 TCGA-44-6777  85 Female European         Dead         Stage IB          3.5068493       Old
# 5 TCGA-55-6982  79 Female European         Dead        Stage IIB          0.0000000       Old
# 6 TCGA-50-7109  60   Male European         Dead         Stage IA          6.5753425     Young

```

```r
# Factors are needed so the colors map to the categories
data$Pathologic_stage <- factor(data$Pathologic_stage)
data$Age_Group        <- factor(data$Age_Group)

# How many colors do we need?
n_stage <- nlevels(data$Pathologic_stage)
n_age   <- nlevels(data$Age_Group)
```

```r
n_stage
#[1] 9
n_age
#[1] 2
```
```r
stage_cols <- brewer.pal(max(3, n_stage), "Set2")[1:n_stage]

barplot(table(data$Pathologic_stage),
        col  = stage_cols,
        main = "Pathologic Stage Distribution",
        ylab = "Number of patients",
        las  = 2)
```

```r
age_cols <- brewer.pal(max(3, n_age), "Dark2")[1:n_age]

barplot(table(data$Age_Group),
        col  = age_cols,
        main = "Age Group Distribution",
        ylab = "Number of patients")

```

## 🔗 Further Reading

* [Emil Hvitfeldt's Comprehensive List of R Palettes](https://emilhvitfeldt.github.io/r-color-palettes/)
* [`paletteer` on GitHub](https://github.com/EmilHvitfeldt/paletteer)
* [ggsci documentation](https://nanx.me/ggsci/)
* [R Graph Gallery Color Finder](https://r-graph-gallery.com/color-palette-finder)
* [ColorBrewer 2.0](https://colorbrewer2.org/)
* [Viz Palette](https://projects.susielu.com/viz-palette) for testing palettes in context
