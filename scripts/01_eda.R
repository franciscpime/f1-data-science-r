library(tidyverse)

load("../data/f1_data.RData")

f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)

# Calculate the correlation between starting and finishing
# positions for each season
correlation_by_season <- f1_data |>
    group_by(season) |>
    summarise(correlation = cor(grid, position))

write_csv(
    correlation_by_season,
    "../results/correlations_by_season.csv"
)

# Visualise the frequency of each finishing position
position_distribution <- ggplot(
    f1_data,
    aes(x = position)
) +
    geom_bar(
        fill = "steelblue",
        color = "white"
    ) +
    scale_x_continuous(breaks = 1:20) +
    labs(
        title = "Distribution of Finishing Positions",
        x = "Finishing Position",
        y = "Number of Observations"
    ) +
    theme_minimal() +
    theme(
        plot.title = element_text(
            face = "bold",
            hjust = 0.5
        )
    )

ggsave(
    "../plots/position_distribution.png",
    position_distribution,
    width = 10,
    height = 5,
    dpi = 300
)

# Compare starting grid positions with finishing positions
grid_vs_position <- ggplot(f1_data, aes(x = grid, y = position)) +
    geom_col() +
    labs(title = "Grid vs Position")

ggsave(
    "../plots/grid_vs_position.png",
    grid_vs_position
)

# Examine the relationship between starting and finishing
# positions separately for each season
grid_vs_position_season <- ggplot(f1_data, aes(x = grid, y = position)) +
    geom_point(alpha = 0.15) +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    facet_wrap(~ season) +
    labs(
        title = "Grid vs Finishing Position, Correlation by Season",
        x = "Starting Position (Grid)",
        y = "Finishing Position"
    )

ggsave(
    "../plots/grid_vs_position_season.png",
    grid_vs_position_season
)

# Calculate average finishing position for each driver
pilots_performance <- f1_data |>
    group_by(driver) |>
    summarize(average = mean(position, na.rm = TRUE)) |>
    arrange(average)

write_csv(
    pilots_performance,
    "../results/pilots_performance.csv"
)

# Calculate average finishing position for each constructor
teams_performance <- f1_data |>
    group_by(team) |>
    summarize(average = mean(position, na.rm = TRUE)) |>
    arrange(average)

write_csv(
    teams_performance,
    "../results/teams_performance.csv"
)