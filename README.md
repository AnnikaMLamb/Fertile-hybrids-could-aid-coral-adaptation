# Fertile corals could aid coral adaptation
> This repository contains the code and data required to reproduce analyses conducted by Annika Lamb (AIMS) for the manuscript "Fertile corals could aid coral adaptation".
>
> Data is avaiable in .csv format and code is written in R.

# Data
Repository contains six datasets with data on gametes, gamete fertilisation, and spawning behaviour of hybrid and purbred corals.

## Egg count data
>EggCountData_2020-2021.csv
>
>Number of eggs in the mesentaries of dissected hybrid and purebred corals. Dataset comprised of:
- SampleID: unique colony ID number
+ Cross: hybrid (LT) or purebred (LL) experimental group
* Tank: holding tank ID
- System: holding system ID
+ Polyp: polyp replicate
* UniPolyp: unique polyp ID
- Eggs(Sample): whether the sample contained eggs (Y) or not (N)
+ Mesentary: replicate mesentary
* Count: number of eggs per mesentary
- Year: sampling year

## Egg size data 
>EggSize_2020-2021.csv
>
>Size of eggs in the mesentaries of dissected hybrid and purebred corals. Dataset comprised of:
- SampleID: unique colony ID number
+ Cross: hybrid (LT) or purebred (LL) experimental group
* Tank: holding tank ID
- System: holding system ID
+ Year: sampling year
* Polyp: polyp replicate
- UniPolyp: unique polyp ID
+ Mesentary: replicate mesentary
* UniMesentary: unique mesentary ID
- Egg: replicate egg
+ D1: longest diameter (mm)
* D2: diameter perpendicular to longest diameter (mm)
- AverageDiameter: mean of D1 and D2

## Fertilisation data
>FertilisationData.csv
>
>Fertilisation success of hybrid and purebred gametes. Dataset comprised of:
- Combo: IDs of cross-fertilised (X) colonies
* Mother: Dam of cross
- Father: Sire of cross
+ Cross: purebred cross (LL x LL), backcross between purebred LL dam x hybrid LT sire, backcross between hybrid LT dam x purebred LL sire, F2 hybrid cross (LT x LT), no sperm control, or selfing control cross. 
* FertilisationTime: time of gamete mixing (fertilisation)
- FertCheckTime: time of fertilisation count
+ UnfertilisedEggCount: number of unfertilised eggs in well
* FertilisedEggCount: number of fertilised eggs (dividing embryos) in well
- ProportionFertilised: proportion of fertilised eggs out of the total
+ Percentage: percentage of fertilised eggs out of the total
* TotalCount: total number of eggs counted in reaction
- Replicate: fertilisation reaction replicate of duplicates
+ NightOf: fertilisation date

## Spawning data
>SpawningData.csv
>
>Spawning observations of hybrid and purebred corals. Dataset comprised of:
- Coral: unique colony ID number
+ Cross: hybrid (LT) or purebred (LL) experimental group
* Tank: holding tank ID
- System: holding system ID
+ SpawningDate: date of observation
* Spawned: colony observed (Y) to spawn or not (N) spawn.

## Spawning percentages
>SpawningPercentages.csv
>
>Percentage of hybrid and purbred corals spawning on each night of spawning observations in 2021. Dataset comprised of:
- Cross: hybrid (LT) or purebred (LL) experimental group
+ Date: date of observations
* Percentage: percentage of colonies that spawned
- Proportion: proportion of colonies that spawned
+ Spawned: number of colonies that spawned
* NotSpawned: number of colonies that did not spawn

## Spawning time data
>TimeData.csv
>
>Time of observations of spawning and pre-spawning behaviour in hybrid and purebred corals. Dataset comprised of:
- ColonyID: unique colony ID number
+ Cross: hybrid (LT) or purebred (LL) experimental group
* System: holding system ID
- Spawned: whether the colony spawned (Y) or did not spawn (N)
+ SettingTime: time the colony was observed to be displaying pre-spawning behaviour called "setting"
* SpawningTime: time the colony was observed to be spawning
- Sunset: time of artificial sunset
+ SpawningMinutes: number of minutes after sunset that spawning was observed
* SettingMinutes: number of minutes after sunset that pre-spawning behaviour called 'setting' was observed
- Date: date of observation

# Code
Repository contains three scripts for analysing data on gametes, gamete fertilisation, and spawning behaviour of hybrid and purbred corals.
## Gamete data analyses
>R code for analysing hybrid and purebred gamete data.
>
>Requires EggCountData_2020-2021.csv and EggSize_2020-2021.csv
## Spawning pattern analyses
>R code for analysing hybrid and purebred spawning patterns.
>
>Requires SpawningData_ByNight.csv, SpawningPercentages.csv, and TimeData.csv
## Fertilisation data analyses
>R code for analysing fertilisation data on hybrid and purebred gametes.
>
>Requires FertilisationData.csv

