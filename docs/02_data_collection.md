
# Data Collection, Formula 1 Historical Race Results

## 1. Introduction

This document describes the process of collecting historical Formula 1 race results using R and the Jolpica-F1 API.

The data collection stage provides the raw information required for data preparation, exploratory data analysis, feature engineering, and predictive modelling.

The project covers five Formula 1 seasons, from 2021 to 2025.

The data is retrieved in JSON format and stored locally for subsequent processing.

## 2. Data Source

The project uses the **Jolpica-F1 API**, which provides historical Formula 1 data through an Ergast-compatible interface.

Base URL:

`https://api.jolpi.ca/ergast/f1/`

The results endpoint follows this structure:

`https://api.jolpi.ca/ergast/f1/{season}/results/`

The `{season}` parameter identifies the championship season.

For example:

`https://api.jolpi.ca/ergast/f1/2021/results/`

This endpoint retrieves race result records for the 2021 season.

### 2.1 Why Use an API?

An Application Programming Interface (API) allows a program to request information from an external service.

Instead of manually collecting results from individual race reports, the project uses HTTP requests to retrieve structured data.

This provides several advantages:

- Consistent data structure across seasons.
- Automated retrieval of multiple race results.
- Reduced manual data entry.
- Reproducible data collection.
- Compatibility with R data processing tools.

## 3. API Request Parameters

The project uses pagination to retrieve season results across multiple requests.

Example:

`https://api.jolpi.ca/ergast/f1/2021/results/?limit=100&offset=0`

The URL contains three important elements.

| Element | Example | Purpose |
|---|---|---|
| Season | `2021` | Selects the Formula 1 championship season |
| `limit` | `100` | Requests up to 100 result records in one response |
| `offset` | `0` | Specifies how many result records to skip |

### 3.1 The `limit` Parameter

The `limit` parameter controls the maximum number of records returned in a single response.

For example:

`limit=100`

This requests up to 100 result records.

The API may return fewer records if fewer are available.

Importantly, a result record represents an individual driver's race result, not necessarily an entire Grand Prix.

Therefore, 100 result records do not mean 100 races.

### 3.2 The `offset` Parameter

The `offset` parameter determines where the API should begin returning records.

For example:

| Request | Offset | Requested record positions |
|---|---|---|
| First | `0` | 1–100 |
| Second | `100` | 101–200 |
| Third | `200` | 201–300 |
| Fourth | `300` | 301–400 |
| Fifth | `400` | 401–500 |

These ranges describe pagination positions, not race rounds.

The exact number of records available depends on the season and API response.

## 4. Pagination

### 4.1 What Is Pagination?

Pagination is the process of retrieving a large dataset through multiple smaller requests.

APIs commonly limit the number of records returned per request.

If a season contains more records than the selected limit, a single request will not retrieve the entire dataset.

The project therefore requests multiple pages using different offsets.

### 4.2 Pagination Example

The following code illustrates the API URL construction used in the project:

```r
season <- 2021
offset <- 0

url <- paste0(
    "https://api.jolpi.ca/ergast/f1/",
    season,
    "/results/?limit=100&offset=",
    offset
)
```

The resulting URL is:

`https://api.jolpi.ca/ergast/f1/2021/results/?limit=100&offset=0`

Changing `offset` to `100` requests the next page.

### 4.3 Why Combine Pages?

Each API response contains only the records included in that request.

To prepare a complete season dataset, the race information from the different responses must be combined.

The project's collection workflow accumulates race objects from multiple pages and combines them into a single collection.

The combined race objects are then assigned to the `Races` field of the JSON structure before the resulting data is saved.

## 5. Reading JSON Data in R

The project uses the `jsonlite` package.

```r
library(jsonlite)
```

The package provides functions for converting between JSON and R objects.

### 5.1 `fromJSON()`

The `fromJSON()` function reads JSON data and converts it into R objects.

Example:

```r
api_data <- fromJSON(
    url,
    simplifyVector = FALSE
)
```

#### Function Syntax

```r
fromJSON(txt, simplifyVector = TRUE, ...)
```

#### Arguments

