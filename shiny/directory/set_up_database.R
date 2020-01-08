library(dplyr)
library(readr)
library(RPostgreSQL)
library(readxl)

# # From within psql
# CREATE DATABASE directory;

# Read database credentials
source('credentials_connect.R')
source('credentials_extract.R')

# define whether creating locally or remotely 
local <- TRUE

# Get credentials
if(local){
  credentials <- credentials_extract(credentials_file = 'credentials/credentials_local.yaml', 
                                     all_in_file = TRUE)
} else {
  credentials <- credentials_extract(credentials_file = 'credentials/credentials.yaml', 
                                     all_in_file = TRUE)
}

# create a connection object with credentials
co <- credentials_connect(options_list = credentials)

# Read in the original source data
data <- read_excel("data/database.xlsx")
data$tags <- NA
data$contact_added = Sys.Date()
# Change names
names(data) <- c('first_name', 'last_name',
                 'position', 'institution', 'email', 'tags', 'contact_added')
data$tags <- 'ivermectin'
data$admin <- FALSE
data$password <- 'password'
admins <- tibble(first_name = c('Sònia', 'Mary', 'Carlos', 'Elena', 'Joe', 'Ben', 'John', 'Jane'),
                 last_name = c('Tomàs', 'Mael', 'Chaccour', 'Moreno', 'Brew', 'Brew', 'Doe', 'Doe'),
                 position = c('Project manager', 'Project assistant' , 'Assistant research professor', 'Projet manager', 'Data scientist', 'Data scientist', 'Fake person', 'Fake person'),
                 institution = c('ISGlobal', 'ISGlobal', 'ISGlobal', 'ISGlobal', 'DataBrew', 'DataBrew', 'Acme', 'Acme'),
                 email = c('sonia.tomas@isglobal.org', 'mary.mael@isglobal.org', 'carlos.chaccour@isglobal.org', 'elena.moreno@isglobal.org', 'joe@databrew.cc', 'ben@databrew.cc', 'john@mail.com', 'jane@mail.com'),
                 tags = 'ivermectin',
                 contact_added = Sys.Date(),
                 admin = c(rep(TRUE, 6), FALSE, TRUE),
                 password = 'password')

# Create tables
users <- data %>% bind_rows(admins)



# write to the table to the database to which we are connected
dbWriteTable(conn = co, 
             name = 'users', 
             value = users, 
             row.names = FALSE,
             overwrite = TRUE)

# disconnect from the db
dbDisconnect(co)
