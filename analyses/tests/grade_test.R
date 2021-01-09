
library(tidyverse)

# notes
# two rows where no id is given
# there is one "DIM" instead of "DIN"
# just because they may have gotten one wrong, might not be very consequential
# attache test_results.csv with pdf

# create a list of questions 
# create a list of columns thrown out

# Scenario 1:
## Hamlet: Mparange
## Code: MPR
# Scenario 2:
## Hamlet:  Dimani B
## Code: DIN

# read in test questions and answeres (wid 108 is answer key for two scenarios)
dat <- read.csv('test_key.csv', na.strings=c("","NA"))

# remove all columns where both entries in the answerkey (wid 108) are NA
na_index <- which(!apply(dat %>% filter(group_intro.wid_manual == '108'), 2, function(x) all(is.na(x)) ))
dat <- dat[, na_index]

# recode the once instance where group_location.hh_hamlet_code_list is DIM instead of DIN
dat$group_location.hh_hamlet_code <- as.character(dat$group_location.hh_hamlet_code)
dat$group_location.hh_hamlet_code <- ifelse(dat$group_location.hh_hamlet_code =='DIM', 'DIN',dat$group_location.hh_hamlet_code)

# where wid is NA, put None
dat$group_intro.wid <- ifelse(is.na(dat$group_intro.wid), 'None', dat$group_intro.wid)
dat$group_intro.wid_manual <- ifelse(is.na(dat$group_intro.wid_manual), 'None', dat$group_intro.wid_manual)

dat$group_intro.wid[dat$group_intro.wid=='None'][1] <- 'Unknown 1'


# get answer key for each scneario 
qa_key_mpr <- dat %>% filter(group_location.hh_hamlet_code_list=='MPR')
qa_key_din <- dat %>% filter(group_location.hh_hamlet_code_list=='DIN')

sort(summary(as.factor(dat$group_intro.wid_manual)))

# create a question/answer only dataframe by removing non question answers
not_questions <- c('group_intro.device_id', 'group_intro.start_time', 'group_intro.end_time', 'group_intro.todays_date', 'group_intro.wid_manual', 'group_location.hh_country', 'group_location.hh_region','group_location.hh_district', 'group_location.hh_ward', 'group_location.hh_village', 'group_location.hh_hamlet', 'group_location.hh_other_location', 'group_location.hh_hamlet_code_list', 'group_foto.hh_photograph', 'repeat_household_members_enumeration', 'group_geocode.hh_geo_location.Latitude',	'group_geocode.hh_geo_location.Longitude', 'group_geocode.hh_geo_location.Altitude', 'group_geocode.hh_geo_location.Accuracy', 'group_hh_sub.repeat_hh_sub', 'meta.instanceID', 'meta.instanceName')

qa_key_mpr <- qa_key_mpr[, !names(qa_key_mpr) %in% not_questions]
qa_key_din <- qa_key_din[, !names(qa_key_din) %in% not_questions]


# get a dataframe of questions and answerkey only
qa_key_mpr <- qa_key_mpr %>%filter(group_intro.wid=='108')%>%select(group_location.hh_have_paint_house:group_contact_info.hh_contact_info_number_alternate) 
qa_key_din <- qa_key_din %>%filter(group_intro.wid=='108')%>%select(group_location.hh_have_paint_house:group_contact_info.hh_contact_info_number_alternate) 

# make long
qa_key_mpr <- as.data.frame(t(qa_key_mpr), stringsAsFactors = FALSE)
qa_key_mpr$question <- row.names(qa_key_mpr)
row.names(qa_key_mpr) <- NULL
names(qa_key_mpr)[1] <- 'Real answer'

qa_key_din <- as.data.frame(t(qa_key_din), stringsAsFactors = FALSE)
qa_key_din$question <- row.names(qa_key_din)
row.names(qa_key_din) <- NULL
names(qa_key_din)[1] <- 'Real answer'

# trim white space if any
qa_key_mpr$`Real answer` <- trimws(qa_key_mpr$`Real answer`, which = 'both')
qa_key_mpr$question <- trimws(qa_key_mpr$question, which = 'both')

qa_key_din$`Real answer` <- trimws(qa_key_din$`Real answer`, which = 'both')
qa_key_din$question <- trimws(qa_key_din$question, which = 'both')


# create list to store data frame with all questions answeres and correct answers
qa_mpr <- list()
qa_din <- list()

