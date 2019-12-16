library(shiny)
library(shinydashboard)
library(dplyr)
library(DT)
library(leaflet)
source('global.R')

header <- dashboardHeader(title="QR example app")
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
        fluidRow(
          column(3,
                 checkboxInput('show_houses',
                               'Show households',
                               value = TRUE),
                 checkboxInput('show_borders',
                               'Show borders',
                               value = FALSE),
                 actionButton('randomize',
                              'Re-randomize household locations')),
          column(9,
                 leafletOutput('l'))
        ),
        fluidRow(column(3),
                 column(9,
                        DT::dataTableOutput('dt')))

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
  
  fake_data <- reactiveValues(locations = generate_fake_locations(bbp = bbp))
  voronoid <- reactive({
    locations <- fake_data$locations
    out <- voronoi(shp = locations,
                   poly = polygon)
    return(out)
  })
  
  observeEvent(input$randomize,{
    locations = generate_fake_locations(bbp = bbp)
    print(head(locations))
    fake_data$locations <- locations
  })
  
  output$dt <- DT::renderDataTable({
    locations <- fake_data$locations
    out <- get_space(locations)
    out
  })
  
  output$l <- renderLeaflet({
    
    locations <- fake_data$locations
    vv <- voronoid()
    
    pal <- colorFactor(palette = 'Spectral',
                       domain = locations$comarca)
    
    district_borders <- polygon
    out <- leaflet()  %>%
      addProviderTiles(providers$Stamen.Toner,
                       group = 'Satellite', options = providerTileOptions(zIndex = 3)) %>%
      addPolygons(data = vv,
                  weight = 0,
                  color = NA)

    out
  })
  
  observeEvent(c(input$show_borders,
                 input$randomize),{
    if(input$show_borders){
      vv <- voronoid()
      leafletProxy("l") %>%
        clearShapes() %>%
        addPolygons(data = vv,
                    fillColor = ~pal(id),
                    color = 'black',
                    stroke = TRUE,
                    weight = 1,
                    fillOpacity = 0.8,
                    popup = paste0('Hamlet name: ', vv$id))
    } else {
      leafletProxy("l") %>%
        clearShapes()
    }
  })
  
  observeEvent(c(input$show_houses,
                 input$randomize),{
    if(input$show_houses){
      locations <- fake_data$locations
      leafletProxy("l") %>%
        clearMarkers() %>%
        addCircleMarkers(data = locations,
                         # radius = 2,
                         weight =1,
                         color = ~pal(comarca),
                         fillOpacity = 0.6,
                         stroke = FALSE) %>%
        addMarkers(data = locations,
                   icon = list(
                     iconSize = c(15, 15),
                     iconUrl = 'icon.png'
                   ),
                   popup = paste0('Household ID code: ', locations$qr, '. Hamlet: ', locations$comarca))
        
    } else {
      leafletProxy("l") %>%
        clearMarkers()
    }
  })
}







shinyApp(ui, server)