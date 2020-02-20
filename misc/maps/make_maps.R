library(tidyverse)
library(bohemia)
library(sp)
library(ggrepel)
library(ggthemes)
library(databrew)
library(extrafont)
library(leaflet)
library(webshot)
# # install_github("wch/webshot")
library(htmltools)
# library(mapview)

# Get health facilities
hf <- bohemia::health_facilities

# Get polygon
shp <- shp_poly <- bohemia::ruf2
shp <- fortify(shp, group = 'GID_0')

# Keep only Tanzania
hf <- hf %>%
  filter(district == 'Rufiji')

# Plot
g <- ggplot() +
  geom_polygon(data = shp,
               aes(x = long,
                   y = lat,
                   group = group),
               color = 'white',
               fill = 'grey') +
  geom_point(data = hf,
             aes(x = lng,
                 y = lat),
             size = 0.6,
             alpha = 0.6) +
  coord_map() +
  databrew::theme_simple() +
  labs(x = 'Longitude',
       y = 'Latitude',
       title = 'Rufiji health facilities')
g
ggsave('outputs/rufiji_health_facilities.pdf')

# With names
g +
  geom_label_repel(data = hf,
                  aes(x = lng,
                      y = lat,
                      label = name),
                  size = 1.6,
                  box.padding = 0.05,
                  label.padding = 0.05,
                  alpha = 0.6)
ggsave('outputs/rufiji_health_facilities_with_names.pdf')

# Satellite
m <- leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addPolygons(data = shp_poly,
              # fillColor = NA,
              fillOpacity = 0,
              stroke = 0.2) %>%
  addCircleMarkers(data = hf,
                   fillOpacity = 1,
                   color = 'red',
                   radius = 1)
# mapshot(m, file = "~/Documents/bohemia/misc/maps/outputs/rufiji_health_facilities_satellite.png")
save_html(m, paste0(getwd(), "/outputs/temp.html"))
webshot(paste0(getwd(), "/outputs/temp.html"), 
        file = paste0(getwd(), '/outputs/rufiji_health_facilities_satellite.png'),
        cliprect = "viewport")

