library(shiny)
library(shinydashboard)

source('global.R')

header <- dashboardHeader(title = tags$a(tags$img(src='logo.png',height='32',width='36', alt = 'DataBrew')))
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            text="Main",
            tabName="main",
            icon=icon("archway")),
        menuItem(
            text="Server status",
            tabName="server_status",
            icon=icon("server")),
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
            uiOutput('ui_main')),
        tabItem(
            tabName = 'server_status',
            uiOutput('ui_server_status')
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
ui <- dashboardPage(header, sidebar, body, skin="blue", title = 'databrew')

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
                                   icon = icon('wave')),
                      
                      fluidRow(
                          column(6,
                                 h3('Geography'))
                      ),
                      fluidRow(
                          column(6,
                                 selectInput('geo',
                                             'Select a Geography level',
                                             choices = c('Country', 'Region', 'District', 'Ward', 'Village', 'Hamlet'),
                                             selected = 'Country')),
                          column(6,
                                 # uioutputs to depend on what level the user specifies
                                 uiOutput('geo_region'),
                                 uiOutput('geo_district'),
                                 uiOutput('geo_ward'),
                                 uiOutput('geo_village'),
                                 uiOutput('geo_hamlet')),
                      ),
                      br(), br(),
                      fluidRow(
                          column(3,
                                 box(id = 'questionnaire',
                                     title = 'Questionnaires completed',
                                     status = 'primary', 
                                     solidHeader = TRUE, 
                                     width = 12)),
                          column(3,
                                 box(id = 'num_fw',
                                     title = 'Number of active fieldworkers',
                                     status = 'success', 
                                     solidHeader = TRUE, 
                                     width = 12)),
                          column(3,
                                 box(id = 'other_1',
                                     title = 'Other stats',
                                     status = 'info', 
                                     solidHeader = TRUE, 
                                     width = 12)
                          ),
                          column(3,
                                 box(id = 'other_2',
                                     title = 'Other stats',
                                     status = 'warning', 
                                     solidHeader = TRUE, 
                                     width = 12))
                          
                      ), 
                      br(),
                      fluidRow(
                          column(6,
                                 h3('Field workers'))
                      ),
                      br(), br(),
                      fluidRow(
                          column(6,
                                 selectInput('field_worker',
                                             'Select Field worker ID',
                                             choices = c('011', '235', '813', '213'),
                                             selected = '011'))
                      ),
                      br(),
                      fluidRow(
                          column(6, 
                                 dataTableOutput('fw_performance')),
                          column(6,
                                 leafletOutput('fw_map'))
                      ),
                      br(), br(),
                      fluidRow(
                          column(6,
                                 box(id = 'alerts',
                                     title = 'Alerts',
                                     status = 'danger',
                                     footer = 'Errors and discrepancies')),
                          column(6,
                                 box(id = 'actions',
                                     title = 'Action items',
                                     status = 'danger')),
                          
                      )
            )
        } else {
            #UI if the user is not logged in
            fluidPage(h3('Log in to see cool stuff'),
                      actionButton('log_in_button',
                                   'Click here to log in',
                                   icon = icon('door')))
        }
    })
    
    output$ui_server_status <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        
        # UI if the user is logged in
        if(li){
            
            
            
            fluidRow(
                column(12, 
                       dataTableOutput('server_activity'))
            )
            
            
        } else {
            #UI if the user is not logged in
            fluidPage(h3('Log in on main page to access content'))
        }
    })
    
    # Observe the log-in / log-out buttons and update the session data
    observeEvent(input$log_in_button, {
        session_data$logged_in <- TRUE
    })
    observeEvent(input$log_out_button, {
        session_data$logged_in <- FALSE
    })
    
    # placehold for mozambique field worker table 
    output$fw_performance <- DT::renderDataTable({
        # check if user is logged in
        li <- session_data$logged_in
        # if logged in, show table
        if(li){
            fake_data <- data_frame('fw_id' = c('012', '034', '054'),
                                    'Number of houses surveyed' = c(3, 1, 5),
                                    'Number of houses to go' = c(6, 6, 8),
                                    'Average duration of interviews (minutes)' = c(40, 34.5, 56.4))
            datatable(fake_data)
        } else {
            NULL
        }
    })
    # placeholder for mozambique map 
    output$fw_map <- renderLeaflet({
        # check if user is logged in
        li <- session_data$logged_in
        # if logged in, show map
        if(li){
            moz <- getData(country = 'MOZ', level = 0)
            leaflet() %>%
                addProviderTiles("Esri.WorldImagery") %>%
                addPolygons(data = moz)
        } else {
            NULL
        }
    })
    
    # table for server activity
    output$server_activity <- DT::renderDataTable({
        # check if user is logged in
        li <- session_data$logged_in
        # if logged in, show table
        if(li){
            fake_data <- data_frame('Server' = c('Spain', 'Moz', 'TZ'),
                                    'Total memory (TB)' = c(10.5, 10.5, 25),
                                    'Memory in use (TB)' = c(4.5, 3.2, 7.9))
            datatable(fake_data)
        } else {
            NULL
        }
    })
}

shinyApp(ui, server)#
