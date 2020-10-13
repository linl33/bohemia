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
#' @import lubridate
#' @import RPostgres
#' @import yaml
app_ui <- function(request) {
  options(scipen = '999')
  
  tagList(
    mobile_golem_add_external_resources(),
    
    dashboardPage(
      dashboardHeader(#title = tags$a(tags$img(src='www/logo.png',height='32',width='36', alt = 'BohemiApp')),
        tags$li(class = 'dropdown',
                tags$style(type='text/css', "#log_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: 10px; margin-bottom: -12px;}"),
                tags$li(class = 'dropdown',
                        radioButtons('geo', ' ',
                                     choices = c(#'Tanzania' = 'Rufiji',
                                       'Mozambique' = 'Mopeia'
                                     ),
                                     inline = TRUE,
                                     selected = 'Mopeia')),
                tags$li(class = 'dropdown',
                        uiOutput('log_ui')))),
      dashboardSidebar(
        sidebarMenu(
          menuItem(
            text="Main",
            tabName="main",
            icon=icon("archway")),
          menuItem(
            text = 'Operations',
            tabName = 'operations',
            icon = icon('laptop-code'),
            startExpanded = FALSE,
            menuSubItem(
              text="Field monitoring",
              tabName="field_monitoring",
              icon=icon("clipboard")),
            menuSubItem(
              text="Enrollment",
              tabName="enrollment",
              icon=icon("database")),  
            menuSubItem(
              text="Server status",
              tabName="server_status",
              icon=icon("server"))),
          menuItem('Research',
                   tabName = 'research',
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
          menuItem('Tracking tools',
                   tabName = 'tracking_tools',
                   icon = icon('list'),
                   startExpanded = FALSE,
                   menuSubItem(
                     text="Visit control sheet and file index and folder location",
                     tabName="visit_control_sheet",
                     icon=icon("users"))
          ),
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
            tabName="enrollment",
            uiOutput('ui_enrollment')),
          tabItem(
            tabName="server_status",
            uiOutput('ui_server_status')),
          tabItem(
            tabName="visit_control_sheet",
            fluidPage(
              fluidRow(h2('Visit control sheet and file index and folder location')),
              fluidRow(
                column(4,
                       radioButtons('country', 'Country', choices = c('Tanzania', 'Mozambique'), inline = TRUE, selected = 'Mozambique'), 
                       uiOutput('region_ui'),
                       uiOutput('district_ui'),
                       uiOutput('ward_ui'),
                       uiOutput('village_ui'),
                       uiOutput('hamlet_ui'),
                       h4('Location code:'),
                       h3(textOutput('location_code_text'))),
                column(8,
                       navbarPage(title = 'Sheets',
                                  tabPanel("Visit control sheet", 
                                           fluidPage(
                                             h3("Visit control sheet"),
                                             uiOutput('ui_enumeration_n_hh'),
                                             helpText('The default numbers shown are 25% higher than the number estimated by the village leader.'),
                                             textInput('enumeration_n_teams',
                                                       'Number of teams',
                                                       value = 2),
                                             checkboxInput('enumeration', 'Enumeration?', value = FALSE),
                                             
                                             helpText('MOZ only. Tick this box if you want to generate a list for enumerators'),
                                             checkboxInput('use_previous', 'Use previous', value = FALSE),
                                             helpText('MOZ only. "Use previous" means populating the sheet based on the previously enumerated households from the hamlet (thereby ignoring the estimated number of forms or ID limitations inputs).'),
                                             
                                             helpText('Usually, in order to avoid duplicated household IDs, there should just be one team. In the case of multiple teams, it is assumed that each team will enumerate a similar number of forms.'),
                                             uiOutput('ui_id_limit'),
                                             br(), br(),
                                             downloadButton('render_visit_control_sheet',
                                                            'Generate visit control sheet(s)')
                                           )),
                                  tabPanel("File index and folder location",
                                           fluidPage(
                                             h3("File index and folder location"),
                                             uiOutput('ui_id_limit_file'),
                                             br(), br(),
                                             downloadButton('render_file_index_list',
                                                            'Generate file index and folder location list(s)')
                                           )),
                                  tabPanel('Consent verification list',
                                           fluidPage(
                                             uiOutput('ui_verification_text_filter'),
                                             uiOutput('ui_consent_verification_list_a'),
                                             uiOutput('ui_consent_verification_list')
                                           ))))
              )
            )
          ),
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
  
  message('Working directory is :', getwd())
  
  
  # Define a summary data table (from which certain high-level indicators read)
  default_aggregate_table <- tibble(forms_submitted = 538,
                                    active_fieldworkers = 51,
                                    most_recent_submission = 12.6)
  
  
  # Define a default fieldworkers data
  if(!'fids.csv' %in% dir('/tmp')){
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0'
    fids1 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Tanzania')
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130'
    fids2 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Mozambique')
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508'
    fids3 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Catalonia')
    fids <- bind_rows(fids1, fids2, fids3)
    readr::write_csv(fids, '/tmp/fids.csv')
  } else {
    fids <- readr::read_csv('/tmp/fids.csv')
  }
  
  default_fieldworkers <- fids %>%
    dplyr::rename(id = bohemia_id) %>%
    mutate(name = paste0(first_name, ' ', last_name)) %>%
    dplyr::select(id, name)
  
  
  ###########################################################################
  # REACTIVE OBJECTS
  ###########################################################################
  # Reactive object for seeing if logged in or not
  # (Joe will build log-in functionality later
  session_info <- reactiveValues(logged_in =FALSE, 
                                 user = 'default',
                                 access = c("field_monitoring", "enrollment", 'consent_verification_list', "server_status", "demography", "socioeconomics", "veterinary", "environment", "health", "malaria"),
                                 country = 'MOZ')
  
  # Create some reactive data
  session_data <- reactiveValues(aggregate_table = data.frame(),
                                 anomalies = data.frame(),
                                 fieldworkers = default_fieldworkers)
  odk_data <- reactiveValues(data = NULL)
  load_odk_data <- function(the_country = 'Mozambique'){
    
    creds <- yaml::yaml.load_file('credentials/credentials.yaml')
    users <- yaml::yaml.load_file('credentials/users.yaml')
    psql_end_point = creds$endpoint
    psql_user = creds$psql_master_username
    psql_pass = creds$psql_master_password
    drv <- RPostgres::Postgres()
    con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                     port=5432,
                     user=psql_user, password=psql_pass)
    # Read in data
    data <- list()
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main where hh_country='", the_country, "'"))
    data$minicensus_main <- main
    ok_uuids <- paste0("(",paste0("'",main$instance_id,"'", collapse=","),")")
    
    repeat_names <- c("minicensus_people", 
                      "minicensus_repeat_death_info",
                      "minicensus_repeat_hh_sub", 
                      "minicensus_repeat_mosquito_net", 
                      "minicensus_repeat_water")
    for(i in 1:length(repeat_names)){
      this_name <- repeat_names[i]
      this_data <- dbGetQuery(con, paste0("SELECT * FROM clean_", this_name, " WHERE instance_id IN ", ok_uuids))
      data[[this_name]] <- this_data
    }
    # Read in enumerations data
    enumerations <- dbGetQuery(con, "SELECT * FROM clean_enumerations")
    data$enumerations <- enumerations
    
    # # Read in va data
    # va <- dbGetQuery(con, "SELECT * FROM clean_va")
    # data$va <- va
    # 
    # Read in refusals data
    refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
    data$refusals <- refusals
    
    # Read in corrections data
    corrections <- dbGetQuery(con, "SELECT * FROM corrections")
    data$corrections <- corrections
    
    dbDisconnect(con)
    
    return(data)
  }
  
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
    users <- yaml::yaml.load_file('credentials/users.yaml')
    liu <- input$log_in_user
    lip <- input$log_in_password
    ok <- credentials_check(user = liu,
                            password = lip,
                            users = users)
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
  
  ##################
  # LOCATION HIERARCHY UTILITIES
  ##################
  # Get the location code based on the input hierarchy
  location_code <- reactiveVal(value = NULL)
  country <- reactiveVal(value = 'Tanzania')
  observeEvent(input$geo, {
    gg <- input$geo
    if(gg == 'Rufiji'){
      the_country <- 'Tanzania'
    } else {
      the_country <- 'Mozambique'
    }
    country(the_country)
    
    # Load data     
    li <- session_info$logged_in
    if(li){
      out <- load_odk_data(the_country = the_country)
      # save(out, file = '/tmp/out.RData')
      odk_data$data <- out
    }
  })
  
  # Load correct data
  observeEvent(input$confirm_log_in, {
    the_country <- country()
    li <- session_info$logged_in
    if(li){
      out <- load_odk_data(the_country = the_country)
      odk_data$data = out
      
      anomaly_and_error_registry <- bohemia::anomaly_and_error_registry
      # save(out, file = '/tmp/out.RData')
      suppressMessages({
        anomalies <- identify_anomalies_and_errors(data = out,
                                                   anomalies_registry = anomaly_and_error_registry)
      })
      
      
      # save(corrections, anomalies, file = '/tmp/joe.RData')
      session_data$anomalies <- anomalies
      
      
    }
  })
  
  observeEvent(c(input$country,
                 input$region,
                 input$district,
                 input$ward,
                 input$village,
                 input$hamlet), {
                   country = input$country
                   region = input$region
                   district = input$district
                   ward = input$ward
                   village = input$village
                   hamlet = input$hamlet
                   
                   glc <- get_location_code(country = country,
                                            region = region,
                                            district = district,
                                            ward = ward,
                                            village = village,
                                            hamlet = hamlet)
                   location_code(glc)
                 })
  output$location_code_text <- renderText({
    lc <- location_code()
    lc
  })
  
  output$region_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country)
    choices <- sort(unique(sub_locations$Region))
    country_name <- input$country
    if(country_name == 'Mozambique'){
      selectInput('region', 'Região', choices = choices)
    } else {
      selectInput('region', 'Region', choices = choices)
    } 
  })
  
  output$district_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region)
    choices <- sort(unique(sub_locations$District))
    country_name <- input$country
    if(country_name == 'Mozambique'){
      selectInput('district', 'Distrito', choices = choices)
    } else {
      selectInput('district', 'District', choices = choices)
    }
  })
  
  output$ward_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district)
    choices <- sort(unique(sub_locations$Ward))
    country_name <- input$country
    if(country_name == 'Mozambique'){
      selectInput('ward', 'Posto administrativo/localidade', choices = choices)
    } else {
      selectInput('ward', 'Ward', choices = choices)
    }  
  })
  
  output$village_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district,
                                      ward = input$ward)
    choices <- sort(unique(sub_locations$Village))
    country_name <- input$country
    if(country_name == 'Mozambique'){
      selectInput('village', 'Povoado', choices = choices)
    } else {
      selectInput('village', 'Village', choices = choices)
    }  
  })
  
  output$hamlet_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district,
                                      ward = input$ward,
                                      village = input$village)
    choices <- sort(unique(sub_locations$Hamlet))
    country_name <- input$country
    if(country_name == 'Mozambique'){
      selectInput('hamlet', 'Bairro', choices = choices)
    } else {
      selectInput('hamlet', 'Hamlet', choices = choices)
    } 
    
  })
  
  # Get number of households for hamlet selected
  hamlet_num_hh <- reactive({
    ok <- FALSE
    # hamlet_name <- input$hamlet
    lc <- location_code()
    if(!is.null(lc)){
      ok <- TRUE
    }
    if(ok){
      num_houses <- gps %>% filter(code == lc) %>% .$n_households
      num_houses <- round(num_houses * 1.25)
    } else {
      num_houses <- 500
    }
    return(num_houses)
  })
  
  output$ui_enumeration_n_hh <- renderUI({
    val <- hamlet_num_hh()
    textInput('enumeration_n_hh',
              'Estimated number of forms',
              value = val)
  })
  
  output$ui_id_limit <- renderUI({
    val <- hamlet_num_hh()
    high_val <- round(val * 2)
    fluidPage(
      sliderInput('id_limit', 'Limit IDs to:',
                  min = 1,
                  max = high_val, # round(num_houses),
                  value = c(1, high_val), # c(1, num_houses),
                  step = 1),
      helpText('Normally, do not touch this slider. Adjust it only if you want to exclude certain IDs (ie, in the case of having already printed numbers 1-50, you might set the lower limit of the slider to 51).')
    )
  })
  
  output$ui_id_limit_file <- renderUI({
    val <- hamlet_num_hh()
    fluidPage(
      sliderInput('id_limit', 'Limit IDs to:',
                  min = 1,
                  max = val, # round(num_houses),
                  value = c(1, val), # c(1, num_houses),
                  step = 1),
      helpText('Normally, do not touch this slider. Adjust it only if you want to exclude certain IDs (ie, in the case of having already printed numbers 1-50, you might set the lower limit of the slider to 51).')
    )
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
    # if(geo == 'Both'){
    #   shp = rbind(ruf2, mop2)
    #   coords <- coordinates(shp)
    #   afr <- rbind(moz0, tza0)
    #   plot(afr, col = adjustcolor('black', alpha.f = 1), border = NA)
    #   plot(shp, col = 'red', add = T)
    #   # points(coords, col = 'red', pch = 16)
    #   lines(coords, col = 'red', lty =2)
    # } else {
    plot(shp, col = 'black')
    # }
  })
  
  
  # Field monitoring UI  #############################################
  field_monitoring_geo <- reactiveVal('Ward')
  output$ui_field_monitoring_by <- renderUI({
    
    cn <- input$geo
    if(cn=='Rufiji'){
      cn_choices = c('District',
                     'Ward',
                     'Village',
                     'Hamlet')
    } else {
      cn_choices = c('Distrito' = 'District',
                     'Posto administrativo/localidade' ='Ward',
                     'Povoado' ='Village',
                     'Bairro' ='Hamlet')
    }
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'field_monitoring' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fmg <- field_monitoring_geo()
              fluidPage(
                column(12, align = 'center',
                       radioButtons('field_monitor_by',
                                    'Geographic level:',
                                    choices = cn_choices,
                                    selected = fmg,
                                    inline = TRUE))
              )
            })
  })
  
  # VA geo monitoring UI  #############################################
  va_monitoring_geo <- reactiveVal('Ward')
  output$ui_va_monitoring_by <- renderUI({
    
    cn <- input$geo
    if(cn=='Rufiji'){
      cn_choices = c('District',
                     'Ward',
                     'Village',
                     'Hamlet')
    } else {
      cn_choices = c('Distrito' = 'District',
                     'Posto administrativo/localidade' ='Ward',
                     'Povoado' ='Village',
                     'Bairro' ='Hamlet')
    }
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              fmg <- va_monitoring_geo()
              fluidPage(
                fluidRow(
                  column(12, align = 'center',
                         radioButtons('va_monitor_by',
                                      'Geographic level:',
                                      choices = cn_choices,
                                      selected = fmg,
                                      inline = TRUE))
                )
              )
            })
  })
  # 
  # ui for VA progress by geography.
  output$va_progress_geo_ui <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {

              # Get the overall va progress table
              pd <- odk_data$data
              pd <- pd$minicensus_main
              co <- country()
              pd <- pd %>%
                filter(hh_country == co)
              deaths <- odk_data$data$minicensus_repeat_death_info
              # save(pd, co, deaths, file = '/tmp/joe.RData')

              deaths <- deaths %>% filter(instance_id %in% pd$instance_id,
                                          !is.na(death_number))
              pd <- pd %>%
                dplyr::select(district = hh_district,
                              ward = hh_ward,
                              village = hh_village,
                              hamlet = hh_hamlet, instance_id)
              grouper <- input$va_monitor_by
              if(is.null(grouper)){
                grouper <- 'district'
              } else {
                grouper <- tolower(grouper)
              }
              va_progress_geo <- deaths %>%
                left_join(pd) %>%
                filter(!is.na(hamlet)) %>%
                group_by_(grouper) %>%
                summarise(`VA forms collected` = 0,
                          `Deaths reported` = n()) %>%
                mutate(`% VA forms completed` = round(`VA forms collected` /
                                                        `Deaths reported` * 100))

              fluidPage(
                fluidRow(
                  h2(paste0('Progress by ', grouper)),
                  prettify(va_progress_geo)
                )
              )
            })
  })
  # 
  output$va_progress_ui <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              # Get the overall va progress table
              pd <- odk_data$data
              pd <- pd$minicensus_main
              co <- country()
              pd <- pd %>% 
                filter(hh_country == co)
              deaths <- odk_data$data$minicensus_repeat_death_info
              # save(pd, co, deaths, file = '/tmp/joe.RData')
              deaths <- deaths %>% filter(instance_id %in% pd$instance_id,
                                          !is.na(death_number))
              pd <- pd %>%
                dplyr::select(district = hh_district,
                              ward = hh_ward,
                              village = hh_village,
                              hamlet = hh_hamlet, instance_id)
              # grouper <- input$va_monitor_by
              
              grouper <- 'district'
             
              va_progress <- deaths %>%
                left_join(pd) %>%
                filter(!is.na(hamlet)) %>%
                group_by_(grouper) %>%
                summarise(`VA forms collected` = 0,
                          `Deaths reported` = n()) %>%
                mutate(`% VA forms completed` = round(`VA forms collected` / 
                                                        `Deaths reported` * 100)) %>%
                select(`VA forms collected`, `Deaths reported`, `% VA forms completed`)
              
              fluidPage(
                fluidRow(
                  h2('Overall progress table'),
                  prettify(va_progress)
                )
              )
            })
  })
  
  # percent complete map input UI  #############################################
  # map_complete_geo<- reactiveVal('Hamlet')
  # output$ui_map_complete_by <- renderUI({
  #   
  #   cn <- input$geo
  #   if(cn=='Rufiji'){
  #     cn_choices = c('Ward',
  #                    'Village',
  #                    'Hamlet')
  #   } else {
  #     cn_choices = c('Posto administrativo/localidade' ='Ward',
  #                    'Povoado' ='Village',
  #                    'Bairro' ='Hamlet')
  #   }
  #   # See if the user is logged in and has access
  #   si <- session_info
  #   li <- si$logged_in
  #   ac <- 'field_monitoring' %in% si$access
  #   # Generate the ui
  #   make_ui(li = li,
  #           ac = ac,
  #           ok = {
  #             mcg <- map_complete_geo()
  #             
  #             fluidPage(
  #               column(6,
  #                      selectInput('map_complete_by',
  #                                   'Geographic level for map:',
  #                                   choices = cn_choices,
  #                                   selected = mcg))
  #             )
  #           })
  # })
  observeEvent(input$field_monitor_by,{
    x <- input$field_monitor_by
    field_monitoring_geo(x)
    
  })
  
  # Table of drop outs for fieldworkers
  output$drop_out_ui <- renderUI({
    options(dplyr.summarise.inform = FALSE)
    
    # Get the fieldworkers for the country in question
    co <- country()
    sub_fids <- fids %>% filter(country == co)
    # Get the minicensus data for the fieldworkers in question
    pd <- odk_data$data
    pd <- pd$minicensus_main
    pd$todays_date <- as.Date(pd$todays_date)
    # Detect all "drop outs" for each fieldworker
    pd_ids <- sort(unique(pd$wid))
    out_list <- list()
    for(i in 1:length(pd_ids)){
      this_pd <- pd %>% filter(wid == pd_ids[i])
      right <- this_pd %>%
        group_by(date = todays_date) %>%
        tally
      left <- tibble(date = seq(from = min(this_pd$todays_date, na.rm = TRUE),
                                to = Sys.Date(), #max(this_pd$todays_date, na.rm = TRUE),
                                by = 1)) %>%
        mutate(wd = weekdays(date))
      joined <- left_join(left, right, by = 'date')
      joined <- joined %>% filter(!wd %in% c('Saturday', 'Sunday'))
      # Identify episodes of non-activity
      joined$roller <- ave(joined$n, cumsum(!is.na(joined$n)), FUN = seq_along) - 1
      joined$episode_start <- ifelse(joined$roller == 1, 1, 0)
      joined$episode <- cumsum(joined$episode_start)
      joined$episode <- ifelse(!is.na(joined$n), NA, joined$episode)
      min_date <- min(joined$date)
      out <- joined %>%
        filter(is.na(n)) %>%
        group_by(episode) %>%
        summarise(n_days = max(roller),
                  start_date = min(date),
                  end_date = max(date)) %>%
        ungroup %>%
        mutate(period = paste0(format(start_date, '%b %d'), '-', format(end_date, '%b %d'))) %>%
        mutate(start_working = min_date) %>%
        mutate(fwid =  pd_ids[i]) %>%
        dplyr::select(`FW ID` = fwid,
                      `FW start date` = start_working,
                      `Drop-out episode number` = episode,
                      `Days missing` = n_days,
                      Dates = period)
      out_list[[i]] <- out
    }
    out <- bind_rows(out_list)
    out <- left_join(out, 
                     sub_fids %>% dplyr::select(`FW ID` = bohemia_id,
                                                Supervisor = supervisor))
    
    fluidPage(
      h2('Drop-outs table'),
      bohemia::prettify(out)
    )
  })
  
  
  output$ui_field_monitoring <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    
    li <- si$logged_in
    ac <- 'field_monitoring' %in% si$access
    
    
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              # Get the aggregate table # (fake)
              aggregate_table <- session_data$aggregate_table
              
              # Get the odk data
              pd <- odk_data$data
              pd <- pd$minicensus_main
              co <- country()
              # save(pd, file = '/tmp/pd.RData')
              pd <- pd %>% filter(hh_country == co)
              
              pd_ok <- FALSE
              if(!is.null(pd)){
                if(nrow(pd) > 0){
                  pd_ok <- TRUE
                }
              }
              if(pd_ok){
                # List of fieldworkers
                fid_options <- sort(unique(pd$wid))
                fid_choices <- session_data$fieldworkers
                # save(fid_options, fid_choices, file = '/tmp/fid.RData')
                fid_choices <- fid_choices %>% dplyr::filter(as.numeric(id) %in% as.numeric(fid_options))
                # save(fid_choices, file = 'temp_fid_choices.rda')
                x = as.character(fid_choices$name)
                y = as.character(fid_choices$id)
                fid_choices <- as.numeric(y)
                # names(fid_choices) <- x
                # fid_choices <- c(x = y)
                
                # Some pre-processing
                dr <- as.Date(range(pd$todays_date, na.rm = TRUE))
                n_days = as.numeric(1 + (max(dr)-min(dr)))
                the_iso <- iso <- ifelse(co == 'Tanzania', 'TZA', 'MOZ')
                # target <- sum(gps$n_households[gps$iso == iso], na.rm = TRUE)
                target <- ifelse(iso == 'TZA', 46105, 30467)
                
                # save(pd, file='pd_tab.rda')
                # Create table of overview
                overview <- pd %>%
                  summarise(Type = 'Observed',
                            `No. FWs` = length(unique(pd$wid)),
                            `Daily forms/FW` = round(nrow(pd) / `No. FWs` / n_days, digits = 1),
                            `Weekly forms/FW` = round(`Daily forms/FW` * 7, digits = 1),
                            `Total forms/FW` = round(nrow(pd) / `No. FWs`, digits = 1),
                            `Total Daily forms/country` = round(nrow(pd) / n_days, digits = 1),
                            `Total Weekly forms/country` = round(`Total Daily forms/country` * 7, digits = 1),
                            `Overall target/country` = target,
                            `# Total weeks` = round(`Overall target/country` / `Total Weekly forms/country`, digits = 1)) %>%
                  mutate(`Estimated date` = (`# Total weeks` * 7) + as.Date(dr[1]))
                # # Get a second row for targets
                # target_helper <- 
                #   tibble(xiso = c('MOZ', 'TZA'),
                #          n_fids = c(100,77),
                #          end_date = as.Date(c('2020-12-31',
                #                               '2020-12-15')),
                #          start_date = as.Date(c('2020-10-06',
                #                                 '2020-10-15'))) %>%
                #   mutate(n_days = as.numeric(end_date - start_date),
                #          n_weeks = round(n_days / 7, digits = 1)) %>%
                #   mutate(n_forms = c(30467, 46105)) %>%
                #   mutate(n_forms_daily = round(n_forms / n_days, digits = 2)) %>%
                #   mutate(n_forms_weekly =  round(n_forms_daily * 7, digits = 2)) %>%
                #   mutate(n_forms_daily_per_fid = round(n_forms_daily/n_fids, digits = 2)) %>%
                #   mutate(n_forms_weekly_per_fid = round(n_forms_weekly/n_fids, digits = 2)) %>%
                #   mutate(n_forms_total_per_fid = round(n_forms / n_fids, 2))
                # target_helper <- target_helper %>% filter(xiso == iso)
                # hard coded values for each country
                if(co=='Tanzania'){
                  num_fws <- 77
                  daily_forms_fw <- 13
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 599
                  total_daily_country <- 1001
                  total_weekly_country <- total_daily_country*5
                  total_forms <- 41605
                  total_weeks <- round(total_forms/total_weekly_country,2)
                  total_days <- total_weeks*7
                  est_date <- Sys.Date()+total_days
                } else {
                  num_fws <- 100
                  daily_forms_fw <- 10
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 500
                  total_daily_country <- 1000
                  total_weekly_country <- total_daily_country*5
                  total_forms <- 30467
                  total_weeks <- round(total_forms/total_weekly_country,2)
                  total_days <- total_weeks*7
                  # save(est_date, file = 'est_date.rda')
                  
                }
                second_row <- 
                  tibble(Type = 'Target',
                         `No. FWs` = num_fws,  
                         `Daily forms/FW` = daily_forms_fw,
                         `Weekly forms/FW` = weekly_forms_fw,
                         `Total forms/FW` = total_forms_fw,
                         `Total Daily forms/country` = total_daily_country,
                         `Total Weekly forms/country` = total_weekly_country,
                         `Overall target/country` = total_forms,
                         `# Total weeks` = total_weeks, #as.character(target_helper$end_date))
                         `Estimated date` = as.character(Sys.Date()+total_days))
                third_row <- 
                  tibble(Type = 'Percentage',
                         `No. FWs` = round(overview$`No. FWs`/second_row$`No. FWs` * 100),  
                         `Daily forms/FW` = round(overview$`Daily forms/FW`/second_row$`Daily forms/FW`, 2)  * 100,
                         `Weekly forms/FW` = round(overview$`Weekly forms/FW`/second_row$`Weekly forms/FW`,2) * 100,
                         `Total forms/FW` = round(overview$`Total forms/FW`/second_row$`Total forms/FW`,2) * 100,
                         `Total Daily forms/country` = round(overview$`Total Daily forms/country`/second_row$`Total Daily forms/country`,2) * 100,
                         `Total Weekly forms/country` = round(overview$`Total Weekly forms/country`/second_row$`Total Weekly forms/country`,2) * 100,
                         `Overall target/country` = ' ',
                         `# Total weeks` = ' ', #round(overview$`# Total weeks`/second_row$`# Total weeks`,2),
                         `Estimated date` = '')
                # save(pd, overview,target_helper, second_row, file = '/tmp/overview.RData')
                for(j in 1:ncol(overview)){
                  overview[,j] <- as.character(overview[,j])
                }
                for(j in 1:ncol(second_row)){
                  second_row[,j] <- as.character(second_row[,j])
                }
                
                for(j in 1:ncol(third_row)){
                  third_row[,j] <- as.character(third_row[,j])
                }
                overview <- bind_rows(overview, second_row, third_row)
                
                # Create map
                ll <- extract_ll(pd$hh_geo_location)
                pd$lng <- ll$lng; pd$lat <- ll$lat
                l <- leaflet() %>% addTiles()
                if(!all(is.na(pd$lng))){
                  l <- l %>%
                    addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
                }
                
                #########   percent complete map - create dataframe grouped by all locations together
                lxd_all <- pd %>% group_by(hh_ward, hh_village, code = hh_hamlet_code) %>%
                  tally %>%
                  left_join(gps %>% dplyr::select(code, n_households)) %>%
                  mutate(p = n / n_households * 100)
                lxd_all <- left_join(gps %>% filter(iso == the_iso) %>% 
                                       dplyr::select(code, lng, lat), lxd_all) %>%
                  mutate(p = ifelse(is.na(p), 0, p))
                pal_all <- pal_hamlet <- colorNumeric(
                  palette = c("black","darkred", 'red', 'darkorange', 'blue'),
                  domain = 0:ceiling(max(lxd_all$p))
                )
                # save(lxd_all, file = 'lxd_all.rda')
                hamlet_text <- paste(
                  "Percent finished: ",  round(ifelse(is.na(lxd_all$p), 0, lxd_all$p),2),"<br>",
                  as.character(lxd_all$code),"<br/>",
                  sep="") %>%
                  lapply(htmltools::HTML)
                # create map for hamlet
                leaflet_height <- 1000
                lxd_hamlet <- leaflet(data = lxd_all, height = leaflet_height) %>% 
                  addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                  addCircleMarkers(data = lxd_all, lng = ~lng, lat = ~lat,label = hamlet_text, stroke=FALSE, color=~pal_hamlet(p), fillOpacity = 0.6, 
                                   radius = 10) %>%
                  addLegend(position = c("bottomleft"), pal = pal_hamlet, values = lxd_all$p)
                
                # create map for village
                lxd_village <- lxd_all %>% group_by(hh_village) %>%
                  summarise(p = mean(p),
                            lat =mean(lat),
                            lng=mean(lng))
                pal_village <- colorNumeric(
                  palette = c("black","darkred", 'red', 'darkorange', 'blue'),
                  domain = 0:ceiling(max(lxd_village$p))
                )
                village_text <- paste(
                  "Percent finished: ", round(lxd_village$p,2),"<br>",
                  as.character(lxd_village$hh_village),"<br/>",
                  sep="") %>%
                  lapply(htmltools::HTML)
                lxd_village <- leaflet(data = lxd_village, height = leaflet_height) %>% 
                  addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                  addCircleMarkers(data = lxd_village, lng = ~lng, lat = ~lat,label = village_text, stroke=FALSE, color=~pal_village(p), fillOpacity = 0.6) %>%
                  addLegend(position = c("bottomleft"), pal = pal_village, values = lxd_village$p)
                
                # create map for ward 
                lxd_ward <- lxd_all %>% group_by(hh_ward) %>%
                  summarise(p = mean(p),
                            lat =mean(lat),
                            lng=mean(lng))
                pal_ward <- colorNumeric(
                  palette = c("black","darkred", 'red', 'darkorange', 'blue'),
                  domain = 0:ceiling(max(lxd_ward$p))
                )
                ward_text <- paste(
                  "Percent finished: ",  round(lxd_ward$p,2),"<br>",
                  as.character(lxd_ward$hh_ward),"<br/>",
                  sep="") %>%
                  lapply(htmltools::HTML)
                lxd_ward <- leaflet(data = lxd_ward, height = leaflet_height) %>% 
                  addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                  addCircleMarkers(data = lxd_ward, lng = ~lng, lat = ~lat,label = ward_text, stroke=FALSE, color=~pal_ward(p), fillOpacity = 0.6) %>%
                  addLegend(position = c("bottomleft"), pal = pal_ward, values = lxd_ward$p)
                
                # create map for district 
                lxd_district <- lxd_all %>% ungroup %>%
                  summarise(p = mean(p),
                            lat =mean(lat),
                            lng=mean(lng))
                pal_district <- colorNumeric(
                  palette = c("black","darkred", 'red', 'darkorange', 'blue'),
                  domain = 0:ceiling(max(lxd_district$p))
                )
                district_text <- paste(
                  "Percent finished: ",  round(lxd_district$p,2),"<br>",
                  input$geo,"<br>",
                  sep="") %>%
                  lapply(htmltools::HTML)
                lxd_district <- leaflet(data = lxd_district, height = leaflet_height) %>% 
                  addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                  addCircleMarkers(data = lxd_district, lng = ~lng, lat = ~lat, label = district_text,stroke=FALSE, color=~pal_district(p), fillOpacity = 0.6) %>%
                  addLegend(position = c("bottomleft"), pal = pal_district, values = lxd_district$p) %>%
                  setView(lng = lxd_district$lng,
                          lat = lxd_district$lat,
                          zoom = 8)
                
                # get input for which location to view
                map_location = field_monitoring_geo()#  map_complete_geo()
                print('MAP LOCATION IS ')
                print(map_location)
                # get country to translate names for map title
                cn <- input$geo
                cn <- ifelse(cn == 'Rufiji', 'Tanzania', 'Mozambique')
                if(is.null(map_location)){
                  lx <- lxd_hamlet
                } else {
                  if(map_location == 'District'){
                    lx <- lxd_district
                    if(cn == 'Mozambique'){
                      map_location <- 'Distrito'
                    }
                  }
                  if(map_location=='Hamlet'){
                    lx <- lxd_hamlet
                    if(cn=='Mozambique'){
                      map_location = 'Bairro'
                    }
                  } else if(map_location=='Village'){
                    lx <- lxd_village
                    if(cn=='Mozambique'){
                      map_location = 'Povaodo'
                    }
                  } else if(map_location=='Ward'){
                    lx <- lxd_ward
                    if(cn=='Mozambique'){
                      map_location = 'Posto administrativo/localidade'
                    }
                  }
                }
                
                # create map title
                map_complete_title <- paste0('Map of completion % by ', map_location)
                
                # join fids with pd to ge supervisor info
                # Get the fieldworkers for the country in question
                co <- country()
                sub_fids <- fids %>% filter(country == co)
                pd <- left_join(pd, sub_fids, by=c('wid'= 'bohemia_id'))
                # Create fieldworkers table
                pd$end_time <- lubridate::as_datetime(pd$end_time)
                pd$start_time <- lubridate::as_datetime(pd$start_time)
                pd$time <- pd$end_time - pd$start_time
                fwt <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  group_by(`FW ID` = wid,
                           `FW Supervisor` = supervisor) %>%
                  mutate(nd = as.numeric(max(todays_date, na.rm = TRUE) - min(todays_date, na.rm = TRUE) + 1)) %>%
                  ungroup %>%
                  group_by(`FW ID`,
                           `FW Supervisor`) %>%
                  summarise(`Daily forms` = round(n() / dplyr::first(nd), digits = 1),
                            `Weekly forms` = round(`Daily forms` * 7, digits = 1),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units'))) 
                fwt_daily <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  filter(end_time >= (Sys.time() - lubridate::hours(24))) %>%
                  group_by(`FW ID` = wid,
                           `FW Supervisor` = supervisor) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')))
                fwt_weekly <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  filter(end_time >= (Sys.time() - lubridate::hours(24*7))) %>%
                  group_by(`FW ID` = wid,
                           `FW Supervisor` = supervisor) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')))
                fwt_overall <-  pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  group_by(`FW ID` = wid,
                           `FW Supervisor` = supervisor) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')),
                            `Daily work hours` = '(Pending feature)')
                
                
                
                # Create a progress plot
                output$progress_plot <- renderPlot({
                  x <- pd %>%
                    group_by(date = as.Date(todays_date)) %>%
                    tally %>%
                    mutate(denom = target) %>%
                    mutate(cs = cumsum(n)) %>%
                    mutate(p = cs / denom * 100)
                  ggplot(data = x,
                         aes(x = date,
                             y = p)) +
                    geom_point() +
                    geom_line() +
                    theme_bohemia() +
                    labs(x = 'Date',
                         y = 'Percent of target completed',
                         title = 'Cumulative percent of target completed')
                })
                # Create a progress table
                progress_table <- tibble(`Forms finished` = nrow(pd),
                                         `Estimated total forms` = target,
                                         `Estimated forms remaining` = target - nrow(pd),
                                         `Estimated % finished` = round(nrow(pd) / target * 100, digits = 2))
                
                # Create a detailed progress table (by hamlet)
                left <- gps %>%
                  filter(iso == the_iso) %>%
                  dplyr::select(code, n_households)
                right <- pd %>%
                  group_by(code = hh_hamlet_code) %>%
                  summarise(numerator = n())
                joined <- left_join(left, right) %>%
                  mutate(numerator = ifelse(is.na(numerator), 0, numerator)) %>%
                  mutate(p = numerator / n_households * 100) %>%
                  mutate(p = round(p, digits = 2))
                progress_by_hamlet <- joined %>%
                  left_join(locations %>% dplyr::select(code, Hamlet)) %>%
                  dplyr::select(code, Hamlet, `Forms done` = numerator,
                                `Estimated number of forms` = n_households,
                                `Estimated percent finished` = p)
                
                
                # Create a progress by geo tables
                progress_by <- joined %>% left_join(locations %>% dplyr::select(code, District, Ward, Village, Hamlet))
                # save(progress_by, file = '/tmp/progress_by.RData')
                progress_by_district <- progress_by %>% group_by(District) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                         n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(District, `Forms done` = numerator,
                                `Estimated number of forms` = n_households,
                                `Estimated percent finished` = p)
                progress_by_ward <- progress_by %>% group_by(Ward) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                 n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(Ward, `Forms done` = numerator,
                                `Estimated number of forms` = n_households,
                                `Estimated percent finished` = p)
                progress_by_village <- progress_by %>% group_by(Village) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                       n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(Village, `Forms done` = numerator,
                                `Estimated number of forms` = n_households,
                                `Estimated percent finished` = p)
                by_geo <- field_monitoring_geo() #input$field_monitor_by
                if(is.null(by_geo)){
                  monitor_by_table <- progress_by_district
                } else {
                  cn <- input$geo
                  cn <- ifelse(cn == 'Rufiji', 'Tanzania', 'Mozambique')
                  if(by_geo == 'District'){
                    if(cn == 'Mozambique'){
                      names(progress_by_district)[1] <- 'Distrito'
                      monitor_by_table <- progress_by_district
                    } else {
                      monitor_by_table <- progress_by_district
                    }
                  } else if(by_geo == 'Ward'){
                    if(cn == 'Mozambique'){
                      names(progress_by_ward)[1] <- 'Posto administrativo/localidade'
                      monitor_by_table <- progress_by_ward
                    } else {
                      monitor_by_table <- progress_by_ward
                    }
                  } else if(by_geo == 'Village'){
                    if(cn == 'Mozambique'){
                      names(progress_by_village)[1] <- 'Povoado'
                      monitor_by_table <- progress_by_village
                    } else {
                      monitor_by_table <- progress_by_village
                    }
                  } else if(by_geo == 'Hamlet'){
                    if(cn == 'Mozambique'){
                      names(progress_by_hamlet)[1] <- 'Bairro'
                      monitor_by_table <- progress_by_hamlet
                    } else {
                      monitor_by_table <- progress_by_hamlet
                    }
                  }
                }
                
                # va table
                deaths <- odk_data$data$minicensus_repeat_death_info
                deaths <- deaths %>% filter(instance_id %in% pd$instance_id)
                # save(deaths, pd, file = '/tmp/deaths.RData')
                # Conditional mourning period
                mourning_period <- ifelse(cn == 'Mozambique', 30, 40)
                va <- left_join(deaths %>% 
                                  left_join(pd %>% dplyr::select(instance_id, todays_date)) %>%
                                  mutate(todays_date = as.Date(todays_date),
                                         death_dod = as.Date(death_dod)) %>%
                                  mutate(old = (todays_date - death_dod) > mourning_period) %>%
                                  mutate(time_to_add = ifelse(old, 7, mourning_period)) %>%
                                  mutate(xx = todays_date + time_to_add, # this needs to be 7 days after hh visit date if death was <40 days prior to hh visit date | 40 days after hh visit date if the death was >40 days after hh visit date
                                         yy = Sys.Date() - todays_date) %>%
                                  # Note: in case the "date of death" is unknown (the form has that option): let's just calculate the "latest date to do VA" by adding 40 days (Tanzania) and 30 days (Moz) to the "date of the hh visit", to be safe.
                                  mutate(safe_bet = todays_date + mourning_period) %>%
                                  mutate(xx = ifelse(is.na(xx), safe_bet, xx)) %>%
                                  mutate(xx = as.Date(xx, origin = '1970-01-01')) %>%
                                  dplyr::select(instance_id,
                                                `Date of death` = death_dod,
                                                `Latest date to collect VA form` = xx,
                                                `PERM ID` = death_id,
                                                `Time elapsed` = yy),
                                pd %>%
                                  dplyr::select(instance_id,
                                                District = hh_district,
                                                Ward = hh_ward,
                                                Village = hh_village,
                                                Hamlet = hh_hamlet,
                                                `HH ID` = hh_hamlet_code,
                                                `FW ID` = wid,
                                                `HH visit date` = todays_date)) %>%
                  mutate(`FW ID` = ' ') %>%
                  dplyr::select(-instance_id)
                # Filter to only include those past the latest date
                va <- va %>% filter(`Latest date to collect VA form` <= Sys.Date())
                if(nrow(va) > 0){
                  va <- va %>% dplyr::select(District, Ward, Village, Hamlet,
                                             `HH ID`, `FW ID`, `PERM ID`,
                                             `HH visit date`, `Date of death`,
                                             `Latest date to collect VA form`,
                                             `Time elapsed`
                  ) %>%
                    arrange(desc(`HH visit date`))
                  if(cn=='Mozambique'){
                    va <- va %>%  rename(Distrito = District,
                                         `Posto administrativo/localidade`=Ward,
                                         Povoado=Village,
                                         Bairro=Hamlet)
                  } 
                }
              } else {
                progress_by <- progress_by_district <- monitor_by_table <-  progress_by_ward <- progress_by_village <- progress_by_hamlet <- progress_table <- performance_table <-
                  fwt_daily <- fwt_weekly <- fwt_overall <- overview <- va <- va2 <- va3 <- tibble(`No data available` = ' ')
                l <- lx <- leaflet() %>% addTiles()
                fid_options <- fid_choices <- 1:700
                fwt <- tibble(`No fieldworkers from this country` = ' ')
                output$progress_plot <- renderPlot({
                  ggplot() + theme_bohemia()
                })
              }
              
              fluidPage(
                fluidRow(column(12, align = 'center',
                                h1('Field monitoring'))),
                tabsetPanel(
                  tabPanel('Overview',
                           navbarPage(
                             title = 'Overview',
                             tabPanel('Progress by geographical unit',
                                      fluidRow(
                                        h3('Progress by geography'),
                                        uiOutput('ui_field_monitoring_by'),
                                        column(12, align = 'center',
                                               bohemia::prettify(monitor_by_table, nrows = 10),
                                               h3(map_complete_title),
                                               lx
                                        )
                                      )),
                             tabPanel('Overall progress',
                                      fluidPage(
                                        h3('Estimated targets'),
                                        gt(overview),
                                        
                                        fluidRow(
                                          column(6,
                                                 h3('Overall progress plot'),
                                                 plotOutput('progress_plot')),
                                          column(6,
                                                 h3('Overall progress table'),
                                                 gt(progress_table))
                                        )#, removing map of forms
                                        # fluidRow(
                                        #   # uiOutput('ui_map_complete_by'),
                                        #   column(6, align = 'center',
                                        #          br(),
                                        #          h3('Map of forms'),
                                        #          l)
                                        # )
                                      ))
                           )
                  ),
                  tabPanel('Performance',
                           fluidPage(
                             navbarPage(title = 'Performance',
                                        tabPanel('Fieldworkers',
                                                 fluidRow(
                                                   infoBox(title = 'Number of detected anomalies',
                                                           icon = icon('microscope'),
                                                           color = 'black',
                                                           width = 6,
                                                           h1(0)),
                                                   infoBox(title = 'Missing response rate',
                                                           icon = icon('address-book'),
                                                           color = 'black',
                                                           width = 6,
                                                           h1('0%'))
                                                 ),
                                                 tabsetPanel(
                                                   tabPanel('Individual data',
                                                            fluidPage(
                                                              fluidRow(
                                                                column(12,
                                                                       selectInput('fid',
                                                                                   'Fieldworker ID',
                                                                                   choices = fid_choices),
                                                                       tableOutput('individual_details'))),
                                                              fluidRow(box(width = 12,
                                                                           title = 'Location of forms submitted by this worker',
                                                                           leafletOutput('fid_leaf',
                                                                                         height = 500))
                                                              ))),
                                                   tabPanel('Aggregate data',
                                                            navbarPage('Fieldworkers tables',
                                                                       tabPanel('Daily',
                                                                                DT::datatable(fwt_daily, rownames = FALSE)),
                                                                       tabPanel('Weekly',
                                                                                DT::datatable(fwt_weekly, rownames = FALSE)),
                                                                       tabPanel('Overall',
                                                                                DT::datatable(fwt_overall, rownames = FALSE)))),
                                                   tabPanel('Dropouts',
                                                            fluidRow(
                                                              uiOutput('drop_out_ui')
                                                            ))
                                                 )),
                                        tabPanel('Supervisors',
                                                 fluidPage(
                                                   fluidRow(
                                                     column(12, align = 'center',
                                                            h3('By supervisor'),
                                                            p('PENDING: need standardized supervisor information from both sites for all fieldworkers.'))
                                                   )
                                                 ))
                             )
                           )),
                  tabPanel('VA',
                           fluidPage(
                             # br(), br(),
                             navbarPage(title = 'VA',
                                        tabPanel('List generation',
                                                 DT::datatable(va_list <- va%>%select(-`Time elapsed`), rownames = FALSE)),
                                        tabPanel('VA progress',
                                                 tabsetPanel(
                                                   tabPanel('VA Overall progress',
                                                            uiOutput('va_progress_ui')),
                                                   #h4('Map of VA forms submitted'),
                                                   #leaflet(height = 1000) %>% addTiles()),
                                                   tabPanel('VA progress by geographical unit',
                                                            br(),
                                                            uiOutput('ui_va_monitoring_by'),
                                                            br(),
                                                            uiOutput('va_progress_geo_ui')),
                                                   tabPanel('Past due VAs', 
                                                            h1('Past due'),
                                                            DT::datatable(va, rownames = FALSE))
                                                   
                                                 ))
                             ))
                  ),
                  tabPanel('Alerts',
                           uiOutput('anomalies_ui'))))
            })
  })
  
  # Leaflet of fieldworkers
  output$fid_leaf <- renderLeaflet({
    leaflet() %>% addProviderTiles(providers$Stamen.Toner)
  })
  observeEvent(input$fid, {
    xfids <- input$fid
    if(is.null(xfids)){
      xfids <- 1:700
    }
    xfids <- as.numeric(xfids)
    # Get the aggregate table # (fake)
    aggregate_table <- session_data$aggregate_table
    
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    # save(cpd, file = '/tmp/pd.RData')
    pd <- pd %>% filter(hh_country == co)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      ll <- extract_ll(pd$hh_geo_location)
      pd$lng <- ll$lng; pd$lat <- ll$lat
      pd <- pd %>% filter(wid %in% xfids)
      # round table not here, and here make sure map works (not saving data below)
      leafletProxy('fid_leaf') %>%
        clearMarkers() %>%
        addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
    } else {
      message('here instead')
      leafletProxy('fid_leaf') %>%
        clearMarkers() 
    }
    
  })
  
  # Observe the fix submission
  observeEvent(input$submit_fix,{
    sr <- input$anomalies_table_rows_selected
    action <- session_data$anomalies
    this_row <- action[sr,]
    
    # Must be just one row
    just_one <- FALSE
    if(nrow(this_row) == 1){
      just_one <- TRUE
    }
    if(just_one){
      showModal(
        modalDialog(
          title = 'Provide information on the fix',
          size = 'l',
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
    } else {
      showModal(
        modalDialog(
          title = 'Not quite...',
          size = 'm',
          easyClose = TRUE,
          fade = TRUE,
          footer = modalButton('Go back'),
          fluidPage(
            p(paste0('You have selected ',
                     nrow(this_row), 
                     ' rows.')),
            p('Before submitting a correction / confirmation, you must select exactly one row.')
          )
        )
      )
    }
    
  })
  
  # # Observe the notification disregard
  # observeEvent(input$discard_notification,{
  #   sr <- input$notifications_table_rows_selected
  #   notifications <- session_data$notifications
  #   message('sr is ', sr)
  #   vals <- 1:nrow(notifications)
  #   vals <- vals[!vals %in% sr]
  #   notifications <- notifications[vals,]
  #   session_data$notifications <- notifications
  # })
  
  # Confirm a fix send
  observeEvent(input$send_fix,{
    sr <- input$anomalies_table_rows_selected
    action <- session_data$anomalies
    
    # Get the fix row
    this_row <- action[sr,]
    # Get the fix text
    fix_details <- input$fix_details
    fix <-
      tibble(id = this_row$id,
             action = fix_details,
             submitted_by = input$log_in_user,
             submitted_at = Sys.time(),
             done = FALSE,
             done_by = ' ')
    # CONNECT TO THE DATABASE AND ADD FIX
    message('Connecting to the database in order to add a fix to the corrections table')
    con <- get_db_connection()
    dbAppendTable(conn = con,
                  name = 'corrections',
                  value = fix)
    message('Done. now disconnecting from database')
    dbDisconnect(con)
    # AND THEN MAKE SURE TO UPDATE THE IN-SESSION STUFF
    save(this_row, sr, action, fix, odk_data, fix_details, file = '/tmp/this_row.RData')
    message('Now uploading the in-session data')
    old_corrections <- odk_data$data$corrections 
    new_correction <- fix
    new_corrections <- bind_rows(old_corrections, new_correction)
    odk_data$data$corrections  <- new_corrections
    save(new_corrections, file = '/tmp/new_corrections.RData')
    
    # message('sr is ', sr)
    # vals <- 1:nrow(action)
    # vals <- vals[!vals %in% sr]
    # action <- action[vals,]
    # session_data$anomalies <- action
    removeModal()
  })
  
  
  # Data management UI  ##############################################
  output$ui_enrollment <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'enrollment' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              # Get places visisted so far
              pd <- odk_data$data
              pd <- pd$minicensus_main
              # Get the country
              co <- input$geo
              co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
              pd <- pd %>% dplyr::filter(hh_country == co)
              ll <- extract_ll(pd$hh_geo_location)
              pd$lng <- ll$lng; pd$lat <- ll$lat
              pd <- pd %>%
                dplyr::select(code = hh_hamlet_code,
                              hh_id,
                              wid, lng, lat) %>%
                left_join(locations %>% dplyr::select(code, Ward, Village, Hamlet)) %>%
                mutate(status = 'Participant')
              # Get map
              l <- leaflet() %>% addProviderTiles(providers$Esri.WorldImagery) %>%
                addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
              
              if(co=='Mozambique'){
                pd <- pd %>% rename(`Posto administrativo/localidade`=Ward,
                                    Povoado=Village,
                                    Bairro=Hamlet)
              }
              # NO DETAILS YET FOR NON-PARTICIPANTS
              
              fluidPage(
                h3('Enrollment'),
                fluidRow(
                  column(12, align = 'center',
                         h4('Map of participating and non-participating households'),
                         l,
                         h2('Table of participating households'),
                         DT::datatable(pd, rownames = FALSE),
                         br(), br(),
                         h2('Table of non-participating households'),
                         DT::datatable(tibble(`None` = 'There are none.')))
                )
              )
            }
            
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
                h3('LOGGED IN. This page is under construction..')
              )
    )
  })
  
  # Consent verification list UI ##########################################
  output$ui_consent_verification_list_a <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'consent_verification_list' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                dateRangeInput('verification_date_filter',
                               'Filter by date',
                               start = as.Date('2020-09-01'),
                               end = Sys.Date()))
              
            })
  })
  
  output$ui_verification_text_filter <- renderUI({
    pd <- odk_data$data
    pd <- pd$minicensus_main
    
    # Get the country
    co <- input$geo
    co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
    pd <- pd %>% dplyr::filter(hh_country == co)
    wid <- sort(unique(pd$wid))
    wid <- wid[!is.na(wid)]
    selectInput('verification_text_filter',
                'Filter by FW code (all, by default)',
                choices = wid,
                selected = wid,
                multiple = TRUE)
  })
  
  consent_verification_list_reactive <- reactiveValues(data = NULL)
  
  quality_control_list_reactive <- reactiveValues(data = NULL)
  output$ui_consent_verification_list <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'consent_verification_list' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              # Get the odk data
              pd <- odk_data$data
              people <- pd$minicensus_people
              pd <- pd$minicensus_main
              # Get the country
              co <- input$geo
              co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
              pd <- pd %>% dplyr::filter(hh_country == co)
              # save(pd, co, people, file = '/tmp/joe.RData')
              # Get hh head
              out <- pd %>%
                dplyr::select(num = hh_head_id,
                              instance_id,
                              todays_date,
                              hh_head_dob,
                              wid,
                              hh_hamlet_code) %>%
                mutate(num = as.character(num)) %>%
                left_join(people %>% mutate(num = as.character(num)),
                          by = c('instance_id', 'num'))
              
              # out_list <- list()
              # for(i in 1:nrow(pd)){
              #   this_instance_id <- pd$instance_id[i]
              #   this_num <- pd$hh_head_id[i]
              #   this_date <- pd$todays_date[i]
              #   this_dob <- pd$hh_head_dob[i]
              #   this_wid <- pd$wid[i]
              #   this_hh_hamlet_code <- pd$hh_hamlet_code[i]
              #   this_person <- people %>% filter(instance_id == this_instance_id,
              #                                    num == this_num)
              #   out <- this_person %>% mutate(todays_date = this_date,
              #                                 hh_head_dob = this_dob,
              #                                 wid = this_wid,
              #                                 hh_hamlet_code = this_hh_hamlet_code)
              #   out_list[[i]] <- out
              # }
              # out <- bind_rows(out_list)
              # # save(out, file = '/tmp/out.RData')
              pd <- out %>%
                mutate(name = paste0(first_name, ' ', last_name),
                       age = round((as.Date(todays_date) - as.Date(hh_head_dob)) / 365.25)) %>%
                mutate(consent = 'HoH (minicensus)') %>%
                mutate(x = ' ',y = ' ', z = ' ') %>%
                mutate(hh_id = substr(permid, 1, 7)) %>%
                dplyr::select(wid,
                              hh_hamlet_code,
                              hh_head_permid = permid,
                              hh_id,
                              # name,
                              age,
                              todays_date,
                              consent,
                              x,y,z) %>%
                mutate(todays_date = as.Date(todays_date))
              
              text_filter <- input$verification_text_filter
              if(!is.null(text_filter)){
                pd <- pd %>%
                  dplyr::filter(wid %in% text_filter)
              }
              date_filter <- input$verification_date_filter
              if(!is.null(date_filter)){
                pd <- pd %>%
                  dplyr::filter(
                    todays_date <= date_filter[2],
                    todays_date >= date_filter[1]
                  )
              }
              
              # get date closest to today
              qc <- pd
              # only keep hh_id and permid
              # save(qc, file = '/tmp/qc.RData')
              qc <- qc %>% select(`Hamlet code` = hh_hamlet_code,
                                  `Worker code` = wid,
                                  `Household ID` = hh_id, 
                                  `HH Head ID` = hh_head_permid,
                                  Age = age,
                                  Date = todays_date)
              # get inputs for slider to control sample size
              min_value <- 1
              max_value <- nrow(qc)
              selected_value <- sample(min_value:max_value, 1)
              # NEED TRANSLATION FOR HOUSEHOLD ID
              if(co == 'Mozambique'){
                names(pd) <- c('Código TC',
                               'Código Bairro',
                               'Household ID',
                               'ExtID (número de identificão do participante)',
                               # 'Nome do membro do agregado',
                               'Idade do membro do agregado',
                               'Data de recrutamento',
                               'Consentimento/ Assentimento informado (marque se estiver correto e completo)',
                               'Se o documento não estiver preenchido correitamente, indicar o error',
                               'O error foi resolvido (sim/não)',
                               'Verificado por (iniciais do arquivista) e data')
              } else {
                names(pd) <- c('FW code',
                               'Hamlet code',
                               'Household ID',
                               'ExtID HH member',
                               # 'Name of household member',
                               'Age of household member',
                               'Recruitment date',
                               'Informed consent/assent type (check off if correct and complete)',
                               'If not correct, please enter type of error',
                               'Was the error resolved (Yes/No)?',
                               'Verified by (archivist initials) and date')
              }
              consent_verification_list_reactive$data <- pd
              quality_control_list_reactive$data <- qc
              fluidPage(
                fluidRow(
                  downloadButton('render_consent_verification_list',
                                 'Print consent verification list')
                ),
                br(),
                br(),
                fluidRow(
                  h3('Quality control check'),
                  p('Select the number of forms to sample (below) and filter by date (above). Then, click "Quality control check" to generate a random table of forms to check on.'),
                  sliderInput('sample_num', 'Number of forms to sample',
                              min = min_value,
                              max = max_value,
                              value = selected_value, step = 1),
                  actionButton('quality_control_check',
                               'Quality control check'),
                  DT::dataTableOutput('quality_control_table')
                )
              )
            }
    )
  }
  )
  
  
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
                h3('LOGGED IN. This page is under construction..')
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
                h3('LOGGED IN. This page is under construction..')
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
                h3('LOGGED IN. This page is under construction..')
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
                h3('LOGGED IN. This page is under construction..')
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
                h3('LOGGED IN. This page is under construction..')
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
                h3('LOGGED IN. This page is under construction..')
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
  output$anomalies_table <- DT::renderDataTable({
    action <- session_data$anomalies
    # Join with the already existing fixes and remove those for which a fix has already been submitted
    corrections <- odk_data$data$corrections
    save(action, corrections, file = '/tmp/this.RData')
    if(nrow(corrections) == 0){
      corrections <- dplyr::tibble(id = '',
                                   action = '',
                                   submitted_by = '',
                                   submitted_at = Sys.time(),
                                   done = FALSE,
                                   done_by = ' ')
    }
    joined <- dplyr::left_join(action, corrections)
    # joined <- joined %>% filter(action != '')
    DT::datatable(joined,
                  rownames = NULL,
                  filter = 'bottom',
                  options = list(
                    paging =TRUE,
                    pageLength =  nrow(joined) 
                  ))
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
  
  output$individual_details <- 
    renderTable({
      
      # Get the odk data
      pd <- odk_data$data
      pd <- pd$minicensus_main
      co <- country()
      # save(pd, file = '/tmp/pd.RData')
      pd <- pd %>% filter(hh_country == co)
      
      pd_ok <- FALSE
      if(!is.null(pd)){
        if(nrow(pd) > 0){
          pd_ok <- TRUE
        }
      }
      if(pd_ok){
        who <- input$fid
        id <- who
        last_upload <- as.character(max(pd$end_time[pd$wid == who]))
        total_forms <- length(which(pd$wid == who))
        average_time <- 63
        daily_work_hours <- 'pending'
        tibble(`FW ID` = id, `# forms` = total_forms, `Average time/form` = average_time,
               `Last upload`=last_upload, `Daily work hours`= daily_work_hours)
        
      } else {
        NULL
      }
      
      
    })
  
  # observe event for action button quality_control_check
  quality_control_table_data <- reactiveValues(data = NULL)
  observeEvent(input$quality_control_check, {
    # Get the data
    sample_num = input$sample_num
    qcx <- quality_control_list_reactive$data
    if(is.null(qcx)|is.null(sample_num)){
      NULL
    } else {
      # sample half data (replace with input)
      if(nrow(qcx)>1){
        if(sample_num > nrow(qcx)){
          sample_index <- 1:nrow(qcx)
        } else {
          sample_index <- sample(1:nrow(qcx), sample_num, replace = FALSE)
        }
        qcx <- qcx[sample_index,]
      }
      quality_control_table_data$data <- qcx
    }
    
  })
  
  output$quality_control_table <- DT::renderDataTable({
    qct <- quality_control_table_data$data
    if(is.null(qct)){
      NULL
    } else {
      bohemia::prettify(qct,
                        download_options = TRUE,
                        nrows = nrow(qct))
    }
  })
  
  # Alert ui
  output$anomalies_ui <- renderUI({
    
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'malaria' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                fluidRow(column(6,
                                p('Select a row and then click one of the below:')),
                         column(6,
                                actionButton('submit_fix',
                                             'Submit fix',
                                             style='padding:=8px; font-size:280%'))),
                fluidRow(
                  box(width = 12,
                      # icon = icon('table'),
                      color = 'orange',
                      div(DT::dataTableOutput('anomalies_table'), style = "font-size:60%"))
                )
              )
            }
    )
    
    
  })
  
  output$render_visit_control_sheet <-
    downloadHandler(filename = "visit_control_sheet.pdf",
                    content = function(file){
                      
                      # Get the location code
                      lc <- location_code()
                      # Get other details
                      enum <- input$enumeration
                      use_previous <- input$use_previous
                      data <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                         n_teams = as.numeric(as.character(input$enumeration_n_teams)),
                                         id_limit_lwr = as.numeric(as.character(input$id_limit[1])),
                                         id_limit_upr = as.numeric(as.character(input$id_limit[2])))
                      enumerations_data = odk_data$enumerations
                      
                      # tmp <- list(data = data,
                      #             loc_id = lc,
                      #             enumeration = enum)
                      # save(tmp, file = '/tmp/tmp.RData')
                      out_file <- paste0(getwd(), '/visit_control_sheet.pdf')
                      rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/visit_control_sheet.Rmd'),
                                        output_file = out_file,
                                        params = list(data = data,
                                                      loc_id = lc,
                                                      enumeration = enum,
                                                      use_previous = use_previous,
                                                      enumerations_data = enumerations_data))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  output$render_file_index_list <-
    downloadHandler(filename = "file_list.pdf",
                    content = function(file){
                      
                      # Get the location code
                      lc <- location_code()
                      # Get other details
                      enum <- input$enumeration
                      data <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                         id_limit_lwr = as.numeric(as.character(input$id_limit[1])),
                                         id_limit_upr = as.numeric(as.character(input$id_limit[2])))
                      # generate html
                      # out_file <- paste0(system.file('shiny/operations/rmds', package = 'bohemia'), '/list.pdf')
                      out_file <- paste0(getwd(), '/file_list.pdf')
                      rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/file_list.Rmd'),
                                        output_file = out_file,
                                        params = list(data = data,
                                                      loc_id = lc))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
  
  output$render_consent_verification_list <-
    downloadHandler(filename = "consent_verification_list.pdf",
                    content = function(file){
                      
                      # Get the data
                      pdx <- consent_verification_list_reactive$data
                      # save(pdx, file = '/tmp/data.RData')
                      
                      out_file <- paste0(getwd(), '/consent_verification_list.pdf')
                      rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/consent_verification_list.Rmd'),
                                        output_file = out_file,
                                        params = list(data = pdx))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
  
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
