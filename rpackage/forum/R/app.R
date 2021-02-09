
##################################################
# UI
##################################################
#' @import shiny
#' @import shinydashboard
#' @import leaflet
#' @import shiny
#' @import ggplot2
#' @import googlesheets4
#' @import DT
#' @import shinyMobile
app_ui <- function(request) {
  options(scipen = '999')
  
  tagList(
    mobile_golem_add_external_resources(),
    
    dashboardPage(
      dashboardHeader (title = "Databrew Dashboard"),
      dashboardSidebar(
        sidebarMenu(
          menuItem(
            text="Main",
            tabName="main"),
          menuItem(
            text = 'About',
            tabName = 'about')
        )),
      dashboardBody(
        # tags$head(
        #   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        # ),
        tabItems(
          tabItem(
            tabName="main",
            fluidPage(
              fluidRow(
                DT::dataTableOutput('contact_table')
              )
            )
          ),
          tabItem(
            tabName = 'about',
            fluidPage(
              fluidRow(
                div(img(src='logo_clear.png', align = "center"), style="text-align: center;"),
                h4('Built in partnership with ',
                   a(href = 'https://databrew.cc',
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
          )
        )
      )
    )
  )
}



##################################################
# SERVER
##################################################
#' @import shiny
#' @import leaflet
app_server <- function(input, output, session) {
  
  # create a reactive dataframe to store data
  x = reactiveValues(df=NULL)
  observe({
    df <- googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/1qDxynnod4YZYzGP1G9562auOXzAq1nVn89EjeJYgL8k/edit#gid=0') 
    # removing details for now
    df$details <- NULL
    df <- df[, c("country", "first_name", "last_name", "institution", "position", "email", "phone")]
    x$df <- df
  })
  
  # put data in table with options for saving a csv 
  output$contact_table <- DT::renderDataTable({
    # message(table_data)
    DT::datatable(x$df, editable = 'cell',extensions = 'Buttons', filter = 'top', 
                  options = list(pageLength = nrow(x$df), info = FALSE, dom='Bfrtip', buttons = list('csv')))
  })
  
  # edit table
  observeEvent(input[["contact_table_cell_edit"]], {
    cellinfo <- input[["contact_table_cell_edit"]]
    x$df <- editData(x$df, input[["contact_table_cell_edit"]], "contact_table")
  })
  
  
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
mobile_golem_add_external_resources <- function(){
  addResourcePath(
    'www', system.file('app/www', package = 'forum')
  )
  
  
  share <- list(
    title = "Bohemia forum app",
    url = "https://bohemia.team/forum/",
    image = "https://www.databrew.cc/images/logo_clear.png",
    description = "Bohemia app",
    twitter_user = "data_brew"
  )
  
  tags$head(
    
    # # Facebook OpenGraph tags
    # tags$meta(property = "og:title", content = share$title),
    # tags$meta(property = "og:type", content = "website"),
    # tags$meta(property = "og:url", content = share$url),
    # tags$meta(property = "og:image", content = share$image),
    # tags$meta(property = "og:description", content = share$description),
    # 
    # # Twitter summary cards
    # tags$meta(name = "twitter:card", content = "summary"),
    # tags$meta(name = "twitter:site", content = paste0("@", share$twitter_user)),
    # tags$meta(name = "twitter:creator", content = paste0("@", share$twitter_user)),
    # tags$meta(name = "twitter:title", content = share$title),
    # tags$meta(name = "twitter:description", content = share$description),
    # tags$meta(name = "twitter:image", content = share$image),
    # 
    # # golem::activate_js(),
    # # golem::favicon(),
    # # Add here all the external resources
    # # Google analytics script
    # includeHTML(system.file('app/www/google-analytics-mini.html', package = 'covid19')),
    # includeScript(system.file('app/www/script.js', package = 'covid19')),
    # includeScript(system.file('app/www/mobile.js', package = 'covid19')),
    # includeScript('inst/app/www/script.js'),
    
    # includeScript('www/google-analytics.js'),
    # If you have a custom.css in the inst/app/www
    tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
    # tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
  )
}

app <- function(){
  # Detect the system. If on AWS, don't launch browswer
  is_aws <- grepl('aws', tolower(Sys.info()['release']))
  shinyApp(ui = app_ui,
           server = app_server,
           options = list('launch.browswer' = !is_aws))
}