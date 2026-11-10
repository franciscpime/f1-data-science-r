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
    "../../results/mae_by_status.csv"
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
    "../../results/mae_by_grid.csv"
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
    "../../results/mae_by_grid_group.csv"
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
    "../../results/mae_by_race.csv"
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
    "../../results/mae_by_driver.csv"
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
    "../../results/validation_outliers.csv"
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
    "../../results/validation_mae_by_status.csv"
)

# Errors 2024
validation_errors_2024 <- tibble(
    Driver = validation_data$driver,
    Race = validation_data$raceName,
    Actual = validation_data$position,
    Linear_Predicted = validation_data$recent_points_prediction,
    Linear_Error = abs(
        validation_data$position - 
        validation_data$recent_points_prediction
    ),
    Status = validation_data$status
) |> arrange(desc(Linear_Error))

write_csv(
    validation_errors_2024,
    "../../results/validation_errors_2024.csv"
)

erros_by_status_2024 <- validation_errors_2024 |>
    group_by(Status) |>
    summarise(
        Count = n(),
        Linear_MAE = mean(Linear_Error)
    ) |> arrange(desc(Linear_MAE))



# Errors 2025
test_errors_2025 <- tibble(
    Driver = test_data$driver,
    Race = test_data$raceName,
    Actual = test_data$position,
    Grid = test_data$grid,
    Linear_Predicted = recent_points_test_prediction,
    RF_Predicted = random_forest_test_prediction,
    Linear_Error = abs(test_data$position - recent_points_test_prediction),
    RF_Error = abs(test_data$position - random_forest_test_prediction),
    Status = test_data$status
) |> arrange(desc(Linear_Error))

write_csv(
    test_errors_2025,
    "../../results/test_errors_2025.csv"
)

errors_by_grid <- test_errors_2025 |>
    

errors_by_status_2025 <- test_errors_2025 |>
    group_by(Status) |>
    summarise(
        Count = n(),
        Linear_MAE = mean(Linear_Error),
        RF_MAE = mean(RF_Error)
    ) |>
    arrange(desc(Linear_MAE))

errors_by_status_long_2025 <- errors_by_status_2025 |>
    pivot_longer(
        cols = c(Linear_MAE, RF_MAE),
        names_to = "Models",
        values_to = "Errors"
    )