library(shiny)
library(shinydashboard)
if('temp_data.RData' %in% dir()){
    load('temp_data.RData')
} else {
    source('global.R')
}
# how are credentials used, where should i store them
# am i adding to the credentials file

# use function to get odk data using minicensus as name 
header <- dashboardHeader(title = tags$a(tags$img(src='logo.png',height='32',width='36', alt = 'DataBrew')))
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            text="Main",
            tabName="main",
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
                fluidRow(
                    column(4,
                           selectInput(inputId = 'fw_id',
                                       label = 'Select FW',
                                       choices = c('fw1', 'fw2', 'fw3'), 
                                       selected = c('fw1', 'fw2', 'fw3'),
                                       multiple = TRUE),
                           selectInput(inputId = 'q_id',
                                       label = 'Select Question',
                                       choices = sort(unique(temp$question)), 
                                       selected = sort(unique(temp$question)), 
                                       multiple = TRUE)),
                    column(8,
                           plotOutput('fw_plot'),
                           DT::dataTableOutput('fw_table'))
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
ui <- dashboardPage(header, sidebar, body, skin="blue", title = 'databrew')

# Server
server <- function(input, output, session) {
    
    
    output$fw_table <- DT::renderDataTable({
        # get inputs
        fw_id <- c('fw1', 'fw2', 'fw3')
        q_id <- sort(unique(temp$question))
        fw_id <- input$fw_id
        q_id <- input$q_id
        
        temp <- temp %>% 
            select(question, key, fw_id) %>% 
            filter(question %in% q_id)
        
        DT::datatable(temp)
    })
    
    output$fw_plot <- renderPlot({
        # get inputs
        fw_id <- c('fw1', 'fw2', 'fw3')
        q_id <- sort(unique(temp$question))
        fw_id <- input$fw_id
        q_id <- input$q_id
        
        temp <- temp %>% 
            select(question, key, fw_id) %>% 
            filter(question %in% q_id)
        
        temp_key <- temp %>% select(question, key)
        temp_test <- temp %>% select(question, fw_id)
        
        temp_test <- melt(temp_test, id.vars = c('question'))
        temp_test <- left_join(temp_test, temp_key)
        temp_test$answer <- ifelse(temp_test$value != temp_test$key, 'wrong', 'right')
        temp_test$answer[is.na(temp_test$answer)] <- 'wrong'

        temp_test <- temp_test %>% group_by(variable) %>% summarise(sum_right = sum(answer == 'right'),
                                                                     sum_wrong = sum(answer == 'wrong'))
        temp_test$percent_correct = round(temp_test$sum_right/(temp_test$sum_right+temp_test$sum_wrong)*100,2)
        ggplot(temp_test, aes(variable, percent_correct)) + geom_bar(stat='identity')
    })
    
    
}
shinyApp(ui, server)#
