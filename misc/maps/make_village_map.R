library(tidyverse)
library(sp)
library(ggplot2)
library(ggthemes)
library(bohemia)
library(databrew)
library(RColorBrewer)
library(ggrepel)

# Get Mopeia locations
mhd <- mopeia_hamlet_details
mh <- mopeia_hamlets

label_data <- mh@data
coords <- coordinates(mh)
label_data$lng <- coords[,1]
label_data$lat <- coords[,2]

cols <- colorRampPalette(brewer.pal(n = 9, name = 'Spectral'))(nrow(mh))
cols <- sample(cols, length(cols))
ggplot() +
  geom_polygon(data = mh,
               aes(x = long,
                   y = lat,
                   group = id,
                   fill = id),
               # color = 'black',
               # size = 0.1,
               alpha = 0.6) +
  theme_map() +
  theme_simple() +
  scale_fill_manual(name = '', values = cols) +
  theme(legend.position = 'none') +
  labs(x = 'Longitude',
       y = 'Latitude',
       title = 'Bairros de Mopeia',
       subtitle = '(estimado a partir da localização das casas no projeto de custo)') +
  geom_text(data = label_data,
                  aes(x = lng,
                      y = lat,
                      label = village),
                  size = 1,
                  alpha = 0.5)
ggsave('~/Desktop/mopeia.png')
