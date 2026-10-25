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

# Show only colorblind-friendly palettes
display.brewer.all(colorblindFriendly = TRUE)

```

### In ggplot2

```r
# Discrete
scale_fill_brewer(palette = "Set1")
scale_color_brewer(palette = "Dark2")

# Continuous
scale_color_distiller(palette = "YlOrRd")              # sequential
scale_color_distiller(palette = "RdBu", direction = 1) # diverging
```

| Type | Popular palettes |
| :--- | :--- |
| Sequential | `Blues`, `Greens`, `YlOrRd`, `RdPu`, `Purples` |
| Diverging | `RdBu`, `RdYlBu`, `PuOr`, `BrBG`, `Spectral` |
| Qualitative | `Set1`, `Set2`, `Set3`, `Dark2`, `Paired`, `Pastel1` |

Interactive helper: [colorbrewer2.org](https://colorbrewer2.org/) (filter by colorblind-safe, print-friendly, and photocopy-safe).

---

## 4. viridis

Perceptually uniform, colorblind-friendly, and prints well in grayscale. Included with `ggplot2`.

| Option | Look |
| :--- | :--- |
| `viridis` (default) | Purple → green → yellow |
| `magma` | Black → purple → cream |
| `inferno` | Black → red → yellow |
| `plasma` | Blue → pink → yellow |
| `cividis` | Blue → yellow (optimized for colorblind) |
| `mako` | Dark blue → teal → mint |
| `rocket` | Black → red → cream |
| `turbo` | Improved rainbow |

```r
# Discrete (categories)
plot_qualitative + scale_fill_viridis_d(option = "plasma")

# Continuous (numeric)
plot_sequential + scale_color_viridis_c(option = "inferno")

# Reverse direction
scale_color_viridis_c(option = "mako", direction = -1)
```

> 💡 None of the viridis palettes are diverging. They work for **sequential** and **qualitative** data.

---

## 5. scico (Scientific Colour Maps)

The `scico` package provides palettes from the Scientific Colour Maps project, with sequential, diverging, multi-sequential, and cyclic options.

```r
install.packages("scico")
library(scico)

# Discrete
plot_qualitative + scale_fill_scico_d(palette = "batlow")

# Continuous
plot_sequential + scale_color_scico_c(palette = "bamako")

# Diverging
plot_sequential + scale_color_scico_c(palette = "roma")
```

| Type | Popular palettes |
| :--- | :--- |
| Sequential | `batlow`, `bamako`, `hawaii`, `lajolla`, `oslo` |
| Diverging | `roma`, `broc`, `berlin`, `vik`, `cork` |
| Cyclic | `romaO`, `bamO`, `brocO` |

List all available palettes:

```r
scico_palette_names()
```

---

## 6. Okabe-Ito (Colorblind Safe)

Masataka Okabe and Kei Ito designed this qualitative palette to be readable under all common color-vision deficiencies.

```r
install.packages("ggokabeito")
library(ggokabeito)

plot_qualitative + scale_fill_okabe_ito()
```

Or use the raw hex codes:

```r
okabe_ito <- c(
  black     = "#000000",
  orange    = "#E69F00",
  sky_blue  = "#56B4E9",
  green     = "#009E73",
  yellow    = "#F0E442",
  blue      = "#0072B2",
  vermilion = "#D55E00",
  purple    = "#CC79A7"
)

scale_color_manual(values = okabe_ito)
```

---

## 7. paletteer: One Interface for Everything

`paletteer` collects palettes from hundreds of packages into a single, unified interface.

```r
install.packages("paletteer")
library(paletteer)
```

Syntax: **`"package::palette_name"`**

```r
# Get raw hex codes
paletteer_d("nord::aurora")           # discrete
paletteer_c("scico::batlow", n = 100) # continuous
paletteer_dynamic("cartography::multi.pal", 8)

# Use in ggplot2
ggplot(penguins, aes(flipper_length_mm, body_mass_g, color = species)) +
  geom_point(size = 3) +
  scale_color_paletteer_d("ggsci::nrc_npg")

ggplot(penguins, aes(bill_length_mm, bill_depth_mm, color = body_mass_g)) +
  geom_point(size = 3) +
  scale_color_paletteer_c("viridis::inferno")
