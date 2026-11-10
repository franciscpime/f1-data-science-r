# Calculation of errors made in attempting to predict final positions
# using validation dataset (2024)
validation_data <- validation_data |>
    mutate(
        error = position - predicted_position,
        absolute_error = abs(error)
    ) |>
    arrange(desc(absolute_error))


#######################################################
#         CALCULATE MAE (Mean Absolute Error)         #
#   mean(abs(Actual Position - Predicted Position))   #
#######################################################

calculate_mae <- function(actual, predicted) {
    mean(abs(actual-predicted))
}

linear_regression_mae <- calculate_mae(
    validation_data$position, 
    validation_data$predicted_position
)

baseline_mae <- calculate_mae(
    validation_data$position, 
    validation_data$baseline_prediction
)
        
decision_tree_mae <- calculate_mae(
        validation_data$position, 
        validation_data$tree_prediction
    )

improved_linear_model_mae <- calculate_mae(
        validation_data$position, 
        validation_data$improved_prediction
    )

recent_position_LR_mae <- calculate_mae(
        validation_data$position, 
        validation_data$recent_prediction
    )

recent_points_LR_mae_2024 <- calculate_mae(
        validation_data$position,
            validation_data$recent_points_prediction
    )

both_recent_features_mae <- calculate_mae(
        validation_data$position, 
        validation_data$both_recent_prediction
    )

log_recent_points_LR_mae <- calculate_mae(
        validation_data$position,
            validation_data$log_recent_points_prediction
    )

recent_points_LR_mae_2025 <- calculate_mae(
        test_data$position, 
        recent_points_test_prediction
    )

mae_improvement <- (
    (baseline_mae - linear_regression_mae) / baseline_mae
) * 100

#######################################################
#       CALCULATE RMSE (Root Mean Squared Error)      #
#   √mean((Actual Position - Predicted Position)^2)   #
#######################################################

calculate_rmse <- function(actual, predicted) {
    sqrt(mean((actual-predicted)^2))
}

linear_regression_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$predicted_position
    )

baseline_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$baseline_prediction
    )

decision_tree_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$tree_prediction
    )

improved_linear_model_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$improved_prediction
    )

recent_position_LR_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$recent_prediction
    )

recent_points_LR_rmse_2024 <- calculate_rmse(
        validation_data$position,
        validation_data$recent_points_prediction
    )

both_recent_features_rmse <- calculate_rmse(
        validation_data$position, 
        validation_data$both_recent_prediction
    )

log_recent_points_LR_rmse <- calculate_rmse(
        validation_data$position,
        validation_data$log_recent_points_prediction
    )

recent_points_LR_rmse_2025 <- calculate_rmse(
        test_data$position, 
        recent_points_test_prediction
    )