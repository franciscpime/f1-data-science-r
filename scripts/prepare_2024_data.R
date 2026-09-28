library(jsonlite)
library(tidyverse)

json_2024 <- fromJSON("../data/2024_results_full.json")

season <- json_2024[['MRData']][['RaceTable']][['season']] 
round <- json_2024[['MRData']][['RaceTable']][['Races']][['round']]
raceName <- json_2024[['MRData']][['RaceTable']][['Races']][['raceName']]

round_data <- list()

for (i in seq(1, length(round))) {
    drivers_first_name <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['Driver']][['givenName']]
    drivers_last_name <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['Driver']][['familyName']]
    drivers_fullName <- paste(drivers_first_name, drivers_last_name)
    races_names <- raceName[i]
    teams <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['Constructor']][['name']]
    positions <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['position']]
    points <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['points']]
    grids <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['grid']]
    laps <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['laps']]
    status <- json_2024[['MRData']][['RaceTable']][['Races']][['Results']][[i]][['status']]

    current_round <- tibble(
        season = season,
        round = round[i],
        raceName = races_names,
        driver = drivers_fullName,
        team = teams,
        position = positions,
        points = points,
        grid = grids,
        laps = laps,
        status = status
    )

    round_data[[i]] <- current_round
}

data_2024 <- bind_rows(round_data)

save(data_2024, file = "../data/data_2024.RData")
print(data_2024, width = Inf)