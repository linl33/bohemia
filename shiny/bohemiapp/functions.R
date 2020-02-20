placeholder <- function(li = FALSE){
  if(li){
    fluidPage(h3('This is the logged-in UI'))
  } else {
    #UI if the user is not logged in
    fluidPage(h3('This is the logged-out UI'))
  }
}

make_log_in_ui <- function(li = FALSE){
  if(li){
    fluidPage(h3('This is the logged-in UI'),
              actionButton('log_out_button',
                           'Click here to log out',
                           icon = icon('wave')))
  } else {
    #UI if the user is not logged in
    fluidPage(h3('Log in to see cool stuff'),
              actionButton('log_in_button',
                           'Click here to log in',
                           icon = icon('door')))
  }
}

# Function for generating the about page
make_about <- function(){
  fluidPage(
    fluidRow(
      div(img(src='logo.png', align = "center"), style="text-align: center;"),
      h4('Built in partnership with ',
         a(href = 'http://databrew.cc',
           target='_blank', 'Databrew'),
         align = 'center'),
      p('Empowering research and analysis through collaborative data science.', align = 'center'),
      div(a(actionButton(inputId = "email", label = "info@databrew.cc", 
                         icon = icon("envelope", lib = "font-awesome")),
            href="mailto:info@databrew.cc",
            align = 'center')), 
      style = 'text-align:center;'
    )
  )
}