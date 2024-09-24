##R script for analyses of hybrid and purebred egg count and size data
#Data obtained using methods described in manuscript - Fertile hybrids could aid coral adaptation - methods
#Written by Annika Lamb 

##Load functions and packages
#Summary function
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE, conf.interval=.95, .drop=TRUE) {
  
  require(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  
  length2 <- function (x, na.rm=FALSE) {
    
    if (na.rm) sum(!is.na(x))
    
    else       length(x)
    
  }
  
  
  # This does the summary. For each group's data frame, return a vector with
  
  # N, mean, and sd
  
  datac <- ddply(data, groupvars, .drop=.drop,
                 
                 .fun = function(xx, col) {
                   
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     
                     median = median (xx[[col]], na.rm=na.rm),
                     
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                     
                   )
                   
                 },
                 
                 measurevar
                 
  )
  # Rename the "mean" column    
  
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  
  # Calculate t-statistic for confidence interval: 
  
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

#load packages
library(lme4)
library(ggplot2)
library(tidyverse)
library(viridis)
library(emmeans)
library(glmmTMB)
library(cowplot)


### Analysis of egg counts
##Import egg count data
EggCount <- read.table('EggCountData_2020-2021.csv', header=T, sep=',')
head(EggCount)
##Remove additional replicates
EggCount<-EggCount[EggCount$Polyp <11, ]

##Dataframe Modifications
EggCount$SampleID<-as.factor(EggCount$SampleID)
EggCount$Cross<-as.factor(EggCount$Cross)
EggCount$Tank<-as.factor(EggCount$Tank)
EggCount$System<-as.factor(EggCount$System)
EggCount$UniPolyp<-as.factor(EggCount$UniPolyp)
EggCount$Treatment<-as.factor(EggCount$Treatment)
EggCount$Year<-as.factor(EggCount$Year)
#Check
str(EggCount)
#Remove missing data
EggCount_complete <-EggCount %>% drop_na(Count) 
EggCount_complete <- EggCount[!is.na(EggCount$Count), ]
EggCount_treatment <- EggCount[!is.na(EggCount$Treatment), ]

##Zero-inflated GLMM of egg count data
#Generate model, accounting for random variation due to Chan et al. treatment
EggCount_glmmTMB_treatment <- glmmTMB(Count~Cross * Year + (1|System/SampleID/UniPolyp) +(1|Treatment), family = poisson(),data =EggCount_treatment,ziformula = ~Cross * Year )
summary(EggCount_glmmTMB_treatment)
#Compare Egg counts amongst years and experimental groups (LLF1 and LTF1)
leastsquare = lsmeans(EggCount_glmmTMB_treatment,
                      pairwise ~ Cross|Year,
                      adjust = "tukey")
leastsquare

#Summary statistics
tapply(EggCount_complete$Count, EggCount_complete$Cross, median)
tapply(EggCount_complete$Count, EggCount_complete$Cross, range)
tapply(EggCount_complete$Count, EggCount_complete$Year, median)
tapply(EggCount_complete$Count, EggCount_complete$Year, range)

##Figure
EggCount_plot<-EggCount %>% ggplot(aes(x=Cross, y=Count)) +
  geom_boxplot() +
  scale_x_discrete(labels=expression('LL'[F1],'LK'[F1]))+
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  scale_y_continuous(limits = c(0,11))+
  geom_jitter(aes(colour=Cross),size=1, alpha=0.9)  +
  theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
        legend.position = "none",
        plot.title = element_text(size=16),
        strip.text.x = element_text(size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  xlab("Parental group") +
  ggtitle("A")+
  ylab("Number of oocytes") +
  facet_wrap(~ Year, nrow = 2, scales = "free")
EggCount_plot

###Analysis of egg sizes
##Import egg size data
EggSize<- read.table('EggSize_2020-2021.csv', header=T, sep=',')
##Data modifications
EggSize$Cross<-as.factor(EggSize$Cross)
EggSize$System<-as.factor(EggSize$System)
EggSize$Tank<-as.factor(EggSize$Tank)
EggSize$Year<-as.factor(EggSize$Year)
EggSize$Sample<-as.factor(EggSize$Sample)
EggSize$UniMesentary<-as.factor(EggSize$UniMesentary)
EggSize$UniPolyp<-as.factor(EggSize$UniPolyp)
EggSize$AverageDiameter<-as.numeric(EggSize$AverageDiameter)
EggSize$Treatment<-as.factor(EggSize$Treatment)
#Check
str(EggSize)
#Remove missing data
EggSize_complete <- EggSize %>% drop_na()   

#Summary statistics, by year
Size_Y2021 <-EggSize_complete[EggSize_complete$Year ==2021, ]
tapply(Size_Y2021$AverageDiameter, Size_Y2021$Cross, median)
tapply(Size_Y2021$AverageDiameter, Size_Y2021$Cross, mean)
tapply(Size_Y2021$AverageDiameter, Size_Y2021$Cross, range)

Size_Y2020 <-EggSize_complete[EggSize_complete$Year ==2020, ]
tapply(Size_Y2020$AverageDiameter, Size_Y2020$Cross, median)
tapply(Size_Y2020$AverageDiameter, Size_Y2020$Cross, mean)
tapply(Size_Y2020$AverageDiameter, Size_Y2020$Cross, range)

##Linear mixed effects modelling
#Build model
EggSize_lmm <- lmer(AverageDiameter ~ Cross * Year +(1|System/Sample/UniPolyp/UniMesentary)+(1|Treatment), data =EggSize)
#Summarise model
summary(EggSize_lmm)
#Compare egg sizes amongst years and experimental groups (LLF1 and LTF1)
leastsquare = lsmeans(EggSize_lmm,
                      pairwise ~ Cross:Year,
                      adjust = "tukey")
leastsquare$contrasts

#Graphic
EggSize_plot<-EggSize %>% ggplot(aes(x=Cross, y=AverageDiameter)) +
  geom_boxplot() +
  scale_x_discrete(labels=expression('LL'[F1],'LK'[F1]))+
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  scale_y_continuous(limits = c(0,0.4))+
  geom_jitter(aes(colour=Cross),size=1, alpha=0.9)  +
  theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
        legend.position = "none",
        plot.title = element_text(size=16),
        strip.text.x = element_text(size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  xlab("Parental group") +
  ggtitle("B")+
  ylab("Average oocyte diameter (mm)") +
  facet_wrap(~ Year, nrow = 2, scales = "free")
EggSize_plot

#Combined gamete plot
CombinedPlot<-plot_grid(EggCount_plot, EggSize_plot, ncol = 2, rel_widths = c(1, 1))
CombinedPlot