```

| Need | Function |
| :--- | :--- |
| Discrete color | `scale_color_paletteer_d()` |
| Discrete fill | `scale_fill_paletteer_d()` |
| Continuous color | `scale_color_paletteer_c()` |
| Continuous fill | `scale_fill_paletteer_c()` |

---

## 8. Custom and Corporate Palettes

Organizations often require specific colors. For example, Georgia State uses a special blue (`#0039A6`) and red accent (`#CC0000`). Store them in a named object so you never have to remember hex codes:

```r
gsu_colors <- c(
  "#0039A6", "#CC0000", "#374057", "#0071CE",
  "#00AEEF", "#97CAEB", "#EEEEEE", "#CCCCCC", "#767679"
)

# Access by position
gsu_colors[1:2]
gsu_colors[c(3, 5, 9)]

# Preview every color
scales::show_col(gsu_colors)

# Use in a plot
plot_qualitative + scale_fill_manual(values = gsu_colors[1:5])
```

### Make your own scale function

```r
scale_fill_gsu <- function(...) {
  scale_fill_manual(values = gsu_colors[1:5], ...)
}

plot_qualitative + scale_fill_gsu()
```

Other examples of brand rules: the Urban Institute defines `#1696d2` for Democrats and `#db2b27` for Republicans.

---

## 9. Fun and Artsy Palettes

Not all of these are perceptually uniform or colorblind safe, but they are great for creating a specific vibe.

### Art: MetBrewer and MoMAColors

```r
library(MetBrewer)
library(MoMAColors)

plot_sequential + scale_color_gradientn(colors = met.brewer("OKeeffe2"))
plot_qualitative + scale_fill_manual(values = met.brewer("Johnson"))
plot_sequential + scale_color_gradientn(colors = moma.colors("VanGogh")[2:7])
```

| Package | Sequential | Diverging | Qualitative |
| :--- | :--- | :--- | :--- |
| `MetBrewer` | `OKeeffe2` | `Hiroshige` | `Johnson` |
| `MoMAColors` | `VanGogh` | `Kippenberger` | `ustwo` |

### CARTOColors

```r
library(rcartocolor)

plot_sequential  + scale_color_carto_c(palette = "PurpOr")
plot_qualitative + scale_fill_carto_d(palette = "Prism")
```

### Themed packages

| Category | Packages |
| :--- | :--- |
| 🎵 Music | `tayloRswift`, `beyonce`, `rockthemes`, `popthemes` |
| 🏞️ National parks | `nationalparkcolors`, `NatParksPalettes` |
| 📜 History | `suffrager`, `inauguration`, `ggpomological` |
| 🎬 TV & movies | `tvthemes`, `wesanderson`, `trekcolors`, `severance`, `ghibli`, `harrypotter` |
| 🏀 Other | `nbapalettes`, `LaCroixColoR` |

---

## 10. ggsci: Complete Guide

`ggsci` offers high-quality palettes inspired by scientific journals, data visualization libraries, science fiction movies, and TV shows.

### 10.1 Installation

```r
install.packages("ggsci")
library(ggsci)
library(ggplot2)
library(gridExtra)

# Built-in demo plots
p1 <- example_scatterplot()
p2 <- example_barplot()
```

### 10.2 Naming Convention

```r
scale_color_palname()   # points, lines
scale_fill_palname()    # bars, areas, tiles
scale_colour_palname()  # alias of scale_color_*
```

### 13.3 Palette Reference Table

