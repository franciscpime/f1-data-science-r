
# Feature Engineering, Historical Driver Performance

## 1. Introduction

Feature engineering is the process of creating new variables from existing data to improve the information available to predictive models.

In this project, feature engineering transforms historical Formula 1 race results into indicators of driver performance.

The implementation is located in:

`scripts/02_features.R`

The main objectives are to:

- Calculate historical average finishing positions.
- Calculate historical average championship points.
- Calculate recent performance over rolling windows.
- Prevent the current race result from being used as a predictor.
- Remove observations without sufficient historical information.
- Split the dataset chronologically into training, validation, and testing sets.
- Save the prepared modelling datasets.

## 2. Required Libraries and Dataset

```r
library(tidyverse)
library(slider)

load("../data/f1_data.RData")
```

### 2.1 `library()`

Loads an installed R package into the current R session.

**Syntax:**

```r
library(package)
```

| Argument | Description |
|---|---|
| `package` | Name of the package to load |

The project uses:

- `tidyverse` for data manipulation and transformation.
- `slider` for rolling calculations over sequences of observations.

### 2.2 `load()`

Restores previously saved R objects.

```r
load("../data/f1_data.RData")
```

| Argument | Description |
|---|---|
| `file` | Path to the `.RData` file |

The loaded object, `f1_data`, contains the combined race results from 2021 to 2025.

## 3. Data Type Conversion

Before creating features, the script converts selected variables to integers.

```r
f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)
```

### 3.1 `as.integer()`

Converts a vector into integer values.

**Syntax:**

```r
as.integer(x)
```

| Argument | Description |
|---|---|
| `x` | Object to convert |

Example:

```r
as.integer("10")
```

returns the integer `10`.

The conversion allows numerical operations such as averages and comparisons.

**Important consideration:** converting fractional numeric values to integers truncates their decimal part. Therefore, this operation may affect points values if fractional championship points are present.

## 4. Original Feature Engineering Pipeline

The main transformation is:

```r
f1_data <- f1_data |>
    group_by(driver, season) |>
    arrange(season, round) |>
    mutate(
        prev_avg_position = lag(cummean(position)),
        prev_avg_points = lag(cummean(points)),
        recent_avg_position = slide_dbl(
            lag(position),
            mean,
            .before = 4,
            na.rm = TRUE
        ),
        recent_avg_points = slide_dbl(
            lag(points),
            mean,
            .before = 4,
            na.rm = TRUE
        )
    ) |>
    filter(
        !is.na(prev_avg_position),
        !is.na(prev_avg_points)
    )
```

This pipeline performs several operations in sequence.

Each operation is explained below.

## 5. Grouping Observations with `group_by()`

```r
group_by(driver, season)
```

### 5.1 Purpose

The function groups observations by driver and championship season.

This ensures that historical performance calculations are performed separately for each driver-season combination.

For example, a driver's results from 2022 are not combined with their results from 2023 when calculating historical averages.

### 5.2 Syntax

```r
group_by(.data, ..., .add = FALSE, .drop = group_by_drop_default(.data))
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Variables used to create groups |
| `.add` | Whether new grouping variables are added to existing groups |
| `.drop` | Whether empty factor groups are dropped |

### 5.3 Example

Consider:

| driver | season | round | position |
|---|---|---|---|
| Driver A | 2023 | 1 | 4 |
| Driver A | 2023 | 2 | 2 |
| Driver A | 2024 | 1 | 6 |
| Driver B | 2023 | 1 | 8 |

Using:

```r
group_by(driver, season)
```

creates three groups:

1. Driver A — 2023.
2. Driver A — 2024.
3. Driver B — 2023.

Historical calculations are performed independently within these groups.

## 6. Sorting Observations with `arrange()`

```r
arrange(season, round)
```

### 6.1 Purpose

The `arrange()` function orders observations according to selected variables.

In this project, observations are ordered by season and race round.

This is important because historical averages and rolling calculations depend on the sequence of races.

### 6.2 Syntax

```r
arrange(.data, ..., .by_group = FALSE)
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Variables used for sorting |
| `.by_group` | Whether grouping variables should be considered first |

The project uses:

```r
arrange(season, round)
```

Because `.by_group` is not specified, its default value is `FALSE`.

This means the data is sorted by the supplied variables rather than automatically sorting by every grouping variable.

The subsequent grouped calculations still operate separately within each driver-season group.

### 6.3 Why Chronological Order Matters

Functions such as `lag()`, `cummean()`, and `slide_dbl()` use the order of observations.

If race results were arranged incorrectly, historical averages could incorporate results from later races.

