library(shiny)
library(shinydashboard)
library(dplyr)
library(geosphere)
source('global.R')

header <- dashboardHeader(title="Bohemia Operations Helper App")
sidebar <- dashboardSidebar(
  
  sidebarMenu(id = 'tabs',
              
              menuItem(
                text="Hamlet explorer",
                tabName="hamlet_explorer",
                icon=icon("home")),
              
              menuItem(
                text="Overview map",
                tabName="main",
                icon=icon("eye")),
              
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
      tabName="hamlet_explorer",
      fluidPage(
        # fluidRow(column(3,
        #                 textInput('search', 'Search (for a village, ward, localidade, etc.)',
        #                           placeholder = 'For example: 4 de julho, posto campo, etc.')),
        #          column(9,
        #                 DT::dataTableOutput('locations_table')))
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
                                      'Show hamlet borders',
                                      value = FALSE),
                        checkboxInput('this_hamlet',
                                      'Highlight this hamlet',
                                      value = FALSE),
                        br(), br(),
                        actionButton('print_enumeration',
                                     'Print enumeration lists',
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
                                     pageLength = 5), 
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
      addPolylines(data = district_borders, weight = 0) 

    
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
          addMiniMap(
            tiles = providers$Esri.WorldStreetMap,
            toggleDisplay = TRUE) %>%
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
      addFullscreenControl()
    
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
        addPolylines(data = shp,
                     color = 'red',
                     weight = 1,
                     group = 'Hamlet borders') 
    }
    if(ok_this_hamlet){
      leafletProxy("ll") %>%
        addPolygons(data = hamlet, 
                    fillColor = 'red',
                    fillOpacity = 0.8,
                    stroke = TRUE,
                    weight = 1,
                    color = 'black',
                    popup = hamlet$village,
                    label = hamlet$village)
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
        out <- mopeia_hamlets
      } else {
        out <- rufiji_hamlets
      }
    }
    return(out)
  })
  
  shp_hamlet <- reactive({
    shp <- shp_reactive()
    ih <- input$hamlet
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
      out <- shp[shp@data$village == ih,]
    }
    return(out)
  })
  
  output$qualy_table <- DT::renderDataTable({
    out <- data.frame(a = c('No data available yet',
                     'Qualitative data to be collected during census reconnaissance activities',
                     '(Jan-Feb)'))
    names(out) <- ' '
    DT::datatable(out, 
                  options = list(dom = 't',
                                 pageLength = 5), 
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
                                 pageLength = 5), 
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
  
  observeEvent(input$print_enumeration,{
    showModal(modalDialog(
      title = "Enumeration list generator",
      fluidPage(
        fluidRow(
          column(6,
                 textInput('enumeration_n_hh',
                           'Estimated number of households'),
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
  })
  
  output$render_enumeration_list <-
    downloadHandler(filename = "list.pdf",
                    content = function(file){
                      
                      # Get the location code
                      lc <- location_code()
                      data <- data.frame(n_hh = as.numeric(as.character(input$enumeration_n_hh)),
                                         n_teams = as.numeric(as.character(input$enumeration_n_teams)))
                      # generate html
                      rmarkdown::render('rmds/list.Rmd',
                                        params = list(data = data,
                                                      loc_id = lc))
                      
                      # copy html to 'file'
                      file.copy("rmds/list.pdf", file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
}


shinyApp(ui, server)