| Name | Scales | Palette Types | Generator |
| :--- | :--- | :--- | :--- |
| NPG | `scale_color_npg()` / `scale_fill_npg()` | `"nrc"` | `pal_npg()` |
| AAAS | `scale_color_aaas()` / `scale_fill_aaas()` | `"default"` | `pal_aaas()` |
| NEJM | `scale_color_nejm()` / `scale_fill_nejm()` | `"default"` | `pal_nejm()` |
| Lancet | `scale_color_lancet()` / `scale_fill_lancet()` | `"lanonc"` | `pal_lancet()` |
| JAMA | `scale_color_jama()` / `scale_fill_jama()` | `"default"` | `pal_jama()` |
| BMJ | `scale_color_bmj()` / `scale_fill_bmj()` | `"default"` | `pal_bmj()` |
| JCO | `scale_color_jco()` / `scale_fill_jco()` | `"default"` | `pal_jco()` |
| UCSCGB | `scale_color_ucscgb()` / `scale_fill_ucscgb()` | `"default"` | `pal_ucscgb()` |
| D3 | `scale_color_d3()` / `scale_fill_d3()` | `"category10"`, `"category20"`, `"category20b"`, `"category20c"` | `pal_d3()` |
| Gephi | `scale_color_gephi()` / `scale_fill_gephi()` | `gephi_palettes()` | `pal_gephi()` |
| Observable | `scale_color_observable()` / `scale_fill_observable()` | `"observable10"` | `pal_observable()` |
| Primer | `scale_color_primer()` / `scale_fill_primer()` | `"mark17"` | `pal_primer()` |
| Atlassian | `scale_color_atlassian()` / `scale_fill_atlassian()` | `"categorical8"` | `pal_atlassian()` |
| iTerm | `scale_color_iterm()` / `scale_fill_iterm()` | `iterm_palettes()` | `pal_iterm()` |
| LocusZoom | `scale_color_locuszoom()` / `scale_fill_locuszoom()` | `"default"` | `pal_locuszoom()` |
| IGV | `scale_color_igv()` / `scale_fill_igv()` | `"default"`, `"alternating"` | `pal_igv()` |
| COSMIC | `scale_color_cosmic()` / `scale_fill_cosmic()` | `"hallmarks_light"`, `"hallmarks_dark"`, `"signature_substitutions"` | `pal_cosmic()` |
| UChicago | `scale_color_uchicago()` / `scale_fill_uchicago()` | `"default"`, `"light"`, `"dark"` | `pal_uchicago()` |
| Star Trek | `scale_color_startrek()` / `scale_fill_startrek()` | `"uniform"` | `pal_startrek()` |
| Tron Legacy | `scale_color_tron()` / `scale_fill_tron()` | `"legacy"` | `pal_tron()` |
| Futurama | `scale_color_futurama()` / `scale_fill_futurama()` | `"planetexpress"` | `pal_futurama()` |
| Rick and Morty | `scale_color_rickandmorty()` / `scale_fill_rickandmorty()` | `"schwifty"` | `pal_rickandmorty()` |
| The Simpsons | `scale_color_simpsons()` / `scale_fill_simpsons()` | `"springfield"` | `pal_simpsons()` |
| Flat UI | `scale_color_flatui()` / `scale_fill_flatui()` | `"default"`, `"flattastic"`, `"aussie"` | `pal_flatui()` |
| Frontiers | `scale_color_frontiers()` / `scale_fill_frontiers()` | `"default"` | `pal_frontiers()` |
| GSEA *(continuous)* | `scale_color_gsea()` / `scale_fill_gsea()` | `"default"` | `pal_gsea()` |
| Bootstrap 5 *(continuous)* | `scale_color_bs5()` / `scale_fill_bs5()` | 11 hues | `pal_bs5()` |
| Material Design *(continuous)* | `scale_color_material()` / `scale_fill_material()` | 19 hues | `pal_material()` |
| Tailwind CSS *(continuous)* | `scale_color_tw3()` / `scale_fill_tw3()` | 22 hues | `pal_tw3()` |

### 10.4 Journal Palettes (Discrete)

| Palette | Inspired by |
| :--- | :--- |
| **NPG** | Nature Publishing Group journals |
| **AAAS** | American Association for the Advancement of Science (Science) |
| **NEJM** | New England Journal of Medicine |
| **Lancet** | Lancet journals (e.g. Lancet Oncology) |
| **JAMA** | Journal of the American Medical Association |
| **BMJ** | BMJ living style guide |
| **JCO** | Journal of Clinical Oncology |

