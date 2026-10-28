
# R Function Reference, Formula 1 Prediction Project

## 1. Introduction

This document is a technical reference for the R functions used throughout the Formula 1 finishing-position prediction project.

Its purpose is to explain how the functions work, what their arguments mean, and how they contribute to the project's data processing, exploratory analysis, feature engineering, predictive modelling, and model evaluation.

The reference covers the functions used in:

- `scripts/01_api_test.R`
- `scripts/prepare_data/`
- `scripts/combine_data.R`
- `scripts/01_eda.R`
- `scripts/02_features.R`
- `scripts/03_models.R`
- `scripts/04_evaluation.R`

Examples are based on the project's variables and workflows. Some are simplified illustrations rather than exact excerpts.

## 2. How to Read This Reference

Each function entry includes:

- **Package:** The package that provides the function.
- **Purpose:** What the function does.
- **Syntax:** The function's relevant calling structure.
- **Arguments:** Important parameters and their meanings.
- **Returns:** The type of result produced.
- **Project example:** How the function is used or can be illustrated with project data.
- **Important notes:** Behaviour, limitations, or common mistakes.

Functions may support additional arguments not listed here. The reference focuses on those relevant to the project.

---

# Part I — Packages, Files, and JSON

## 3. `library()`

**Package:** base

**Purpose:** Loads an installed R package.

```r
library(package)
```

| Argument | Description | Default |
|---|---|---|
| `package` | Package name | Required |
| `character.only` | Whether the package name is supplied as a character string | `FALSE` |

**Returns:** Normally returns invisibly after attaching the package.

**Project example:**

```r
library(tidyverse)
library(jsonlite)
library(slider)
library(rpart)
```

**Important notes:**

`library()` does not install packages. A package must already be installed.

## 4. `fromJSON()`

**Package:** jsonlite

**Purpose:** Converts JSON data into R objects.

