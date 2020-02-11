library(shiny)
library(shinydashboard)

source('global.R')

header <- dashboardHeader(title = tags$a(href='http://databrew.cc',
                                         tags$img(src='logo.png',height='32',width='36', alt = 'DataBrew')))
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            text="Main",
            tabName="main",
            icon=icon("archway")),
        menuItem(
            text="Alerts",
            tabName="alerts",
            icon=icon("bell")),
        menuItem(
            text="Performance",
            tabName="performance",
            icon=icon("poll")),
        menuItem(
            text="Actions",
            tabName="actions",
            icon=icon("list")),
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
                    
                )
            )
        ),
        tabItem(
            tabName="alerts",
            fluidPage(
                fluidRow(
                    
                )
            )
        ),
        tabItem(
            tabName="performance",
            fluidPage(
                fluidRow(
                    
                )
            )
        ),
        tabItem(
            tabName="actions",
            fluidPage(
                fluidRow(
                    
                )
            )
        ),
        tabItem(
            tabName = 'about',
            fluidPage(
                fluidRow(
                    div(img(src='logo.png', align = "center"), style="text-align: center;"),
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
    
   
}

shinyApp(ui, server)#
