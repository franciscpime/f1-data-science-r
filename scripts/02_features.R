library(tidyverse)

load("../data/f1_data.RData")

f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)

f1_data <- f1_data |>
    group_by(driver, season) |>
    arrange(season, round) |>
    mutate(
        prev_avg_position = lag(cummean(position)),
        prev_avg_points = lag(cummean(points))
    ) |>
    filter(
        !is.na(prev_avg_position),
        !is.na(prev_avg_points)
    )

prev_avg_position_vs_position <- ggplot(
    f1_data,
    aes(x = prev_avg_position, y = position)
) +
    geom_col()

ggsave(
    "../plots/prev_avg_position_vs_position.png",
    prev_avg_position_vs_position
)

prev_avg_points_vs_position <- ggplot(
    f1_data,
    aes(x = prev_avg_points, y = position)
) +
    geom_col()

ggsave(
    "../plots/prev_avg_points_vs_position.png",
    prev_avg_points_vs_position
)

train_data <- f1_data |>
    filter(season <= 2024) |>
    ungroup()

test_data <- f1_data |>
    filter(season == 2025) |>
    ungroup()

save(
    f1_data,
    train_data,
    test_data,
    file = "../data/model_data.RData"
)