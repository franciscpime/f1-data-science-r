#################################################################
#             FEATURE CORRELATION AND MULTICOLLINEARITY         #
# Checks whether some features contain similar information and  #
# uses VIF to identify possible multicollinearity problems.     #
#################################################################

historical_recent_position_correlation <- cor(
    train_data$prev_avg_position,
    train_data$recent_avg_position
)

original_LR_vif <- vif(model)
improved_LR_vif <- vif(improved_model)
recent_position_LR_vif <- vif(recent_model)
recent_points_LR_vif <- vif(recent_points_model)


# Combine VIF results into one table:
#   >> Model: which regression model was tested
#   >> Variable: feature used by that model
#   >> VIF: how much that feature overlaps with other features
#   >> useful for comparing multicollinearity between models

linear_models_vif <- bind_rows(
    tibble(
        Model = "Original LR",
        Variable = names(original_LR_vif),
        VIF = as.numeric(original_LR_vif)
    ),
    tibble(
        Model = "Improved LR",
        Variable = names(improved_LR_vif),
        VIF = as.numeric(improved_LR_vif)
    ),
    tibble(
        Model = "Recent Position LR",
        Variable = names(recent_position_LR_vif),
        VIF = as.numeric(recent_position_LR_vif)
    ),
    tibble(
        Model = "Recent Points LR",
        Variable = names(recent_points_LR_vif),
        VIF = as.numeric(recent_points_LR_vif)
    )
)

write_csv(
    linear_models_vif,
    "../../results/model_vif.csv"
)


#################################################################
#                RESIDUALS VS PREDICTED POSITIONS               #
# Shows how prediction errors change across predicted finishing #
# positions, helping identify patterns or possible model issues.#
#################################################################


linear_models_residuals_2024_graph <- prediction_errors |>
    filter(
        Year == 2024,
        Model %in% c(
            "Original LR",
            "Improved LR",
            "Recent Points LR"
        )
    ) |>
    ggplot(aes(x = Predicted, y = Error)) +
    geom_point(
        alpha = 0.4,
        color = "steelblue"
    ) +
    geom_hline(
        yintercept = 0,
        linetype = "dashed",
        color = "red"
    ) +
    facet_wrap(~ Model) +
    labs(
        title = "Residuals vs Predicted Positions",
        subtitle = "2024 Validation",
        x = "Predicted Finishing Position",
        y = "Residual (Actual - Predicted)"
    ) +
    theme_minimal()

ggsave(
    "../../plots/residuals_vs_fitted.png",
    plot = linear_models_residuals_2024_graph,
    width = 12,
    height = 5,
    dpi = 300
)


###################################################################
#                        Q-Q PLOT ANALYSIS                        #
# Compares prediction errors with a normal distribution to see    #
# whether they follow a similar pattern or show large deviations. #
###################################################################

linear_models_qq_2024_graph <- prediction_errors |>
    filter(
        Year == 2024,
        Model %in% c(
            "Original LR",
            "Improved LR",
            "Recent Points LR"
        )
    ) |>
    ggplot(aes(sample = Error)) +
    stat_qq(
        color = "steelblue",
        alpha = 0.5,
        size = 1
    ) +
    stat_qq_line(
        color = "red",
        linetype = "dashed"
    ) +
    facet_wrap(~ Model) +
    labs(
        title = "Q-Q Plot of Prediction Errors",
        subtitle = "2024 Validation",
        x = "Theoretical Quantiles",
        y = "Sample Quantiles"
    ) +
    theme_minimal()

ggsave(
    "../../plots/residuals_qq_plot.png",
    plot = linear_models_qq_2024_graph,
    width = 12,
    height = 5,
    dpi = 300
)


#################################################################
#                     HETEROSCEDASTICITY TESTS                  #
# Uses the Breusch-Pagan test to check whether the variance of  #
# training residuals stays constant or changes across values.   #
#################################################################

improved_LR_bp_test <- bptest(improved_model)

recent_points_LR_bp_test <- bptest(recent_points_model)


#################################################################
#                    INFLUENTIAL OBSERVATIONS                   #
# Uses Cook's distance to identify training observations that   #
# may have a strong influence on the regression model.          #
#################################################################


improved_LR_cooks_distance <- cooks.distance(improved_model)

improved_LR_cooks_threshold <- 4 / nobs(improved_model)

improved_LR_influential_count <- sum(
    improved_LR_cooks_distance > improved_LR_cooks_threshold
)

improved_LR_influential_observations <- train_data |>
    mutate(
        cooks_distance = improved_LR_cooks_distance
    ) |>
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
    improved_LR_influential_observations,
    "../../results/influential_observations.csv"
)


#################################################################
#                       ERRORS BY RACE STATUS                   #
# Compares prediction errors for different race outcomes, such  #
# as finishing normally, retiring, or being disqualified.       #
#################################################################

models_errors_by_status_2024_2025_graph <- errors_by_status |>
    ggplot(
        aes(
            x = Status,
            y = MAE,
            fill = Model
        )
    ) +
    geom_col(position = "dodge") +
    facet_wrap(~ Year) +
    labs(
        title = "Mean Absolute Error by Race Status",
        subtitle = "2024 Validation vs 2025 Test",
        x = "Race Status",
        y = "Mean Absolute Error (Positions)",
        fill = "Model"
    ) +
    theme_minimal() +
    theme(
        axis.text.x = element_text(
            angle = 30,
            hjust = 1
        )
    )

ggsave(
    "../../plots/errors_by_status.png",
    plot = models_errors_by_status_2024_2025_graph,
    width = 13,
    height = 6,
    dpi = 300
)