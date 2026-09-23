library(jsonlite)
library(tidyverse)

json_2023 <- fromJSON("../data/2023_results.json")

choose_round <- readline("Which round (1/2): ")

season <- json_2023[['MRData']][['RaceTable']][['season']] 
round <- json_2023[['MRData']][['RaceTable']][['Races']][['round']]
raceName <- json_2023[['MRData']][['RaceTable']][['Races']][['raceName']]

# ========= DRIVERS =========
drivers_first_name_round_1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Driver']][['givenName']]
drivers_first_name_round_2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Driver']][['givenName']]
drivers_last_name_round_1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Driver']][['familyName']]
drivers_last_name_round_2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Driver']][['familyName']]
drivers_fullName_1 <- paste(drivers_first_name_round_1, drivers_last_name_round_1)
drivers_fullName_2 <- paste(drivers_first_name_round_2, drivers_last_name_round_2)
drivers <- c(drivers_fullName_1, drivers_fullName_2)

# rounds <- c(rep(1, length(drivers_first_name_round_1)), rep(2, length(drivers_first_name_round_2)))

# ========= RACE NAMES =========

raceName_1 <- raceName[1]
raceName_2 <- raceName[2]
# race_names <- c(rep(raceName_1, length(drivers_first_name_round_1)), rep(raceName_2, length(drivers_first_name_round_2)))

# ========= TEAMS =========

teams1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['Constructor']][['name']]
teams2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['Constructor']][['name']] 
# teams <- c(team1, team2)

# ========= POSITIONS =========

positions1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['position']]
positions2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['position']]
# positions <- c(position1, position2)

# ========= POINTS =========

points1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['points']]
points2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['points']]
# points <- c(points1, points2) 

# ========= GRIDS (Position the driver started) =========

grids1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['grid']]
grids2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['grid']]
# grids <- c(grid1, grid2)

# ========= LAPS (Number of 'turns' the driver completed) =========

laps1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['laps']]
laps2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['laps']]
# laps <- c(laps1, laps2)

# ========= STATUS =========

status1 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[1]][['status']]
status2 <- json_2023[['MRData']][['RaceTable']][['Races']][['Results']][[2]][['status']]
# status <- c(status1, status2)

if (choose_round == '1') {
    data_2023 <- tibble(
        season = season,
        round = round[1],
        raceName = raceName_1,
        driver = drivers_fullName_1,
        team = teams1,
        position = positions1,
        points = points1,
        grid = grids1,
        laps = laps1,
        status = status1
    )
} else if (choose_round == '2') {
    data_2023<- tibble(
        season = season,
        round = round[2],
        raceName = raceName_2,
        driver = drivers_fullName_2,
        team = teams2,
        position = positions2,
        points = points2,
        grid = grids2,
        laps = laps2,
        status = status2
    )
}

print(data_2023, width = Inf)


