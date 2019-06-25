
<!-- README.md is generated from README.Rmd. Please edit that file -->
bohemia: The R package of the Bohemia project
=============================================

This package contains utilities used by the Bohemia research team. It is publicly available for the purposes of reproducibility and transparency.

Installation
------------

To install this package, run the below from within the R console.

``` r
if(!require(devtools)) install.packages("devtools")
install_github('databrew/bohemia')
```

Building the package
--------------------

Having done the above, run `Rscript build_package.R` from within the main directory to compile the package.

Package utilities
-----------------

This package contains several noteworthy tools.

### Generating fake data

Some methods and analysis require "dummy" data in order to be tested. Functions which generate dummy data begin with the prefix `generate_fake`. For example, `generate_fake_locations` creates a dataframe of `n` locations, grouped into `n_clusters` clusters, which is useful for testing algorithms related to clustering, buferring, etc.

Here is a working example:

``` r
set.seed(1)
library(tidyverse)
#> ── Attaching packages ────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ tibble  2.1.3     ✔ purrr   0.3.2
#> ✔ readr   1.3.1     ✔ stringr 1.4.0
#> ✔ tibble  2.1.3     ✔ forcats 0.4.0
#> ── Conflicts ───────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter()  masks stats::filter()
#> ✖ purrr::is_null() masks testthat::is_null()
#> ✖ dplyr::lag()     masks stats::lag()
#> ✖ dplyr::matches() masks testthat::matches()
library(sp)
library(bohemia)
# Generate some fake data
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.04)
# Plot the fake data
plot(fake$x, fake$y, col = rainbow(10)[fake$cluster])
```

![](README-unnamed-chunk-2-1.png)

``` r
# Generate boundaries from the point locations
boundaries <- bohemia::create_borders(df = fake)
# Plot the boundaries
cols <- rainbow(10)[fake$cluster]
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
```

![](README-unnamed-chunk-3-1.png)

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T)
```

![](README-unnamed-chunk-4-1.png)

As an alternative to the above approach, and so as to generate generealizable boundaries with no "holes", we can use voronoi tesselation as opposed to convex hulling.

``` r
boundaries <- create_borders(df = fake, voronoi = TRUE)
#> Loading required namespace: deldir
# Plot the boundaries
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
```

![](README-unnamed-chunk-5-1.png)

Just like with convex hull generated borders, we can add buffers to delauney triangles.

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T, col = adjustcolor(cols, alpha.f = 0.3))
```

![](README-unnamed-chunk-6-1.png)

In the above, we use *external* boundaries, which results in one areas borders bleeding into the core of another area. As an alternative to this, we can use *internal* boundaries.

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = -5000)
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T, col = adjustcolor(cols, alpha.f = 0.5))
points(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
```

![](README-unnamed-chunk-7-1.png)

For the purposes of an intervention in which each area is assigned status A or B (ie, intervention or control), the need for buffers between areas of identical intervention status is redundant (and can unecessarily eliminate potential study participants).

``` r
# Define some ids 
ids <- sample(1:2, nrow(boundaries), replace = TRUE)
cols2 <- c('lightblue', 'orange')
cols <- cols2[ids]

# Generate buffers from boundaries
buffers <- create_buffers(shp = boundaries,
                                   meters = -5000,
                                   ids = ids)
#> Warning in gpclibPermit(): support for gpclib will be withdrawn from
#> maptools at the next major release
#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated

#> Warning in `[<-`(`*tmp*`, i, value = gpc): implicit list embedding of S4
#> objects is deprecated
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
# plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.8))
plot(buffers, add = T, col = adjustcolor(cols2, alpha.f = 0.5))
points(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
```

![](README-unnamed-chunk-8-1.png)
