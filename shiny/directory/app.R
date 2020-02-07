source('global.R')

header <- dashboardHeader(title="Ivermectin directory")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Directory",
      tabName="directory",
      icon=icon("eye")),
    menuItem(
      text="Bulk Upload",
      tabName="upload",
      icon=icon("upload")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon"))
  )
)

body <- dashboardBody(
  shinyjs::useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  tabItems(
    tabItem(
      tabName="directory",
      fluidPage(
        fluidRow(h3('Instructions')),
        fluidRow(column(6,
                        p('Once you have selected people, click below to send them an email'), 
                        uiOutput('ui_send_email'),
                        uiOutput('ui_create_account')),
                 uiOutput('edit_text')),
        fluidRow(DT::dataTableOutput('edit_table'))
      )
    ),
    tabItem(
      tabName = 'upload',
      fluidPage(
        fluidRow(includeMarkdown('upload_instructions.md')),
        fluidRow(
          column(12, 
                 downloadButton('download_template',
                                'Download template spreadsheet for bulk upload', icon = icon('download')))
        ),
        fluidRow(includeMarkdown('upload_instructions2.md')),
        fluidRow(
          column(12, 
                 fileInput("file1", "Select a file for bulk upload",
                           multiple = FALSE,
                           accept = c(".xlsx"))),
          
        )
      ),
      fluidRow(
        uiOutput('bulk_ui')
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
                         users = users,
                         bulk_data = data.frame())
  log_in_text <- reactiveVal('')
  email_text <- reactiveVal('')
  email_people <- reactiveVal('')
  logged_in <- reactiveVal(value = FALSE)
  modal_text <- reactiveVal(value = '')
  is_admin <- reactiveVal(value = FALSE)
  
  
  # Observe the bulk upload and act accordingly
  observeEvent(input$file1, {
    inFile <- input$file1
    file.rename(inFile$datapath,
                paste(inFile$datapath, ".xlsx", sep=""))
    pd <- read_excel(paste(inFile$datapath, ".xlsx", sep=""), 1)
    data$bulk_data <- pd
  })
  
  # observe log in and get data from database
  observeEvent(input$submit, {
    this_user_data <- dbGetQuery(conn = co, 
                                 statement = paste0("SELECT * FROM users WHERE email='", input$user, "'"))
    data$user_data <- this_user_data
    is_admin(this_user_data$admin)
    addy <- is_admin()
    message('this user - ', this_user_data$email, ' - ',
            ifelse(addy, 'is an admin', 'is not an admin'))
    li <- logged_in()
    if(li){removeModal()}
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
    
    # Capture the log-in text
    lit <- mt <- log_in_text()
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
        h3(textInput('create_user', 'Email'),
           textInput('create_password', 'Create password'),
           textInput('create_first_name', 'First name'),
           textInput('create_last_name', 'Last name'),
           textInput('create_position', 'Position'),
           textInput('create_institution', 'Institution')
        ),
        fluidRow(
          column(6, align = 'left', p(lit)),
          column(6, align = 'right',
                 actionButton('submit_create_account',
                              'Add person'))
        )
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
    pp <- input$create_password
    if(is.null(pp)){
      pout <- 'password'
    } else {
      pout <- pp
    }
    x <- add_user(user = input$create_user,
                  password = pout,
                  first_name = input$create_first_name,
                  last_name = input$create_last_name,
                  position = input$create_position,
                  institution = input$create_institution,
                  users = data$users)
    if(x){
      y <- 'Account successfully created'
    } else {
      y <- paste0('Did not create an account because one already exists for ', input$create_user)
    }
    log_in_text(y)
    data$users <- get_users() %>% arrange(first_name)
  })
  
  output$edit_table <- DT::renderDataTable({
    li <- logged_in()
    addy <- is_admin()
    if(addy){
      eddy <- list(target = 'cell', disable = list(columns = c(5)))
    } else {
      eddy <- FALSE
    }
    if(li){
      message('capturing data$users...')
      df <- data$users
      df <- df %>% dplyr::select(first_name, last_name,
                                 position, institution, email,
                                 tags, contact_added)
      names(df) <- c('First', 'Last', 'Position', 'Institution',
                     'Emails', 'Tags', 'Contact added')
      df <- df %>% arrange(First)
      DT::datatable(df, editable = eddy)#,
      # colnames = c('First' = 'first_name',
      #              'Last' = 'last_name',
      #              'Position' = 'position', 
      #              'Institution' = 'institution',
      #              'Email' = 'email',
      #              'Tags' = 'tags'))
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
            "<a href=\"mailto:", et, "?subject=Bohemia\" target=\"_blank\">Click HERE to send email to the selected ", n_text, ".</a>")
        )
      }
    }
    return(out)
  })
  
  # Capture edits to data and store them
  proxy = dataTableProxy('edit_table')
  observeEvent(input$edit_table_cell_edit, {
    x <- data$users
    x <- x %>% arrange(first_name)
    info = input$edit_table_cell_edit
    i = info$row
    j = info$col
    v = info$value
    message('selected cell info:')
    message('--row: ', i)
    message('--column: ', j)
    message('--value: ', v)
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
    data$users <- x %>% arrange(first_name)
  })
  
  output$ui_create_account <- renderUI({
    
    addy <- is_admin()
    li <- logged_in()
    selected_rows <- input$edit_table_rows_selected
    any_selected <- length(selected_rows) > 0
    if(li & addy){
      if(any_selected){
        fluidPage(
          fluidRow(
            column(6,
                   actionButton('new_entry',
                                'Add new entry',icon = icon('face'))),
            column(6,
                   actionButton('delete_entry',
                                'Delete selected entries',icon = icon('face')))),
          br(),
          fluidRow(
            column(6,
                   actionButton('download',
                                'Download to excel', icon = icon('download'))),
            column(6,
                   actionButton('download_csv',
                                'Download Mailchimp CSV', icon = icon('download')))
          )
        )
      } else {
        fluidPage(
          fluidRow(
          column(12,
                 actionButton('new_entry',
                              'Add new entry',icon = icon('face')))),
          br(),
          fluidRow(
          column(4,
                 actionButton('download',
                              'Download to excel', icon = icon('download'))),
          column(4,
                 actionButton('download_csv',
                              'Download Mailchimp CSV', icon = icon('download')))
        ))
      }
      
    }
  })
  observeEvent(input$new_entry,{
    create_account(TRUE)
    log_in_text('')
    showModal(
      modalDialog(
        uiOutput('new_entry_ui'),
        easyClose = TRUE
      )
    )
  })
  
  
  
  output$new_entry_ui <- renderUI({
    lit <- log_in_text()
    fluidPage(
      h3(textInput('create_user', 'Email'),
         # textInput('create_password', 'Create password', value = 'password'),
         textInput('create_first_name', 'First name'),
         textInput('create_last_name', 'Last name'),
         textInput('create_position', 'Position'),
         textInput('create_institution', 'Institution')
      ),
      fluidRow(
        column(6, align = 'left', p(lit)),
        column(6, align = 'right',
               actionButton('submit_create_account',
                            'Create account'))
      )
    )
  })
  
  observeEvent(input$download,{
    showModal(
      modalDialog(
        uiOutput('download_ui'),
        easyClose = TRUE
      )
    )
  })
  
  observeEvent(input$download_csv,{
    showModal(
      modalDialog(
        uiOutput('download_csv_ui'),
        easyClose = TRUE
      )
    )
  })
  
  output$download_template <- 
    downloadHandler(
      filename = function() {
        paste("bulk_upload_template.xlsx", sep="")
      },
      content = function(file) {
        xlsx::write.xlsx(upload_csv, file, row.names = FALSE)
      }
    )
  
  output$download_ui <- renderUI({
    fluidPage(
      fluidRow(
        h4('Which data would you like to download?')
      ),
      fluidRow(
        selectInput('which_download', ' ',
                    choices = c('All data',
                                'Only selected rows'))
      ),
      fluidRow(
        downloadButton('download_confirm')
      )
    )
  })
  
  output$download_csv_ui <- renderUI({
    fluidPage(
      fluidRow(
        h4('Which data would you like to download?')
      ),
      fluidRow(
        selectInput('which_download_csv', ' ',
                    choices = c('All data',
                                'Only selected rows'))
      ),
      fluidRow(
        downloadButton('download_csv_confirm')
      )
    )
  })
  
  
  
  output$download_confirm <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file) {
      df <- data$users %>% arrange(first_name)
      df <- df %>% dplyr::select(email, first_name, last_name) %>%
        dplyr::rename(`First name` = first_name,
                      `Last name` = last_name,
                      `Email address` = email)
      if(input$which_download != 'All data'){
        selected_rows <- input$edit_table_rows_selected
        df <- df[selected_rows,]
        print(head(df))
      } 
      xlsx::write.xlsx(df, file, row.names = FALSE)
    }
  )
  
  output$download_csv_confirm <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      df <- data$users %>% arrange(first_name)
      df <- df %>% dplyr::select(email, first_name, last_name) %>%
        dplyr::rename(`First name` = first_name,
                      `Last name` = last_name,
                      `Email address` = email)
      if(input$which_download_csv != 'All data'){
        selected_rows <- input$edit_table_rows_selected
        df <- df[selected_rows,]
        print(head(df))
      } 
      readr::write_csv(df, file)
    }
  )
  
  
  # Capture the selected rows
  observeEvent(c(input$edit_table_rows_selected, is.null(input$edit_table_rows_selected)),{
    selected_rows <- input$edit_table_rows_selected
    message('selected rows are')
    print(selected_rows)
    # emails
    df <- data$users
    df <- df %>% arrange(first_name)
    df <- df[selected_rows,]
    emails <- sort(unique(df$email[!is.na(df$email)]))
    message('selected emails are')
    print(emails)
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
  
  
  # Bulk table output
  output$bulk_ui <- renderUI({
    pd <- data$bulk_data
    ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        ok <- TRUE
      }
    }
    if(ok){
      fluidPage(
        fluidRow(column(6,
                        p('Now inspect the below table. If everything looks okay, confirm the bulk upload by clicking the "Confirm bulk upload button"')),
                 column(6,
                        actionButton('confirm_bulk_upload', 'Confirm bulk upload', icon = icon('upload')))),
        verbatimTextOutput("text"),
        fluidRow(DT::dataTableOutput('bulk_table'))
      )
    } else {
      NULL
    }
  })
  
  output$bulk_table <- DT::renderDataTable({
    
    pd <- data$bulk_data
    ok <- FALSE
    if(!is.null(pd)){
      if(nrow(pd) > 0){
        pd
      }
    }
  })
  
  observeEvent(input$confirm_bulk_upload, {
    withCallingHandlers({
      shinyjs::html("text", "")
      
      # Loop through each person in the upload data and try to add to database
      pd <- data$bulk_data
      ok <- FALSE
      if(!is.null(pd)){
        if(nrow(pd) > 0){
          ok <- TRUE
        }
      }
      if(ok){
        pd <- pd %>% dplyr::distinct(Email, .keep_all = TRUE)
        message('Starting the bulk upload of ', nrow(pd), ' new people:')
        added <- rep(NA, nrow(pd))
        for(i in 1:nrow(pd)){
          added[i] <- add_user(user = pd$Email[i],
                   password = 'password', 
                   first_name = pd$`First name`[i], 
                   last_name = pd$`Last name`[i], 
                   position = pd$Position[i], 
                   institution = pd$Institution[i], 
                   users = data$users)
          Sys.sleep(0.2)
        }
        n_added <- length(which(added))
        n_not_added <- length(which(!added))
        message('Successfully added ', n_added, ' new entries to the database')
        if(n_not_added > 0){
          message('Did not add the following people to the database because there are already entries with their email addresses:')
          message(paste0('.....', pd$Email[!added], collapse = '\n'))
        }
        # Upload the in-session users data
        data$users <- get_users() %>% arrange(first_name)
      }
    },
    message = function(m) {
      shinyjs::html(id = "text", html = m$message, add = TRUE)
    })
  })
  
  observeEvent(input$delete_entry, {
    selected_rows <- input$edit_table_rows_selected
    df <- data$users
    df <- df %>% arrange(first_name)
    
    df <- df[selected_rows,]
    emails <- sort(unique(df$email[!is.na(df$email)]))
    showModal(modalDialog(
      title = 'Confirm deletion',
      fluidPage(
        paste0('Are you sure you want to delete the entries for ',
               paste0(emails, collapse = ', '), '?'),
        actionButton('sure', 'Yes', icon = icon('check'))
      )
    ))
  })
  observeEvent(input$sure,{
    selected_rows <- input$edit_table_rows_selected
    df <- data$users
    df <- df %>% arrange(first_name)
    
    df <- df[selected_rows,]
    emails <- sort(unique(df$email[!is.na(df$email)]))
    for(i in 1:length(emails)){
      this_email <- emails[i]
      message('Deleting entry for ', this_email)
      dbSendQuery(conn = co,
                  paste0("delete from users where email = '",
                         this_email, "'"))
    }
    
    # Update the in-memory data
    message('Updating the in-memory data$users object following deletion.')
    df <- data$users <- get_users() %>% arrange(first_name)
    removeModal()
  })
}
onStop(function() {
  message('Disconnecting from database')
  dbDisconnect(co)
})
shinyApp(ui, server)