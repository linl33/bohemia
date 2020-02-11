library(shiny)
library(shinydashboard)

source('global.R')

header <- dashboardHeader(title = tags$a(href='http://databrew.cc',
                                         tags$img(src='logo.png',height='32',width='36', alt = 'DataBrew')))
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            text="Main",
            tabName="main",
            icon=icon("archway")),
        menuItem(
            text = 'About',
            tabName = 'about',
            icon = icon("cog", lib = "glyphicon"))
    )
)

body <- dashboardBody(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
        tabItem(
            tabName="main",
            uiOutput('ui_main')
        ),
        tabItem(
            tabName = 'about',
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
        )
    )
)

# UI
ui <- dashboardPage(header, sidebar, body, skin="blue")

# Server
server <- function(input, output, session) {
    
    # Reactive object for seeing if logged in or not
    # (Joe will build log-in functionality later
    session_data <- reactiveValues(logged_in = FALSE)
    
    output$ui_main <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        
        # UI if the user is logged in
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
    })
    
    # Observe the log-in / log-out buttons and update the session data
    observeEvent(input$log_in_button, {
        session_data$logged_in <- TRUE
    })
    observeEvent(input$log_out_button, {
        session_data$logged_in <- FALSE
    })
    
   
}

shinyApp(ui, server)#
