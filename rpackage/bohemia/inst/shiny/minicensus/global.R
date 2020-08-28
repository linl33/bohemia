
# get data from server
library(bohemia)
library(yaml)
library(reshape2)
library(tidyverse)

# read in creds
creds <- read_yaml('../../../../../credentials/credentials.yaml')

# GET TEST DATA
data <- odk_get_data(
  url = creds$databrew_odk_server,
  id = 'minicensus',
  id2 = NULL,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = NULL,
  user = creds$databrew_odk_user,
  password = creds$databrew_odk_pass
)

# ADD IN FAKE IDS
temp <- data[[2]]
temp$wid_manual <- c(111,222,333,444)
temp <- temp[,colSums(is.na(temp))<nrow(temp)]

# HERE MAKE SHORT LIST OF QUESTIONS TO MAKE SIMPLER
questions_list <- names(temp)[grepl('hh_|wid_manual', names(temp))]

# SUBSET DATA BY QUESTIONS 
temp <- temp[, questions_list]
temp <- as.data.frame(t(temp))

# ARBITRAILITY ASSIGN ONE COLUMNS AS KEY AND THE OTHER FAKE FW_IDS
names(temp) <- c('key', 'fw1', 'fw2', 'fw3')
temp$question <- rownames(temp)
rownames(temp) <- NULL
temp <- temp[, c('question', 'key', 'fw1', 'fw2', 'fw3')]
save.image('temp_data.RData')


# 
# 
# # temp <- melt(temp, id.vars = 'wid_manual')
# temp <- temp[-2,]
# temp_key <- temp[1,]
# temp <- temp[2:3,]
# 
# # compare data
# wid_names <- sort(unique(temp$wid_manual))
# i=1
# dat_list <- list()
# for(i in 1:length(unique(wid_names))){
#   this_name <- wid_names[i]
#   sub_form <- temp %>% filter(wid_manual == this_name)
#   test_form <- rbind(sub_form,temp_key)
#   test_form<-as.data.frame(t(test_form))
#   names(test_form) <- c('test', 'key')
#   test_form$question <- rownames(test_form)
#   test_form$test <- as.character(test_form$test)
#   test_form$key <- as.character(test_form$key)
#   
#   test_form$wrong <- test_form$test != test_form$key
#   test_form$wrong[is.na(test_form$wrong)] <- TRUE
#   dat_list[[i]] <- test_form
#   
# }
# 
# temp1 <- dat_list[[1]]
# names(temp1)[1] <- paste0('test_', wid_names[1])
# names(temp1)[4] <- paste0('wrong_', wid_names[1])
# names(temp2)[1] <- paste0('test_', wid_names[2])
# names(temp2)[4] <- paste0('wrong_', wid_names[2])
# 
# temp <- inner_join(temp1, temp2)
# temp <- temp[, c('question', 'key', 'test_333', 'wrong_333', 'test_444', 'wrong_444')]
# save.image('temp_data.RData')
# rm(creds,dat_list, data, sub_form, temp_key, test_form)
# # temp <- melt(temp, id.vars = 'question')
# 
# # PLACEHOLDER FOR GETTING FORM DATA
# 
# # PLACEHOLDER FOR GETTING ANSWER KEY DATA
# 
# 
# 
# 
