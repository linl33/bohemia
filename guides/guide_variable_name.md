# Guide for census variable naming scheme

This guide will describe the scheme databrew used to name the variables. 

## Survey type, section, and description.

There are 3 aspects of our variable naming scheme: 
(1) The survey type
(2) The section
(3) And the description

#### Survey type and section
- Databrew uses underscores to separate strings in our variable name.
- There are two forms: (1) The household survey and (2) the individual survey.
- Variables in the household survey will start with the acronym 'hh'.
- Variables in the individual survey will start with 'idv'.
- The next string will follow an underscorer and represent the sections within the two surveys.

#### Description
- The first two strings in the variable name (separated by an underscore) represent the location of the question (survey and section).
- The following strings describe the content of the question. These are also separated by an underscore and can consist of multiple strings. 
- The trade off is between the descriptive detail of the variable name and it's size. 

Example 1: 
- Survey type = 'Household'
- Section = 'Household head'
- Question = 'Household head's given name(s)?'
- Variable name = 'hh_head_surname'. 
 - the first string ('hh') represents the household survey.
 - the second string ('head') represents the section Household head.
 - the third string ('surname') describes the variable.

Example 2: 
- Survey type = 'Individual'. 
- Section = 'Health morbidity information'
- Question = 'Have you had any other other diseases in the past 15 days?'
- Variable name = 'idv_health_any_diseases_past_15'. 
 - the first string ('idv') represents the individual survey.
 - the second string ('health') represents the section Health morbidity infromation.
 - the third string ('any_diseases_past_15') describes the variable.
