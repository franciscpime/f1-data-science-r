library(jsonlite)
library(tidyverse)

# Load historical race results from JSON
json_2021 <- fromJSON("../data/2021_results_full.json")

# Extract season and race information
season <- json_2021[["MRData"]][["RaceTable"]][["season"]]
round <- json_2021[["MRData"]][["RaceTable"]][["Races"]][["round"]]
raceName <- json_2021[["MRData"]][["RaceTable"]][["Races"]][["raceName"]]

# Create a list to store data from each race
round_data <- list()

# Extract driver results for every race
for (i in seq_along(round)) {

    results <- json_2021[["MRData"]][["RaceTable"]][["Races"]][["Results"]][[i]]

    # Driver information
    drivers_first_name <- results[["Driver"]][["givenName"]]
    drivers_last_name <- results[["Driver"]][["familyName"]]
    drivers_fullName <- paste(drivers_first_name, drivers_last_name)

    # Race and constructor information
    races_names <- raceName[i]
    teams <- results[["Constructor"]][["name"]]

    # Race results
    positions <- results[["position"]]
    points <- results[["points"]]
    grids <- results[["grid"]]
    laps <- results[["laps"]]
    status <- results[["status"]]

    # Create a table for the current race
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

    # Store the current race data
    round_data[[i]] <- current_round
}

# Combine all races into one dataset
data_2021 <- bind_rows(round_data)

save(data_2021, file = "../data/data_2021.RData")
print(data_2021, width = Inf)