
# Data Preparation, Formula 1 Historical Race Results

## 1. Introduction

This document describes how the raw Formula 1 JSON data is transformed into structured datasets suitable for exploratory data analysis, feature engineering, and predictive modelling.

The preparation process is implemented in R and covers the 2021–2025 Formula 1 seasons.

Each season is processed separately before all season datasets are combined into a single dataset.

The main objectives are to:

- Read previously collected JSON files.
- Navigate nested race and driver information.
- Extract relevant variables.
- Create structured observations for individual driver-race results.
- Combine observations into season datasets.
- Save prepared datasets for subsequent analysis.
- Combine all five seasons into one dataset.

## 2. Relevant Scripts

The data preparation stage uses the following scripts:

```text
scripts/
├── prepare_data/
│   ├── prepare_2021_data.R
│   ├── prepare_2022_data.R
│   ├── prepare_2023_data.R
│   ├── prepare_2024_data.R
│   └── prepare_2025_data.R
└── combine_data.R
```

Each season preparation script follows the same general approach, with the input and output filenames adjusted for the relevant year.

The `combine_data.R` script joins the prepared datasets into one historical dataset.

## 3. Loading Required Libraries

The preparation scripts use the `jsonlite` and `tidyverse` packages.

```r
library(jsonlite)
library(tidyverse)
```

### 3.1 `library()`

The `library()` function loads an installed R package into the current session.

**Syntax:**

```r
library(package)
```

| Argument | Description |
|---|---|
| `package` | Name of the package to load |

In this project:

- `jsonlite` provides functions for reading JSON files.
- `tidyverse` provides data manipulation functions, including `tibble()` and `bind_rows()`.

A package must be installed before it can be loaded.

## 4. Reading the JSON Files

Each season preparation script reads its corresponding full-season JSON file.

For example:

```r
api_data <- fromJSON(
    "../data/2021_results_full.json",
    simplifyVector = FALSE
)
```

### 4.1 `fromJSON()`

The `fromJSON()` function converts JSON data into R objects.

**Syntax:**

```r
fromJSON(txt, simplifyVector = TRUE, ...)
```

| Argument | Description |
|---|---|
| `txt` | JSON text, file path, or URL |
| `simplifyVector` | Whether JSON arrays should be simplified into R structures |
| `...` | Additional arguments |

The project uses `simplifyVector = FALSE` to preserve nested JSON arrays as lists.

This allows race and driver objects to be accessed explicitly.

### 4.2 Relative File Paths

The input path:

```r
"../data/2021_results_full.json"
```

contains `..`, which refers to the parent directory of the current working directory.

When R is executed from `scripts/`, the path points to the repository's `data/` directory.

The path is interpreted relative to the working directory, not automatically relative to the location of the R script.

## 5. Understanding the Nested JSON Structure

The JSON data contains several levels of information.

A simplified structure is:

```text
MRData
└── RaceTable
    ├── season
    └── Races
        ├── Race 1
        │   ├── round
        │   ├── raceName
        │   └── Results
        │       ├── Driver 1 result
        │       │   ├── Driver
        │       │   ├── Constructor
        │       │   ├── position
        │       │   ├── grid
        │       │   ├── points
        │       │   ├── laps
        │       │   └── status
        │       └── Driver 2 result
        └── Race 2
            └── Results
```

The preparation scripts navigate this hierarchy to retrieve the required information.

## 6. Accessing Named List Elements

R uses the `$` operator to access named elements within lists and data frames.

For example:

```r
api_data$MRData
```

retrieves the `MRData` object.

```r
api_data$MRData$RaceTable
```

retrieves the `RaceTable` object.

```r
api_data$MRData$RaceTable$Races
```

retrieves the list of races.

The `$` operator is particularly convenient when the element name is known.

## 7. Single and Double Square Brackets

R provides two important indexing operators for lists.

### 7.1 Single Square Brackets: `[ ]`

Single square brackets return a subset while preserving the list structure.

Example:

```r
races[1]
```

This returns a list containing the first race.

### 7.2 Double Square Brackets: `[[ ]]`

Double square brackets extract an individual element from a list.

Example:

```r
races[[1]]
```

This returns the first race object itself.

### 7.3 Why the Difference Matters

Suppose `races` contains several race objects.

```r
first_race_list <- races[1]
first_race <- races[[1]]
```

The first variable is a list containing one race.

The second variable is the actual race object.

To access fields such as `raceName` or `Results`, extracting the individual race object is generally more convenient.

For example:

```r
races[[1]]$raceName
```

## 8. Extracting Race Information

Each race contains information shared by all drivers participating in that race.

Examples include:

- Season.
- Round.
- Grand Prix name.

A race can be accessed using its position in the race collection.

For example:

```r
race <- races[[1]]
```

Then:

```r
race$round
race$raceName
race$Results
```

The `Results` field contains the individual driver results for that race.

These race-level fields must be associated with every corresponding driver observation.

## 9. Extracting Driver Information

