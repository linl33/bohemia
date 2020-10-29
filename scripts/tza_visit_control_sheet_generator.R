library(bohemia)
library(dplyr)
library(rmarkdown)
library(gsheet)
# gps <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1016618615')
# 
# # Keep only TZA
gps <- bohemia::gps

# Keep only Tanzania
tza <- gps %>% filter(iso == 'TZA')

# Loop through each one and render pdf
dir.create('tza_visit_control_sheets')
for(i in 1:nrow(tza)){
  message(i, ' of ', nrow(tza))
  this_row <- tza[i,]  
  lc <- this_code <- this_row$code
  out_file <- paste0(getwd(), '/tza_visit_control_sheets/', this_code,  '_visit_control_sheet.pdf')
  xdata <- data.frame(n_hh = round(this_row$n_households*2),
                      n_teams = 1,
                      id_limit_lwr = 1,
                      id_limit_upr = 99999999)
  use_previous <- FALSE
  rmarkdown::render(input = 
                      paste0(system.file('rmd', package = 'bohemia'), '/visit_control_sheet.Rmd'),
                    # '../inst/rmd/visit_control_sheet.Rmd',
                    output_file = out_file,
                    params = list(xdata = xdata,
                                  loc_id = lc,
                                  enumeration = NULL,
                                  use_previous = FALSE,
                                  enumerations_data = NULL,
                                  refusals_data = NULL,
                                  minicensus_main_data = NULL,
                                  li = TRUE))
}
