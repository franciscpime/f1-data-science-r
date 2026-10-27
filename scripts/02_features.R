library(tidyverse)
library(slider)

load("../data/f1_data.RData")

f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)

# Group observations by driver and season, then order by race
# to calculate performance features using previous races only
f1_data <- f1_data |>
    group_by(driver, season) |>
    arrange(season, round) |>
    mutate(
        # Average finishing position before the current race
        prev_avg_position = lag(cummean(position)),
        # Average championship points before the current race
        prev_avg_points = lag(cummean(points)),
        # Average finishing position over the previous five races
        recent_avg_position = slide_dbl(
            lag(position), 
            mean, 
            .before = 4, 
            na.rm = TRUE
        ),
        # Average championship points over the previous five races
        recent_avg_points = slide_dbl(
            lag(points), 
            mean, 
            .before = 4, 
            na.rm = TRUE
        )
    ) |>
    filter(
        !is.na(prev_avg_position),
        !is.na(prev_avg_points)
    )

# Visualise the relationship between historical average
# finishing position and actual race finishing position
prev_avg_position_vs_position <- ggplot(
    f1_data,
    aes(x = prev_avg_position, y = position)
) +
    geom_point(alpha = 0.15, color = "steelblue") +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    scale_y_reverse(breaks = 1:20) +
    labs(
        title = "Previous Average Position vs Finishing Position",
        x = "Previous Average Finishing Position",
        y = "Actual Finishing Position"
    ) +
    theme_minimal()

ggsave(
    "../plots/prev_avg_position_vs_position.png",
    prev_avg_position_vs_position
)

# Visualise the relationship between historical average
# championship points and actual race finishing position
prev_avg_points_vs_position <- ggplot(
    f1_data,
    aes(x = prev_avg_points, y = position)
) +
    geom_point(alpha = 0.15, color = "steelblue") +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    scale_y_reverse(breaks = 1:20) +
    labs(
        title = "Previous Average Points vs Finishing Position",
        x = "Previous Average Points",
        y = "Actual Finishing Position"
    ) +
    theme_minimal()

ggsave(
    "../plots/prev_avg_points_vs_position.png",
    prev_avg_points_vs_position
)

# Training dataset: 2021 to 2023
train_data <- f1_data |>
    filter(season <= 2023) |>
    ungroup()

# Validation dataset: 2024
validation_data <- f1_data |>
    filter(season == 2024)|>
    ungroup()

# Test dataset: 2025
test_data <- f1_data |>
    filter(season == 2025) |>
    ungroup()

save(
    f1_data,
    train_data,
    validation_data,
    test_data,
    file = "../data/model_data.RData"
)