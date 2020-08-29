library(shiny)
library(shinydashboard)
library(tidyverse)
library(reshape2)
if('temp_data.RData' %in% dir()){
    load('temp_data.RData')
} else {
    source('global.R')
}
# how are credentials used, where should i store them
# am i adding to the credentials file

# use function to get odk data using minicensus as name 
header <- dashboardHeader(title = 'Minicensus grader')
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            text="Main",
            tabName="main",
            icon=icon("home")),
        menuItem(
            text="Details",
            tabName="details",
            icon=icon("archway")),
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
                DT::dataTableOutput('agg_table')
            )),
        tabItem(
            tabName = 'details',
            fluidPage(
                fluidRow(
                    column(12,
                           h3('Fieldworkers'),
                           selectInput(inputId = 'fw_id',
                                       label = 'Select FW ID',
                                       choices = agg$`Worker ID`, 
                                       multiple = FALSE),
                           DT::dataTableOutput('fw_table'),
                           h3('Questions'),
                           selectInput(inputId = 'q_id',
                                       label = 'Select Question',
                                       choices = sort(unique(final$Variable))),
                           DT::dataTableOutput('q_table'),
                           h3('Complete data'),
                           DT::dataTableOutput('overall_table'))
                )
                
            )
            
            
        ),
        tabItem(
            tabName = 'about',
            fluidPage(
                fluidRow(
                    # div(img(src='logo.png', align = "center"), style="text-align: center;"),
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
ui <- dashboardPage(header, sidebar, body, skin="blue", title = 'databrew')

# Server
server <- function(input, output, session) {
    
    
    output$fw_table <- DT::renderDataTable({
        fid <- input$fw_id
        if(is.null(fid)){
            out <- NULL
        } else{
            out <- done %>% filter(`Worker ID` == fid)
        }
        return(out)
    })
    
    output$q_table <- DT::renderDataTable({
        fid <- input$q_id
        if(is.null(fid)){
            out <- NULL
        } else{
            out <- done %>% filter(Variable == fid)
        }
        return(out)
    })
    
    output$overall_table <- DT::renderDataTable({
        done
    })
    
    output$agg_table <- DT::renderDataTable({
        agg
    })
    
}
shinyApp(ui, server)#
