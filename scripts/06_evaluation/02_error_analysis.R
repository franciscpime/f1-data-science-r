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


#####################################################################
#                       ERRORS BY RACE STATUS                       #
# Check whether race results affect prediction accuracy:            #
#   >> group predictions by race status                             #
#   >> Count: number of predictions in each status                  #
#   >> MAE: average absolute error for that status                  #
#   >> helps compare finished races with retirements or DNFs        #
#   >> higher MAE: more difficult results to predict                #
#####################################################################

errors_by_status <- prediction_errors |>
    group_by(Year, Dataset, Model, Status) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#####################################################################
#                       ERRORS BY GRID POSITION                     #
# Check how starting position affects prediction accuracy:          #
#   >> calculate MAE for each individual grid position              #
#   >> Count: number of predictions from that position              #
#   >> helps identify grid positions with larger errors             #
#####################################################################

errors_by_grid <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid)


#####################################################################
#                        ERRORS BY GRID GROUP                       #
# Compare errors between different parts of the starting grid:      #
#   >> group positions into 1-5, 6-10, 11-15 and 16+                #
#   >> calculate the average error for each group                   #
#   >> easier to compare than looking at every position separately  #
#####################################################################

errors_by_grid_group <- prediction_errors |>
    group_by(Year, Dataset, Model, Grid_Group) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, Grid_Group)


#####################################################################
#                          ERRORS BY RACE                           #
# Find the races where the models made the biggest mistakes:        #
#   >> calculate MAE separately for each Grand Prix                 #
#   >> Count: number of driver predictions in that race             #
#   >> higher MAE: less accurate predictions for that race          #
#   >> useful for identifying unusual or unpredictable races        #
#####################################################################

errors_by_race <- prediction_errors |>
    group_by(Year, Dataset, Model, Race) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#####################################################################
#                         ERRORS BY DRIVER                          #
# Check which drivers are harder for the models to predict:         #
#   >> calculate MAE separately for each driver                     #
#   >> Count: number of predictions made for that driver            #
#   >> higher MAE: larger average prediction mistakes               #
#   >> useful for spotting drivers with less predictable results    #
#####################################################################

errors_by_driver <- prediction_errors |>
    group_by(Year, Dataset, Model, Driver) |>
    summarise(
        Count = n(),
        MAE = mean(Absolute_Error),
        .groups = "drop"
    ) |>
    arrange(Year, Model, desc(MAE))


#####################################################################
#                        PREDICTION OUTLIERS                        #
# Find the largest individual prediction mistakes:                  #
#   >> select the 10 biggest absolute errors for each model/year    #
#   >> with_ties = FALSE keeps exactly 10 predictions per group     #
#   >> useful for checking unexpected race results                  #
#   >> helps explain why some predictions were very inaccurate      #
#####################################################################

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