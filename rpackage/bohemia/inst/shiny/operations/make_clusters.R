source('global.R')

# Define the country
the_country <- 'Mozambique'
df <- geocodes %>% filter(Country == the_country)

gc_moz <- geocodes %>% filter(Country == 'Mozambique')
gc_moz$cluster <- 1:nrow(gc_moz)
# Define function to make two points per cluster (so as to tesselate)
double <- gc_moz %>%
  mutate(lat = lat + 0.0000001,
         lng = lng + 0.0000001)  
triple <- gc_moz %>%
  mutate(lat = lat - 0.00001,
         lng = lng - 0.00001)  
gc_moz <- bind_rows(gc_moz, double, triple) %>%
mutate(y = lat,
         x = lng) %>%
  filter(!is.na(y))



boundaries <- bohemia::create_borders(df = gc_moz)


gz_tza <- geocodes %>% filter(Country == 'Tanzania')

bohemia::create_clusters(cluster_size = 10,
                         sleep = 0)

fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.04)
