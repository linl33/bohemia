
library(knitr)
library(xtable)
library(sf)
library(raster)
library(dplyr)
library(spData)
library(spDataLarge)
library(tmap) 
library(ggplot2)
library(cartography)
library(cartogram)
library(gridExtra)
library(XLConnect)

## Figure 1: maps of study countries
data(World)
country_data<-read.csv(file='./country_data_whole_9.csv')
country.name<-country_data$country

study_area <- World %>% 
  filter(name %in% country.name) %>% 
  left_join(country_data, by=c("name"="country")) %>% 
  mutate(incidence_case = cases_point_estimated/pop_at_risk*1000,
         incidence_death = deaths_point_estimated/pop_at_risk*1000)
bhu_bb <- st_bbox(study_area)
bhu_bb <- bhu_bb * 1.1

make_plot <- function(){
  
  # Figure 1a
  m1 = tm_shape(World, bbox = bhu_bb) +  
    tm_borders() +
    tm_polygons(col = 'grey') +
    tm_shape(study_area, bbox = bhu_bb) +
    tm_polygons(col = "incidence_case", palette="YlOrRd", style="cont", title="Malaria incidence") +
    tm_text("iso_a3", size = 0.6) +
    tm_layout(frame = T, legend.position = c(0.03, 0.03), bg.color="lightcyan1",
              legend.title.size=1.7, legend.text.size = 0.7) +
    tm_credits('Per 1000 population at risk', size = 0.5, position = c(0,0))
  
  m2 = tm_shape(World, bbox = bhu_bb) +  
    tm_borders() +
    tm_polygons(col = 'grey') +
    tm_shape(study_area, bbox = bhu_bb) +
    tm_polygons(col = "deaths_point_estimated", palette="YlOrRd", style="cont",  title="Malaria deaths") +
    tm_text("iso_a3", size = 0.6) +
    tm_layout(frame = T, legend.position = c(0.03, 0.03), bg.color="lightcyan1",
              legend.title.size=1.2, legend.text.size = 0.7) 
  
  
  tmap_arrange(m1, m2, nrow = 1)
}

setEPS()
svg("1.svg")
par(mfrow=c(1,2))
make_plot()
dev.off()

png("1.png")
par(mfrow=c(1,2))
make_plot()
dev.off()
#########################################




#function of calculation----------------------------
year.init<-2018

