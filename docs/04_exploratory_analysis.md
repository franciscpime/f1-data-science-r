
# Exploratory Data Analysis, Formula 1 Race Results

## 1. Introduction

Exploratory Data Analysis (EDA) is the process of examining a dataset to understand its structure, identify patterns, investigate relationships between variables, and detect potential limitations before predictive modelling.

In this project, EDA focuses on Formula 1 race results from 2021 to 2025.

The analysis is implemented in:

` scripts/01_eda.R `

The main objectives are to:

- Examine the distribution of finishing positions.
- Investigate the relationship between starting grid and finishing position.
- Compare this relationship across seasons.
- Calculate correlations between grid and finishing position.
- Summarise historical driver performance.
- Summarise historical team performance.
- Export visualisations and statistical results.

## 2. Loading the Dataset

The script begins by loading the tidyverse package and the combined historical dataset.

```r
library(tidyverse)

load("../data/f1_data.RData")
```

### 2.1 `library()`

Loads an installed R package.

**Syntax:**

```r
library(package)
```

| Argument | Description |
|---|---|
| `package` | Name of the package to load |

The tidyverse includes several packages used in this analysis, particularly `dplyr`, `ggplot2`, and `readr`.

### 2.2 `load()`

Restores R objects saved in an `.RData` file.

**Syntax:**

```r
load(file)
```

| Argument | Description |
|---|---|
| `file` | Path to the saved R data file |

The loaded object is `f1_data`, containing the combined historical race observations.

## 3. Converting Data Types

The script converts several columns into integer values.

```r
f1_data$round <- as.integer(f1_data$round)
f1_data$position <- as.integer(f1_data$position)
f1_data$points <- as.integer(f1_data$points)
f1_data$grid <- as.integer(f1_data$grid)
f1_data$laps <- as.integer(f1_data$laps)
```

### 3.1 `as.integer()`

Converts an object into integer values.

**Syntax:**

```r
as.integer(x)
```

| Argument | Description |
|---|---|
| `x` | Object to convert |

For example:

```r
as.integer("12")
```

returns the integer `12`.

This conversion is necessary because numerical fields retrieved from JSON may initially be stored as character strings.

**Important:** `as.integer()` truncates fractional numeric values rather than rounding them. Therefore, its use for `points` can remove fractional championship points if any are present in the source data.

## 4. The Native R Pipe Operator

The project uses the native R pipe operator:

```r
|>
```

The pipe passes the result of one expression into the next function call.

Example:

```r
f1_data |>
    group_by(season) |>
    summarise(
        average_position = mean(position)
    )
```

This is equivalent to nesting function calls, but makes the sequence of operations easier to read.

The pipe is particularly useful for constructing data transformation workflows.

## 5. Correlation Between Starting Grid and Finishing Position

The project calculates the correlation between starting grid position and finishing position for each season.

```r
correlation_by_season <- f1_data |>
    group_by(season) |>
    summarise(
        correlation = cor(grid, position)
    )
```

### 5.1 `group_by()`

Groups observations according to one or more variables.

**Syntax:**

```r
group_by(.data, ..., .add = FALSE, .drop = group_by_drop_default(.data))
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Variables used to define groups |
| `.add` | Whether to add groups to existing grouping variables |
| `.drop` | Whether to drop empty groups formed from factor levels |

In this project:

```r
group_by(season)
```

creates one group for each championship season.

Subsequent summary operations are calculated separately for each group.

### 5.2 `summarise()`

Creates summary values from a dataset.

**Syntax:**

```r
summarise(.data, ..., .by = NULL, .groups = NULL)
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Expressions defining summary columns |
| `.by` | Optional grouping for the current operation |
| `.groups` | Controls the grouping structure of the result |

In this project:

```r
summarise(
    correlation = cor(grid, position)
)
```

calculates one correlation value for each season.

### 5.3 `cor()`

Calculates the correlation between two numerical variables.

**Syntax:**

```r
cor(x, y = NULL, use = "everything", method = "pearson")
```

| Argument | Description |
|---|---|
| `x` | First numerical vector |
| `y` | Second numerical vector |
| `use` | Determines how missing values are handled |
| `method` | Correlation method, such as Pearson, Spearman, or Kendall |

The project uses:

```r
cor(grid, position)
```

Because `method` is not specified, R uses Pearson correlation.

Pearson correlation measures the strength and direction of a linear relationship.

Its values range from -1 to 1.

| Value | Interpretation |
|---|---|
| Close to 1 | Strong positive linear relationship |
| Close to 0 | Weak linear relationship |
| Close to -1 | Strong negative linear relationship |

In Formula 1, a positive correlation generally indicates that drivers starting further back also tend to finish further back.

