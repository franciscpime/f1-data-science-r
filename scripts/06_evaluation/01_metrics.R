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
