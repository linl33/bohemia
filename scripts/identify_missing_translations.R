library(readxl)
library(tidyverse)
df <- read_xlsx('census.xls', sheet = 2)

# Labels
cat(paste0(which(is.na(df$`label::Portuguese`) & !is.na(df$`label::English`)) + 1, collapse = '\n'))

# Hints
cat(paste0(which(is.na(df$`hint::Portuguese`) & !is.na(df$`hint::English`)) + 1, collapse = '\n'))

missing_hints <- df %>%
  mutate_(other_language = paste0('hint::', language))
missing_hints <- which(is.na(df %>% .$paste0('hint::', language))) & !is.na(df$`hint::English`)
