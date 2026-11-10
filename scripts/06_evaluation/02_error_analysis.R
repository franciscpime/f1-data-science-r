#####################################################################
#                     PREDICTION ERROR ANALYSIS                     #
# Create a single table with prediction errors:                     #
#   >> includes predictions from 2024 Validation and 2025 Test      #
#   >> each row: one driver's prediction in one race                #
#   >> compares different models using the same table               #
#   >> Actual: real finishing position                              #
#   >> Predicted: position predicted by the model                   #
#   >> Error = Actual - Predicted                                   #
#       >>> positive: driver finished worse than predicted          #
#       >>> negative: driver finished better than predicted         #
#   >> Absolute_Error: size of the mistake, ignoring its sign       #
#####################################################################

prediction_errors <- bind_rows(
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
) |>
    mutate(
        Error = Actual - Predicted,
        Absolute_Error = abs(Error),

        # Divide starting positions into groups:
        #   >> makes it easier to compare errors across the grid
        #   >> 1-5: front of the grid
        #   >> 6-10 and 11-15: middle positions
        #   >> 16+: back of the grid
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


#################################################################
#                    ERRORS BY RACE STATUS                      #
# Checks whether the models make more mistakes when the drivers #
# finish normally, abandon the race, or are disqualified.       #
#################################################################

errors_by_status <- prediction_errors |>
    group_by(Year, Dataset, Model, Status) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#################################################################
#                    ERRORS BY GRID POSITION                    #
# Checks whether the starting position of a driver affects the  #
# accuracy of the models' predictions.                          #
#################################################################

errors_by_grid <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid)


#################################################################
#                     ERRORS BY GRID GROUP                      #
# Compares prediction errors between drivers starting at the    #
# front, middle, and back of the grid.                          #
#################################################################

errors_by_grid_group <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid_Group) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid_Group)


#################################################################
#                       ERRORS BY RACE                          #
# Identifies which Grand Prix races were the hardest for the    #
# models to predict correctly.                                  #
#################################################################

errors_by_race <- prediction_errors |>
    group_by(Year, Dataset, Model, Race) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#################################################################
#                      ERRORS BY DRIVER                         #
# Checks which drivers have the largest average prediction      #
# errors across their races.                                    #
#################################################################

errors_by_driver <- prediction_errors |>
    group_by(Year, Dataset, Model, Driver) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#################################################################
#                     PREDICTION OUTLIERS                       #
# Identifies the 10 biggest prediction mistakes for each model  #
# and year, helping us understand unusual race results.         #
#################################################################

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