ivermectin.mda<-function(country.data,uptake,eff,grif.rt,grif.rt.death,sev.case){
  n.pop<-country.data[1];n.case<-country.data[2];n.death<-country.data[3];gr<-country.data[4]+1
  year.total<-uptake[1];year.start<-uptake[2];uptake.cov<-uptake[-c(1,2)]
  inter.rt<-1-eff*uptake.cov #(0.05+0:4*0.03) is the uptake coverage that can be changed
  
  cases_estimate<-n.case*(gr*grif.rt)^(0:year.total)
  deaths<-n.death*(gr*grif.rt.death)^(0:(year.total))
  #deaths.inter<-n.death*c((gr*grif.rt)^(0:(year.start-1)),(gr*grif.rt)^(year.start:year.total)*inter.rt)
  
  cases_estimate<-n.case;deaths<-n.death;case_scen<-n.case;death_scen<-n.death;pop_risk<-n.pop
  avert5case<-rep(0,year.start);avert5death<-rep(0,year.start) #5% is the annual cummulative efficacy
  for (i in 1:year.total){
    pop_risk<-c(pop_risk,n.pop*gr^i)
    cases_estimate<-c(cases_estimate,n.case*(gr*grif.rt)^i)
    deaths<-c(deaths,n.death*(gr*grif.rt.death)^i)
    if (i<year.start){
      case_scen<-c(case_scen,n.case*(gr*grif.rt)^i)
      death_scen<-c(death_scen,n.death*(gr*grif.rt.death)^i)
    }
    if (i>=year.start){
      case_scen<-c(case_scen,(cases_estimate[i+1]-avert5case[i])*inter.rt[(i-year.start+1)])
      avert5case<-c(avert5case,(cases_estimate[i+1]-case_scen[i+1])*ac.eff)
      death_scen<-c(death_scen,(deaths[i+1]-avert5death[i])*inter.rt[(i-year.start+1)])
      avert5death<-c(avert5death,(deaths[i+1]-death_scen[i+1])*ac.eff)
    }
  }
  case_death_sum<-cbind(pop_risk,cases_estimate,deaths,case_scen,avert5case,death_scen,avert5death)
  avert_case<-(cases_estimate-case_scen)[year.start:year.total+1]
  avert_death<-(deaths-death_scen)[year.start:year.total+1]
  colnames(case_death_sum)<-c('population at risk','cases estimates','deaths',
                              paste0('cases+',100*eff,'% efficacy+5% coverage'),'5% of the averted cases',
                              paste0('deaths+',100*eff,'% efficacy+5% coverage'),'5% of the averted deaths')
  rownames(case_death_sum)<-0:year.total+year.init
  
  #Averted costs
  avert_cost<-avert_case*((1-sev.case)*uncom.cost+sev.case*sev.cost) #on average, the cost per case is 6.0842 (uncom.case*uncom.cost+sev.case*sev.cost)
  cumu_avert_cost<-NULL
  for (i in 1:length(avert_cost)){
    cumu_avert_cost<-c(cumu_avert_cost,sum(avert_cost[1:i]))
  }
  
  #Scale up costs
  n.tab<-3 #number of tablets taken per person per round
  n.round<-1 #number of rounds in one year
  tab.cost<-0.15 #cost of one tablet
  dist.cost<-0.46 #distribution cost per person per round
  cov.risk<-0.64
  cost_p_person<-n.tab*n.round*tab.cost+n.round*dist.cost #Cost per person in one year
  pop.treat<-pop_risk[year.start:year.total+1]*uptake.cov*cov.risk #population treated
  cost_ivermectin<-pop.treat*cost_p_person
  cost_p_case_avert<-c(sum(avert_cost),sum(cost_ivermectin)-sum(avert_cost),sum(avert_case),sum(avert_death),
                       (sum(cost_ivermectin)-sum(avert_cost))/sum(avert_case)) #cost per case averted.
  
  result<-NULL
  result[[1]]<-case_death_sum 
  result[[2]]<-c(avert_cost,sum(avert_cost))
  result[[3]]<-c(cost_ivermectin,sum(cost_ivermectin))
  result[[4]]<-cost_p_case_avert
  result[[5]]<-c(avert_case,sum(avert_case))
  result[[6]]<-c(avert_death,sum(avert_death))
  return(result)
}
#output
# result[[1]]<-case_death_sum 
# result[[2]]<-c(avert_cost,sum(avert_cost)), shows averted cost due to MDA in each year, the last number is the sum for all years.
# result[[3]]<-c(cost_ivermectin,sum(cost_ivermectin)), shows cost of MDA in each year, the last number is the sum for all years.
# result[[4]]<-cost_p_case_avert, first number is the accumulative averted cost due to MDA, second number is the 
#                                 accumulative cost of MDA minus the averted cost due to MDA, third number is the 
#                                 accumulative number of averted cases, fourth number is the accumulative averted 
#                                 deaths due to MDA, fifth number is the the second number devided by the third number.
# result[[5]]<-avert_case, shows number of averted cases in each year, the last number is the sum for all years.
# result[[6]]<-avert_death, shows number of averted deaths in each year, the last number is the sum for all years.
#n.pop<-population at risk at the first year
#n.case<-number of cases at the first year
#n.death<-number of deaths at the first year
#gr<-growth rate at the first year
#uptake.cov<-uptake coverage for the year using ivermectin mda
#eff<-efficacy of the uptake.
#grif.rt<-griffin scenarios' annual percentage change in cases & deaths
#sev.case<-percentage of severe malaria cases.


#Calculation-----------
ac.eff<-0.05
uncom.cost<-5.84;sev.cost<-30.26 #costs for uncomplicate and severe malaria cases
n.tab<-3.3 #number of tablets taken per person per round
n.round<-3 #number of rounds in one year
tab.cost<-0.15 #cost of one tablet
dist.cost<-0.46 #distribution cost per person per round
cov.risk<-0.64 #coverage of population at risk

country_data<-read.csv(file='./country_data_9.csv')

country.name<-country_data$country
uptake.name<-c('Conservative','Rapid','National 7')
grif.name<-c('Accelerate 1','Accelerate 2','Innovate','Sustain','No change')

country.data.grid<-country_data[,3:6]
uptake.grid<-list(c(2027-year.init,2023-year.init,0.05+0:4*0.03),
                  c(2027-year.init,2023-year.init,0.05+0:4*0.1),
                  c(2029-year.init,2023-year.init,0.05,0.1,1:5*0.2))
