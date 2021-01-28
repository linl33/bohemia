library(ggplot2)
library(bohemia)
library(tidyverse)
library(grid)
library(gridExtra)
library(ggpubr)
library(extrafont)
loadfonts()
# dimensions: Format 10 x 6 aprox
dims <- c(10, 6)
# dims <- dims * 3
dims <- dims * 0.5


library(gsheet)
fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0'
fids1 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor, Role = details) %>% dplyr::mutate(country = 'Tanzania')
fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=409816186'
fids2 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor, Role = details) %>% dplyr::mutate(country = 'Mozambique')
fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508'
fids3 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor, Role = details) %>% dplyr::mutate(country = 'Catalonia')
fids <- bind_rows(fids1, fids2, fids3)
fids <- fids[1:600,]
fids <- fids %>% filter(bohemia_id %in% c(1:200, 301:500))

numbers <- fids$bohemia_id
numbers <- add_zero(numbers, 3)
fid_names <- paste0(ifelse(is.na(fids$first_name), '', fids$first_name), ' ', 
                    ifelse(is.na(fids$last_name), '', fids$last_name))
fid_names[fid_names == 'NA NA'] <- ''

ggqrcode <- function(text, color="black", alpha=1) {
  pkg <- "qrcode"
  require(pkg, character.only = TRUE)
  x <- qrcode_gen(text, plotQRcode=F, dataOutput=T)
  x <- as.data.frame(x)
  
  y <- x
  y$id <- rownames(y)
  y <- gather(y, "key", "value", colnames(y)[-ncol(y)])
  y$key = factor(y$key, levels=rev(colnames(x)))
  y$id = factor(y$id, levels=rev(rownames(x)))
  
  ggplot(y, aes_(x=~id, y=~key)) + geom_tile(aes_(fill=~value), alpha=alpha) +
    scale_fill_gradient(low="white", high=color) +
    theme_void() + theme(legend.position='none')
} # https://github.com/GuangchuangYu/yyplot/blob/master/R/ggqrcode.R

# Generate pdf
dir.create('pdfs_workers')
for(i in 1:length(numbers)){
  message(i, ' of ', length(numbers))
# for(i in 1:2){
  this_number <- numbers[i]
  this_name <- fid_names[i]
  marg <- ggplot() + theme_void()# databrew::theme_simple()
  a <- ggplot() +
    theme_void() +
    # databrew::theme_simple() +
    labs(title = this_number,
         # y = 'www.databrew.cc/qr',
         subtitle = this_name,
         caption = 'www.bohemia.team/qr')+
    theme(plot.title = element_text(hjust = 0.5, size = 36),
          plot.subtitle = element_text(hjust = 0.5, size = 12),
          plot.caption = element_text(size = 7, hjust = 0.5))
  gl <- ggqrcode(this_number)

  x <- ggarrange(marg, 
           ggarrange(a, gl, marg, nrow = 1,
                     widths = c(4,4,1)),
           marg,
           ncol = 1,
           heights = c(2,10,2))
  
  
  ggexport(x,
           filename = paste0('pdfs_workers/', this_number, '.pdf'),
           width = dims[1], height = dims[2])
}
# setwd('pdfs')
# system('pdftk *.pdf cat output all.pdf')
# setwd('..')

# Combine to 12 per page
setwd('pdfs_workers')
dir.create('to_print')
n <- length(numbers)
ends <- (1:n)[1:n %% 12 == 0]
starts <- ends - 11

for(i in 1:length(starts)){
  this_start <- starts[i]
  this_end <- ends[i]
  these_numbers <- this_start:this_end
  these_numbers <- add_zero(these_numbers, 3)
  these_files <- paste0(these_numbers, '.pdf')
  file_string <- paste0(these_files, collapse = ' ')
  out_file <- paste0('to_print/', add_zero(this_start, 3), '-',
                     add_zero(this_end, 3), '.pdf')
  command_string <- paste0('pdfjam ', file_string,
                           ' --nup 3x4 --landscape --outfile ',
                           out_file)
  system(command_string)
}
setwd('to_print')
system('pdftk *.pdf cat output all.pdf')
setwd('..')
setwd('..')
# 
# system('pdfjam 001.pdf 002.pdf 003.pdf 004.pdf 005.pdf 006.pdf 007.pdf 008.pdf 009.pdf 010.pdf 011.pdf 012.pdf --nup 3x4 --landscape --outfile 001-004.pdf')
# setwd('..')