A correlation does not establish causation.

### 5.4 Exporting Correlation Results

```r
write_csv(
    correlation_by_season,
    "../results/correlations_by_season.csv"
)
```

The exported file contains one correlation value per season.

## 6. Exporting Data with `write_csv()`

The project uses `write_csv()` from the `readr` package.

**Relevant syntax:**

```r
write_csv(x, file, na = "NA", append = FALSE, col_names = !append)
```

| Argument | Description |
|---|---|
| `x` | Data frame to export |
| `file` | Destination path or connection |
| `na` | Text representation of missing values |
| `append` | Whether to append to an existing file |
| `col_names` | Whether to include column names |

The project uses the default settings for these optional arguments.

CSV files allow statistical results to be inspected outside R, including in spreadsheet applications.

## 7. Introduction to `ggplot2`

The project uses `ggplot2` to create statistical visualisations.

A typical plot follows this structure:

```r
ggplot(data, aes(x = variable_x, y = variable_y)) +
    geom_point() +
    labs(
        title = "Example Plot",
        x = "X Axis",
        y = "Y Axis"
    ) +
    theme_minimal()
```

A `ggplot2` visualisation is constructed using layers.

The `+` operator adds layers to the plot.

These layers can define:

- Data and aesthetic mappings.
- Geometric representations.
- Statistical transformations.
- Facets.
- Scales.
- Titles and axis labels.
- Themes and visual formatting.

## 8. `ggplot()`

Initialises a ggplot object.

**Syntax:**

```r
ggplot(data = NULL, mapping = aes(), ...)
```

| Argument | Description |
|---|---|
| `data` | Dataset used for plotting |
| `mapping` | Aesthetic mappings, usually defined with `aes()` |
| `...` | Additional arguments |

Example:

```r
ggplot(
    f1_data,
    aes(x = grid, y = position)
)
```

This specifies the dataset and associates `grid` with the horizontal axis and `position` with the vertical axis.

A geometric layer is required to display the data.

## 9. `aes()`

Defines aesthetic mappings between variables and visual properties.

**Syntax:**

```r
aes(x = ..., y = ..., ...)
```

Common mappings include:

| Mapping | Purpose |
|---|---|
| `x` | Horizontal axis |
| `y` | Vertical axis |
| `color` | Colour determined by a variable |
| `fill` | Fill colour determined by a variable |
| `size` | Point or line size |
| `alpha` | Transparency |
| `group` | Grouping of observations |

Example:

```r
aes(x = grid, y = position)
```

A mapping inside `aes()` generally connects a visual property to data.

By contrast, a fixed value such as:

```r
geom_point(color = "steelblue")
```

sets the same colour for all points.

## 10. Finishing Position Distribution

The project creates a bar chart showing the frequency of finishing positions.

The plot uses:

```r
geom_bar(
    fill = "steelblue",
    color = "white"
)
```

### 10.1 `geom_bar()`

Creates a bar chart by counting observations for each x-axis value.

**Relevant syntax:**

```r
geom_bar(
    mapping = NULL,
    data = NULL,
    stat = "count",
    position = "stack",
    ...
)
```

| Argument | Description |
|---|---|
| `mapping` | Aesthetic mappings |
| `data` | Dataset used by the layer |
| `stat` | Statistical transformation |
| `position` | How overlapping bars are positioned |
| `fill` | Interior colour of the bars |
| `color` | Border colour of the bars |

By default, `geom_bar()` uses:

```r
stat = "count"
```

This counts the number of observations for each x-axis value.

In the project, each observation represents a driver's race result.

Therefore, the plot shows how frequently each finishing position occurs in the dataset.

### 10.2 `scale_x_continuous()`

The plot uses:

```r
scale_x_continuous(
    breaks = 1:20
)
```

**Relevant syntax:**

```r
scale_x_continuous(
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
| `breaks` | Locations of axis tick marks |
| `labels` | Labels displayed at tick marks |
| `limits` | Visible data range |
| `...` | Additional scale options |

The expression:

```r
1:20
```

generates integers from 1 through 20.

Setting `breaks = 1:20` requests tick marks for those finishing positions.

It does not automatically remove observations outside this range.

## 11. Starting Grid vs Finishing Position

The project includes a plot comparing starting grid and finishing position.

One version uses:

```r
geom_col()
```

### 11.1 `geom_col()`

Creates bars using values already provided in the data.

**Relevant syntax:**

```r
geom_col(
    mapping = NULL,
    data = NULL,
    position = "stack",
    ...
)
```

Unlike `geom_bar()`, `geom_col()` does not automatically count observations.

It uses the supplied y-values.

### 11.2 `geom_bar()` vs `geom_col()`

| Function | Default behaviour |
|---|---|
| `geom_bar()` | Counts observations |
| `geom_col()` | Uses existing y-values |

For example:

```r
ggplot(
    f1_data,
    aes(x = grid, y = position)
) +
    geom_col()
