library(shiny)
library(shinydashboard)
library(shinydashboardPlus)

source('global.R')

###########################################################################
# HEADER
###########################################################################
header <- dashboardHeader(title = tags$a(tags$img(src='logo.png',height='32',width='36', alt = 'BohemiApp')),
                          tags$li(class = 'dropdown',
                                  tags$style(type='text/css', "#log_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: 10px; margin-bottom: -12px;}"),
                                  tags$li(class = 'dropdown',
                                          uiOutput('log_ui'))))

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
      tabName = 'tech',
      icon = icon('laptop-code'),
      startExpanded = FALSE,
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
             tabName = 'science',
             icon = icon('microscope'),
             startExpanded = FALSE,
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
                                 access = c("field_monitoring", "data_management", "server_status", "demography", "socioeconomics", "veterinary", "environment", "health", "malaria"),
                                 country = 'MOZ')
  
  # Create some reactive data
  session_data <- reactiveValues(aggregate_table = default_aggregate_table,
                                 action = default_action_table,
                                 fieldworkers = default_fieldworkers)
  
  # Text for incorrect log-in, etc.
  reactive_log_in_text <- reactiveVal(value = '')
  
  # Observe the corner log-in / log-out buttons
  observeEvent(input$log_in_button, {
    # See if there was an incorrect user/password combo
    info_text <- reactive_log_in_text()
    make_log_in_modal(info_text = info_text)
  })
  
  observeEvent(input$confirm_log_in,{
    # Run a check on the credentials
    liu <- input$log_in_user
    lip <- input$log_in_password
    ok <- credentials_check(user = liu,
                            password = lip)
    if(ok){
      message('---Correct user/password. Logged in.')
      session_info$logged_in <- TRUE
      reactive_log_in_text('')
      removeModal()
    } else {
      message('---Incorrect user/password. Not logged in.')
      session_info$logged_in <- FALSE
      removeModal()
      reactive_log_in_text(span('Incorrect user/password combo. Please try again.', style="color:red"))
      info_text <- reactive_log_in_text()
      make_log_in_modal(info_text = info_text)
    }
    
  })
  
  observeEvent(input$log_out_button, {
    session_info$logged_in <- FALSE
    removeModal()
  })
  
  
  ###########################################################################
  # LOG-IN
  ###########################################################################
  # observeEvent(session_info$logged_in,{
  #     li <- session_info$logged_in
  #     if(li){
  #         removeModal()
  #     }
  # })
  
  ###########################################################################
  # UIs
  ###########################################################################
  
  # Main UI ##########################################################
  output$ui_main <- renderUI({
    si <- session_info
    li <- si$logged_in
    ac <- 'field_monitoring' %in% si$access
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                fluidRow(column(12, align = 'center',
                                h1('BohemiApp'))),
                fluidRow(column(12, align = 'center',
                                h3('The Bohemia Data Portal'))),
                fluidRow(column(12, align = 'center',
                                selectInput('geo',
                                            'Choose your geography',
                                            choices = c('Rufiji',
                                                        'Mopeia',
                                                        'Both')))),
                fluidRow(column(12, align = 'center',
                                plotOutput('main_plot'))),
              )
            })
  })
  
  output$main_plot <- renderPlot({
    shp <- bohemia::mop2
    geo <- input$geo
    if(geo == 'Rufiji'){
      shp <- bohemia::ruf2
    }
    if(geo == 'Both'){
      shp = rbind(ruf2, mop2)
      coords <- coordinates(shp)
      plot(shp, col = 'black')
      points(coords, col = 'red', pch = 16)
      lines(coords, col = 'red')
    } else {
      plot(shp, col = 'black')
    }
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
            ok = {
              
              # Get the aggregate table
              aggregate_table <- session_data$aggregate_table
              
              fluidPage(
                fluidRow(column(12, align = 'center',
                                h1('Field monitoring'))),
                tabsetPanel(
                  tabPanel('Alerts',
                           fluidPage(
                             br(),
                             fluidRow(h3('Action required')),
                             fluidRow(
                               box(width = 9,
                                   # icon = icon('table'),
                                   color = 'orange',
                                   DT::dataTableOutput('action_table')),
                               box(width = 3,
                                   fluidPage(
                                     fluidRow(
                                       p('Select a row (or rows) and then click one of the below:')
                                     ),
                                     fluidRow(
                                       
                                       column(12, align = 'center',
                                              actionButton('confirm_correct',
                                                           'Confirm correct'),
                                              br(),br(),
                                              actionButton('submit_fix',
                                                           'Submit fix'))
                                       
                                       
                                     )
                                   ))
                             ),
                             br(),
                             fluidRow(h3('Notifications')),
                             fluidRow(
                               infoBox(icon = icon('table'),
                                       color = 'purple',
                                       h3('Some content here.'))
                             )
                           )),
                  tabPanel('Aggregate data',
                           fluidPage(
                             # br(),
                             fluidRow(
                               infoBox(width = 4,
                                       icon = icon('address-book'),
                                       color = 'black',
                                       title = 'Forms submitted',
                                       column(12,
                                              align = 'center', h1(aggregate_table$forms_submitted))),
                               infoBox(title = 'Active fieldworkers',
                                       icon = icon("user"),
                                       color = 'black',
                                       column(12,
                                              align = 'center',
                                              h1(aggregate_table$active_fieldworkers))),
                               infoBox(title = 'Minutes since last form',
                                       icon = icon("business-time"),
                                       color = 'black',
                                       column(12,
                                              align = 'center',
                                              h3(aggregate_table$most_recent_submission)                                                  ))
                             ),
                             fluidRow(
                               box(title = 'Forms submitted',
                                   width = 6,
                                   leafletOutput('field_monitoring_map_forms')),
                               box(title = 'Estimated completion by ward',
                                   width = 6,
                                   leafletOutput('field_monitoring_map_coverage'))
                             ),
                             fluidRow(
                               column(6)
                             ))),
                  tabPanel('Individual data',
                           fluidPage(
                             fluidRow(
                               infoBox(title = 'Number of detected anomalies',
                                       icon = icon('microscope'),
                                       color = 'black',
                                       width = 6,
                                       h1(7)),
                               infoBox(title = 'Missing response rate',
                                       icon = icon('address-book'),
                                       color = 'black',
                                       width = 6,
                                       h1('4.2%'))
                             ),
                             fluidRow(
                               column(4, 
                                      selectInput('fid',
                                                  'Fieldworker',
                                                  choices = session_data$fieldworkers$name),
                                      tableOutput('individual_details')),
                               box(width = 8,
                                   title = 'Location of forms submitted by this worker',
                                      leafletOutput('individual_map'))
                             ),
                             fluidRow(
                               box(width = 12,
                                   title = 'Individual performance table',
                                   DT::dataTableOutput('individual_table'))
                             )
                             ))
                )
              )
            })
  })
  
  # Observe corrections confirmation
  observeEvent(input$confirm_correct,{
    # Capture selected rows
    sr <- input$action_table_rows_selected
    # If more than 0, show the modal
    ok <- length(sr) > 0
    if(ok){
      
      action <- session_data$action
      this_row <- action[sr,][1,]
      
      showModal(
        modalDialog(
          title = 'Can you confidently confirm that the below information is correct and not a data-entry error?',
          size = 'm',
          easyClose = TRUE,
          fade = TRUE,
          footer = modalButton('Go back'),
          fluidPage(
            fluidRow(HTML(knitr::kable(this_row, 'html'))),
            fluidRow(column(12, align = 'center',
                            actionButton('confirm_correct_again',
                                         'Confirm')))
          )
        )
      )
    }
  })
  
  observeEvent(input$confirm_correct_again,{
    sr <- input$action_table_rows_selected
    action <- session_data$action
    message('sr is ', sr)
    vals <- 1:nrow(action)
    vals <- vals[!vals %in% sr]
    action <- action[vals,]
    session_data$action <- action
    removeModal()
  })
  
  # Observe the fix submission
  observeEvent(input$submit_fix,{
    
    showModal(
      modalDialog(
        title = 'Provide information on the fix',
        size = 'm',
        easyClose = TRUE,
        fade = TRUE,
        footer = modalButton('Go back'),
        fluidPage(
          fluidRow(h3('The problem:')),
          fluidRow(HTML(knitr::kable(this_row, 'html'))),
          fluidRow(h3('The fix:')),
          fluidRow(textAreaInput('fix_details', 'Fix details:')),
          fluidRow(column(12, align = 'center',
                          actionButton('send_fix',
                                       'Send fix')))
        )
      )
    )
  })
  
  # Confirm a fix send
  observeEvent(input$send_fix,{
    sr <- input$action_table_rows_selected
    action <- session_data$action
    message('sr is ', sr)
    vals <- 1:nrow(action)
    vals <- vals[!vals %in% sr]
    action <- action[vals,]
    session_data$action <- action
    removeModal()
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
  
  # Meta UI elements (ie, those that go across tabs) ####################
  
  # Log in / out button in the upper right
  output$log_ui <- renderUI({
    li <- session_info$logged_in
    make_log_in_button(li)
  })
  
  # Main UI elements ####################################################
  
  
  # Field monitoring UI elements ########################################
  
  # Action table
  output$action_table <- DT::renderDataTable({
    action <- session_data$action
    print(action)
    DT::datatable(action)
  })
  
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
  
  output$individual_map <- 
    renderLeaflet({
      x <- input$fieldworker
      fake_map(with_points = 95,
               tile = 'Stamen.Toner',
               with_polys = FALSE)
    })
  
  output$individual_table <-
    DT::renderDataTable({
      tibble(a = 1:10,
             b = sample(1:1000, 10),
             c = sample(letters, 10),
             d = sample(LETTERS, 10))
    })
  
  output$individual_details <- 
    renderTable({
      who <- input$fid
      id <- sample(1:600, 1)
      last_upload <- as.character(Sys.time() - 100000)
      total_forms <- 91
      average_time <- 63
      tibble(key = c('Name', 'ID', 'Last upload', 'Total forms',
                     'Avg time'),
             value = c(input$fid, id, last_upload, total_forms, average_time))
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
