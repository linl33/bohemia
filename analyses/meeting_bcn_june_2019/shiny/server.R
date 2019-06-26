
library(shiny)
library(googlesheets)
library(ggplot2)
library(dplyr)

fake_data <- FALSE

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$t1 <- renderText({
    if(fake_data){
      return('Using fake data')
    } else {
      collect_date <- max(df$date, na.rm = TRUE)
      return(paste0('Using data collected through ', dplyr::last(df$timestamp)))
    }
  })
  
  output$p1 <- renderPlot({
    # plot_variable(input$variable)
    plot_variable('km_rufiji')
  })
  
  output$p2 <- renderPlot({
    # plot_variable_by(input$variable,
    #                  input$by_variable)
    plot_variable_by('km_rufiji',
                     input$by_variable)
  })
  output$p3 <- renderPlot({
    plot_variable('km_mopeia')
  })
  
  output$p4 <- renderPlot({
    plot_variable_by('km_mopeia',
                     input$by_variable)
  })

  output$p5 <- renderPlot({
    plot_variable('years')
  })
  
  output$p6 <- renderPlot({
    plot_variable_by('years',
                     input$by_variable)
  })
  
  
  output$v1 <- renderValueBox({
    valueBox(value = nrow(df),
             subtitle = 'Participants',
             icon = icon("cog", lib = "glyphicon"),
             color = 'light-blue')
  })
  output$v2 <- renderValueBox({
    valueBox(value = round(mean(df$years, na.rm = TRUE), digits = 1),
             subtitle = 'Average age of participants',
             icon = icon('table'),
             color = 'red')
  })
  output$v3 <- renderValueBox({
    valueBox(value = round(length(which(df$sex == 'Female')) / nrow(df) * 100, digits = 1),
             subtitle = '% female',
             icon = icon('calendar'),
             color = 'orange')
  })
  
  output$download_doc <-
    downloadHandler(filename = "paper.pdf",
                    content = function(file){
                      
                      # generate html
                      rmarkdown::render('paper.Rmd',
                                        params = list(df = df))
                      
                      # copy html to 'file'
                      file.copy("paper.pdf", file)
                      
                      # # delete folder with plots
                      # unlink("figure", recursive = TRUE)
                    },
                    contentType = "application/pdf"
    )
  
})