eff.grid<-c(0.2,0.4)
grif.rt.grid<-c(0.79,0.41,0.26,1.28,1)^(1/15) #Based on Griffin scenarios; change in malaria incidence over 15 years i.e. from 2015 to 2030.
grif.rt.death.grid<-c(0.6,0.26,0.19,1.11,1)^(1/15) #Based on Griffin scenarios; change in malaria death over 15 years i.e. from 2015 to 2030.
sev.case.grid<-c(0.01,0.03)


temp<-rep(list(rep(list(rep(list(rep(list(rep(list(list()),9)),2)),5)),2)),3)
sum.temp<-rep(list(rep(list(rep(list(rep(list(rep(list(list()),4)),2)),5)),2)),3)
for (uptake.id in 1:3){
  for (eff.id in 1:2){
    for (grif.rt.id in 1:5){
      for (sev.case.id in 1:2){
        sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]]<-
          ivermectin.mda(as.numeric(country.data.grid[1,]),uptake.grid[[uptake.id]],
                         eff.grid[eff.id],grif.rt.grid[grif.rt.id],grif.rt.death.grid[grif.rt.id],sev.case.grid[sev.case.id])
        for (country.data.id in 1:9){
          temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]][[country.data.id]]<-
            ivermectin.mda(as.numeric(country.data.grid[country.data.id,]),uptake.grid[[uptake.id]],
                           eff.grid[eff.id],grif.rt.grid[grif.rt.id],grif.rt.death.grid[grif.rt.id],sev.case.grid[sev.case.id])
          for (ii in 1:4){
            if (country.data.id>1){
              sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]][[ii]]<-
                sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]][[ii]]+
                temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]][[country.data.id]][[ii]]
            }
          }
        }
      }
    }
  }
}
## Figures 2: Change in malaria cases for all 10 countries
out_list <- final_list <- list()
# par(mfrow=c(3,1))
counter <- 0
for (uptake.id in 1:3){
  counter <- counter + 1
  casedata<-NULL
  for (grif.rt.id in 1:5){
    casedata.temp<-NULL
    for (eff.id in 1:2){
      case.temp<-data.frame(sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[1]][[1]])
      if (eff.id == 1){
        casedata.temp<-rbind(case.temp[,2]/case.temp[,1],case.temp[,4]/case.temp[,1])
      }else{
        casedata.temp<-rbind(casedata.temp,case.temp[,4]/case.temp[,1])
      }
    }
    casedata[[grif.rt.id]]<-casedata.temp[,1:10]*1000
  }
  convert_to_df <- function(x){
    out <- data.frame(t(x))
    names(out) <- c('Baseline scenario',
                    '20% efficacy',
                    '40% efficacy')
    return(out)
  }
  done_list <- list()
  for(i in 1:length(casedata)){
    done <- convert_to_df(casedata[[i]])
    done$grif <- i
    done$uptake_id = uptake.id
    done_list[[i]] <- done
  }
  done <- bind_rows(done_list)
  done$grif <- ifelse(done$grif == 4, 'Sustain',
                      ifelse(done$grif == 5, 'No change',
                             ifelse(done$grif == 1, 'Accelerate 1',
                                    ifelse(done$grif == 2, 'Accelerate 2',
                                           ifelse(done$grif == 3, 'Innovate', NA)))))
  done$year <- 2018:2027
  final_list[[counter]] <- done
}
done <- bind_rows(final_list)
done$uptake_id <- 
  ifelse(done$uptake_id == 1, 'Conservative uptake',
         ifelse(done$uptake_id == 2, 'Rapid uptake',
                ifelse(done$uptake_id == 3, 'National', NA)))

pd <- done %>%
    tidyr::gather(key, value, `Baseline scenario`:`40% efficacy`)
pd$uptake_id <- factor(pd$uptake_id, levels = c('Conservative uptake',
                                                    'Rapid uptake',
                                                    'National'))
pd$grif <- factor(pd$grif, levels = c('Sustain',
                                      'No change',
                                      'Accelerate 1',
                                      'Accelerate 2',
                                      'Innovate'))
pd$key <- factor(pd$key,
                 levels = c('Baseline scenario',
                            '20% efficacy',
                            '40% efficacy'))

