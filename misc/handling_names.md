# Handling names

The below provides a summary of how paricipant names are handled for the Bohemia project.

## 5 Principles
- There is no research value in participant names
- There is operational value in participant names
- Sites (CISM, IHI) can access and store participant names
- Sponor (ISGlobal) cannot store participant names
- Sponsor-contracted third parties (Databrew) cannot store participant names

## The problem

The first four of the above five problems pose no problems. However, the fifth principle is slightly problematic. The reason is that the sponsor-contracted third party (Databrew) needs to generate digital forms in which names are included (ie, fieldworkers need to select a household and household member, and pre-populate certain fields based on the selection). In order for Databrew to put a name on a form Databrew needs access to that name.

### Side-note: Why not just use the local site databases?

If the third-party contractor cannot store names, but sites can, why not just use the names data from the site databases to populate forms? The reason is that Databrew carries out data processing tasks which sometimes result in the alteration of an incorrectly-enumerated participant ID number or the removal of a duplicated participant. These alterations occur in the Databrew database, but do not get copied over to the site databases (since the site databases are unmodified/raw). Therefore, if the tablets relied solely on the names data from the site databases, they may end up with duplicates and errors.

## The solution

We propose a solution wherein.

![](img/names.png)

Test.
