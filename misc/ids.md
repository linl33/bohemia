# IDs handling

This document gives an overview of the Bohemia project's approach to handling location data.

## Overview

The census portion of the Bohemia research project requires that each household and household member be identified and identifiable over time. This means assigning a unique ID to each household and member at the time of the census. This document gives details on the system for assigning those IDs.

## Nomenclature

### Household ID nomenclature

The Bohemia household ID is a six-character alphanumeric code consisting of (i) a three-letter code indicating the hamlet/bairro followed by (ii) a 3 number code. For example, for a house in the imaginary village of "Asante", its code might be `ASA536` whereby `ASA` indicates that the house is located in the hamlet/bairro of Asante, and 536 is the sequential number assigned to that house at the time of enumeration.  

#### A note on the 3-character bairro/hamlet code

The three-character location code which forms the first half of the location ID will be similar in name to the location which it represents (ie, `ASA` for Asante). That said, there are cases in which multiple locations beginning with the same 3 letters (for example, "Asante" and "Asambogo"). For this reason, the 3-letter codes are generated _a priori_ and are built into the Bohemia Census form (as well as available via web application). When assigning IDs, fieldworkers should use DataBrew tools (the census form or web app) so as to ensure that they are using the correct codes; they should not create codes _ad hoc_.

### Person ID nomenclature

The person ID is a simple extension of the household ID at which the person was first censed. It consists of (i) the 6-character household ID followed by (ii) a 3 digit ID-specific to that person. For example, the head of household at the aforementioned house (`ASA536`) might have an ID like `ASA536001`. This person's ID is "permanent" in the sense that (s)he would retain that ID number even in the case of (a) moving to a new house, (b) dying, (c) remaining in the house but being replaced as head of household, (d) emigrating, or (e) being lost to follow-up. In other words, a 9-character person ID is issued only once, to only one person, and that person is never issued more than one ID.

The assignation of person IDs within a household is sequential (ie, starting with 001 and going upwards) (the only exception being non-resident household members - see next section).

#### A note on non-residents

Non-resident household members are assigned an ID beginning at number 901 and increasing thereafter sequentially.

## How to assign individual IDs

- Individual IDs are assigned at the moment of data entry in the census form. They are automatically generated as a function of the sequence of data collection.
- Edge case A: An option exists to "override" automatic assignation (ie, assign number "5" to someone who was automatically going to receive number "1"). This is only applicable to cases of (a) interrupted visits requiring a device shut-down/exit or (b) a return/follow-up visit.
- Edge case B: A "retrieval" option exists for getting a list of the names and IDs of the members of a household who have already been enrolled in the census. Since houses are generally censed in one-go (ie, not requiring return visits), and since internet connectivity is intermittent in some areas, this should only be useful in exceptional circumstances.


## How to assign household IDs

There are two methods for household "enumeration" (ie, the assignation of IDs to households). 


## Permanence and mutability

- All IDs are permanent.
- Fieldworkers: A fieldworker ID will be issued to only one person, once. If that person leaves the project, that number will never be used again
- Households: Each fieldworker has a unique set of 1,000 household IDs. Each household ID will be issued only once. If a household disappears, its ID will never be used
- Individuals: Each individual is issued a letter. Generally speaking "A" will be the head of household, but this can change. In the case of migration, birth, or death, new letters are issued. In no case will a letter for a household be re-issued to someone new

## Example QR codes

- Example QR codes are viewable at www.databrew.cc/qrs.pdf