| Argument | Description |
|---|---|
| `txt` | JSON text, a file path, or a URL containing JSON data |
| `simplifyVector` | Controls whether JSON arrays are simplified into R vectors or data frames when possible |
| `...` | Additional arguments supported by the function |

#### Why Use `simplifyVector = FALSE`?

By default, `fromJSON()` attempts to simplify JSON structures.

When `simplifyVector = FALSE`, arrays remain represented as lists.

This is useful when working with nested Formula 1 API responses, where the structure contains several levels of lists.

For example, race results are nested within race objects, which are themselves nested within the API response.

Preserving this structure allows the project to navigate the data explicitly.

### 5.2 Reading from a URL vs a Local File

`fromJSON()` can read directly from an API URL:

```r
api_data <- fromJSON(
    "https://api.jolpi.ca/ergast/f1/2021/results/?limit=100&offset=0",
    simplifyVector = FALSE
)
```

It can also read a previously downloaded JSON file:

```r
api_data <- fromJSON(
    "../data/2021_results_full.json",
    simplifyVector = FALSE
)
```

The first example retrieves data from an external service.

The second reads data already stored on the computer.

Using locally saved files allows later processing without repeatedly requesting the same information from the API.

## 6. JSON Response Structure

The API returns a nested JSON object.

A simplified representation is shown below:

```json
{
  "MRData": {
    "RaceTable": {
      "season": "2021",
      "Races": [
        {
          "season": "2021",
          "round": "1",
          "raceName": "Bahrain Grand Prix",
          "Results": [
            {
              "position": "1",
              "grid": "1",
              "points": "25",
              "Driver": {
                "givenName": "Lewis",
                "familyName": "Hamilton"
              },
              "Constructor": {
                "name": "Mercedes"
              }
            }
          ]
        }
      ]
    }
  }
}
```

This example is abbreviated to illustrate the hierarchy.

The actual response contains additional fields.

### 6.1 Main JSON Levels

| Level | Description |
|---|---|
| `MRData` | Main API response object |
| `RaceTable` | Collection of race information |
| `Races` | Array of race objects |
| `Results` | Array of driver result objects for a race |
| `Driver` | Driver information |
| `Constructor` | Team information |

### 6.2 Accessing Nested Objects

R uses the `$` operator to access named elements within lists.

For example:

```r
api_data$MRData
```

Accesses the main API response object.

```r
api_data$MRData$RaceTable
```

Accesses the race table.

```r
api_data$MRData$RaceTable$Races
```

Accesses the collection of races.

### 6.3 Accessing Individual Races

When `Races` is a list, double square brackets can be used to retrieve one race object.

```r
api_data$MRData$RaceTable$Races[[1]]
```

This retrieves the first race object.

The distinction between single and double square brackets is important:

- `[1]` returns a sublist containing the first element.
- `[[1]]` extracts the first element itself.

For nested JSON data, `[[ ]]` is particularly useful when accessing individual race or result objects.

### 6.4 Accessing Driver Results

A race object contains a `Results` list.

Example:

```r
race <- api_data$MRData$RaceTable$Races[[1]]

results <- race$Results
```

The first driver's result can be accessed using:

```r
results[[1]]
```

Individual fields can then be extracted:

```r
results[[1]]$position
results[[1]]$grid
results[[1]]$points
results[[1]]$Driver$givenName
results[[1]]$Driver$familyName
results[[1]]$Constructor$name
```

This structure is used during the data preparation stage.

## 7. Combining API Responses

The collection process uses a list to accumulate race objects from multiple API pages.

### 7.1 Lists in R

A list is a data structure capable of storing different types of objects.

For example:

```r
all_races <- list()
```

This creates an empty list.

As additional API pages are retrieved, their race objects can be added to the collection.

### 7.2 `unlist()`

The project's collection script uses:

```r
all_races <- unlist(
    all_races,
    recursive = FALSE
)
```

#### Function Syntax

```r
unlist(x, recursive = TRUE, use.names = TRUE)
```

#### Arguments

| Argument | Description |
|---|---|
| `x` | The list to process |
| `recursive` | Controls whether nested lists are flattened recursively |
| `use.names` | Controls whether names are preserved in the result |