table_list <- list()

# loop through each FW and get scores and other info for each one 
wid_code <- as.character(sort(unique(dat$group_intro.wid), na.last = TRUE))
wid_code <- wid_code[wid_code!='108']
for(i in 1:length(wid_code)){
  this_wid <- wid_code[i]
  sub_dat <- dat %>% filter(group_intro.wid ==this_wid)
  if(this_wid=='None'){
    this_wid = 'Unknown 2'
  }
  if(nrow(sub_dat)==1){
    if(sub_dat$group_location.hh_hamlet_code_list=='DIN'){
      sub_din <- sub_dat[sub_dat$group_location.hh_hamlet_code=='DIN',]
      sub_din <- as.data.frame(t(sub_din), stringsAsFactors = FALSE)
      sub_din$question <- row.names(sub_din)
      row.names(sub_din) <- NULL
      names(sub_din)[1] <- 'FW answer'
      # left join with answer keys 
      sub_din <- left_join(sub_din, qa_key_din, by = 'question')
      sub_din$`FW answer` <- trimws(sub_din$`FW answer`, which = 'both')
      sub_din$question <- trimws(sub_din$question, which = 'both')
      sub_din$`Real answer` <- trimws(sub_din$`Real answer`, which = 'both')
      sub_din <- sub_din %>% filter(!is.na(`Real answer`))
      sub_din$correct <- ifelse(sub_din$`FW answer`==sub_din$`Real answer`, 'yes', 'no')
      num_correct_din <- length(which(sub_din$correct == 'yes'))
      num_wrong_din <- length(which(sub_din$correct == 'no' | is.na(sub_din$correct)))
      
      per_correct_din <- round(num_correct_din/nrow(sub_din)*100, 2)
      sub_din$wid <- this_wid
      qa_din[[i]] <- sub_din
      temp <- tibble(wid = this_wid, test_version = c('DIN'), num_correct = c(num_correct_din),
                     num_wrong = c(num_wrong_din), per_correct= c(per_correct_din))
      table_list[[i]] <- temp
    } else {
      sub_mpr <- sub_dat[sub_dat$group_location.hh_hamlet_code=='MPR',]
      sub_mpr <- as.data.frame(t(sub_mpr), stringsAsFactors = FALSE)
      sub_mpr$question <- row.names(sub_mpr)
      row.names(sub_mpr) <- NULL
      names(sub_mpr)[1] <- 'FW answer'
      # left join with answer keys 
      sub_mpr <- left_join(sub_mpr, qa_key_mpr, by = 'question')
      sub_mpr$`FW answer` <- trimws(sub_mpr$`FW answer`, which = 'both')
      sub_mpr$question <- trimws(sub_mpr$question, which = 'both')
      sub_mpr$`Real answer` <- trimws(sub_mpr$`Real answer`, which = 'both')
      sub_mpr <- sub_mpr %>% filter(!is.na(`Real answer`))
      sub_mpr$correct <- ifelse(sub_mpr$`FW answer`==sub_mpr$`Real answer`, 'yes', 'no')
      num_correct_mpr <- length(which(sub_mpr$correct == 'yes'))
      num_wrong_mpr <- length(which(sub_mpr$correct == 'no' | is.na(sub_mpr$correct)))

      per_correct_mpr <- round(num_correct_mpr/nrow(sub_mpr)*100, 2)
      sub_mpr$wid <- this_wid
      qa_mpr[[i]] <- sub_mpr
      temp <- tibble(wid = this_wid, test_version = c('MPR'), num_correct = c(num_correct_mpr),
                     num_wrong = c(num_wrong_mpr), per_correct= c(per_correct_mpr))
      table_list[[i]] <- temp
    }
  } else {
    # Scenario 1 DIN
    sub_din <- sub_dat[sub_dat$group_location.hh_hamlet_code=='DIN',]
    sub_din <- as.data.frame(t(sub_din), stringsAsFactors = FALSE)
    sub_din$question <- row.names(sub_din)
    row.names(sub_din) <- NULL
    names(sub_din)[1] <- 'FW answer'
    # left join with answer keys 
    sub_din <- left_join(sub_din, qa_key_din, by = 'question')
    sub_din$`FW answer` <- trimws(sub_din$`FW answer`, which = 'both')
    sub_din$question <- trimws(sub_din$question, which = 'both')
    sub_din$`Real answer` <- trimws(sub_din$`Real answer`, which = 'both')
    sub_din <- sub_din %>% filter(!is.na(`Real answer`))
    
    # Scenario 2 MPR
    sub_mpr <- sub_dat[sub_dat$group_location.hh_hamlet_code=='MPR',]
    sub_mpr <- as.data.frame(t(sub_mpr), stringsAsFactors = FALSE)
    sub_mpr$question <- row.names(sub_mpr)
    row.names(sub_mpr) <- NULL
    names(sub_mpr)[1] <- 'FW answer'
    # left join with answer keys 
    sub_mpr <- left_join(sub_mpr, qa_key_mpr, by = 'question')
    sub_mpr$`FW answer` <- trimws(sub_mpr$`FW answer`, which = 'both')
    sub_mpr$question <- trimws(sub_mpr$question, which = 'both')
    sub_mpr$`Real answer` <- trimws(sub_mpr$`Real answer`, which = 'both')
    sub_mpr <- sub_mpr %>% filter(!is.na(`Real answer`))
    
    # create a column to indicate if was the right answer
    sub_mpr$correct <- ifelse(sub_mpr$`FW answer`==sub_mpr$`Real answer`, 'yes', 'no')
    sub_din$correct <- ifelse(sub_din$`FW answer`==sub_din$`Real answer`, 'yes', 'no')
    
    # create number correct and percent correct
    num_correct_mpr <- length(which(sub_mpr$correct == 'yes'))
    num_correct_din <- length(which(sub_din$correct == 'yes'))
    
    num_wrong_mpr <- length(which(sub_mpr$correct == 'no' | is.na(sub_mpr$correct) ))
    num_wrong_din <- length(which(sub_din$correct == 'no' | is.na(sub_din$correct)))
    
    per_correct_mpr <- round(num_correct_mpr/nrow(sub_mpr)*100, 2)
    per_correct_din <- round(num_correct_din/nrow(sub_din)*100, 2)
    
    # create identifier columns 
    sub_mpr$wid <- this_wid
    sub_din$wid <- this_wid
    
    # return a list of sub_mpr/sub_din
    qa_mpr[[i]] <- sub_mpr
    qa_din[[i]] <- sub_din
    
    # create data frame with wid, test version, and number and percent correct
    temp <- tibble(wid = this_wid, test_version = c('DIN','MPR'), num_correct = c(num_correct_din, num_correct_mpr), num_wrong = c(num_wrong_din, num_wrong_mpr),per_correct= c(per_correct_din, per_correct_mpr))
    table_list[[i]] <- temp
  }
  
  
}

