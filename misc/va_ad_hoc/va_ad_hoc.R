library(gsheet)
library(dplyr)
library(readr)

# Read in VA form
va <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1xq6nr65Rm5prK5C-vWkVJFvzCodoXGY7TJrAHxGGWZ4/edit#gid=1264701015')

# Read in VA data
real <- read_csv('~/Desktop/VA.csv')

# Order
left <- va %>%
  dplyr::select(name, Field = `label::English`) %>%
  mutate(name = tolower(name)) %>%
  filter(!is.na(name))
real <- real[,left$name[left$name %in% names(real)]]

joiny <- tibble(name = names(real)) %>%
  left_join(left) %>%
  mutate(Field = ifelse(is.na(Field), name, Field))

names(real) <- joiny$Field
write_csv(real, '~/Desktop/paula_va.csv')
