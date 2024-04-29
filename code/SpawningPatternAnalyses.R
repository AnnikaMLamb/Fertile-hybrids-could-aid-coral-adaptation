##R script for analyses of hybrid and purebred spawning patterns
#Data obtained using methods described in manuscript -  Fertile hybrids could aid coral adaptation

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

#Load packages 
library(nlme)
library(lme4)
library(multcomp)
library(ggplot2)
library(tidyr)
library(plyr)
library(emmeans)

###Spawning activity analyses
##Import data
Spawn_ByNight <- read.table('SpawningData_ByNight.csv', header=T, sep=',')
##Data modifications
Spawn_ByNight$Cross<-as.factor(Spawn_ByNight$Cross)
Spawn_ByNight$Tank<-as.factor(Spawn_ByNight$Tank)
Spawn_ByNight$Treatment<-as.factor(Spawn_ByNight$Treatment)
Spawn_ByNight$System<-as.factor(Spawn_ByNight$System)
Spawn_ByNight$SpawningDate<-as.factor(Spawn_ByNight$SpawningDate)
Spawn_ByNight$Spawned<-as.factor(Spawn_ByNight$Spawned)
Spawn_ByNight$Coral<-as.factor(Spawn_ByNight$Coral)
str(Spawn_ByNight)

##Generalised linear mixed effects model
#Model
spawn_mod1<-glmer(Spawned ~ Cross + (1|System/Coral) + (1|SpawningDate), data = Spawn_ByNight, family = binomial())
#Summary
summary(spawn_mod1)

##Graphic 
#Import data
SpawningPercentages <- read.table('SpawningPercentages.csv', header=T, sep=',')
#Data modification
SpawningPercentages$Cross<-as.factor(SpawningPercentages$Cross)
str(SpawningPercentages)
#Plot
ggplot(SpawningPercentages, aes(fill=Cross, y=Percentage, x=Date)) + 
  ylab("Percentage spawned") +
  scale_y_continuous(limits = c(0,75), expand = expansion(mult = c(0, .1))) +
  geom_bar(position="dodge", stat="identity") +
  theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
        legend.text = element_text(size = 14), legend.title = element_text(size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_fill_manual(name="Parental group",labels = expression('LL'[F1], 'LT'[F1]),  values = c("salmon","turquoise3"))


###Spawning and setting time analyses
##Import data
Time <- read.table('TimeData.csv', header=T, sep=',')
#Data modifications
Time$ColonyID<-as.factor(Time$ColonyID)
Time <- Time %>% drop_na(System)
Spawning <- Time %>% drop_na(SpawningMinutes)
Setting <- Time %>% drop_na(SettingMinutes)

##Spawning time analyses
#Linear mixed effects model
Spawning_mod1<-lme(SpawningMinutes~Cross, random= ~1|System/ColonyID, data=Spawning)
summary(Spawning_mod1)
#Summarise spawning times
Spawning_ByCross<-summarySE(Spawning, measurevar="SpawningMinutes", groupvars=c("Cross"),conf.interval=0.95)
Spawning_ByCross
#Graphic
ggplot(Spawning,aes(x = Cross, y = SpawningMinutes))+geom_boxplot()+scale_x_discrete(labels=expression('LL'[F1],'LT'[F1]))+
  ylim(0, 185) + ylab("Minutes after sunset") + xlab("F1 parental group")+
  theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
        legend.text = element_text(size = 14), legend.title = element_text(size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  geom_text(data=Spawning_ByCross, (aes(x=factor(Cross), y=132, label=paste("n =",N))))
