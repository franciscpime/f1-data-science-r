load("../../data/processed/random_forest_results.RData")

#################################################################
#                  MODEL PERFORMANCE COMPARISON                 #
# Compares the accuracy of all models using MAE and RMSE,       #
# with 2024 for validation and 2025 for final testing.          #
#################################################################

model_performance <- tibble(
    Year = c(rep(2024L, 9), rep(2025L, 2)),
    Dataset = c(rep("Validation", 9), rep("Test", 2)),
    Model = c(
        "Baseline",
        "Original LR",
        "Decision Tree",
        "Improved LR",
        "Recent Position LR",
        "Recent Points LR",
        "Both Recent Features LR",
        "Log Recent Points LR",
        "Random Forest",
        "Recent Points LR",
        "Random Forest"
    ),
    MAE = c(
        baseline_mae,
        linear_regression_mae,
        decision_tree_mae,
        improved_linear_model_mae,
        recent_position_LR_mae,
        recent_points_LR_mae_2024,
        both_recent_features_mae,
        log_recent_points_LR_mae,
        random_forest_mae,
        recent_points_LR_mae_2025,
        random_forest_test_mae
    ),
    RMSE = c(
        baseline_rmse,
        linear_regression_rmse,
        decision_tree_rmse,
        improved_linear_model_rmse,
        recent_position_LR_rmse,
        recent_points_LR_rmse_2024,
        both_recent_features_rmse,
        log_recent_points_LR_rmse,
        random_forest_rmse,
        recent_points_LR_rmse_2025,
        random_forest_test_rmse
    )
) |> arrange(Year, MAE)

write_csv(
    model_performance,
    "../../results/model_performance.csv"
)

save(
    model_performance,
    file = "../../data/processed/model_performance.RData"
)

#################################################################
#                PREPARE PREDICTIONS FOR GRAPHS                 #
# Organises the actual and predicted finishing positions from   #
# four models into one table for easier visual comparison.      #
#################################################################

model_predictions_2024 <- validation_data |>
    select(
        position,
        predicted_position,
        tree_prediction,
        improved_prediction,
        recent_points_prediction
    ) |>
    pivot_longer(
        cols = -position,
        names_to = "Model",
        values_to = "Predicted"
    ) |>
    mutate(
        Model = dplyr::recode(
            Model,
            predicted_position = "Original LR",
            tree_prediction = "Decision Tree",
            improved_prediction = "Improved LR",
            recent_points_prediction = "Recent Points LR"
        ),
        Error = position - Predicted
    )


#################################################################
#               ACTUAL VS PREDICTED POSITIONS                   #
# Compares predicted and actual finishing positions to show     #
# how closely each model's predictions match real results.      #
#################################################################

models_actual_vs_predicted_2024_graph <- ggplot(
    model_predictions_2024,
    aes(x = position, y = Predicted)
) +
    geom_point(
        alpha = 0.3,
        color = "steelblue",
        size = 1.5
    ) +
    geom_abline(
        slope = 1,
        intercept = 0,
        linetype = "dashed",
        color = "red"
    ) +
    facet_wrap(~ Model) +
    coord_equal() +
    labs(
        title = "Actual vs Predicted Finishing Positions",
        subtitle = "Model Comparison: 2024 Validation",
        x = "Actual Finishing Position",
        y = "Predicted Finishing Position"
    ) +
    theme_minimal()

ggsave(
    "../../plots/models_actual_vs_predicted_2024_graph.png",
    plot = models_actual_vs_predicted_2024_graph,
    width = 12,
    height = 9,
    dpi = 300
)


#################################################################
#                 PREDICTION ERROR DISTRIBUTIONS               #
# Shows how prediction errors are distributed across models,   #
# helping identify which models make more large mistakes.      #
#################################################################

models_error_distribution_2024_graph <- ggplot(
    model_predictions_2024,
    aes(x = Error)
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
    facet_wrap(~ Model) +
    labs(
        title = "Distribution of Prediction Errors",
        subtitle = "Model Comparison: 2024 Validation",
        x = "Prediction Error (Actual - Predicted)",
        y = "Number of Observations"
    ) +
    theme_minimal()

ggsave(
    "../../plots/models_error_distribution_2024.png",
    plot = models_error_distribution_2024_graph,
    width = 12,
    height = 9,
    dpi = 300
)