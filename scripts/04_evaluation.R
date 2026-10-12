library(tidyverse)
library(rpart)
library(car)
library(lmtest)
load("../data/model_results.RData")


validation_data <- validation_data |>
    mutate(
        error = position - predicted_position,
        absolute_error = abs(error)
    ) |>
    arrange(desc(absolute_error))


# Linear Regression Evaluation
linear_regression_mae <- mean(
    abs(validation_data$position - validation_data$predicted_position)
)

linear_regression_rmse <- sqrt(
    mean((validation_data$position - validation_data$predicted_position)^2)
)

baseline_mae <- mean(
    abs(validation_data$position - validation_data$baseline_prediction)
)

baseline_rmse <- sqrt(
    mean((validation_data$position - validation_data$baseline_prediction)^2)
)

mae_improvement <- ((baseline_mae - linear_regression_mae) / baseline_mae) * 100


# Decision Tree
decision_tree_mae <- mean(
    abs(validation_data$position - validation_data$tree_prediction)
)

decision_tree_rmse <- sqrt(
    mean((validation_data$position - validation_data$tree_prediction)^2)
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


mae_by_status <- validation_data |>
                    group_by(status) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_status,
    "../results/mae_by_status.csv"
)


mae_by_grid <- validation_data |>
                group_by(grid) |>
                summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                arrange(desc(LR_mae))


write_csv(
    mae_by_grid,
    "../results/mae_by_grid.csv"
)


# Compare predicted and real positions
predict_vs_real_position <- validation_data |>
    select(driver, position, predicted_position) |>
    arrange(position)


# Real position vs predicted position
real_position_vs_predicted_position <- ggplot(
    validation_data,
    aes(x = position, y = predicted_position)
) +
    geom_abline(slope = 1, intercept = 0) +
    geom_point()

ggsave(
    "../plots/real_position_vs_predicted_position.png",
    real_position_vs_predicted_position
)


# Linear Regression error distribution
errors_distribution <- ggplot(validation_data, aes(x = error)) +
    geom_histogram()

ggsave(
    "../plots/errors_distribution.png",
    errors_distribution
)


# Model comparison
models_comparison <- ggplot(validation_data, aes(x = position)) +
    geom_col(aes(y = predicted_position)) +
    geom_col(aes(y = tree_prediction))

ggsave(
    "../plots/models_comparison.png",
    models_comparison
)


# Decision Tree error distribution
tree_errors_distribution <- ggplot(
    validation_data,
    aes(x = position - tree_prediction)
) +
    geom_histogram()

ggsave(
    "../plots/tree_errors_distribution.png",
    tree_errors_distribution
)


validation_data <- validation_data |>
                mutate(
                    grid_group = cut(
                                    grid,
                                    breaks = c(0, 5, 10, 15, 20),
                                    labels = c("1-5", "6-10", "11-15", "16-20")
                                )
                )


mae_by_grid_group <- validation_data |>
                        group_by(grid_group) |>
                        summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                        arrange(desc(LR_mae))

write_csv(
    mae_by_grid_group,
    "../results/mae_by_grid_group.csv"
)


mae_by_race <- validation_data |>
                    group_by(raceName) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_race,
    "../results/mae_by_race.csv"
)


mae_by_driver <- validation_data |>
                    group_by(driver) |>
                    summarize(LR_mae = mean(abs(position - predicted_position)), count = n()) |>
                    arrange(desc(LR_mae))

write_csv(
    mae_by_driver,
    "../results/mae_by_driver.csv"
)


improved_model_mae <- mean(
    abs(validation_data$position - validation_data$improved_prediction)
)


improved_model_rmse <- sqrt(
    mean((validation_data$position - validation_data$improved_prediction)^2)
)


recent_model_mae <- mean(
    abs(validation_data$position - validation_data$recent_prediction)
)

recent_model_rmse <- sqrt(
    mean((validation_data$position - validation_data$recent_prediction)^2)
)


recent_points_mae <- mean(
    abs(validation_data$position - validation_data$recent_points_prediction)
)

recent_points_rmse <- sqrt(
    mean((validation_data$position - validation_data$recent_points_prediction)^2)
)


both_recent_mae <- mean(
    abs(validation_data$position - validation_data$both_recent_prediction)
)

