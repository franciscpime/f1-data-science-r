load("../../data/processed/random_forest_results.RData")

####################################################################
#                   MODEL PERFORMANCE COMPARISON                   #
# Create a single table:                                           #
#   >> contains the performance of all models                      #
#   >> each row = one model evaluated on a specific dataset        #
#   >> 2024 = Validation (9 models)                                #
#   >> 2025 = Test (2 final models)                                #
#   >> MAE = average prediction error                              #
#   >> RMSE = similar to MAE, but punishes bigger errors more      #
#   >> lower MAE/RMSE = better predictions                         #
#   >> model names, MAE and RMSE must follow the same order        #
####################################################################

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

###########################################################################
#                   PREPARE PREDICTIONS FOR THE GRAPHS                    #
# Prepare the 2024 predictions:                                           #
#   >> select the actual positions and predictions from 4 models          #
#   >> pivot_longer() puts all predictions into one column                #
#   >> Model: which model made the prediction                             #
#   >> Predicted: the position predicted by that model                    #
#   >> recode() replaces the column names with cleaner model names        #
#   >> Error = Actual Position - Predicted Position                       #
#       >>> positive error: driver finished worse than predicted          #
#       >>> negative error: driver finished better than predicted         #
###########################################################################

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


# ============================================================
# ACTUAL VS PREDICTED FINISHING POSITIONS
# ============================================================

# Compare actual positions with predicted positions:
#   >> X-axis = actual finishing position
#   >> Y-axis = predicted finishing position
#   >> each dot = one prediction
#   >> red dashed line = perfect prediction
#   >> closer to the line = more accurate prediction
#   >> facet_wrap() creates one panel for each model
#   >> coord_equal() keeps the X and Y scales equal

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
    "../../plots/models_actual_vs_predicted_2024.png",
    plot = models_actual_vs_predicted_2024_graph,
    width = 12,
    height = 9,
    dpi = 300
)


##############################################################################
#                       PREDICTION ERROR DISTRIBUTIONS                       #
# Compare how prediction errors are distributed:                             #
#   >> X-axis = prediction error (actual - predicted)                        #
#   >> Y-axis = number of predictions                                        #
#       >>> error = 0: perfect prediction                                    #
#       >>> errors closer to 0: better predictions                           #
#       >>> bigger absolute errors: bigger mistakes                          #
#   >> red dashed line: zero error                                           #
#   >> facet_wrap() lets us compare all 4 models in one figure               #
#   >> useful for spotting models that make more large mistakes              #
##############################################################################

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