Each race result contains information about one driver's performance.

The relevant fields include:

| JSON field | Prepared variable |
|---|---|
| `Driver$givenName` | Part of `driver` |
| `Driver$familyName` | Part of `driver` |
| `Constructor$name` | `team` |
| `position` | `position` |
| `grid` | `grid` |
| `points` | `points` |
| `laps` | `laps` |
| `status` | `status` |

The driver's full name is constructed from the given name and family name.

For example:

```r
driver <- paste(
    result$Driver$givenName,
    result$Driver$familyName
)
```

### 9.1 `paste()`

The `paste()` function combines values into character strings.

**Syntax:**

```r
paste(..., sep = " ", collapse = NULL)
```

| Argument | Description |
|---|---|
| `...` | Values to combine |
| `sep` | Separator placed between values |
| `collapse` | Optional separator used to combine multiple resulting strings into one |

By default, `sep = " "` inserts a space.

For example:

```r
paste("Lewis", "Hamilton")
```

returns:

```text
"Lewis Hamilton"
```

## 10. Iterating Through Races and Results

The preparation process needs to handle multiple races, each containing multiple driver results.

A `for` loop is used to repeat operations.

### 10.1 `for` Loop Syntax

```r
for (item in collection) {
    # Operations
}
```

| Element | Description |
|---|---|
| `item` | Variable representing the current element |
| `collection` | Sequence or collection to iterate over |
| `{ }` | Code executed during each iteration |

### 10.2 Iterating Over Race Indices

For example:

```r
for (i in seq_along(races)) {
    race <- races[[i]]
}
```

The loop processes each race in sequence.

### 10.3 `seq_along()`

The `seq_along()` function generates an integer sequence corresponding to the positions of an object's elements.

**Syntax:**

```r
seq_along(along.with)
```

| Argument | Description |
|---|---|
| `along.with` | Object whose length determines the sequence |

For example:

```r
seq_along(c("A", "B", "C"))
```

returns:

```r
1:3
```

Unlike `1:length(x)`, `seq_along(x)` safely returns an empty sequence when `x` has no elements.

### 10.4 Processing Driver Results

After accessing a race, its driver results can be processed.

Illustrative example:

```r
results <- race$Results

for (j in seq_along(results)) {
    result <- results[[j]]
}
```

The outer iteration processes races, while the inner iteration processes individual results.

This makes it possible to create one observation for each driver-race combination.

## 11. Creating Structured Data with `tibble()`

After extracting the relevant fields, the preparation scripts construct structured data using `tibble()`.

A tibble is a modern data frame provided by the `tibble` package, which is included in the tidyverse.

Illustrative example:

```r
race_data <- tibble(
    season = season,
    round = round,
    raceName = race_name,
    driver = driver,
    team = team,
    position = position,
    points = points,
    grid = grid,
    laps = laps,
    status = status
)
```

### 11.1 `tibble()`

**Syntax:**

```r
tibble(...)
```

| Argument | Description |
|---|---|
| `...` | Named vectors or values used to construct columns |

Each named argument creates a column.

For example:

```r
tibble(
    driver = c("Driver A", "Driver B"),
    position = c(1, 2)
)
```

produces:

| driver | position |
|---|---|
| Driver A | 1 |
| Driver B | 2 |

### 11.2 Column Lengths

Columns must have compatible lengths.

A value of length one can be recycled to match a longer column.

For example:

```r
tibble(
    season = 2021,
    driver = c("Driver A", "Driver B")
)
```

produces two observations, both with `season = 2021`.

This is useful when the same race or season information applies to multiple drivers.

## 12. Combining Observations with `bind_rows()`

Individual race observations need to be combined into a larger dataset.

The project uses `bind_rows()` for this purpose.

### 12.1 Function Syntax

```r
bind_rows(..., .id = NULL)
```

| Argument | Description |
|---|---|
| `...` | Data frames or lists of data frames to combine |
| `.id` | Optional column name used to identify the original input |

### 12.2 Example

```r
race_1 <- tibble(
    driver = "Driver A",
    position = 1
)

race_2 <- tibble(
    driver = "Driver B",
    position = 2
)

combined <- bind_rows(race_1, race_2)
```

Result:

| driver | position |
|---|---|
| Driver A | 1 |
| Driver B | 2 |

### 12.3 Why Use `bind_rows()`?

`bind_rows()` combines datasets vertically.

This means it adds observations rather than creating additional columns.

It also matches columns by name.

If an input is missing a column present in another input, the missing values are filled with `NA`.

The resulting dataset contains all combined observations.

## 13. Saving Prepared Season Datasets

After processing a season, the resulting R object is saved as an `.RData` file.

The project uses the `save()` function.

Example:

```r
save(
    data_2021,
    file = "../data/data_2021.RData"
)
```

### 13.1 `save()`

**Syntax:**

```r
save(..., file)
```

| Argument | Description |
|---|---|
| `...` | One or more R objects to save |
| `file` | Destination file path |

