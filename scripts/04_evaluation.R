library(tidyverse)
library(rpart)
library(car)
library(lmtest)

load("../data/model_results.RData")

# Calculate prediction errors for the 2024 validation dataset
validation_data <- validation_data |>
    mutate(
        error = position - predicted_position,
        absolute_error = abs(error)
    ) |>
    arrange(desc(absolute_error))

# Mean Absolute Error (MAE)
linear_regression_mae <- mean(
    abs(validation_data$position - validation_data$predicted_position)
)

# Root Mean Squared Error (RMSE)
linear_regression_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$predicted_position)^2
    )
)

# Evaluate predictions based on the training-set mean
baseline_mae <- mean(
    abs(validation_data$position - validation_data$baseline_prediction)
)

baseline_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$baseline_prediction)^2
    )
)

# Calculate percentage improvement over the baseline MAE
mae_improvement <- (
    (baseline_mae - linear_regression_mae) / baseline_mae
) * 100

# Decision Tree Evaluation
decision_tree_mae <- mean(
    abs(validation_data$position - validation_data$tree_prediction)
)

decision_tree_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$tree_prediction)^2
    )
)

# Initial Model Performance Comparison
# Compare baseline, original linear regression and decision tree
models <- c("Baseline", "Linear Regression", "Decision Tree")

mae <- c(
    baseline_mae,
    linear_regression_mae,
    decision_tree_mae
)

rmse <- c(
    baseline_rmse,
    linear_regression_rmse,
    decision_tree_rmse
)

models_performance <- tibble(
    model = models,
    MAE = mae,
    RMSE = rmse
)

write_csv(
    models_performance,
    "../results/models_performance.csv"
)

# Original Linear Regression: Error by Race Status
# Calculate MAE for each race completion status
mae_by_status <- validation_data |>
    group_by(status) |>
    summarize(
        LR_mae = mean(abs(position - predicted_position)),
        count = n()
    ) |>
    arrange(desc(LR_mae))

write_csv(
    mae_by_status,
    "../results/mae_by_status.csv"
)

# Original Linear Regression: Error by Starting Grid
# Calculate MAE for each starting grid position
mae_by_grid <- validation_data |>
    group_by(grid) |>
    summarize(
        LR_mae = mean(abs(position - predicted_position)),
        count = n()
    ) |>
    arrange(desc(LR_mae))

write_csv(
    mae_by_grid,
    "../results/mae_by_grid.csv"
)

# Actual vs Predicted Finishing Positions
# Create a comparison table for the original regression model
predict_vs_real_position <- validation_data |>
    select(driver, position, predicted_position) |>
    arrange(position)

# Plot actual and predicted finishing positions
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

# Original Linear Regression: Error Distribution
# Visualise the distribution of validation prediction errors
errors_distribution <- ggplot(
    validation_data,
    aes(x = error)
) +
    geom_histogram(
        binwidth = 1,
        fill = "steelblue",
        color = "white"
    ) +
    geom_vline(
        xintercept = 0,
        color = "red",
        linetype = "dashed"
    ) +
    labs(
        title = "Distribution of Prediction Errors",
        subtitle = "Original Linear Regression, 2024 Validation",
        x = "Prediction Error (Actual - Predicted)",
        y = "Number of Observations"
    ) +
    theme_minimal() +
    theme(
        plot.title = element_text(
            face = "bold",
            hjust = 0.5
        ),
        plot.subtitle = element_text(
            hjust = 0.5
        )
    )

ggsave(
    "../plots/errors_distribution.png",
    errors_distribution,
    width = 10,
    height = 5,
    dpi = 300
)

# Linear Regression vs Decision Tree Visualisation
# Reshape predictions for side by side model comparison
models_comparison_data <- validation_data |>
    select(position, predicted_position, tree_prediction) |>
    pivot_longer(
        cols = c(predicted_position, tree_prediction),
        names_to = "model",
        values_to = "prediction"
    ) |>
    mutate(
        model = dplyr::recode(
            model,
            predicted_position = "Linear Regression",
            tree_prediction = "Decision Tree"
        )
    )

# Compare actual and predicted positions for both models
models_comparison <- ggplot(
    models_comparison_data,
    aes(x = position, y = prediction)
) +
    geom_point(
        alpha = 0.25,
        color = "steelblue",
        size = 1.5
    ) +
    geom_abline(
        slope = 1,
        intercept = 0,
        linetype = "dashed",
        color = "red"
    ) +
    facet_wrap(~ model) +
    coord_equal() +
    labs(
        title = "Actual vs Predicted Finishing Positions",
        subtitle = "Linear Regression and Decision Tree, 2024 Validation",
        x = "Actual Finishing Position",
        y = "Predicted Finishing Position"
    ) +
    theme_minimal(base_size = 12)

