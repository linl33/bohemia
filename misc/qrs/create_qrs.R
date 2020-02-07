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
dims <- dims * 0.393701

numbers <- 1:600
numbers <- add_zero(numbers, 3)

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
dir.create('pdfs')
for(i in 1:length(numbers)){
  message(i, ' of ', length(numbers))
# for(i in 1:2){
  this_number <- numbers[i]
  marg <- ggplot() + databrew::theme_simple()
  a <- ggplot() +
    databrew::theme_simple() +
    labs(title = this_number,
         # y = 'www.databrew.cc/qr',
         subtitle = 'Bohemia\nID card',
         caption = 'www.bohemia.team/qr')+
    theme(plot.title = element_text(hjust = 0.5, size = 36),
          plot.subtitle = element_text(hjust = 0.5, size = 12),
          plot.caption = element_text(hjust = 1, size = 7))
  gl <- ggqrcode(this_number)
  x <- ggarrange(
    marg,
    ggarrange(marg, gl, a, marg, widths = c(2, 57.6, 38.4, 2), nrow = 1),
    marg,
    heights = c(2, 96, 2), ncol = 1)
  ggexport(x,
           filename = paste0('pdfs/', this_number, '.pdf'),
           width = dims[1], height = dims[2])
}
setwd('pdfs')
system('pdftk *.pdf cat output all.pdf')
setwd('..')
