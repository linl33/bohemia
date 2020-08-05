source('global.R')

# Define the country
the_country <- 'Tanzania'

# Define whether we want to interpolate for missing animals
# and/or missing people
interpolate_animals <- TRUE
interpolate_humans <- TRUE

# Define the percentage of people which are children
p_children <- 30

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

# Clustering rules:
# humans: >= 35 children (<5 in moz, 5-15 in tza)
# distance: >= 1km around core (ie, 2km between cores)
# number of ttm groups: 3 (human-ivm, all-ivm, control)
# number of clusters per group: >48 per group
# Preferences:
# - no splitting of villages
# - experiment by different species