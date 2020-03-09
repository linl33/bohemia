library(shiny)
library(shinydashboard)
library(dplyr)
source('global.R')

header <- dashboardHeader(title="Bohemia Satellite Viewer")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Main",
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
    
    hfs <- input$hf
    if(!is.null(hfs)){
      if(hfs){
        out <- out %>%
          addMarkers(data = hf,
                     popup = ~name)
      }
    }
    
    bords <- input$borders
    if(!is.null(bords)){
      if(bords){
        out <- out %>%
          addPolylines(data = district_borders,
                       color = 'white',
                       weight = 2,
                       group = 'District borders') 
      }
    }
    
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
          addProviderTiles(providers$Hydda.RoadsAndLabels, group = 'Place names', options = providerTileOptions(zIndex = 10000)) %>%
          
          addDrawToolbar(
            polylineOptions = mydrawPolylineOptions(metric=TRUE, feet=FALSE),
            editOptions=editToolbarOptions(edit = FALSE,
                                           remove = TRUE,
                                           selectedPathOptions=selectedPathOptions()),
            # editOptions = TRU,
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
              'Place names'
            ),
            position = 'bottomright') %>%
          # hideGroup(c('Place names')) %>%
          # hideGroup(c('Graticules')) %>%
          # hideGroup(c('Satellite')) %>%
          # hideGroup(c('OSM')) %>%
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
  
  output$ht <- renderText({
    out <- NULL
    extras <- input$extras
    if(!is.null(extras)){
      if(extras){
        out <- 'Click the square icon for full screen. Click the line segment to measure distances.'
      }
    }
  })
}







shinyApp(ui, server)