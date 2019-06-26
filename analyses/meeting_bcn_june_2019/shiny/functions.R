library(shinydashboard)
library(googlesheets)
library(ggplot2)
library(dplyr)
library(Hmisc)
library(ggridges)
library(cowplot)


# Define plotting theme
theme_databrew <- function (base_size = 15, base_family = "Sawasdee", y_comma = TRUE, 
                            subtitle_family = "Sawasdee", axis_family = "Sawasdee") 
{
  color_background = "#F8F5E1"
  color_grid_major = "grey"
  color_axis_text = "#0d63c4"
  color_axis_title = color_axis_text
  color = "darkgrey"
  color_title = color_axis_text
  color_subtitle = grey(0.1)
  base_size1 = base_size
  out <- theme_bw(base_size = base_size1) + theme(panel.background = element_rect(fill = color_background, 
                                                                                  color = color_background)) + theme(plot.background = element_rect(fill = color_background, 
                                                                                                                                                    color = color_background)) + theme(panel.border = element_rect(color = color_background)) + 
    theme(panel.grid.major = element_line(color = adjustcolor(color_grid_major, 
                                                              alpha.f = 0.25), size = 0.25)) + theme(panel.grid.major = element_line(color = adjustcolor(color_grid_major, 
                                                                                                                                                         alpha.f = 0.4), size = 0.4)) + theme(panel.grid.minor = element_blank()) + 
    theme(axis.ticks = element_blank()) + theme(legend.background = element_rect(fill = color_background)) + 
    theme(legend.text = element_text(family = base_family, 
                                     size = base_size * 0.7, color = color_axis_title)) + 
    theme(plot.title = element_text(family = base_family, 
                                    color = color_title, size = base_size * 1.2, vjust = 1.25)) + 
    theme(plot.subtitle = element_text(family = subtitle_family, 
                                       color = color_subtitle, size = base_size * 0.8, vjust = 1.25)) + 
    theme(axis.text.x = element_text(family = axis_family, 
                                     size = base_size * 0.7, color = color_axis_text)) + 
    theme(axis.text.y = element_text(family = axis_family, 
                                     size = base_size * 0.7, color = color_axis_text)) + 
    theme(axis.title.x = element_text(family = axis_family, 
                                      size = base_size * 0.9, color = color_axis_title, 
                                      vjust = 0)) + theme(axis.title.y = element_text(family = axis_family, 
                                                                                      size = base_size * 0.9, color = color_axis_title, vjust = 1.25)) + 
    theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) + 
    theme(complete = TRUE) + theme(legend.key = element_blank()) + 
    theme(legend.position = "bottom") + theme(strip.background = element_rect(fill = color_background), 
                                              strip.text = element_text(size = base_size * 0.6), panel.spacing = unit(0, 
                                                                                                                      "lines"), panel.border = element_rect(colour = NA, 
                                                                                                                                                            fill = NA, size = 0))
  if (y_comma) {
    out <- list(out, scale_y_continuous(label = scales::comma))
  }
  else {
    out <- list(out)
  }
  return(out)
}



# Make sure variables are classified as needed
make_numeric <- function(x){as.numeric(as.character(x))}

# Define function for plotting distribution of a variable
plot_variable <- function(variable = 'km_rufiji',
                          data = df,
                          db = TRUE){
  
  title_df <- data.frame(variable = c('years','sex','km_rufiji','km_mopeia','gps', 'avg_error_absolute'),
                         title = c('Age of participants',
                                   'Sex of participants',
                                   'Km from BCN to Rufiji',
                                   'KM from BCN to Mopeia',
                                   'GPS watch',
                                   'Absolute error (%)'))
  
  data <- data.frame(data)
  data$x <- data[,variable]
  avg <- mean(data$x, na.rm = TRUE)
  avg_df <- data.frame(x = avg,
                       y = 0,
                       label = paste0('Crowd\naverage:\n',
                                      round(avg, 2),
                                      '\n\n\n'))
  if(variable == 'km_rufiji'){
    true_df <- data.frame(x = 6665, y = 0, label = paste0('Truth:\n6665\n\n\n\n\n\n\n\n\n'))
  } else if(variable == 'km_mopeia'){
    true_df <- data.frame(x = 7433, y = 0, label = paste0('Truth:\n7433\n\n\n\n\n\n\n\n\n'))
  } else {
    true_df <- data.frame(x = NA, y = 0, label = NA)
  }
  g <- ggplot(data = data,
              aes(x = x)) +
    geom_density(alpha = 0.3,
                 fill = 'blue')
  if(db){
    g <- g + theme_databrew() 
  } else {
      g <- g + cowplot::theme_cowplot()
  }
  g <- g +
    labs(x = Hmisc::capitalize(variable),
         y = 'Density',
         title = title_df$title[title_df$variable == variable],
         subtitle = paste0('Participant responses')) +
    geom_text(data = avg_df,
              aes(x = x,
                  y = y,
                  label = label)) +
    geom_vline(xintercept = avg,
               lty = 2,
               alpha = 0.8) 
  if(variable != 'years'){
    g <- g +
      geom_vline(xintercept = true_df$x,
                 lty = 2,
                 alpha = 0.8) +
      geom_text(data = true_df,
                aes(x = x,
                    y = y,
                    label = label)) +
      theme(axis.text.y = element_text(size = 0),
            axis.title.x = element_text(size = 0))
  }
  return(g)
}

# Define function for plotting a variable by another one
plot_variable_by <- function(variable = 'km_mopeia',
                             variable_by = '',
                             data = df,
                             db = TRUE){
  
  title_df <- data.frame(variable = c('years','sex','km_rufiji','km_mopeia','gps', 'avg_error_absolute'),
                         title = c('Age of participants',
                                   'Sex of participants',
                                   'Km from BCN to Rufiji',
                                   'KM from BCN to Mopeia',
                                   'GPS watch',
                                   'Absolute error (%)'))
  data <- data.frame(data)
  data$x <- data[,variable]
  has_by <- FALSE
  if(!is.null(variable_by)){
    if(!variable_by %in% c('', 'nothing')){
      has_by <- TRUE
      data$y <- data[,variable_by]
    }
  }
  
  if(!has_by){
    g <- ggplot() +
      theme_databrew()
  } else {
    if(variable_by %in% c('sex', 'gps')){
      g <- ggplot(data = data,
             aes(x = x,
                 group = y,
                 fill = y)) +
        geom_density(alpha = 0.3) 
      
      if(db){
        g <- g + theme_databrew() 
      } else {
        g <- g + cowplot::theme_cowplot()
      }
      
      g <- g +
        labs(x = Hmisc::capitalize(variable),
             y = 'Density',
             title = title_df$title[title_df$variable == variable]) +
        scale_fill_manual(name = '',
                          values = c('darkorange', 'blue')) 
    } else {
      g <- ggplot(data = data,
             aes(x = y,
                 y = x)) +
        geom_jitter()
      if(db){
        g <- g + theme_databrew() 
      } else {
        g <- g + cowplot::theme_cowplot()
      }
      g <- g +
        labs(x = Hmisc::capitalize(variable_by),
             y = '',
             title = title_df$title[title_df$variable == variable]) +
        stat_smooth (geom="line", alpha=0.3, size=1, #span=0.5,
                     color = 'blue') +
        geom_line(stat="smooth",method = "lm",
                  size = 1,
                  linetype ="dashed",
                  alpha = 0.5,
                  color = 'darkorange') 
    }
  }
  return(g)
}
