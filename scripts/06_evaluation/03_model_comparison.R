load("../../data/processed/random_forest_results.RData")

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
    "../../results/models_performance.csv"
)

# Model Comparison: 2024 Validation
# Collect MAE and RMSE for all linear regression variants
mae_2024 <- c(
    linear_regression_mae,
    improved_linear_model_mae,
    recent_position_LR_mae,
    recent_points_LR_mae_2024,
    both_recent_features_mae,
    log_recent_points_LR_mae,
    random_forest_mae
)

rmse_2024 <- c(
    linear_regression_rmse,
    improved_linear_model_rmse,
    recent_position_LR_rmse,
    recent_points_LR_rmse_2024,
    both_recent_features_rmse,
    log_recent_points_LR_rmse,
    random_forest_rmse
)

# Create a comparison table
comparison_models_2024 <- tibble(
    Model = c(
        "Original", 
        "Improved", 
        "Recent_Model", 
        "Recent_Points", 
        "Both", 
        "Log",
        "Random Forest"
    ),
    MAE = num(mae_2024, digits=4),
    RMSE = num(rmse_2024, digits=4)
) |> arrange(MAE)

# Export model comparison results
write_csv(
    comparison_models_2024,
    "../../results/models_comparison_validation.csv"
)

save(
    comparison_models_2024,
    file="../../data/processed/model_comparison.RData"
)

# Model Comparison: 2025 Validation

mae_2025 <- c(
    recent_points_LR_mae_2025,
    random_forest_test_mae
)

rmse_2025 <- c(
    recent_points_LR_rmse_2025,
    random_forest_test_rmse
) 

comparison_models_2025 <- tibble(
    Model = c(
        "Recent Points Test",
        "Random Forest"
    ),
    MAE = num(mae_2025, digits=4),
    RMSE = num(rmse_2025, digits=4)
) |> arrange(MAE)

save(
    comparison_models_2025,
    file = "../../data/processed/test_model_comparison.RData"
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
    "../../plots/real_position_vs_predicted_position.png",
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
    "../../plots/errors_distribution.png",
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
    "../../plots/models_comparison.png",
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
    "../../plots/tree_errors_distribution.png",
    tree_errors_distribution,
    width = 10,
    height = 5,
    dpi = 300
)
