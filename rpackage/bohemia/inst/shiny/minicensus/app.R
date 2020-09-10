library(shiny)
library(shinydashboard)
library(tidyverse)
library(reshape2)
library(DT)
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
            text="Answer key",
            tabName="answer_key",
            icon=icon("key")),
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
            tabName = 'answer_key',
            fluidPage(
                column(3,
                       selectInput('code', 'Hamlet code',
                                   choices = answer_non_repeats$hh_hamlet_code)),
                column(9,
                       h3('Non-repeats'),
                       DT::dataTableOutput('answer_key_table'),
                       h3('Repeats'),
                       DT::dataTableOutput('answer_key_repeats_table'))
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
    
    output$answer_key_table <- DT::renderDataTable({
        the_code <- input$code
        the_answer_non_repeats <- answer_non_repeats %>% filter(hh_hamlet_code == the_code)
        label_df <- tibble(name = names(the_answer_non_repeats)) %>% left_join(xf)
        out <- tibble(
               `Variable` = names(the_answer_non_repeats),
               `Label (en)` = label_df$en,
               `Label (sw)` = label_df$sw,
               `Correct answer` = as.character(the_answer_non_repeats))
        out <- out %>%
            filter(!Variable %in% dont_evaluate,
                   !is.na(`Correct answer`)) %>%
            filter(`Correct answer` != 'NA',
                   `Correct answer` != '()')
        out
    })
    
    output$answer_key_repeats_table <- DT::renderDataTable({
        the_code <- input$code
        the_answer_non_repeats <- answer_non_repeats %>% filter(hh_hamlet_code == the_code)
        answer_uuid <- the_answer_non_repeats$instanceID

        # Go through each repeat and get those correct answers too
        rep_list <- list()
        counter <- 0
        for(r in 1:length(repeat_names)){
            print(r)
            this_repeat_name <- repeat_names[r]
            this_answer <- answer_repeats[[this_repeat_name]] %>% filter(instanceID == answer_uuid)
            this_answer <- this_answer[,!names(this_answer) %in% dont_evaluate]
            for(x in 1:nrow(this_answer)){
                x_answer <- this_answer[x,]
                label_df <- tibble(name = names(x_answer)) %>% left_join(xf)
                outx <- tibble(
                               `Variable` = names(x_answer),
                               `Label (en)` = label_df$en,
                               `Label (sw)` = label_df$sw,
                               `Correct answer` = as.character(this_answer))
                counter <- counter + 1
                rep_list[[counter]] <- outx
            }
        }
        out <- bind_rows(rep_list)
        out <- out %>%
            filter(!Variable %in% dont_evaluate,
                   !is.na(`Correct answer`)) %>%
            filter(`Correct answer` != 'NA',
                   `Correct answer` != '()')
        out
    })
    
}
shinyApp(ui, server)#
