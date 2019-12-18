library(shiny)
source('global.R')

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Mopeia data fixer"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput('id', 'Bairro ID', choices = ids)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput('l')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    # Reactive object of identified hh
    bad_houses <- reactiveVal(value = c())
    
    # Reactive objects given selected i
    households_reactive <- reactive({
        inid <- input$id
        bh <- bad_houses()
        mopeia_households %>%
            filter(id == inid) %>%
            mutate(bad = joe_id %in% bh)
    })

    hamlet_reactive <- reactive({
        inid <- input$id
        mopeia_hamlet_details %>%
            filter(id == inid)
    })
    
    # Leaflet map
    output$l <- renderLeaflet({
        
        out <- leaflet() %>%
            addTiles() %>%
            addPolylines(data = mopeia2,
                         color = 'black',
                         weight = 1)
    })
    
    observeEvent(c(bad_houses(),
                   input$id),{
        
        # Get the reactive households
        hr <- households_reactive()

        bh <- bad_houses()
        good <- hr %>% filter(!bad)
        bad <- hr %>% filter(bad)
        print(table(hr$bad))
        leafletProxy('l') %>%
            clearMarkers() %>%
            addCircleMarkers(data = good,
                             radius = 5,
                             color = 'red',
                             layerId = good$joe_id,
                             weight = 5,
                             opacity = 0.8,
                             fillColor = 'red',
                             label = paste0('Joe ID: ', good$joe_id, ' ID in COST: ', good$hid)) %>%
            addCircleMarkers(data = bad,
                             radius = 5,
                             color = 'black',
                             layerId = bad$joe_id,
                             weight = 5,
                             opacity = 0.8,
                             fillColor = 'black',
                             label = paste0('FLAGGED AS BAD. Joe ID: ', bad$joe_id, ' ID in COST: ', bad$hid))

        
    })
    
    # Capture clicks
    observeEvent(input$l_marker_click,{
        p <- input$l_marker_click
        pid <- p$id
        # print(p)
        bh <- bad_houses()
        if(pid %in% bh){
            message(pid, ' is already in bh. Removing')
            bh <- bh[bh != pid]
        } else {
            message('Adding ', pid, ' to bh')
            bh <- c(pid, bh)
        }
        bad_houses(bh)
        message('bad houses are:')
        bh <- bad_houses()
        print(bh)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
