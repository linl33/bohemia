library(httr)
library(stringi)
library(xml2)

url = 'https://bohemia.systems/formList'
r <- GET(url)

# See status
status_code(r)
http_status(r)

# Warn / stop for status
warn_for_status(r)
stop_for_status(r)

# Pull out elements from headers
# headers(r)

# Look at actual content/body
contingut <- content(r)

# # Url query string example
# # http://httpbin.org/get?key=val
# r <- GET("http://httpbin.org/get", 
#          query = list(key1 = "value1", key2 = "value2")
# )



# FORM LIST
url = 'https://bohemia.systems/formList'
r <- GET(url)
contingut <- content(r)
xname <- xml_name(contingut)
xnens <- xml_children(contingut)
xname
xnens
# Get the names of the forms
xml_name(xnens)
form_names <- xml_text(xnens)
form_names
# Get the urls
urls <- xml_attr(xnens, 'url')
# Get the form ids
get_id <- function(x){
  out <- strsplit(x, 'formId=', fixed = TRUE)
  out <- lapply(out, function(z){
    z[2]
  })
  out <- unlist(out)
  return(out)
}
ids <- get_id(urls)


# Get the secondary id of a specific form (only necessary if excel sheet was named differently before converting)
url2 = "https://bohemia.systems/formXml?formId=recon"
r <- GET(url2)
contingut <- content(r)
xnens <- xml_children(contingut)
a <- as_list(xnens)
b <- a[[1]]$model$instance
id2 <- names(b)


# Get the results (data) submissions for a specific form
url3 = 'https://bohemia.systems/view/submissionList?formId=recon'
r = GET(url3)
contingut <- content(r)
xnens <- xml_children(contingut)
xuuids <- xml_children(xnens)
uuids <- xml_text(xuuids)


# Get the data for an individual submission
base_url <- 'https://bohemia.systems'
form_id = ids[1]
form_name = form_names[1]
form_name <- 
piece2 <- '/view/downloadSubmission?formId='
piece3 <- paste0('[[@version=4 and @uiVersion=null]/', form_name, '[@key=')
uuid <- uuids[2]
url4 = paste0(base_url, piece2, form_id, piece3, uuid, ']')
r <- GET(url4)

xx = 'https://bohemia.systems/view/downloadSubmission?formId=recon[@version=null%20and%20@uiVersion=null]/recon[@key=uuid:9989ac01-8dd0-4996-bba1-fa52e9bdd070]'
xxx <- url_escape(xx)
GET(xxx)

# The below works!
# Important, the second is the name of the xml file
'https://bohemia.systems/view/downloadSubmission?formId=recon%5B@version=null%20and%20@uiVersion=null%5D/bohemiarecon%5B@key=uuid:9989ac01-8dd0-4996-bba1-fa52e9bdd070%5D'
https://bohemia.systems/view/downloadSubmission?formId=recon%5B@version=null%20and%20@uiVersion=null%5D/bohemiarecon%5B@key=uuid:9989ac01-8dd0-4996-bba1-fa52e9bdd070%5D

# # Get an image:
# wget http://localhost:32500/odkweb/view/binaryData\?blobKey\=Birds%5B%40version%3Dnull+and+%40uiVersion%3Dnull%5D%2Fnm%5B%40key%3Duuid%3A6539b7fb-06b6-440c-8275-a98b480366a2%5D%2Frepeat_observation%5B%40ordinal%3D2%5D%2Fimage -O 'images.jpg'

