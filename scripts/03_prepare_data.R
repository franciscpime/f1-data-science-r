library(jsonlite)
library(tidyverse)

json_2021 <- fromJSON("../data/2021_results.json")

season <- json_2021[['MRData']][['RaceTable']][['season']] 
round <- json_2021[['MRData']][['RaceTable']][['Races']][['round']]
raceName <- json_2021[['MRData']][['RaceTable']][['Races']][['raceName']]

# ========= DRIVERS =========
drivers_first_name_round_1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Driver']][['givenName']]
drivers_first_name_round_2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Driver']][['givenName']]
drivers_last_name_round_1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Driver']][['familyName']]
drivers_last_name_round_2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Driver']][['familyName']]
drivers_fullName_1 <- paste(drivers_first_name_round_1, drivers_last_name_round_1)
drivers_fullName_2 <- paste(drivers_first_name_round_2, drivers_last_name_round_2)
drivers <- c(drivers_fullName_1, drivers_fullName_2)

rounds <- c(rep(1, length(drivers_first_name_round_1)), rep(2, length(drivers_first_name_round_2)))

# ========= RACE NAMES =========

raceName_1 <- raceName[1]
raceName_2 <- raceName[2]
race_names <- c(rep(raceName_1, length(drivers_first_name_round_1)), rep(raceName_2, length(drivers_first_name_round_2)))

# ========= TEAMS =========

team1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Constructor']][['name']]
team2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Constructor']][['name']] 
teams <- c(team1, team2)

# ========= POSITIONS =========

position1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['position']]
position2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['position']]
positions <- c(position1, position2)

# ========= POINTS =========

points1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['points']]
points2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['points']]
points <- c(points1, points2) 

# ========= GRIDS (Position the driver started) =========

grid1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['grid']]
grid2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['grid']]
grids <- c(grid1, grid2)

# ========= LAPS (Number of 'turns' the driver completed) =========

laps1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['laps']]
laps2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['laps']]
laps <- c(laps1, laps2)

# ========= STATUS =========

status1 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['status']]
status2 <- json_2021[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['status']]
status <- c(status1, status2)

data_2021 <- tibble(
        season = season,
        round = rounds,
        raceName = race_names,
        driver = drivers,
        team = teams,
        position = positions,
        points = points,
        grid = grids,
        laps = laps,
        status = status
    )

print(data_2021)


