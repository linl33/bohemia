library(dplyr)
library(bohemia)
library(rmarkdown)

locs <- gps
locs <- locs %>% filter(iso == 'MOZ')

locs <- locs %>% filter(code %in% c('CIM', 'DEO', 'DEA', 'LUT', 'MIF', 'FFF'))

dir.create('pdfs2')
for(i in 1:nrow(locs)){
  message(i, ' of ', nrow(locs))
  this_loc <- locs[i,]
  lc <- this_loc$code
  this_code <- this_loc$code
  this_name <- paste0(this_loc$code)
  n_hh <- this_loc$n_households
  data <- data.frame(n_hh = n_hh,
                     n_teams = 2,
                     id_limit_lwr = 1,
                     id_limit_upr = n_hh)
  
  enum <- FALSE
  out_file <- paste0(getwd(), '/pdfs2/', this_name, '.pdf')
  rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/visit_control_sheet.Rmd'),
                    output_file = out_file,
                    params = list(data = data,
                                  loc_id = lc,
                                  enumeration = enum))
}
