
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bohemia: The R package of the Bohemia project

This package contains utilities used by the Bohemia research team. It is
publicly available for the purposes of reproducibility and transparency.

## Installation

To install this package: - Clone the parent repo: `git clone
https://github.com/databrew/bohemia` - `cd` into `rpackage` - Run
`Rscript build_package.R`

Alternatively, one can install directly from
github:

``` r
devtools::install_github('databrew/bohemia', subdir = 'rpackage/bohemia', dependencies = TRUE, force = TRUE)
```

To remove the package (for example, so as to re-install for an update),
simply run: \`remove.packages(‘bohemia’)

## Setting up data

The package includes both tools (functions) as well as data. In order to
set up the package’s datasets, the following steps should be taken:

#### Download OSM data

1.  Download Mozambique data from
    <https://download.geofabrik.de/africa/mozambique-latest-free.shp.zip>
    into `data-raw/geofabrik` and extract

2.  Download Tanzania data from
    <https://download.geofabrik.de/africa/tanzania-latest-free.shp.zip>
    into `data-raw/geofabrik` and extract

#### Run the data compilation script

1.  From the command line, run `cd data-raw; Rscript DATASET.R; cd..`

## Building the package

Having done the above, run `Rscript build_package.R` from within the
main directory to compile the package.

## Package utilities

This package contains several noteworthy tools. What follows is a
walk-through of some of them.

### Data

#### Country-level polygonal data

``` r
library(sp)
library(bohemia)

# Create a map of Mozambique at the second administrative level (district)
plot(bohemia::mozambique2)
```

![](figures/unnamed-chunk-3-1.png)<!-- -->

``` r

# Create a map of Mozambique at the tertiary administrative level (posto administrativo)
plot(bohemia::mozambique3, lwd = 0.2)
```

![](figures/unnamed-chunk-3-2.png)<!-- -->

``` r

# Create a map of Tanzania at the second administrative level (district)
plot(bohemia::tanzania2)
```

![](figures/unnamed-chunk-3-3.png)<!-- -->

``` r

# Create a map of Tanzania at the tertiary administrative level (posto administrativo)
plot(bohemia::tanzania3, lwd = 0.2)
```

![](figures/unnamed-chunk-3-4.png)<!-- -->

#### Study area polygonal data

``` r
plot(bohemia::mopeia2)
```

![](figures/unnamed-chunk-4-1.png)<!-- -->

``` r
plot(bohemia::mopeia3)
```

![](figures/unnamed-chunk-4-2.png)<!-- -->

``` r

plot(bohemia::rufiji2)
```

![](figures/unnamed-chunk-4-3.png)<!-- -->

``` r
plot(bohemia::rufiji3)
```

![](figures/unnamed-chunk-4-4.png)<!-- -->

#### Study area road data

``` r
plot(bohemia::mopeia2)
plot(bohemia::mopeia_roads, add = TRUE)
```

![](figures/unnamed-chunk-5-1.png)<!-- -->

``` r

plot(bohemia::rufiji2)
plot(bohemia::rufiji_roads, add = TRUE)
```

![](figures/unnamed-chunk-5-2.png)<!-- -->

#### Study area road data

``` r
plot(bohemia::mopeia2)
plot(bohemia::mopeia_roads, add = TRUE)
```

![](figures/unnamed-chunk-6-1.png)<!-- -->

``` r

plot(bohemia::rufiji2)
plot(bohemia::rufiji_roads, add = TRUE)
```

![](figures/unnamed-chunk-6-2.png)<!-- -->

#### Study area water data

``` r
plot(bohemia::mopeia2)
plot(bohemia::mopeia_water, add = TRUE)
plot(bohemia::mopeia_waterways, add = TRUE)
```

![](figures/unnamed-chunk-7-1.png)<!-- -->

``` r