Therefore, chronological ordering is essential for reliable feature engineering.

## 7. Creating Variables with `mutate()`

The project creates four new features using `mutate()`.

### 7.1 Purpose

`mutate()` creates or modifies columns while preserving the existing observations.

### 7.2 Syntax

```r
mutate(.data, ..., .by = NULL, .keep = "all")
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Expressions defining new or modified columns |
| `.by` | Optional grouping for the operation |
| `.keep` | Controls which existing columns are retained |

Example:

```r
mutate(
    double_points = points * 2
)
```

creates a new column containing twice the original points.

In the project, `mutate()` creates:

- `prev_avg_position`
- `prev_avg_points`
- `recent_avg_position`
- `recent_avg_points`

## 8. Understanding `lag()`

The `lag()` function is central to preventing the current race result from being included in historical features.

### 8.1 Purpose

`lag()` shifts a vector backward by a specified number of observations.

### 8.2 Syntax

```r
lag(x, n = 1L, default = NULL, order_by = NULL, ...)
```

| Argument | Description |
|---|---|
| `x` | Input vector |
| `n` | Number of positions to shift |
| `default` | Value used for positions without a previous observation |
| `order_by` | Optional vector specifying observation order |
| `...` | Additional arguments |

The project uses the default:

```r
n = 1
```

### 8.3 Example

Suppose a driver's finishing positions are:

```r
position <- c(5, 3, 8, 2)
```

Applying:

```r
lag(position)
```

produces:

```text
NA, 5, 3, 8
```

| Race | Actual position | Lagged position |
|---|---|---|
| 1 | 5 | NA |
| 2 | 3 | 5 |
| 3 | 8 | 3 |
| 4 | 2 | 8 |

The current race's position is excluded from its lagged value.

### 8.4 Why This Matters

When predicting the result of Race 4, the model must not use the actual finishing position of Race 4.

Using `lag()` ensures that the historical features depend on previous observations instead.

## 9. Understanding `cummean()`

The `cummean()` function calculates cumulative averages.

### 9.1 Purpose

It calculates the mean of all values from the beginning of a sequence up to the current observation.

### 9.2 Syntax

```r
cummean(x)
```

| Argument | Description |
|---|---|
| `x` | Numerical vector |

### 9.3 Example

```r
position <- c(5, 3, 8, 2)

