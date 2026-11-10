# Create a unified table of individual prediction errors
# Each row represents one prediction for one driver and race
prediction_errors <- bind_rows(
    # 2024 Original Linear Regression
    validation_data |>
        transmute(
            Year = 2024L,
            Dataset = "Validation",
            Model = "Original LR",
            Driver = driver,
            Race = raceName,
            Grid = grid,
            Status = status,
            Actual = position,
            Predicted = predicted_position
        ),

    # 2024 Improved Linear Regression
    validation_data |>
        transmute(
            Year = 2024L,
            Dataset = "Validation",
            Model = "Improved LR",
            Driver = driver,
            Race = raceName,
            Grid = grid,
            Status = status,
            Actual = position,
            Predicted = improved_prediction
        ),

    # 2024 Recent Points Linear Regression
    validation_data |>
        transmute(
            Year = 2024L,
            Dataset = "Validation",
            Model = "Recent Points LR",
            Driver = driver,
            Race = raceName,
            Grid = grid,
            Status = status,
            Actual = position,
            Predicted = recent_points_prediction
        ),

    # 2025 Recent Points Linear Regression
    test_data |>
        transmute(
            Year = 2025L,
            Dataset = "Test",
            Model = "Recent Points LR",
            Driver = driver,
            Race = raceName,
            Grid = grid,
            Status = status,
            Actual = position,
            Predicted = recent_points_test_prediction
        ),

    # 2025 Random Forest
    test_data |>
        transmute(
            Year = 2025L,
            Dataset = "Test",
            Model = "Random Forest",
            Driver = driver,
            Race = raceName,
            Grid = grid,
            Status = status,
            Actual = position,
            Predicted = random_forest_test_prediction
        )

) |> mutate(
        Error = Actual - Predicted,
        Absolute_Error = abs(Error),
        Grid_Group = cut(
            Grid,
            breaks = c(-Inf, 5, 10, 15, Inf),
            labels = c("1-5", "6-10", "11-15", "16+")
        )
    )

write_csv(
    prediction_errors,
    "../../results/prediction_errors.csv"
)

save(
    prediction_errors,
    file = "../../data/processed/prediction_errors.RData"
)


# Error summary by race completion status

errors_by_status <- prediction_errors |>
    group_by(Year, Dataset, Model, Status) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


# Error summary by starting grid position

errors_by_grid <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid)


# Error summary by starting grid group

errors_by_grid_group <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid_Group) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid_Group)


# Error summary by race

errors_by_race <- prediction_errors |>
    group_by(Year, Dataset, Model, Race) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


# Error summary by driver

errors_by_driver <- prediction_errors |>
    group_by(Year, Dataset, Model, Driver) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


# Ten largest errors for each model and year

prediction_outliers <- prediction_errors |>
    group_by(Year, Dataset, Model) |>
    slice_max(
        order_by = Absolute_Error,
        n = 10,
        with_ties = FALSE
    ) |>
    ungroup() |>
    arrange(Year, Model, desc(Absolute_Error))

write_csv(
    errors_by_status,
    "../../results/errors_by_status.csv"
)

write_csv(
    errors_by_grid,
    "../../results/errors_by_grid.csv"
)

write_csv(
    errors_by_grid_group,
    "../../results/errors_by_grid_group.csv"
)

write_csv(
    errors_by_race,
    "../../results/errors_by_race.csv"
)

write_csv(
    errors_by_driver,
    "../../results/errors_by_driver.csv"
)

write_csv(
    prediction_outliers,
    "../../results/prediction_outliers.csv"
)

save(
    errors_by_status,
    errors_by_grid,
    errors_by_grid_group,
    errors_by_race,
    errors_by_driver,
    prediction_outliers,
    file = "../../data/processed/error_summaries.RData"
)