#### Why Use `recursive = FALSE`?

The project needs to combine accumulated race collections without flattening all the nested fields inside each race.

Setting `recursive = FALSE` prevents recursive flattening through every level of the JSON hierarchy.

This helps preserve race objects containing nested driver and constructor information.

The exact result also depends on how the original list was constructed.

## 8. Replacing the Race Collection

After combining the API pages, the project updates the `Races` field:

```r
api_data$MRData$RaceTable$Races <- all_races
```

This assignment replaces the existing race collection in `api_data` with the accumulated collection.

The purpose is to produce a single JSON object containing the collected race information.

The surrounding `MRData` and `RaceTable` structure is retained.

## 9. Saving JSON Files

The project uses `write_json()` to save API data locally.

Example:

```r
write_json(
    api_data,
    "../data/2025_results_full.json",
    pretty = TRUE,
    auto_unbox = TRUE
)
```

### 9.1 Function Syntax

```r
write_json(x, path, ...)
```

### 9.2 Arguments

| Argument | Description |
|---|---|
| `x` | R object to convert into JSON |
| `path` | Destination file path |
| `pretty` | Controls readable indentation and formatting |
| `auto_unbox` | Controls automatic conversion of length-one vectors into JSON scalar values |
| `...` | Additional JSON conversion options |

### 9.3 `pretty = TRUE`

This formats the JSON with indentation and line breaks.

It makes the saved file easier to inspect manually.

### 9.4 `auto_unbox = TRUE`

R vectors and JSON arrays are not identical structures.

The `auto_unbox` argument controls how length-one vectors are represented.

For example, automatic unboxing can represent a single value as:

```json
"season": "2025"
```

rather than:

```json
"season": ["2025"]
```

This option is useful when preserving scalar-style fields in the saved JSON structure.

It does not guarantee that every saved field will exactly match the original API representation.

## 10. File Paths

The scripts use relative file paths.

For example:

```r
"../data/2025_results_full.json"
```

The `..` component refers to the parent directory of the current working directory.

When a script is executed from the `scripts/` directory, this path refers to the `data/` directory at the repository root.

Relative paths help keep project files organised without requiring an absolute path specific to one computer.

However, their behaviour depends on the working directory from which R is executed.

## 11. Data Collection Outputs

The repository contains JSON files associated with each season.

Examples include:

```text
data/
├── 2021_results.json
├── 2021_results_full.json
├── 2022_results.json
├── 2022_results_full.json
├── 2023_results.json
├── 2023_results_full.json
├── 2024_results.json
├── 2024_results_full.json
├── 2025_results.json
└── 2025_results_full.json
```

The `_full.json` files are used by the season preparation scripts.

Keeping raw API responses separate from prepared `.RData` files allows the project to distinguish data collection from data transformation.

## 12. Data Collection Considerations

### 12.1 API Availability

Retrieving data directly from an API requires the service to be accessible.

Network errors or temporary service interruptions can prevent successful requests.

Locally saved JSON files reduce this dependency during later stages.

### 12.2 Pagination Completeness

When using pagination, all required pages must be retrieved.

Missing pages can lead to incomplete season datasets.

The collection process should therefore be checked against the total number of available records.

### 12.3 Data Types

Some numeric information in the JSON response is represented as text.

For example:

```json
"position": "1"
```

The data preparation stage converts relevant fields into numeric types for analysis and modelling.

### 12.4 Reproducibility

Saving the downloaded JSON files makes it possible to repeat data preparation and analysis without requiring the API to return identical responses at a later date.

The saved files represent the collected data used in the project.

## 13. Connection to the Next Stage

The data collection stage produces JSON files containing nested race and driver information.

These files are then processed by the season preparation scripts:

```text
scripts/prepare_data/
├── prepare_2021_data.R
├── prepare_2022_data.R
├── prepare_2023_data.R
├── prepare_2024_data.R
└── prepare_2025_data.R
```

Each script extracts the required variables and constructs a structured season dataset.

The next document, `03_data_preparation.md`, explains this process in detail, including the R 
functions, arguments, loops, list indexing, data types, and dataset combination operations.