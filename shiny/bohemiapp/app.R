library(shiny)
library(shinydashboard)

source('global.R')

###########################################################################
# HEADER
###########################################################################
header <- dashboardHeader(title = tags$a(tags$img(src='logo.png',height='32',width='36', alt = 'BohemiApp')))

###########################################################################
# SIDEBAR
###########################################################################
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

###########################################################################
# BODY
###########################################################################
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

###########################################################################
# UI
###########################################################################
ui <- dashboardPage(header, sidebar, body, skin="blue", title = 'BohemiApp')

# Server
server <- function(input, output, session) {
    
    ###########################################################################
    # REACTIVE OBJECTS
    ###########################################################################
    # Reactive object for seeing if logged in or not
    # (Joe will build log-in functionality later
    session_info <- reactiveValues(logged_in = FALSE,
                                   user = 'default',
                                   access = c("field_monitoring", "data_management", "server_status", "demography", "socioeconomics", "veterinary", "environment", "health", "malaria"))
    
    # Observe the log-in / log-out buttons and update the session data
    observeEvent(input$log_in_button, {
        session_info$logged_in <- TRUE
    })
    observeEvent(input$log_out_button, {
        session_info$logged_in <- FALSE
    })
    
    ###########################################################################
    # LOG-IN
    ###########################################################################
    observeEvent(session_info$logged_in,{
        li <- session_info$logged_in
        if(li){
            removeModal()
        }
    })
    
    ###########################################################################
    # UIs
    ###########################################################################
    
    # Main UI ##########################################################
    output$ui_main <- renderUI({
        # See if the user is logged in
        li <- session_info$logged_in
        if(!li){
            showModal(modalDialog(
                title = NULL,
                easyClose = TRUE,
                footer = NULL,
                fade = TRUE,
                make_log_in_ui(li)
            ))
        }
        placeholder(li)
                
    })
    
    # Field monitoring UI  #############################################
    output$ui_field_monitoring <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'field_monitoring' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        fluidRow(column(12, align = 'center',
                                        h1('Field monitoring'))),
                        tabsetPanel(
                            tabPanel('Test A',
                                     fluidPage(
                                         leafletOutput('field_monitoring_map_forms'))),
                            tabPanel('Test B',
                                     fluidPage(
                                         leafletOutput('field_monitoring_map_coverage')))
                        )
                    )
        )
    })
    
    # Data management UI  ##############################################
    output$ui_data_management <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'data_management' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Server status UI  ################################################
    output$ui_server_status <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'server_status' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Demography UI  ###################################################
    output$ui_demography <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'demography' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Socioeconomics UI  ###############################################
    output$ui_socioeconomics <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'socioeconomics' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Veterinary UI  ###################################################
    output$ui_veterinary <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'veterinary' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Environment UI  ##################################################
    output$ui_environment <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'environment' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Health UI  #######################################################
    output$ui_health <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'health' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    # Malaria UI  ######################################################
    output$ui_malaria <- renderUI({
        # See if the user is logged in and has access
        si <- session_info
        li <- si$logged_in
        ac <- 'malaria' %in% si$access
        # Generate the ui
        make_ui(li = li,
                ac = ac,
                ok = 
                    fluidPage(
                        h5('This is what the user will see if logged in and granted access.')
                    )
        )
    })
    
    ###########################################################################
    # UI ELEMENTS
    ###########################################################################
    
    # Main UI elements ####################################################

    # Field monitoring UI elements ########################################
    
    # Map of all forms filled out
    output$field_monitoring_map_forms <- 
        renderLeaflet({
            fake_map(tile = 'Esri.WorldImagery',
                     with_points = 1500,
                     with_polys = FALSE)
        })
    
    # Map of estimated coverage
    output$field_monitoring_map_coverage <- 
        renderLeaflet({
            fake_map(with_points = 0,
                     with_polys = TRUE)
        })

    # Data management UI elements #########################################

    # Server status UI elements ###########################################

    # Demography UI elements ##############################################

    # Socioeconomics UI elements ##########################################

    # Veterinary UI elements ##############################################

    # Environment UI elements #############################################

    # Health UI elements ##################################################

    # Malaria UI elements #################################################

}

shinyApp(ui, server)#
