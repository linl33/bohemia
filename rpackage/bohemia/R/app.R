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
#' @import leafgl
#' @import sf
#' @import shinybusy
#' @import ggrepel
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
                                     choices = c('Tanzania' = 'Rufiji',
                                                 'Mozambique' = 'Mopeia'
                                     ),
                                     inline = TRUE,
                                     selected = 'Rufiji')),
                tags$li(class = 'dropdown',
                        uiOutput('log_ui')))),
      dashboardSidebar(
        sidebarMenu(
          id = 'sidebar',
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
                   menuSubItem(text = 'Sneak peek',
                               tabName = 'sneak_peek',
                               icon = icon('glasses')),
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
                   tabName = 'tracking',
                   icon = icon('list'),
                   startExpanded = FALSE,
                   menuSubItem(
                     text = 'Sheets',
                     tabName = 'tracking_tools',
                     icon = icon('list')
                   ),
                   menuSubItem(
                     text = 'Mark as done',
                     tabName = 'done_hamlets',
                     icon = icon('list'))),
          menuItem('Alerts',
                   tabName = 'alerts',
                   icon = icon('exclamation-circle')),
          menuItem('Download data',
                   tabName = 'download_data',
                   icon = icon('download')),
          menuItem(
            text = 'About',
            tabName = 'about',
            icon = icon("cog", lib = "glyphicon"))
        )),
      dashboardBody(
        add_busy_spinner(
          spin = "folding-cube",#  "self-building-square",
          position = 'bottom-right',
          onstart = TRUE,
          height = '100px',
          width = '100px',
          margins = c(10, 10)#,
          # color = 'de0000'
        ),
        
        # tags$head(
        #   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        # ),
        
        tabItems(
          tabItem(
            tabName="main",
            ui_main),
          tabItem(
            tabName = 'field_monitoring',
            tabsetPanel(tabPanel('Overview',
                                 navbarPage(
                                   title = 'Overview',
                                   tabPanel('Progress by geographical unit',
                                            uiOutput('ui_progress_by_geographical_unit')),
                                   tabPanel('Overall progress',
                                            uiOutput('ui_overall_progress'))
                                 )),
                        tabPanel('Performance',
                                 fluidPage(
                                   navbarPage(title = 'Performance',
                                              tabPanel('Fieldworkers',
                                                       tabsetPanel(
                                                         tabPanel('Individual data',
                                                                  fluidPage(
                                                                    uiOutput('ui_individual_data'),
                                                                    uiOutput('ui_individual_out')
                                                                  )),
                                                         tabPanel('Aggregate data',
                                                                  navbarPage('Fieldworkers tables',
                                                                             tabPanel('Daily',
                                                                                      fluidPage(
                                                                                        uiOutput('ui_fw_time_period'),
                                                                                        uiOutput('ui_fw_daily')
                                                                                      )
                                                                             ),
                                                                             tabPanel('Overall',
                                                                                      uiOutput('ui_fw_overall')))),
                                                         tabPanel('Dropouts',
                                                                  fluidRow(
                                                                    br() # drop out ui here
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
                                              tabPanel('VA progress',
                                                       tabsetPanel(
                                                         tabPanel('VA Overall progress',
                                                                  uiOutput('ui_va_overall_progress')),
                                                         tabPanel('VA progress by geographical unit',
                                                                  fluidPage(
                                                                    uiOutput('ui_va_monitoring_by'),
                                                                    br(),
                                                                    uiOutput('va_progress_geo_ui'))),
                                                         tabPanel('Past due VAs',
                                                                  uiOutput('ui_va_progress_past_due')
                                                         )
                                                         
                                                       ))
                                   )
                                 )
                                 
                        ),
                        tabPanel('GPS tracking',
                                 uiOutput('ui_gps')),
                        tabPanel('Refusals and Absences',
                                 uiOutput('ui_refusals_and_absences')))
          ),
          tabItem(
            tabName="enrollment",
            navbarPage(
              title = 'Enrollment data',
              tabPanel('Aggregated',
                       uiOutput('ui_enrollment'))
            )),
          tabItem(
            tabName="server_status",
            uiOutput('ui_server_status')),
          tabItem(
            tabName = 'done_hamlets',
            uiOutput('ui_done_hamlets')
          ),
          tabItem(
            tabName="tracking_tools",
            fluidPage(
              fluidRow(
                column(3,
                       uiOutput('all_locations_ui')),
                column(9, align = 'center',
                       navbarPage(title = 'Sheets',
                                  tabPanel("Visit control sheet", 
                                           fluidPage(
                                             h3("Visit control sheet"),
                                             uiOutput('ui_enumeration_n_hh'),
                                             helpText('The default numbers shown are 25% higher than the number estimated by the village leader.'),
                                             textInput('enumeration_n_teams',
                                                       'Number of teams',
                                                       value = 2),
                                             radioButtons('enumeration_or_minicensus',
                                                          'Type',
                                                          choices = c('Enumeration visit',
                                                                      'Data collection visit')),
                                             helpText('In the case of Mozambique, "Data collection visit" means that the visit control sheet will be populated based only on previously enumerated households from the hamlet (thereby ignoring the estimated number of forms or ID limitations inputs).'),
                                             
                                             uiOutput('ui_id_limit'),
                                             br(), 
                                             downloadButton("download_visit_control_data", "Download spreadsheet of visit control data"),
                                             br(),
                                             downloadButton('render_visit_control_sheet',
                                                            'Generate visit control sheet(s)')
                                           )),
                                  tabPanel("File index and folder location",
                                           fluidPage(
                                             h3("File index and folder location"),
                                             # uiOutput('ui_id_limit_file'),
                                             br(), br(),
                                             downloadButton('render_file_index_list',
                                                            'Generate file index and folder location list(s)')
                                           )),
                                  tabPanel('Consent verification list',
                                           fluidPage(
                                             fluidRow(
                                               column(6, checkboxInput('verification_all',
                                                                       'All fieldworkers?',
                                                                       value = TRUE)),
                                               column(6, 
                                                      uiOutput('ui_verification_text_filter'))
                                             ),
                                             uiOutput('ui_consent_verification_list_a'),
                                             uiOutput('ui_consent_verification_list')
                                           )),
                                  tabPanel('VA control sheet',
                                           uiOutput('ui_va_list_generation'))
                       ))
              )
            )),
          tabItem(
            tabName="sneak_peek",
            fluidPage(
              fluidRow(
                column(4,
                       selectInput('indicator_time', 'Choose variable', choices = c('Household size','Number of children', 'Ratio of children to adults', 'Number of cattle per household', 'Number of pigs per household', 'Number of mosquito nets per household'))),
              ),
              fluidRow(
                column(6, 
                       plotOutput('average_time'))
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
            tabName = 'download_data',
            uiOutput('download_ui')
          ),
          tabItem(
            tabName = 'alerts',
            navbarPage(
              title = 'Errors & anomalies',
              tabPanel('Alerts table',
                       fluidPage(
                         tags$img(src = "www/alerts_legend.png"),
                         # add_busy_gif(src = "https://jeroen.github.io/images/banana.gif", height = 70, width = 70),
                         uiOutput('anomalies_ui_a'),
                         uiOutput('anomalies_ui')
                       )),
              tabPanel('Bulk uploader',
                       fluidPage(
                         fluidRow(
                           p('Upload a .csv file of your corrections with at least the following 5 columns: "Instance id", "Id", "Response details", "Resolved by", "Resolution method"')
                         ),
                         
                         fluidRow(
                           column(6,
                                  fileInput("upload_data", "Choose CSV File",
                                            accept = c(
                                              "text/csv",
                                              "text/comma-separated-values,text/plain",
                                              ".csv")
                                  ))
                         ),
                         fluidRow(
                           column(12,
                                  tableOutput("upload_data_message"))
                         )
                       ))
            )
           
          ),
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
  
  
  share <- list(
    title = "Bohemia app",
    url = "https://bohemia.team/app/",
    image = "https://www.databrew.cc/images/logo_clear.png",
    description = "Bohemia app",
    twitter_user = "data_brew"
  )
  
  tags$head(
    
    # Facebook OpenGraph tags
    tags$meta(property = "og:title", content = share$title),
    tags$meta(property = "og:type", content = "website"),
    tags$meta(property = "og:url", content = share$url),
    tags$meta(property = "og:image", content = share$image),
    tags$meta(property = "og:description", content = share$description),
    
    # Twitter summary cards
    tags$meta(name = "twitter:card", content = "summary"),
    tags$meta(name = "twitter:site", content = paste0("@", share$twitter_user)),
    tags$meta(name = "twitter:creator", content = paste0("@", share$twitter_user)),
    tags$meta(name = "twitter:title", content = share$title),
    tags$meta(name = "twitter:description", content = share$description),
    tags$meta(name = "twitter:image", content = share$image),
    # 
    golem::activate_js(),
    golem::favicon(),
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
  
  # Define whether local or not
  if(grepl('brew', getwd())){
    is_local <- TRUE
    message('Using local database')
  } else {
    is_local <- FALSE
    message('Using remote database')
  }
  # is_local <- FALSE
  
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
                                 country = 'MOZ',
                                 already_loaded_errors = FALSE)
  
  # Create some reactive data
  session_data <- reactiveValues(aggregate_table = data.frame(),
                                 anomalies = data.frame(),
                                 fieldworkers = default_fieldworkers,
                                 traccar = data.frame(),
                                 traccar_summary = data.frame(),
                                 va_table = data.frame(),
                                 visit_control_data = data.frame())
  # create reactive object to store odk_data.
  odk_data <- reactiveValues(data = NULL)
  
  
  # Text for incorrect log-in, etc.
  reactive_log_in_text <- reactiveVal(value = '')
  
  # Observe the corner log-in / log-out buttons
  observeEvent(input$log_in_button, {
    # See if there was an incorrect user/password combo
    info_text <- reactive_log_in_text()
    make_log_in_modal(info_text = info_text)
  })
  
  country <- reactiveVal(value = 'Tanzania')
  observeEvent(input$confirm_log_in,{
    # Run a check on the credentials
    users <- yaml::yaml.load_file('credentials/users.yaml')
    liu <- input$log_in_user
    lip <- input$log_in_password
    ok <- credentials_check(user = liu,
                            password = lip,
                            users = users)
    gg <- input$geo
    if(gg == 'Rufiji'){
      the_country <- 'Tanzania'
    } else {
      the_country <- 'Mozambique'
    }
    country(the_country)
    if(ok){
      message('---Correct user/password. Logged in.')
      # Update sessions table
      sesh <- tibble(user_email = liu,
                     success = TRUE,
                     start_time = Sys.time(),
                     end_time = NA,
                     web = grepl('/srv/shiny-server', getwd(), fixed = TRUE))
      con <- get_db_connection(local = is_local)
      message('Writing session info to sessions table.')
      dbAppendTable(conn = con,
                    name = 'sessions',
                    value = sesh)
      
      # PAUSING TRACCAR STUFF, TOO SLOW, OPTIMIZE LATER
      # Read in the traccar data (could speed this up by not reading all in)
      message('Reading in traccar table')
      # Get the country
      co <- the_country
      lat_string <- ifelse(co == 'Mozambique',
                           'latitude < -15',
                           'latitude > -9')
      # Get fieldworkers for this country
      these_fids <- fids %>% filter(country == co)
      keep_ids <- these_fids$bohemia_id
      these_fids <- paste0("(",paste0("'",these_fids$bohemia_id,"'", collapse=","),")")
      # Get traccar data for those fieldworkers
      device_time <- paste0(Sys.Date() - 7, ' 01:01:01')
      traccar <- dbGetQuery(conn = con,
                             statement = paste0('SELECT * FROM traccar WHERE (unique_id IN ', these_fids, " AND devicetime > '", device_time, "' AND ", lat_string, ")"))
      session_data$traccar <- traccar
      dbDisconnect(con)
      # Get traccar summary data
      message('Retrieving information on workers from traccar')
      creds <- yaml::yaml.load_file('credentials/credentials.yaml')
      dat <- get_traccar_data(url = creds$traccar_server,
                              user = creds$traccar_user,
                              pass = creds$traccar_pass)
      # Keep only the summary data for the country
      dat$uniqueId <- as.numeric(dat$uniqueId)
      dat <- dat %>% filter(uniqueId %in% keep_ids)
      session_data$traccar_summary <- dat
      session_info$logged_in <- TRUE
      reactive_log_in_text('')
      removeModal()
    } else {
      message('---Incorrect user/password. Not logged in.')
      # Update the sessions table
      sesh <- tibble(user_email = liu,
                     success = FALSE,
                     start_time = Sys.time(),
                     end_time = NA,
                     web = grepl('ubuntu', getwd()))
      con <- get_db_connection(local = is_local)
      dbAppendTable(conn = con,
                    name = 'sessions',
                    value = sesh)
      dbDisconnect(con)
      session_info$logged_in <- TRUE
      reactive_log_in_text('')
      removeModal()
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
      out <- load_odk_data(local = is_local, the_country = the_country)
      odk_data$data <- out
      
      # Get anomalies
      con <- get_db_connection(local = is_local)
      anomalies <- dbGetQuery(conn = con,
                              statement = paste0("SELECT * FROM anomalies WHERE country = '", the_country, "'"))
      session_data$anomalies <- anomalies
      
      # PAUSING TRACCAR STUFF, TOO SLOW, OPTIMIZE LATER
      # Read in the traccar data (could speed this up by not reading all in)
      message('Reading in traccar table')
      # Get the country
      the_country <- country()
      co <- the_country
      lat_string <- ifelse(co == 'Mozambique',
                           'latitude < -15',
                           'latitude > -9')
      # Get fieldworkers for this country
      these_fids <- fids %>% filter(country == co)
      keep_ids <- these_fids$bohemia_id
      these_fids <- paste0("(",paste0("'",these_fids$bohemia_id,"'", collapse=","),")")
      # Get traccar data for those fieldworkers
      device_time <- paste0(Sys.Date() - 7, ' 01:01:01')
      traccar <- dbGetQuery(conn = con,
                            statement = paste0('SELECT * FROM traccar WHERE (unique_id IN ', these_fids, " AND devicetime > '", device_time, "' AND ", lat_string, ")"))
      session_data$traccar <- traccar
      # Get traccar summary data
      message('Retrieving information on workers from traccar')
      creds <- yaml::yaml.load_file('credentials/credentials.yaml')
      dat <- get_traccar_data(url = creds$traccar_server,
                              user = creds$traccar_user,
                              pass = creds$traccar_pass)
      
      dbDisconnect(con)
      
    }
  })
  
  # Observe log in and load data
  observeEvent(session_info$logged_in, {
    the_country <- country()
    li <- session_info$logged_in
    if(li){
      message('Logged in. Loading data for ', the_country)
      out <- load_odk_data(local = is_local, the_country = the_country)
      
      # Get anomalies
      con <- get_db_connection(local = is_local)
      anomalies <- dbGetQuery(conn = con,
                              statement = paste0("SELECT * FROM anomalies WHERE country = '", the_country, "'"))
      session_data$anomalies <- anomalies
      
      # PAUSING TRACCAR STUFF, TOO SLOW, OPTIMIZE LATER
      # Read in the traccar data (could speed this up by not reading all in)
      message('Reading in traccar table')
      # Get the country
      the_country <- country()
      co <- the_country
      lat_string <- ifelse(co == 'Mozambique',
                           'latitude < -15',
                           'latitude > -9')
      # Get fieldworkers for this country
      these_fids <- fids %>% filter(country == co)
      keep_ids <- these_fids$bohemia_id
      these_fids <- paste0("(",paste0("'",these_fids$bohemia_id,"'", collapse=","),")")
      # Get traccar data for those fieldworkers
      device_time <- paste0(Sys.Date() - 7, ' 01:01:01')
      traccar <- dbGetQuery(conn = con,
                            statement = paste0('SELECT * FROM traccar WHERE (unique_id IN ', these_fids, " AND devicetime > '", device_time, "' AND ", lat_string, ")"))
      session_data$traccar <- traccar
      # Get traccar summary data
      message('Retrieving information on workers from traccar')
      creds <- yaml::yaml.load_file('credentials/credentials.yaml')
      dat <- get_traccar_data(url = creds$traccar_server,
                              user = creds$traccar_user,
                              pass = creds$traccar_pass)
      
      dbDisconnect(con)
      
      odk_data$data <- out
      if(grepl('joebrew', getwd())){
        save(out, file = '~/Desktop/odk_data_data.RData')
      }
    }
  })
  
  
  # Error and anomaly detection
  observeEvent(input$sidebar, {
    sidebar <- input$sidebar
    message('Clicked on sidebar: ', sidebar)
    li <- session_info$logged_in
    if(!li){
      info_text <- reactive_log_in_text()
      make_log_in_modal(info_text = info_text)
    }
  })
  output$all_locations_ui <- renderUI({
    fluidRow(
      column(12, 
             # radioButtons('country', 'Country', choices = c('Tanzania', 'Mozambique'), inline = TRUE, selected = 'Mozambique'), 
             uiOutput('region_ui'),
             uiOutput('district_ui'),
             uiOutput('ward_ui'),
             uiOutput('village_ui'),
             uiOutput('hamlet_ui'),
             h4('Location code:'),
             h3(textOutput('location_code_text')))
    )
  })
  
  
  observeEvent(c(country(),
                 input$region,
                 input$district,
                 input$ward,
                 input$village,
                 input$hamlet), {
                   country = country()
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
                                            hamlet = hamlet,
                                            allow_all = TRUE)
                   
                   location_code(glc)
                 })
  output$location_code_text <- renderText({
    lc <- location_code()
    if(!is.null(lc)){
      if(length(lc) > 1){
        lc <- paste0(sort(lc), collapse = ', ')
      }
    }
    lc
  })
  
  output$region_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = country())
    choices <- sort(unique(sub_locations$Region))
    choices <- c(choices, 'All')
    country_name <- country()
    if(country_name == 'Mozambique'){
      selectInput('region', 'Região', choices = choices)
    } else {
      selectInput('region', 'Region', choices = choices)
    } 
  })
  
  output$district_ui <- renderUI({
    selected <- input$region
    ok <- FALSE
    if(!is.null(selected)){
      if(selected != 'All'){
        ok <- TRUE
      }
    }
    if(ok){
      sub_locations <- filter_locations(locations = locations,
                                        country = country(),
                                        region = input$region)
      choices <- sort(unique(sub_locations$District))
      choices <- c(choices, 'All')
      country_name <- country()
      if(country_name == 'Mozambique'){
        selectInput('district', 'Distrito', choices = choices)
      } else {
        selectInput('district', 'District', choices = choices)
      }
    } else {
      NULL
    }
  })
  
  output$ward_ui <- renderUI({
    selected <- input$district
    ok <- FALSE
    if(!is.null(selected)){
      if(selected != 'All'){
        selected <- input$region
        if(!is.null(selected)){
          if(selected != 'All'){
            ok <- TRUE
          }
        }
      }
    }
    if(ok){
      sub_locations <- filter_locations(locations = locations,
                                        country = country(),
                                        region = input$region,
                                        district = input$district)
      choices <- sort(unique(sub_locations$Ward))
      choices <- c(choices, 'All')
      country_name <- country()
      if(country_name == 'Mozambique'){
        selectInput('ward', 'Posto administrativo/localidade', choices = choices)
      } else {
        selectInput('ward', 'Ward', choices = choices)
      } 
    } else {
      NULL
    }
  })
  
  output$village_ui <- renderUI({
    selected <- input$ward
    ok <- FALSE
    if(!is.null(selected)){
      if(selected != 'All'){
        selected <- input$district
        if(!is.null(selected)){
          if(selected != 'All'){
            selected <- input$region
            if(!is.null(selected)){
              if(selected != 'All'){
                ok <- TRUE
              }
            }
          }
        }
      }
    }
    if(ok){
      sub_locations <- filter_locations(locations = locations,
                                        country = country(),
                                        region = input$region,
                                        district = input$district,
                                        ward = input$ward)
      choices <- sort(unique(sub_locations$Village))
      choices <- c(choices, 'All')
      country_name <- country()
      if(country_name == 'Mozambique'){
        selectInput('village', 'Povoado', choices = choices)
      } else {
        selectInput('village', 'Village', choices = choices)
      }
    } else {
      NULL
    }
  })
  
  output$hamlet_ui <- renderUI({
    selected <- input$village
    ok <- FALSE
    if(!is.null(selected)){
      if(selected != 'All'){
        selected <- input$ward
        if(!is.null(selected)){
          if(selected != 'All'){
            selected <- input$district
            if(!is.null(selected)){
              if(selected != 'All'){
                selected <- input$region
                if(!is.null(selected)){
                  if(selected != 'All'){
                    ok <- TRUE
                  }
                }
              }
            }
          }
        }
      }
    }
    if(ok){
      sub_locations <- filter_locations(locations = locations,
                                        country = country(),
                                        region = input$region,
                                        district = input$district,
                                        ward = input$ward,
                                        village = input$village)
      choices <- sort(unique(sub_locations$Hamlet))
      choices <- c(choices, 'All')
      country_name <- country()
      if(country_name == 'Mozambique'){
        selectInput('hamlet', 'Bairro', choices = choices)
      } else {
        selectInput('hamlet', 'Hamlet', choices = choices)
      } 
    } else {
      NULL
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
      num_houses <- gps %>% filter(code %in% lc) %>% .$n_households
      num_houses <- round(sum(num_houses) * 1.25)
    } else {
      num_houses <- 500
    }
    message('---- retrieved number of houses for hamlet selected')
    return(num_houses)
  })
  
  output$ui_enumeration_n_hh <- renderUI({
    val <- hamlet_num_hh()
    textInput('enumeration_n_hh',
              'Estimated number of forms',
              value = val)
    # message('---- created enumeration text input for estimated numer of forms')
    
  })
  
  output$ui_id_limit <- renderUI({
    val <- hamlet_num_hh()
    lc <- location_code()
    if(length(lc) > 1){
      high_val <- 1000
    } else {
      high_val <- round(val * 2)
    }
    
    fluidPage(
      sliderInput('id_limit', 'Limit IDs to:',
                  min = 1,
                  max = high_val, # round(num_houses),
                  value = c(1, high_val), # c(1, num_houses),
                  step = 1),
      helpText('Normally, do not touch this slider. Adjust it only if you want to exclude certain IDs (ie, in the case of having already printed numbers 1-50, you might set the lower limit of the slider to 51).')
    )
  })
  
  # output$ui_id_limit_file <- renderUI({
  #   val <- hamlet_num_hh()
  #   fluidPage(
  #     sliderInput('id_limit', 'Limit IDs to:',
  #                 min = 1,
  #                 max = val, # round(num_houses),
  #                 value = c(1, val), # c(1, num_houses),
  #                 step = 1),
  #     helpText('Normally, do not touch this slider. Adjust it only if you want to exclude certain IDs (ie, in the case of having already printed numbers 1-50, you might set the lower limit of the slider to 51).')
  #   )
  # })
  
  
  
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
  
  # sneak peek #############################################
  output$average_time <- renderPlot({
    
    # TEMOPRARY FUNCTION UNTIL WE FIND A DPLYR SOLUTION
    cummean_date <- function(temp_data, var_name){
      # loop through each date and get mean of variable up until that date
      names(temp_data)[which(names(temp_data)==var_name)] <- 'y'
      unique_dates <- sort(unique(temp_data$todays_date))
      loop_list <- list()
      raw_list <- list()
      for(i in 1:length(unique_dates)){
        this_date <- unique_dates[i]
        
        sub_temp_data <- temp_data %>% dplyr::filter(todays_date<=this_date)
        y_value <- mean(sub_temp_data$y, na.rm = TRUE)
        temp <- tibble('date'= this_date,
                       'y_value'= y_value)
        loop_list[[i]] <- temp
        raw_list[[i]] <- sub_temp_data %>% dplyr::select(date = todays_date, y)
      }
      part1 <- bind_rows(loop_list)
      part2 <- bind_rows(raw_list)
      out <- list(part1, part2)
      return(out)
    }
    
    # get data
    indic <- input$indicator_time
    pd <- odk_data$data
    # save(pd, file='odk_data.rda')
    pd_people <- pd$minicensus_people
    pd <- pd$minicensus_main
    
    # for the people dataset, group by instance id and summarise
    pd_people <- pd_people %>% group_by(instance_id) %>%
      mutate(age = floor(as.numeric(as.Date(Sys.Date()) - as.Date(dob))/ 365.25)) %>%
      summarise(total_people = n(),
                sum_children = length(which(age<18)),
                sum_adults = length(which(age>=18))) %>%
      mutate(child_to_adult = round(sum_children/sum_adults, 2))
    pd_people$child_to_adult[is.infinite(pd_people$child_to_adult)] <- 0
    # join pd and pd_people by
    pd <- left_join(pd, pd_people, by = 'instance_id')
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      if(indic=='Household size'){
        var_name <- 'hh_size'
      } else if(indic=='Number of cattle per household'){
        var_name <- 'hh_n_cows_less_than_1_year'
      } else if(indic=='Number of pigs per household'){
        var_name <- 'hh_n_pigs_less_than_6_weeks'
      } else if(indic=='Number of mosquito nets per household'){
        var_name <- 'n_nets_in_hh'
      } else if(indic=='Ratio of children to adults'){
        var_name <- 'child_to_adult'
      } else if(indic=='Number of children'){
        var_name <- 'sum_children'
      }
      plot_data <- cummean_date(pd, var_name = var_name)[[1]]
      raw_data <- cummean_date(pd, var_name = var_name)[[2]]
      
      ggplot() +
        geom_jitter(data = raw_data,
                    aes(x = date,
                        y = y),
                    size = 0.2,
                    alpha = 0.2,
                    height = 0.5) +
        geom_line(data = plot_data, aes(date,y_value),
                  color = 'darkred') +
        geom_point(data = plot_data, aes(date,y_value)) +
        labs(x = 'Date',
             y='Average up until date') +
        theme_bohemia() +
        geom_label(data = plot_data,
                   aes(x = date,
                       y = y_value,
                       label = round(y_value, 2)))
      
    } else {
      NULL
    }
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
  
  # date slider for progress by geography
  output$ui_progress_by_date <- renderUI({
    
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'field_monitoring' %in% si$access
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country==co)
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                column(6,
                       sliderInput(inputId = 'progress_by_date', 
                                   label = 'Select dates', 
                                   min = min(pd$todays_date), 
                                   max=max(pd$todays_date), 
                                   value = c(min(pd$todays_date), max(pd$todays_date))))
              )
            })
  })
  
  
  
  # Progress by geographical unit
  output$dt_monitor_by_table <- DT::renderDataTable({
    
    # Get the odk data
    pd <- odk_data$data
    
    enum <- pd$enumerations
    va <- pd$va
    # ref <- pd$refusals
    pd <- pd$minicensus_main
    co <- country()
    the_iso <- ifelse(co == 'Tanzania', 'TZA', 'MOZ')
    # save(pd, enum, va, co, the_iso, file = '/tmp/pd.RData')
    
    # get country
    pd <- pd %>% filter(hh_country==co)
    enum <- enum %>% filter(country==co)
    va <- va %>% filter(the_country==co)
    # ref <- ref %>% filter(country==co)
    
    # subset by date
    time_period <- input$progress_by_date
    if(is.null(time_period)){
      time_period <- c(as.Date('2020-01-01'), Sys.Date())
    } 
    
    pd <- pd %>% filter(todays_date >= time_period[1],
                        todays_date <=time_period[2]) 
    enum <- enum %>% filter(todays_date >= time_period[1],
                            todays_date <=time_period[2]) 
    va <- va %>% filter(todays_date >= time_period[1],
                        todays_date <=time_period[2]) 
    # save(pd, enum, va, file = 'temp_gps.rda')
    pd_ok <- FALSE
    
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(!pd_ok){
      out <- NULL
    } else {
      # Create a progress table
      target <- ifelse(co == 'Tanzania', 
                       gps %>% filter(iso == 'TZA', clinical_trial == 0) %>% summarise(x = sum(n_households)) %>% .$x,
                       30467)
      progress_table <- tibble(`Forms finished` = nrow(pd),
                               `Estimated total forms` = target,
                               `Estimated forms remaining` = target - nrow(pd),
                               `Estimated % finished` = round(nrow(pd) / target * 100, digits = 2))
      
      # Create a detailed progress table (by hamlet)
      left <- gps %>%
        filter(clinical_trial != 1) %>%
        filter(iso == the_iso) %>%
        dplyr::select(code, n_households)
      right <- pd %>%
        group_by(code = hh_hamlet_code) %>%
        summarise(numerator = n())
      right_enum <-enum%>%
        group_by(code = hamlet_code) %>%
        summarise(numerator = n())
      right_va <-va%>%
        mutate(hamlet_code = substr(death_id, 1, 3)) %>%
        group_by(code = hamlet_code) %>%
        summarise(`VA Forms done` = n())
      joined <- left_join(left, right, by = 'code') %>%
        mutate(numerator = ifelse(is.na(numerator), 0, numerator)) %>%
        mutate(p = numerator / n_households * 100) %>%
        mutate(p = round(p, digits = 2))
      joined_enum <-  left_join(left, right_enum, by = 'code') %>%
        mutate(numerator = ifelse(is.na(numerator), 0, numerator)) %>%
        mutate(p = numerator / n_households * 100) %>%
        mutate(p = round(p, digits = 2))
      progress_by_hamlet_enum <- joined_enum %>%
        left_join(locations %>% dplyr::select(code, Hamlet), by = 'code') %>%
        dplyr::select(code, Hamlet, `Enumerations Forms done` = numerator,
                      `Estimated number of forms` = n_households,
                      `Enumerations Estimated percent finished` = p)
      progress_by_hamlet <- joined %>%
        left_join(locations %>% dplyr::select(code, Hamlet), by = 'code') %>%
        dplyr::select(code, Hamlet, `Minicensus Forms done` = numerator,
                      `Estimated number of forms` = n_households) %>% 
        inner_join(progress_by_hamlet_enum) %>%
        # Get % minicensed of enumerated
        mutate(`% minicensed of enumerated` = `Minicensus Forms done` / `Enumerations Forms done` * 100)  %>%
        # add va
      left_join(right_va) %>%
        mutate(`VA Forms done` = ifelse(is.na(`VA Forms done`), 0, `VA Forms done`))

      # Transform the estimated number of forms (will be lower for MOZ than TZA since MOZ did buildings, not households)
      transformer <- ifelse(co == 'Mozambique', 0.55, 1)
      
      # Create a progress by geo tables
      apply_summary <- function(df){
        df %>%
          summarise(`Minicensus Forms done` = sum(`Minicensus Forms done`, na.rm = TRUE),
                    `Enumeration Forms done` = sum(`Enumerations Forms done`, na.rm = TRUE),
                    `Target forms (recon)` = sum(`Estimated number of forms`, na.rm = TRUE),
                    `VA Forms done` = sum(`VA Forms done`, na.rm = TRUE)) %>%
          ungroup %>%
          mutate(#`Minicensus Estimated percent finished`  = round(`Minicensus Forms done` / `Estimated number of forms` * 100, digits = 2),
                 `% Enumerated of target` = round(`Enumeration Forms done` / `Target forms (recon)` * 100, digits = 2),
                 `% Minicensed of enumerated` = round(`Minicensus Forms done` / `Enumeration Forms done` * 100, digits = 2)) %>%
          select(`Minicensus Forms done`, `Enumeration Forms done`, `Target forms (recon)`,`% Enumerated of target`,`% Minicensed of enumerated`  , `VA Forms done`)
      }
      progress_by <- progress_by_hamlet %>% left_join(locations %>% 
                                            dplyr::select(code, District, Ward, Village), by = 'code')
      
      
      progress_by_district <- progress_by %>% group_by(District) %>%
        apply_summary
      
      progress_by_ward <- progress_by %>% 
        group_by(Ward) %>% 
        apply_summary
      progress_by_village <- progress_by %>% 
        group_by(Village) %>% 
        apply_summary
      progress_by_hamlet <- progress_by %>% 
        group_by(Hamlet) %>% 
        apply_summary
      
      
      by_geo <- field_monitoring_geo() 
      
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
            names(progress_by_hamlet)[2] <- 'Bairro'
            monitor_by_table <- progress_by_hamlet
          } else {
            monitor_by_table <- progress_by_hamlet
          }
        }
      }
      # reorder columns
      
      message('---created progess table for Overview by geography')
      out <- bohemia::prettify(monitor_by_table, download_options = TRUE, nrows = nrow(monitor_by_table))
    }
    return(out)
  })
  
  # Map of progress by geography
  output$leaf_lx <- renderLeaflet({
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    the_iso <- ifelse(co == 'Tanzania', 'TZA', 'MOZ')
    pd <- pd %>% filter(hh_country == co)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(!pd_ok){
      out <- NULL
    } else {
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
        left_join(gps %>% dplyr::select(code, n_households), by = 'code') %>%
        mutate(p = n / n_households * 100)
      lxd_all <- left_join(gps %>% filter(iso == the_iso) %>% 
                             dplyr::select(code, lng, lat), lxd_all, by = 'code') %>%
        mutate(p = ifelse(is.na(p), 0, p))
      pal_all <- pal_hamlet <- colorNumeric(
        palette = c("black","darkred", 'red', 'darkorange', 'blue'),
        domain = 0:ceiling(max(lxd_all$p))
      )
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
        addLegend(title = '% completed', position = c("bottomleft"), pal = pal_hamlet, values = lxd_all$p)
      
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
        addLegend(title = '% completed', position = c("bottomleft"), pal = pal_village, values = lxd_village$p)
      
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
        addLegend(title = '% completed', position = c("bottomleft"), pal = pal_ward, values = lxd_ward$p)
      
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
        addLegend(title = '% completed', position = c("bottomleft"), pal = pal_district, values = lxd_district$p) %>%
        setView(lng = lxd_district$lng,
                lat = lxd_district$lat,
                zoom = 8)
      # get input for which location to view
      map_location = field_monitoring_geo()
      message('---Field monitoring map location level is ', map_location)
      # get country to translate names for map title
      cn <- input$geo
      cn <- ifelse(cn == 'Rufiji', 'Tanzania', 'Mozambique')
      if(is.null(map_location)){
        lx <- lxd_hamlet
      } else {
        if(map_location == 'District'){
          lx <- lxd_district
        }
        if(map_location=='Hamlet'){
          lx <- lxd_hamlet
        } else if(map_location=='Village'){
          lx <- lxd_village
        } else if(map_location=='Ward'){
          lx <- lxd_ward
        }
      }
      message('---Created map of progess by geography')
      
      out <- lx
    }
    return(out)
  })
  
  output$ui_progress_by_geographical_unit <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                h3('Progress by geographical unit'),
                uiOutput('ui_field_monitoring_by'),
                uiOutput('ui_progress_by_date'),
                column(12, align = 'center',
                       div(DT::dataTableOutput('dt_monitor_by_table'), style = "font-size:80%"),
                       leafletOutput('leaf_lx', height = 800))
              )
            })
  })
  
  # Overall progress ui elements ####################################
  output$gt_overview <- gt::render_gt({
    
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
      fid_choices <- fid_choices %>% dplyr::filter(as.numeric(id) %in% as.numeric(fid_options))
      x = as.character(fid_choices$name)
      y = as.character(fid_choices$id)
      fid_choices <- as.numeric(y)
      
      # Some pre-processing
      dr <- as.Date(range(pd$todays_date, na.rm = TRUE))
      n_days = as.numeric(1 + (max(dr)-min(dr)))
      the_iso <- iso <- ifelse(co == 'Tanzania', 'TZA', 'MOZ')
      # target <- sum(gps$n_households[gps$iso == iso], na.rm = TRUE)
      target <- ifelse(iso == 'TZA', 
                       gps %>% filter(iso == 'TZA', clinical_trial == 0) %>% summarise(x = sum(n_households)) %>% .$x,
                       30467)
      
      # save(pd, file = 'temp_pd.rda')
      # create a placeholder for number of fieldworkers. 
      # num_fws <- length(unique(pd$wid)) #-12 - get average number of unique fieldworkers per day
      if(co == 'Tanzania'){
        num_fws <- 73
      } else {
        num_fws <- 86
      }
      
      
      # Create table of overview
      overview <- pd %>%
        summarise(Type = 'Observed',
                  `No. FWs` = num_fws,
                  `Daily forms/FW` = round(nrow(pd) / `No. FWs` / n_days, digits = 1),
                  `Weekly forms/FW` = round(`Daily forms/FW` * 7, digits = 1),
                  `Total forms/FW` = round(nrow(pd) / `No. FWs`, digits = 1),
                  `Total Daily forms/country` = round(nrow(pd) / n_days, digits = 1),
                  `Total Weekly forms/country` = round(`Total Daily forms/country` * 7, digits = 1),
                  `Overall target/country` = nrow(pd),
                  `# Total weeks` = round(target/`Total Weekly forms/country`, digits = 1)) %>%
        mutate(`Estimated date` = (`# Total weeks` * 7) + as.Date(dr[1]))
      message('---Created "observed" row for overall progress table')
      
      # # Get a second row for targets
      # hard coded values for each country
      if(co=='Tanzania'){
        num_fws <- 77
        daily_forms_fw <- 13
        weekly_forms_fw <- daily_forms_fw*5
        total_forms_fw <- 599
        total_daily_country <- 1001
        total_weekly_country <- total_daily_country*5
        total_forms <- gps %>% filter(iso == 'TZA', clinical_trial == 0) %>% summarise(x = sum(n_households)) %>% .$x
        total_weeks <- round(total_forms/total_weekly_country,2)
        total_days <- total_weeks*7
        est_date <- Sys.Date()+total_days
      } else {
        num_fws <- 86
        daily_forms_fw <- 10
        weekly_forms_fw <- daily_forms_fw*5
        total_forms_fw <- 500
        total_daily_country <- 1000
        total_weekly_country <- total_daily_country*5
        total_forms <- 30467
        total_weeks <- round(total_forms/total_weekly_country,2)
        total_days <- total_weeks*7
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
      message('---Created "target" row for overall progress table')
      
      third_row <- 
        tibble(Type = 'Percentage',
               `No. FWs` = round(overview$`No. FWs`/second_row$`No. FWs` * 100),  
               `Daily forms/FW` = round(overview$`Daily forms/FW`/second_row$`Daily forms/FW`, 2)  * 100,
               `Weekly forms/FW` = round(overview$`Weekly forms/FW`/second_row$`Weekly forms/FW`,2) * 100,
               `Total forms/FW` = round(overview$`Total forms/FW`/second_row$`Total forms/FW`,2) * 100,
               `Total Daily forms/country` = round(overview$`Total Daily forms/country`/second_row$`Total Daily forms/country`,2) * 100,
               `Total Weekly forms/country` = round(overview$`Total Weekly forms/country`/second_row$`Total Weekly forms/country`,2) * 100,
               `Overall target/country` = round(overview$`Overall target/country`/total_forms,2)*100,
               `# Total weeks` = ' ', #round(overview$`# Total weeks`/second_row$`# Total weeks`,2),
               `Estimated date` = '')
      message('---Created "percentage" row for overall progress table')
      
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
      message('---Created estimated targets table')
    } else {
      overview <- NULL
    }
    return(overview)
  })
  
  output$plot_progress <- renderPlot({
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
      target <- ifelse(co == 'Tanzania', 
                       gps %>% filter(iso == 'TZA', clinical_trial == 0) %>% summarise(x = sum(n_households)) %>% .$x,
                       30467)
      x <- pd %>%
        group_by(date = as.Date(todays_date)) %>%
        tally %>%
        mutate(denom = target) %>%
        mutate(cs = cumsum(n)) %>%
        mutate(p = cs / denom * 100)
      g <- ggplot(data = x,
                  aes(x = date,
                      y = p)) +
        geom_point() +
        geom_area(alpha = 0.3, fill = 'red', color = 'black') +
        theme_bohemia() +
        labs(x = 'Date',
             y = 'Percent of target completed',
             title = 'Cumulative percent of target completed') +
        ylim(0,100)
    } else {
      g <- ggplot() 
    }
    message('---Created overall progress plot ')
    return(g)
  })
  output$gt_progress_table <- gt::render_gt({
    
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
      target <- ifelse(co == 'Tanzania', 
                       gps %>% filter(iso == 'TZA', clinical_trial == 0) %>% summarise(x = sum(n_households)) %>% .$x,
                       30467)
      progress_table <- tibble(`Forms finished` = nrow(pd),
                               `Estimated total forms` = target,
                               `Estimated forms remaining` = target - nrow(pd),
                               `Estimated % finished` = round(nrow(pd) / target * 100, digits = 2))
    } else {
      progress_table <- data.frame(a = 0)
    }
    message('---Created overall progress table ')
    return(progress_table)
  })
  
  output$ui_overall_progress <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                gt::gt_output('gt_overview'),
                fluidRow(
                  column(6,
                         h3('Overall progress plot'),
                         plotOutput('plot_progress')),
                  column(6,
                         h3('Overall progress table'),
                         gt::gt_output('gt_progress_table'))
                ))
            })
  })
  
  # Individual data
  output$leaf_fid <- renderLeaflet({
    # Get the odk data
    who <- input$fid
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country == co)
    # save(pd, file = 'fid_pd.rda')
    if(is.null(who)){
      who <- 0
    }
    pd <- pd %>% filter(wid==who)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      ll <- extract_ll(pd$hh_geo_location)
      pd$lng <- ll$lng; pd$lat <- ll$lat
      # round table not here, and here make sure map works (not saving data below)
      l <- leaflet() %>%
        # addProviderTiles(providers$Stamen.Toner) %>%
        # addProviderTiles(providers$Esri.WorldImagery) %>%
        addTiles() %>%
        clearMarkers() %>%
        addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
      
    } else {
      l <- leaflet() %>% addProviderTiles(providers$Esri.WorldImagery)# addProviderTiles(providers$Stamen.Toner)
      
    }
    l
  })
  
  # table for anomaly description
  output$table_individual_errors <- renderTable({
    an <- session_data$anomalies
    who <- input$fid
    the_country <- country()
    
    an <- an %>% filter(wid==who)
    # an <- an %>% filter(country==the_country)
    
    if(nrow(an)>0){
      pd <- an %>%
        group_by(type, description) %>%
        summarise(Occurrences = n()) %>%
        dplyr::arrange(desc(Occurrences))
      pd
    } else {
      NULL
    }
  })
  
  output$table_individual_details <- renderTable({
    
    # Get the odk data
    pd <- odk_data$data
    # save(pd, file='temp_odk_dat.rda')
    enum <- pd$enumerations
    va <- pd$va
    ref <- pd$refusals
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country == co)
    enum <- enum %>% filter(country==co)
    va <- va %>% filter(the_country==co)
    ref <- ref %>% filter(country==co)
    min_date <- min(pd$todays_date, na.rm = TRUE)
    max_date <- max(pd$todays_date, na.rm = TRUE)
    seq_days <- seq(min_date, max_date, by = 1)
    seq_days <- seq_days[!weekdays(seq_days) %in% c('Saturday', 'Sunday')]
    n_days <- length(seq_days)
    # get anomaly dataset
    an <- session_data$anomalies
    # save(pd, co, an,
    #      file = '/tmp/fw.RData')
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      if(co=='Tanzania'){
        num_fws <- 77
        daily_forms_fw <- 13
        weekly_forms_fw <- daily_forms_fw*5
        total_forms_fw <- 599
        
      } else {
        num_fws <- 100
        daily_forms_fw <- 10
        weekly_forms_fw <- daily_forms_fw*5
        total_forms_fw <- 500
      }
      who <- input$fid
      
      pd <- pd %>%
        mutate(end_time = lubridate::as_datetime(end_time))
      if(nrow(an) > 0){
        an$date <- as.Date(an$date, format='%Y-%m-%d')
        an <- an %>% filter(wid==who)
        num_anomaly <- length(which(an$type=='anomaly'))
        num_error <- length(which(an$type=='error'))
      } else {
        num_anomaly <- 0
        num_error <- 0
      }
      
      if(is.null(who)){
        who <- 0 
      }
      
      id <- who
      pd <- pd %>% filter(wid == id)
      enum <- enum %>% filter(wid==id)
      va <- va %>% filter(wid==id)
      ref <- ref %>% filter(wid==id)
      
      last_upload <- as.character(max(pd$end_time, na.rm = TRUE))
      sup_name <- as.character(fids$supervisor[fids$bohemia_id == id])
      total_forms <- nrow(pd)
      average_time <- mean(pd$end_time - pd$start_time)
      average_time <- paste0(round(as.numeric(average_time), digits = 2), ' ', attr(average_time, 'units'))
      daily_work_hours <- '(pending)'
      rolling_per = round((total_forms / n_days) / daily_forms_fw * 100, digits = 2)
      total_per = round(total_forms/total_forms_fw * 100,2)
      message('---Created FW performance individual table ')
      
      # get number of enumeration, refusals, and va forms filled 
      num_enum = nrow(enum)
      num_va = nrow(va)
      num_ref = nrow(ref)
      
      # last_days <-paste0('Last ', time_period, ' days')
      tibble(` ` = c('Supervisor','% of rolling minicensus target','% of total minicensus target','# of minicensus forms','# of enumeration forms','# of va forms','# of refusals','# of anomalies', '# of errors','Average time/form', 'Daily work hours'), `   ` = c(sup_name, rolling_per, total_per, total_forms, num_enum, num_va, num_ref,num_anomaly, num_error,average_time, daily_work_hours))
    } else {
      NULL
    }
    
  })
  
  output$plot_individual_errors <- renderPlot({
    an <- session_data$anomalies
    who <- input$fid
    the_country <- country()
    
    an <- an %>% filter(wid==who)
    an <- an %>% filter(country==the_country)
    
    if(nrow(an)>0){
      an <- an %>%
        mutate(date = strsplit(as.character(date), ",")) %>%
        unnest(date) %>%
        group_by(date) %>%
        summarise(`# of anomalies` = sum(type == 'error', na.rm=TRUE),
                  `# of errors` = sum(type == 'anomaly', na.rm=TRUE)) %>%
        gather(key=key, value=value, -date) %>%
        mutate(date = as.Date(date))
      ggplot(an, aes(date, value, fill=key)) +
        geom_bar(stat = 'identity', position = 'dodge') +
        scale_fill_manual(name = '',
                          values = c('black', 'grey')) +
        labs(x='Date', y='', title='Number of errors and anomalies') +
        theme_bohemia()
    } else {
      NULL
    }
    
    
  })
  
  
  output$plot_individual_target <- renderPlot({
    
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country == co)
    
    if(co=='Mozambique'){
      daily_forms_fw <- 10
      total_forms_fw <- 500
    } else {
      daily_forms_fw <- 13
      total_forms_fw <- 599
    }
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      who <- input$fid
      if(is.null(who)){
        who <- 0 
      }
      
      min_date <- min(pd$todays_date, na.rm = TRUE)
      max_date <- max(pd$todays_date, na.rm = TRUE)
      seq_days <- seq(min_date, max_date, by = 1)
      seq_days <- seq_days[!weekdays(seq_days) %in% c('Saturday', 'Sunday')]
      
      left <- tibble(date = seq_days) %>%
        mutate(target = daily_forms_fw *(1:length(seq_days)))
      
      plot_data <- pd %>% filter(wid == who)
      if(nrow(plot_data) > 0){
        plot_data <- plot_data %>%
          group_by(date = todays_date) %>%
          tally %>%
          ungroup 
        joined <- left_join(left, plot_data) %>%
          mutate(n = ifelse(is.na(n), 0, n)) %>%
          mutate(cs = cumsum(n)) %>%
          dplyr::select(date, Target = target, Observed = cs ) %>%
          tidyr::gather(key, value, Target:Observed)
        
        g <- ggplot(data = joined,
                    aes(x = date,
                        y = value)) +
          geom_step(aes(color = key,
                        group = key)) +
          geom_point(aes(color = key)) +
          labs(x = 'Date',
               y = 'Forms collected',
               title = 'Forms collected by date') +
          theme_bohemia() +
          scale_color_manual(name = '',
                             values = c('red', 'blue')) +
          theme(legend.position = 'bottom')
        
        
      } else {
        g <- NULL
      }
      
    } else {
      g <- NULL
    }
    return(g)
    
  })
  
  output$plot_individual_details <- renderPlot({
    
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country == co)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      who <- input$fid
      if(is.null(who)){
        who <- 0 
      }
      plot_data <- pd %>% filter(wid == who)
      if(nrow(plot_data) > 0){
        plot_data <- plot_data %>%
          group_by(date = todays_date) %>%
          tally
        
        g <- ggplot(data = plot_data,
                    aes(x = date,
                        y = n)) +
          geom_bar(stat = 'identity',
                   fill = 'black') +
          labs(x = 'Date',
               y = 'Forms collected',
               title = 'Forms collected by date') +
          theme_bohemia()
        
        
      } else {
        g <- NULL
      }
      
    } else {
      g <- NULL
    }
    return(g)
    
  })
  
  output$plot_individual_form_time <- renderPlot({
    
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    co <- country()
    pd <- pd %>% filter(hh_country == co)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      who <- input$fid
      if(is.null(who)){
        who <- 0 
      }
      plot_data <- pd %>% filter(wid == who)
      if(nrow(plot_data) > 0){
        plot_data$time_taken <- plot_data$end_time - plot_data$start_time
        units_taken <- attr(plot_data$time_taken, 'units')
        avg <- mean(plot_data$time_taken)
        avg <- round(avg, digits = 2)
        n <- nrow(plot_data)
        g <- ggplot(data = plot_data,
                    aes(x = time_taken)) +
          geom_histogram(fill = 'darkred', alpha = 0.6, color = 'black') +
          labs(x = paste0('Time per form (', units_taken, ')'),
               y = 'Density',
               title = paste0('Distribution of time taken per form for FW ',
                              who, '; ', n, ' forms, ', avg, ' ', units_taken)) +
          theme_bohemia()
        
        
      } else {
        g <- NULL
      }
      
    } else {
      g <- NULL
    }
    return(g)
    
  })
  
  
  
  output$ui_individual_data <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # Get the odk data
              pd <- odk_data$data
              pd <- pd$minicensus_main
              co <- country()
              # save(pd, file = '/tmp/pd.RData')
              pd <- pd %>% filter(hh_country == co)
              
              # Define choices for leaflet fw selection
              co <- country()
              sub_fids <- fids %>% 
                filter(country == co)
              the_choices <- sub_fids$bohemia_id
              names(the_choices) <- paste0(sub_fids$bohemia_id, '. ',
                                           sub_fids$first_name, ' ',
                                           sub_fids$last_name)
              
              
              fluidPage(
                # fluidRow(
                #   infoBox(title = 'Number of detected anomalies',
                #           icon = icon('microscope'),
                #           color = 'black',
                #           width = 6,
                #           h1(0)),
                #   infoBox(title = 'Number of detected errors',
                #           icon = icon('address-book'),
                #           color = 'black',
                #           width = 6,
                #           h1('0%'))
                # ),
                fluidRow(
                  column(12,
                         selectInput('fid',
                                     'Fieldworker ID',
                                     choices = the_choices)))
              )
            })
  })
  output$ui_individual_out <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                fluidRow(
                  column(6,
                         tableOutput('table_individual_details')),
                  column(6,
                         tableOutput('table_individual_errors'))),
                fluidRow(
                  column(6,
                         plotOutput('plot_individual_target')),
                  column(6,
                         plotOutput('plot_individual_errors'))
                ),
                fluidRow(column(6, align = 'center',
                                h3('Locations visited by FW over last 7 days'),
                                leafletOutput('traccar_leaf',
                                              height = 500)),
                         column(6,
                                h3('Locations of forms submitted by FW'),
                                leafletOutput('leaf_fid',
                                              height = 500)
                         )),
                fluidRow(
                  column(6,
                         plotOutput('plot_individual_details')),
                  column(6,
                         plotOutput('plot_individual_form_time'))
                )
              )})
  })
  
  # Text above VA table
  output$va_text <- renderText({
    pd <- session_data$va_table
    out <- NULL
    if(nrow(pd) == 0){
      out <- 'No unfinished VA forms for the location(s) selected. Consider modifying locations (left).'
    }
    return(out)
  })
  
  # Va data
  observeEvent(location_code(),{
    
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    if(li){
      pd <- odk_data$data
      pd <- pd$minicensus_main
      cn <- country()
      pd <- pd %>% filter(hh_country == cn)
      
      pd_ok <- FALSE
      if(!is.null(pd)){
        if(nrow(pd) > 0){
          pd_ok <- TRUE
        }
      }
          if(pd_ok){
            # va table
            people <- odk_data$data$minicensus_people
            deaths <- odk_data$data$minicensus_repeat_death_info
            deaths <- deaths %>% filter(instance_id %in% pd$instance_id)
            # Conditional mourning period
            mourning_period <- ifelse(cn == 'Mozambique', 30, 40)
            va <- left_join(deaths %>%
                              left_join(pd %>%
                                          dplyr::select(instance_id, todays_date), by = 'instance_id') %>%
                              mutate(todays_date = as.Date(todays_date),
                                     death_dod = as.Date(death_dod)) %>%
                              mutate(old = (todays_date - death_dod) > mourning_period) %>%
                              mutate(time_to_add = ifelse(old, 7, mourning_period)) %>%
                              mutate(xx = todays_date + time_to_add#, # this needs to be 7 days after hh visit date if death was <40 days prior to hh visit date | 40 days after hh visit date if the death was >40 days after hh visit date
                                     # yy = Sys.Date() - todays_date
                              ) %>%
                              # Note: in case the "date of death" is unknown (the form has that option): let's just calculate the "latest date to do VA" by adding 40 days (Tanzania) and 30 days (Moz) to the "date of the hh visit", to be safe.
                              mutate(safe_bet = todays_date + mourning_period) %>%
                              mutate(xx = ifelse(is.na(xx), safe_bet, xx)) %>%
                              mutate(xx = as.Date(xx, origin = '1970-01-01')) %>%
                              mutate(yy = Sys.Date() - xx) %>% # "time elapsed" means time between lastest date to collect and today
                              mutate(death_initials = paste0(
                                ifelse(is.na(death_name), '.',
                                       death_name),
                                ifelse(is.na(death_surname),
                                       '.', death_surname))) %>%
                              dplyr::select(instance_id,
                                            death_initials,
                                            `Date of death` = death_dod,
                                            `Latest date to collect VA form` = xx,
                                            `ID of deceased person` = death_id,
                                            `Time elapsed` = yy),
                            pd %>%
                              mutate(num = as.numeric(hh_head_id)) %>%
                              dplyr::select(instance_id,
                                            District = hh_district,
                                            Ward = hh_ward,
                                            Village = hh_village,
                                            Hamlet = hh_hamlet,
                                            `HH ID` = hh_id,
                                            `FW ID` = wid,
                                            num, # for getting the initials of household head
                                            `HH visit date` = todays_date), by = 'instance_id') %>%
              left_join(people %>% dplyr::select(instance_id,
                                                 first_name,
                                                 last_name,
                                                 pid,
                                                 num), by = c('instance_id', 'num')) %>%
              mutate(`FW ID` = ' ') %>%
              dplyr::select(-instance_id) %>%
              mutate(`HH head ID and initials` = paste0(pid, ' (', first_name, last_name, ')'))

            # Remove those which have already been collected
            already_done <- unique(odk_data$data$va$death_id)
            va <- va %>% filter(!`ID of deceased person` %in% already_done)

            # Remove those not in the selected location hierarchy
            lc <- location_code()
            va <- va %>% filter(substr(`HH ID`, 1, 3) %in% lc)

            if(nrow(va) > 0){
              va <- va %>% dplyr::select(District,
                                         Ward,
                                         Village,
                                         Hamlet,
                                         `HH ID`,
                                         `HH head ID and initials`,
                                         # `FW ID`,
                                         `Name of deceased person` = death_initials,
                                         `ID of deceased person`,
                                         `Date of death`,
                                         `Latest date to collect VA form`
              ) %>%
                mutate(`FW / Supervisor ID` = ' ',
                       `Date of VA visit` = ' ',
                       `Was the ICF signed?` = 'Yes__ No__',
                       `Was the VA form completed?` = 'Yes__ No__',
                       `If this HH was not visited or the VA form was not completed, explain why` = '                 ')
              if(cn=='Mozambique'){
                va <- va %>%  rename(Distrito = District,
                                     `PA / Localidade`=Ward,
                                     Povoado=Village,
                                     Bairro=Hamlet)
              }

              message('---Created list generation table for VA')
              # Save for use in other places
              session_data$va_table <- va
            } else {
              session_data$va_table <- data.frame()
            }
          } else {
            session_data$va_table <- data.frame()
          }
    } else {
      session_data$va_table <- data.frame()
    }
    
  })
  
  # VA list generation table
  output$table_va_list_generation <- DT::renderDataTable({
    va <- session_data$va_table
    if(nrow(va) > 0){
      # Make datatable
      final <- DT::datatable(va, 
                             options = list(pageLength = nrow(va), 
                                            dom = "Bfrtip", buttons = list("copy", "print", 
                                                                           list(extend = "collection", buttons = "csv", 
                                                                                text = "Download"))), rownames = FALSE, extensions = "Buttons") %>%
        formatStyle(names(va)[1:6],
                    backgroundColor = '#ffcccb') %>%
        formatStyle(names(va)[7:10],
                    backgroundColor = '#fed8b1') %>%
        formatStyle(names(va)[11:ncol(va)],
                    backgroundColor = '#ADD8E6')
    } else {
      final <- DT::datatable(data.frame(`O` = 'No data'))
    }
    
    return(final)
  })
  # VA List Generation UI
  output$ui_va_list_generation <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              pd <- session_data$va_table
              any_va <- nrow(pd) > 0
              if(any_va){
                fluidPage(
                  column(12, align = 'center',
                         downloadButton('render_control_sheet',
                                        'Print VA control sheet'),
                         br(), br(),
                         div(DT::dataTableOutput('table_va_list_generation'), style = "font-size:60%")
                         )
                )
              } else {
                fluidPage(
                  column(12, align = 'center',
                         textOutput('va_text'),
                  ))
              }
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
  
  # ui for va overall progress
  output$ui_va_overall_progress <- renderUI({
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
              deaths <- deaths %>% filter(instance_id %in% pd$instance_id,
                                          !is.na(death_number))
              pd <- pd %>%
                dplyr::select(district = hh_district,
                              ward = hh_ward,
                              village = hh_village,
                              hamlet = hh_hamlet, instance_id)
              # # Get VA info
              va <- odk_data$data$va
              # save(va, pd, co, deaths, file = '/tmp/tmp.RData')
              
              grouper <- 'district'
              
              va_progress <- deaths %>%
                left_join(pd) %>%
                filter(!is.na(hamlet)) %>%
                group_by_(grouper) %>%
                summarise(`VA forms collected` = nrow(va),
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
              
              deaths <- deaths %>% filter(instance_id %in% pd$instance_id,
                                          !is.na(death_number))
              pd <- pd %>%
                dplyr::select(district = hh_district,
                              ward = hh_ward,
                              village = hh_village,
                              hamlet = hh_hamlet, instance_id)
              
              grouper <- input$va_monitor_by
              
              
              va <- odk_data$data$va
              # Get location in va
              va <- va %>%
                mutate(code = substr(hh_id, 1, 3)) %>%
                left_join(locations %>% dplyr::select(code, region = Region, district = District,
                                                      ward = Ward, village = Village, hamlet = Hamlet))
              
              
              if(is.null(grouper)){
                grouper <- 'district'
              } else {
                grouper <- tolower(grouper)
              }
              va_agg <- va %>%
                group_by_(grouper) %>%
                summarise(`VA forms collected` = n())
              
              va_progress_geo <- deaths %>%
                left_join(pd) %>%
                filter(!is.na(hamlet)) %>%
                group_by_(grouper) %>%
                summarise(`Deaths reported` = n()) %>%
                full_join(va_agg) %>%
                mutate(`VA forms collected` = ifelse(is.na(`VA forms collected`), 0, `VA forms collected`)) %>%
                mutate(`Deaths reported` = ifelse(is.na(`Deaths reported`), 0, `Deaths reported`)) %>%
                mutate(`% VA forms completed` = round(`VA forms collected` /
                                                        `Deaths reported` * 100))
              message('---Created progess table for VA by geography')
              
              
              if(co == 'Mozambique'){
                if(grouper=='district'){
                  names(va_progress_geo)[1] <- 'Distrito'
                } else if(grouper=='ward'){
                  names(va_progress_geo)[1] <- 'Posto administrativo/localidade'
                } else if (grouper=='hamlet'){
                  names(va_progress_geo)[1] <- 'Bairro'
                } else if(grouper =='village'){
                  names(va_progress_geo)[1] <- 'Povaodo'
                }
              }
              fluidPage(
                fluidRow(
                  h2(paste0('Progress by ',  names(va_progress_geo)[1])),
                  prettify(va_progress_geo)
                )
              )
            })
  })
  
  
  output$table_va_progress_past_due <- DT::renderDataTable({
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$minicensus_main
    cn <- country()
    pd <- pd %>% filter(hh_country == cn)
    
    pd_ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd_ok <- TRUE
      }
    }
    if(pd_ok){
      # va table
      deaths <- odk_data$data$minicensus_repeat_death_info
      deaths <- deaths %>% filter(instance_id %in% pd$instance_id)
      va <- odk_data$data$va
      
      # Conditional mourning period
      mourning_period <- ifelse(cn == 'Mozambique', 30, 40)
      out <- left_join(deaths %>% 
                         left_join(pd %>% dplyr::select(instance_id, todays_date), by = 'instance_id') %>%
                         mutate(todays_date = as.Date(todays_date),
                                death_dod = as.Date(death_dod)) %>%
                         mutate(old = (todays_date - death_dod) > mourning_period) %>%
                         mutate(time_to_add = ifelse(old, 7, mourning_period)) %>%
                         mutate(xx = todays_date + time_to_add#, # this needs to be 7 days after hh visit date if death was <40 days prior to hh visit date | 40 days after hh visit date if the death was >40 days after hh visit date
                                # yy = Sys.Date() - todays_date
                         ) %>%
                         # Note: in case the "date of death" is unknown (the form has that option): let's just calculate the "latest date to do VA" by adding 40 days (Tanzania) and 30 days (Moz) to the "date of the hh visit", to be safe.
                         mutate(safe_bet = todays_date + mourning_period) %>%
                         mutate(xx = ifelse(is.na(xx), safe_bet, xx)) %>%
                         mutate(xx = as.Date(xx, origin = '1970-01-01')) %>%
                         mutate(yy = Sys.Date() - xx) %>% # "time elapsed" means time between lastest date to collect and today
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
                                       `HH ID` = hh_id,
                                       `FW ID` = wid,
                                       `HH visit date` = todays_date), by = 'instance_id') %>%
        mutate(`FW ID` = ' ') %>%
        dplyr::select(-instance_id)
      
      # Remove those which have already been done
      out <- out %>%
        filter(!`PERM ID` %in% va$death_id)
      
      if(nrow(out) > 0){
        out <- out %>% dplyr::select(District, Ward, Village, Hamlet,
                                     `HH ID`, `FW ID`, `PERM ID`,
                                     `HH visit date`, `Date of death`,
                                     `Latest date to collect VA form`,
                                     `Time elapsed`
        ) %>%
          arrange(desc(`HH visit date`))
        if(cn=='Mozambique'){
          out <- out %>%  rename(Distrito = District,
                                 `Posto administrativo/localidade`=Ward,
                                 Povoado=Village,
                                 Bairro=Hamlet)
        }
        out$`Time elapsed` <- NULL
        print(head(out))        
        message('---Created past due table for VA')
        out <- out %>% filter(`Latest date to collect VA form` <= Sys.Date())
        return(bohemia::prettify(out, nrows = nrow(out), download_options = TRUE))
      } 
    } else {
      return(NULL)
    }
  })
  output$ui_va_progress_past_due <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              DT::dataTableOutput('table_va_progress_past_due')
            })
  })
  # 
  
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
  
  # create an input for fw daily table
  output$ui_fw_time_period <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              pd <- odk_data$data
              pd <- pd$minicensus_main
              co <- country()
              # save(pd, file = '/tmp/pd.RData')
              pd <- pd %>% filter(hh_country == co)
              
              fluidPage(
                fluidRow(
                  column(6,
                         sliderInput(inputId = 'fw_time_period', 
                                     label = 'Previous days to include:', 
                                     min = min(pd$todays_date), 
                                     max=max(pd$todays_date), 
                                     value = c(min(pd$todays_date), max(pd$todays_date))))
                )
              ) 
            })
  })
  output$ui_fw_daily <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # Get the odk data
              pd <- odk_data$data
              an <- session_data$anomalies
              
              co <- country()
              # save(pd, co, an, file = '/tmp/pd.RData')
              enumerations <- pd$enumerations
              va <- pd$va
              pd <- pd$minicensus_main
              
              pd <- pd %>% filter(hh_country == co)
              
              min_date <- min(pd$todays_date, na.rm = TRUE)
              max_date <- max(pd$todays_date, na.rm = TRUE)
              seq_days <- seq(min_date, max_date, by = 1)
              seq_days <- seq_days[!weekdays(seq_days) %in% c('Saturday', 'Sunday')]
              n_days <- length(seq_days)
              # get anomaly dataset
              if(nrow(an) > 0){
                an$date <- as.Date(an$date, format = '%Y-%m-%d')
              }
              # save(an, pd, co, file='/tmp/temp_an.rda')
              
              pd_ok <- FALSE
              if(!is.null(pd)){
                if(nrow(pd) > 0){
                  pd_ok <- TRUE
                }
              }
              if(pd_ok){
                # join fids with pd to ge supervisor info
                # Get the fieldworkers for the country in question
                sub_fids <- fids %>% filter(country == co)
                pd <- left_join(pd %>%
                                  mutate(wid = as.character(wid)), 
                                sub_fids %>%
                                  mutate(bohemia_id = as.character(bohemia_id)),
                                by=c('wid'= 'bohemia_id')) 
                pd <- pd %>% filter(!is.na(country)) %>%
                  filter(country == co) %>%
                  mutate(end_time = lubridate::as_datetime(end_time),
                         start_time = lubridate::as_datetime(start_time)) %>%
                  mutate(time = end_time - start_time)
                
                if(co=='Mozambique'){
                  daily_forms_fw <- 10
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 500
                } else {
                  daily_forms_fw <- 13
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 599
                }
                
                time_period <- input$fw_time_period
                if(is.null(time_period)){
                  time_period <- c(min(pd$todays_date), max(pd$todays_date))
                } 
                time_range <- time_period
                an <- an %>% group_by(wid = as.character(wid)) %>% 
                  filter(date >= time_range[1],
                         date <=time_range[2]) %>%
                  summarise(num_errors = sum(type=='error'),
                            num_anomalies = sum(type == 'anomaly'))
                if(nrow(enumerations) > 0){
                  enumerations <- enumerations %>% 
                    filter(todays_date >= time_range[1],
                           todays_date <=time_range[2]) %>%
                    group_by(wid = as.character(wid)) %>%
                    summarise(num_enumerations = n())
                }
                if(nrow(va) > 0){
                  va <- va %>% 
                    filter(todays_date >= time_range[1],
                           todays_date <=time_range[2]) %>%
                    group_by(wid = as.character(wid)) %>%
                    summarise(num_va = n())
                }
                
                if(nrow(va) > 0){
                  pd <- left_join(pd %>% mutate(wid = as.character(wid)), va, by ='wid')
                } else {
                  pd <- pd %>% mutate(num_va = 0)
                }
                if(nrow(enumerations) > 0){
                  pd <- pd %>% left_join(enumerations, by ='wid')
                } else {
                  pd <- pd %>% mutate(num_enumerations = 0)
                }
                if(nrow(an) > 0){
                  pd <- pd %>% left_join(an, by ='wid')
                } else {
                  pd <- pd %>% mutate(
                    num_anomalies = 0,
                    num_errors = 0
                  )
                }
                 
                
                fwt_daily <- pd %>%
                  mutate(fw_name = paste0(first_name, ' ', last_name)) %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  filter(todays_date >= time_range[1],
                         todays_date <=time_range[2])%>%
                  group_by(`FW ID` = wid,
                           FW = fw_name,
                           `Supervisor` = supervisor) %>%
                  summarise(`Minicensus forms` = n(),
                            `Average time per minicensus form (minutes)` = round(mean(time, na.rm = TRUE), 1),
                            `% rolling target (minicensus)` = (`Minicensus forms` / n_days) / daily_forms_fw * 100,
                            `Enumeration forms` = sum(num_enumerations),
                            `VA forms` = sum(num_va),
                            `# of anomalies` = max(num_anomalies),
                            `# of errors` = max(num_errors)) 
                
              }
              fluidPage(
                div(bohemia::prettify(fwt_daily, nrows = nrow(fwt_daily),
                                  download_options = TRUE), style = "font-size:80%")
              ) 
            })
  })
  output$ui_fw_overall <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # Get the odk data
              pd <- odk_data$data
              co <- country()
              # save(pd, co, an, file = '/tmp/pd.RData')
              enumerations <- pd$enumerations
              va <- pd$va
              pd <- pd$minicensus_main
              
              pd <- pd %>% filter(hh_country == co)
              
              # save(pd, file = '/tmp/pd.RData')
              pd <- pd %>% filter(hh_country == co)
              
              # get anomaly dataset
              an <- session_data$anomalies %>%
                mutate(date = as.Date(date, format = '%Y-%m-%d'))
              pd_ok <- FALSE
              if(!is.null(pd)){
                if(nrow(pd) > 0){
                  pd_ok <- TRUE
                }
              }
              if(pd_ok){
                # join fids with pd to ge supervisor info
                # Get the fieldworkers for the country in question
                co <- country()
                sub_fids <- fids %>% filter(country == co)
                pd <- left_join(pd %>% mutate(wid = as.character(wid)), 
                                sub_fids %>% mutate(bohemia_id = as.character(bohemia_id)), by=c('wid'= 'bohemia_id')) %>%
                  filter(!is.na(country)) %>%
                  filter(country == co)
                # Create fieldworkers table
                pd$end_time <- lubridate::as_datetime(pd$end_time)
                pd$start_time <- lubridate::as_datetime(pd$start_time)
                pd$time <- pd$end_time - pd$start_time
                
                if(co=='Mozambique'){
                  daily_forms_fw <- 10
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 500
                } else {
                  daily_forms_fw <- 13
                  weekly_forms_fw <- daily_forms_fw*5
                  total_forms_fw <- 599
                }

                an <- an %>% group_by(wid = as.character(wid)) %>% summarise(num_errors = sum(type=='error'),
                                                         num_anomalies = sum(type == 'anomaly'))
                if(nrow(an) > 0){
                  pd <- pd %>% left_join(an, by ='wid')
                } else {
                  pd <- pd %>% mutate(
                    num_anomalies = 0,
                    num_errors = 0
                  )
                }
                if(nrow(enumerations) > 0){
                  enumerations <- enumerations %>% 
                    group_by(wid = as.character(wid)) %>%
                    summarise(num_enumerations = n())
                }
                if(nrow(va) > 0){
                  va <- va %>% 
                    group_by(wid = as.character(wid)) %>%
                    summarise(num_va = n())
                }
                if(nrow(va) > 0){
                  pd <- left_join(pd %>% mutate(wid = as.character(wid)), va, by ='wid')
                } else {
                  pd <- pd %>% mutate(num_va = 0)
                }
                if(nrow(enumerations) > 0){
                  pd <- pd %>% left_join(enumerations, by ='wid')
                } else {
                  pd <- pd %>% mutate(num_enumerations = 0)
                }
                fwt_overall <-  pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(fw_name = paste0(first_name, ' ', last_name)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  group_by(`FW ID` = wid,
                           `FW` = fw_name,
                           `Supervisor` = supervisor) %>%
                  summarise(`Minicensus forms` = n(),
                            `Average time per form (minutes)` = round(mean(time, na.rm = TRUE), 1),
                            `% complete total (minicensus)` = round(`Minicensus forms`/total_forms_fw * 100, digits = 2),
                            `Enumeration forms` = sum(num_enumerations),
                            `VA forms` = sum(num_va),
                            `# of anomalies` = max(num_anomalies),
                            `# of errors` = max(num_errors))
                fwt_overall$`# of errors`[is.na(fwt_overall$`# of errors`)] <- 0
                fwt_overall$`# of anomalies`[is.na(fwt_overall$`# of anomalies`)] <- 0
                
              }
              fluidPage(
                div(bohemia::prettify(fwt_overall, nrows = nrow(fwt_overall),
                                  download_options = TRUE), style = "font-size:80%")
              ) 
            })
  })
  
  
  # Leaflet of fieldworkers
  output$fid_leaf <- renderLeaflet({
    NULL
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
  
  # TRACCAR GPS UI
  output$traccar_plot_1 <- renderPlot({
    # ggplot() +
    #   theme_bohemia() +
    #   labs(title = 'Undergoing changes')
    # Get the traccar data for that country
    traccar <- session_data$traccar
    # Get the fortified shapefile
    shp_fortified <- bohemia::mop2_fortified
    geo <- input$geo
    if(geo == 'Rufiji'){
      shp_fortified <- bohemia::ruf2_fortified
    }
    ggplot() +
      geom_polygon(data = shp_fortified,
                   aes(x = long,
                       y = lat,
                       group = group),
                   fill = 'black') +
      # geom_path(aes(x = longitude,
      #               y = latitude,
      #               group = unique_id),
      #           color = 'red',
      #           size = 0.2,
      #           alpha = 0.5) +
      geom_point(data = traccar,
                 aes(x = longitude,
                     y = latitude),
                 color = 'red',
                 size = 0.2,
                 alpha = 0.5) +
      theme_bohemia()
  })
  output$traccar_leaf <- renderLeaflet({
    # leaflet() %>% addTiles()
    # Get the traccar data for that country
    traccar <- session_data$traccar
    the_worker <- input$fid
    if(!is.null(the_worker)){
      sub_traccar <- traccar %>% filter(unique_id == the_worker)
      pts = st_as_sf(data.frame(sub_traccar), coords = c("longitude", "latitude"), crs = 4326)
    }
    # Make the plot
    l <- leaflet() %>%
      addTiles()
    if(nrow(sub_traccar) > 0){
      l <- l %>%
        addGlPoints(data = pts,
                    fillColor = 'red',
                    # fillColor = pts$status,
                    popup = pts %>% dplyr::select(devicetime, valid),
                    group = "pts")
    }
    l
  })
  
  
  
  output$traccar_table <- DT::renderDataTable({
    # data.frame(a = 'Undergoing changes')
    out <- session_data$traccar %>%
      arrange(desc(devicetime)) %>%
      group_by(unique_id) %>%
      dplyr::distinct(unique_id, id, valid, devicetime, longitude, latitude)
    bohemia::prettify(out,
                      download_options = FALSE)
  })
  
  ### 401 errors, just commenting out for now
  # output$traccar_live_view <- renderUI({
  #   # See if the user is logged in and has access
  #   si <- session_info
  #   li <- si$logged_in
  #   ac <- TRUE
  #   # Generate the ui
  #   make_ui(li = li,
  #           ac = ac,
  #           ok = {
  #             if(grepl('brew', getwd())){
  #               fluidRow(h3('You are in dev mode. Not showing up here.'))
  #             } else {
  #               creds <- yaml::yaml.load_file('credentials/credentials.yaml')
  #               user = creds$traccar_read_only_user
  #               password = creds$traccar_read_only_pass
  #               rurl <- paste0('http://bohemia.fun/?token=', creds$traccar_read_only_token)
  #               r = GET(rurl,
  #                       authenticate(user = user,
  #                                    password = password, 
  #                                    type = 'basic'),
  #                       accept_json())
  #               rcontent <- content(r)
  #               
  #               tags$iframe(
  #                 height = 800, width = 1200,
  #                 seamless="seamless",
  #                 src = paste0('https://bohemia.fun/?token=', creds$traccar_read_only_token))
  #             }
  #             
  #           })})
  
  output$ui_gps <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              
              fluidPage(
                fluidRow(h1('GPS tracking')),
                # fluidRow(column(12, align = 'center',
                #                 h3('Live view'),
                #                 uiOutput('traccar_live_view'))),
                fluidRow(column(12, align = 'center',
                                h3('Map of locations visited, last 7 days'),
                                
                                plotOutput('traccar_plot_1'))),
                fluidRow((column(12, align = 'center',
                                 DT::dataTableOutput('traccar_table'))))
              )
              
            })
  })
  
  
  # Refusals and absences UI
  output$ui_refusals_and_absences <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- TRUE
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # Get the country
              co <- country()
              
              # # get refusals data
              rf = odk_data$data$refusals
              # save(rf, file = '/tmp/rf.RData')
              # Keep only the country in question
              rf <- rf %>% dplyr::filter(country == co)
              
              # Get agg
              rf_agg <- rf %>%
                mutate(free_text = reason_no_participate) %>%
                mutate(reason_no_participate = ifelse(reason_no_participate %in% 
                                                        c('SEM COMENTARIO',
                                                          'He didnt want to do it',
                                                          'Dont know',
                                                          'refused'),
                                                      'refused',
                                                      'not_present')) %>%
                group_by(district, ward, village, hamlet, hh_id, reason_no_participate, free_text) %>%
                summarise(n = n(),
                          date = max(as.Date(todays_date), na.rm = TRUE)) %>%
                ungroup
              
              out_rf <- rf_agg %>%
                filter(reason_no_participate == 'refused') %>%
                dplyr::select(district, ward, village, hamlet, hh_id,
                              `Refusal date` = date,
                              `Description` = free_text)
              
              out_ab <- rf_agg %>%
                filter(reason_no_participate == 'not_present',
                       reason_no_participate != 'refused')  %>%
                dplyr::select(district, ward, village, hamlet, hh_id,
                              `Visits` = n,
                              `Last visit` = date)
              
              tabsetPanel(
                tabPanel(title = 'Refusals',
                         fluidPage(
                           fluidRow(
                             bohemia::prettify(out_rf,
                                               nrows = nrow(out_rf),
                                               download_options = TRUE)
                           )
                         )),
                tabPanel(title = 'Absences',
                         fluidPage(
                           fluidRow(
                             bohemia::prettify(out_ab,
                                               nrows = nrow(out_ab),
                                               download_options = TRUE)
                           )
                         ))
              )
              
            })
  })
  
  # Observe the fix submission
  observeEvent(input$submit_fix,{
    sr <- input$anomalies_table_rows_selected
    action <- session_data$anomalies
    this_row <- action[sr,]
    # fids <- read.csv('/tmp/fids.csv')
    gg <- input$geo
    if(gg=='Mopeia'){
      co <- 'Mozambique'
    } else {
      co <- 'Tanzania'
    }
    
    fids <- fids %>% 
      filter(country==co)
    the_choices <- fids$bohemia_id
    names(the_choices) <- paste0(fids$bohemia_id, '. ',
                                 fids$first_name, ' ',
                                 fids$last_name)
    
    # Must be just one row
    just_one <- FALSE
    if(nrow(this_row) == 1){
      just_one <- TRUE
    }
    if(just_one){
      this_row <- tidyr::gather(this_row, key, value)
      showModal(
        modalDialog(
          title = 'Anomaly/error resolution',
          size = 'l',
          easyClose = TRUE,
          fade = TRUE,
          footer = modalButton('Go back'),
          fluidPage(
            fluidRow(h3('The problem:')),
            fluidRow(HTML(knitr::kable(this_row, format = 'html'))),
            fluidRow(h3('The response:')),
            fluidRow(textAreaInput('response_details', 'Response details:')),
            fluidRow(selectizeInput('fix_source', 'Resolved by', choices = the_choices,
                                    options = list(create=TRUE))),
            fluidRow(selectizeInput('fix_method', 'Method of resolution',
                                    choices = c('By going to HH', 'By phone', 'Self-resolved'),
                                    options = list(create = TRUE))),
            fluidRow(dateInput('resolution_date', 'Resolution date',
                               min = '2020-10-01',
                               max = Sys.Date())),
            fluidRow(column(12, align = 'center',
                            actionButton('send_fix',
                                         'Submit response')))
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
    response_details <- paste0(input$response_details)
    fix_source <- input$fix_source
    fix_method <- input$fix_method
    resolution_date <- input$resolution_date
    log_in_user <- input$log_in_user
    fix <-
      tibble(id = this_row$id,
             instance_id = this_row$instance_id,
             response_details = response_details,
             resolved_by = fix_source,
             resolution_method = fix_method,
             resolution_date = as.character(resolution_date),
             submitted_by = log_in_user,
             submitted_at = Sys.time())
    # CONNECT TO THE DATABASE AND ADD FIX
    message('Connecting to the database in order to add a fix to the corrections table')
    # save(fix, fix_source, fix_method, resolution_date, log_in_user, response_details, this_row, action, sr, file = '/tmp/sunday.RData')
    con <- get_db_connection(local = is_local)
    dbAppendTable(conn = con,
                  name = 'corrections',
                  value = fix)
    message('Done. now disconnecting from database')
    dbDisconnect(con)
    # AND THEN MAKE SURE TO UPDATE THE IN-SESSION STUFF
    # save(this_row, sr, action, fix, odk_data, resolution_details, file = '/tmp/this_row.RData')
    message('Now uploading the in-session data')
    old_corrections <- odk_data$data$corrections 
    new_correction <- fix
    new_corrections <- bind_rows(old_corrections, new_correction)
    odk_data$data$corrections  <- new_corrections
    # save(new_corrections, file = '/tmp/new_corrections.RData')
    
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
              
              # Get the country
              co <- input$geo
              co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
              
              # Get places visisted so far
              pd <- odk_data$data
              pd <- pd$minicensus_main
              
              # get enumerations and refusals data
              en = odk_data$data$enumerations
              rf = odk_data$data$refusals
              # save(pd, en, rf, file = 'saved.RData')
              # save(en, file = 'enum.rda')
              # save(pd, file = 'pd_en.rda')
              # save(rf, file = 'refs.rda')
              # save(co, pd, en, rf, file = 'joe.RData')
              
              # subset by country
              pd <- pd %>% dplyr::filter(hh_country == co) %>%
                group_by(hh_id) %>%
                summarise(num_mini = n(),
                          last_date_mini = max(todays_date, na.rm=TRUE),
                          loc = dplyr::first(hh_geo_location)) 
              rf <- rf %>% dplyr::filter(country == co) %>% 
                group_by(hh_id, reason_no_participate) %>%
                summarise(num_ref = n(),
                          last_date_ref = max(todays_date, na.rm=TRUE),
                          loc = dplyr::first(hh_geo_location)) 
              en <- en %>% dplyr::filter(country == co) %>% 
                group_by(agregado) %>%
                summarise(num_enum = n(),
                          last_date_enum = max(todays_date, na.rm=TRUE),
                          loc = dplyr::first(location_gps)) 
              
              # Extract locations
              pd_locs <- extract_ll(pd$loc)
              pd$lng_minicensus <- pd_locs$lng; pd$lat_minicensus <- pd_locs$lat; pd$loc <- NULL
              en_locs <- extract_ll(en$loc)
              en$lng_enumerations <- en_locs$lng; en$lat_enumerations <- en_locs$lat; en$loc <- NULL
              rf_locs <- extract_ll(rf$loc)
              rf$lng_refusals <- rf_locs$lng; rf$lat_refusals <- rf_locs$lat; rf$loc <- NULL
              
              # get list of all unique house ids
              all_hh_ids <- tibble(hh_id = sort(unique(c(pd$hh_id, rf$hh_id, en$agregado))))
              
              # join with rest of data
              dat <- left_join(all_hh_ids, pd)
              dat <- left_join(dat, en, by = c('hh_id'='agregado'))
              dat <- left_join(dat, rf)
              
              # See if there is any geocoding for many houses
              dat <- dat %>% mutate(any_geocode = !(is.na(lng_minicensus) &
                                                      is.na(lng_enumerations) &
                                                      is.na(lng_refusals))) %>%
                # See if there is a minicensus without enumeration
                mutate(minicensus_wo_enumeration = !is.na(last_date_enum) & is.na(last_date_mini)) %>%
                # See if there is enumeration without minicensus
                mutate(enumeration_wo_minicensus = is.na(last_date_enum) & !is.na(last_date_mini)) %>%
                # Get average time between enumeration and minicensus
                mutate(time_bw_enumeration_and_minicensus = as.numeric(last_date_mini - last_date_enum))
              
              # save(dat, file = '/tmp/dat.RData')
              # create summary stats off of dat
              
              sub_dat <- dat %>%
                summarise(`Minicensus forms collected` = sum(num_mini, na.rm = TRUE),
                          `Unique minicensus HH IDs` = length(which(!is.na(last_date_mini))),
                          `Enumeration forms collected` = sum(num_enum, na.rm = TRUE),
                          `Unique enumeration HH IDs` = length(which(!is.na(last_date_enum))),
                          `Refusals` = sum(num_ref[reason_no_participate %in% c('SEM COMENTARIO',
                                                                                'He didnt want to do it',
                                                                                'Dont know',
                                                                                'refused')], na.rm = TRUE),
                          `Unique households` = nrow(all_hh_ids),
                          `Households geocoded` = length(which(any_geocode)),
                          `Avg days between enumeration and minicensus` = mean(time_bw_enumeration_and_minicensus, na.rm = TRUE),
                          `Households enumerated but not minicensed` = length(which(enumeration_wo_minicensus))) %>%
                mutate(`%` = `Unique minicensus HH IDs` / `Unique enumeration HH IDs` * 100)
              message('---Created table for aggregated enrollment data')
              # save(dat, file = 'temp_dat.rda')
              sub_stats <- dat %>%
                summarise(`Minicensus response rate`= (length(which(!is.na(num_mini)))/nrow(dat))*100,
                          `# of enumeration refusals` = length(which(is.na(num_enum)&is.na(num_mini))),
                          `# of minicensus refusals`= length(which(!is.na(num_enum)&is.na(num_mini)&!is.na(num_ref))),
                          `# of hh ever absent` = sum(num_ref[reason_no_participate %in% c("Wasnt there",
                                                                                           'not_present' )], na.rm = TRUE),
                          `# of refusals due to 3 absences` = length(which(`# of hh ever absent`>3)),
                          `% refused` = (sum(`# of enumeration refusals`,`# of minicensus refusals`,`# of refusals due to 3 absences`)/nrow(dat))*100,
                          `# of households absent then present` = length(which(last_date_ref>last_date_mini)),
                          `% successful follow up`=(`# of households absent then present`/`# of hh ever absent`))
              # Get raw data table for display
              dat <- dat %>%
                mutate(lng = ifelse(is.na(lng_minicensus),
                                    ifelse(is.na(lng_enumerations),
                                           ifelse(is.na(lng_refusals),
                                                  NA,
                                                  lng_refusals),
                                           lng_enumerations),
                                    lng_minicensus)) %>%
                mutate(lat = ifelse(is.na(lat_minicensus),
                                    ifelse(is.na(lat_enumerations),
                                           ifelse(is.na(lat_refusals),
                                                  NA,
                                                  lat_refusals),
                                           lat_enumerations),
                                    lat_minicensus)) %>%
                mutate(status = ifelse(!is.na(last_date_ref),
                                       'Refused',
                                       ifelse(!is.na(last_date_mini),
                                              'Minicensed',
                                              ifelse(!is.na(last_date_enum),
                                                     'Enumerated',NA)))) %>%
                dplyr::select(hh_id, status, num_mini, last_date_mini,
                              num_enum, last_date_enum,
                              num_ref, last_date_ref, reason_no_participate,
                              lng, lat) 
              
              geo_dat <- dat %>%
                filter(!is.na(lng)) %>%
                filter(lng > 1,
                       lat < -1)
              
              pts = st_as_sf(data.frame(geo_dat), coords = c("lng", "lat"), crs = 4326)
              dat_leaf <- leaflet() %>%
                addProviderTiles(provider = providers$Esri.WorldImagery) %>%
                addGlPoints(data = pts,
                            # fillColor = 'red',
                            fillColor = pts$status,
                            popup = pts,
                            group = "pts") %>%
                addLegend("bottomright", 
                          colors =c("#FFFF00",  "#871F78", "#00FFFF"),
                          labels= c("Refused", "Enumerated","Minicensed"),
                          title= "Status",
                          opacity = 1)
              # setView(lng = 35.7, lat = 18, zoom = 4) %>%
              # addLayersControl(overlayGroups = "pts")
              # # Add markers
              # icon_enumerations <- makeAwesomeIcon(icon= 'flag', markerColor = 'blue', iconColor = 'black')
              # icon_refusals <- makeAwesomeIcon(icon = 'flag', markerColor = 'red', library='fa', iconColor = 'black')
              # icon_minicensus <- makeAwesomeIcon(icon = 'home', markerColor = 'green', library='ion')
              
              # ref_geo <- geo_dat %>% filter(status == 'Refused')
              # en_geo <- geo_dat %>% filter(status == 'Enumerated')
              # mc_geo <- geo_dat %>% filter(status == 'Minicensed')
              # 
              # if(nrow(ref_geo) > 0){
              #   pts = st_as_sf(data.frame(ref_geo), coords = c("lng", "lat"), crs = 4326)
              #   dat_leaf <- dat_leaf %>%
              #     addGlPoints(data = pts, fillColor = 'red', group = "pts")
              #     # addAwesomeMarkers(data = ref_geo,
              #     #                   label = ref_geo$hh_id,
              #     #                   labelOptions = labelOptions(noHide = TRUE),
              #     #                   icon = icon_refusals)
              # }
              # if(nrow(en_geo) > 0){
              #   pts2 = st_as_sf(data.frame(en_geo), coords = c("lng", "lat"), crs = 4326)
              #   dat_leaf <- dat_leaf %>%
              #     addGlPoints(data = pts2, fillColor = 'blue', group = "pts2") 
              #     # addAwesomeMarkers(data = en_geo,
              #     #                   label = en_geo$hh_id,
              #     #                   labelOptions = labelOptions(noHide = TRUE),
              #     #                   icon = icon_enumerations)
              # }
              # if(nrow(mc_geo) > 0){
              #   pts3 = st_as_sf(data.frame(mc_geo), coords = c("lng", "lat"), crs = 4326)
              #   dat_leaf <- dat_leaf %>%
              #     addGlPoints(data = pts, fillColor = 'green', group = "pts3") 
              #     # addAwesomeMarkers(data = mc_geo,
              #     #                   label = mc_geo$hh_id,
              #     #                   labelOptions = labelOptions(noHide = TRUE),
              #     #                   icon = icon_minicensus)
              # }
              # dat_leaf <- dat_leaf %>%
              #   addLayersControl(overlayGroups = "pts3")
              output$dat_leaf_output <- renderLeafgl({
                dat_leaf
              })
              message('---Created Enrollment map')
              
              
              fluidPage(
                fluidRow(
                  column(12, align = 'center',
                         h2('Aggregated enrollment data'),
                         p('The below table shows a summary of enrollment'),
                         prettify(sub_dat, download_options = TRUE),
                         h2('Enrollment stats'),
                         prettify(sub_stats, download_options = TRUE),
                         br(),
                         h2('Enrollment map'),
                         p('Under construction'),
                         leafglOutput('dat_leaf_output')#,
                         # h2('De-aggregated enrollment data'),
                         # p('The below table shows the status of each household'),
                         # prettify(dat, download_options = TRUE)
                  ),
                  
                  
                )
              )
              
              
            }
            
    )
  })
  
 
  # Done hamlets UI  ################################################
  output$done_hamlet_table <- DT::renderDataTable({
    sb <- input$sidebar
    liu <- input$log_in_user
    done_button <- input$mark_done
    the_authorized_users <- c("iirema@ihi.or.tz",
                              "eldo.elobolobo@manhica.net",
                              "joe@databrew.cc")
    if(liu %in% the_authorized_users){
      con <- get_db_connection(local = is_local)
      done_hamlets <- dbGetQuery(conn = con,
                              statement = paste0("SELECT * FROM done_hamlets"))
      dbDisconnect(con)
      bohemia::prettify(done_hamlets,
                        nrows = nrow(done_hamlets))
    } else {
      bohemia::prettify(data.frame(o = 'You are not authorized to mark hamlets as done.'))
    }
  })
  
  output$ui_done_hamlets <- renderUI({
    si <- session_info
    li <- si$logged_in
    ac <- 'server_status' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              
              liu <- input$log_in_user
              the_authorized_users <- c("iirema@ihi.or.tz",
                                        "eldo.elobolobo@manhica.net",
                                        "joe@databrew.cc")
              if(liu %in% the_authorized_users){
                ok_to_mark <- TRUE
              } else {
                ok_to_mark <- FALSE
              }
              if(ok_to_mark){
                mark_button <- actionButton('mark_done',
                                           'Mark as done')
              } else {
                mark_button <- actionButton('mark_done_fake',
                                            'Clicking here will do nothing')
              }
              
              pd <- odk_data$data
              the_country <- country()
              the_choices <- bohemia::locations$code
              the_choices <- sort(unique(the_choices))
              fluidPage(
                fluidRow(h3('Mark a hamlet as done')),
                fluidRow(
                  column(6,
                         selectInput('the_done_hamlet',
                                     'Hamlet',
                                     choices = the_choices)),
                  column(6,
                         DT::dataTableOutput('done_hamlet_table'))
                ),
                fluidRow(
                  mark_button
                )
                
              )
            })
  })
  observeEvent(input$mark_done, {
    the_hamlet <- input$the_done_hamlet
    liu <- input$log_in_user
    the_data <- tibble(code = the_hamlet,
                       done_by = liu,
                       done_at = Sys.time())
    con <- get_db_connection(local = is_local)
    done_hamlets <- dbAppendTable(conn = con,
                                        name = 'done_hamlets',
                                        value = the_data)
    dbDisconnect(con)
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
            ok = {
              pd <- odk_data$data
              an <- session_data$anomalies
              the_country <- country()
              # save(pd, file = '/tmp/tmp.RData')
              
              # for every date that has mulitple dates seperated by comma, split and create new row.
              an <- an %>% 
                mutate(date = strsplit(as.character(date), ",")) %>% 
                unnest(date) %>%
                group_by(date) %>% 
                summarise(`# of anomalies` = sum(type == 'error', na.rm=TRUE),
                          `# of errors` = sum(type == 'anomaly', na.rm=TRUE)) %>%
                gather(key=key, value=value, -date) %>%
                mutate(date = as.Date(date))
              a_and_e_plot <- ggplot(an, aes(date, value, fill=key)) +
                geom_bar(stat = 'identity', position = 'dodge') +
                scale_fill_manual(name = '', 
                                  values = c('black', 'grey')) +
                labs(x='Date', y='') +
                theme_bohemia()
              output$e_and_a_per_day <- renderPlot({a_and_e_plot})
              
              # create data to visualize number of active FW per day. active being submitted a form.
              pd_fw <- pd$minicensus_main %>% group_by(todays_date,wid) %>% summarise(counts=n()) %>%
                group_by(todays_date) %>% summarise(counts = n())
              fw_active_daily_plot<-  ggplot(pd_fw, aes(todays_date, counts)) + 
                geom_bar(stat = 'identity') +
                geom_label(aes(label=counts)) +
                labs(x = 'Date', 
                     y = 'Number of active FW') +
                theme_bohemia()
              
              output$active_fw_per_day <- renderPlot({fw_active_daily_plot})
              
              end_times <- pd$minicensus_main %>%
                group_by(date_time = lubridate::round_date(end_time, unit = 'hour'),
                         country = hh_country) %>%
                tally
              left <- expand.grid(date_time = seq(
                from=as.POSIXct(min(end_times$date_time)),
                to=as.POSIXct(max(end_times$date_time)),
                by="hour"
              ),
              country = c('Mozambique', 'Tanzania'))
              end_times <- left_join(left, end_times) %>% mutate(n = ifelse(is.na(n), 0, n))
              end_times_plot <- ggplot(data = end_times %>% filter(country == the_country),
                                       aes(x = date_time,
                                           y = n)) +
                facet_wrap(~country) +
                geom_area(alpha = 0.3, 
                          fill = 'darkred',
                          color = 'black') +
                theme_bohemia()
              output$end_times_plot <- renderPlot({end_times_plot})
              
              
              
              out_mc <- pd$minicensus_main %>%
                group_by(country = hh_country,
                         date = todays_date) %>%
                summarise(Forms = n())
              out_people <- pd$minicensus_people %>%
                left_join(pd$minicensus_main %>% dplyr::select(country = hh_country,
                                                               date = todays_date,
                                                               instance_id),
                          by = 'instance_id') %>%
                group_by(country,
                         date) %>%
                summarise(People = n())
              out_enumerations <- pd$enumerations %>%
                group_by(country, date = todays_date) %>%
                summarise(`Enumerations` = n())
              out_va <- pd$va %>%
                group_by(country = the_country,
                         date = todays_date) %>%
                summarise(`Va forms` = n())
              out_refusals <- pd$refusals %>%
                mutate(reason_no_participate = ifelse(reason_no_participate %in% 
                                                        c('SEM COMENTARIO',
                                                          'He didnt want to do it',
                                                          'Dont know'),
                                                      'refused',
                                                      'not_present')) %>%
                group_by(country,
                         date = todays_date) %>%
                summarise(Absences = length(which(reason_no_participate == 'not_present')),
                          Refusals = length(which(reason_no_participate == 'refused')))
              # Join all
              all_dates <- c(out_mc$date, out_people$date, out_enumerations$date, out_va$date, out_refusals$date)
              left <- expand.grid(date = seq(min(all_dates,na.rm = TRUE),
                                             max(all_dates, na.rm = TRUE),
                                             by = 1),
                                  country = c('Mozambique', 'Tanzania'))
              joined <-
                left %>% left_join(out_mc, by = c('country', 'date')) %>%
                left_join(out_people, by = c('country', 'date')) %>%
                left_join(out_enumerations, by = c('country', 'date')) %>%
                left_join(out_va, by = c('country', 'date')) %>%
                left_join(out_refusals, by = c('country', 'date')) %>%
                mutate(Forms = ifelse(is.na(Forms), 0, Forms),
                       People = ifelse(is.na(People), 0, People),
                       Enumerations = ifelse(is.na(Enumerations), 0, Enumerations),
                       `Va forms` = ifelse(is.na(`Va forms`), 0, `Va forms`),
                       Absences = ifelse(is.na(Absences), 0, Absences),
                       Refusals = ifelse(is.na(Refusals), 0, Refusals))
              joined <- joined %>% filter(country == the_country)
              
              
              fluidPage(
                fluidRow(
                  h3('Plot of form end times (minicensus)'),
                  plotOutput('end_times_plot'),
                ),
                fluidRow(
                  h3('Active FWs per day'),
                  plotOutput('active_fw_per_day')
                ),
                fluidRow(
                  h3('Errors and anomalies per day'),
                  plotOutput('e_and_a_per_day')
                ),
                fluidRow(
                  h3('Errors and Anomalies resolutions'),
                  column(6,
                         plotOutput('ea1')),
                  column(6,
                         plotOutput('ea2'))
                  
                ),
                fluidRow(
                  h3('Summary table'),
                  bohemia::prettify(joined,
                                    nrows = nrow(joined),
                                    download_options = TRUE)
                )
              ) 
            }
            
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
    verification_all <- input$verification_all
    if(!verification_all){
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
    }
    
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
              subs <- pd$minicensus_repeat_hh_sub
              pd <- pd$minicensus_main
              # Get the country
              co <- input$geo
              co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
              pd <- pd %>% dplyr::filter(hh_country == co)
              # save(pd, co, people, file = '/tmp/joe.RData')
              # Get hh head
              out <- pd %>%
                dplyr::mutate(num = as.character(hh_head_id)) %>%
                # get info on heads
                left_join(people %>% 
                            mutate(num = as.character(num)) %>%
                            mutate(person_name = paste0(first_name, '.', last_name, '.')),
                          by = c('instance_id', 'num')) %>%
                # get info on fieldworkers
                left_join(fids %>% 
                            mutate(wid_name = paste0(first_name, ' ', last_name)) %>%
                            dplyr::select(wid = bohemia_id, wid_name)) %>%
                # get info on hh head subs
                left_join(subs %>% filter(!is.na(hh_sub_id)) %>%  
                            mutate(hh_sub_id = as.character(hh_sub_id)) %>%
                            dplyr::distinct(instance_id, .keep_all = TRUE) %>%
                            dplyr::select(instance_id, hh_sub_id)) %>%
                left_join(people %>% 
                            mutate(hh_sub_id = as.character(num)) %>%
                            mutate(sub_id = permid) %>%
                            mutate(sub_name = paste0(first_name, '.', last_name, '.')) %>%
                            dplyr::select(instance_id, hh_sub_id, sub_name, sub_id),
                          by = c('instance_id', 'hh_sub_id')) %>%
                dplyr::select(
                  todays_date,
                  wid,
                  wid_name,
                  hh_hamlet,
                  hh_hamlet_code,
                  hh_id,
                  permid,
                  person_name,
                  sub_id,
                  sub_name) %>%
                mutate(icf_exists = 'Sim__ Não__',
                       reason_no_exists = '',
                       icf_correct = 'Sim__ Não__',
                       reason_no_correct = '',
                       error_resolved = 'Sim__ Não__',
                       verified_by = '') %>%
                # Hide names
                mutate(sub_name = ' ') %>%
                mutate(person_name = ' ')
              
              verification_all <- input$verification_all
              if(!verification_all){
                text_filter <- input$verification_text_filter
                if(!is.null(text_filter)){
                  out <- out %>%
                    dplyr::filter(wid %in% text_filter)
                }
              }
              
              date_filter <- input$verification_date_filter
              if(!is.null(date_filter)){
                out <- out %>%
                  dplyr::filter(
                    todays_date <= date_filter[2],
                    todays_date >= date_filter[1]
                  )
              }
              
              # Render QC stuf
              qc <- out %>%  
                dplyr::select(`Hamlet code` = hh_hamlet_code,
                              `Worker code` = wid,
                              `Household ID` = hh_id, 
                              `HH Head ID` = permid,
                              Date = todays_date)
              quality_control_list_reactive$data <- qc
              
              # get inputs for slider to control sample size
              min_value <- 1
              max_value <- nrow(qc)
              selected_value <- sample(min_value:max_value, 1)
              if(co == 'Mozambique'){
                # here
                names(out) <- c(
                  'Data de recolha de dados',
                  'ID inquiridor',
                  'Nome do inquiridor',
                  'Bairro',
                  'ID_Bairro',
                  'Agregado',
                  'ID_Chefe de agregado',
                  'Nome do Chefe de Agregado',
                  'ID_Chefe de Agregado Substituto',
                  'Nome do Chefe de Agregado Substituto',
                  'O Consentimento Informado(CI) existe?',
                  'Se não existe, verifique com o supervisor e escreva a data caso encontre o CI',
                  'CI preenchido correctamente?',
                  'Se não estiver preenchido correctramente, indicar o erro (ver tabela tipos de erros)',
                  'O erro foi resolvido?',
                  'Verificado por (iniciais da arquivista e data)')
                
              } else {
                out <- out %>%
                  mutate(icf_exists = 'Y__ N__',
                         icf_correct = 'Y__ N__',
                         error_resolved = 'Y__ N__')
                names(out) <- 
                  c(
                    'Data collection date',
                    'FW ID',
                    'FW name',
                    'Hamlet',
                    'Hamlet ID',
                    'HH',
                    'HH head ID',
                    'HH head name',
                    'HH head sub ID',
                    'HH head sub name',
                    'ICF exists?',
                    'If not, verify with supervisor and write date of retrieval',
                    'ICF correctly filled?',
                    'If not, indicate error',
                    'Error resolved?',
                    'Verified by (initials of archivist and date)')
                
                
              }
              message('---Created visit control sheet')
              
              
              consent_verification_list_reactive$data <- out
              fluidPage(
                fluidRow(
                  checkboxInput('workers_on_separate_pages',
                                'Print workers on separate pages?',
                                value = TRUE),
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
    # Get supervisor
    action <- action %>%
      left_join(fids %>% dplyr::mutate(fw_name = paste0(first_name, ' ', last_name))  %>%
                  mutate(wid = as.character(bohemia_id)) %>%
                  dplyr::select(wid, supervisor))
    action <- action %>% dplyr::rename(FW = wid)
    # Join with the already existing fixes and remove those for which a fix has already been submitted
    corrections <- odk_data$data$corrections
    fixes <- odk_data$data$fixes
    # odk_data <- odk_data$data
    # save(action, corrections, fixes, odk_data, file = '/tmp/this.RData')
    
    # Join tables together
    joined <- left_join(action,
                        corrections %>% dplyr::select(-instance_id))
    joined <- left_join(joined, fixes)
    
    joined$technical_date <- unlist(lapply(strsplit(as.character(joined$date), ','), function(x){x[length(x)]}))
    joined$days_ago <- Sys.Date() - as.Date(joined$technical_date)
    joined$technical_date <- NULL
    joined$resolution_submitted <- !is.na(joined$submitted_at)
    joined$fix_implemented <- !is.na(joined$done_by)
    # Reorder a bit
    joined <- joined %>% 
      dplyr::select(type, days_ago, country, FW, date, id, description, incident, instance_id, supervisor,
                    response_details,
                    resolved_by,
                    resolution_method,
                    submitted_by,
                    submitted_at,
                    done_by,
                    done_at,
                    resolution_submitted,
                    fix_implemented)
    hide_submitted <- input$hide_submitted
    if(!is.null(hide_submitted)){
      if(hide_submitted){
        joined <- joined %>% filter(!resolution_submitted) 
      }
    }
    bohemia::prettify(joined, 
                      download_options = TRUE,
                      nrows = nrow(joined)) %>%
      DT::formatStyle(
        'Type',
        backgroundColor = styleEqual(c('Error', 'Anomaly'),
                                     c('red', 'orange'))
      ) %>%
      DT::formatStyle(
        'Resolution submitted',
        backgroundColor = styleEqual(c(TRUE),
                                     c('#FFFACD')),
        target = 'row'
      ) %>%
      DT::formatStyle(
        'Fix implemented',
        backgroundColor = styleEqual(c(TRUE),
                                     c('#98FB98')),
        target = 'row'
      )
  },
  options = list(scrollX = TRUE))
  
  
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
      NULL
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
  
  # Errors and anomalies charts
  output$ea1 <- renderPlot({
    anomalies <- session_data$anomalies
    # # Get supervisor
    # anomalies <- anomalies %>%
    #   left_join(fids %>% dplyr::mutate(fw_name = paste0(first_name, ' ', last_name))  %>%
    #               mutate(wid = as.character(bohemia_id)) %>%
    #               dplyr::select(wid, supervisor))
    # anomalies <- anomalies %>% dplyr::rename(FW = wid)
    # Join with the already existing fixes and remove those for which a fix has already been submitted
    corrections <- odk_data$data$corrections
    fixes <- odk_data$data$fixes
    # save(anomalies, corrections, fixes, file = '/tmp/this.RData')
    
    joined <- left_join(anomalies,
                        corrections %>% dplyr::select(-instance_id))
    joined <- left_join(joined, fixes)
    
    pd <- joined %>%
      mutate(status = ifelse(!is.na(done_by), 'Done',
                             ifelse(!is.na(response_details), 'Response submitted',
                                    'Needs response'))) %>%
      group_by(category = status) %>%
      tally %>%
      ungroup %>%
      mutate(fraction = n/ sum(n)) %>%
      mutate(p = paste0(round(fraction * 100, digits = 1), '%')) %>%
      mutate(ymax = cumsum(fraction)) %>%
      mutate(ymin = c(0, head(ymax, n = -1))) %>%
      mutate(label_position = (ymax + ymin) / 2) %>%
      mutate(label = paste0(category, '\nN: ', n, ' (', p, ')'))
    
    cols <- c('darkgreen', grey(0.5),'darkorange')
    ggplot(data = pd, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=2, fill=category)) +
      geom_rect(alpha = 0.6) +
      ggrepel::geom_text_repel( x=5, aes(y=label_position, label=label, color = category), size=4) +
      coord_polar(theta="y") +
      xlim(c(-1, 4)) +
      theme_void() +
      # scale_fill_brewer(palette=4) +
      scale_fill_manual(name = '',
                        values = cols) +
      scale_color_manual(name = '',
                         values = cols) +
      theme(legend.position = "none") +
      labs(x = '',
           y = '',
           title = 'Anomalies/errors status')
  })
  output$ea2 <- renderPlot({
    anomalies <- session_data$anomalies
    # # Get supervisor
    # anomalies <- anomalies %>%
    #   left_join(fids %>% dplyr::mutate(fw_name = paste0(first_name, ' ', last_name))  %>%
    #               mutate(wid = as.character(bohemia_id)) %>%
    #               dplyr::select(wid, supervisor))
    # anomalies <- anomalies %>% dplyr::rename(FW = wid)
    # Join with the already existing fixes and remove those for which a fix has already been submitted
    corrections <- odk_data$data$corrections
    fixes <- odk_data$data$fixes
    
    joined <- left_join(anomalies,
                        corrections %>% dplyr::select(-instance_id))
    joined <- left_join(joined, fixes)
    
    pd <- joined %>%
      mutate(status = ifelse(!is.na(done_by), 'Done',
                             ifelse(!is.na(response_details), 'Response submitted',
                                    'Needs response'))) %>%
      mutate(week = lubridate::week(date)) %>%
      group_by(week) %>%
      mutate(week_label = paste0(min(date), '-\n', max(date))) %>%
      group_by(category = status, date = week_label) %>%
      tally %>%
      ungroup 
    cols <- c(grey(0.5),'darkorange', 'darkgreen')
    pd$category <- factor(pd$category,
                          levels = c('Needs response',
                                     'Response submitted',
                                     'Done'))
    ggplot(data = pd,
           aes(x = date,
               y = n,
               group = category,
               fill = category)) +
      geom_bar(stat = 'identity') +
      scale_fill_manual(name = '',
                        values = cols,
                        guide = guide_legend(reverse = TRUE)) +
      labs(x = 'Week of anomaly occurrence',
           y = 'Number of anomalies',
           title = 'Anomalies/errors and status over time') +
      theme_bohemia()
  })
  
  # Alert ui
  uploaded_data <- reactiveValues(data_text ='No data uploaded')
  
  observeEvent(input$upload_data, {
    if (is.null(input$upload_data)){
      NULL
    } else {
      ok <- TRUE
      inFile <- input$upload_data
      dat <- read.csv(inFile$datapath, check.names = FALSE)
      previous_corrections <- odk_data$data$corrections
      save(dat, previous_corrections, file='/tmp/temp_upload.rda')
      
      # create valid names 
      log_in_user <- input$log_in_user
      
      valid_names <- c("Instance id", "Id", "Response details", "Resolved by", "Resolution method")  
      
      # Check column names
      if(all(valid_names %in% names(dat))){
        ok_names <- TRUE
      } else {
        ok_names <- FALSE
        ok <- FALSE
        out_text <- paste0('ERROR! The following required columns are missing: ', paste0(valid_names[which(!valid_names %in% names(dat))], collapse = '; '), collapse = ' ')
      }

      # Check duplicates
      if(ok){
        any_duplicates <- any(duplicated(dat$Id))
        if(any_duplicates){
          ok <- FALSE
          out_text <- 'ERROR! Multiple entries per anomaly. No duplicated "Ids" allowed.'
        }
      }
      
      # Check to see if everything is complete
      if(ok){
        sub_dat <- dat[,valid_names]
        any_nas <- as.numeric(which(apply(sub_dat, 2, function(x){any(is.na(x))})))
        any_empties <- as.numeric(which(apply(sub_dat, 2, function(x){any(x == '')})))
        any_nas <- sort(unique(c(any_nas, any_empties)))
        if(length(any_nas) > 0){
          ok <- FALSE
          out_text <- paste0('ERROR! Empty values are not permitted. There are empty values in the following ', length(any_nas), ' columns. Fill out all cells in these columns and then re-upload: ', paste0(paste0(names(sub_dat)[any_nas], collapse = '; ')))
        }
      }
      
      # Check to see if anything has already been resolved
      if(ok){
        sub_dat <- dat[,valid_names]
        sub_dat$Id <- tolower(sub_dat$Id)
        already_ids <- previous_corrections$id
        already <- which(sub_dat$Id %in% already_ids)
        if(length(already) > 0){
          ok <- FALSE
          out_text <- paste0('ERROR! Column names are correct, but there are entries for anomalies which have ALREADY been correted. Please remove rows with the following', length(already),  ' IDs and then re-upload: ', paste0(paste0(sub_dat$Id[already], collapse = ', ')))
        }
      }
      if(ok){
        out_text <- 'Successfully uploaded corrections requests.'

        fix <- dat %>%
          mutate(id = tolower(Id),
                 instance_id = tolower(`Instance id`),
                 response_details = `Response details`,
                 resolved_by = `Resolved by`,
                 resolution_method = `Resolution method`,
                 resolution_date = as.character(Sys.Date()),
                 submitted_by = log_in_user,
                 submitted_at = Sys.time()) %>%
          dplyr::select(id, instance_id, response_details, resolved_by,
                        resolution_method, resolution_date, submitted_by, submitted_at)
        con <- get_db_connection(local = is_local)
        dbAppendTable(conn = con,
                      name = 'corrections',
                      value = fix)
        message('Done. now disconnecting from database')
        dbDisconnect(con)
        # AND THEN MAKE SURE TO UPDATE THE IN-SESSION STUFF
        message('Now uploading the in-session data')
        old_corrections <- odk_data$data$corrections 
        new_correction <- fix
        new_corrections <- bind_rows(old_corrections, new_correction)
        odk_data$data$corrections  <- new_corrections
      } 
      status_text <- ifelse(ok, 'SUCCESS!', 'ERROR!')
      uploaded_data$data_text <- out_text
      showModal(modalDialog(
        title = status_text,
        paste0(uploaded_data$data_text),
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  output$upload_data_message <- renderTable({
    this_text <- uploaded_data$data_text
    data_frame(' '=this_text)
  })
  # sh
  output$anomalies_ui_a <- renderUI({
    
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'malaria' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # fluidPage(
              #   h1('Temporarily down for maintenance'),
              #   add_busy_gif(src = "https://jeroen.github.io/images/banana.gif", 
              #                position = 'bottom-right',
              #                height = '100px',
              #                width = '100px',
              #                margins = c(350, 350))
              # )
              fluidPage(
                fluidRow(column(6,
                                p('Select a row and then click one of the below:')),
                         column(6,
                                actionButton('submit_fix',
                                             'Submit response',
                                             style='padding:=8px; font-size:120%'))),
                fluidRow(
                  column(12,
                         checkboxInput('hide_submitted', 
                                       'Hide rows for which a resolution has already been submitted?',
                                       value = FALSE))
                  
                  
                ))
            }
    )
  })
  
  
  output$anomalies_ui <- renderUI({
    
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'malaria' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              # fluidPage(
              #   h1('Temporarily down for maintenance'),
              #   add_busy_gif(src = "https://jeroen.github.io/images/banana.gif", 
              #                position = 'bottom-right',
              #                height = '100px',
              #                width = '100px',
              #                margins = c(350, 350))
              # )
              fluidPage(
                fluidRow(
                  box(width = 12,
                      # icon = icon('table'),
                      color = 'orange',
                      div(DT::dataTableOutput('anomalies_table'), style = "font-size:60%"))
                  
                ))
            }
    )
  })
  
  output$download_ui <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'malaria' %in% si$access
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                fluidRow(
                  column(6,
                         selectInput('which_download',
                                     'Pick a dataset',
                                     choices = c('Minicensus main',
                                                 'Minicensus enumerations',
                                                 'Minicensus refusals',
                                                 'Minicensus people roster',
                                                 'Minicensus death registry',
                                                 'Minicensus HH subs',
                                                 'Minicensus mosquito nets',
                                                 'Minicensus water',
                                                 'VA',
                                                 'Modifications'
                                     ))
                  ),
                  column(6,
                         downloadButton("download_dataset", "Download dataset")
                  )
                )
              )
            })
  })
  
  
  
  output$download_dataset <- downloadHandler(
    filename = function(){
      paste0(input$which_download, ".csv", sep = "")
    },
    content = function(file){
      
      which_download <- input$which_download
      
      if(which_download == 'Minicensus main'){
        df <- odk_data$data$minicensus_main
      } else if(which_download == 'Minicensus enumerations'){
        df <- odk_data$data$enumerations
      } else if(which_download == 'Minicensus refusals'){
        df <- odk_data$data$refusals
      } else if(which_download == 'Minicensus people roster'){
        df <- odk_data$data$minicensus_people
      } else if(which_download == 'Minicensus death registry'){
        df <- odk_data$data$minicensus_repeat_death_info
      } else if(which_download == 'Minicensus HH subs'){
        df <- odk_data$data$minicensus_repeat_hh_sub
      } else if(which_download == 'Minicensus mosquito nets'){
        df <- odk_data$data$minicensus_repeat_mosquito_net
      } else if(which_download == 'Minicensus water'){
        df <- odk_data$data$minicensus_repeat_water
      } else if(which_download == 'VA'){
        df <- odk_data$data$va
      } else if(which_download == 'Modifications'){
        df <- odk_data$data$fixes
      } 
      write.csv(df,
                file,
                row.names = FALSE)
    }
  )
  
  output$render_control_sheet <-
    downloadHandler(filename = "sheet.pdf",
                    content = function(file){
                      # Get whether logged in
                      si <- session_info
                      li <- si$logged_in
                      xdata <- session_data$va_table
                      
                      out_file <- paste0(getwd(), '/control_sheet.pdf')
                      rmarkdown::render(input = 
                                          paste0(system.file('rmd', package = 'bohemia'), '/control_sheet.Rmd'),
                                        # '../inst/rmd/control_sheet.Rmd',
                                        output_file = out_file,
                                        params = list(xdata = xdata,
                                                      li = li))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
  output$download_visit_control_data <- downloadHandler(
    filename = function(){
      paste0('visit_control_sheet', ".csv", sep = "")
    },
    content = function(file){
      si <- session_info
      
      li <- si$logged_in
      #Processing of visit control data
      lc <- location_code()
      # Get other details
      enumeration_or_minicensus <- input$enumeration_or_minicensus
      enum <- enumeration_or_minicensus == 'Enumeration visit'
      use_previous <- enumeration_or_minicensus == 'Data collection visit'
      xdata <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                          n_teams = as.numeric(as.character(input$enumeration_n_teams)),
                          id_limit_lwr = as.numeric(as.character(input$id_limit[1])),
                          id_limit_upr = as.numeric(as.character(input$id_limit[2])))
      enumerations_data = odk_data$data$enumerations
      minicensus_main_data <- odk_data$data$minicensus_main
      refusals_data = odk_data$data$refusals
      loc_id = lc
      enumeration = enum
      
      # save(li, lc, enumeration_or_minicensus, enum, use_previous, xdata, enumerations_data,
      #      minicensus_main_data, refusals_data,
      #      loc_id, enumeration, file = '/tmp/spreadsheet.RData')
      
      
      x <- bohemia::locations
      x <- x %>% filter(code %in% loc_id)
      if(nrow(x) > 0){
        loc_name <- paste0(x$Ward, ', ', x$Village, ', ', x$Hamlet)
      } else {
        loc_name <- ' '
      }
      include_name <- FALSE
      
      
      lc <- loc_id
      n_hh <- as.numeric(xdata$n_hh)
      if(is.na(n_hh)){
        n_hh <- 1000
      }
      n_teams <- as.numeric(xdata$n_teams)
      id_limit_lwr <- as.numeric(xdata$id_limit_lwr)
      id_limit_upr <- as.numeric(xdata$id_limit_upr)
      
      # Get country
      country <- 'Mozambique'
      if(lc[1] %in% locations$code[locations$Country == 'Tanzania']){
        country <- 'Tanzania'
      }
      
      id_vals <- 1:n_hh
      id_vals <- id_vals[id_vals %in% id_limit_lwr:id_limit_upr]
      n_hh <- length(id_vals)
      
      team_numbers <- rep(1:n_teams, each = round(n_hh / n_teams))
      while(length(team_numbers) < n_hh){
        team_numbers <- c(team_numbers, team_numbers[length(team_numbers)])
      }
      
      while(length(team_numbers) > n_hh){
        team_numbers <- team_numbers[1:n_hh]
      }
      
      
      if(country == 'Tanzania'){
        out_list <- list()
        for(lcx in 1:length(lc)){
          this_out <- tibble(`HHID` = paste0(lc[lcx], '-', bohemia::add_zero(id_vals, n = 3)),
                             team = team_numbers)
          out_list[[lcx]] <- this_out
        }
        out <-bind_rows(out_list)
        
        left <- locations %>% filter(code %in% lc) %>% dplyr::select(code, District, Ward, Village, Hamlet)
        out$code <- substr(out$`HHID`, 1, 3)
        out = left_join(out, left, by = 'code') %>% dplyr::select(-code)
      } else {
        out_list <- list()
        for(lcx in 1:length(lc)){
          this_out <- tibble(`Código do agregado` = paste0(lc[lcx], '-', bohemia::add_zero(id_vals, n = 3)),
                             team = team_numbers) %>%
            arrange(`Código do agregado`)
          out_list[[lcx]] <- this_out
        }
        out <-bind_rows(out_list)
      }
      
      if(li){
        if(country == 'Mozambique'){
          if(enumeration){
            # ENUMERATION
            df <- out %>% dplyr::mutate(`Nome de chefe de agregado` = ' ', `Localização do Numero de Agregado` = ' ', `Data de enumeração` = ' ')
          } else {
            # NON ENUMERATION
            # We use the previously enumerated data then and have to remove absences / etc
            refusals <- refusals_data %>%
              mutate(reason_no_participate = ifelse(reason_no_participate %in% c('SEM COMENTARIO',
                                                                                 'He didnt want to do it',
                                                                                 'Dont know'),
                                                    'refused',
                                                    'not_present')) %>%
              group_by(hh_id, reason_no_participate) %>%
              tally
            # Define those who should not be visited again
            remove_these <- refusals %>% filter(reason_no_participate == 'refused' | length(which(reason_no_participate == 'not_present')) >= 3) %>%
              .$hh_id
            # Define those which have already been mini-censed (and can therefore be removed)
            remove_these_mc <- minicensus_main_data$hh_id
            remove_these <- unique(c(remove_these, remove_these_mc))
            # Define those with previous absences
            previous_absences <- refusals %>%
              group_by(agregado = hh_id) %>%
              filter(length(which(reason_no_participate == 'refused')) == 0) %>%
              filter(reason_no_participate == 'not_present') %>%
              summarise(n = n())
            this_df <- enumerations_data %>% dplyr::filter(hamlet_code %in% lc) %>% dplyr::select(
              agregado, village, ward, hamlet, hamlet_code, localizacao_agregado, todays_date, chefe_name, wid, hamlet_code) %>%
              filter(!is.na(agregado)) %>%
              dplyr::distinct(agregado, .keep_all = TRUE) %>%
              left_join(previous_absences) %>%
              mutate(`Ausências anteriores` = ifelse(is.na(n), 0, n)) %>%
              dplyr::select(-n) %>%
              filter(!agregado %in% remove_these) %>%
              arrange(agregado)
            
            if(!is.null(df)){
              if(!include_name & nrow(this_df) > 0){
                this_df$chefe_name <- ' '
              }
            }
            
            # Add team numbers
            nr = nrow(this_df)
            if(nr > 0){
              team_vals <- sort(((1:nr) %% n_teams) + 1)
              this_df$team <- team_vals
              df <- this_df %>%
                dplyr::select(-team) %>% dplyr::select(`Data de enumeração` = todays_date, `ID agregado` = agregado, `Posto administrativo e Localidade` = ward, `Povoado` = village, `Bairro` = hamlet, `ID Bairro` = hamlet_code, `Nome de chefe de agregado` = chefe_name, `Ausências anteriores`) %>% dplyr::mutate(`Data da visita` = ' ') %>%  dplyr::mutate(`O chefe de agregado ou Chefe de agregado sustituto assino o consentimento informado?` = 'Sim__Não__', `Foi realizado o formulario?` = 'Sim__Não__',  `Se Não foi visitado ou entrevistado, explique o porque?` = ' ')
            } else{
              df <- data.frame(a = paste0('No previous enumerated households for ', lc))
            }
          }
        } else {
          # TANZANIA
          df <- out  %>% dplyr::mutate(`Status` = ' ', `Comments` = ' ')
        }
      } else {
        # Not logged in
        df <- data.frame(a = 'Log in first.')
      }
      write.csv(df,
                file,
                row.names = FALSE)
    }
  )
  
  output$render_visit_control_sheet <-
    downloadHandler(filename = "visit_control_sheet.pdf",
                    content = function(file){
                      # Get whether logged in
                      si <- session_info
                      li <- si$logged_in
                      # Get the location code
                      lc <- location_code()
                      # Get other details
                      enumeration_or_minicensus <- input$enumeration_or_minicensus
                      enum <- enumeration_or_minicensus == 'Enumeration visit'
                      use_previous <- enumeration_or_minicensus == 'Data collection visit'
                      xdata <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                          n_teams = as.numeric(as.character(input$enumeration_n_teams)),
                                          id_limit_lwr = as.numeric(as.character(input$id_limit[1])),
                                          id_limit_upr = as.numeric(as.character(input$id_limit[2])))
                      enumerations_data = odk_data$data$enumerations
                      minicensus_main_data <- odk_data$data$minicensus_main
                      refusals_data = odk_data$data$refusals
                      
                      # tmp <- list(data = data,
                      #             loc_id = lc,
                      #             enumeration = enum)
                      # save(tmp, file = '/tmp/tmp.RData')
                      out_file <- paste0(getwd(), '/visit_control_sheet.pdf')
                      rmarkdown::render(input = 
                                          paste0(system.file('rmd', package = 'bohemia'), '/visit_control_sheet.Rmd'),
                                        # '../inst/rmd/visit_control_sheet.Rmd',
                                        output_file = out_file,
                                        params = list(xdata = xdata,
                                                      loc_id = lc,
                                                      enumeration = enum,
                                                      use_previous = use_previous,
                                                      enumerations_data = enumerations_data,
                                                      refusals_data = refusals_data,
                                                      minicensus_main_data = minicensus_main_data,
                                                      li = li))
                      
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
                      # Get data
                      pd <- odk_data$data
                      pd <- pd$minicensus_main
                      pd <- pd %>% filter(hh_hamlet_code %in% lc)
                      
                      # Get country
                      # Get country
                      country <- 'Mozambique'
                      if(lc %in% locations$code[locations$Country == 'Tanzania']){
                        country <- 'Tanzania'
                      }
                      # save(pd, file = '/tmp/pd.RData')
                      
                      
                      out <- pd %>%
                        dplyr::select(
                          Ward = hh_ward,
                          Village = hh_village,
                          Hamlet = hh_hamlet,
                          `Hamlet code` = hh_hamlet_code,
                          `HH ID` = hh_id
                        ) %>%
                        mutate(Observations = '  ',
                               `Location of file` =  '   ') %>%
                        dplyr::arrange(`HH ID`)
                      
                      
                      if(country == 'Mozambique'){
                        names(out) <- c("Posto administrativo", "Localidade", "Bairro", "Código Bairro",
                                        "Número do Agregado Familiar",
                                        "Observações",
                                        "Localização da pasta de arquivo")
                      }
                      out_file <- paste0(getwd(), '/file_list.pdf')
                      rmarkdown::render(
                        input = paste0(system.file('rmd', package = 'bohemia'), '/file_list.Rmd'),
                        # input = '../inst/rmd/file_list.Rmd',
                        output_file = out_file,
                        params = list(xdata = out))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                    },
                    contentType = "application/pdf"
    )
  
  output$render_consent_verification_list <-
    downloadHandler(filename = "consent_verification_list.pdf",
                    content = function(file){
                      
                      # Get the data
                      pdx <- consent_verification_list_reactive$data
                      # Get page numbering system
                      
                      workers_on_separate_pages <- input$workers_on_separate_pages
                      # save(pdx, file = '/tmp/data.RData')
                      
                      # save(pdx, file = 'pdx_tab.rda')
                      out_file <- paste0(getwd(), '/consent_verification_list.pdf')
                      rmarkdown::render(
                        # input = '../inst/rmd/consent_verification_list.Rmd',
                        input = paste0(system.file('rmd', package = 'bohemia'), '/consent_verification_list.Rmd'),
                        output_file = out_file,
                        params = list(data = pdx,
                                      workers_on_separate_pages = workers_on_separate_pages))
                      
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
