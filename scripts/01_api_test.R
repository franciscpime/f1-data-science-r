library(jsonlite)

season <- 2025
offset <- 0
all_races <- list()

for (i in 1:5) {
    url <- paste0(
      "https://api.jolpi.ca/ergast/f1/",
      season,
      "/results/?limit=100&offset=",
      offset
  )

  test <- fromJSON(url, simplifyVector = FALSE)

  print(url)

  offset <- offset + 100
  all_races[[i]] <- test$MRData$RaceTable$Races
}

all_races <- unlist(all_races, recursive = FALSE)

api_data <- test
api_data$MRData$RaceTable$Races <- all_races




# url <- "https://api.jolpi.ca/ergast/f1/2025/1/results/"

# api_data <- fromJSON(url, simplifyVector = FALSE)

write_json(
    api_data,
    "../data/2025_results_full.json",
    pretty = TRUE,
    auto_unbox = TRUE
)
