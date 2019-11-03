source('global.R')

header <- dashboardHeader(title="Ivermectin directory")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Directory",
      tabName="directory",
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
      tabName="directory",
      fluidPage(
        fluidRow(h3('Instructions')),
        fluidRow(column(6,
                        p('Once you have selected people, click below to send htem an email'), 
                        uiOutput('ui_send_email')),
                 uiOutput('edit_text')),
        fluidRow(DT::dataTableOutput('edit_table'))
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        fluidRow(
          div(img(src='logo_clear.png', align = "center"), style="text-align: center;"),
          h4('Hosted by ',
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
server <- function(input, output, session) {
  
  # Reactive values
  data <- reactiveValues(user_data = data.frame(),
                         users = users)
  log_in_text <- reactiveVal('')
  email_text <- reactiveVal('')
  email_people <- reactiveVal('')
  logged_in <- reactiveVal(value = FALSE)
  modal_text <- reactiveVal(value = '')
  is_admin <- reactiveVal(value = FALSE)
  
  # observe log in and get data from database
  observeEvent(input$submit, {
    this_user_data <- dbGetQuery(conn = co, 
                                 statement = paste0("SELECT * FROM users WHERE email='", input$user, "'"))
    data$user_data <- this_user_data
    is_admin(this_user_data$admin)
    addy <- is_admin()
    message('this user - ', this_user_data$email, ' - ',
            ifelse(addy, 'is an admin', 'is not an admin'))
  })
  
  # Log in modal
  showModal(
    modalDialog(
      uiOutput('modal_ui'),
      footer = NULL
    )
  )
  
  
  # See if log-in worked
  observeEvent(input$submit, {
    cp <- check_password(user = input$user,
                         password = input$password,
                         the_users = data$users)
    logged_in(cp)
    message('cp is ', cp)
    if(cp){
      lit <- 'Successful log-in'
    } else {
      lit <- 'That user/password combination does not exist'
    }
    log_in_text(lit)
  })
  
  # When OK button is pressed, attempt to log-in. If success,
  # remove modal.
  observeEvent(input$submit, {
    # Did login work?
    li <- logged_in()
    lit <- log_in_text()
    if(li){
      # Update the reactive modal_text
      modal_text(paste0('Logged in as ', input$user))
      removeModal()
    } else {
      # Update the reactive modal_text
      modal_text(lit)
    }
  })
  
  # Make a switcher between the log in vs. create account menus
  create_account <- reactiveVal(FALSE)
  observeEvent(input$create_account,{
    currently <- create_account()
    nowly <- !currently
    create_account(nowly)
  })
  observeEvent(input$submit_create_account,{
    currently <- create_account()
    nowly <- !currently
    create_account(nowly)
  })
  observeEvent(input$back,{
    currently <- create_account()
    nowly <- !currently
    create_account(nowly)
  })
  
  output$modal_ui <- renderUI({
    
    # Capture the modal text.
    mt <- modal_text()
    # See if we're in account creation vs log in mode
    account_creation <- create_account()
    if(account_creation){
      fluidPage(
        fluidRow(
          column(12,
                 align = 'right',
                 actionButton('back',
                              'Back'))
        ),
        h3(textInput('create_user', 'Create username'),
           textInput('create_password', 'Create password')),
        fluidRow(
          column(12, align = 'right',
                 actionButton('submit_create_account',
                              'Create account'))
        ),
        fluidRow(recaptcha_ui("test", language = 'en', sitekey = captcha$site_key))
      )
    } else {
      fluidPage(
        h3(textInput('user', 'Username',
                     value = 'joe@databrew.cc'),
           passwordInput('password', 'Password', value = 'password')),
        fluidRow(
          column(6,
                 actionButton('submit',
                              'Submit')),
          column(6, align = 'right',
                 actionButton('create_account',
                              'Create account'))
        ),
        p(mt)
      )}
  })
  
  # Observe account creation
  observeEvent(input$submit_create_account,{
    add_user(user = input$create_user,
             password = input$create_password)
  })
  
  output$edit_table <- DT::renderDataTable({
    li <- logged_in()
    if(li){
      df <- data$users
      df <- df %>% dplyr::select(first_name, last_name,
                                 position, institution, email,
                                 tags, id)
      addy <- is_admin()
      DT::datatable(df, editable = ifelse(addy, 'row', FALSE),
                    colnames = c('First' = 'first_name',
                                 'Last' = 'last_name',
                                 'Position' = 'position', 
                                 'Institution' = 'institution',
                                 'Email' = 'email',
                                 'Tags' = 'tags'))
    } else {
      NULL
    }
  })
  
  output$ui_send_email <- renderUI({
    et <- email_text()
    n <- length(email_people())
    n_text <- ifelse(n == 1, '1 person',
                     paste0(n, ' people', collapse = ''))
    out <- NULL
    if(!is.na(et)){
      if(et != ''){
        out <- fluidPage(
          HTML(
            "<a href=\"mailto:", et, "?subject=Bohemia\">Click HERE to send email to the selected ", n_text, ".</a>")
        )
      }
    }
    return(out)
  })
  
  # Capture edits to data and store them
  proxy = dataTableProxy('edit_table')
  observeEvent(input$edit_table_cell_edit, {
    x <- data$users
    info = input$edit_table_cell_edit
    i = info$row
    j = info$col
    v = info$value
    old_vals <- x[i,]
    id <- x$id[i]
    x[i, j] <- DT::coerceValue(v, x[i, j])
    replaceData(proxy, x, resetPaging = FALSE, rownames = FALSE)
    # Overwrite the database too
    old_email <- old_vals$email
    message('Deleting old row')
    dbSendQuery(conn = co,
                paste0("delete from users where email = '",
                       old_email, "'"))
    message('Replacing with updated row')
    dbWriteTable(conn = co, 
                 name = 'users', 
                 value = x[i,], 
                 row.names = FALSE,
                 overwrite = FALSE,
                 append = TRUE)
    # Update the in-memory object
    data$users <- x
  })
  
  # Capture the selected rows
  observeEvent(input$edit_table_rows_selected,{
    selected_rows <- input$edit_table_rows_selected
    message('selected rows are')
    print(selected_rows)
    # emails
    df <- data$users
    df <- df[selected_rows,]
    emails <- sort(unique(df$email[!is.na(df$email)]))
    email_people(emails)
    email_text(paste0(emails, collapse = ', '))
  })
  
  output$edit_text <- renderUI({
    addy <- is_admin()
    if(addy){
      column(6,
             p('Hold ctrl + click to select people. Double click a cell to edit it.'),
             p('Type any name, institution, "tag", etc. to filter people.'))
    } else {
      column(6,
             p('Hold ctrl + click to select people.'),
             p('Type any name, institution, "tag", etc. to filter people.'))
    }
  })
}
onStop(function() {
  message('Disconnecting from database')
  dbDisconnect(co)
})
shinyApp(ui, server)