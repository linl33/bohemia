library(shiny)
library(ggplot2)
library(mapview)

traccar_transform <- function(x){
  out <- x %>%
    mutate(y = valid) %>%
    mutate(date = as.Date(substr(devicetime, 1, 10)),
           battery = unlist(lapply(strsplit(y, split = ":"), function(z){as.numeric(gsub(' distance', '', z[2]))})),
           distance = unlist(lapply(strsplit(y, split = ":"), function(z){as.numeric(gsub(' totalDistance', '', z[3]))})),
           total_distance = unlist(lapply(strsplit(y, split = ":"), function(z){as.numeric(gsub(' motion', '', z[4]))}))) %>%
    dplyr::select(id, deviceid, devicetime, latitude, longitude,
                  unique_id, date, battery, distance, total_distance)
  return(out)
}

traccar_simplify <- function(y){
  out <- y %>%
    arrange(devicetime) %>%
    group_by(unique_id) %>%
    filter(devicetime == max(devicetime)) %>%
    mutate(total_distance = total_distance / 1000)
    dplyr::select(unique_id,
                  `Last ping` = devicetime,
                  `Last battery` = battery,
                  `Total KM` = total_distance)
  return(out)
}

traccar_summarise <- function(y, fids){
  out <- y %>%
    arrange(devicetime) %>%
    mutate(bohemia_id = as.numeric(as.character(unique_id))) %>%
    left_join(fids %>% dplyr::select(bohemia_id, 
                                     first_name, 
                                     last_name,
                                     Role)) %>%
    mutate(Fieldworker = paste0(bohemia_id, ' ',
                                first_name, ' ',
                                last_name, ' (',
                                Role, ')')) %>%
    group_by(Fieldworker) %>%
    summarise(`First ping` = min(devicetime),
              `Last ping` = max(devicetime),
              `Pings` = n(),
              # `Total KM` = max(total_distance/1000),
              `KM in period` = max(total_distance/1000) -
                min(total_distance/1000),
              `Days with any ping` = length(unique(date)))
  return(out)
}


points_to_line <- function(data, group = "day"){
  data <- data %>% 
    group_by_at(group) %>%
    summarise(do_union = FALSE) %>%
    st_cast("LINESTRING") %>%
    ungroup 
  return(data)
}

points_to_line2 <- function(data){
  
  out <- data %>%
    mutate(time_since = as.numeric(lubridate::as.difftime(devicetime - dplyr::lag(devicetime, 1), units = 'seconds'))) %>%
    mutate(same_day = day == dplyr::lag(day, 1)) %>%
    mutate(same_id = unique_id == dplyr::lag(unique_id, 1)) %>%
    mutate(grp_helper = ifelse(time_since >500 | !same_day | !same_id, 1, 0)) %>%
    mutate(grp_helper = ifelse(is.na(grp_helper), 1, grp_helper)) %>%
    mutate(grp = cumsum(grp_helper))
    
  
  group = 'grp'
  out <- out %>% 
    group_by_at(group) %>%
    summarise(do_union = FALSE) %>%
    st_cast("LINESTRING") %>%
    ungroup 
  return(out)
}

# Basic placeholder function
placeholder <- function(li = FALSE,
                        ac = FALSE){
  if(li){
    fluidPage(h3('This is the logged-in UI'))
  } else {
    #UI if the user is not logged in
    fluidPage(h3('This is the logged-out UI'))
  }
}


# Function to conditionally handle UI generation based on (a) logged-in status and (b) access level
make_ui <- function(li = FALSE,
                    ac = FALSE,
                    ok = fluidPage()){
  if(li){
    if(ac){
      ok
    } else {
      h3('You do not have not been authorized to view this page. If you require access, please email info@databrew.cc.')
    }
  } else {
    fluidPage(h3('Please log-in to view this page'),
              p('To log-in, click the button in the upper right corner.'))
  }
}

# Define function for checking whether logged in, etc.

# Generate the log-in UI
make_log_in_button <- function(li = FALSE){
  if(li){
    actionButton('log_out_button',
                           'Log out',
                           icon = icon('wave'))
  } else {
    actionButton('log_in_button',
                           'Click here to log in',
                           icon = icon('door'))
  }
}

# Log in modal
make_log_in_modal <- function(info_text = NULL){
  showModal(modalDialog(
    title = NULL,
    easyClose = TRUE,
    footer = NULL,
    fade = TRUE,
    fluidPage(
      fluidRow(column(12,
                      align = 'center',
                      h2('Log-in'))),
      fluidRow(column(6,
                      textInput('log_in_user',
                                'Email',
                                placeholder = 'info@databrew.cc')),
               column(6,
                      passwordInput('log_in_password',
                                    'Password',
                                    placeholder = 'password'))),
      fluidRow(column(12, align = 'center',
                      actionButton('confirm_log_in',
                                   'Log in'))),
      fluidRow(column(12, align = 'center',
                      p(info_text))),
      fluidRow(column(12, align = 'center',
                      p('If you are an authorized project collaborator and do not have log-in credentials, please email bohemia@databrew.cc.')))
    )
  ))
}

# Check credentials
credentials_check <- function(user = NULL,
                              password = NULL,
                              users = NULL){
  checks_out <- FALSE
  if(user %in% names(users)){
    correct_password <- users[names(users) == user]
    if(password == correct_password){
      checks_out <- TRUE
    }
  }
  return(checks_out)
}

na_to_zero <- function(x){ifelse(is.na(x), 0, x)}


