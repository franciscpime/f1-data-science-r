library(jsonlite)

url <- "https://api.jolpi.ca/ergast/f1/2024/1/results/"

api_data <- fromJSON(url, simplifyVector = FALSE)

write_json(
  api_data,
  "../data/api-teste-2024-ronda-1.json",
  pretty = TRUE,
  auto_unbox = TRUE
)

print(api_data$MRData$RaceTable$Races[1])