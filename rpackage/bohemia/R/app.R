
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
                                                 # 'Both',
                                                 'Mozambique' = 'Mopeia'),
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
                     text="Visit control and file index",
                     tabName="visit_control_sheet",
                     icon=icon("users")),
                   menuSubItem(
                     text="Consent verification list",
                     tabName="consent_verification_list",
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
            uiOutput('ui_field_monitoring_by'),
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
              fluidRow(h2('Visit control and file index sheets')),
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
                       tabsetPanel(type = 'pills',
                                   tabPanel("Visit control sheet", 
                                            fluidPage(
                                              h3("Visit control sheet"),
                                              uiOutput('ui_enumeration_n_hh'),
                                              helpText('Err on the high side (ie, enter 20-30% more households than there likely are). It is better to have a list which is too long (and does not get finished) than to have a list which is too-short (and is exhausted prior to finishing enumeration). THE DEFAULT NUMBERS SHOWN ARE 25% HIGHER THAN THE NUMBER ESTIMATED BY THE VILLAGE LEADER.'),
                                              textInput('enumeration_n_teams',
                                                        'Number of teams',
                                                        value = 2),
                                              checkboxInput('enumeration', 'Enumeration?', value = FALSE),
                                              helpText('MOZ only. Tick this box if you want to generate a list for enumerators'),
                                              helpText('Usually, in order to avoid duplicated household IDs, there should just be one team. In the case of multiple teams, it is assumed that each team will enumerate a similar number of households.'),
                                              uiOutput('ui_id_limit'),
                                              br(), br(),
                                              downloadButton('render_enumeration_list',
                                                             'Generate visit control sheet(s)')
                                            )),
                                   tabPanel("File index locator",
                                            fluidPage(
                                              h3("File index"),
                                              uiOutput('ui_id_limit_file'),
                                              br(), br(),
                                              downloadButton('render_file_index_list',
                                                             'Generate file index and folder location list(s)')
                                            ))))
              )
            )
          ),
          tabItem(
            tabName="consent_verification_list",
            uiOutput('ui_consent_verification_list_a'),
            uiOutput('ui_consent_verification_list')),
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
  if(!'fids.csv' %in% dir('/tmp')){
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0'
    fids1 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name)
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130'
    fids2 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name)
    fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508'
    fids3 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name)
    fids <- bind_rows(fids1, fids2, fids3)
    readr::write_csv(fids, '/tmp/fids.csv')
  } else {
    fids <- readr::read_csv('/tmp/fids.csv')
  }
  
  default_fieldworkers <- fids %>%
    dplyr::rename(id = bohemia_id) %>%
    mutate(name = paste0(first_name, ' ', last_name)) %>%
    dplyr::select(id, name)

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
  session_info <- reactiveValues(logged_in = TRUE, # to change later
                                 user = 'default',
                                 access = c("field_monitoring", "enrollment", 'consent_verification_list', "server_status", "demography", "socioeconomics", "veterinary", "environment", "health", "malaria"),
                                 country = 'MOZ')
  
  # Create some reactive data
  session_data <- reactiveValues(aggregate_table = default_aggregate_table,
                                 action = default_action_table,
                                 fieldworkers = default_fieldworkers,
                                 notifications = default_notifications)
  
  odk_data <- reactiveValues(data = fake_data())
  
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
  
  ##################
  # LOCATION HIERARCHY UTILITIES
  ##################
  # Get the location code based on the input hierarchy
  location_code <- reactiveVal(value = NULL)
  country <- reactiveVal(value = 'Tanzania')
  observeEvent(input$geo, {
    gg <- input$geo
    if(gg == 'Rufiji'){
      country('Tanzania')
    } else {
      country('Mozambique')
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
    selectInput('region', 'Region', choices = choices)
  })
  
  output$district_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region)
    choices <- sort(unique(sub_locations$District))
    selectInput('district', 'District', choices = choices)
  })
  
  output$ward_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district)
    choices <- sort(unique(sub_locations$Ward))
    selectInput('ward', 'Ward', choices = choices)
  })
  
  output$village_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district,
                                      ward = input$ward)
    choices <- sort(unique(sub_locations$Village))
    selectInput('village', 'Village', choices = choices)
  })
  
  output$hamlet_ui <- renderUI({
    sub_locations <- filter_locations(locations = locations,
                                      country = input$country,
                                      region = input$region,
                                      district = input$district,
                                      ward = input$ward,
                                      village = input$village)
    choices <- sort(unique(sub_locations$Hamlet))
    selectInput('hamlet', 'Hamlet', choices = choices)
    
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
      ## JOE NEED TO DEBUG THIS
      num_houses <- gps %>% filter(code == lc) %>% .$n_households
      # # num_houses <- (mop_houses %>% filter(Hamlet %in% hamlet_name) %>% .$households)*1.25
      num_houses <- round(num_houses * 1.25)
    } else {
      num_houses <- 500
    }
    return(num_houses)
  })
  
  output$ui_enumeration_n_hh <- renderUI({
    val <- hamlet_num_hh()
    textInput('enumeration_n_hh',
              'Estimated number of households',
              value = val)
  })
  
  output$ui_id_limit <- renderUI({
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
  output$ui_field_monitoring_by <- renderUI({
    # See if the user is logged in and has access
    si <- session_info
    li <- si$logged_in
    ac <- 'field_monitoring' %in% si$access
    
    
    # Generate the ui
    make_ui(li = li,
            ac = ac,
            ok = {
              fluidPage(
                column(12, align = 'center',
                       radioButtons('field_monitor_by',
                                    'Geographic level:',
                                    choices = c('District',
                                                'Ward',
                                                'Village',
                                                'Hamlet'),
                                    inline = TRUE))
              )
            })
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
              pd <- pd$non_repeats
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
                x = as.character(fid_choices$name)
                y = as.character(fid_choices$id)
                fid_choices <- as.numeric(y)
                names(fid_choices) <- x
                # fid_choices <- c(x = y)

                # Some pre-processing
                dr <- as.Date(range(pd$todays_date, na.rm = TRUE))
                n_days = as.numeric(1 + (max(dr)-min(dr)))
                the_iso <- iso <- ifelse(co == 'Tanzania', 'TZA', 'MOZ')
                target <- sum(gps$n_households[gps$iso == iso], na.rm = TRUE)
                
                # Create table of overview
                overview <- pd %>%
                  summarise(`N. FWs` = ifelse(iso == 'TZA', 100, 77),  #length(unique(pd$wid)),
                            `Daily forms per FW` = round(nrow(pd) / `N. FWs` / n_days, digits = 1),
                            `Weekly forms per FW` = round(`Daily forms per FW` * 7, digits = 1),
                            `Total forms per FW` = round(nrow(pd) / `N. FWs`, digits = 1),
                            `Daily forms per country` = round(nrow(pd) / n_days, digits = 1),
                            `Weekly forms per country` = round(`Daily forms per country` * 7, digits = 1),
                            `Overall target per country` = target,
                            `Estimated weeks` = round(`Overall target per country` / `Weekly forms per country`, digits = 1)) %>%
                  mutate(`Estimated date` = (`Estimated weeks` * 7) + as.Date(dr[1]))
                # save(overview, file = '/tmp/overview.RData')
                
                
                # Create map
                ll <- extract_ll(pd$hh_geo_location)
                pd$lng <- ll$lng; pd$lat <- ll$lat
                l <- leaflet() %>% addTiles()
                if(!all(is.na(pd$lng))){
                  l <- l %>%
                    addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
                }
                
                
                # Create color-coded map
                # Get percent done by hamlet
                lxd <- pd %>% group_by(code = hh_hamlet_code) %>%
                  tally %>%
                  left_join(gps %>% dplyr::select(code, n_households)) %>%
                  mutate(p = n / n_households * 100)
                lxd <- left_join(gps %>% filter(iso == the_iso) %>% dplyr::select(code, lng, lat), lxd) %>%
                  mutate(p = ifelse(is.na(p), 0, p))
                pal <- colorNumeric(
                  palette = c("black","darkred", 'red', 'darkorange', 'blue'),
                  domain = 0:100
                )
                lx <- leaflet(data = lxd) %>% addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
                  addCircleMarkers(data = lxd, lng = ~lng, lat = ~lat, stroke=FALSE, color=~pal(p), fillOpacity = 0.6) %>%
                  addLegend(position = c("bottomleft"), pal = pal, values = lxd$p)
                
                # Create fieldworkers table
                pd$end_time <- lubridate::as_datetime(pd$end_time)
                pd$start_time <- lubridate::as_datetime(pd$start_time)
                pd$time <- pd$end_time - pd$start_time
                fwt <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  group_by(`FW ID` = wid) %>%
                  mutate(nd = as.numeric(max(todays_date, na.rm = TRUE) - min(todays_date, na.rm = TRUE) + 1)) %>%
                  ungroup %>%
                  group_by(`FW ID`) %>%
                  summarise(`Daily forms` = round(n() / dplyr::first(nd), digits = 1),
                            `Weekly forms` = round(`Daily forms` * 7, digits = 1),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')))
                fwt_daily <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  filter(end_time >= (Sys.time() - lubridate::hours(24))) %>%
                  group_by(`FW ID` = wid) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')),
                            `Time of last form end` = max(end_time, na.rm = TRUE))
                fwt_weekly <- pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  filter(end_time >= (Sys.time() - lubridate::hours(24*7))) %>%
                  group_by(`FW ID` = wid) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')),
                            `Time of last form end` = max(end_time, na.rm = TRUE))
                fwt_overall <-  pd %>%
                  mutate(todays_date = as.Date(todays_date)) %>%
                  mutate(end_time = lubridate::as_datetime(end_time)) %>%
                  group_by(`FW ID` = wid) %>%
                  summarise(`Forms` = n(),
                            `Average time per form` = paste0(round(mean(time, na.rm = TRUE), 1), ' ', attr(pd$time, 'units')),
                            `Time of last form end` = max(end_time, na.rm = TRUE),
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
                                `Estimated households` = n_households,
                                `Estimated percent finished` = p)
                
                
                # Create a progress by geo tables
                progress_by <- joined %>% left_join(locations %>% dplyr::select(code, District, Ward, Village, Hamlet))
                # save(progress_by, file = '/tmp/progress_by.RData')
                progress_by_district <- progress_by %>% group_by(District) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                         n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(District, `Forms done` = numerator,
                                `Estimated households` = n_households,
                                `Estimated percent finished` = p)
                progress_by_ward <- progress_by %>% group_by(Ward) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                 n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(Ward, `Forms done` = numerator,
                                `Estimated households` = n_households,
                                `Estimated percent finished` = p)
                progress_by_village <- progress_by %>% group_by(Village) %>% summarise(numerator = sum(numerator, na.rm  = TRUE),
                                                                                       n_households = sum(n_households, na.rm = TRUE)) %>%
                  mutate(p = round(numerator / n_households * 100, digits = 2)) %>%
                  dplyr::select(Village, `Forms done` = numerator,
                                `Estimated households` = n_households,
                                `Estimated percent finished` = p)
                by_geo <- input$field_monitor_by
                if(is.null(by_geo)){
                  monitor_by_table <- progress_by_district
                } else {
                  if(by_geo == 'District'){
                    monitor_by_table <- progress_by_district
                  } else if(by_geo == 'Ward'){
                    monitor_by_table <- progress_by_ward
                  } else if(by_geo == 'Village'){
                    monitor_by_table <- progress_by_village
                  } else if(by_geo == 'Hamlet'){
                    monitor_by_table <- progress_by_hamlet
                  }
                }
                
                
                
                # va table
                deaths <- odk_data$data$repeats$repeat_death_info
                deaths <- deaths %>% filter(instanceID %in% pd$instanceID)
                # save(deaths, pd, file = '/tmp/deaths.RData')
                va <- left_join(deaths %>% 
                                  mutate(xx = ' ', # this needs to be 7 days after hh visit date if death was <40 days prior to hh visit date | 40 days after hh visit date if the death was >40 days after hh visit date
                                         yy = ' ') %>%
                                  dplyr::select(instanceID,
                                                `Date of death` = death_dod,
                                                `Latest date to collect VA form` = xx,
                                                `Time elapsed` = yy),
                                pd %>% mutate(va_code = '(What is this?)') %>% 
                                  dplyr::select(instanceID,
                                                District = hh_district,
                                                Ward = hh_ward,
                                                Village = hh_village,
                                                Hamlet = hh_hamlet,
                                                `HH ID` = hh_hamlet_code,
                                                `FW ID` = wid,
                                                `PERM ID` = va_code,
                                                `HH visit date` = todays_date)) %>%
                  dplyr::select(-instanceID) 
                if(nrow(va) > 0){
                  va <- va[,c(4:11, 1:3)]
                  va2 <- tibble(`No data available` = ' ') # this will need to be updated later with location-level VA performance info # paula slide page 10
                  va3 <- tibble(`No data available` = ' ') # this will need to be updated later with VA fieldowrker performance: fw id, # va forms, # of va forms pending
                } else {
                  va2 <- tibble(`No data available` = ' ')
                  va3 <- tibble(`No data available` = ' ')
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
                           fluidPage(
                             h3('Progress by geography'),
                             fluidRow(
                               column(12, align = 'center',
                                      bohemia::prettify(monitor_by_table, nrows = nrow(monitor_by_table))
                               )
                             ),
                             h3('Estimated targets'),
                             gt(overview),
                             
                             fluidRow(
                               column(6,
                                      h3('Overall progress plot'),
                                      plotOutput('progress_plot')),
                               column(6,
                                      h3('Overall progress table'),
                                      gt(progress_table))
                             ),
                             fluidRow(
                               column(6, align = 'center',
                                      br(),
                                      h3('Map of forms'),
                                      l),
                               column(6, align = 'center',
                                      br(),
                                      h3('Map of completion % by hamlet'),
                                      lx)
                             )
                           )
                  ),
                  tabPanel('Performance',
                           fluidPage(
                             navbarPage(title = 'Performance',
                               tabPanel('Fieldworkers',
                                        fluidPage(
                                          # fluidRow(column(3, align = 'center',
                                          #                 selectInput('fid_select', 'Select fieldworker ID',
                                          #                             choices = fid_options))
                                          # ),
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
                                            fluidRow(
                                              column(4,
                                                     selectInput('fid',
                                                                 'Fieldworker',
                                                                 choices = fid_choices),
                                                     tableOutput('individual_details')),
                                              box(width = 8,
                                                  title = 'Location of forms submitted by this worker',
                                                  leafletOutput('fid_leaf'))
                                            ),
                                          navbarPage('Fieldworkers tables',
                                                     tabPanel('Daily',
                                                              DT::datatable(fwt_daily, rownames = FALSE)),
                                                     tabPanel('Weekly',
                                                              DT::datatable(fwt_weekly, rownames = FALSE)),
                                                     tabPanel('Overall',
                                                              DT::datatable(fwt_overall, rownames = FALSE))),
                                          fluidRow(
                                                   h3('Table of fieldworkers'),
                                                   DT::datatable(fwt, rownames = FALSE),
                                                   h5('Drop-outs'),
                                                   p('PENDING: need standardized definition of what a drop-out is.')
                                          ))),
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
                             br(), br(),
                             navbarPage(title = 'VA',
                                        tabPanel('List generation',
                                                 DT::datatable(va, rownames = FALSE)),
                                        tabPanel('Monitoring',
                                                 fluidPage(
                                                   DT::datatable(va2, rownames =FALSE),
                                                   h4('Map of VA forms submitted'),
                                                   leaflet() %>% addTiles()
                                                 )),
                                        tabPanel('Performance',
                                                 DT::datatable(va3, rownames =FALSE)))
                           )),
                  tabPanel('Alerts',
                           fluidPage(
                             br(),
                             h1('UNDER CONSTRUCTION'),
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
                             h1('UNDER CONSTRUCTION'),
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
                           h1('DEPRECATED'),
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
                             )))))
            })
  })
  
  # Leaflet of fieldworkers
  output$fid_leaf <- renderLeaflet({
    leaflet() %>% addProviderTiles(providers$Stamen.Toner)
  })
  observeEvent(input$fid, {
    fids <- input$fid
    if(is.null(fids)){
      fids <- 1:700
    }
    fids <- as.numeric(fids)
    # Get the aggregate table # (fake)
    aggregate_table <- session_data$aggregate_table
    
    # Get the odk data
    pd <- odk_data$data
    pd <- pd$non_repeats
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
      ll <- extract_ll(pd$hh_geo_location)
      pd$lng <- ll$lng; pd$lat <- ll$lat
      pd <- pd %>% filter(wid %in% fids)
      leafletProxy('fid_leaf') %>%
        clearMarkers() %>%
        addMarkers(data = pd, lng = pd$lng, lat = pd$lat)
    } else {
      leafletProxy('fid_leaf') %>%
        clearMarkers() 
    }
    
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
              pd <- pd$non_repeats
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
              
              # NO DETAILS YET FOR NON-PARTICIPANTS
              
              fluidPage(
                h3('Enrollment'),
                fluidRow(
                  column(12, align = 'center',
                         h4('Map of participating and non-participating households'),
                         l,
                         h4('Table of participating households'),
                         DT::datatable(pd, rownames = FALSE),
                         h4('Table of non-participating households'),
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
                column(4,
                       textInput('verification_text_filter',
                                 'Filter by FW code'),
                       dateRangeInput('verification_date_filter',
                                      'Filter by date',
                                      start = as.Date('2020-09-01'),
                                      end = Sys.Date()))
              )
            })})
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
              pd <- pd$non_repeats
              # Get the country
              co <- input$geo
              co <- ifelse(co == 'Rufiji', 'Tanzania', 'Mozambique')
              pd <- pd %>% dplyr::filter(hh_country == co)
              # Get hh head
              pd$hh_head_permid <- pd$hh_head_first_name <- pd$hh_head_last_name <- NA
              if(nrow(pd) > 0){
                for(i in 1:nrow(pd)){
                  this_row <- pd[i,]
                  id <- this_row$hh_head_id
                  good <- TRUE
                  if(is.null(id)){
                    good <- FALSE
                  } else
                    if(is.na(id)){
                      good <- FALSE
                    }
                  if(!good){
                    message('IMPORANT, MISSING ID FOR HH HEAD')
                    id <- 1
                  }
                  pd$hh_head_permid[i] <- this_row[,paste0('pid', id)] %>% unlist
                  pd$hh_head_first_name[i] <- this_row[,paste0('first_name', id)] %>% unlist
                  pd$hh_head_last_name[i] <- this_row[,paste0('last_name', id)] %>% unlist
                  
                }
                pd <- pd %>%
                  mutate(name = paste0(hh_head_first_name, ' ', hh_head_last_name)) %>%
                  mutate(age = round((Sys.Date() - as.Date(hh_head_dob))/365.25)) %>%
                  mutate(consent = 'HoH (minicensus)') %>%
                  mutate(x = ' ',y = ' ', z = ' ') %>%
                  dplyr::select(wid,
                                hh_hamlet_code,
                                hh_head_permid,
                                name,
                                age,
                                todays_date,
                                consent,
                                x,y,z)
                text_filter <- input$verification_text_filter
                if(!is.null(text_filter)){
                  pd <- pd %>% 
                    dplyr::filter(grepl(text_filter, wid))
                }
                date_filter <- input$verification_date_filter
                if(!is.null(date_filter)){
                  pd <- pd %>%
                    dplyr::filter(
                      todays_date <= date_filter[2],
                      todays_date >= date_filter[1]
                    )
                }
                if(co == 'Mozambique'){
                  names(pd) <- c('Código TC',
                                 'Código Bairro',
                                 # 'Número do Agregado Familiar',
                                 'ExtID (número de identificação do participante)',
                                 'Nome do membro do agregado',
                                 'Idade do membro do agregado',
                                 'Data de recrutamento',
                                 'Consentimento/Assentimento informado',
                                 'Se o documento não estiver preenchido correitamente, indicar o error',
                                 'O error foi resolvido (sim/não)',
                                 'Verificado por (iniciais do arquivista) e data')
                } else {
                  names(pd) <- c('FW code',
                                 'Hamlet code',
                                 # 'HH number',
                                 'ExtID HH member',
                                 'Name of household member',
                                 'Age of household member',
                                 'Recruitment date',
                                 'Informed consent/assent type (check off if correct and complete)',
                                 'If not correct, please enter type of error',
                                 'Was the error resolved (Yes/No)?',
                                 'Verified by (archivist initials) and date')
                }
                fluidPage(
                  gt(pd) %>%
                    tab_style(
                      style = cell_fill(
                        color = "#FFA500"
                      ),
                      locations = cells_body(names(pd)[1:7])
                    ))
              } else {
                fluidPage(
                  h3(paste0('No data available for location: ', input$geo, '.'))
                )
              }
            }
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
  
  output$individual_details <- 
    renderTable({
      
      # Get the odk data
      pd <- odk_data$data
      pd <- pd$non_repeats
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
        tibble(key = c('ID', 'Last upload', 'Total forms'),
               value = c(id, last_upload, total_forms))
      } else {
        NULL
      }
      
      
    })
  
  output$render_enumeration_list <-
    downloadHandler(filename = "list.pdf",
                    content = function(file){
                      
                      # Get the location code
                      lc <- location_code()
                      # Get other details
                      enum <- input$enumeration
                      data <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                         n_teams = as.numeric(as.character(input$enumeration_n_teams)),
                                         id_limit_lwr = as.numeric(as.character(input$id_limit[1])),
                                         id_limit_upr = as.numeric(as.character(input$id_limit[2])))
                      # generate html
                      # out_file <- paste0(system.file('shiny/operations/rmds', package = 'bohemia'), '/list.pdf')
                      out_file <- paste0(getwd(), '/list.pdf')
                      rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/list.Rmd'),
                                        output_file = out_file,
                                        params = list(data = data,
                                                      loc_id = lc,
                                                      enumeration = enum))
                      
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