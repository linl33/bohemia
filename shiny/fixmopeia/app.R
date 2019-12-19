library(shiny)
source('global.R')

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Mopeia data fixer"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput('id', 'Bairro ID', choices = ids),
            column(12, align = 'center',
                   actionButton('next_bairro',
                                'Next bairro',
                                icon = icon('arrow-right'))),
            column(12, align = 'center',
                   textOutput('warning_text')),
            column(12, align = 'center',
                   actionButton('submit', 'Submit corrections',
                                icon = icon('home'))
            ),
            hr(), br(),
            column(12, align = 'center',
                   h3('Instructions')),
            HTML('<ul><li>Select a bairro. All households in that bairro will show up as red dot.<li>If a point is incorrect, click it. It will turn black.<li>If a point is black (flagged as incorrect), but it is actually correct, click it again; it will turn back to red<li>The polygon is the "convex hull" formed by the perimeter of the (correct) points.<li>When the polygon is correctly shaped (ie, all incorrect points have been flagged, click "Submit corrections" and move on to the next bairro.</ul>')
        ),
        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput('l'),
            textOutput('ht'),
            fluidRow(
                column(6,
                       h3('Households of this code which have been flagged as erroneous:'),
                       verbatimTextOutput('ftid')),
                column(6,
                       h3('All households identified as geographically erroneous:'),
                       verbatimTextOutput('ft'))
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    # Reactive object of identified hh
    bad_houses <- reactiveVal(value = starting_bad_houses)
    
    # Reactive objects given selected i
    households_reactive <- reactive({
        inid <- input$id
        bh <- bad_houses()
        mopeia_households %>%
            filter(id == inid) %>%
            mutate(bad = joe_id %in% bh)
    })
    
    # Only households (without indication of good bad)
    households_only <- reactive({
        inid <- input$id
        mopeia_households %>%
            filter(id == inid)
    })
    
    hamlet_reactive <- reactive({
        inid <- input$id
        mopeia_hamlet_details %>%
            filter(id == inid)
    })
    
    # Leaflet map
    output$l <- renderLeaflet({
        
        hr <- households_only()
        out <- leaflet() %>%
            addTiles() %>%
            # addPolylines(data = mopeia2,
            #              color = 'black',
            #              weight = 1) %>%
            addCircleMarkers(data = hr,
                             weight = 0)
    })
    
    observeEvent(c(bad_houses(),
                   input$id),{
                       
                       # Get the reactive households
                       hr <- households_reactive()
                       
                       bh <- bad_houses()
                       good <- hr %>% filter(!bad)
                       bad <- hr %>% filter(bad)
                       
                       # Get shapes and convex hull
                       make_ch <- function(x){
                           out <- NULL
                           if(!is.null(x)){
                               if(nrow(x) > 0){
                                   if('x' %in% names(x)){
                                       x <- data.frame(x)
                                       coordinates(x) <- ~x+y
                                       proj4string(x) <- proj4string(mopeia2)
                                       out <- rgeos::gConvexHull(x)
                                       out <- SpatialPolygonsDataFrame(Sr = out,
                                                                       data = data.frame(id = 1:length(out)))
                                   }
                               }
                           }
                           
                           return(out)
                       }
                       good_ch <- make_ch(good)
                       
                       # Add the shape if possible
                       if(!is.null(good_ch)){
                           leafletProxy('l') %>%
                               clearShapes() %>%
                               clearMarkers() %>%
                               addPolygons(data = good_ch,
                                           color = 'pink',
                                           fillOpacity = 0.3,
                                           weight = 1,
                                           stroke = TRUE,
                                           fillColor = 'red')  %>%
                               addCircleMarkers(data = good,
                                                radius = 1,
                                                color = 'red',
                                                layerId = good$joe_id,
                                                weight = 2,
                                                opacity = 0.8,
                                                fillColor = 'red',
                                                label = paste0('Joe ID: ', good$joe_id, ' ID in COST: ', good$hid)) %>%
                               addCircleMarkers(data = bad,
                                                radius = 1,
                                                color = 'black',
                                                layerId = bad$joe_id,
                                                weight = 2,
                                                opacity = 0.8,
                                                fillColor = 'black',
                                                label = paste0('FLAGGED AS BAD. Joe ID: ', bad$joe_id, ' ID in COST: ', bad$hid))
                       } else {
                           leafletProxy('l') %>%
                               clearMarkers() %>%
                               clearShapes() %>%
                               addCircleMarkers(data = good,
                                                radius = 1,
                                                color = 'red',
                                                layerId = good$joe_id,
                                                weight = 2,
                                                opacity = 0.8,
                                                fillColor = 'red',
                                                label = paste0('Joe ID: ', good$joe_id, ' ID in COST: ', good$hid)) %>%
                               addCircleMarkers(data = bad,
                                                radius = 1,
                                                color = 'black',
                                                layerId = bad$joe_id,
                                                weight = 2,
                                                opacity = 0.8,
                                                fillColor = 'black',
                                                label = paste0('FLAGGED AS BAD. Joe ID: ', bad$joe_id, ' ID in COST: ', bad$hid))
                           
                       }
                       
                       
                       
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
    
    output$ht <- renderText({
        inid <- input$id
        the_row <- mopeia_hamlet_details %>%
            filter(id == inid)
        paste0('ID: ', the_row$id,
               '. Localidade: ', the_row$Village, 
               '. Bairro: ', the_row$Hamlet, 
               '. Population: ', the_row$population)
    })
    
    output$ft <- renderText({
        bh <- bad_houses()
        paste0(sort(unique(bh)), collapse = ', ')
    })
    
    
    output$ftid <- renderText({
        hr <- households_reactive()
        out <- hr %>% filter(bad)
        
        paste0(sort(unique(out$hid)), collapse = ', ')
    })
    
    # Observe the submission and write a csv
    observeEvent(input$submit,{
        message('Writing csv')
        # Read in the old ones
        old_bh <- readr::read_csv('data/bh.csv')
        # Combine with the new ones
        bh <- bad_houses()
        new_bh <- sort(unique(c(bh, old_bh$id)))
        # Make new dataframe
        out <- tibble(id = new_bh)
        readr::write_csv(out, 'data/bh.csv')
    })
    
    warning_value <- reactiveVal(value = FALSE)
    observeEvent(c(bad_houses(),input$submit), {
        in_memory_bh <- bad_houses()
        in_csv_bh <- read_csv('data/bh.csv')
        in_csv_bh <- in_csv_bh$id
        in_memory_bh <- sort(unique(in_memory_bh))
        in_csv_bh <- sort(unique(in_csv_bh))
        if(all(in_memory_bh == in_csv_bh)){
            warning_value(FALSE)
        } else {
            warning_value(TRUE)
        }
    })
    output$warning_text <- renderText({
        wv <- warning_value()
        if(wv){
            paste0('You have unsaved changes. Make sure to click "Submit corrections" before closing the app')
        } else {
            paste0('You do not have any unsaved changes')
        }
    })
    
    observeEvent(input$next_bairro,{
        inid <- input$id
        wid <- which(ids == inid)
        new_index <- wid+1
        if(new_index > length(ids)){
            new_index <- 1
        }
        new_choice <- ids[new_index]
        updateSelectInput(session, inputId = 'id',
                          choices = ids,
                          selected = new_choice)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
