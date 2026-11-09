library(tidyverse)
load("../../data/processed/data_2021.RData")
load("../../data/processed/data_2022.RData")
load("../../data/processed/data_2023.RData")
load("../../data/processed/data_2024.RData")
load("../../data/processed/data_2025.RData")

# Combine all seasons into a single dataset
f1_data <- bind_rows(
    data_2021,
    data_2022,
    data_2023,
    data_2024,
    data_2025
)

save(f1_data, file = "../../data/processed/f1_data.RData")