Livestock ownership and malaria risk in Mopeia
================

Overlap of livestock ownership
==============================

### Total livestock ownership (all localidades)

![](figures/unnamed-chunk-3-1.png)

### Total livestock ownership (by "Posto Administrativo")

![](figures/unnamed-chunk-4-1.png)

### Total livestock ownership (by "Localidade")

![](figures/unnamed-chunk-5-1.png)

### Correlation between ownership of one animal and another

On May 27 2019, Cassidy Rist asked the following (via email):

    I wonder what the overlap is among livestock ownership. 
    For example, do most people own pigs and goats, or is it 
    more likely that one or the other species is owned?

As of now, we only have aggregate-level data (most granular: localidade). Without individual-level data, the above can be addressed. Until then. we can examine the correlation at the localidade level (below), but in doing so we're committing the ecological fallacy.

The below aims to address the above question, using aggregated data ("localidade"-level).

#### Cattle and Goats

![](figures/unnamed-chunk-6-1.png)

#### Cattle and Sheep

![](figures/unnamed-chunk-7-1.png)

#### Cattle and Swine

![](figures/unnamed-chunk-8-1.png)

#### Goats and Sheep

![](figures/unnamed-chunk-9-1.png)

#### Goats and Swine

![](figures/unnamed-chunk-10-1.png)

#### Sheep and Swine

![](figures/unnamed-chunk-11-1.png)

Map of livestock
================

Map of malaria incidence in cohort children
===========================================

Map of livestock and malaria incidence combined into single index
=================================================================

Pending: Map of mosquito densities
==================================

Technical details
=================

This document was produced on 2019-06-10 on a Linux machine (release 4.15.0-46-generic. To reproduce, one should take the following steps:

1.  Clone the repository at <https://github.com/databrew/bohemia>

2.  Populate the `analyses/livestock_distribution/data` directory with the following files: `Distribuicao de gado em Mopeia (1).xlsx` (emailed to team members from Charfudin Sacoor on May 27 2019);

3.  "Render" (using `rmarkdown`) the code in `analysis/livestock_distribution/README.Rmd`

Any questions or problems should be addressed to <joe@databrew.cc>