```r
p1_npg <- p1 + scale_color_npg()
p2_npg <- p2 + scale_fill_npg()
grid.arrange(p1_npg, p2_npg, ncol = 2)

# Swap in any other journal the same way
p1 + scale_color_aaas()
p1 + scale_color_nejm()
p1 + scale_color_lancet()
p1 + scale_color_jama()
p1 + scale_color_bmj()
p1 + scale_color_jco()
```

### 10.5 Genomics and Bioinformatics Palettes

| Palette | Origin |
| :--- | :--- |
| **UCSCGB** | UCSC Genome Browser chromosome colors (heavily used in Circos) |
| **LocusZoom** | LocusZoom |
| **IGV** | Integrative Genomics Viewer chromosome colors |
| **COSMIC** | Catalogue Of Somatic Mutations in Cancers |
| **GSEA** | GSEA GenePattern heatmaps *(continuous)* |

```r
p1 + scale_color_ucscgb()
p1 + scale_color_locuszoom()

# IGV: default or alternating
p1 + scale_color_igv()
p2 + scale_fill_igv("alternating")

# COSMIC: three variants
p1 + scale_color_cosmic("hallmarks_light")
p1 + scale_color_cosmic("hallmarks_dark")
p1 + scale_color_cosmic("signature_substitutions")
```

### 16.6 Software and Design-System Palettes

| Palette | Origin |
| :--- | :--- |
| **D3** | D3.js categorical colors (v3.x and before) |
| **Observable** | Observable 10 default scheme |
| **Primer** | GitHub's Primer design system |
| **Atlassian** | Atlassian Design System chart colors |
| **Flat UI** | Flat UI Colors 2 |
| **Frontiers** | Frontiers journals |
| **UChicago** | University of Chicago |

```r
# D3 has four variants
p1 + scale_color_d3("category10")
p1 + scale_color_d3("category20")
p1 + scale_color_d3("category20b")
p1 + scale_color_d3("category20c")

p1 + scale_color_observable()
p1 + scale_color_primer()
p1 + scale_color_atlassian()
p1 + scale_color_frontiers()

# Flat UI: default, flattastic, aussie
p2 + scale_fill_flatui("flattastic")

# UChicago: default, light, dark
p2 + scale_fill_uchicago("dark")
```

### 10.7 Sci-Fi and TV Palettes

| Palette | Show or movie |
| :--- | :--- |
| **Star Trek** | Star Trek (uniform colors) |
| **Tron Legacy** | Tron Legacy (made for dark themes) |
| **Futurama** | Futurama |
| **Rick and Morty** | Rick and Morty |
| **The Simpsons** | The Simpsons |

```r
p1 + scale_color_startrek()
p1 + scale_color_futurama()
p1 + scale_color_rickandmorty()
p1 + scale_color_simpsons()
```

**Tron Legacy works best on a dark theme:**

```r
p1_tron <- p1 + theme_dark() +
  theme(
    panel.background = element_rect(fill = "#2D2D2D"),
    legend.key       = element_rect(fill = "#2D2D2D")
  ) +
  scale_color_tron()

p2_tron <- p2 + theme_dark() +
  theme(panel.background = element_rect(fill = "#2D2D2D")) +
  scale_fill_tron()

grid.arrange(p1_tron, p2_tron, ncol = 2)
```

### 10.8 Gephi: Generative Palettes

Unlike fixed palettes, Gephi **generates** visually distinct colors for however many categories your plot has. Because it uses randomness, set a seed for reproducible output.

```r
# List named presets
gephi_palettes()

p1_gephi <- p1 + scale_color_gephi("default")
p2_gephi <- p2 + scale_fill_gephi("default")

set.seed(42)   # call before building/printing the plot
grid.arrange(p1_gephi, p2_gephi, ncol = 2)

# Or isolate the RNG side effects:
# withr::with_seed(42, print(p1_gephi))
```

### 10.9 iTerm: 400+ Terminal Color Schemes

Sourced from the `iterm2-color-schemes` project. Each scheme gives six categorical colors with two variants: `"normal"` and `"bright"`.

```r
# List every scheme
iterm_palettes()

p1 + scale_color_iterm("Rose Pine")
p2 + scale_fill_iterm("Rose Pine")
```

