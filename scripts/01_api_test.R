library(jsonlite)

url <- "https://api.jolpi.ca/ergast/f1/2024/1/results/"

resposta_api <- fromJSON(url, simplifyVector = FALSE)

str(resposta_api, max.level = 2)

write_json(
  resposta_api,
  "data/api-teste-2024-ronda-1.json",
  pretty = TRUE,
  auto_unbox = TRUE
)