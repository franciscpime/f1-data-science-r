library(tidyverse)
load("../data/f1_data.RData")

f1_data$round <- as.integer(f1_data$round) 
f1_data$position <- as.integer(f1_data$position) 
f1_data$points <- as.integer(f1_data$points) 
f1_data$grid <- as.integer(f1_data$grid) 
f1_data$laps <- as.integer(f1_data$laps) 


correlation_by_season <- f1_data |>
    group_by(season) |>
    summarise(correlation = cor(grid, position))

write_csv(correlation_by_season, "../results/correlations_by_season.csv")

position_distribution <- ggplot(f1_data, aes(x = position)) +
                        geom_bar()

ggsave("../plots/position_distribution.png")


grid_vs_position <- ggplot(f1_data, aes(x = grid, y = position)) +
                    geom_point()

ggsave("../plots/grid_vs_position.png")


grid_vs_position_season <- ggplot(f1_data, aes(x = grid, y = position)) +
                            geom_point() +
                            facet_wrap(~ season)

ggsave("../plots/grid_vs_position_season.png")


pilots_performance <- f1_data |>
                    group_by(driver) |>
                    summarize(average = mean(position, na.rm = TRUE)) |>
                    arrange(average)

write_csv(pilots_performance, "../results/pilots_performance.csv")


teams_performance <- f1_data |>
                    group_by(team) |>
                    summarize(average = mean(position, na.rm = TRUE)) |>
                    arrange(average)

write_csv(teams_performance, "../results/teams_performance.csv")

print(team_performance)
save(f1_data, file = "../data/01_edu.RData")