library(rmarkdown)

languages <- c('English', 'Portuguese', 'Swahili')

for(i in 1:length(languages)){
  message(i, ' part 1')
  try({detach("package:kableExtra", unload=TRUE)})
  this_language <- languages[i]
  render("data_dictionary.Rmd", params = list(language = this_language),
         output_file = paste0(this_language, '.pdf'))
  
  # HTML
  message(i, ' part 2')
  try({detach("package:kableExtra", unload=TRUE)})
  render("data_dictionary_html.Rmd", params = list(language = this_language, 
                                                   relevant = TRUE, 
                                                   include_variable_names = TRUE,
                                                   choice_names_too = TRUE,
                                                   invisibilize = TRUE),
         output_file = paste0(this_language, '_technical.html'))
  
  
  # try({detach("package:kableExtra", unload=TRUE)})
  # render("data_dictionary.Rmd", params = list(language = this_language, relevant = TRUE, include_variable_names = TRUE, choice_names_too = TRUE),
  #        output_file = paste0(this_language, '_with_flow.pdf'))
  # detach("package:kableExtra", unload=TRUE)
  
  
}