```r
fromJSON(
    txt,
    simplifyVector = TRUE,
    simplifyDataFrame = simplifyVector,
    simplifyMatrix = simplifyVector,
    flatten = FALSE,
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `txt` | JSON text, file path, or URL | Required |
| `simplifyVector` | Simplifies JSON arrays into R vectors where possible | `TRUE` |
| `simplifyDataFrame` | Simplifies suitable arrays into data frames | Same as `simplifyVector` |
| `simplifyMatrix` | Simplifies suitable arrays into matrices | Same as `simplifyVector` |
| `flatten` | Flattens nested data-frame columns where applicable | `FALSE` |

**Returns:** An R representation of the JSON data, such as a list.

**Project example:**

```r
api_data <- fromJSON(
    "../data/2021_results_full.json",
    simplifyVector = FALSE
)
```

**Important notes:**

The project uses `simplifyVector = FALSE` to preserve nested race and result structures as lists.

## 5. `write_json()`

**Package:** jsonlite

**Purpose:** Serialises R objects into JSON files.

```r
write_json(
    x,
    path,
    pretty = FALSE,
    auto_unbox = FALSE,
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `x` | R object to serialise | Required |
| `path` | Destination file | Required |
| `pretty` | Adds indentation and readable formatting | `FALSE` |
| `auto_unbox` | Converts length-one atomic vectors into scalar JSON values | `FALSE` |

**Returns:** Writes a JSON file.

**Project example:**

```r
write_json(
    api_data,
    "../data/2021_results_full.json",
    pretty = TRUE,
    auto_unbox = TRUE
)
```

**Important notes:**

`auto_unbox = TRUE` can change whether a length-one value is represented as a JSON scalar or array. It should be used with awareness of the expected JSON structure.

## 6. `unlist()`

**Package:** base

**Purpose:** Flattens list structures.

```r
unlist(x, recursive = TRUE, use.names = TRUE)
```

| Argument | Description | Default |
|---|---|---|
| `x` | List or other object | Required |
| `recursive` | Whether nested lists should also be flattened | `TRUE` |
| `use.names` | Whether names should be retained | `TRUE` |

**Returns:** A flattened vector or list, depending on the input and settings.

**Project example:**

```r
all_races <- unlist(
    race_pages,
    recursive = FALSE
)
```

**Important notes:**

Using `recursive = FALSE` avoids recursively flattening all nested race information.

This is important when combining collections of race objects while preserving their internal structure.

## 7. `save()`

**Package:** base

**Purpose:** Saves named R objects to a file.

```r
save(..., file)
```

| Argument | Description | Default |
|---|---|---|
| `...` | Objects to save | Required |
| `file` | Destination path | Required |

**Returns:** Writes an R data file.

**Project example:**

```r
save(
    f1_data,
    file = "../data/f1_data.RData"
)
```

**Important notes:**

A single `.RData` file can store multiple objects.

## 8. `load()`

**Package:** base

**Purpose:** Restores objects saved using `save()`.

```r
load(file)
```

| Argument | Description | Default |
|---|---|---|
| `file` | File containing saved R objects | Required |

**Returns:** The names of the restored objects, invisibly.

**Project example:**

```r
load("../data/model_data.RData")
```

**Important notes:**

`load()` restores objects using their saved names and may overwrite existing objects with those names.

## 9. `write_csv()`

**Package:** readr

**Purpose:** Exports a data frame as CSV.

```r
write_csv(
    x,
    file,
    na = "NA",
    append = FALSE,
    col_names = !append
)
```

| Argument | Description | Default |
|---|---|---|
| `x` | Data frame | Required |
| `file` | Output path | Required |
| `na` | Representation of missing values | `"NA"` |
| `append` | Whether to append to an existing file | `FALSE` |
| `col_names` | Whether to write column names | `!append` |

**Returns:** Writes a CSV file.

**Project example:**

```r
write_csv(
    correlation_by_season,
    "../results/correlations_by_season.csv"
)
```

---

# Part II — Data Structures and Manipulation

## 10. `tibble()`

**Package:** tibble

**Purpose:** Creates a modern data frame.

```r
tibble(...)
```

| Argument | Description |
|---|---|
| `...` | Named vectors or expressions defining columns |

**Returns:** A tibble.

**Project example:**

```r
tibble(
    driver = c("Driver A", "Driver B"),
    position = c(3, 7)
)
```

**Important notes:**

Columns must have compatible lengths. Length-one values can be recycled.

## 11. `bind_rows()`

**Package:** dplyr

**Purpose:** Combines data frames vertically.

```r
bind_rows(..., .id = NULL)
```

| Argument | Description | Default |
|---|---|---|
| `...` | Data frames to combine | Required |
| `.id` | Optional source identifier column | `NULL` |

**Returns:** A combined data frame.

**Project example:**

```r
f1_data <- bind_rows(
    data_2021,
    data_2022,
    data_2023,
    data_2024,
    data_2025
)
```

**Important notes:**

Columns are matched by name. Missing columns are filled with `NA` where compatible.

## 12. `group_by()`

**Package:** dplyr

**Purpose:** Defines groups for subsequent operations.

```r
group_by(
    .data,
    ...,
    .add = FALSE
)
```

| Argument | Description | Default |
|---|---|---|
| `.data` | Input data frame | Required |
| `...` | Grouping variables | None |
| `.add` | Add to existing groups | `FALSE` |

**Returns:** A grouped data frame.

**Project example:**

```r
f1_data |>
    group_by(driver, season)
```

**Important notes:**

Grouped operations such as `mutate()` and `summarise()` operate within the defined groups.

## 13. `ungroup()`

**Package:** dplyr

**Purpose:** Removes grouping metadata.

```r
ungroup(x, ...)
```

| Argument | Description |
|---|---|
| `x` | Grouped data frame |
| `...` | Optional groups to remove |

**Returns:** A data frame with the specified grouping removed.

**Project example:**

```r
train_data <- f1_data |>
    filter(season <= 2023) |>
    ungroup()
```

## 14. `arrange()`

**Package:** dplyr

**Purpose:** Sorts rows.

```r
arrange(
    .data,
    ...,
    .by_group = FALSE
)
```

| Argument | Description | Default |
|---|---|---|
| `.data` | Input data frame | Required |
| `...` | Sorting variables | Required |
| `.by_group` | Sort by grouping variables first | `FALSE` |

**Returns:** A data frame with reordered rows.

**Project example:**

```r
arrange(season, round)
```

**Important notes:**

Chronological ordering is essential before calculating lagged or rolling features.

## 15. `desc()`

**Package:** dplyr

**Purpose:** Specifies descending order.

```r
desc(x)
```

| Argument | Description |
|---|---|
| `x` | Vector used for sorting |

**Project example:**

```r
arrange(desc(abs_error))
```

This places larger errors first.

## 16. `mutate()`

**Package:** dplyr

**Purpose:** Creates or modifies columns.

```r
mutate(
    .data,
    ...,
    .by = NULL,
    .keep = "all"
)
```

| Argument | Description | Default |
|---|---|---|
| `.data` | Input data frame | Required |
| `...` | New or modified columns | Required |
| `.by` | Temporary grouping | `NULL` |
| `.keep` | Existing columns to retain | `"all"` |

**Returns:** A data frame with new or modified columns.

**Project example:**

```r
mutate(
    prev_avg_position = lag(cummean(position))
)
```

## 17. `filter()`

**Package:** dplyr

**Purpose:** Retains rows satisfying logical conditions.

```r
filter(.data, ..., .by = NULL)
```

| Argument | Description | Default |
|---|---|---|
| `.data` | Input data frame | Required |
| `...` | Logical conditions | Required |
| `.by` | Temporary grouping | `NULL` |

**Returns:** A filtered data frame.

**Project example:**

```r
filter(
    !is.na(prev_avg_position),
    !is.na(prev_avg_points)
)
```

Multiple conditions are combined using logical AND.

## 18. `summarise()`

**Package:** dplyr

**Purpose:** Produces summary values.

```r
summarise(
    .data,
    ...,
    .by = NULL,
    .groups = NULL
)
```

| Argument | Description | Default |
|---|---|---|
| `.data` | Input data frame | Required |
| `...` | Summary expressions | Required |
| `.by` | Temporary grouping | `NULL` |
| `.groups` | Result grouping behaviour | `NULL` |

**Returns:** A summary data frame.

**Project example:**

```r
f1_data |>
    group_by(season) |>
    summarise(
        correlation = cor(grid, position)
    )
```

## 19. `slice_head()`

**Package:** dplyr

**Purpose:** Selects the first rows of a data frame.

```r
slice_head(.data, n = NULL, prop = NULL)
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `n` | Number of rows |
| `prop` | Proportion of rows |

**Returns:** A subset of the data frame.

**Project example:**

```r
validation_data |>
    arrange(desc(abs_error)) |>
    slice_head(n = 10)
```

## 20. `pivot_longer()`

**Package:** tidyr

**Purpose:** Reshapes data from wide to long format.

```r
pivot_longer(
    data,
    cols,
    names_to = "name",
    values_to = "value"
)
```

| Argument | Description | Default |
|---|---|---|
| `data` | Input data frame | Required |
| `cols` | Columns to reshape | Required |
| `names_to` | New column for original names | `"name"` |
| `values_to` | New column for values | `"value"` |

**Returns:** A longer data frame.

**Project example:**

```r
pivot_longer(
    cols = c(
        predicted_position,
        tree_prediction
    ),
    names_to = "model",
    values_to = "prediction"
)
```

## 21. `recode()`

**Package:** dplyr

**Purpose:** Replaces selected values using specified mappings.

```r
recode(.x, ..., .default = NULL, .missing = NULL)
```

| Argument | Description |
|---|---|
| `.x` | Input vector |
| `...` | Replacement mappings |
| `.default` | Replacement for unmatched values |
| `.missing` | Replacement for missing values |

**Project example:**

```r
dplyr::recode(
    model,
    predicted_position = "Linear Regression",
    tree_prediction = "Decision Tree"
)
```

---

# Part III — Numerical and Statistical Functions

## 22. `as.integer()`

**Package:** base

**Purpose:** Converts values to integer type.

```r
as.integer(x)
```

| Argument | Description |
|---|---|
| `x` | Object to convert |

**Returns:** An integer vector.

**Project example:**

```r
f1_data$position <- as.integer(f1_data$position)
```

**Important notes:**

Fractional numeric values are truncated, not rounded.

## 23. `mean()`

**Package:** base

**Purpose:** Calculates the arithmetic mean.

```r
mean(x, trim = 0, na.rm = FALSE, ...)
```

| Argument | Description | Default |
|---|---|---|
| `x` | Numerical vector | Required |
| `trim` | Fraction trimmed from both ends | `0` |
| `na.rm` | Remove missing values | `FALSE` |

**Returns:** A numeric mean.

**Project example:**

```r
mean(train_data$position)
```

This is used to calculate the baseline prediction.

## 24. `cummean()`

**Package:** dplyr

**Purpose:** Calculates cumulative means.

```r
cummean(x)
```

| Argument | Description |
|---|---|
| `x` | Numerical vector |

**Returns:** A numeric vector of cumulative averages.

**Project example:**

```r
cummean(position)
```

For:

```r
c(4, 6, 2)
```

the cumulative means are:

```text
4, 5, 4
```

## 25. `lag()`

**Package:** dplyr

**Purpose:** Shifts values to access previous observations.

```r
lag(
    x,
    n = 1L,
    default = NULL,
    order_by = NULL
)
```

| Argument | Description | Default |
|---|---|---|
| `x` | Input vector | Required |
| `n` | Number of positions shifted | `1` |
| `default` | Value inserted at the beginning | `NULL`, producing missing values |
| `order_by` | Optional ordering vector | `NULL` |

**Returns:** A shifted vector.

**Project example:**

```r
lag(cummean(position))
```

**Important notes:**

The order of observations determines which value is considered previous.

## 26. `slide_dbl()`

**Package:** slider

**Purpose:** Applies a function to sliding windows and returns double values.

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

| Argument | Description | Default |
|---|---|---|
| `.x` | Input vector | Required |
| `.f` | Function applied to each window | Required |
| `...` | Arguments passed to `.f` | None |
| `.before` | Previous elements included | `0` |
| `.after` | Following elements included | `0` |
| `.complete` | Require complete windows | `FALSE` |

**Returns:** A double vector.

**Project example:**

```r
slide_dbl(
    lag(position),
    mean,
    .before = 4,
    na.rm = TRUE
)
```

This calculates the mean of up to five previous finishing positions.

## 27. `cor()`

**Package:** stats

**Purpose:** Calculates correlation.

```r
cor(
    x,
    y = NULL,
    use = "everything",
    method = "pearson"
)
```

| Argument | Description | Default |
|---|---|---|
| `x` | First numeric vector | Required |
| `y` | Second numeric vector | `NULL` |
| `use` | Missing-value handling | `"everything"` |
| `method` | Correlation method | `"pearson"` |

**Returns:** A correlation coefficient or matrix.

**Project example:**

```r
cor(grid, position)
```

## 28. `abs()`

**Package:** base

**Purpose:** Calculates absolute values.

```r
abs(x)
```

**Returns:** Absolute values.

**Project example:**

```r
abs(position - predicted_position)
```

Used to calculate MAE.

## 29. `sqrt()`

**Package:** base

**Purpose:** Calculates square roots.

```r
sqrt(x)
```

**Returns:** Square-root values.

**Project example:**

```r
sqrt(mean(error^2))
```

Used to calculate RMSE.

## 30. `log1p()`

**Package:** base

**Purpose:** Calculates the natural logarithm of one plus a value.

```r
log1p(x)
```

**Returns:** Numeric logarithmic values.

**Project example:**

```r
log1p(recent_avg_points)
```

Unlike `log(x)`, this produces a finite result for `x = 0`.

## 31. `is.na()`

**Package:** base

**Purpose:** Identifies missing values.

```r
is.na(x)
```

**Returns:** A logical vector.

**Project example:**

```r
!is.na(prev_avg_position)
```

The `!` operator negates the logical result.

## 32. `cut()`

**Package:** base

**Purpose:** Converts numeric values into intervals.

```r
cut(
    x,
    breaks,
    labels = NULL,
    include.lowest = FALSE,
    right = TRUE
)
```

| Argument | Description | Default |
|---|---|---|
| `x` | Numerical vector | Required |
| `breaks` | Interval boundaries | Required |
| `labels` | Interval labels | `NULL` |
| `include.lowest` | Include lowest boundary | `FALSE` |
| `right` | Right-closed intervals | `TRUE` |

**Returns:** A factor representing intervals.

**Project example:**

```r
cut(
    grid,
    breaks = c(0, 5, 10, 15, 20),
    labels = c("1-5", "6-10", "11-15", "16-20")
)
```

---

# Part IV — Predictive Modelling

## 33. `lm()`

**Package:** stats

**Purpose:** Fits a linear regression model.

```r
lm(
    formula,
    data,
    subset,
    weights,
    na.action,
    method = "qr",
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `formula` | Response and predictors | Required |
| `data` | Training dataset | Optional |
| `subset` | Selected observations | All |
| `weights` | Observation weights | Unweighted |
| `na.action` | Missing-value handling | Session option |
| `method` | Fitting method | `"qr"` |

**Returns:** A fitted `lm` model object.

**Project example:**

```r
model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)
```

## 34. `rpart()`

**Package:** rpart

**Purpose:** Fits a recursive partitioning model.

```r
rpart(
    formula,
    data,
    method,
    control = rpart.control(),
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `formula` | Response and predictors | Required |
| `data` | Training dataset | Optional |
| `method` | Tree modelling method | Inferred from response |
| `control` | Tree-building settings | `rpart.control()` |

**Returns:** A fitted `rpart` model object.

**Project example:**

```r
tree_model <- rpart(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)
```

## 35. `rpart.control()`

**Package:** rpart

**Purpose:** Configures decision tree growth and pruning controls.

```r
rpart.control(
    minsplit = 20,
    minbucket = round(minsplit / 3),
    cp = 0.01,
    maxdepth = 30,
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `minsplit` | Minimum observations required to attempt a split | `20` |
| `minbucket` | Minimum observations in terminal nodes | Approximately `minsplit / 3` |
| `cp` | Complexity parameter | `0.01` |
| `maxdepth` | Maximum depth of the tree | `30` |

**Project relevance:**

The decision tree uses the default controls.

The project does not explicitly tune these values.

## 36. `predict()`

**Package:** stats (generic function)

**Purpose:** Generates predictions from fitted models.

```r
predict(object, newdata = NULL, ...)
```

| Argument | Description | Default |
|---|---|---|
| `object` | Fitted model | Required |
| `newdata` | Dataset containing predictors | Model-specific |
| `...` | Model-specific options | Varies |

**Returns:** Predictions, with the structure depending on the model and arguments.

**Project example:**

```r
predict(
    recent_points_model,
    newdata = validation_data
)
```

**Important notes:**

The prediction method is selected according to the fitted model's class.

---

# Part V — Statistical Diagnostics

## 37. `vif()`

**Package:** car

**Purpose:** Calculates Variance Inflation Factors.

```r
car::vif(mod, ...)
```

| Argument | Description |
|---|---|
| `mod` | Fitted regression model |
| `...` | Additional method-specific arguments |

**Returns:** VIF values, or generalised VIF information for certain model terms.

**Project example:**

```r
car::vif(improved_model)
```

Higher values indicate stronger linear relationships between predictors.

## 38. `bptest()`

**Package:** lmtest

**Purpose:** Performs the Breusch–Pagan test for heteroscedasticity.

```r
lmtest::bptest(
    formula,
    varformula = NULL,
    studentize = TRUE,
    data = list()
)
```

| Argument | Description | Default |
|---|---|---|
| `formula` | Model or formula | Required |
| `varformula` | Variance model formula | `NULL` |
| `studentize` | Studentized version | `TRUE` |
| `data` | Dataset | `list()` |

**Returns:** A hypothesis-test result.

**Project example:**

```r
lmtest::bptest(recent_points_model)
```

## 39. `cooks.distance()`

**Package:** stats

**Purpose:** Measures the influence of observations on fitted regression models.

```r
cooks.distance(model, ...)
```

| Argument | Description |
|---|---|
| `model` | Fitted model |
| `...` | Method-specific arguments |

**Returns:** Cook's distance values.

**Project example:**

```r
cooks.distance(improved_model)
```

## 40. `nobs()`

**Package:** stats

**Purpose:** Returns the number of observations used by a fitted model.

```r
nobs(object, ...)
```

| Argument | Description |
|---|---|
| `object` | Fitted model |
| `...` | Additional arguments |

**Returns:** Observation count.

**Project example:**

```r
4 / nobs(improved_model)
```

Used as a heuristic Cook's distance threshold.

## 41. `crPlots()`

**Package:** car

**Purpose:** Creates component-plus-residual plots.

```r
car::crPlots(model)
```

| Argument | Description |
|---|---|
| `model` | Fitted regression model |

**Returns:** Diagnostic plots.

**Project example:**

```r
car::crPlots(recent_points_model)
```

These plots help investigate possible departures from linear relationships.

---

# Part VI — Data Visualisation

## 42. `ggplot()`

**Package:** ggplot2

**Purpose:** Initialises a plot.

```r
ggplot(data, mapping = aes(), ...)
```

| Argument | Description |
|---|---|
| `data` | Dataset |
| `mapping` | Aesthetic mappings |

**Returns:** A ggplot object.

**Project example:**

```r
ggplot(
    f1_data,
    aes(x = grid, y = position)
)
```

## 43. `aes()`

**Package:** ggplot2

**Purpose:** Maps variables to visual properties.

```r
aes(x = ..., y = ..., ...)
```

Common mappings include:

- `x`
- `y`
- `color`
- `fill`
- `size`
- `alpha`
- `group`

**Project example:**

```r
aes(x = prev_avg_position, y = position)
```

## 44. `geom_bar()`

**Package:** ggplot2

**Purpose:** Displays counts as bars.

```r
geom_bar(
    stat = "count",
    position = "stack",
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `stat` | Statistical transformation | `"count"` |
| `position` | Bar positioning | `"stack"` |

**Project example:**

```r
geom_bar(
    fill = "steelblue",
    color = "white"
)
```

## 45. `geom_col()`

**Package:** ggplot2

**Purpose:** Creates bars using supplied y-values.

```r
geom_col(
    position = "stack",
    ...
)
```

**Project example:**

```r
geom_col()
```

**Important notes:**

Unlike `geom_bar()`, `geom_col()` does not automatically count observations.

## 46. `geom_point()`

**Package:** ggplot2

**Purpose:** Creates scatter plot points.

```r
geom_point(...)
```

Common arguments:

| Argument | Description |
|---|---|
| `alpha` | Transparency |
| `color` | Point colour |
| `size` | Point size |
| `shape` | Point symbol |

**Project example:**

```r
geom_point(alpha = 0.15)
```

## 47. `geom_smooth()`

**Package:** ggplot2

**Purpose:** Adds a fitted trend or smooth curve.

```r
geom_smooth(
    method = NULL,
    se = TRUE,
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `method` | Fitting method | Automatic |
| `se` | Show confidence band | `TRUE` |

**Project example:**

```r
geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
)
```

## 48. `geom_histogram()`

**Package:** ggplot2

**Purpose:** Displays the distribution of numerical observations.

```r
geom_histogram(
    binwidth = NULL,
    bins = NULL,
    ...
)
```

| Argument | Description |
|---|---|
| `binwidth` | Width of bins |
| `bins` | Number of bins |

**Project relevance:**

Used to visualise prediction error distributions.

## 49. `facet_wrap()`

**Package:** ggplot2

**Purpose:** Creates separate plot panels.

```r
facet_wrap(
    facets,
    nrow = NULL,
    ncol = NULL,
    scales = "fixed"
)
```

| Argument | Description |
|---|---|
| `facets` | Variable defining panels |
| `nrow` | Number of panel rows |
| `ncol` | Number of panel columns |
| `scales` | Axis scale behaviour |

**Project example:**

```r
facet_wrap(~ season)
```

## 50. `labs()`

**Package:** ggplot2

**Purpose:** Adds titles and labels.

```r
labs(
    title = NULL,
    x = NULL,
    y = NULL,
    caption = NULL
)
```

**Project example:**

```r
labs(
    title = "Grid vs Finishing Position",
    x = "Starting Grid",
    y = "Finishing Position"
)
```

## 51. `theme_minimal()`

**Package:** ggplot2

**Purpose:** Applies a minimal plot theme.

```r
theme_minimal(
    base_size = 11,
    base_family = ""
)
```

**Project example:**

```r
theme_minimal()
```

## 52. `theme()`

**Package:** ggplot2

**Purpose:** Customises plot appearance.

```r
theme(...)
```

**Project relevance:**

Used to adjust visual properties such as text, axes, and plot elements.

## 53. `element_text()`

**Package:** ggplot2

**Purpose:** Configures text appearance within a theme.

```r
element_text(
    family = NULL,
    face = NULL,
    colour = NULL,
    size = NULL,
    angle = NULL,
    hjust = NULL,
    vjust = NULL,
    ...
)
```

Common arguments:

| Argument | Description |
|---|---|
| `size` | Font size |
| `angle` | Text rotation |
| `hjust` | Horizontal justification |
| `vjust` | Vertical justification |
| `face` | Font style |

## 54. `scale_x_continuous()`

**Package:** ggplot2

**Purpose:** Configures a continuous x-axis.

```r
scale_x_continuous(
    breaks = waiver(),
    labels = waiver(),
    limits = NULL,
    ...
)
```

**Project example:**

```r
scale_x_continuous(breaks = 1:20)
```

## 55. `scale_y_reverse()`

**Package:** ggplot2

**Purpose:** Reverses a continuous y-axis.

```r
scale_y_reverse(
    breaks = waiver(),
    labels = waiver(),
    limits = NULL,
    ...
)
```

**Project example:**

```r
scale_y_reverse(breaks = 1:20)
```

This places better finishing positions higher on the plot.

## 56. `coord_equal()`

**Package:** ggplot2

**Purpose:** Maintains equal physical scales on both axes.

```r
coord_equal(
    ratio = 1,
    xlim = NULL,
    ylim = NULL,
    expand = TRUE
)
```

**Project example:**

```r
coord_equal()
```

Useful for actual-versus-predicted plots.

## 57. `ggsave()`

**Package:** ggplot2

**Purpose:** Saves a plot to a file.

```r
ggsave(
    filename,
    plot = last_plot(),
    width = NA,
    height = NA,
    units = "in",
    dpi = 300,
    ...
)
```

| Argument | Description | Default |
|---|---|---|
| `filename` | Output path | Required |
| `plot` | Plot object | Last plot |
| `width` | Image width | Device-dependent |
| `height` | Image height | Device-dependent |
| `units` | Dimension units | `"in"` |
| `dpi` | Resolution | `300` |

**Project example:**

```r
ggsave(
    "../plots/position_distribution.png",
    position_distribution,
    width = 10,
    height = 5,
    dpi = 300
)
```

---

# Part VII — Additional R Operations

## 58. `paste()`

**Package:** base

**Purpose:** Combines values into character strings.

```r
paste(
    ...,
    sep = " ",
    collapse = NULL
)
```

| Argument | Description | Default |
|---|---|---|
| `...` | Values to combine | Required |
| `sep` | Separator between values | Space |
| `collapse` | Separator for combining resulting strings | `NULL` |

**Project example:**

```r
paste(
    result$Driver$givenName,
    result$Driver$familyName
)
```

## 59. `seq_along()`

**Package:** base

**Purpose:** Generates indices for the elements of an object.

```r
seq_along(along.with)
```

**Project example:**

```r
for (i in seq_along(races)) {
    race <- races[[i]]
}
```

**Important notes:**

Unlike `1:length(x)`, `seq_along(x)` behaves safely when the input has zero elements.

## 60. `print()`

**Package:** base

**Purpose:** Displays an R object.

```r
print(x, ...)
```

| Argument | Description |
|---|---|
| `x` | Object to display |
| `...` | Method-specific options |

**Project example:**

```r
print(validation_data, width = Inf)
```

For tibbles, `width = Inf` requests the display of all columns.

## 61. `num()`

**Package:** scales

**Purpose:** Formats numerical values for presentation.

```r
scales::num(
    x,
    accuracy = NULL,
    scale = 1,
    ...,
    digits = NULL
)
```

| Argument | Description |
|---|---|
| `x` | Numeric input |
| `accuracy` | Optional rounding accuracy |
| `scale` | Multiplicative scaling factor |
| `digits` | Number of significant digits |

**Project relevance:**

Used to format evaluation metrics.

**Important notes:**

Significant digits are not the same as decimal places.

---

# Part VIII — Key R Concepts

## 62. The Native Pipe Operator `|>`

**Purpose:** Passes the result of one expression into another function.

```r
f1_data |>
    group_by(season) |>
    summarise(
        average_position = mean(position)
    )
```

The native pipe usually passes the left-hand result as the first argument of the next function.

It makes multi-step data transformations easier to read.

## 63. The `$` Operator

**Purpose:** Accesses a named element.

```r
f1_data$position
```

or:

```r
api_data$MRData
```

The `$` operator is commonly used with lists and data frames.

## 64. Single Brackets `[ ]`

**Purpose:** Selects subsets while retaining the outer structure for lists.

```r
races[1]
```

This returns a list containing the first race.

## 65. Double Brackets `[[ ]]`

**Purpose:** Extracts an individual element.

```r
races[[1]]
```

This returns the first race object.

## 66. The Formula Operator `~`

**Purpose:** Separates the response from the predictors in a model formula.

```r
position ~ grid + prev_avg_position
```

The left-hand side identifies the response.

The right-hand side specifies the model terms.

## 67. Logical Operators

| Operator | Meaning | Example |
|---|---|---|
| `!` | NOT | `!is.na(position)` |
| `&` | Element-wise AND | `a & b` |
| `|` | Element-wise OR | `a | b` |
| `==` | Equal to | `season == 2024` |
| `!=` | Not equal to | `season != 2024` |
| `<` | Less than | `grid < 10` |
| `<=` | Less than or equal to | `season <= 2023` |
| `>` | Greater than | `grid > 10` |
| `>=` | Greater than or equal to | `grid >= 10` |

These operators are frequently used in filtering and conditional expressions.

## 68. Missing Values: `NA` vs `NaN`

`NA` represents a missing value.

`NaN` represents an undefined numerical result.

For example:

```r
mean(numeric(0))
```

returns:

```text
NaN
```

The project may encounter undefined rolling averages when no previous race results are available.

Both `NA` and `NaN` are identified by `is.na()`.

## 69. Working with Relative Paths

The project frequently uses paths such as:

```r
"../data/model_data.RData"
```

The `..` component refers to the parent directory of the current working directory.

Paths are resolved relative to R's working directory, not automatically relative to the script file.

Therefore, running scripts from an unexpected working directory can produce file-not-found errors.

## 70. Function Namespaces

R allows functions to be called with an explicit package prefix.

For example:

```r
car::vif(model)
```

```r
lmtest::bptest(model)
```

```r
dplyr::recode(x, ...)
```

The `::` operator accesses an exported function from a specified package.

This is useful when different packages provide functions with the same name.

---

# Part IX — Quick Reference by Project Stage

## 71. Data Collection

| Function | Purpose |
|---|---|
| `fromJSON()` | Read API responses and JSON files |
| `write_json()` | Save JSON |
| `unlist()` | Combine nested list collections |
| `seq_along()` | Iterate safely through collections |

## 72. Data Preparation

| Function | Purpose |
|---|---|
| `tibble()` | Create structured observations |
| `bind_rows()` | Combine race and season data |
| `paste()` | Construct driver names |
| `save()` | Save prepared R objects |
| `load()` | Restore prepared R objects |
| `as.integer()` | Convert numerical fields |

## 73. Exploratory Data Analysis

| Function | Purpose |
|---|---|
| `group_by()` | Define analysis groups |
| `summarise()` | Calculate group summaries |
| `cor()` | Calculate correlations |
| `mean()` | Calculate average performance |
| `arrange()` | Sort performance tables |
| `ggplot()` | Initialise plots |
| `geom_bar()` | Display counts |
| `geom_col()` | Display supplied values |
| `geom_point()` | Display numerical relationships |
| `geom_smooth()` | Add fitted trends |
| `facet_wrap()` | Compare seasons |
| `ggsave()` | Export plots |

## 74. Feature Engineering

| Function | Purpose |
|---|---|
| `group_by()` | Separate driver-season histories |
| `arrange()` | Ensure chronological order |
| `mutate()` | Create historical features |
| `lag()` | Exclude current observations |
| `cummean()` | Calculate cumulative averages |
| `slide_dbl()` | Calculate rolling averages |
| `filter()` | Remove incomplete observations |
| `is.na()` | Detect missing values |
| `ungroup()` | Remove grouping before modelling |

## 75. Predictive Modelling

| Function | Purpose |
|---|---|
| `lm()` | Train linear regression models |
| `rpart()` | Train regression trees |
| `rpart.control()` | Configure tree behaviour |
| `predict()` | Generate predictions |
| `log1p()` | Transform recent points |
| `mean()` | Calculate baseline predictions |
| `mutate()` | Add prediction columns |

## 76. Model Evaluation

| Function | Purpose |
|---|---|
| `abs()` | Calculate absolute errors |
| `sqrt()` | Calculate RMSE |
| `mean()` | Calculate MAE |
| `cut()` | Group grid positions |
| `pivot_longer()` | Reshape model predictions |
| `recode()` | Rename model labels |
| `vif()` | Investigate multicollinearity |
| `bptest()` | Test for heteroscedasticity |
| `cooks.distance()` | Measure influence |
| `nobs()` | Count model observations |
| `crPlots()` | Investigate functional relationships |
| `slice_head()` | Select large-error observations |
| `write_csv()` | Export evaluation results |

## 77. Final Notes

This reference documents the main R functions and operations relevant to the project's implementation.

The functions are used together in a reproducible workflow:

1. Collect historical Formula 1 results.
2. Convert JSON data into structured datasets.
3. Explore the data and identify relationships.
4. Create historical driver performance features.
5. Train predictive models.
6. Generate validation and test predictions.
7. Evaluate prediction accuracy and model diagnostics.

For complete context, consult the corresponding project documentation files.

The next document, `09_project_workflow.md`, explains the execution order, script dependencies, input and output files, and how the full project pipeline fits together.