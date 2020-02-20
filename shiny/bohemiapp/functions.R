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
    fluidPage(h3('Please log-in to view this page'))
  }
}

# Generate the log-in UI
make_log_in_ui <- function(li = FALSE){
  if(li){
    fluidPage(h3('This is the logged-in UI'),
              actionButton('log_out_button',
                           'Click here to log out',
                           icon = icon('wave')))
  } else {
    #UI if the user is not logged in
    fluidPage(h3('Log in to see cool stuff'),
              actionButton('log_in_button',
                           'Click here to log in',
                           icon = icon('door')))
  }
}

# Function for generating the about page
make_about <- function(){
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
}

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
