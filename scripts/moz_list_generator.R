library(bohemia)
library(dplyr)
library(rmarkdown)

# Define parameters for connecting to CISM ODK server
creds <- list(
  user = '<USERNAME GOES HERE>',
  password = '<PASSWORD GOES HERE>',
  url = '<ODK AGGREGATE SERVER URL GOES HERE>'
)

# Define other parameters
refresh <- TRUE # do you want to fetch new data (TRUE) or just use previously fetched data (FALSE)
lc <- 'DEX' # 3 letter location code
n_teams <- 3 # Number of enumeration teams
enum <- FALSE # whether to generate a list for enumerators (true) or not (false)
use_previous <- TRUE # whether to use previous data on households collected through enumeration (true) or guess households based on recon (false)

############# ENUMERATIONS
# Read in the "enumerations" data
id <- 'enumerations'
file_name <- paste0('moz_list_data/', id, '.RData')
exists_enumerations <- file.exists(file_name)
if(refresh | !exists_enumerations){
  enumerations <-
    odk_get_data(url = creds$url,
                 id = id,
                 user = creds$user,
                 password = creds$password,
                 unknown_id2 = FALSE,
                 uuids = NULL,
                 exclude_uuids = NULL)
  save(enumerations, file = file_name)
} else {
  load(file_name)
}

############# MINICENSUS
# Read in the "minicensus" data
id <- 'minicensus'
file_name <- paste0('moz_list_data/', id, '.RData')
exists_minicensus <- file.exists(file_name)

if(refresh | !exists_minicensus){
  minicensus <-
    odk_get_data(url = creds$url,
                 id = id,
                 user = creds$user,
                 password = creds$password,
                 unknown_id2 = FALSE,
                 uuids = NULL,
                 exclude_uuids = NULL)
  save(minicensus, file = file_name)
} else {
  load(file_name)
}

############# VISIT CONTROL SHEET
# Print the possible location codes
enumerations$non_repeats %>%
  group_by(hamlet_code) %>%
  tally %>%
  arrange(desc(n))

# Get number of households for the place in question (per recon)
gps <- bohemia::gps
hamlet <- gps %>% filter(code == lc)
n_hh <- hamlet$n_households

# Get other details
data <- data.frame(n_hh,
                   n_teams,
                   id_limit_lwr = 1,
                   id_limit_upr = n_hh)
enumerations_data = enumerations$non_repeats
names(enumerations_data) <- tolower(names(enumerations_data))
enumerations_data <- enumerations_data %>%
  dplyr::distinct(agregado, .keep_all = TRUE) %>%
  dplyr::arrange(agregado)

out_file <- paste0(getwd(), '/pdfs/visit_control_sheet.pdf')
rmarkdown::render(input = #paste0('../rpackage/bohemia/inst/rmd/visit_control_sheet.Rmd'),
                  paste0(system.file('rmd', package = 'bohemia'), '/visit_control_sheet.Rmd'),
                  output_file = out_file,
                  params = list(data = data,
                                loc_id = lc,
                                enumeration = enum,
                                use_previous = use_previous,
                                enumerations_data = enumerations_data, 
                                include_name = TRUE))
message('PDF produced at ', out_file)

######## CONSENT VERIFICATION LIST
# Get the data
pd <- minicensus$non_repeats
names(pd) <- tolower(names(pd))
people <- minicensus$repeats$minicensus_people
co <- 'Mozambique'
pd <- pd %>% dplyr::filter(hh_country == co)
# Get hh head
out_list <- list()
for(i in 1:nrow(pd)){
  this_instance_id <- pd$instance_id[i]
  this_num <- pd$hh_head_id[i]
  this_date <- pd$todays_date[i]
  this_dob <- pd$hh_head_dob[i]
  this_wid <- pd$wid[i]
  this_hh_hamlet_code <- pd$hh_hamlet_code[i]
  this_person <- people %>% filter(instance_id == this_instance_id,
                                   num == this_num)
  out <- this_person %>% mutate(todays_date = this_date,
                                hh_head_dob = this_dob,
                                wid = this_wid,
                                hh_hamlet_code = this_hh_hamlet_code)
  out_list[[i]] <- out
}
out <- bind_rows(out_list)

pd <- out %>%
  mutate(name = paste0(first_name, ' ', last_name),
         age = round((as.Date(todays_date) - as.Date(hh_head_dob)) / 365.25)) %>%
  mutate(consent = 'HoH (minicensus)') %>%
  mutate(x = ' ',y = ' ', z = ' ') %>%
  mutate(hh_id = substr(permid, 1, 7)) %>%
  dplyr::select(wid,
                hh_hamlet_code,
                hh_head_permid = permid,
                hh_id,
                name,
                age,
                todays_date,
                consent,
                x,y,z)

date_filter <- NULL # alternatively, vector of two dates
if(!is.null(date_filter)){
  pd <- pd %>%
    dplyr::filter(
      todays_date <= date_filter[2],
      todays_date >= date_filter[1]
    )
}

# convert to date for quality control table
pd$todays_date <- as.Date(pd$todays_date)
# get today's date and find the closest date in the data
today_date <- Sys.Date()
# get date closest to today
qc <- pd[which(abs(pd$todays_date-today_date) == min(abs(pd$todays_date - today_date))),]
# only keep hh_id and permid
qc <- qc %>% select(hh_id, hh_head_permid)
# get inputs for slider to control sample size
min_value <- 1
max_value <- nrow(qc)
selected_value <- sample(min_value:max_value, 1)
# NEED TRANSLATION FOR HOUSEHOLD ID
if(co == 'Mozambique'){
  names(pd) <- c('Código TC',
                 'Código Bairro',
                 'Household ID',
                 'ExtID (número de identificaçao do participante)',
                 'Nome do membro do agregado',
                 'Idade do membro do agregado',
                 'Data de recrutamento',
                 'Consentimento/ Assentimento informado (marque se estiver correto e completo)',
                 'Se o documento não estiver preenchido correitamente, indicar o error',
                 'O error foi resolvido (sim/não)',
                 'Verificado por (iniciais do arquivista) e data')
} else {
  names(pd) <- c('FW code',
                 'Hamlet code',
                 'Household ID',
                 'ExtID HH member',
                 'Name of household member',
                 'Age of household member',
                 'Recruitment date',
                 'Informed consent/assent type (check off if correct and complete)',
                 'If not correct, please enter type of error',
                 'Was the error resolved (Yes/No)?',
                 'Verified by (archivist initials) and date')
}
pdx <- pd

out_file <- paste0(getwd(), '/pdfs/consent_verification_list.pdf')
rmarkdown::render(input = paste0(system.file('rmd', package = 'bohemia'), '/consent_verification_list.Rmd'),
                  output_file = out_file,
                  params = list(data = pdx))