cols <- RColorBrewer::brewer.pal(n = 5, name = 'Spectral')
cols[3] <- 'darkgrey'
ggplot(data = pd,
         aes(x = year,
             y = value,
             color = grif,
             lty = key,
             pch = key)) +
    geom_line() +
  # geom_point() +
    facet_wrap(~uptake_id, ncol = 1) +
    ylim(0, 350) +
  scale_color_manual(name = '',
                     values = cols) +
  scale_x_continuous(breaks = 2018:2027) +
  scale_y_log10() +
  labs(y = 'Incidence per 1,000 people at risk',
       x = 'Year') +
  # ggthemes::theme_fivethirtyeight() +
  databrew::theme_simple() +
  scale_linetype(name = '') +
  theme(legend.position = 'right',
        legend.direction = 'vertical',
        legend.text = element_text(size = 14))
ggsave('2.svg', height = 7, width = 9) 
ggsave('2.png', height = 7, width = 9) 

##########################################

## Figures 4

done_list <- list()
strategies <- c('Innovate', 'Accelerate 2', 'Accelerate 1', 'No change', 'Sustain')
strategies <- rev(strategies)
# strategies <- strategies[c(4,5,1,2,3)]
key_values <- c('20% Efficacy, 1% severe cases','20% Efficacy, 3% severe cases',
                              '40% Efficacy, 1% severe cases','40% Efficacy, 3% severe cases')
counter <- 0
for (uptake.id in 1:3){
  counter <- counter +1
  bardata<-NULL
  for (grif.rt.id in 1:5){
    bardata.temp<-NULL
    for (eff.id in 1:2){
      for (sev.case.id in 1:2){
        avert.temp<-sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[sev.case.id]][[2]]
        bardata.temp<-c(bardata.temp,avert.temp[length(avert.temp)])
      }
    }
    bardata[[grif.rt.id]]<-bardata.temp
  }
  bar_mat<-matrix(unlist(bardata),nrow=4,byrow=F)[,c(4,5,1,2,3)]   # reorder the Griffin scenario
  bar_mat <- bar_mat / 1000000
  out <- data.frame(bar_mat)
  out$key <- key_values
  out$uptake_id <- uptake.id
  names(out)[1:5] <- strategies
  done_list[[counter]] <- out
}
done <- bind_rows(done_list)
done$uptake_id <- 
  ifelse(done$uptake_id == 1, 'Conservative uptake',
         ifelse(done$uptake_id == 2, 'Rapid uptake',
                ifelse(done$uptake_id == 3, 'National', NA)))
pd <- done %>%
  tidyr::gather(uptake, value, Innovate:Sustain)

pd$uptake_id <- factor(pd$uptake_id, levels = c('Conservative uptake',
                                                    'Rapid uptake',
                                                    'National'))
pd$uptake <- factor(pd$uptake, levels = c('Sustain',
                                      'No change',
                                      'Accelerate 1',
                                      'Accelerate 2',
                                      'Innovate'))
pd$key <- factor(pd$key, levels = key_values)
ggplot(data = pd,
       aes(x = uptake,
           y = value,
           group = key,
           fill = key)) +
  facet_wrap(~uptake_id, ncol = 1) +
  geom_bar(stat = 'identity', position = position_dodge(width = 0.9),
           alpha = 0.8) +
  databrew::theme_simple() +
  scale_fill_manual(name = '',
                    values = cols[c(1,2,4,5)]) +
  theme(legend.position = 'bottom',
        legend.text = element_text(size = 14)) +
  guides(fill=guide_legend(nrow=2,byrow=TRUE)) +
  labs(x = '',
       y = 'Dollars (millions)') +
  geom_text(aes(label = round(value),
                y = value - 30),
            position = position_dodge(width = 0.9),
            alpha = 0.9, col = 'black', size = 1.7) +
  coord_flip()
ggsave('4.svg', width = 9, height= 7)
ggsave('4.png', width = 9, height= 7)


