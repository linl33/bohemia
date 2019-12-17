library(shiny)
library(shinydashboard)
library(dplyr)
library(DT)
library(leaflet)
source('global.R')

header <- dashboardHeader(title="ID look-up app")
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
                 textInput('qr',
                           'Enter ID (or portion)',
                           placeholder = '123-456'),
                 checkboxInput('show_houses',
                               'Show other households',
                               value = FALSE),
                 checkboxInput('show_searched_houses',
                               'Show searched households',
                               value = TRUE),
                 checkboxInput('show_borders',
                               'Show borders',
                               value = FALSE)),
          column(9,
                 leafletOutput('l'))
        ),
        fluidRow(column(3),
                 column(9,
                        uiOutput('uix'),
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
 
  sub_locations <- reactive({
    iqr <- input$qr
    ok <- FALSE
    if(!is.null(iqr)){
      out <- locations[grepl(iqr, locations$qr, fixed = TRUE),]
      if(nrow(out) < nrow(locations) & nrow(out) > 0){
        ok <- TRUE
      }
    }
    if(ok){
      return(out)
    } else {
      return(NULL)
    }
    
  })
  
  output$dt <- DT::renderDataTable({
    sl <- sub_locations()
    out <- NULL
    if(!is.null(sl)){
      if(nrow(sl) > 0){
        out <- sl@data %>%
          dplyr::select(qr, comarca, lng, lat)
      }
    }
    return(out)
  })
  
  output$l <- renderLeaflet({
    
    vv <- voronoid
    
    district_borders <- polygon
    out <- leaflet()  %>%
      addProviderTiles(providers$Stamen.Toner,
                       group = 'Satellite', options = providerTileOptions(zIndex = 3)) %>%
      addPolygons(data = vv,
                  weight = 0,
                  color = NA)

    out
  })
  
  observeEvent(c(input$show_borders),{
    if(input$show_borders){
      vv <- voronoid
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
  
  observeEvent(c(input$show_houses),{
    
    sl <- sub_locations()
    ok <- FALSE
    if(!is.null(sl)){
      if(nrow(sl) > 0){
        ok <- TRUE
      }
    }
    
    if(input$show_houses){
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
      if(ok){
        if(input$show_searched_houses){
          leafletProxy("l") %>%
            clearMarkers() %>%
            addCircleMarkers(data = sl,
                             # radius = 2,
                             weight =2,
                             color = ~pal(comarca),
                             fillOpacity = 0.8,
                             stroke = FALSE) %>%
            addMarkers(data = sl,
                       icon = list(
                         iconSize = c(30, 30),
                         iconUrl = 'icon.png'
                       ),
                       popup = paste0('Household ID code: ', sl$qr, '. Hamlet: ', sl$comarca))
        }
      }
      else {
        leafletProxy("l") %>%
          clearMarkers() 
      }
    }
  })
  
  # Observe changes to the text input
  observeEvent(c(input$qr, input$show_searched_houses),{
    sl <- sub_locations()
    ok <- FALSE
    if(!is.null(sl)){
      if(nrow(sl) > 0){
        ok <- TRUE
      }
    }
    if(ok){
      if(input$show_searched_houses){
        leafletProxy("l") %>%
          clearMarkers() %>%
          addCircleMarkers(data = sl,
                           # radius = 2,
                           weight =2,
                           color = ~pal(comarca),
                           fillOpacity = 0.8,
                           stroke = FALSE) %>%
          addMarkers(data = sl,
                     icon = list(
                       iconSize = c(30, 30),
                       iconUrl = 'icon.png'
                     ),
                     popup = paste0('Household ID code: ', sl$qr, '. Hamlet: ', sl$comarca))
      }
    }
     else {
      leafletProxy("l") %>%
        clearMarkers() 
    }
  })
  
  output$uix <- renderUI({
    sl <- sub_locations()
    out <- NULL
    if(!is.null(sl)){
      if(nrow(sl) > 0){
        out <- sl@data
      }
    }
    no_qr <- FALSE
    if(is.null(input$qr)){
      no_qr <- TRUE
    }
    if(nchar(input$qr) == 0){
      no_qr <- TRUE
    }
    
    if(is.null(out)){
      if(no_qr){
        out <- fluidPage(
          h3('Search for households by typing the QR code in the text box')
        )
      } else {
        out <- fluidPage(
          h3('No households matched the search term: "', input$qr, '"')
        )
      }
    }
  })
  
}

shinyApp(ui, server)