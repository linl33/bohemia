library(shiny)
library(shinydashboard)
library(dplyr)
library(geosphere)
library(lubridate)
library(shinyjs)
source('global.R')



header <- dashboardHeader(title="Bohemia Operations Helper App")
sidebar <- dashboardSidebar(
  
  sidebarMenu(id = 'tabs',
              
              menuItem(
                text="Hamlet explorer",
                tabName="hamlet_explorer",
                icon=icon("home")),
              
              menuItem('Data collection',
                       tabName = 'data_collection',
                       icon = icon('database')),
              
              menuItem(
                text="Recon progress",
                tabName="recon_progress",
                icon=icon("chart-bar")),
              
              menuItem(
                text="Recon data",
                tabName="recon_data",
                icon=icon("chart-line")),
              
              menuItem(
                text="Clustering",
                tabName="clustering",
                icon=icon("android")),
              
              menuItem(
                text="Recon performance",
                tabName="recon_performance",
                icon=icon("thumbs-up")),
              
              menuItem(
                text="Animal data",
                tabName="animal_data",
                icon=icon("paw")),
              
              menuItem(
                text="Location codes",
                tabName="locations_tab",
                icon=icon("code")),
              
              menuItem(
                text="Satellite map",
                tabName="main",
                icon=icon("eye")),
              menuItem(
                text="QR code generator",
                tabName="qr",
                icon=icon("qrcode")),
              
              menuItem(
                text = 'About',
                tabName = 'about',
                icon = icon("cog", lib = "glyphicon"))
  )
)

