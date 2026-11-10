#####################################################################
#              FEATURE CORRELATION AND MULTICOLLINEARITY            #
# Check if some features contain very similar information:          #
#   >> correlation measures how strongly two features are related   #
#   >> values close to 1: strong positive relationship              #
#   >> VIF checks multicollinearity in Linear Regression models     #
#       >>> high VIF: a feature overlaps with other features        #
#       >>> lower VIF: less multicollinearity                       #
#   >> compare VIF values across 4 different regression models      #
#####################################################################

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


#####################################################################
#                   RESIDUALS VS PREDICTED POSITIONS                #
# Check how prediction errors behave across different models:       #
#   >> X-axis = predicted finishing position                        #
#   >> Y-axis = prediction error (actual - predicted)               #
#       >>> each dot = one prediction                               #
#   >> red dashed line = zero error                                 #
#   >> points randomly spread around zero = a better pattern        #
#   >> clear curves or patterns may suggest model problems          #
#   >> facet_wrap() compares 3 models in one figure                 #
#####################################################################

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


#####################################################################
#                         Q-Q PLOT ANALYSIS                         #
# Check if prediction errors follow a normal distribution:          #
#   >> each dot compares observed and expected error quantiles      #
#   >> red line = what a normal distribution would look like        #
#   >> dots close to the line = errors are closer to normal         #
#   >> large deviations = errors may not be normally distributed    #
#   >> facet_wrap() compares the 3 regression models                #
#####################################################################

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


#####################################################################
#                       HETEROSCEDASTICITY TESTS                    #
# Check if the size of the residuals changes across predictions:    #
#   >> Breusch-Pagan test checks for non-constant error variance    #
#   >> p-value < 0.05 = evidence of heteroscedasticity              #
#   >> p-value >= 0.05 = not enough evidence of heteroscedasticity  #
#   >> tests use training residuals, not validation predictions     #
#####################################################################

improved_LR_bp_test <- bptest(improved_model)

recent_points_LR_bp_test <- bptest(recent_points_model)


#####################################################################
#                    INFLUENTIAL OBSERVATIONS                       #
# Find training observations that strongly affect the model:        #
#   >> Cook's distance measures how influential each row is         #
#   >> threshold = 4 / number of training observations              #
#   >> values > threshold are flagged for investigation             #
#   >> count how many observations exceed the threshold             #
#   >> save the 10 observations with the highest Cook's distance    #
#   >> influential does not automatically mean incorrect            #
#####################################################################

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


#####################################################################
#                       ERRORS BY RACE STATUS                       #
# Compare prediction accuracy across different race outcomes:       #
#   >> Finished = drivers who completed the race normally           #
#   >> Retired = drivers who did not finish                         #
#   >> MAE = average absolute prediction error for each status      #
#   >> higher bars = larger average prediction mistakes             #
#   >> different colours = different prediction models              #
#   >> facet_wrap() separates 2024 Validation and 2025 Test         #
#   >> useful for checking how incidents affect prediction accuracy #
#####################################################################

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