```

draws bars using finishing positions as their heights.

**Interpretation caution:** when multiple observations share the same grid position, the default stacking behaviour can combine their y-values. Therefore, this plot should not be interpreted as a direct one-to-one comparison between starting and finishing positions.

The project also includes a scatter plot that is more appropriate for examining the relationship between these two numerical variables.

## 12. Starting Grid vs Finishing Position by Season

The project creates a scatter plot with a linear trend line and separate panels for each season.

The relevant functions are:

```r
geom_point(alpha = 0.15) +
geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
) +
facet_wrap(~ season)
```

### 12.1 `geom_point()`

Creates a scatter plot.

**Relevant syntax:**

```r
geom_point(
    mapping = NULL,
    data = NULL,
    ...
)
```

Common arguments include:

| Argument | Description |
|---|---|
| `alpha` | Point transparency |
| `color` | Point colour |
| `size` | Point size |
| `shape` | Point symbol |

The project uses:

```r
alpha = 0.15
```

This makes points highly transparent.

Transparency helps reveal areas where many observations overlap.

### 12.2 `geom_smooth()`

Adds a fitted trend line or smooth curve.

**Relevant syntax:**

```r
geom_smooth(
    method = NULL,
    se = TRUE,
    ...
)
```

| Argument | Description |
|---|---|
| `method` | Statistical method used to fit the trend |
| `se` | Whether to display a confidence band |
| `color` | Line colour |
| `linewidth` | Line thickness |
| `linetype` | Line style |

The project uses:

```r
geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
)
```

Here:

- `method = "lm"` fits a linear regression trend.
- `se = FALSE` hides the confidence band.
- `color = "red"` sets the trend line colour.

The fitted line illustrates the overall linear relationship between starting and finishing positions.

It is an exploratory visualisation, not one of the final predictive models trained later in the project.

### 12.3 `facet_wrap()`

Divides a plot into multiple panels according to a variable.

**Relevant syntax:**

```r
facet_wrap(
    facets,
    nrow = NULL,
    ncol = NULL,
    scales = "fixed",
    ...
)
```

| Argument | Description |
|---|---|
| `facets` | Variable used to create panels |
| `nrow` | Number of rows |
| `ncol` | Number of columns |
| `scales` | Whether axes use fixed or independent scales |

The project uses:

```r
facet_wrap(~ season)
```

The formula `~ season` instructs `ggplot2` to create one panel for each season.

This allows the grid-position relationship to be compared across years.

## 13. Plot Labels with `labs()`

The project uses `labs()` to add descriptive text.

**Relevant syntax:**

```r
labs(
    title = NULL,
    subtitle = NULL,
    x = NULL,
    y = NULL,
    caption = NULL,
    ...
)
```

| Argument | Description |
|---|---|
| `title` | Main plot title |
| `subtitle` | Secondary title |
| `x` | Horizontal axis label |
| `y` | Vertical axis label |
| `caption` | Caption below the plot |

Example:

```r
labs(
    title = "Starting Grid vs Finishing Position",
    x = "Starting Grid Position",
    y = "Finishing Position"
)
```

Clear labels are important because Formula 1 finishing positions have a specific interpretation: lower numerical positions indicate better results.

## 14. Plot Themes

The project uses:

```r
theme_minimal()
```

### 14.1 `theme_minimal()`

Applies a minimal visual theme.

**Relevant syntax:**

```r
theme_minimal(base_size = 11, base_family = "")
```

| Argument | Description |
|---|---|
| `base_size` | Base text size |
| `base_family` | Font family |

The minimal theme reduces unnecessary visual elements and emphasises the data.

Other project scripts use additional `theme()` customisations, which are documented in the model evaluation section.

## 15. Saving Plots with `ggsave()`

The project exports plots as PNG images.

Example:

```r
ggsave(
    "../plots/position_distribution.png",
    position_distribution,
    width = 10,
    height = 5,
    dpi = 300
)
```

### 15.1 `ggsave()`

Saves a plot to an image or document file.

**Relevant syntax:**

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

| Argument | Description |
|---|---|
| `filename` | Output file path |
| `plot` | Plot object to save |
| `width` | Output width |
| `height` | Output height |
| `units` | Units for dimensions |
| `dpi` | Resolution in dots per inch |
| `...` | Additional graphics device arguments |

The project uses:

```r
width = 10
height = 5
dpi = 300
```

Because `units` is not specified, the dimensions are interpreted in inches.

A resolution of 300 DPI is suitable for high-resolution reports and academic documents.

Other plots in the project use default output dimensions.

## 16. Driver Performance Analysis

The project calculates average finishing positions for individual drivers.

The analysis uses:

```r
group_by(driver)
```

followed by:

```r
mean(position)
```

### 16.1 `mean()`

Calculates the arithmetic mean.

**Syntax:**

```r
mean(x, trim = 0, na.rm = FALSE, ...)
```

| Argument | Description |
|---|---|
| `x` | Numerical vector |
| `trim` | Fraction of observations to trim from each end |
| `na.rm` | Whether to remove missing values |
| `...` | Additional arguments |

Example:

```r
mean(c(3, 5, 7))
```

returns:

```text
5
```

In this project, the mean finishing position summarises the average result achieved by a driver across the observations in the dataset.

Lower average positions generally indicate stronger finishing results.

However, this measure does not account for all differences in car performance, race participation, or race circumstances.

### 16.2 `arrange()`

The results are ordered using `arrange()`.

**Syntax:**

```r
arrange(.data, ..., .by_group = FALSE)
```

| Argument | Description |
|---|---|
| `.data` | Input data frame |
| `...` | Variables used for sorting |
| `.by_group` | Whether grouped variables should be considered first |

Example:

```r
arrange(average_position)
```

sorts the observations in ascending order.

To sort in descending order, `desc()` can be used:

```r
arrange(desc(average_position))
```

### 16.3 `desc()`

Indicates descending order inside sorting operations.

**Syntax:**

```r
desc(x)
```

| Argument | Description |
|---|---|
| `x` | Variable to order in descending order |

## 17. Team Performance Analysis

The project also summarises average finishing positions by constructor.

The procedure follows the same general structure as the driver analysis, but uses:

```r
group_by(team)
```

This creates one group for each team.

The average finishing position is then calculated using `mean(position)`.

These summaries allow the project to compare historical finishing performance across teams.

As with driver averages, the results are descriptive and should not be interpreted as direct causal estimates of team performance.

## 18. Exploratory Analysis Outputs

The EDA script generates the following outputs.

### 18.1 Statistical Results

```text
results/
├── correlations_by_season.csv
├── pilots_performance.csv
└── teams_performance.csv
```

These files contain season-level correlations and driver/team performance summaries.

### 18.2 Visualisations

```text
plots/
├── position_distribution.png
├── grid_vs_position.png
└── grid_vs_position_season.png
```

The plots provide complementary perspectives on the dataset.

| Plot | Purpose |
|---|---|
| `position_distribution.png` | Shows the frequency of finishing positions |
| `grid_vs_position.png` | Displays finishing-position values against grid positions using columns |
| `grid_vs_position_season.png` | Examines the relationship between grid and finishing position across seasons |

## 19. Interpretation of EDA Results

The EDA stage helps identify variables that may be useful for predictive modelling.

Starting grid position is a particularly relevant candidate because it is known before a race begins.

Historical driver performance is another potential source of predictive information.

However, descriptive relationships do not guarantee predictive accuracy.

A variable may correlate with finishing position without improving predictions on future observations.

For this reason, the project evaluates predictors using chronological training and validation datasets.

## 20. Limitations of the Exploratory Analysis

### 20.1 Correlation Is Not Causation

A strong relationship between grid and finishing position does not establish that starting position alone causes the observed result.

Other factors may influence both variables.

### 20.2 Average Performance Can Hide Variation

Driver and team averages summarise many races into one number.

They may conceal differences between individual races or seasons.

### 20.3 Missing Values

Functions such as `mean()` and `cor()` can return missing results when relevant input values contain `NA`, unless missing-value handling is specified.

The project does not explicitly set `na.rm = TRUE` in these EDA calculations.

### 20.4 Finishing Position Is Ordinal in Meaning

Finishing position is represented numerically, but it describes an ordered ranking.

The numerical difference between positions does not necessarily correspond to a constant difference in underlying race performance.

### 20.5 Exploratory Plots Are Descriptive

EDA visualisations reveal patterns in the observed dataset.

They do not independently establish how well a predictive model will perform on unseen data.

## 21. Connection to Feature Engineering

The exploratory analysis provides context for selecting predictive variables.

The next stage creates historical performance features using previous race results.

These features include:

- Previous average finishing position.
- Previous average championship points.
- Recent average finishing position.
- Recent average championship points.

The next document, `05_feature_engineering.md`, explains how these features are calculated using `group_by()`, `arrange()`, `mutate()`, `lag()`, `cummean()`, `slide_dbl()`, `filter()`, and related functions.