both_recent_rmse <- sqrt(
    mean((validation_data$position - validation_data$both_recent_prediction)^2)
)


log_recent_points_mae <- mean(
    abs(validation_data$position - validation_data$log_recent_points_prediction)
)

log_recent_points_rmse <- sqrt(
    mean((validation_data$position - validation_data$log_recent_points_prediction)^2)
)

metrics <- c("MAE", "RMSE")
original <- c(linear_regression_mae, linear_regression_rmse)
improved <- c(improved_model_mae, improved_model_rmse)
recent <- c(recent_model_mae, recent_model_rmse)
recent_points <- c(recent_points_mae, recent_points_rmse)
both_recent <- c(both_recent_mae, both_recent_rmse)
log_recent_points <- c(log_recent_points_mae, log_recent_points_rmse)

comparation_original_vs_improved <- tibble(
    Metrics = metrics,
    Original_Model = num(original, digits = 4),
    Improved_Model = num(improved, digits = 4),
    Recent_Model = num(recent, digits = 4),
    Recent_Points_Model = num(recent_points, digits = 4),
    Both_Recent_Model = num(both_recent, digits = 4),
    Log_Recent_Points_Model = num(log_recent_points, digits = 4)
)


write_csv(
    comparation_original_vs_improved,
    "../results/models_comparison_validation.csv"
)


# 0.94961
prev_vs_rec_avg_position <- cor(
    train_data$prev_avg_position,
    train_data$recent_avg_position
)


original_vif <- vif(model)
improved_vif <- vif(improved_model)
recent_vif <- vif(recent_model)
recent_points_vif <- vif(recent_points_model)

models <- c(rep("Original", 3), rep("Improved", 4), rep("Recent", 3))

variables <- c(
    names(original_vif),
    names(improved_vif),
    names(recent_vif)
)

vifs <- c(original_vif, improved_vif, recent_vif)

model_vif <- tibble(
    Models = models,
    Variables = variables,
    VIFs = vifs
)

write_csv(
    model_vif,
    "../results/model_vif.csv",
)

residuals_vs_fitted <- ggplot(
    validation_data,
    aes(x = improved_prediction, y = position - improved_prediction),
) +
scale_y_continuous(breaks = seq(-11, 19, by = 1)) +
scale_x_continuous(breaks = seq(0, 17, by = 1)) +
geom_point() +
geom_hline(yintercept = 0, linetype = "dashed")


ggsave(
    "../plots/residuals_vs_fitted.png",
    residuals_vs_fitted
)


residuals_qq_plot <- ggplot(
    validation_data,
    aes(sample = position - improved_prediction)
) +
scale_y_continuous(breaks = seq(-12, 29, by = 1)) +
scale_x_continuous(breaks = seq(-3, 3, by = 1)) +
stat_qq() +
stat_qq_line()

ggsave(
    "../plots/residuals_qq_plot.png",
    residuals_qq_plot
)

validation_outliers <- validation_data |>
                        mutate(
                            residual = validation_data$position - validation_data$improved_prediction,
                            abs_residual = abs(residual)
                            ) |>
                            arrange(desc(abs_residual)) |>
                            slice_head(n = 10) |>
                            select(raceName, driver, grid, position, improved_prediction, residual, abs_residual, status)


write_csv(
    validation_outliers,
    "../results/validation_outliers.csv"
)


validation_mae_by_status <- validation_data |>
                                group_by(status) |>
                                summarize(mae_by_status = mean(abs(position - improved_prediction)), count = n()) |>
                                arrange(desc(mae_by_status))


write_csv(
    validation_mae_by_status,
    "../results/validation_mae_by_status.csv"
)


bp_test <- bptest(improved_model)
recent_points_bp_test <- bptest(recent_points_model)

cooks_distance <- cooks.distance(improved_model)

cooks_threshold = 4 / nobs(improved_model)

influential_count <- sum(cooks_distance > cooks_threshold)

influential_observations <- train_data |>
                                mutate(cooks_distance = cooks_distance) |>
                                arrange(desc(cooks_distance)) |>
                                slice_head(n = 10) |>
                                select(season, raceName, driver, grid, position, status, cooks_distance)

write_csv(
    influential_observations,
    "../results/influential_observations.csv"
)

# crPlots(improved_model)
crPlots(recent_points_model)
print(validation_data, width = Inf)