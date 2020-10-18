# Refusals

(and absences, enumerations, enrollment, etc.).

This concept note / guide explains how to deal with non-participation in the Bohemia (mini)census.

## Over-arching principles

- Everyone / anyone has the right to refuse / decline participation.  
- All refusals should be documented via the [refusals](https://github.com/databrew/bohemia/tree/master/forms/refusals) form.  
- All households (whether participating or not) are assigned a HH-ID number (in the case of a non-participating household, this ID number may be digital-only, ie not painted anywhere).

## Process

The process for identifying and logging refusals (ie, non-participating households) is slightly different for MOZ versus TZA. The reason for this difference is because:
- MOZ uses the ["a priori" enumeration method](https://github.com/databrew/bohemia/blob/master/misc/ids.md#method-1-a-priori)  
- TZA uses the ["on the fly" enumeration method](https://github.com/databrew/bohemia/blob/master/misc/ids.md#method-2-on-the-fly)  

Because of these different methods, refusals can take place at different times. What follows is a country-specific flow for when / how refusals take place.

### Shared principles: handling absences

In both the case of Mozambique and Tanzania, absences are handled identically. If the person is absent when the house is visited, the `refusals` form should be used to register the absence. The "Reason for not participating" field should be marked as "Not present".  

Unlike a "refused" response, when a household is marked as "not present", that household will remain in visitation lists thereafter (ie, they should be tried again).

A household is removed from visitation lists following three "not present" entries.

### Mozambique

- The enumeration team goes to a hamlet.  
- The enumeration team goes house-by-house to _every_ house in that hamlet.  
- _Every_ house is registered either :
  - A. In the `enumerations` form (if they choose to participate)
  - B. In the `refusals` form (if they decline to participate)
- Following enumeration, during the actual minicensus, the team goes back to the hamlet to collect data.
  - A. Houses which were enumerated can still refuse to participate at this point. If they do so, a `refusals` form should be filled out for the house in question. In this case, a household will have been enumerated but then refused (ie, shown up in both the enumerations table and the refusals table).  
  - B. Houses which refused to participate during enumerations do not need to be contacted again.
- In summary, every househould will fit one of the following three patterns:
  - 1. Refusal (occurred during enumeration)
  - 2. Enumeration then refusal (refusal occurred during minicensus collection)
  - 3. Enumeration then minicensus
- There exists a fourth edge-case which is:
  - 4. Minicensus (no enumeration)
- The above can occur in the case of the enumeration team (a) missing a house or (b) a house being constructed after enumeration but prior to minicensus.

### Tanzania

- The data collection team goes to a hamlet.  
- The data collection team goes house-by-house to _every_ house in that hamlet.
- _Every_ house is registered either :
- A. In the `minicensus` form (if they choose to participate)
- B. In the `refusals` form (if they decline to participate)
