# IDs handling

This document gives an overview of the Bohemia project's approach to handling location data.

## Overview

The census portion of the Bohemia research project requires that each household and household member be identified and identifiable over time. This means assigning a unique ID to each household and member at the time of the census. This document gives details on the system for assigning those IDs.

## Nomenclature

### Household ID nomenclature

The Bohemia household ID is a six-character alphanumeric code consisting of (i) a three-letter code indicating the hamlet/bairro followed by (ii) a 3 number code. For example, for a house in the imaginary village of "Asante", its code might be `ASA536` whereby `ASA` indicates that the house is located in the hamlet/bairro of Asante, and 536 is the sequential number assigned to that house at the time of enumeration.  

#### A note on the 3-character bairro/hamlet code

The three-character location code which forms the first half of the location ID will be similar in name to the location which it represents (ie, `ASA` for Asante). That said, there are cases in which multiple locations beginning with the same 3 letters (for example, "Asante" and "Asambogo"). For this reason, the 3-letter codes are generated _a priori_ and are built into the Bohemia Census form (as well as available via web application). When assigning IDs, fieldworkers should use DataBrew tools (the census form or web app) so as to ensure that they are using the correct codes; they should not create codes _ad hoc_.

There are three ways to get the "official" location ID for a given hamlet.  

1. Location IDs are viewable [in this spreadsheet](https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765).
2. They are also retrievable using the DataBrew Bohemia R package funtion `get_location_code()`.
3. Finally, one can view location IDs in the operation helper app at http://bohemia.team:3838/operations/

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

There are two methods for household "enumeration" (ie, the assignation of IDs to households). It is our current understanding that Mozambique will use method 1 and Tanzania will use method 2.

### Method 1: A priori

The "a priori" method means assigning a number to every household in a hamlet/village _prior_ to collecting data from any of those households. The advantage of this method is that it decreases the likelihood of duplication and saves the data collectors time.

#### Steps

- Go to http://bohemia.team:3838/operations and enter the location of the hamlet/bairro to be enumerated by the pre-census enumeration team
- In the far right of the page, under "Utilities", click on "Print enumeration lists"
- Enter (a) estimated number of households and (b) the number of teams which will enumerate the hamlet/bairro (normally there is just one)
- The web application will generate printable lists in which there is one page for each team
- Deploy the enumeration team(s) to the field with their list. They should then manually cross off each household ID number as it is assigned/painted.

### Method 2: On the fly

The "on the fly" method means assigning a number to each household at the same time as the census data collection visit. The advantage of this method is that it does not require two separate visits to a household. The disadvantage is the possibility of ID duplications - that is, because houses are being assigned IDs in the same village simultaneously, there is a risk that two houses will get the same ID number.

#### Steps

- (Pending confirmation that Tanzania will indeed use this method, and details re: number of fieldworkers per hamlet)