plot(bohemia::rufiji2)
plot(bohemia::rufiji_water, add = TRUE)
plot(bohemia::rufiji_waterways, add = TRUE)
```

![](figures/unnamed-chunk-7-2.png)<!-- -->

## Functions

### Retrieving data from ODK aggregate

The `bohemia` package has a series of tools meant for assisting with the
automated retrieval of data from the ODK Aggregate server. Below is a
basic walk-through with examples.

First define some basic parameters (this will vary depending on your
system).

``` r
library(bohemia)
library(knitr)
library(dplyr)
odk_agg_url <- 'https://bohemia.systems'
user <- 'data'
password <- 'data'
form_name <- 'Recon'
```

Retrieve a list of forms from the
server:

``` r
fl <- odk_list_forms(url = odk_agg_url, user = user, password = password)
```

Let’s have a look at the
content:

``` r
kable(fl)
```

| name            | id               | url                                                      |
| :-------------- | :--------------- | :------------------------------------------------------- |
| Census          | census           | <https://bohemia.systems/formXml?formId=census>          |
| Geocoding       | geocoding        | <https://bohemia.systems/formXml?formId=geocoding>       |
| Census training | census\_training | <https://bohemia.systems/formXml?formId=census_training> |
| VA              | va               | <https://bohemia.systems/formXml?formId=va>              |
| Recon           | recon            | <https://bohemia.systems/formXml?formId=recon>           |

Fetch the ID for the form in question:

``` r
id <- fl %>% filter(name == form_name) %>% .$id
```

Let’s have a look at the content:

``` r
id
#> [1] "recon"
```

Get the secondary id of the form in question:

``` r
# (in most cases this will be identical)
id2 <- odk_get_secondary_id(url = odk_agg_url, id = id)
```

Let’s have a look at the content:

``` r
id2
#> [1] "recon"
```

Get a list of submissions for that form:

``` r
submissions <- odk_list_submissions(url = odk_agg_url,
                                    id = id,
                                    user = user,
                                    password = password)
```

Let’s have a look at the content:

``` r
kable(submissions)
```

| x                                         |
| :---------------------------------------- |
| uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| uuid:89b70ac4-9156-4679-b16f-9af438a936ba |
| uuid:9fb57034-bac1-4225-b75d-aacf98838ab6 |
| uuid:7da79f02-8db0-4ece-a8c4-45b45ba0effc |

Retrieve the data for an individual submission (the first one, for
example):

``` r
submission <- odk_get_submission(url = odk_agg_url,
                                 id = id,
                                 id2 = id2,
                                 uuid = submissions[1],
                                 user = user,
                                 password = password)