👉 Preview all of them on one page: [nanx.me/ggsci-iterm](https://nanx.me/ggsci-iterm/)

### 10.10 Continuous Palettes

`ggsci` offers two kinds of continuous palettes:

* **Diverging** (`GSEA`): neutral center, contrasting ends. Use when your data has a natural midpoint.
* **Sequential** (`Bootstrap 5`, `Material`, `Tailwind`): low → high intensity.

**Diverging demo: correlation matrix**

```r
data("mtcars")
cor <- cor(unname(mtcars))
cor_melt <- data.frame(
  Var1  = rep(seq_len(nrow(cor)), times = ncol(cor)),
  Var2  = rep(seq_len(ncol(cor)), each = nrow(cor)),
  value = as.vector(cor)
)

p3 <- ggplot(cor_melt, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(colour = "black", linewidth = 0.3) +
  theme_void()

p3_gsea     <- p3 + scale_fill_gsea()
p3_gsea_inv <- p3 + scale_fill_gsea(reverse = TRUE)
grid.arrange(p3_gsea, p3_gsea_inv, ncol = 2)
```

**Sequential demo: random matrix**

```r
set.seed(42)
k <- 6
x <- diag(k)
x[upper.tri(x)] <- runif(sum(1:(k - 1)), 0, 1)
x_melt <- data.frame(
  Var1  = rep(seq_len(nrow(x)), times = ncol(x)),
  Var2  = rep(seq_len(ncol(x)), each = nrow(x)),
  value = as.vector(x)
)

p4 <- ggplot(x_melt, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(colour = "black", linewidth = 0.3) +
  theme_void() +
  theme(legend.position = "none")

p4 + scale_fill_bs5("blue")              # Bootstrap 5
p4 + scale_fill_material("deep-purple")  # Material Design
p4 + scale_fill_tw3("emerald")           # Tailwind CSS
```

**Available hues**

| Palette | Options |
| :--- | :--- |
| **Bootstrap 5** | `blue`, `indigo`, `purple`, `pink`, `red`, `orange`, `yellow`, `green`, `teal`, `cyan`, `gray` |
| **Material Design** | `red`, `pink`, `purple`, `deep-purple`, `indigo`, `blue`, `light-blue`, `cyan`, `teal`, `green`, `light-green`, `lime`, `yellow`, `amber`, `orange`, `deep-orange`, `brown`, `grey`, `blue-grey` |
| **Tailwind CSS** | `slate`, `gray`, `zinc`, `neutral`, `stone`, `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`, `teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`, `fuchsia`, `pink`, `rose` |

> 💡 Even when the same matrix is plotted, some palettes are easier to read than others because our eyes are more sensitive to saturation changes in certain hues. Always test a few.

### 10.11 Transparency (`alpha`)

Every generator and scale function accepts `alpha`:

```r
p1 + scale_color_npg(alpha = 0.7)
p2 + scale_fill_jco(alpha = 0.5)
```

### 10.12 Using ggsci Outside ggplot2 (Base R, lattice)

Use the `pal_*()` generator functions to extract hex codes:

```r
mypal <- pal_npg("nrc", alpha = 0.7)(9)
mypal
#> [1] "#E64B35B2" "#4DBBD5B2" "#00A087B2" "#3C5488B2" "#F39B7FB2"
#> [6] "#8491B4B2" "#91D1C2B2" "#DC0000B2" "#7E6148B2"

# Preview
scales::show_col(mypal)

# Use in base R
barplot(1:9, col = mypal)
```

### 10.13 ggsci Caveats

* Some palettes may **not** be colorblind safe, photocopy safe, or print friendly.
* For accessibility and print, prefer `viridis`, `RColorBrewer`, or Okabe-Ito.
* The palettes are made for research purposes; the authors are not responsible for how they are used.

---

## 11. Accessibility Testing

Two things can silently ruin a good-looking palette:

1. **Black-and-white printing**: different colors can collapse to the same gray.
2. **Color blindness**: some hues become indistinguishable.

### 11.1 Grayscale / desaturation test

```r
library(colorspace)

pal_data <- list(
  Normal      = rainbow(32),
  Desaturated = colorspace::desaturate(rainbow(32))
)
```

| Palette | Prints well in B&W? |
| :--- | :--- |
| `rainbow()` | ❌ Different colors map to the same gray |
| `scales::hue_pal()` (old ggplot2 default) | ❌ Constant luminance, so identical grays |
| `viridis::inferno()` | ✅ Luminance changes smoothly |

Quick visual check:

```r
test_palette <- RColorBrewer::brewer.pal(8, "Set1")
gray_version <- colorspace::desaturate(test_palette)

par(mfrow = c(2, 1), mar = c(1, 1, 2, 1))
barplot(rep(1, 8), col = test_palette, main = "Original")
barplot(rep(1, 8), col = gray_version, main = "Grayscale simulation")
```

### 11.2 Color blindness simulation (`dichromat`)

```r
library(dichromat)

pal_data <- list(
  Normal       = rainbow(256),
  Deuteranopia = dichromat(rainbow(256), type = "deutan"),
  Protanopia   = dichromat(rainbow(256), type = "protan"),
  Tritanopia   = dichromat(rainbow(256), type = "tritan")
)
```

You can also simulate color blindness on an entire ggplot with the `colorblindr` package.

### 11.3 Safe choices

| Need | Recommended |
| :--- | :--- |
| Colorblind-safe categories | **Okabe-Ito** (`ggokabeito`, or `ggthemes::colorblind_pal()`) |
| Colorblind-safe sequential | **viridis** / **cividis** |
| Colorblind-safe, map-style | **ColorBrewer** (use the "colorblind safe" filter) |
| Print-friendly (B&W) | **viridis**, or sequential ColorBrewer palettes |

Reference: Okabe and Ito, *Color Universal Design (CUD): How to make figures and presentations that are friendly to colorblind people*.

---

## 12. Quick Decision Guide

| If you need... | Use |
| :--- | :--- |
| Categories, colorblind safe | `scale_fill_okabe_ito()` |
| Categories, any style | `scale_fill_brewer(palette = "Set2")` |
| Numeric gradient, safe and uniform | `scale_color_viridis_c()` |
| Diverging around zero | `scale_color_distiller(palette = "RdBu")` or `scico::roma` |
| A journal-style figure | `ggsci`: `scale_color_npg()`, `scale_color_nejm()`, `scale_color_lancet()` |
| Scientific heatmaps | `ggsci`: `scale_fill_gsea()`, or `scico` |
| A dark-theme dashboard | `ggsci`: `scale_color_tron()` |
| Matching a web or UI design system | `ggsci`: `scale_fill_tw3()`, `scale_fill_bs5()`, `scale_fill_material()` |
| Brand colors | `scale_fill_manual(values = brand_colors)` |
| Fun and artsy | `MetBrewer`, `MoMAColors`, `wesanderson`, `ghibli` |
| One interface for every palette | `paletteer` |

### Function cheat sheet

| Goal | Function |
| :--- | :--- |
| Manual categories | `scale_*_manual(values = c(...))` |
| Two-color gradient | `scale_*_gradient(low, high)` |
| Multi-color gradient | `scale_*_gradientn(colors = c(...))` |
| Brewer discrete / continuous | `scale_*_brewer()` / `scale_*_distiller()` |
| viridis discrete / continuous | `scale_*_viridis_d()` / `scale_*_viridis_c()` |
| scico discrete / continuous | `scale_*_scico_d()` / `scale_*_scico_c()` |
| carto discrete / continuous | `scale_*_carto_d()` / `scale_*_carto_c()` |
| paletteer discrete / continuous | `scale_*_paletteer_d()` / `scale_*_paletteer_c()` |

*(Replace `*` with `color` or `fill`.)*

---

## 🔗 Further Reading

* [Emil Hvitfeldt's Comprehensive List of R Palettes](https://emilhvitfeldt.github.io/r-color-palettes/)
* [`paletteer` on GitHub](https://github.com/EmilHvitfeldt/paletteer)
* [ggsci documentation](https://nanx.me/ggsci/)
* [R Graph Gallery Color Finder](https://r-graph-gallery.com/color-palette-finder)
* [ColorBrewer 2.0](https://colorbrewer2.org/)
* [Viz Palette](https://projects.susielu.com/viz-palette) for testing palettes in context