# Function for generating the about page
make_about <- function(){
  fluidPage(
    fluidRow(
      div(img(src='www/logo.png', align = "center"), style="text-align: center;"),
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
}

# Plot theme
theme_bohemia <- ggplot2::theme_bw

# Function for extracting lng and lat from a odk geocode object
extract_ll <- function(x){
  lngs <- lats <- c()
  for(i in 1:length(x)){
    y <- x[i]
    lat <- unlist(lapply(strsplit(y[1], ' '), function(z){z[1]}))
    lng <- unlist(lapply(strsplit(y[1], ' '), function(z){z[2]}))
    lngs[i] <- lng; lats[i] <- lat
  }
  
  lng <- as.numeric(lngs); lat <- as.numeric(lats)
  return(tibble(lng = lng, lat = lat))
}
# extract_ll <- Vectorize(extract_ll)

# Function for generating a fake / placeholder map 
fake_map <- function(tile = 'Stamen.Watercolor',
                     poly = bohemia::rufiji3,
                     with_points = 1000,
                     with_polys = TRUE){
  # Basic map
  l <- leaflet() %>%
    addProviderTiles(tile) %>%
    addPolygons(data = poly, 
                fillOpacity = 0,
                stroke = TRUE,
                color = 'white',
                weight = 1)
  
  # Add polys
  if(with_polys){
    cols <- colorRampPalette(RColorBrewer::brewer.pal(n = 9, name = 'Spectral'))(nrow(poly@data))
    l <- l %>%
      addPolygons(data = poly,
                  fillOpacity = 0.6,
                  fillColor = cols,
                  stroke = TRUE,
                  color = 'black',
                  weight = 1)
  }
  
  # Add points
  if(with_points > 0){
    coords <- coordinates(poly)
    fake_points <- data.frame(lng = rep(coords[,1], each = with_points),
                              lat = rep(coords[,2], each = with_points),
                              id = 1:(nrow(coords) * with_points))
    fake_points$lng <- jitter(fake_points$lng, factor = 1000)
    fake_points$lat <- jitter(fake_points$lat, factor = 1000)
    fake_points <- fake_points  %>%
      mutate(x = lng, y = lat)
    coordinates(fake_points) <- ~x+y
    proj4string(fake_points) <- proj4string(poly)
    # Keep only those in the area
    keep <- !is.na(over(fake_points, polygons(poly)))
    fake_points <- fake_points[keep,]
    # Keep only those needed
    fake_points <- data.frame(fake_points)
    fake_points <- fake_points %>% dplyr::sample_n(nrow(fake_points))
    fake_points <- fake_points[1:with_points,]
    l <- l %>%
      addCircleMarkers(data = fake_points,
                       lng = fake_points$lng,
                       lat = fake_points$lat,
                       fillOpacity = 1,
                       radius = 3,
                       fillColor = 'red',
                       stroke = FALSE)
  }
  return(l)
}

# ui_main <- fluidPage(
#   fluidRow(column(12, align = 'center',
#                   h1('BohemiApp'))),
#   fluidRow(column(12, align = 'center',
#                   h3('The Bohemia Data Portal'))),
#   fluidRow(column(12, align = 'center')),
#   fluidRow(column(12, align = 'center',
#                   plotOutput('main_plot'))),
# )

# Filter locations
# Define function for filtering locations based on inputs
filter_locations <- function(locations,
                             country = NULL,
                             region = NULL,
                             district = NULL,
                             ward = NULL,
                             village = NULL,
                             hamlet = NULL){
  out <- locations
  

  if(!is.null(country)){
    if(!country %in% c('', 'All')){
      out <- out %>% filter(Country %in% country) 
    }
  }
  if(!is.null(region)){
    if(!region %in% c('', 'All')){
      out <- out %>% filter(Region %in% region)
    }
  }
  if(!is.null(district)){
    if(!district %in% c('', 'All')){
      out <- out %>% filter(District %in% district)
    }
  }
  if(!is.null(ward)){
    if(!ward %in% c('', 'All')){
      out <- out %>% filter(Ward %in% ward) 
    }
  }
  if(!is.null(village)){
    if(!village %in% c('', 'All')){
      out <- out %>% filter(Village %in% village)
    }
  }
  if(!is.null(hamlet)){
    if(!hamlet %in% c('', 'All')){
      out <- out %>% filter(Hamlet %in% hamlet) 
    }
  }
  return(out)
}

# Fake data retrieval function
fake_data <- function(){
  if(!'fake_data.RData' %in% dir('/tmp')){
    require(yaml)
    is_aws <- grepl('aws', tolower(Sys.info()['release']))
    if(is_aws){
      credentials_file <- 'credentials/credentials.yaml'
    } else {
      credentials_file = '../../../credentials/credentials.yaml'
    }
    creds <- yaml::yaml.load_file(credentials_file)
    url <- 'https://bohemia.systems'
    id = 'minicensus'
    id2 = NULL
    user = creds$databrew_odk_user
    password = creds$databrew_odk_pass
    data <- odk_get_data(
      url = url,
      id = id,
      id2 = id2,
      unknown_id2 = FALSE,
      uuids = NULL,
      exclude_uuids = NULL,
      user = user,
      password = password
    )
    save(data, file = '/tmp/fake_data.RData')
    return(data)
  } else {
    load('/tmp/fake_data.RData')
    return(data)
  }
}

# Get database connection
get_db_connection <- function(local = FALSE){
  creds <- yaml::yaml.load_file('credentials/credentials.yaml')
  users <- yaml::yaml.load_file('credentials/users.yaml')
  drv <- RPostgres::Postgres()
  
  if(local){
    con <- dbConnect(drv, dbname = 'bohemia')
  } else {
    psql_end_point = creds$endpoint
    psql_user = creds$psql_master_username
    psql_pass = creds$psql_master_password
    con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                     port=5432,
                     user=psql_user, password=psql_pass)
  }

  return(con)
}
