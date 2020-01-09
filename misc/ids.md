# IDs handling

This document gives an overview of the Bohemia project's approach to handling IDs and location data.

## Overview

The census portion of the Bohemia research project requires that each household and household member be identified and identifiable over time. This means assigning a unique ID to each household and member at the time of the census. This document gives details on the system for assigning those IDs.

## Nomenclature

### Household ID nomenclature

The Bohemia household ID is a six-character alphanumeric code consisting of (i) a three-character code indicating the hamlet/bairro followed by (ii) a 3 number code. In the case of Tanzania, the initial three-character code is made up of letters (for example, "ABC"); in the case of Mozambique, the initial three-character code is made up of numbers (for example, "123"). For example, for a house in the imaginary village of "Asante", its code might be `ASA536` whereby `ASA` indicates that the house is located in the hamlet/bairro of Asante, and 536 is the sequential number assigned to that house at the time of enumeration.  

#### A note on the 3-character bairro/hamlet code

For areas using the letter naming system (Tanzania), the three-character location code which forms the first half of the location ID will be similar in name to the location which it represents (ie, `ASA` for Asante). That said, there are cases in which multiple locations beginning with the same 3 letters (for example, "Asante" and "Asambogo"). For this reason, the 3-letter codes are generated _a priori_ and are built into the Bohemia Census form (as well as available via web application). When assigning IDs, fieldworkers should use DataBrew tools (the census form or web app) so as to ensure that they are using the correct codes; they should not create codes _ad hoc_.

#### How to get codes

There are three ways to get the "official" location ID for a given hamlet.  

1. Location IDs are viewable [in this spreadsheet](https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765).
2. They are also retrievable using the DataBrew Bohemia R package function `get_location_code()`, or in the `locations` object in the same package
3. Finally, one can view location IDs in the operation helper app at http://bohemia.team:3838/operations/ and clicking "Location codes" in the left sidebar menu:

![](img/locations.png)


### Person ID nomenclature

The person ID is a simple extension of the household ID at which the person was first censed. It consists of (i) the 6-character household ID followed by (ii) a 3 digit ID-specific to that person. For example, the head of household at the aforementioned house (`ASA-536`) might have an ID like `ASA-536-001`. This person's ID is "permanent" in the sense that (s)he would retain that ID number even in the case of (a) moving to a new house, (b) dying, (c) remaining in the house but being replaced as head of household, (d) emigrating, or (e) being lost to follow-up. In other words, the 9-character person ID is issued only once, to only one person, and that person is never issued more than one ID.

The assignation of person IDs within a household is sequential (ie, starting with 01 and going upwards) (the only exception being non-resident household members - see next section).

#### A note on non-residents

Non-resident household members should be assigned an ID beginning at number 901 and increasing thereafter sequentially.

## How to assign individual IDs

- Individual IDs are assigned at the moment of data entry in the census form. A default ID is automatically generated as a function of the sequence of data collection. The default ID schema is `001` for the head of household `002` (and sequentially increasing) for the household head substitute, and `003` (or more, in the case of multiple household head substitutes) and upwards for the other household members.
- However, there are edge cases in which the default should not be used.
  - Edge case A: Non-resident household members' automatic ID generation should be overridden so as to begin their number with "9", ie `901`.
  - Edge case B: An option exists to "override" automatic assignation (ie, assign number "5" to someone who was automatically going to receive number "1"). This is only applicable to cases of (a) interrupted visits requiring a device shut-down/exit or (b) a return/follow-up visit.
  - Edge case C: A "retrieval" option will be implemented for getting a list of the names and IDs of the members of a household who have already been enrolled in the census. Since houses are generally censed in one-go (ie, not requiring return visits), and since internet connectivity is intermittent in some areas, this should only be useful in exceptional circumstances.


## How to assign household IDs

There are two methods for household "enumeration" (ie, the assignation of IDs to households). Mozambique will use the "a priori" method, and Tanzania will use the "on the fly" method.

### Method 1: A priori

The "a priori" method means assigning a number to every household in a hamlet/village _prior_ to collecting data from any of those households. The advantage of this method is that it decreases the likelihood of duplication and saves the data collectors time. It also allows for a more systematic/organized approach to enumerating. The disadvantage is that it requires two household visits.

#### Steps

- Go to http://bohemia.team:3838/operations and enter into the drop down menus the location of the hamlet/bairro to be enumerated by the pre-census enumeration team:
![](img/locationsdrop.png =150x)
- In the far right of the page, under "Utilities", click on "Print enumeration lists" button.
- Enter (a) estimated number of households and (b) the number of teams which will enumerate the hamlet/bairro (normally there is just one):
![](img/enumeration1.png = 100x)
- The web application will generate printable lists in which there is one page for each team
- Deploy the enumeration team(s) to the field with their list. They should then manually cross off each household ID number as it is assigned/painted.

### Method 2: On the fly

The "on the fly" method means assigning a number to each household at the same time as the census data collection visit. The advantage of this method is that it does not require two separate visits to a household. The disadvantage is the possibility of ID duplications - that is, because houses are being assigned IDs in the same village simultaneously, there is a risk that two houses will get the same ID number.

In order to eliminate the risk of duplicates, the "on the fly" method uses the same enumeration list approach as the "a priori" method. The main difference is that the "on the fly" approach has many different people/teams simultaneously enumerating (whereas the "a priori" approach generally has only one enumeration team in a hamlet at any given time). Because in the "on the fly" method there are many simultaneous enumerators, it is important that pre-printed, unique enumeration lists be used.

#### Steps
- Go to http://bohemia.team:3838/operations and enter into the drop down menus the location of the hamlet/bairro to be enumerated and censed simultaneously:
![](img/locationsdrop.png =150x)
- In the far right of the page, under "Utilities", click on "Print enumeration lists" button.
- Enter (a) estimated number of households and (b) the number of workers which will cense the hamlet/bairro (there will often be multiple):
![](img/enumeration1.png = 100x)
- The web application will generate printable lists in which there is one page for each worker
- Deploy the workers to the field with their list. They should then manually cross off each household ID number as it is assigned/painted.

## Verification  
- It is of vital importance that:
  - household numbers be unique
  - household numbers be correct (ie, coded for their corresponding hamlets)
  - household numbers be unique
- Because many areas do not have internet connectivity, and because census fieldworkers may be carrying out data offline data collections simultaneously, there is no reliable, automated way to verify data entries in real time.
- However, on the server-side, an automated script is set up to detect ID abnormalities as soon as they are entered (ie, as soon as a fieldworker synchronizes). When an abnormality (duplicate, skipped ID, miscoded hamlet, etc.) occurs, the abnormality is logged and an "event" is triggered in the data manager web application requiring correction or confirmation.