# # What has been retrieved is a response for an http request in xml format:
# submission
# To take a better look at it, try:
# library(xml2)
# xmlview::xml_view(read_xml(submission))
```

To parse this submission, we’ll run the `odk_parse_submission`. This
takes the xml response from the server and generates a list with two
elements: `non_repeats` data and `repeats` data.

``` r
parsed <- odk_parse_submission(xml = submission)
```

What is the above? It’s a list made up of two tables. The first one
(`parsed$non_repeats`) is essentially the “core” form data. The `key` is
the variable/question, the `value` is the response, and the `instanceID`
is the unique identifier of that particular form. This is what those
data look
like:

``` r
kable(head(parsed$non_repeats))
```

| key          | value                         | instanceID                                |
| :----------- | :---------------------------- | :---------------------------------------- |
| device\_id   | 8a9f2d05366ce50e              | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| start\_time  | 2020-03-01T09:48:31.521+01:00 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| end\_time    | 2020-03-01T09:50:02.393+01:00 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| todays\_date | 2020-03-01                    | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| have\_wid    | No                            | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| wid\_manual  | 423                           | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |

The second element of the list (`parsed$repeats`) is the data for those
elements which were repeated. It also has `key`, `value`, and
`instanceID`. But it has two additional columns: the `repeat_name`
(essentially, the table to which the field in question belongs) and the
`repeated_id`, which helps to associate different `key`-`value` pairs
with one
another.

``` r
kable(head(parsed$repeats))
```

| key                      | value             | repeat\_name  | repeated\_id | instanceID                                |
| :----------------------- | :---------------- | :------------ | -----------: | :---------------------------------------- |
| chief\_name              | Ben Brew          | repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| chief\_role              | Village secretary | repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| chief\_role\_other\_role | NA                | repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| chief\_contact           | 13412342          | repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| chief\_contact\_alt      | NA                | repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |
| chief\_name              | Xing Brew         | repeat\_chief |            2 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |

The parsed data is in *“long”* format, with “key” being the variable
name and “value” being the response. To get the data into *“wide”*
format, one should use the `odk_make_wide` function as such:

``` r
wide <- odk_make_wide(long_list = parsed)
```

What is the above? It’s just liked `parsed`, but with wide format data
rather than long. Let’s have a look.
Non-repeats:

``` r
kable(head(wide$non_repeats))
```

| instanceID                                | accessibility\_best\_rainy | accessibility\_bicycle | accessibility\_boat | accessibility\_car | accessibility\_details | accessibility\_details\_yn | accessibility\_motorcycle | accessibility\_note | Country    | device\_id       | distance\_nearest\_hf | District | electricity | end\_time                     | Hamlet      | hamlet\_alternative | hamlet\_alternative\_name | hamlet\_code | hamlet\_code\_list | hamlet\_code\_not\_list | hamlet\_other | have\_wid | instanceName                 | location                                                 | market\_availability | market\_availability\_other | market\_community | meet\_tv | meet\_when | meet\_where | meet\_which\_station | meet\_which\_tv | name\_nearest\_hf | note\_chief | note\_general | number\_hh | other\_location | Region   | religion  | religion\_add\_comment | religion\_comments | start\_time                   | telecom\_best\_data | telecom\_best\_voice | telecom\_data\_note | telecom\_have\_data | telecom\_have\_voice | telecom\_voice\_note | telecom\_work\_data\_airtel | telecom\_work\_data\_halotel | telecom\_work\_data\_mcell | telecom\_work\_data\_movitel | telecom\_work\_data\_tigo | telecom\_work\_data\_vodacom | telecom\_work\_voice\_airtel | telecom\_work\_voice\_halotel | telecom\_work\_voice\_mcell | telecom\_work\_voice\_movitel | telecom\_work\_voice\_tigo | telecom\_work\_voice\_vodacom | time\_nearest\_hf | todays\_date | type\_nearest\_hf | type\_nearest\_hf\_other | Village    | village\_other | Ward        | wid | wid\_manual | wid\_qr |
| :---------------------------------------- | :------------------------- | :--------------------- | :------------------ | :----------------- | :--------------------- | :------------------------- | :------------------------ | :------------------ | :--------- | :--------------- | --------------------: | :------- | :---------- | :---------------------------- | :---------- | :------------------ | :------------------------ | :----------- | :----------------- | :---------------------- | :------------ | :-------- | :--------------------------- | :------------------------------------------------------- | :------------------- | :-------------------------- | :---------------- | :------- | :--------- | :---------- | :------------------- | :-------------- | :---------------- | :---------- | :------------ | ---------: | :-------------- | :------- | :-------- | :--------------------- | :----------------- | :---------------------------- | :------------------ | :------------------- | :------------------ | :------------------ | :------------------- | :------------------- | :-------------------------- | :--------------------------- | :------------------------- | :--------------------------- | :------------------------ | :--------------------------- | :--------------------------- | :---------------------------- | :-------------------------- | :---------------------------- | :------------------------- | :---------------------------- | ----------------: | :----------- | :---------------- | :----------------------- | :--------- | :------------- | :---------- | --: | ----------: | :------ |
| uuid:e8832376-55e0-4382-aeb6-1d9746ff629a | Bicycle                    | Dry                    | Rainy               | NA                 | NA                     | No                         | NA                        | NA                  | Mozambique | 8a9f2d05366ce50e |                     1 | Mopeia   | Partially   | 2020-03-01T09:50:02.393+01:00 | 25 de Junho | No                  | NA                        | DEN          | DEN                | NA                      | NA            | No        | recon-25 de Junho-2020-03-01 | 37.4219983333 -122.0840000000 5.0000000000 20.0000000000 | NA                   | NA                          | No                | No       | NA         | NA          | NA                   | NA              | John’s pharmacy   | NA          | NA            |        100 | AAA             | Zambezia | Christian | No                     | NA                 | 2020-03-01T09:48:31.521+01:00 | NA                  | MCell                | NA                  | No                  | Yes                  | NA                   | NA                          | NA                           | NA                         | NA                           | NA                        | NA                           | NA                           | NA                            | Yes                         | Yes                           | NA                         | No                            |                12 | 2020-03-01   | Dispensary        | NA                       | Campo Sede | NA             | Posto Campo | 423 |         423 | NA      |

And
repeats:

``` r
kable(head(wide$repeats))
```

| repeat\_name  | repeated\_id | instanceID                                | chief\_contact | chief\_contact\_alt | chief\_name | chief\_role       | chief\_role\_other\_role |
| :------------ | -----------: | :---------------------------------------- | -------------: | ------------------: | :---------- | :---------------- | :----------------------- |
| repeat\_chief |            1 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |       13412342 |                  NA | Ben Brew    | Village secretary | NA                       |
| repeat\_chief |            2 | uuid:e8832376-55e0-4382-aeb6-1d9746ff629a |       13413412 |            34634224 | Xing Brew   | Informal chief    | NA                       |

All of the above describes the process for getting data for one
submission. But in the pipeline (ie, real-life use), we need to be able
to retrieve lots of data. This is where `odk_get_data` comes in.
`odk_get_data` is essentially a “wrapper” for the above process, and
allows for the retrieval of multiple submissions. Here’s how to use it.

``` r
# Run the function
recon <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = NULL,
  user = user,
  password = password
)
```

As with the above functions, this will return two lists.

### Generating fake data

Some methods and analysis require “dummy” data in order to be tested.
Functions which generate dummy data begin with the prefix
`generate_fake`. For example, `generate_fake_locations` creates a
dataframe of `n` locations, grouped into `n_clusters` clusters, which is
useful for testing algorithms related to clustering, buferring, etc.

Here is a working example:

``` r
set.seed(1)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✓ tibble  2.1.3     ✓ purrr   0.3.3
#> ✓ readr   1.3.1     ✓ stringr 1.4.0
#> ✓ tibble  2.1.3     ✓ forcats 0.4.0
#> ── Conflicts ────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(sp)
library(bohemia)
# Generate some fake data
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.04)
# Plot the fake data
plot(fake$x, fake$y, col = rainbow(10)[fake$cluster])
```

![](figures/unnamed-chunk-26-1.png)<!-- -->

### Generating village boundaries

``` r
# Generate boundaries from the point locations
boundaries <- bohemia::create_borders(df = fake)
# Plot the boundaries
cols10 <- rainbow(10)
cols <- cols10[fake$cluster]
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols10, alpha.f = 0.3),
     border = NA)