## Figures 3 right half: Cumulative averted deaths due to BOHEMIA iMDA for all 10 countries.
done_list <- list()
strategies <- c('Conservative uptake','Rapid uptake','National')
grifs <- rev(c('Innovate', 'Accelerate 2', 'Accelerate 1', 'No change', 'Sustain'))
counter <- 0
for (uptake.id in 1:3){
  counter <- counter + 1
  avertdata<-NULL
  for (grif.rt.id in 1:5){
    avertdata.temp<-NULL
    for (eff.id in 1:2){
      avert.temp<-sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[1]][[4]]
      avertdata.temp<-c(avertdata.temp,avert.temp[4])
    }
    avertdata[[grif.rt.id]]<-avertdata.temp
  }
  avert_matdeath<-matrix(unlist(avertdata),nrow=2,byrow=F)[,c(4,5,1,2,3)]
  out <- data.frame(t(avert_matdeath))
  names(out) <- rev(c('40% Efficacy', '20% Efficacy'))
  out$strategy <- strategies[counter]
  out$grif <- grifs
  done_list[[counter]] <- out
}
  
done <- bind_rows(done_list)
pd_right <- tidyr::gather(done, key, value, `40% Efficacy`:`20% Efficacy`)

pd_right$strategy <- factor(pd_right$strategy, levels = c('Conservative uptake',
                                                    'Rapid uptake',
                                                    'National'))
pd_right$grif <- factor(pd_right$grif, levels = c('Sustain',
                                      'No change',
                                      'Accelerate 1',
                                      'Accelerate 2',
                                      'Innovate'))
pd_right$value <- pd_right$value / 1000
## Figures 3 left half: Cumulative averted cases due to BOHEMIA iMDA for all 10 countries.
done_list <- list()
strategies <- c('Conservative uptake','Rapid uptake','National')
grifs <- rev(c('Innovate', 'Accelerate 2', 'Accelerate 1', 'No change', 'Sustain'))
counter <- 0
for (uptake.id in 1:3){
  counter <- counter + 1
  avertdata<-NULL
  avertdata.case <- NULL
  for (grif.rt.id in 1:5){
    avertdata.temp<-NULL
    avertdata.temp.case <- NULL
    for (eff.id in 1:2){
      avert.temp<-sum.temp[[uptake.id]][[eff.id]][[grif.rt.id]][[1]][[4]]
      avertdata.temp<-c(avertdata.temp,avert.temp[4])
      avertdata.temp.case<-c(avertdata.temp.case,avert.temp[3])
    }
    avertdata[[grif.rt.id]]<-avertdata.temp
    avertdata.case[[grif.rt.id]]<-avertdata.temp.case
  }
  avert_matdeath<-matrix(unlist(avertdata),nrow=2,byrow=F)[,c(4,5,1,2,3)]
  avert_mat<-matrix(unlist(avertdata.case),nrow=2,byrow=F)[,c(4,5,1,2,3)]
  
  out <- data.frame(t(avert_mat))
  names(out) <- rev(c('40% Efficacy', '20% Efficacy'))
  out$strategy <- strategies[counter]
  out$grif <- grifs
  done_list[[counter]] <- out
  
}
  
done <- bind_rows(done_list)
pd_left <- tidyr::gather(done, key, value, `40% Efficacy`:`20% Efficacy`)

pd_left$strategy <- factor(pd_left$strategy, levels = c('Conservative uptake',
                                                    'Rapid uptake',
                                                    'National'))
pd_left$grif <- factor(pd_left$grif, levels = c('Sustain',
                                      'No change',
                                      'Accelerate 1',
                                      'Accelerate 2',
                                      'Innovate'))
pd_left$value <- pd_left$value / 1000000 * -1

options(scipen = 999)
pd <- bind_rows(
  pd_right,
  pd_left
)
ggplot(data = pd,
       aes(x = grif,
           y = value,
           fill = key)) +
  geom_bar(position = position_dodge(width = 0.9),
           stat = 'identity') +
  facet_wrap(~strategy, ncol = 1) +
  coord_flip() +
  geom_text(aes(label = round(abs(value)),
                y = ifelse(value < 0, value - 17, value + 17)),
                color = 'black',
            position = position_dodge(width = 0.9),
            size = 3) +
  geom_hline(yintercept = 0) +
  labs(y = 'Number of averted cases (millions)              Number of averted deaths (thousands)',
       x = '') +
  databrew::theme_simple() +
  theme(legend.position = 'bottom',
        axis.title = element_text(size = 12, vjust = 0)) +
  scale_fill_manual(name = '',
                    values = c('black', 'darkgrey')) +
  scale_y_continuous(breaks = seq(-500, 500, by = 250),
                     labels = abs(seq(-500, 500, by = 250)),
                     limits = c(-500, 500))
ggsave('3.png', height = 7, width = 8)
ggsave('3.eps', height = 8.5, width = 10)
  
  
