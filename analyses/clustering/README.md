Bohemia clustering
================

![](figures/unnamed-chunk-2-1.png)<!-- -->![](figures/unnamed-chunk-2-2.png)<!-- -->

### Generating village boundaries

![](figures/unnamed-chunk-3-1.png)<!-- -->

### Generating buffers based on tesselation

![](figures/unnamed-chunk-4-1.png)<!-- -->

### Generating tesselated internal buffers

In the above, we use *external* boundaries, which results in one areas
borders bleeding into the core of another area. As an alternative to
this, we can use *internal* boundaries.

![](figures/unnamed-chunk-5-1.png)<!-- -->

### Generating “collapsed” tesselated internal buffers

For the purposes of an intervention in which each area is assigned
status A or B (ie, intervention or control), the need for buffers
between areas of identical intervention status is redundant (and can
unecessarily eliminate potential study
participants).

![](figures/unnamed-chunk-6-1.png)<!-- -->

### Generating village-agnostic clusters

![](figures/unnamed-chunk-7-1.png)<!-- -->![](figures/unnamed-chunk-7-2.png)<!-- -->

What follows below is a visualization of how the `create_buffers`
algorithm works.

<table style="width:100%">

<tr>

<td>

<img src="animation_a/result.gif" />

</td>

<td>

<img src="animation_b/result.gif" />

</td>

<td>

<img src="animation_b/result.gif" />

</td>

</tr>

<tr>

<td>

<img src="animation_c/result.gif" />

</td>

<td>

<img src="animation_d/result.gif" />

</td>

<td>

<img src="animation_j/result.gif" />

</td>

</tr>

<tr>

<td>

<img src="animation_e/result.gif" />

</td>

<td>

<img src="animation_f/result.gif" />

</td>

<td>

<img src="animation_k/result.gif" />

</td>

</tr>

<tr>

<td>

<img src="animation_g/result.gif" />

</td>

<td>

<img src="animation_h/result.gif" />

</td>

<td>

<img src="animation_l/result.gif" />

</td>

</tr>

</table>

# Technical details

This document was produced on 2020-10-27 on a Linux machine (release
5.4.0-52-generic. To reproduce, one should take the following steps:

  - Clone the repository at <https://github.com/databrew/bohemia>

  - “Render” (using `rmarkdown`) the code in
    `analysis/clustering/README.Rmd`

Any questions or problems should be addressed to <joe@databrew.cc>