cummean(position)
```

Result:

| Race | Position | Cumulative mean |
|---|---|---|
| 1 | 5 | 5.00 |
| 2 | 3 | 4.00 |
| 3 | 8 | 5.33 |
| 4 | 2 | 4.50 |

The calculation is:

\[
\text{Cumulative Mean}_t =
\frac{\sum_{i=1}^{t}x_i}{t}
\]

The cumulative mean includes the current observation.

Therefore, it must be shifted before being used as a pre-race feature.

## 10. Previous Average Finishing Position

The project calculates:

```r
prev_avg_position = lag(cummean(position))
```

### 10.1 Calculation Order

R evaluates the inner function first.

First:

```r
cummean(position)
```

calculates cumulative finishing-position averages.

Then:

```r
lag(...)
```

shifts those averages by one observation.

### 10.2 Example

Consider:

```r
position <- c(5, 3, 8, 2)
```

| Race | Position | `cummean(position)` | `lag(cummean(position))` |
|---|---|---|---|
| 1 | 5 | 5.00 | NA |
| 2 | 3 | 4.00 | 5.00 |
| 3 | 8 | 5.33 | 4.00 |
| 4 | 2 | 4.50 | 5.33 |

For Race 4, the feature is calculated using the finishing positions from Races 1, 2, and 3.

### 10.3 Mathematical Definition

For race \(t\):

\[
\text{prev\_avg\_position}_t =
\frac{1}{t-1}
\sum_{i=1}^{t-1}\text{position}_i
\]

This is the average finishing position across all previous races within the same driver-season group.

## 11. Previous Average Championship Points

The project calculates:

```r
prev_avg_points = lag(cummean(points))
```

The logic is identical to the previous average position calculation.

### 11.1 Example

Suppose a driver scores:

```r
points <- c(10, 15, 0, 25)
```

| Race | Points | Previous average points |
|---|---|---|
| 1 | 10 | NA |
| 2 | 15 | 10.00 |
| 3 | 0 | 12.50 |
| 4 | 25 | 8.33 |

The current race's points are not included.

### 11.2 Mathematical Definition

\[
\text{prev\_avg\_points}_t =
\frac{1}{t-1}
\sum_{i=1}^{t-1}\text{points}_i
\]

This feature summarises a driver's historical championship-point performance within the current season.

## 12. Understanding `slide_dbl()`

The project uses the `slider` package to calculate rolling averages.

### 12.1 Purpose

`slide_dbl()` applies a function to successive windows of a vector and returns a numeric vector of type `double`.

### 12.2 Relevant Syntax

```r
slide_dbl(
    .x,
    .f,
    ...,
    .before = 0L,
    .after = 0L,
    .complete = FALSE
)
```

| Argument | Description |
|---|---|
| `.x` | Input vector |
| `.f` | Function applied to each window |
| `...` | Additional arguments passed to `.f` |
| `.before` | Number of preceding observations included |
| `.after` | Number of following observations included |
| `.complete` | Whether incomplete windows should return missing values |

### 12.3 The Project's Implementation

```r
slide_dbl(
    lag(position),
    mean,
    .before = 4,
    na.rm = TRUE
)
```

Each argument has a specific role.

| Argument | Project value | Explanation |
|---|---|---|
| `.x` | `lag(position)` | Uses previous race positions |
| `.f` | `mean` | Calculates the average |
| `.before` | `4` | Includes up to four earlier elements alongside the current element of the lagged sequence |
| `na.rm` | `TRUE` | Passes this argument to `mean()` to ignore missing values |
| `.after` | Default `0` | Does not include following observations |
| `.complete` | Default `FALSE` | Allows windows containing fewer than five available elements |

### 12.4 Why `.before = 4` Means Five Races

The sliding window includes:

- The current element of the lagged sequence.
- Up to four preceding elements.

Therefore, the maximum window contains five values.

Because the input has already been shifted using `lag()`, those values correspond to the previous five races.

### 12.5 Example

Suppose:

```r
position <- c(5, 3, 8, 2, 6, 4, 1)
```

The rolling average is:

```r
slide_dbl(
    lag(position),
    mean,
    .before = 4,
    na.rm = TRUE
)
```

| Race | Actual position | Previous races included | Recent average |
|---|---|---|---|
| 1 | 5 | None | NaN |
| 2 | 3 | 5 | 5.00 |
| 3 | 8 | 5, 3 | 4.00 |
| 4 | 2 | 5, 3, 8 | 5.33 |
| 5 | 6 | 5, 3, 8, 2 | 4.50 |
| 6 | 4 | 5, 3, 8, 2, 6 | 4.80 |
| 7 | 1 | 3, 8, 2, 6, 4 | 4.60 |

At Race 7, the oldest result (Race 1) is no longer included.

This allows the feature to respond to changes in recent performance.

## 13. Recent Average Finishing Position

The project creates:

```r
recent_avg_position = slide_dbl(
    lag(position),
    mean,
    .before = 4,
    na.rm = TRUE
)
```

This feature measures finishing performance over up to five previous races.

Unlike `prev_avg_position`, it does not include the entire season history once more than five previous races are available.

### 13.1 Mathematical Definition

For race \(t\):

\[
\text{recent\_avg\_position}_t =
\frac{1}{n_t}
\sum_{i=\max(1,t-5)}^{t-1}
\text{position}_i
\]

where:

\[
n_t = \min(5,t-1)
\]

The feature is undefined when no previous race is available.

## 14. Recent Average Championship Points

The project also creates:

```r
recent_avg_points = slide_dbl(
    lag(points),
    mean,
    .before = 4,
    na.rm = TRUE
)
```

The calculation is identical to the recent average position calculation, but uses championship points.

### 14.1 Purpose

This feature provides a measure of recent points-scoring performance.

It may capture changes in driver competitiveness that are less visible in a season-long average.

### 14.2 Mathematical Definition

\[
\text{recent\_avg\_points}_t =
\frac{1}{n_t}
\sum_{i=\max(1,t-5)}^{t-1}
\text{points}_i
\]

where:

\[
n_t = \min(5,t-1)
\]

The result is calculated separately for each driver-season group.

## 15. Historical vs Recent Performance

The project uses two types of historical indicators.

| Feature type | Calculation | Main characteristic |
|---|---|---|
| Cumulative average | All previous races in the season | Represents longer-term performance |
| Rolling average | Up to five previous races | Emphasises recent performance |

For example, a driver may perform poorly early in a season but improve later.

The cumulative average changes gradually because it includes earlier results.

The rolling average responds more quickly because older results eventually leave the window.

Both approaches provide potentially useful predictive information.

## 16. Understanding `filter()`

After creating the features, the project removes observations without the required cumulative historical averages.

```r
filter(
    !is.na(prev_avg_position),
    !is.na(prev_avg_points)
)
```

### 16.1 `filter()`

Retains rows that satisfy specified conditions.

**Syntax:**

```r
filter(.data, ..., .by = NULL, .preserve = FALSE)
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Logical conditions |
| `.by` | Optional grouping for the operation |
| `.preserve` | Whether to preserve the existing grouping structure |

