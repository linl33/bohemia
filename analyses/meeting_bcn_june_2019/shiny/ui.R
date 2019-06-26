dashboardPage(
  dashboardHeader(title = "Survey results"),
  dashboardSidebar(
    # selectInput("variable",
    #             "Variable",
    #             c("Joe's height" = 'height',
    #               "Joe's sleep last night" = 'sleep',
    #               "Joe's age" = 'age')),
    selectInput('by_variable',
                'Examine results by:',
                c('', "Participant age" = 'years',
                  "Participant sex" = 'sex',
                  "Participant GPS watch" = 'gps'))
  ),
  dashboardBody(
    fluidRow(
      valueBoxOutput('v1'),
      valueBoxOutput('v2'),
      valueBoxOutput('v3')),
    h3('Participant responses:'),
    fluidRow(box(plotOutput("p1", height = 250), width = 4),
             box(plotOutput("p3", height = 250), width = 4),
             box(plotOutput("p5", height = 250), width = 4)),
    h3('Effect of confounders:'),
    fluidRow(box(plotOutput("p2", height = 250), width = 4),
             box(plotOutput("p4", height = 250), width = 4),
             box(plotOutput("p6", height = 250), width = 4)),
    fluidRow(column(12, align = 'center', downloadButton("download_doc", "Download the paper!"))),
    fluidRow(textOutput('t1'))
  )
)

