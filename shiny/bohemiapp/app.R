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
            text = 'Tech',
            tabName = NULL,
            icon = icon('laptop-code'),
            startExpanded = TRUE,
            menuSubItem(
                text="Field monitoring",
                tabName="field_monitoring",
                icon=icon("clipboard")),
            menuSubItem(
                text="Data management",
                tabName="data_management",
                icon=icon("database")),  
            menuSubItem(
                text="Server status",
                tabName="server_status",
                icon=icon("server"))),
        menuItem('Science',
                 tabName = NULL,
                 icon = icon('microscope'),
                 startExpanded = TRUE,
                 menuSubItem(
                     text="Demography",
                     tabName="demography",
                     icon=icon("users")),
                 menuSubItem(
                     text="Socioeconomics",
                     tabName="socioeconomics",
                     icon=icon("motorcycle")),
                 menuSubItem(
                     text="Veterinary",
                     tabName="veterinary",
                     icon=icon("piggy-bank")),
                 menuSubItem(
                     text="Environment",
                     tabName="environment",
                     icon=icon("tree")),
                 menuSubItem(
                     text="Health",
                     tabName="health",
                     icon=icon("briefcase-medical")),
                 menuSubItem(
                     text="Malaria",
                     tabName="malaria",
                     icon=icon("procedures"))),
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
            tabName="field_monitoring",
            uiOutput('ui_field_monitoring')),
        tabItem(
            tabName="data_management",
            uiOutput('ui_data_management')),
        tabItem(
            tabName="server_status",
            uiOutput('ui_server_status')),
        tabItem(
            tabName="demography",
            uiOutput('ui_demography')),
        tabItem(
            tabName="socioeconomics",
            uiOutput('ui_socioeconomics')),
        tabItem(
            tabName="veterinary",
            uiOutput('ui_veterinary')),
        tabItem(
            tabName="environment",
            uiOutput('ui_environment')),
        tabItem(
            tabName="health",
            uiOutput('ui_health')),
        tabItem(
            tabName="malaria",
            uiOutput('ui_malaria')),
        tabItem(
            tabName = 'about',
            make_about()
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
    
    # Observe the log-in / log-out buttons and update the session data
    observeEvent(input$log_in_button, {
        session_data$logged_in <- TRUE
    })
    observeEvent(input$log_out_button, {
        session_data$logged_in <- FALSE
    })
    observeEvent(session_data$logged_in,{
        li <- session_data$logged_in
        if(li){
            removeModal()
        }
    })
    
    output$ui_main <- renderUI({
        # See if the user is logged in
            li <- session_data$logged_in
            if(!li){
                showModal(modalDialog(
                    title = "Somewhat important message",
                    "This is a somewhat important message.",
                    easyClose = FALSE,
                    footer = NULL,
                    make_log_in_ui(li)
                ))
            }
                
    })
    
    output$ui_field_monitoring <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_data_management <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_server_status <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_demography <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_socioeconomics <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_veterinary <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_environment <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_health <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
    output$ui_malaria <- renderUI({
        # See if the user is logged in
        li <- session_data$logged_in
        placeholder(li)
    })
    
}

shinyApp(ui, server)#
