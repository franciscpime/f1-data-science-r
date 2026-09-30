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


f1_data <- f1_data |>
            group_by(driver, season) |>
            arrange(season, round) |>
            mutate(prev_avg_position = lag(cummean(position)), prev_avg_points = lag(cummean(points))) |>
            filter(!is.na(prev_avg_position), !is.na(prev_avg_points))

prev_avg_position_vs_position <- ggplot(f1_data, aes(x = prev_avg_position, y = position)) +
                                geom_point() 

ggsave("../plots/prev_avg_position_vs_position.png")

prev_avg_points_vs_position <- ggplot(f1_data, aes(x = prev_avg_points, y = position)) +
                                geom_point() 

ggsave("../plots/prev_avg_points_vs_position.png")


train_data <- f1_data |>
                filter(season <= 2024)

test_data <- f1_data |>
                filter(season == 2025) 

test_data <- test_data |>
                ungroup() |>
                mutate(predicted_position = predict(model, newdata = test_data), baseline_prediction = mean(train_data$position))

mae <- mean(abs(test_data$position - test_data$predicted_position))

predict_vs_real_position <- test_data |>
                            select(driver, position, predicted_position) |>
                            arrange(position)

rmse <- sqrt(mean((test_data$position - test_data$predicted_position)^2))

baseline_mae <- mean(abs(test_data$position - test_data$baseline_prediction))

mae_improvement <- ((baseline_mae - mae) / baseline_mae) * 100

print(test_data, width = Inf)
save(f1_data, file = "../data/01_edu.RData")