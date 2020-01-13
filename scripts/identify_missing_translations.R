library(readxl)
library(tidyverse)
df <- read_xlsx('census.xls', sheet = 2)

# Labels
cat(paste0(which(is.na(df$`label::Swahili`) & !is.na(df$`label::English`)) + 1, collapse = '\n'))

# Hints
cat(paste0(which(is.na(df$`hint::Swahili`) & !is.na(df$`hint::English`)) + 1, collapse = '\n'))