### 16.2 `is.na()`

Checks whether a value is missing.

**Syntax:**

```r
is.na(x)
```

| Argument | Description |
|---|---|
| `x` | Object to examine |

The function returns `TRUE` for missing values.

### 16.3 Logical Negation: `!`

The `!` operator reverses a logical value.

For example:

```r
is.na(NA)
```

returns `TRUE`.

But:

```r
!is.na(NA)
```

returns `FALSE`.

### 16.4 Combining Conditions

The project uses:

```r
filter(
    !is.na(prev_avg_position),
    !is.na(prev_avg_points)
)
```

Multiple conditions supplied to `filter()` are combined using logical AND.

Therefore, an observation is retained only when both features are non-missing.

### 16.5 Why Early Observations Are Removed

The first race for each driver-season combination has no previous race result.

Consequently:

```r
lag(cummean(position))
```

and:

```r
lag(cummean(points))
```

produce missing values for that observation.

These observations are removed because the predictive models require historical information.

The filter does not explicitly test whether the recent average features are missing.

## 17. Data Leakage Prevention

Data leakage occurs when information unavailable at prediction time is used to train or evaluate a model.

For a pre-race prediction, the finishing position and championship points earned in the target race are not yet known.

Using those values directly as predictors would invalidate the prediction task.

### 17.1 How the Project Prevents Direct Target Leakage

The historical features use:

```r
lag(...)
```

to exclude the current race.

For example:

```r
lag(cummean(position))
```

uses cumulative finishing-position information from previous observations.

Similarly:

```r
slide_dbl(lag(points), mean, .before = 4, na.rm = TRUE)
```

uses previous points results rather than points earned in the current race.

### 17.2 Chronological Ordering

The observations are arranged by season and round before the historical calculations.

This is necessary to ensure that earlier races are processed before later races.

### 17.3 Important Limitation

The engineered features are historical, but the model also uses `grid`, representing the starting grid position.

This information is available after the starting grid has been established, rather than necessarily being available several days before a race.

Therefore, the intended prediction point is after grid information becomes available but before the race result is known.

Additionally, the correctness of the historical calculations depends on the underlying race records being complete and chronologically ordered.

## 18. Creating Training, Validation, and Test Datasets

After feature engineering, the project divides the observations into three datasets.

```r
train_data <- f1_data |>
    filter(season <= 2023) |>
    ungroup()

validation_data <- f1_data |>
    filter(season == 2024) |>
    ungroup()

test_data <- f1_data |>
    filter(season == 2025) |>
    ungroup()
```

### 18.1 Training Dataset

```r
filter(season <= 2023)
```

retains observations from seasons up to and including 2023.

In the project's dataset, this corresponds to 2021–2023.

The training dataset is used to fit the predictive models.

### 18.2 Validation Dataset

```r
filter(season == 2024)
```

retains observations from 2024.

The validation dataset is used to compare predictive models and examine their errors.

### 18.3 Test Dataset

```r
filter(season == 2025)
```

retains observations from 2025.

The test dataset is reserved for independent evaluation.

### 18.4 Comparison Operators

| Operator | Meaning | Project example |
|---|---|---|
| `<=` | Less than or equal to | `season <= 2023` |
| `==` | Equal to | `season == 2024` |
| `>` | Greater than | Not used in these split expressions |
| `>=` | Greater than or equal to | Not used in these split expressions |
| `!=` | Not equal to | Not used in these split expressions |

These operators produce logical values used by `filter()`.

## 19. Understanding `ungroup()`

The feature engineering dataset is grouped by driver and season.

Before modelling, the project removes this grouping.

```r
ungroup()
```

### 19.1 Purpose

`ungroup()` removes grouping metadata from a grouped data frame.

**Syntax:**

```r
ungroup(x, ...)
```

| Argument | Description |
|---|---|
| `x` | Grouped data frame |
| `...` | Optional grouping variables to remove |

Using `ungroup()` without specifying grouping variables removes all groups.

### 19.2 Why It Is Used

Grouping is useful when calculating driver-specific historical features.

However, it is not required for the subsequent model training and evaluation operations.

Removing grouping metadata prevents later data transformations from unintentionally operating within driver-season groups.

## 20. Saving the Modelling Datasets

The project saves the engineered dataset and the three chronological subsets.

```r
save(
    f1_data,
    train_data,
    validation_data,
    test_data,
    file = "../data/model_data.RData"
)
```

