
##################################################
# UI
##################################################
#' @import shiny
#' @import shinydashboard
#' @import leaflet
#' @import shiny
#' @import ggplot2
#' @import gt
#' @import sp
#' @import DT
app_ui <- function(request) {
  options(scipen = '999')
  
  tagList(
    mobile_golem_add_external_resources(),
    
    dashboardPage(
      dashboardHeader(title = tags$a(tags$img(src='www/logo.png',height='32',width='36', alt = 'BohemiApp')),
                      tags$li(class = 'dropdown',
                              tags$style(type='text/css', "#log_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: 10px; margin-bottom: -12px;}"),
                              tags$li(class = 'dropdown',
                                      uiOutput('log_ui')))),
      dashboardSidebar(
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
        )),
      dashboardBody(
        
        # tags$head(
        #   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        # ),

        tabItems(
          tabItem(
            tabName="main",
            ui_main),
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
    )
  )
  
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
    'www', system.file('app/www', package = 'bohemia')
  )
  
  
  # share <- list(
  #   title = "Databrew's COVID-19 Data Explorer",
  #   url = "https://datacat.cc/covid19/",
  #   image = "http://www.databrew.cc/images/blog/covid2.png",
  #   description = "Comparing epidemic curves across countries",
  #   twitter_user = "data_brew"
  # )
  
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
    # includeScript(system.file('app/www/dtselect.js', package = 'saint')),
    # includeScript('inst/app/www/script.js'),
    
    # includeScript('www/google-analytics.js'),
    # If you have a custom.css in the inst/app/www
    tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
    # tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
  )
}

##################################################
# SERVER
##################################################
#' @import shiny
#' @import leaflet
#' @import yaml
#' @import lubridate
#' @import gt
#' @import DT
app_server <- function(input, output, session) {
  
  
  # Define a summary data table (from which certain high-level indicators read)
  default_aggregate_table <- tibble(forms_submitted = 538,
                                    active_fieldworkers = 51,
                                    most_recent_submission = 12.6)
  
  # Define a action table example
  default_action_table <- tibble(ID = 87:89,
                                 Type = c('Anomaly',
                                          'Anomaly',
                                          'Error'),
                                 Description = c('3 consecutive houses for one fieldworker with no head-of-household substitute',
                                                 'Household with > 100 animals',
                                                 'Mismatch between number of household members and number of individual forms')
  )
  
  # Define a default fieldworkers data
  default_fieldworkers <- tibble(id = sort(sample(1:300, size = 10)),
                                 name = c('John Doe',
                                          'Jane Doe',
                                          'Abraham Lincoln',
                                          'Maurice Fromage',
                                          'Pepe Birra',
                                          'Ebenezer Scrooge',
                                          'Byron Bryon',
                                          'Anabel García',
                                          'Camille de la Croix',
                                          'Raquel Manhiça'))
  
  # Define a default notificaitons table
  default_notifications <- 
    tibble(ID = c(101, 144, 149),
           Type = c('Individual', 'Aggregate', 'Individual'),
           Description = c('Worker 167: 4 days without submissions',
                           'Overall: 12 hours with no submissions',
                           'Worker 003: > 15% missingness on form 20920101'))
  
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
                                 fieldworkers = default_fieldworkers,
                                 notifications = default_notifications)
  
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
  
  # # Main UI ##########################################################
  
  output$main_plot <- renderPlot({
    shp <- bohemia::mop2
    geo <- input$geo
    if(geo == 'Rufiji'){
      shp <- bohemia::ruf2
    }
    if(geo == 'Both'){
      shp = rbind(ruf2, mop2)
      coords <- coordinates(shp)
      afr <- rbind(moz0, tza0)
      plot(afr, col = adjustcolor('black', alpha.f = 1), border = NA)
      plot(shp, col = 'red', add = T)
      # points(coords, col = 'red', pch = 16)
      lines(coords, col = 'red', lty =2)
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
                                       p('Select a row and then click one of the below:')
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
                               box(width = 9,
                                   color = 'purple',
                                   DT::dataTableOutput('notifications_table')),
                               box(width = 3,
                                   fluidPage(
                                     fluidRow(
                                       p('Select a row and then click the below:')
                                     ),
                                     fluidRow(actionButton('discard_notification',
                                                           'Discard notification'))
                                   ))
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
    sr <- input$action_table_rows_selected
    action <- session_data$action
    this_row <- action[sr,]
    
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
  
  # Observe the notification disregard
  observeEvent(input$discard_notification,{
    sr <- input$notifications_table_rows_selected
    notifications <- session_data$notifications
    message('sr is ', sr)
    vals <- 1:nrow(notifications)
    vals <- vals[!vals %in% sr]
    notifications <- notifications[vals,]
    session_data$notifications <- notifications
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
    DT::datatable(action)
  })
  
  # Notifications table
  output$notifications_table <- DT::renderDataTable({
    notifications <- session_data$notifications
    DT::datatable(notifications)
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

app <- function(){
  # Detect the system. If on AWS, don't launch browswer
  is_aws <- grepl('aws', tolower(Sys.info()['release']))
  shinyApp(ui = app_ui,
           server = app_server,
           options = list('launch.browswer' = !is_aws))
}