library(tidyverse)
library(sp)
library(ggplot2)
library(ggthemes)
library(bohemia)
library(databrew)
library(RColorBrewer)
library(ggrepel)
library(broom)

make_map <- function(location = 'Rufiji',
  labels = T,
  label_size = 1,
  repel = T,
  level = 2){
  # location = 'Rufiji'
  # level = 2
  
  # Get the shapefile
  if(location == 'Rufiji'){
    if(level == 2){
      shp <- rufiji2
      shp_df <- broom::tidy(shp, region = "NAME_2")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$NAME_2)
    }
    if(level == 3){
      shp <- rufiji3
      shp_df <- broom::tidy(shp, region = "NAME_3")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$NAME_3)
    }
    
  }
  if(location == 'Mopeia'){
    if(level == 2){
      shp <- mopeia2
      shp_df <- broom::tidy(shp, region = "NAME_2")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$NAME_2)
    }
    if(level == 3){
      shp <- mopeia3
      shp_df <- broom::tidy(shp, region = "NAME_3")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$NAME_3)
    }
    if(level == 4){
      shp <- mopeia_villages
      shp_df <- broom::tidy(shp, region = "village")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$village)
    }
    if(level == 5){
      shp <- mopeia_hamlets
      # shp@data$id <- paste0(shp@data$administrative_post, ';', shp@data$locality, '; ', shp@data$village)
      shpa <- shp <- shp[!duplicated(shp@data$village),]
      shpa@data$id <- rownames(shpa@data)
      shpa.df     <- fortify(shpa)
      shp_df     <- left_join(shpa.df,shpa@data, by="id")
      coords <- coordinates(shp)
      label_df <- tibble(lng = coords[,1],
                         lat = coords[,2],
                         label = shp@data$village)
    }
  }
  g <- ggplot() +
    geom_polygon(data = shp_df,
                 aes(x = long,
                     y = lat,
                     group = group),
                 fill = NA,
                 color = 'black') +
    theme_map() +
    theme_simple() +
    labs(x = 'Longitude',
         y = 'Latitude',
         title = paste0(location, ', level ', level))
  if(labels){
    if(repel){
      g <- g +
        geom_polygon(data = shp_df,
                     aes(x = long,
                         y = lat,
                         group = group),
                     fill = NA,
                     color = 'black') +
        geom_point(data = label_df,
                   aes(x = lng,
                       y = lat,
                       color = label),
                   alpha = 0.7) +
        geom_text_repel(data = label_df,
                        aes(x = lng,
                            y = lat,
                            label = label,
                            color = label,
                            segment.color = label),
                        size = label_size,
                        segment.alpha = 0.8,
                        # color = 'darkred',
                        alpha = 0.8,
                        # segment.color = 'darkred',
                        force = 1,
                        min.segment.length = 0,
                        segment.size = 0.2,
                        mat.iter = 5000,
                        seed = 1) +
        theme(legend.position = 'none')
    } else {
      g <- g +
        geom_text(data = label_df,
                        aes(x = lng,
                            y = lat,
                            label = label),
                        size = label_size)
    }
    
  }
  g
}

dir.create('elena_maps')

print(make_map('Rufiji', level = 2, labels = F, label_size = 2))
ggsave('elena_maps/rufiji2.png')

print(make_map('Rufiji', level = 3, labels = T, label_size = 3, repel = F))
ggsave('elena_maps/rufiji3.png')


print(make_map('Mopeia', level = 2, labels = F, label_size = 2))
ggsave('elena_maps/mopeia2.png')

print(make_map('Mopeia', level = 3, labels = T, repel = F, label_size = 4))
ggsave('elena_maps/mopeia3.png')

print(make_map('Mopeia', level = 4, labels = T, repel = F, label_size = 4))
ggsave('elena_maps/mopeia4.png')

print(make_map('Mopeia', level = 5, labels = T, repel = T, label_size = 1))
ggsave('elena_maps/mopeia5.png')