```

![](figures/unnamed-chunk-27-1.png)<!-- -->

### Generating external buffers

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T)
```

![](figures/unnamed-chunk-28-1.png)<!-- -->

### Generating buffers based on tesselation

As an alternative to the above approach, and so as to generate
generealizable boundaries with no “holes”, we can use voronoi
tesselation as opposed to convex hulling.

``` r
boundaries <- create_borders(df = fake, voronoi = TRUE)
# Plot the boundaries
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
```

![](figures/unnamed-chunk-29-1.png)<!-- -->

### Generating tesselated buffers

Just like with convex hull generated borders, we can add buffers to
delauney triangles.

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3), border = NA)
plot(buffers, add = T, col = adjustcolor(cols10, alpha.f = 0.3))
```

![](figures/unnamed-chunk-30-1.png)<!-- -->

### Generating tesselated internal buffers

In the above, we use *external* boundaries, which results in one areas
borders bleeding into the core of another area. As an alternative to
this, we can use *internal* boundaries.

``` r
# Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = -5000)
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
# plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T, col = adjustcolor(cols10, alpha.f = 0.4))
points(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
```

![](figures/unnamed-chunk-31-1.png)<!-- -->

### Generating “collapsed” tesselated internal buffers

For the purposes of an intervention in which each area is assigned
status A or B (ie, intervention or control), the need for buffers
between areas of identical intervention status is redundant (and can
unecessarily eliminate potential study participants). The below is an
example of redundant buffers.

``` r
# Define some ids 
ids <- sample(1:2, nrow(boundaries), replace = TRUE)
cols2 <- c('lightblue', 'orange')
cols <- cols2[ids]

# Create a dataframe for joining clusters to ids
merger <- data.frame(cluster = boundaries@data$cluster,
                     id = ids)
# Bring the ids into the point data
old_fake <- fake
fake <- left_join(fake, merger, by = 'cluster')

# Generate buffers from boundaries
buffers@data <- left_join(buffers@data, merger, by = 'cluster')
plot(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
# plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.8))
plot(buffers, add = T, col = adjustcolor(cols2[buffers@data$id], alpha.f = 0.5))
points(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
```

![](figures/unnamed-chunk-32-1.png)<!-- -->

The below collapses redundant borders.

``` r
# Define some ids 
ids <- sample(1:2, nrow(boundaries), replace = TRUE)
cols2 <- c('lightblue', 'orange')
cols <- cols2[ids]

# Create a dataframe for joining clusters to ids
merger <- data.frame(cluster = boundaries@data$cluster,
                     id = ids)
# Bring the ids into the point data
fake <- old_fake
fake <- left_join(fake, merger, by = 'cluster')

# Generate buffers from boundaries
buffers <- create_buffers(shp = boundaries,
                                   meters = -5000,
                                   ids = ids)
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
# plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.8))
plot(buffers, add = T, col = adjustcolor(cols2[buffers@data$id], alpha.f = 0.5))
points(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
```

![](figures/unnamed-chunk-33-1.png)<!-- -->

### Generating village-agnostic clusters

Clusters can be defined *a priori* (ie, named administrative units) or
programatically (ie, village-agnostic groups of `n` people).
Alternatively, a cluster could be formed programatically, but with
certain restrictions (such as the a rule prohibiting the division of a
village into two). To do this, use the `create_clusters` function.

``` r
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.1) %>% dplyr::select(-cluster)
plot(fake$x, fake$y, pch = 16)
```

![](figures/unnamed-chunk-34-1.png)<!-- -->

``` r
cs <- create_clusters(cluster_size = 100,
                      locations = fake)

rcols <- length(unique(cs$cluster))
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
```

![](figures/unnamed-chunk-34-2.png)<!-- -->

The data generated from `create_clusters` is compatible with the other
functions herein described. Here are some usage examples:

``` r
set.seed(2)
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 5,
                                sd = 0.1) %>% dplyr::select(-cluster)
cs <- create_clusters(cluster_size = 100,
                      locations = fake)
rcols <- length(unique(cs$cluster))

# Create true borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs)
plot(boundaries, add = T)
```

![](figures/unnamed-chunk-35-1.png)<!-- -->

``` r

# Create tesselation borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs, voronoi = TRUE)
plot(boundaries, add = TRUE)
```

![](figures/unnamed-chunk-35-2.png)<!-- -->

``` r

# Create internal buffered tesselation borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs, voronoi = TRUE)
buffered <- create_buffers(shp = boundaries, meters = -3000)
plot(buffered, add = TRUE)
```

![](figures/unnamed-chunk-35-3.png)<!-- -->

``` r

# Create internal buffered tesselation borders with binary treatment status
id_df <- cs %>% 
  group_by(cluster) %>%
  tally 
id_df$id <- sample(1:2, nrow(id_df), replace = TRUE)
cs <- left_join(cs, id_df)
#> Joining, by = "cluster"
cols2 <- c('darkblue', 'pink')
plot(cs$x, cs$y, col = cols2[cs$id])
boundaries <- create_borders(df = cs, voronoi = TRUE)
buffered <- create_buffers(shp = boundaries, meters = -3000,
                           ids = id_df$id)
plot(buffered, add = TRUE)
```

![](figures/unnamed-chunk-35-4.png)<!-- -->

What follows below is a visualization of how the `create_buffers`
algorithm works.

``` r
set.seed(2)
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 5,
                                sd = 0.1) %>% dplyr::select(-cluster)
cs <- create_clusters(cluster_size = 100,
                      locations = fake,
                      plot_map = TRUE,
                      save = 'animation')
setwd('animation')
system('convert -delay 100 -loop 0 *.png result.gif')
setwd('..')
```

![](animation/result.gif)

## QR Codes

The Bohemia project uses QR codes for the purpose of quickly reading in
and confirming household ID numbers. These can be printed easily using
the `create_qr()` function in the `bohemia` r package. Here is an
example of its use:

``` r
# Example id number: 1234567
id <- ('111-222')
create_qr(id)
#> Loading required package: qrcode
```

![](figures/unnamed-chunk-37-1.png)<!-- -->

If many ids need to be printed at once, there is a .pdf functionality
for printing multiple IDs. To use this, run the following:

``` r
# Example ids: 5566778, 7654321, 1234567
ids <- c('123-456', '654-321', '999-888', '777-666')
render_qr_pdf(ids = ids,
              output_file = 'qrs.pdf')
```

The above will generate a pdf in the working directory named `qrs.pdf`
with all of the above QRs.

In order to generate *worker ID* QRs, once can run something like the
following:

``` r
print_worker_qrs(wid = '001', worker = TRUE, n = 12)
```

The above will generate 12 ID QRs for worker with ID number ‘001’.

In order to generate household-specific QRs for a given worker, do
something like below:

``` r
print_worker_qrs(wid = '001', restrict = 20:30)
```

The above will generate ids for house numbers 20 through 30 for worker
ID 001 (ie, ‘001-020’, ‘001-021’, etc.). Remove the `restrict` argument
to generate IDs for all 1000 houses assigned to the worker.
