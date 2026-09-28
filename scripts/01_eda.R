library(tidyverse)
load("../data/f1_data.RData")

f1_data$round <- as.integer(f1_data$round) 
f1_data$position <- as.integer(f1_data$position) 
f1_data$points <- as.integer(f1_data$points) 
f1_data$grid <- as.integer(f1_data$grid) 
f1_data$laps <- as.integer(f1_data$laps) 


f1_data |> distinct(season, round, raceName)

save(f1_data, file = "../data/01_edu.RData")