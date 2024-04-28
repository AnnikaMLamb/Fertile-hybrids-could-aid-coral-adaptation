##R script for analyses of hybrid and purebred gamete fertilisation data
#Data obtained using methods described in manuscript -  Fertile hybrids could aid coral adaptation - methods
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

#Load packages 
library(ggplot2)
library(tidyr)
library(brms)
library(shinystan)
library(emmeans)


### Fertilisation data analyses
##Import data
Fert <- read.table('FertilisationData.csv', header=T, sep=',')
##Data modifications
Crosses<-c("LL x LT","LL x LL","LT x LL","LT x LT")
Fert_crosses<-Fert[Fert$Cross %in% Crosses,]
Fert_crosses<-Fert_crosses[Fert_crosses$TotalCount >99, ]
Fert_crosses$Cross<-as.factor(Fert_crosses$Cross)
Fert_crosses$Mother<-as.factor(Fert_crosses$Mother)
Fert_crosses$Father<-as.factor(Fert_crosses$Father)
Fert_crosses$Combo<-as.factor(Fert_crosses$Combo)
Fert_crosses$Replicate<-as.factor(Fert_crosses$Replicate)
#Check
str(Fert_crosses)
#Summarise
Fert_ByCross<-summarySE(Fert_crosses, measurevar="Percentage", groupvars=c("Cross"),conf.interval=0.95)
Fert_ByCross

#Plot
ggplot(Fert_crosses,aes(x = Cross, y = Percentage))+geom_boxplot()+scale_x_discrete(labels=expression('LL'[F1]*'XLL'[F1],'LL'[F1]*'XLT'[F1], 'LT'[F1]*'XLL'[F1], 'LT'[F1]*'XLT'[F1]))+
  ylim(0, 100) + ylab("Percentage fertilised") + xlab("Cross")+
  theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
        legend.text = element_text(size = 14), legend.title = element_text(size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  geom_text(data=Fert_ByCross, (aes(x=factor(Cross), y=median*0.97, label=paste("n =",N))))


## Bayesian generalised linear mixed effects model
#Build model
fert.form <- bf(FertilisedEggCount ~ Cross + (1|Mother) + (1|Father) + (1|SpecificCombo),
                family=poisson)
#Run model
Fert.brms <- brm(fert.form, data=Fert_crosses,
                 iter=5000, warmup=2000,thin=5,
                 refresh=0, chains=4)
#Check run
plot(Fert.brms)
#Summarise results
summary(Fert.brms)
#Compare groups
Fert_emmeans <- emmeans(Fert.brms, ~ Cross)
Fert_emmeans
summary(pairs(Fert_emmeans), point.est = median)
contrast(Fert_emmeans, method = "pairwise", adjust = "bonferroni")
