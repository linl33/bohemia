source('global.R')

# # Clustering rules:
# humans: >= 35 children (<5 in moz, 5-15 in tza)
# distance: >= 1km around core (ie, 2km between cores)
# number of ttm groups: 3 (human-ivm, all-ivm, control)
# number of clusters per group: >48 per group
# Preferences:
# - no splitting of villages (assuming to mean "hamlets")
# - experiment by different species

# Define the country
the_country <- 'Tanzania'

# Define whether we want to interpolate for missing animals
# and/or missing people
interpolate_animals <- TRUE
interpolate_humans <- TRUE

# Define the percentage of people which are children
p_children <- 30

# Define the human sufficiency rule
human_sufficiency_rule <- 'n_children >= 35'
animal_sufficiency_rule <- 'n_animals >= 35'

# Get the locations
left <- geocodes %>% filter(Country == the_country) %>%
  filter(!duplicated(code)) %>%
  dplyr::select(code, lng, lat)
# Get the animal info
right <- animal %>% filter(Country == the_country) %>%
  filter(!duplicated(hamlet_code)) %>%
  mutate(code = hamlet_code) %>%
  dplyr::select(code,
                contains('n_'))
# Join locations and animal info
joined <- left_join(left, right)
# Get the number of residents info
right <- recon_data %>% filter(Country == the_country) %>%
  filter(!duplicated(hamlet_code)) %>%
  mutate(code = hamlet_code) %>%
  dplyr::select(code,
                n_households = number_hh)
# Join all info
df <- left_join(joined, right)
message(nrow(df), ' locations. Removing those without geocoding reduces to:')
df <- df %>% filter(!is.na(lng), !is.na(lat))
message(nrow(df), ' locations.')

# Recode categorical variables so as to get approximate numbers
recodify <- function(x){
  x <- as.character(x)
  x <- ifelse(x == '0', 0,
              ifelse(x == '1 to 5', 3,
                     ifelse(x == '6 to 19', 12,
                            ifelse(x == '20 or more', 30, NA))))
  return(x)
}
n_names <- c('n_cattle', 'n_goats', 'n_pigs')
for(j in 1:length(n_names)){
  this_column <- n_names[j]
  df[,this_column] <- recodify(as.character(unlist(df[,this_column])))
}

# Carry out interpolations
if(interpolate_humans){
  missing_humans <- which(is.na(df$n_households))
  message('Going to inerpolate for ', length(missing_humans), ' hamlets with missing number of households')
  if(length(missing_humans) > 0){
    for(i in missing_humans){
      this_row <- missing_humans[i]
      df$n_households[i] <- sample(df$n_households[!is.na(df$n_households)],
                                   1)
    }
  }
}
if(interpolate_animals){
  animal_vars <- c('n_cattle', 'n_goats', 'n_pigs')
  for(j in 1:length(animal_vars)){
    animal_var <- animal_vars[j]
    animal_name <- gsub('n_', '', animal_var)
    missing_animals <- which(is.na(unlist(df[,animal_var])))
    message('Going to inerpolate for ', length(missing_animals), ' hamlets with missing ', animal_name)
    if(length(missing_animals) > 0){
      for(i in missing_animals){
        this_row <- missing_animals[i]
        good_animals <- as.numeric(unlist(df[,animal_var]))
        good_animals <- good_animals[!is.na(good_animals)]
        df[i, animal_var] <- sample(good_animals, 1)
      }
    }
  }
}
# Remove any data with missing animals or humans
df <- df %>%
  filter(!is.na(n_households),
         !is.na(n_cattle),
         !is.na(n_pigs),
         !is.na(n_goats))

# Define a n_children variable
df$n_children <- df$n_households * (0.01 * p_children)
# Define an animal variable
df$n_animals <- df$n_cattle + df$n_goats + df$n_pigs

# Create a space for indicating whether the hamlet
# has already been assigned to a cluster or not
df$assigned <- FALSE

# Spatial section ######################################
library(dplyr)
library(sp)
library(geosphere)

# Create a spatial version of df
df_sp <- df
coordinates(df_sp) <- ~lng+lat
proj4string(df_sp) <- CRS("+init=epsg:4326") # define as lat/lng

zone <- 36

new_proj <- CRS(paste0("+proj=utm +zone=", 
           zone, 
           " +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
df_sp <- spTransform(df_sp, new_proj)

# Get a distance matrix between all points
distance_matrix <- rgeos::gDistance(spgeom1 = df_sp, byid = TRUE)

# Add a perimeter around each hamlet (guessing based on population)
buffers <- rgeos::gBuffer(df_sp, byid = TRUE, width = 1000)
# Get in lat/lng
buffers_ll <- spTransform(buffers, proj4string(ruf2))

# Start at the point which is furthest (on average) to all others
median_distances <- apply(distance_matrix, 1, median, na.rm = TRUE)
start_here <- which.min(median_distances)[1]
this_hamlet <- df[start_here,]
sufficiency_rule <- paste0(animal_sufficiency_rule, ' & ',
                           human_sufficiency_rule)
suffiency_text <- paste0(
  "this_hamlet <- this_hamlet %>%
  dplyr::mutate(is_sufficient = ", sufficiency_rule, ")"
)
eval(parse(text = suffiency_text))
is_sufficient <- this_hamlet$is_sufficient
# Get nearest

done <- FALSE
while(!done){
  
}