body <- dashboardBody(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  tabItems(
    
    tabItem(
      tabName="hamlet_explorer",
      fluidPage(
        fluidRow(column(3,
                        radioButtons('country', 'Country', choices = c('Tanzania', 'Mozambique'), inline = TRUE, selected = 'Mozambique'), 
                        uiOutput('region_ui'),
                        uiOutput('district_ui'),
                        uiOutput('ward_ui'),
                        uiOutput('village_ui'),
                        uiOutput('hamlet_ui'),
                        h4('Location code:'),
                        textOutput('location_code_text')),
                 column(6,
                        h3('Map'),
                        leafletOutput('ll')),
                 column(3,
                        h3('Utilities'),
                             checkboxInput('hf_ll',
                                           'Show health posts',
                                           value = FALSE),
                             checkboxInput('borders_ll',
                                           'Show district borders',
                                           value = FALSE),
                        checkboxInput('hamlet_borders_ll',
                                      'Show bairro/ward borders',
                                      value = FALSE),
                        checkboxInput('this_hamlet',
                                      'Highlight this bairro/ward',
                                      value = FALSE),
                        br(), br(),
                        actionButton('print_enumeration',
                                     'Print enumeration lists',
                                     icon = icon('print')),
                        br(), br(),
                        actionButton('print_qrs',
                                     'Print worker QR codes',
                                     icon = icon('print')),
                        br(), br(),
                        actionButton('print_report',
                                     'Print hamlet report',
                                     icon = icon('print')),
                        br(), br(),
                        actionButton('print_directions',
                                     'Print travel directions',
                                     icon = icon('print'))
                 )),
        fluidRow(column(6,
                        h3('Hamlet quantitative data'),
                        DT::dataTableOutput('quant_table')),
                 column(6,
                        h3('Hamlet qualitative data'),
                        DT::dataTableOutput('qualy_table')))
      )
    ),
    
    tabItem(
      tabName = 'data_collection',
      fluidPage(
        fluidRow(h2('Data collection')),
        fluidRow(column(12, align = 'center',
                        selectInput('data_collection_picker',
                                    'How to view data',
                                    choices = c('Raw',
                                                'By country')),
                        h3('Overall:'),
                        DT::dataTableOutput('data_collection_table'),
                        h3('Hamlets without geocoding:'),
                        DT::dataTableOutput('data_collection_need_geocoding_table'),
                        h3('Hamlets without recon:'),
                        DT::dataTableOutput('data_collection_need_recon_table'),
                        h3('Hamlets without animal annex:'),
                        DT::dataTableOutput('data_collection_need_animal_table'),
                        h3('Hamlets with potentially contradictory geocoding'),
                        helpText('The below table shows hamlets that have geocoding from both Recon and animal annex. It is ordered, descending, by the distance (in meters) between the points. Distances of >500 meters should be considered suspect for error.'),
                        DT::dataTableOutput('data_collection_contradictory_table')
                        ))
      )
    ),
    
    
    tabItem(
      tabName = 'recon_progress',
      fluidPage(h2('Recon progress'),
                fluidRow(
                  column(4,
                         selectInput('recon_level',
                                     'Geography level',
                                     choices = c('Country','Region','District','Ward','Village'))),
                  column(8,
                         plotOutput('recon_plot'))
                ),
                fluidRow(
                  column(12,
                         h3('Pending forms by country'),
                         DT::dataTableOutput('recon_table_1'))),
                fluidRow(column(12,
                         h3('Pending forms by district'),
                         DT::dataTableOutput('recon_table_2'))
                ),
                fluidRow(
                  column(12,
                         h3('Pending forms by village'),
                         DT::dataTableOutput('recon_table_3'))),
                  fluidRow(column(12,
                         h3('All hamlets with form status'),
                         DT::dataTableOutput('recon_table_4'))
                ))
    ),
    
    tabItem(
      tabName = 'recon_data',
      fluidPage(
        DT::dataTableOutput('recon_data_table'),
        leafletOutput('recon_data_map')
      )
    ),
    
    tabItem(
      tabName = 'clustering',
      fluidPage(
        fluidRow(column(4, align = 'center',
                        actionButton('action_cluster', 'Generate clusters!'),
                        selectInput('clustering_country', 'Country',
                                    choices = c('Tanzania')),
                        checkboxInput('include_clinical', 'Include clinical', value = TRUE),
                        checkboxInput('interpolate_animals', 'Guess number of animals if missing', value = TRUE),
                        checkboxInput('interpolate_humans', 'Guess number of households/humans if missing', value = TRUE),
                        sliderInput('p_children', 'Percentage of people which are children',
                                    min = 0, max = 100,
                                    value = 30, step = 5),
                        sliderInput('minimum_children', 'Minimum number of children per cluster',
                                    min = 0, max = 100,
                                    value = 0, step = 5),
                        sliderInput('minimum_humans', 'Minimum number of humans per cluster',
                                    min = 0, max = 100,
                                    value = 0, step = 5),
                        sliderInput('minimum_animals', 'Minimum number of animals per cluster',
                                    min = 0, max = 100,
                                    value = 30, step = 5),
                        
                        sliderInput('minimum_cattle', 'Minimum number of cattle per cluster',
                                    min = 0, max = 100,
                                    value = 0, step = 5),
                        sliderInput('minimum_pigs', 'Minimum number of pigs per cluster',
                                    min = 0, max = 100,
                                    value = 0, step = 5),
                        sliderInput('minimum_goats', 'Minimum number of goats per cluster',
                                    min = 0, max = 100,
                                    value = 0, step = 5)),
                 column(8,
                        textOutput('cluster_summary_text'),
                        leafletOutput('cluster_map'),
                        verbatimTextOutput("text")))
      )
    ),
    
    tabItem(
      tabName = 'recon_performance',
      fluidPage(
        textInput('password', 'Password', value = ''),
        DT::dataTableOutput('recon_performance_table')
      )
    ),
    
    tabItem(
      tabName = 'animal_data',
      fluidPage(
        fluidRow(
          h2('Animal annex')
        ),
        fluidRow(
          column(6,
                 h3('Mozambique'),
                 textOutput('animal_text_mz'),
                 plotOutput('animal_plot_mz'),
                 leafletOutput('animal_map_mz'),
                 DT::dataTableOutput('animal_table_mz')),
          column(6,
                 h3('Tanzania'),
                 textOutput('animal_text_tz'),
                 plotOutput('animal_plot_tz'),
                 leafletOutput('animal_map_tz'),
                 DT::dataTableOutput('animal_table_tz'))
        )
        
      )
    ),

    tabItem(
      tabName = 'locations_tab',
      fluidPage(
        fluidRow(column(3,
                        textInput('search', 'Search (for a village, ward, localidade, code, etc.)',
                                  placeholder = 'For example: 4 de julho, posto campo, etc.'),
                        helpText('Click below to download the locations hierarchy with associated codes'),
                        downloadButton('download_locations', 
                                       'Download')),
                 column(9,
                        DT::dataTableOutput('locations_table')))
      )
    ),
    
    tabItem(
      tabName="main",
      fluidPage(
        column(3,
               selectInput('location',
                           'Location',
                           choices = c('Mopeia',
                                       'Rufiji')),
               checkboxInput('hf',
                             'Show health posts',
                             value = TRUE),
               checkboxInput('borders',
                             'Show borders',
                             value = TRUE),
               checkboxInput('extras',
                             'Show extras',
                             value = FALSE),
               helpText(textOutput('ht'))),
        column(9,
               leafletOutput('l'))
        
      )
    ),
    tabItem(
      tabName = 'qr',
      fluidPage(
        fluidRow(
          column(4,
                 textInput('qr_text', 'Enter number/code here (> 2 characters)')),
          column(8,
                 uiOutput('qr_ui'),
                 plotOutput('qr_plot'))
        )
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        fluidRow(
          div(img(src='logo_clear.png', align = "center"), style="text-align: center;"),
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
server <- function(input, output) {
  
  output$download_locations <- downloadHandler(
    filename = function() {
      paste("locations-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      data <- locations
      write.csv(data, file)
    }
  )
  
  filtered_locations <- reactive({
    ok <- FALSE
    search <- input$search
    locations %>%
      mutate(combined = paste0(Country, Region, District, Ward, Village, Hamlet, collapse = NULL)) %>%
      filter(grepl(tolower(search), tolower(combined), fixed = TRUE)) %>%
      dplyr::select(-combined)
  })
  
  output$qr_plot <- renderPlot({
    qrt <- input$qr_text
    if(!is.null(qrt)){
      if(nchar(qrt) > 2){
        create_qr(qrt)
      } else {
        NULL
      }
    }
    
  })
  
  output$qr_ui <- renderUI({
    qrt <- input$qr_text
    if(!is.null(qrt)){
      if(nchar(qrt) > 2){
        h3(qrt)
      } else {
        p('Enter > 2 characters in the box to the left.')
      }
    }
  })
  
  output$recon_data_table <- DT::renderDataTable({
    out <- recon_data %>%
      mutate(Geocoded = ifelse(geo_coded, 'Yes', 'No')) %>%
      dplyr::select(Country, Ward, Village, Hamlet,
                    Households = number_hh,
                    Geocoded)
    out
  })
  
  output$recon_data_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.Terrain) %>%
      addMarkers(data = recon_data,
                 popup = paste0(recon_data$Hamlet))
  })
  
  output$recon_performance_table <- DT::renderDataTable({
    out <- recon_data %>%
      left_join(fids %>% dplyr::rename(wid = bohemia_id)) %>%
      group_by(wid) %>%
      summarise(Forms = n(),
                `Median minutes` = median(as.double(as_datetime(end_time) - as_datetime(start_time), units = 'mins')),
                name = dplyr::first(paste0(first_name, ' ', last_name)),
                       phone = dplyr::first(phone))
    ok <- input$password == 'b0h3mI@'
    if(!ok){
      out$name <- out$phone <-  'Hidden'
    }
    databrew::prettify(out, nrows = nrow(out), download_options = TRUE)
    })
  
  output$locations_table <- DT::renderDataTable({
    fl <- filtered_locations()
    DT::datatable(fl, 
                  extensions = 'Select', 
                  selection = list(target = "cell"),
                  options = list(dom = 't',
                                 pageLength = nrow(fl)), 
                  rownames = FALSE)
  })
  
  output$recon_plot <- renderPlot({
    input_levels <- rev(c('Hamlet', 'Village', 'Ward', 'District', 'Region', 'Country'))
    # Get input level
    input_level <- input$recon_level
    if(is.null(input_level)){
      input_level <- 'Country'
    }
    this_index <- which(input_levels == input_level)
    these_groupers <- input_levels[1:this_index]
    pd <- recon_data %>%
      group_by_at(these_groupers) %>%
      tally
    xvar <- names(pd)[ncol(pd)-1]
    pd$xvar <- as.character(unlist(pd[,xvar]))
    ggplot(data = pd,
           aes(x = xvar,
               y = n)) +
      geom_point() +
      labs(x = input_level,
           y = 'Forms submitted') +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 90,
                                       hjust = 0.5,
                                       vjust = 1)) 
  })
  
  output$recon_table_1 <- DT::renderDataTable({
    right <- locations %>% group_by(Country) %>% summarise(Total = n())
    
    out <- recon_data %>% group_by(Country) %>%
      summarise(Done = n()) %>% left_join(right) %>%
      mutate(`Percent finished` = round(Done / Total * 100, digits = 2))
    databrew::prettify(out, 
                       nrows = nrow(out),
                       download_options = T)
  })
  
  output$recon_table_2 <- DT::renderDataTable({
    x <- locations %>% group_by(Country, District) %>% summarise(Total = n())
    y <- recon_data %>% group_by(Country, District) %>%
      summarise(Done = n()) 
    out <- x %>% left_join(y) %>%
      mutate(Done = ifelse(is.na(Done), 0, Done)) %>%
      mutate(`Status` = ifelse(Done >= Total, 'Done', 'Not done')) %>% 
      dplyr::select(Status, District, Country, Done, Total) 
    databrew::prettify(out, 
                       nrows = nrow(out),
                       download_options = T)
    
  })
  
  output$recon_table_3 <- DT::renderDataTable({
    x <- locations %>% group_by(Country, District, Village) %>% summarise(Total = n())
    y <- recon_data %>% group_by(Country, District, Village) %>%
      summarise(Done = n()) 
    out <- x %>% left_join(y) %>%
      mutate(Done = ifelse(is.na(Done), 0, Done)) %>%
      mutate(`Status` = ifelse(Done >= Total, 'Done', 'Not done')) %>% 
      dplyr::select(Status,  Village, District, Country, Done, Total) 
    databrew::prettify(out, 
                       nrows = nrow(out),
                       download_options = T)    
  })
  
  output$recon_table_4 <- DT::renderDataTable({
    x <- locations %>% group_by(Country, District, Village, Hamlet) %>% summarise(Total = n())
    y <- recon_data %>% group_by(Country, District, Village, Hamlet) %>%
      summarise(Done = n()) 
    out <- x %>% left_join(y) %>%
      mutate(Done = ifelse(is.na(Done), 0, Done)) %>%
      mutate(`Status` = ifelse(Done >= Total, 'Done', 'Not done')) %>% 
      dplyr::select(-Done, -Total) %>%
      dplyr::select(Status, Hamlet, Village, District, Country)
    databrew::prettify(out, 
                       nrows = nrow(out),
                       download_options = T)    
  })
  
  # Get the location code based on the input hierarchy
  location_code <- reactiveVal(value = NULL)
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
  
  output$locations_table <- DT::renderDataTable({
    fl <- filtered_locations()
    DT::datatable(fl, 
                  extensions = 'Select', 
                  selection = list(target = "cell"),
                  options = list(dom = 't',
                                     pageLength = nrow(fl)), 
                  rownames = FALSE)
  })
  
  location <- reactiveValues(data = data.frame())
 
  
  output$ll <- renderLeaflet({
    location <- input$country
    if(location == 'Tanzania'){
      district_borders <- rufiji2
      hf <- rufiji_health_facilities
    } else {
      district_borders <- mopeia2
      hf <- mopeia_health_facilities
    }
    
    # Start map
    out <- leaflet()  %>%
      addProviderTiles(providers$Esri.WorldStreetMap,
                       group = 'ESRI WSM', options = providerTileOptions(zIndex = 2)) %>%
      addFullscreenControl() %>%
      addPolylines(data = district_borders, weight = 0) %>%
      addControlGPS(options = gpsOptions(position = "topleft", activate = TRUE, 
                                              autoCenter = TRUE, maxZoom = 10, 
                                              setView = TRUE))
    activateGPS(out)
    

    
    mydrawPolylineOptions <- 
      function(allowIntersection = TRUE, 
               drawError = list(color = "#b00b00", timeout = 2500), 
               guidelineDistance = 20, 
               metric = TRUE, 
               feet = FALSE, 
               zIndexOffset = 2000, 
               shapeOptions = drawShapeOptions(fill = FALSE), 
               repeatMode = FALSE) {
        leaflet::filterNULL(list(allowIntersection = allowIntersection, 
                                 drawError = drawError, 
                                 uidelineDistance = guidelineDistance, 
                                 metric = metric, 
                                 feet = feet, 
                                 zIndexOffset = zIndexOffset,
                                 shapeOptions = shapeOptions,  
                                 repeatMode = repeatMode)) }
    
    out <- out %>% 
      # addProviderTiles(providers$OpenTopoMap)  %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       group = 'Satellite', options = providerTileOptions(zIndex = 3)) %>%
      addProviderTiles(providers$OpenStreetMap,
                       group = 'OSM', options = providerTileOptions(zIndex = 1000)
      ) %>%
      addProviderTiles(providers$Hydda.RoadsAndLabels, group = 'Places and names', options = providerTileOptions(zIndex = 10000)) %>%
      
      addDrawToolbar(
        polylineOptions = mydrawPolylineOptions(metric=TRUE, feet=FALSE),
        editOptions=editToolbarOptions(edit = FALSE,
                                       remove = TRUE,
                                       selectedPathOptions=selectedPathOptions()),
        polygonOptions = FALSE,
        circleOptions = FALSE,
        rectangleOptions = FALSE,
        markerOptions = FALSE,
        circleMarkerOptions = FALSE) %>%
      addResetMapButton() %>%
      
      addLayersControl(
        baseGroups = c('ESRI WSM', 
                       'Satellite',
                       'OSM'),
        overlayGroups = c(
          'Places and names'
        ),
        position = 'bottomright') %>%
      addScaleBar(position = 'topright') %>%
      # addMiniMap(
      #   tiles = providers$Esri.WorldStreetMap,
      #   toggleDisplay = TRUE) %>%
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
    
  })
  
  output$l <- renderLeaflet({
    location <- input$location
    if(location == 'Rufiji'){
      district_borders <- rufiji2
      hf <- rufiji_health_facilities
    } else {
      district_borders <- mopeia2
      hf <- mopeia_health_facilities
    }
    out <- leaflet()  %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       group = 'Satellite', options = providerTileOptions(zIndex = 3)) %>%
      addPolylines(data = district_borders, weight = 0) %>%
      addFullscreenControl() %>%
      addControlGPS(options = gpsOptions(position = "topleft", activate = TRUE, 
                                         autoCenter = TRUE, maxZoom = 10, 
                                         setView = TRUE))
    activateGPS(out)
    
    extras <- input$extras
    if(!is.null(extras)){
      if(extras){
        mydrawPolylineOptions <- 
          function(allowIntersection = TRUE, 
                   drawError = list(color = "#b00b00", timeout = 2500), 
                   guidelineDistance = 20, 
                   metric = TRUE, 
                   feet = FALSE, 
                   zIndexOffset = 2000, 
                   shapeOptions = drawShapeOptions(fill = FALSE), 
                   repeatMode = FALSE) {
            leaflet::filterNULL(list(allowIntersection = allowIntersection, 
                                     drawError = drawError, 
                                     uidelineDistance = guidelineDistance, 
                                     metric = metric, 
                                     feet = feet, 
                                     zIndexOffset = zIndexOffset,
                                     shapeOptions = shapeOptions,  
                                     repeatMode = repeatMode)) }
        
        out <- out %>% 
          # addProviderTiles(providers$OpenTopoMap)  %>%
          addProviderTiles(providers$OpenStreetMap,
                           group = 'OSM', options = providerTileOptions(zIndex = 1000)
          ) %>%
          addProviderTiles(providers$Hydda.RoadsAndLabels, group = 'Places and names', options = providerTileOptions(zIndex = 10000)) %>%
          
          addDrawToolbar(
            polylineOptions = mydrawPolylineOptions(metric=TRUE, feet=FALSE),
            editOptions=editToolbarOptions(edit = FALSE,
                                           remove = TRUE,
                                           selectedPathOptions=selectedPathOptions()),
            polygonOptions = FALSE,
            circleOptions = FALSE,
            rectangleOptions = FALSE,
            markerOptions = FALSE,
            circleMarkerOptions = FALSE) %>%
          addResetMapButton() %>%
          
          addLayersControl(
            baseGroups = c('Satellite',
                           'OSM'),
            overlayGroups = c(
              'Places and names'
            ),
            position = 'bottomright') %>%
          addScaleBar(position = 'topright') %>%
          addMiniMap(
            tiles = providers$Esri.WorldStreetMap,
            toggleDisplay = TRUE) %>%
          addEasyButton(easyButton(
            icon="fa-crosshairs", title="Locate Me",
            onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
        
      }
    }
    out
  })
  
  observeEvent(c(input$hf, input$extras, input$location),{
    ok <- FALSE
    hfs <- input$hf
    location <- input$location
    if(location == 'Rufiji'){
      hf <- rufiji_health_facilities
    } else {
      hf <- mopeia_health_facilities
    }
    if(!is.null(hfs)){
      if(hfs){
        ok <- TRUE
      }
    }
    if(ok){
      leafletProxy("l") %>%
        clearMarkers()  %>%
        addMarkers(data = hf,
                   popup = ~name) 
    } else {
      leafletProxy("l") %>%
        clearMarkers() 
    }
  })
  
  observeEvent(c(input$borders, input$extras, input$location),{
    ok <- FALSE
    bords <- input$borders
    location <- input$location
    if(location == 'Rufiji'){
      district_borders <- rufiji2
    } else {
      district_borders <- mopeia2
    }
    if(!is.null(bords)){
      if(bords){
        ok <- TRUE
      }
    }
    if(ok){
      leafletProxy("l") %>%
        # clearShapes() %>% 
        addPolylines(data = district_borders,
                     color = 'white',
                     weight = 2,
                     group = 'District borders') 
      
    } else {
      leafletProxy("l") %>%
        clearShapes()
    }
  })
  
  
  observeEvent(c(input$hf_ll, input$country),{
    ok <- FALSE
    hfs <- input$hf_ll
    location <- input$country
    if(location == 'Tanzania'){
      hf <- rufiji_health_facilities
    } else {
      hf <- mopeia_health_facilities
    }
    if(!is.null(hfs)){
      if(hfs){
        ok <- TRUE
      }
    }
    if(ok){
      leafletProxy("ll") %>%
        clearMarkers()  %>%
        addMarkers(data = hf,
                   popup = ~name) 
    } else {
      leafletProxy("ll") %>%
        clearMarkers() 
    }
  })
  
  observeEvent(c(input$borders_ll,
                 input$hamlet_borders_ll,
                 input$country,
                 input$this_hamlet,
                 input$tabs,
                 input$hamlet),{
                   ok <- FALSE
                   bords <- input$borders_ll
                   location <- input$country
                   shp <- shp_reactive()
                   
                   if(location == 'Tanzania'){
                     district_borders <- rufiji2
                   } else {
                     district_borders <- mopeia2
                   }
                   if(!is.null(bords)){
                     if(bords){
                       ok <- TRUE
                     }
                   }
                   ok_hamlet_borders <- FALSE
                   bords <- input$hamlet_borders_ll
                   if(!is.null(bords)){
                     if(bords){
                       ok_hamlet_borders <- TRUE
                     }
                   }
                   ok_this_hamlet <- FALSE
                   bords <- input$this_hamlet
                   if(!is.null(bords)){
                     if(bords){
                       hamlet <- shp_hamlet()
                       if(!is.null(hamlet)){
                         if(nrow(hamlet) > 0){
                           ok_this_hamlet <- TRUE
                         }
                       }
                     }
                   }
                   
                   # Clear first
                   leafletProxy("ll") %>%
                     clearShapes()
                   
                   if(ok){
                     leafletProxy("ll") %>%
                       addPolylines(data = district_borders,
                                    color = 'black',
                                    weight = 2,
                                    group = 'District borders') 
                     
                   } 
                   if(ok_hamlet_borders){
                     leafletProxy("ll") %>%
                       addPolygons(data = shp,
                                    color = 'purple',
                                    weight = 1,
                                   fillOpacity = 0,
                                    label = shp$village,
                                    group = 'Hamlet borders') 
                   }
                   if(ok_this_hamlet){
                     bb <- bbox(hamlet)
                     leafletProxy("ll") %>%
                       addPolygons(data = hamlet, 
                                   fillColor = 'red',
                                   fillOpacity = 0.5,
                                   stroke = TRUE,
                                   weight = 3,
                                   color = 'red',
                                   popup = hamlet$village,
                                   label = hamlet$village) %>%
                       flyToBounds(lng1 = bb[1,1],
                                   lng2 = bb[1,2],
                                   lat1 = bb[2,1],
                                   lat2 = bb[2,2])
                   }
                   
                 })
  
  output$ht <- renderText({
    out <- NULL
    extras <- input$extras
    if(!is.null(extras)){
      if(extras){
        out <- 'Click the square icon for full screen. Click the line segment to measure distances.'
      }
    }
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
    hamlet_name <- input$hamlet
    if(!is.null(hamlet_name)){
      ok <- TRUE
    }
    if(ok){
      num_houses <- (mop_houses %>% filter(Hamlet %in% hamlet_name) %>% .$households)*1.25
      num_houses <- round(num_houses)
    }
    return(num_houses)
  })
  
  # Get the spatial data (polygons of lowest level available)
  shp_reactive <- reactive({
    country <- input$country
    ok <- FALSE
    out <- NULL
    if(!is.null(country)){
      ok <- TRUE
    }
    if(ok){
      if(country == 'Mozambique'){
        out <- mopeia_hamlets[!is.na(mopeia_hamlets@data$village),]
      } else {
        out <- rufiji_hamlets[!is.na(rufiji_hamlets@data$village),]
      }
    }
    return(out)
  })
  
  shp_hamlet <- reactive({
    shp <- shp_reactive()
    
    # For TZA, we only have spatial data down to the ward level
    country <- input$country
    if(country == 'Mozambique'){
      ih <- input$hamlet
      ix <- input$village
    } else {
      ih <- input$ward
    }
    
    ok <- FALSE
    if(!is.null(shp)){
      if(!is.null(ih)){
        if(nrow(shp) > 0){
          ok <- TRUE
        }
      }
      
    }
    if(!ok){
      out <- NULL
    } else {
      if(country == 'Mozambique'){
        out <- shp[shp@data$village == ih &
                     toupper(shp@data$locality) == toupper(ix),]
      } else {
        out <- shp[shp@data$village == ih,]
      }
      
    }
    return(out)
  })
  
  output$qualy_table <- DT::renderDataTable({

    
    # Get the location code
    lc <- location_code()

    
    ok <- FALSE
    if(!is.null(lc)){
      # See if it's in recon data or not
      is_in <- as.character(lc) %in% recon_data$hamlet_code & !is.na(lc)
      if(!is.null(is_in)){
        if(!is.na(is_in)){
          if(is_in){
            ok <- TRUE
          }
        }
      }
    }

    if(ok){
      # Get a table of relevant info
      sub_data <- recon_data %>% dplyr::filter(hamlet_code == lc)
      sub_data <- sub_data[1,]
      save(sub_data, file = '/tmp/sub_data.RData')
      sub_chiefs <- chiefs %>% filter(instanceID %in% sub_data$instanceID)
      message('sub_chiefs')
      print(sub_chiefs)
      out_list <- list()
      if(nrow(sub_chiefs) > 0){
        for(i in 1:nrow(sub_chiefs)){
          x <- 
            sub_chiefs %>% 
            mutate(chief_role = ifelse(chief_role == 'Other', chief_role_other_role, chief_role)) %>%
            dplyr::select(id = repeated_id, contact = chief_contact, 
                          contact_alternative = chief_contact_alt,
                          name = chief_name,
                          role = chief_role)
          x <- x %>%
            gather(Key, Value, names(x)[2:ncol(x)])
          if(max(x$id) > 1){
            x$Key <- paste0(x$Key, ' ', x$id)
          }
          x$Key <- paste0('Chief ', x$Key)
          out_list[[i]] <- x
        }
        chief_data <- bind_rows(out_list) %>%
          dplyr::select(-id) %>%
          dplyr::rename(Question = Key)
      } else {
        chief_data <- tibble(Question = 'Chief',
                             Value = 'No data available')
      }
      
      sub_data <- sub_data %>%
        gather(Key, Value, names(sub_data)) %>%
        left_join(recon_xls,
                  by = c('Key'='name')) %>%
        dplyr::filter(!is.na(question),
                      !is.na(Value))
      
      out <- sub_data %>%
        dplyr::select(Question= question,
                      Value) %>%
        bind_rows(chief_data)
    } else {
      out <- data.frame(a = c('No data available yet',
                              'Qualitative data to be collected during census reconnaissance activities',
                              '(Jan-Feb)'))
      names(out) <- ' '
      }
    
    
    DT::datatable(out, 
                  options = list(dom = 't',
                                 pageLength = nrow(out)), 
                  rownames = FALSE)
  })
  
  output$quant_table <- DT::renderDataTable({
    ok_this_hamlet <- FALSE
    hamlet <- shp_hamlet()
    if(!is.null(hamlet)){
      if(nrow(hamlet) > 0){
        ok_this_hamlet <- TRUE
      }
    }
    if(!ok_this_hamlet){
      out <- data.frame(a = c('No quantitative data yet available for this hamlet',
                              'Quantitative data will be collected during census reconnaissance activities'))
      names(out) <- ' '
    } else {
      loc <- coordinates(hamlet)[1,]
      # Calculate distance to headquarters
      if(input$country == 'Mozambique'){
        hq <- c(35.711, -17.97864)
      } else {
        hq <- c(38.974951, -7.954815)
      }
      # Calculate distance
      dist <- geosphere::distm(hq,
                               loc,
                               fun = distHaversine)
      out <- hamlet@data[1,] %>% dplyr::select(village, population) %>%
        mutate(`KMs to HQ` = round(as.numeric(dist)/1000, digits = 2))
    }
    
    
    DT::datatable(out, 
                  options = list(dom = 't',
                                 pageLength = nrow(out)), 
                  rownames = FALSE)
  })
  
  observeEvent(input$print_report,{
    showModal(modalDialog(
      title = "Under construction",
      "This functionality is currently under development.",
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  observeEvent(input$print_directions,{
    showModal(modalDialog(
      title = "Under construction",
      "This functionality is currently under development.",
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  observeEvent(input$print_qrs,{
    showModal(modalDialog(
      title = "Print worker QRS",
      fluidPage(
        fluidRow(sliderInput('qrs', label = 'ID numbers',
                             min = 1, max = 1000, value = c(1:10), step = 1)),
        fluidRow(
          column(12, align = 'center',
                 downloadButton('render_qrs',
                                'Generate QR codes for printing'))
        ),
        fluidRow(helpText('Warning: if you are generating many QR codes, it can take a few minutes to process. After clicking the button, do not close the app.'))
      ),
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  observeEvent(input$print_enumeration,{
    ok <- FALSE
    num_houses <- hamlet_num_hh()
    if(!is.null(num_houses)){
      ok <- TRUE
    }
    if(ok){
      showModal(modalDialog(
        title = "Enumeration list generator",
        fluidPage(
          fluidRow(
            column(6,
                   textInput('enumeration_n_hh',
                             'Estimated number of households',
                             value = num_houses),
                   helpText('Err on the high side (ie, enter 20-30% more households than there likely are). It is better to have a list which is too long (and does not get finished) than to have a list which is too-short (and is exhausted prior to finishing enumeration).')),
            column(6,
                   textInput('enumeration_n_teams',
                             'Number of teams'),
                   helpText('Usually, in order to avoid duplicated household IDs, there should just be one team. In the case of multiple teams, it is assumed that each team will enumerate a similar number of households.'))
          ),
          fluidRow(
            column(12, align = 'center',
                   downloadButton('render_enumeration_list',
                                  'Generate list(s)'))
          )
        ),
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  output$animal_map_tz <- renderLeaflet({
    
    pd <- animal %>%
      filter(Country == 'Tanzania') %>%
      dplyr::select(Hamlet, lon, lat, n_goats, n_cattle, n_pigs) 
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
      addPolygons(data = ruf2,
                  fillOpacity = 0.1) %>%
      addMarkers(data = pd,
                 popup = paste0(pd$Hamlet, ': ',
                                pd$n_goats, ' goats, ',
                                pd$n_cattle, ' cattle, ',
                                pd$n_pigs, ' pigs'))
  })
  output$animal_map_mz <- renderLeaflet({
    pd <- animal %>%
      filter(Country == 'Mozambique') %>%
      dplyr::select(Hamlet, lon, lat, n_goats, n_cattle, n_pigs) 
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
      addPolygons(data = mop2,
                  fillOpacity = 0.1) %>%
      addMarkers(data = pd,
                 popup = paste0(pd$Hamlet, ': ',
                                pd$n_goats, ' goats, ',
                                pd$n_cattle, ' cattle, ',
                                pd$n_pigs, ' pigs'))
  })
  output$animal_table_tz <- DT::renderDataTable({
    animal %>%
      filter(Country == 'Tanzania') %>%
      dplyr::select(Hamlet, Goats = n_goats, Cattle = n_cattle, Pigs = n_pigs)
  })
  output$animal_table_mz <- DT::renderDataTable({
    animal %>%
      filter(Country == 'Mozambique') %>%
      dplyr::select(Hamlet, Goats = n_goats, Cattle = n_cattle, Pigs = n_pigs)
  })
  
  output$animal_text_mz <- renderText({
    nx <- nrow(animal %>% filter(Country == 'Mozambique'))
    paste0(nx, ' forms administered.')
  })
  output$animal_text_tz <- renderText({
    nx <- nrow(animal %>% filter(Country == 'Tanzania'))
    paste0(nx, ' forms administered.')
  })
  
  output$data_collection_table <- DT::renderDataTable({
    
    dcx <- input$data_collection_picker
    
    pd <- geocodes %>%
      mutate(geocoded = ifelse(is.na(animal_lat) & is.na(recon_lat),
                               'No',
                               ifelse(is.na(animal_lat) & !is.na(recon_lat),
                                      'Yes, in recon',
                                      ifelse(!is.na(animal_lat) & is.na(recon_lat),
                                             'Yes, in animal annex',
                                             ifelse(!is.na(animal_lat) & !is.na(recon_lat),
                                                    'Yes, in both', NA))))) %>%
      mutate(animal_done = ifelse(is.na(animal_done), FALSE, animal_done)) %>%
      mutate(recon_done = ifelse(is.na(recon_done), FALSE, recon_done)) %>%
      dplyr::select(Country, Region, District, Ward, Village, Hamlet, geocoded,
                    code, lng, lat, animal_done, recon_done)

    if(dcx == 'By country'){
      pd <- pd %>%
        group_by(Country) %>%
        summarise(`Hamlets` = n(),
                  `Geocoded` = length(which(grepl('Yes', geocoded))),
                  `Finished recon` = length(which(recon_done)),
                  `Finished animal annex` = length(which(animal_done)))
      pd
    } else {
      return(pd)
    }
  })
  
  output$data_collection_need_geocoding_table <- DT::renderDataTable({
    pd <- geocodes %>%
      filter(is.na(lng)) %>%
      dplyr::select(Country, Region, District, Ward, Village, Hamlet, code)
      pd
  })
  
  output$data_collection_need_recon_table <- DT::renderDataTable({
    pd <- geocodes %>%
      filter(is.na(recon_done)) %>%
      dplyr::select(Country, Region, District, Ward, Village, Hamlet, code)
    pd
  })
  
  output$data_collection_need_animal_table <- DT::renderDataTable({
    pd <- geocodes %>%
      filter(is.na(animal_done)) %>%
      dplyr::select(Country, Region, District, Ward, Village, Hamlet, code)
    pd
  })
  
  output$data_collection_contradictory_table <- DT::renderDataTable({
    pd <- geocodes %>%
      filter(!is.na(distance)) %>%
      dplyr::select(distance, Country, Region, District, Ward, Village, Hamlet, code,
                    animal_lat,
                    animal_lng,
                    recon_lat,
                    recon_lng) %>%
      mutate(distance = round(distance)) %>%
      arrange(desc(distance))
    pd
  })
  
  cluster_data <- reactiveValues(summary_text = NULL,
                                 map = NULL,
                                 hamlet_df = NULL,
                                 cluster_df = NULL)
  
  observeEvent(input$action_cluster, {
    
    withCallingHandlers({
      message('Server messages:')
      shinyjs::html("text", "")
      
      out <- try_clusters(the_country = input$cluster_the_country,
                          include_clinical = input$include_clinical,
                          interpolate_animals = input$interpolate_animals,
                          interpolate_humans = input$interpolate_humans,
                          humans_per_household = input$humans_per_household,
                          p_children = input$p_children,
                          minimum_households = input$minimum_households,
                          minimum_children = input$minimum_children,
                          minimum_humans = input$minimum_humans,
                          minimum_animals = input$minimum_animals,
                          minimum_cattle = input$minimum_cattle,
                          minimum_pigs = input$minimum_pigs,
                          minimum_goats = imput$minimum_goats,
                          df = df)
      cluster_data$summary_text <- out$summary_text
      cluster_data$map <- out$map
      cluster_data$hamlet_df <- out$hamlet_df
      cluster_data$cluster_df <- out$cluster_df                   
      message = function(m) output$text <- renderPrint(m$message) 
    },
    message = function(m) {
      shinyjs::html(id = "text", html = m$message, add = TRUE)
    }
    )
    
  })
  
  output$cluster_summary_text <- renderText({
    cluster_data$summary_text
  })
  output$cluster_map <- renderLeaflet({
    cluster_data$map
  })
  
  output$animal_plot_mz <- renderPlot({
    pd <- animal %>% filter(Country == 'Mozambique') %>%
      dplyr::select(hamlet_code, n_cattle, n_goats, n_pigs) %>%
      tidyr::gather(key, value, n_cattle:n_pigs) %>%
      mutate(key = gsub('n_', '', key)) %>%
      group_by(key, value) %>%
      tally %>%
      mutate(value = ifelse(is.na(value), '0', value))
    pd$value <- factor(pd$value, 
                       levels = c('0',
                                  '1 to 5',
                                  '6 to 19',
                                  '20 or more'))
    ggplot(data = pd,
           aes(x = value,
               y = n)) +
      geom_bar(stat = 'identity') +
      facet_wrap(~key, ncol = 1) +
      theme_bw() +
      labs(x = '',
           y = 'Hamlets') +
      theme(strip.text = element_text(size = 20)) +
      geom_text(aes(label = n),nudge_y = 15)
  })
  
  output$animal_plot_tz <- renderPlot({
    pd <- animal %>% filter(Country == 'Tanzania') %>%
      dplyr::select(hamlet_code, n_cattle, n_goats, n_pigs) %>%
      tidyr::gather(key, value, n_cattle:n_pigs) %>%
      mutate(key = gsub('n_', '', key)) %>%
      group_by(key, value) %>%
      tally %>%
      mutate(value = ifelse(is.na(value), '0', value))
    pd$value <- factor(pd$value, 
                       levels = c('0',
                                  '1 to 5',
                                  '6 to 19',
                                  '20 or more'))
    ggplot(data = pd,
           aes(x = value,
               y = n)) +
      geom_bar(stat = 'identity') +
      facet_wrap(~key, ncol = 1) +
      theme_bw() +
      labs(x = '',
           y = 'Hamlets') +
      theme(strip.text = element_text(size = 20)) +
      geom_text(aes(label = n),nudge_y = 15)
  })
  
  output$render_qrs <- 
    downloadHandler(filename = "list.pdf",
                    content = function(file){
                      
                      # Get the qrs to be printed
                      ids <- input$qrs
                      ids <- seq(min(ids),
                                 max(ids),
                                 by = 1)
                      
                      # Generate
                      print_worker_qrs(wid = ids)

                      # copy pdf to 'file'
                      file.copy("qrs.pdf", file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
  output$render_enumeration_list <-
    downloadHandler(filename = "list.pdf",
                    content = function(file){
                      
                      # Get the location code
                      lc <- location_code()
                      data <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                         n_teams = as.numeric(as.character(input$enumeration_n_teams)))
                      # generate html
                      out_file <- paste0(system.file('shiny/operations/rmds', package = 'bohemia'), '/list.pdf')
                      rmarkdown::render(paste0(system.file('shiny/operations/rmds', package = 'bohemia'), '/list.Rmd'),
                                        params = list(data = data,
                                                      loc_id = lc))
                      
                      # copy html to 'file'
                      file.copy(out_file, file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
}

shinyApp(ui, server)
