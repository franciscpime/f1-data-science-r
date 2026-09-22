library(jsonlite)

url <- "https://api.jolpi.ca/ergast/f1/2025/results/"
api_data <- fromJSON(url, simplifyVector = FALSE)

write_json(
  api_data,
  "../data/2025_results.json",
  pretty = TRUE,
  auto_unbox = TRUE
)

print(api_data)