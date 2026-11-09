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
    "../../results/model_vif.csv"
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
    "../../plots/residuals_vs_fitted.png",
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
    "../../plots/residuals_qq_plot.png",
    residuals_qq_plot,
    width = 10,
    height = 5,
    dpi = 300
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
    "../../results/influential_observations.csv"
)

# Linearity Diagnostics
# Component + residual plots for the improved model
crPlots(improved_model)

# Examine linearity assumptions for the recent points model
crPlots(recent_points_model)
