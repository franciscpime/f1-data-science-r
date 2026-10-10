library(tidyverse)
library(rpart)
load("../data/model_results.RData")


test_data <- test_data |>
    mutate(
        error = position - predicted_position,
        absolute_error = abs(error)
    ) |>
    arrange(desc(absolute_error))


# Linear Regression Evaluation
linear_regression_mae <- mean(
    abs(test_data$position - test_data$predicted_position)
)

linear_regression_rmse <- sqrt(
    mean((test_data$position - test_data$predicted_position)^2)
)

baseline_mae <- mean(
    abs(test_data$position - test_data$baseline_prediction)
)

baseline_rmse <- sqrt(
    mean((test_data$position - test_data$baseline_prediction)^2)
)

mae_improvement <- ((baseline_mae - linear_regression_mae) / baseline_mae) * 100


# Decision Tree
decision_tree_mae <- mean(
    abs(test_data$position - test_data$tree_prediction)
)

decision_tree_rmse <- sqrt(
    mean((test_data$position - test_data$tree_prediction)^2)
)


models = c("Baseline", "Linear Regression", "Decision Tree")
mae = c(baseline_mae, linear_regression_mae, decision_tree_mae)
rmse = c(baseline_rmse, linear_regression_rmse, decision_tree_rmse)

models_performance <- tibble(
    model = models,
    MAE = mae,
    RMSE = rmse
)

write_csv(
    models_performance,
    "../results/models_performance.csv"
)


mae_by_status <- test_data |>
                    group_by(status) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_status,
    "../results/mae_by_status.csv"
)


mae_by_grid <- test_data |>
                group_by(grid) |>
                summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                arrange(desc(LR_mae))


write_csv(
    mae_by_grid,
    "../results/mae_by_grid.csv"
)


# Compare predicted and real positions
predict_vs_real_position <- test_data |>
    select(driver, position, predicted_position) |>
    arrange(position)


# Real position vs predicted position
real_position_vs_predicted_position <- ggplot(
    test_data,
    aes(x = position, y = predicted_position)
) +
    geom_abline(slope = 1, intercept = 0) +
    geom_point()

ggsave(
    "../plots/real_position_vs_predicted_position.png",
    real_position_vs_predicted_position
)


# Linear Regression error distribution
errors_distribution <- ggplot(test_data, aes(x = error)) +
    geom_histogram()

ggsave(
    "../plots/errors_distribution.png",
    errors_distribution
)



# Model comparison
models_comparison <- ggplot(test_data, aes(x = position)) +
    geom_col(aes(y = predicted_position)) +
    geom_col(aes(y = tree_prediction))

ggsave(
    "../plots/models_comparison.png",
    models_comparison
)


# Decision Tree error distribution
tree_errors_distribution <- ggplot(
    test_data,
    aes(x = position - tree_prediction)
) +
    geom_histogram()

ggsave(
    "../plots/tree_errors_distribution.png",
    tree_errors_distribution
)


test_data <- test_data |>
                mutate(
                    grid_group = cut(
                                    grid,
                                    breaks = c(0, 5, 10, 15, 20),
                                    labels = c("1-5", "6-10", "11-15", "16-20")
                                )
                )


mae_by_grid_group <- test_data |>
                        group_by(grid_group) |>
                        summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                        arrange(desc(LR_mae))

write_csv(
    mae_by_grid_group,
    "../results/mae_by_grid_group.csv"
)


mae_by_race <- test_data |>
                    group_by(raceName) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_race,
    "../results/mae_by_race.csv"
)


mae_by_driver <- test_data |>
                    group_by(driver) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_driver,
    "../results/mae_by_driver"
)


improved_model_mae <- mean(
    abs(test_data$position - test_data$improved_prediction)
)


improved_model_rmse <- sqrt(
    mean((test_data$position - test_data$improved_prediction)^2)
)


recent_model_mae <- mean(
    abs(test_data$position - test_data$recent_prediction)
)

recent_model_rmse <- sqrt(
    mean((test_data$position - test_data$recent_prediction)^2)
)


metrics <- c("MAE", "RMSE")
original <- c(linear_regression_mae, linear_regression_rmse)
improved <- c(improved_model_mae, improved_model_rmse)
recent <- c(recent_model_mae, recent_model_rmse)

comparation_original_vs_improved <- tibble(
    Metrics = metrics,
    Original_Model = num(original, digits = 4),
    Improved_Model = num(improved, digits = 4),
    Recent_Model = num(recent, digits = 4) 
)

# 0.94961
prev_vs_rec_avg_position <- cor(
    train_data$prev_avg_position,
    train_data$recent_avg_position
)

print(test_data, width = Inf)