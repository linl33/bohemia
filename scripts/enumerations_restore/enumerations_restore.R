library(dplyr)
dumps <- dir('dumps')
dumps_df <- tibble(file = dumps,
                   letter = letters[1:length(dumps)])
# create databases manually
# create database a; create database b; etc
for(i in 1:nrow(dumps_df)){
  out <- paste0('psql -d ', dumps_df$letter[i], ' -f ', getwd(), '/dumps/', dumps_df$file[i])
  system(out)
}
library(RPostgres)
main_list <- a_list <- b_list <- list()
for(i in 1:nrow(dumps_df)){
  this_db <- dumps_df$letter[i]
  this_file <- dumps_df$file[i]
  con <- dbConnect(RPostgres::Postgres(), dbname = this_db)  
  # Get main
  this_query <- paste0('select * from aggregate."ENUMERATIONS_CORE"')
  out <- dbSendQuery(conn = con, statement = this_query)
  fetched <- dbFetch(out)
  fetched$file <- this_file
  
  # Get helpers
  this_query <- paste0('select * from aggregate."ENUMERATIONS_GROUP_CONSTRUCTION_CONSTRUCTION_MATERIAL"')
  out <- dbSendQuery(conn = con, statement = this_query)
  fetched_wall_a <- dbFetch(out)
  fetched_wall_a$file <- this_file
  
  this_query <- paste0('select * from aggregate."ENUMERATIONS_GROUP_CONSTRUCTION_WALL_MATERIAL"')
  out <- dbSendQuery(conn = con, statement = this_query)
  fetched_wall_b <- dbFetch(out)
  fetched_wall_b$file <- this_file
  
  main_list[[i]] <- fetched
  a_list[[i]] <- fetched_wall_a
  b_list[[i]] <- fetched_wall_b
  dbDisconnect(con)
}

main <- bind_rows(main_list)
wall_a <- bind_rows(a_list)
wall_b <- bind_rows(b_list)

# Keep only non-repeats
main <- main %>% dplyr::distinct(`_URI`, .keep_all = TRUE)
wall_a <- wall_a %>% dplyr::distinct(`_URI`, .keep_all = TRUE)
wall_b <- wall_b %>% dplyr::distinct(`_URI`, .keep_all = TRUE)

# Remove those from papu
main <- main %>% filter(!grepl('papu', GROUP_INQUIRY_DEVICE_ID))
wall_a <- wall_a %>% filter(`_PARENT_AURI` %in% main$`_URI`)
wall_b <- wall_b %>% filter(`_PARENT_AURI` %in% main$`_URI`)

# Wall a is roof
# Wall b is wall
# Change accordingly
roof <- wall_a
wall <- wall_b
rm(wall_a, wall_b)

# Now we have 3 dataframes of interest
# main, wall_a, wall_b

# Now, we go through and get the values from the wall / roof into the main dataframe
main$wall_material <- main$roof_material <- NA
for(i in 1:nrow(main)){
  this_main <- main[i,]
  this_uri <- this_main$`_URI`
  this_wall <- wall %>% filter(`_PARENT_AURI` == this_uri)
  this_roof <- roof %>% filter(`_PARENT_AURI` == this_uri)
  if(nrow(this_wall) > 0){
    wall_values <- paste0(this_wall$VALUE, collapse = ', ')
    main$wall_material[i] <- wall_values
  } 
  if(nrow(this_roof) > 0){
    roof_values <- paste0(this_roof$VALUE, collapse = ', ')
    main$roof_material[i] <- roof_values
  }
}

# Save
save(main, file = 'enumerations.RData')