ggsave(
    "../plots/models_comparison.png",
    models_comparison,
    width = 11,
    height = 5,
    dpi = 300
)

# Decision Tree: Error Distribution
# Visualise prediction errors from the decision tree
tree_errors_distribution <- ggplot(
    validation_data,
    aes(x = position - tree_prediction)
) +
    geom_histogram(
        binwidth = 1,
        fill = "steelblue",
        color = "white"
    ) +
    geom_vline(
        xintercept = 0,
        color = "red",
        linetype = "dashed"
    ) +
    labs(
        title = "Distribution of Prediction Errors",
        subtitle = "Decision Tree, 2024 Validation",
        x = "Prediction Error (Actual - Predicted)",
        y = "Number of Observations"
    ) +
    theme_minimal() +
    theme(
        plot.title = element_text(
            face = "bold",
            hjust = 0.5
        ),
        plot.subtitle = element_text(
            hjust = 0.5
        )
    )

ggsave(
    "../plots/tree_errors_distribution.png",
    tree_errors_distribution,
    width = 10,
    height = 5,
    dpi = 300
)

# Original Linear Regression: Error by Grid Group
# Divide starting grid positions into four groups
validation_data <- validation_data |>
    mutate(
        grid_group = cut(
            grid,
            breaks = c(0, 5, 10, 15, 20),
            labels = c("1-5", "6-10", "11-15", "16-20")
        )
    )

# Calculate MAE within each starting grid group
mae_by_grid_group <- validation_data |>
    group_by(grid_group) |>
    summarize(
        LR_mae = mean(abs(position - predicted_position)),
        count = n()
    ) |>
    arrange(desc(LR_mae))

write_csv(
    mae_by_grid_group,
    "../results/mae_by_grid_group.csv"
)

# Original Linear Regression: Error by Race
# Calculate MAE for each Grand Prix
mae_by_race <- validation_data |>
    group_by(raceName) |>
    summarize(
        LR_mae = mean(abs(position - predicted_position)),
        count = n()
    ) |>
    arrange(desc(LR_mae))

write_csv(
    mae_by_race,
    "../results/mae_by_race.csv"
)

# Original Linear Regression: Error by Driver
# Calculate MAE for each driver
mae_by_driver <- validation_data |>
    group_by(driver) |>
    summarize(
        LR_mae = mean(abs(position - predicted_position)),
        count = n()
    ) |>
    arrange(desc(LR_mae))

write_csv(
    mae_by_driver,
    "../results/mae_by_driver.csv"
)


# Improved Linear Regression Evaluation
improved_model_mae <- mean(
    abs(validation_data$position - validation_data$improved_prediction)
)

improved_model_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$improved_prediction)^2
    )
)

# Recent Position Linear Regression Evaluation
recent_model_mae <- mean(
    abs(validation_data$position - validation_data$recent_prediction)
)

recent_model_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$recent_prediction)^2
    )
)

# Recent Points Linear Regression Evaluation
recent_points_mae <- mean(
    abs(
        validation_data$position -
            validation_data$recent_points_prediction
    )
)

recent_points_rmse <- sqrt(
    mean(
        (
            validation_data$position -
                validation_data$recent_points_prediction
        )^2
    )
)


# Both Recent Features Model Evaluation
both_recent_mae <- mean(
    abs(validation_data$position - validation_data$both_recent_prediction)
)

both_recent_rmse <- sqrt(
    mean(
        (validation_data$position - validation_data$both_recent_prediction)^2
    )
)

# 19. Log Transformed Recent Points Model Evaluation
log_recent_points_mae <- mean(
    abs(
        validation_data$position -
            validation_data$log_recent_points_prediction
    )
)

log_recent_points_rmse <- sqrt(
    mean(
        (
            validation_data$position -
                validation_data$log_recent_points_prediction
        )^2
    )
)


# Linear Regression Model Comparison
# Collect MAE and RMSE for all linear regression variants
metrics <- c(
    "MAE", 
    "RMSE"
)

original <- c(
    linear_regression_mae,
    linear_regression_rmse
)

improved <- c(
    improved_model_mae,
    improved_model_rmse
)

recent <- c(
    recent_model_mae,
    recent_model_rmse
)

recent_points <- c(
    recent_points_mae,
    recent_points_rmse
)

both_recent <- c(
    both_recent_mae,
    both_recent_rmse
)

log_recent_points <- c(
    log_recent_points_mae,
    log_recent_points_rmse
)

# Create a comparison table
comparation_original_vs_improved <- tibble(
    Metrics = metrics,
    Original_Model = num(original, digits = 4),
    Improved_Model = num(improved, digits = 4),
    Recent_Model = num(recent, digits = 4),
    Recent_Points_Model = num(recent_points, digits = 4),
    Both_Recent_Model = num(both_recent, digits = 4),
    Log_Recent_Points_Model = num(log_recent_points, digits = 4)
)