# combine table list 
r_tab <- do.call('rbind', table_list)
r_tab_mpr <- do.call('rbind', qa_mpr)
r_tab_din <- do.call('rbind', qa_din)

# edit r_tab
names(r_tab) <- c('FW ID', 'Test version', '# correct','# wrong', '% correct')

# create a function that takes a wid and creates a table with in depth test results 
get_wid_results <- function(wid_code){
  sub_mpr <- r_tab_mpr %>% filter(wid == wid_code)
  sub_din <- r_tab_din %>% filter(wid == wid_code)
  # sub_dat <- r_tab  %>% filter(`FW ID`==wid_code)
  # print(sub_dat)
  if(nrow(sub_mpr)==0){
    # reorder columns 
    sub_din$wid <- NULL
    sub_din <- sub_din[, c('question', 'FW answer', 'Real answer', 'correct')]
    names(sub_din) <- Hmisc::capitalize(names(sub_din))

    return(sub_din)
  } else if (nrow(sub_din)==0){
    # reorder columns 
    sub_mpr$wid <- NULL
    sub_mpr <- sub_mpr[, c('question', 'FW answer', 'Real answer', 'correct')]
    names(sub_mpr) <- Hmisc::capitalize(names(sub_mpr))

    return(sub_mpr)
  } else {
    # reorder columns 
    sub_mpr$wid <- sub_din$wid <- NULL
    sub_mpr <- sub_mpr[, c('question', 'FW answer', 'Real answer', 'correct')]
    sub_din <- sub_din[, c('question', 'FW answer', 'Real answer', 'correct')]
    names(sub_mpr) <- Hmisc::capitalize(names(sub_mpr))
    names(sub_din) <- Hmisc::capitalize(names(sub_din))
    return(list(sub_din, sub_mpr))
  }
  
}

write.csv(r_tab, file = 'test_results.csv')
