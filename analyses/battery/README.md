Battery test
================

    Error: Column `tablet_id` can't be converted from numeric to character

    Error in get_positions_from_device_id(url = creds$traccar_server, user = creds$traccar_user, : could not find function "get_positions_from_device_id"

    Error in strsplit(x, " "): non-character argument

    Error: `by` required, because the data sources have no common variables

    Error in FUN(X[[i]], ...): object 'deviceTime' not found

![](figures/unnamed-chunk-4-1.png)<!-- -->

# Technical details

This document was produced on 2020-05-24 on a Linux machine (release
5.3.0-53-generic. To reproduce, one should take the following steps:

  - Clone the repository at <https://github.com/databrew/bohemia>

  - “Render” (using `rmarkdown`) the code in
    `analysis/clustering/README.Rmd`

Any questions or problems should be addressed to <joe@databrew.cc>