# Export model comparison results
write_csv(
    comparation_original_vs_improved,
    "../results/models_comparison_validation.csv"
)

# 21. Feature Correlation and Multicollinearity
# Measure correlation between historical and recent positions
# Previously observed correlation: approximately 0.94961
prev_vs_rec_avg_position <- cor(
    train_data$prev_avg_position,
    train_data$recent_avg_position
)

# Calculate Variance Inflation Factors (VIF)
original_vif <- vif(model)
improved_vif <- vif(improved_model)
recent_vif <- vif(recent_model)
recent_points_vif <- vif(recent_points_model)

# Prepare VIF results for the original, improved and recent models
models <- c(
    rep("Original", 3),
    rep("Improved", 4),
    rep("Recent", 3)
)

variables <- c(
    names(original_vif),
    names(improved_vif),
    names(recent_vif)
)

vifs <- c(
    original_vif,
    improved_vif,
    recent_vif
)

model_vif <- tibble(
    Models = models,
    Variables = variables,
    VIFs = vifs
)

write_csv(
    model_vif,
    "../results/model_vif.csv"
)


# Improved Linear Regression: Residuals vs Fitted
# Examine residual patterns on the 2024 validation dataset
residuals_vs_fitted <- ggplot(
    validation_data,
    aes(
        x = improved_prediction,
        y = position - improved_prediction
    )
) +
    scale_y_continuous(breaks = seq(-11, 19, by = 1)) +
    scale_x_continuous(breaks = seq(0, 17, by = 1)) +
    geom_point() +
    geom_hline(
        yintercept = 0,
        linetype = "dashed"
    )

ggsave(
    "../plots/residuals_vs_fitted.png",
    residuals_vs_fitted
)


# Improved Linear Regression: Q-Q Plot
# Examine the distribution of validation prediction errors
residuals_qq_plot <- ggplot(
    validation_data,
    aes(sample = position - improved_prediction)
) +
    stat_qq(
        color = "steelblue",
        alpha = 0.5,
        size = 1.5
    ) +
    stat_qq_line(
        color = "red",
        linetype = "dashed"
    ) +
    labs(
        title = "Q-Q Plot of Prediction Errors",
        subtitle = "Improved Linear Regression, 2024 Validation",
        x = "Theoretical Quantiles",
        y = "Sample Quantiles (Prediction Errors)"
    ) +
    theme_minimal() +
    theme(
        plot.title = element_text(
            face = "bold",
            hjust = 0.5
        ),
        plot.subtitle = element_text(
            hjust = 0.5
        )
    )

ggsave(
    "../plots/residuals_qq_plot.png",
    residuals_qq_plot,
    width = 10,
    height = 5,
    dpi = 300
)

# 24. Improved Linear Regression: Validation Outliers
# Identify the ten largest absolute validation residuals
validation_outliers <- validation_data |>
    mutate(
        residual = position - improved_prediction,
        abs_residual = abs(residual)
    ) |>
    arrange(desc(abs_residual)) |>
    slice_head(n = 10) |>
    select(
        raceName,
        driver,
        grid,
        position,
        improved_prediction,
        residual,
        abs_residual,
        status
    )

write_csv(
    validation_outliers,
    "../results/validation_outliers.csv"
)


# Improved Linear Regression: Error by Race Status
# Calculate MAE for each race status
validation_mae_by_status <- validation_data |>
    group_by(status) |>
    summarize(
        mae_by_status = mean(abs(position - improved_prediction)),
        count = n()
    ) |>
    arrange(desc(mae_by_status))

write_csv(
    validation_mae_by_status,
    "../results/validation_mae_by_status.csv"
)

# Heteroscedasticity Tests
# Breusch-Pagan tests for the improved and recent points models
# These tests use training model residuals
bp_test <- bptest(improved_model)

recent_points_bp_test <- bptest(recent_points_model)

# Influential Observation Analysis
# Calculate Cook's distance for the improved regression model
cooks_distance <- cooks.distance(improved_model)

# Define the influence threshold
cooks_threshold <- 4 / nobs(improved_model)

# Count observations exceeding the threshold
influential_count <- sum(cooks_distance > cooks_threshold)

# Identify the ten most influential training observations
influential_observations <- train_data |>
    mutate(cooks_distance = cooks_distance) |>
    arrange(desc(cooks_distance)) |>
    slice_head(n = 10) |>
    select(
        season,
        raceName,
        driver,
        grid,
        position,
        status,
        cooks_distance
    )

write_csv(
    influential_observations,
    "../results/influential_observations.csv"
)

# Linearity Diagnostics
# Component + residual plots for the improved model
crPlots(improved_model)

# Examine linearity assumptions for the recent points model
crPlots(recent_points_model)

print(validation_data, width = Inf)