Unlike CSV, `.RData` preserves R objects in a format that can be loaded back into an R session.

An `.RData` file can contain multiple named objects.

### 13.2 `save()` vs `write_csv()`

| Function | Purpose |
|---|---|
| `save()` | Stores R objects in an R-specific format |
| `write_csv()` | Exports a rectangular dataset to CSV |

The project uses `.RData` files to preserve prepared datasets and model-related objects.

CSV files are primarily used for exported analysis and evaluation results.

## 14. Loading Prepared Season Datasets

The `combine_data.R` script loads the prepared season files.

For example:

```r
load("../data/data_2021.RData")
```

### 14.1 `load()`

**Syntax:**

```r
load(file)
```

| Argument | Description |
|---|---|
| `file` | Path to the `.RData` file |

The function restores the named objects stored in the file into the R environment.

This differs from functions such as `read_csv()`, which return a data frame that is usually assigned to a variable.

For example:

```r
load("../data/data_2021.RData")
```

restores the saved object using its original name.

## 15. Combining the Five Seasons

Once all season datasets have been prepared, the project combines them using `bind_rows()`.

Conceptually, the operation is:

```r
f1_data <- bind_rows(
    data_2021,
    data_2022,
    data_2023,
    data_2024,
    data_2025
)
```

This produces a dataset containing observations from all five seasons.

The combined dataset preserves the column structure shared by the prepared season datasets.

### 15.1 Why Combine Seasons?

Combining seasons provides a larger historical dataset.

This allows the project to:

- Compare performance across seasons.
- Explore historical patterns.
- Engineer driver performance features.
- Train models using multiple years of data.
- Evaluate models chronologically.

## 16. Saving the Combined Dataset

The combined dataset is saved using:

```r
save(
    f1_data,
    file = "../data/f1_data.RData"
)
```

The resulting file is used by subsequent scripts.

```text
data/f1_data.RData
```

This separates the data preparation stage from the later analysis stages.

## 17. Data Types and Conversion

JSON responses may represent numerical values as character strings.

For example:

```json
{
  "position": "1",
  "points": "25",
  "grid": "2"
}
```

These values need to be converted before numerical analysis.

The project performs explicit type conversions in its analysis and feature engineering scripts.

For example:

```r
f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)
```

### 17.1 `as.integer()`

The `as.integer()` function converts values to integer type.

**Syntax:**

```r
as.integer(x)
```

| Argument | Description |
|---|---|
| `x` | Object to convert |

Example:

```r
as.integer("5")
```

returns the integer value `5`.

### 17.2 Important Considerations

If a value cannot be converted to an integer, R may produce `NA` and issue a warning.

Also, conversion to integer is not always appropriate for values containing decimal fractions.

The project currently applies integer conversion to the fields shown above.

## 18. Missing Values

Missing data in R is represented by `NA`.

For example:

```r
x <- c(1, 2, NA, 4)
```

Missing values may arise from unavailable source fields or unsuccessful conversions.

The preparation stage should preserve the distinction between genuinely missing values and valid numeric values.

Later stages apply specific filtering rules to engineered features.

These rules are documented in `05_feature_engineering.md`.

## 19. Data Preparation Outputs

The preparation stage produces:

```text
data/
├── data_2021.RData
├── data_2022.RData
├── data_2023.RData
├── data_2024.RData
├── data_2025.RData
└── f1_data.RData
```

The individual season files allow each year to be processed separately.

The combined file supports analysis across all five seasons.

## 20. Data Preparation Workflow

The overall process is:

```text
Full-season JSON files
        |
        v
Read JSON using fromJSON()
        |
        v
Access MRData / RaceTable / Races
        |
        v
Iterate through races and driver results
        |
        v
Extract required variables
        |
        v
Construct structured tibbles
        |
        v
Combine observations using bind_rows()
        |
        v
Save individual season .RData files
        |
        v
Load all five season datasets
        |
        v
Combine seasons using bind_rows()
        |
        v
Save f1_data.RData
```

## 21. Important Implementation Considerations

### 21.1 Nested Data

The original API response is hierarchical.

The preparation stage converts this hierarchy into a rectangular dataset.

Each driver-race result becomes one observation.

### 21.2 Consistent Column Names

The five season datasets must use consistent column names for reliable combination.

### 21.3 Consistent Data Types

Variables should have compatible types across seasons.

Incompatible types can cause errors or unexpected conversions during combination.

### 21.4 Race-Level and Driver-Level Information

Race-level variables, such as season and race name, must be associated with the correct driver results.

### 21.5 Reproducibility

Saving prepared season datasets allows subsequent analysis without repeating the JSON extraction process.

## 22. Connection to the Next Stage

The combined dataset is used by:

```text
scripts/01_eda.R
```

The exploratory data analysis stage investigates the relationship between starting grid position and finishing position, driver performance, team performance, and seasonal patterns.

The next document, `04_exploratory_analysis.md`, explains the statistical functions, data transformations, and `ggplot2` visualisations used in that stage.