### 20.1 `save()`

Stores named R objects in an `.RData` file.

**Relevant syntax:**

```r
save(..., file)
```

| Argument | Description |
|---|---|
| `...` | Objects to save |
| `file` | Destination file path |

The resulting file contains four objects:

- `f1_data`
- `train_data`
- `validation_data`
- `test_data`

The next script loads these objects for model training and prediction.

## 21. Feature Visualisations

The script creates two scatter plots to investigate relationships between historical features and actual finishing positions.

### 21.1 Previous Average Position vs Actual Position

The first plot uses:

```r
aes(
    x = prev_avg_position,
    y = position
)
```

It includes:

```r
geom_point(
    alpha = 0.15,
    color = "steelblue"
)
```

and:

```r
geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
)
```

The scatter plot shows the relationship between historical average finishing position and actual finishing position.

The red line represents a fitted linear trend.

### 21.2 Previous Average Points vs Actual Position

The second plot uses:

```r
aes(
    x = prev_avg_points,
    y = position
)
```

The same point and trend-line settings are applied.

This plot examines whether previous championship-point performance is associated with finishing position.

## 22. Reversing the Finishing Position Axis

Both plots use:

```r
scale_y_reverse(breaks = 1:20)
```

### 22.1 `scale_y_reverse()`

Creates a reversed continuous y-axis.

**Relevant syntax:**

```r
scale_y_reverse(
    name = waiver(),
    breaks = waiver(),
    labels = waiver(),
    limits = NULL,
    ...
)
```

| Argument | Description |
|---|---|
| `name` | Axis title |
| `breaks` | Tick mark locations |
| `labels` | Tick mark labels |
| `limits` | Axis limits |
| `...` | Additional scale settings |

### 22.2 Why Reverse the Axis?

In Formula 1, finishing position 1 represents first place.

A lower numerical value is therefore a better result.

Reversing the y-axis places better finishing positions higher in the plot.

This makes the visual representation more intuitive.

## 23. Saving Feature Plots

The project exports two visualisations:

```r
ggsave(
    "../plots/prev_avg_position_vs_position.png",
    prev_avg_position_vs_position
)
```

```r
ggsave(
    "../plots/prev_avg_points_vs_position.png",
    prev_avg_points_vs_position
)
```

The `ggsave()` function saves a plot to a file.

Because explicit dimensions are not supplied, the default sizing behaviour is used.

## 24. Feature Engineering Outputs

The script generates:

```text
data/
└── model_data.RData

plots/
├── prev_avg_position_vs_position.png
└── prev_avg_points_vs_position.png
```

The `.RData` file contains the datasets required for model training.

The plots provide exploratory visual evidence about the relationship between historical performance and finishing position.

## 25. Summary of Engineered Features

| Feature | R expression | Historical information |
|---|---|---|
| `prev_avg_position` | `lag(cummean(position))` | All previous finishing positions in the season |
| `prev_avg_points` | `lag(cummean(points))` | All previous points results in the season |
| `recent_avg_position` | `slide_dbl(lag(position), mean, .before = 4, na.rm = TRUE)` | Up to five previous finishing positions |
| `recent_avg_points` | `slide_dbl(lag(points), mean, .before = 4, na.rm = TRUE)` | Up to five previous points results |

All four features are calculated separately for each driver-season combination.

## 26. Important Limitations

### 26.1 First-Race Exclusion

The first observation in each driver-season group has no previous race result.

These observations are excluded by the filtering step.

### 26.2 Season Reset

Historical averages reset at the beginning of each season.

The current implementation does not carry driver performance averages from one season into the next.

### 26.3 Rolling Window Length

The recent features use a maximum of five previous races.

This is a modelling choice and may not be the optimal window length for every driver or season.

### 26.4 Missing Values

The rolling calculations use `na.rm = TRUE`.

This means missing values are ignored when calculating the average.

If all values in a window are missing, `mean()` returns `NaN`.

### 26.5 Historical Features Are Not Complete Explanations

The engineered features summarise previous finishing positions and points.

They do not directly describe weather conditions, race strategy, mechanical failures, or other factors that can affect race outcomes.

## 27. Connection to Predictive Modelling

The resulting datasets are used by:

`scripts/03_models.R`

The modelling script loads:

```r
load("../data/model_data.RData")
```

It then trains several regression models using combinations of:

- Starting grid position.
- Previous average finishing position.
- Previous average championship points.
- Recent average finishing position.
- Recent average championship points.

The next document, `06_predictive_models.md`, explains the mathematical structure of these models, the `lm()` and `rpart()` functions, model formulas, prediction generation, and saved model objects.