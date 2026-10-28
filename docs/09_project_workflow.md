
# Project Workflow, Formula 1 Finishing Position Prediction

## 1. Introduction

This document explains the complete workflow of the Formula 1 finishing-position prediction project.

It describes how historical race results are collected, processed, analysed, transformed into predictive features, used to train models, and evaluated.

The purpose is to provide a reproducibility guide for understanding the relationships between the project's scripts, datasets, and generated outputs.

The main research question is:

**How accurately can historical Formula 1 race data predict drivers' finishing positions, and which predictive model performs best?**

The project uses historical Formula 1 race results from 2021 to 2025, obtained from the Jolpica-F1 API, an Ergast-compatible data source.

## 2. Project Architecture

The workflow consists of six main stages:

1. Data collection.
2. Data preparation.
3. Exploratory Data Analysis.
4. Feature engineering.
5. Predictive modelling.
6. Model evaluation.

The stages form a pipeline in which the output of one stage becomes the input of a later stage.

```text
Jolpica-F1 API
       |
       v
Historical JSON files
       |
       v
Season preparation scripts
       |
       v
Individual season datasets
       |
       v
Combined historical dataset
       |
       +----------------------+
       |                      |
       v                      v
Exploratory Analysis     Feature Engineering
       |                      |
       v                      v
EDA plots and CSVs       Modelling datasets
                              |
                              v
                       Predictive Models
                              |
                              v
                       Model predictions
                              |
                              v
                       Model Evaluation
                              |
                              v
                       Results and plots
```

## 3. Repository Structure

The relevant project structure is:

```text
f1-data-science-r/
│
├── .github/
│   └── workflows/
│       └── r-check.yml
│
├── README.md
│
├── data/
│   ├── 2021_results.json
│   ├── 2022_results.json
│   ├── 2023_results.json
│   ├── 2024_results.json
│   ├── 2025_results.json
│   │
│   ├── 2021_results_full.json
│   ├── 2022_results_full.json
│   ├── 2023_results_full.json
│   ├── 2024_results_full.json
│   ├── 2025_results_full.json
│   │
│   ├── data_2021.RData
│   ├── data_2022.RData
│   ├── data_2023.RData
│   ├── data_2024.RData
│   ├── data_2025.RData
│   │
│   ├── f1_data.RData
│   ├── model_data.RData
│   └── model_results.RData
│
├── scripts/
│   ├── 01_api_test.R
│   ├── 02_get_historical_data.R
│   ├── combine_data.R
│   ├── 01_eda.R
│   ├── 02_features.R
│   ├── 03_models.R
│   ├── 04_evaluation.R
│   │
│   └── prepare_data/
│       ├── prepare_2021_data.R
│       ├── prepare_2022_data.R
│       ├── prepare_2023_data.R
│       ├── prepare_2024_data.R
│       └── prepare_2025_data.R
│
├── plots/
│
├── results/
│
└── docs/
    ├── 01_project_overview.md
    ├── 02_data_collection.md
    ├── 03_data_preparation.md
    ├── 04_exploratory_analysis.md
    ├── 05_feature_engineering.md
    ├── 06_predictive_models.md
    ├── 07_model_evaluation.md
    ├── 08_r_function_reference.md
    └── 09_project_workflow.md
```

The `data/` directory contains raw and processed datasets.

The `scripts/` directory contains the R implementation.

The `plots/` directory contains generated visualisations.

The `results/` directory contains exported statistical and evaluation results.

The `docs/` directory contains the technical documentation.

## 4. Required Software

The project is developed using the R programming language.

The following software is required:

| Software | Purpose |
|---|---|
| R | Execute the analysis and modelling scripts |
| RStudio or VS Code | Develop and run R code |
| Git | Version control |
| GitHub | Repository hosting and collaboration |

The scripts use several R packages.

## 5. Required R Packages

The main packages are:

| Package | Purpose |
|---|---|
| `tidyverse` | Data manipulation, visualisation, and CSV export |
| `jsonlite` | JSON parsing and serialisation |
| `slider` | Rolling historical averages |
| `rpart` | Decision tree modelling |
| `car` | Regression diagnostics and VIF |
| `lmtest` | Breusch–Pagan testing |
| `scales` | Numerical formatting |

### 5.1 Installing Packages

If the packages are not already installed, they can be installed using:

```r id="9w0jrl"
install.packages(c(
    "tidyverse",
    "jsonlite",
    "slider",
    "rpart",
    "car",
    "lmtest",
    "scales"
))
```

The installation step is normally required only once per R library environment.

### 5.2 Loading Packages

Individual scripts load the packages they require.

For example:

```r id="xphq99"
library(tidyverse)
library(slider)
```

Installing a package and loading a package are different operations.

`install.packages()` downloads and installs the package.

`library()` makes an installed package available in the current R session.

## 6. Working Directory Requirements

The project uses relative file paths.

For example:

```r id="1duj4u"
load("../data/f1_data.RData")
```

The `..` component refers to the parent directory of the current working directory.

Most analysis scripts expect the working directory to be:

```text
f1-data-science-r/scripts/
```

### 6.1 Checking the Working Directory

Use:

```r id="v01dcs"
getwd()
```

This displays the current working directory.

### 6.2 Changing the Working Directory

Use:

```r id="51wz8e"
setwd("path/to/f1-data-science-r/scripts")
```

Replace the example path with the actual location of the repository.

### 6.3 Important Consideration

R resolves relative paths from its current working directory.

It does not automatically resolve them from the location of the script being executed.

Therefore, a script can produce a file-not-found error when run from the wrong directory.

## 7. Stage 1 — Data Collection

### 7.1 Objective

Retrieve historical Formula 1 race results from the Jolpica-F1 API.

### 7.2 Relevant Scripts

```text
scripts/01_api_test.R
scripts/02_get_historical_data.R
```

The first script was used to test the API and inspect its response structure.

The second script belongs to the historical data collection stage.

### 7.3 API Structure

The API follows an Ergast-compatible structure.

An example endpoint is:

```text
https://api.jolpi.ca/ergast/f1/2025/results/
```

The project retrieves race result data for the seasons 2021 through 2025.

### 7.4 Pagination

API responses may contain only a subset of the available results.

The project therefore handles pagination to retrieve additional records.

Relevant query parameters include:

| Parameter | Purpose |
|---|---|
| `limit` | Maximum number of records returned per request |
| `offset` | Number of records skipped before the returned page |

For example:

```text
?limit=100&offset=0
?limit=100&offset=100
?limit=100&offset=200
```

These requests retrieve different pages of results.

The exact number of pages depends on the season and the total number of available records.

### 7.5 Main Functions

| Function | Purpose |
|---|---|
| `fromJSON()` | Retrieve and parse JSON |
| `unlist()` | Combine collections while preserving the intended structure |
| `write_json()` | Save JSON locally |

### 7.6 Outputs

The project contains full historical JSON files:

```text
data/2021_results_full.json
data/2022_results_full.json
data/2023_results_full.json
data/2024_results_full.json
data/2025_results_full.json
```

These are the inputs used by the season preparation scripts.

### 7.7 Reproducibility Note

The repository also contains JSON files without the `_full` suffix.

The preparation scripts use the `_full.json` files.

The API collection scripts should be inspected before rerunning them to confirm their output paths and pagination settings.

This avoids accidentally replacing complete datasets with partial API responses.

## 8. Stage 2 — Data Preparation

### 8.1 Objective

Convert nested JSON responses into structured race-result datasets.

### 8.2 Relevant Scripts

```text
scripts/prepare_data/prepare_2021_data.R
scripts/prepare_data/prepare_2022_data.R
scripts/prepare_data/prepare_2023_data.R
scripts/prepare_data/prepare_2024_data.R
scripts/prepare_data/prepare_2025_data.R
```

Each script processes one season.

### 8.3 JSON Structure

The relevant JSON hierarchy is:

```text
MRData
└── RaceTable
    └── Races
        └── Results
            ├── Driver
            ├── Constructor
            ├── position
            ├── points
            ├── grid
            ├── laps
            └── status
```

The scripts iterate through races and their driver results.

### 8.4 Extracted Variables

| Variable | Description |
|---|---|
| `season` | Championship season |
| `round` | Race round |
| `raceName` | Grand Prix name |
| `driver` | Driver's full name |
| `team` | Constructor name |
| `position` | Finishing position |
| `points` | Championship points earned |
| `grid` | Starting grid position |
| `laps` | Completed laps |
| `status` | Race result status |

### 8.5 Main Functions

| Function | Purpose |
|---|---|
| `fromJSON()` | Load the nested JSON |
| `seq_along()` | Iterate through race collections |
| `paste()` | Combine driver first and last names |
| `tibble()` | Construct structured rows |
| `bind_rows()` | Combine driver results |
| `save()` | Store season datasets |

### 8.6 Outputs

```text
data/data_2021.RData
data/data_2022.RData
data/data_2023.RData
data/data_2024.RData
data/data_2025.RData
```

Each file contains the prepared dataset for one season.

## 9. Combining Historical Seasons

### 9.1 Relevant Script

```text
scripts/combine_data.R
```

### 9.2 Objective

Combine the five prepared season datasets into one historical dataset.

The script loads each season and combines the observations.

```r id="vbnvpm"
f1_data <- bind_rows(
    data_2021,
    data_2022,
    data_2023,
    data_2024,
    data_2025
)
```

### 9.3 Output

```text
data/f1_data.RData
```

This file contains the combined historical dataset used by the EDA and feature engineering scripts.

### 9.4 Dataset Size

The combined dataset contains:

**2,278 driver-race observations.**

These observations cover the 2021–2025 seasons before the historical-feature filtering stage.

## 10. Stage 3 — Exploratory Data Analysis

### 10.1 Relevant Script

```text
scripts/01_eda.R
```

### 10.2 Input

```text
data/f1_data.RData
```

### 10.3 Objective

Explore relationships and patterns in the historical race results.

The script:

- Converts selected variables into numeric types.
- Calculates grid-versus-finishing-position correlations by season.
- Examines finishing-position distributions.
- Visualises starting grid against finishing position.
- Compares grid-position relationships across seasons.
- Summarises driver performance.
- Summarises team performance.

### 10.4 Main Functions

| Function | Purpose |
|---|---|
| `as.integer()` | Convert numerical columns |
| `group_by()` | Group observations |
| `summarise()` | Calculate summaries |
| `cor()` | Calculate correlation |
| `mean()` | Calculate averages |
| `arrange()` | Sort summaries |
| `ggplot()` | Create plots |
| `ggsave()` | Export plots |
| `write_csv()` | Export tables |

### 10.5 Outputs

Statistical results include:

```text
results/correlations_by_season.csv
results/pilots_performance.csv
results/teams_performance.csv
```

Visualisations include:

```text
plots/position_distribution.png
plots/grid_vs_position.png
plots/grid_vs_position_season.png
```

### 10.6 Workflow Dependency

EDA depends on the combined historical dataset.

However, it does not need to be executed before feature engineering for the later modelling scripts to run.

EDA and feature engineering are separate branches of the workflow that use the same combined input dataset.

## 11. Stage 4 — Feature Engineering

### 11.1 Relevant Script

```text
scripts/02_features.R
```

### 11.2 Input

```text
data/f1_data.RData
```

### 11.3 Objective

Create historical driver-performance indicators using previous race results.

The script groups observations by driver and season, orders them chronologically, and creates four features.

### 11.4 Engineered Features

| Feature | Calculation |
|---|---|
| `prev_avg_position` | `lag(cummean(position))` |
| `prev_avg_points` | `lag(cummean(points))` |
| `recent_avg_position` | `slide_dbl(lag(position), mean, .before = 4, na.rm = TRUE)` |
| `recent_avg_points` | `slide_dbl(lag(points), mean, .before = 4, na.rm = TRUE)` |

### 11.5 Preventing Data Leakage

The `lag()` function excludes the current race's result from historical features.

This ensures that the features use previous observations rather than information from the race being predicted.

### 11.6 Removing Incomplete Observations

The script removes observations where the required previous average features are missing.

After filtering, the dataset contains:

**2,168 observations.**

### 11.7 Chronological Dataset Split

The dataset is divided into:

| Dataset | Seasons | Observations |
|---|---|---:|
| Training | 2021–2023 | 1,255 |
| Validation | 2024 | 455 |
| Testing | 2025 | 458 |
| **Total** | **2021–2025** | **2,168** |

### 11.8 Outputs

```text
data/model_data.RData
```

The file contains:

- `f1_data`
- `train_data`
- `validation_data`
- `test_data`

The script also generates:

```text
plots/prev_avg_position_vs_position.png
plots/prev_avg_points_vs_position.png
```

## 12. Stage 5 — Predictive Modelling

### 12.1 Relevant Script

```text
scripts/03_models.R
```

### 12.2 Input

```text
data/model_data.RData
```

### 12.3 Objective

Train and compare predictive models using starting grid position and historical driver performance.

### 12.4 Models

The project trains seven models:

| Model | Method |
|---|---|
| Original Linear Regression | `lm()` |
| Decision Tree | `rpart()` |
| Improved Linear Regression | `lm()` |
| Recent Position Linear Regression | `lm()` |
| Recent Points Linear Regression | `lm()` |
| Both Recent Features Linear Regression | `lm()` |
| Log-Transformed Recent Points Linear Regression | `lm()` |

A baseline is also calculated using the mean training finishing position.

### 12.5 Model Training

All fitted models use:

```r id="r9mjf5"
data = train_data
```

This ensures that model coefficients and tree structure are estimated using the historical training seasons.

### 12.6 Validation Predictions

The script generates validation predictions for all seven models and the baseline.

These predictions are stored as additional columns in `validation_data`.

### 12.7 Test Predictions

The script currently generates 2025 test predictions for:

- Original Linear Regression.
- Decision Tree.
- Baseline.
- Improved Linear Regression.
- Recent Position Linear Regression.

The Recent Points, Both Recent Features, and Log-Transformed Recent Points models do not yet have prediction columns in `test_data`.

### 12.8 Output

```text
data/model_results.RData
```

The file contains the fitted model objects and the datasets with generated predictions.

## 13. Stage 6 — Model Evaluation

### 13.1 Relevant Script

```text
scripts/04_evaluation.R
```

### 13.2 Input

```text
data/model_results.RData
```

### 13.3 Objective

Evaluate model performance using the 2024 validation dataset.

### 13.4 Performance Metrics

The project calculates:

**Mean Absolute Error:**

\[
MAE = \frac{1}{n}\sum_{i=1}^{n}|y_i-\hat{y}_i|
\]

**Root Mean Squared Error:**

\[
RMSE =
\sqrt{\frac{1}{n}\sum_{i=1}^{n}(y_i-\hat{y}_i)^2}
\]

Lower values indicate better prediction accuracy.

### 13.5 Validation Results

| Model | MAE | RMSE |
|---|---:|---:|
| Baseline | 5.0100 | 5.7740 |
| Decision Tree | 3.0720 | 4.0340 |
| Original Linear Regression | 2.9459 | 3.8513 |
| Improved Linear Regression | 2.9448 | 3.8503 |
| Recent Position Linear Regression | 2.9576 | 3.8513 |
| Recent Points Linear Regression | **2.9058** | **3.8338** |
| Both Recent Features Linear Regression | 2.9433 | 3.8536 |
| Log-Transformed Recent Points Linear Regression | 2.9181 | 3.8428 |

The Recent Points Linear Regression model achieved the lowest validation MAE and RMSE.

### 13.6 Additional Error Analysis

The script examines prediction errors according to:

- Driver.
- Race.
- Starting grid position.
- Starting grid group.
- Race status.

### 13.7 Regression Diagnostics

The evaluation includes:

| Diagnostic | Function | Purpose |
|---|---|---|
| Variance Inflation Factor | `car::vif()` | Investigate multicollinearity |
| Breusch–Pagan test | `lmtest::bptest()` | Investigate heteroscedasticity |
| Cook's distance | `cooks.distance()` | Identify influential observations |
| Component-plus-residual plots | `car::crPlots()` | Investigate functional relationships |
| Residual plots | `ggplot2` | Examine error patterns |
| Q-Q plots | `ggplot2` | Examine error distribution |

### 13.8 Outputs

The evaluation stage exports CSV tables and plots to:

```text
results/
plots/
```

Examples include:

```text
results/models_performance.csv
results/models_comparison_validation.csv
results/model_vif.csv
```

The exact collection of generated files depends on the active export statements in the evaluation script.

## 14. Script Dependency Table

| Script | Required input | Main output |
|---|---|---|
| `01_api_test.R` | API endpoint | API test data |
| `02_get_historical_data.R` | API endpoint | Historical JSON data |
| `prepare_YYYY_data.R` | `YYYY_results_full.json` | `data_YYYY.RData` |
| `combine_data.R` | Five season `.RData` files | `f1_data.RData` |
| `01_eda.R` | `f1_data.RData` | EDA plots and CSVs |
| `02_features.R` | `f1_data.RData` | `model_data.RData` |
| `03_models.R` | `model_data.RData` | `model_results.RData` |
| `04_evaluation.R` | `model_results.RData` | Evaluation plots and CSVs |

The `YYYY` placeholder represents a season from 2021 through 2025.

## 15. Recommended Execution Order

The project should be executed in dependency order.

### Step 1 — Confirm the Raw JSON Files

Check that the following files exist:

```text
data/2021_results_full.json
data/2022_results_full.json
data/2023_results_full.json
data/2024_results_full.json
data/2025_results_full.json
```

If these files are already present and complete, the API collection stage does not need to be repeated.

### Step 2 — Prepare Each Season

Run the five season preparation scripts.

These convert the nested JSON records into structured R datasets.

### Step 3 — Combine Seasons

Run:

```text
scripts/combine_data.R
```

This creates:

```text
data/f1_data.RData
```

### Step 4 — Run Exploratory Analysis

Run:

```text
scripts/01_eda.R
```

This generates exploratory tables and plots.

This step can also be executed independently of feature engineering once the combined dataset exists.

### Step 5 — Create Historical Features

Run:

```text
scripts/02_features.R
```

This creates the historical predictors and chronological dataset split.

### Step 6 — Train Models

Run:

```text
scripts/03_models.R
```

This trains the predictive models and generates validation and available test predictions.

### Step 7 — Evaluate Models

Run:

```text
scripts/04_evaluation.R
```

This calculates evaluation metrics, produces diagnostics, and exports results.

## 16. Running the Analysis Scripts

From an R session with the working directory set to:

```text
f1-data-science-r/scripts/
```

the analysis stages can be executed in sequence:

```r id="rgd8wa"
source("01_eda.R")
source("02_features.R")
source("03_models.R")
source("04_evaluation.R")
```

### 16.1 The `source()` Function

Executes R code from a file.

**Relevant syntax:**

```r id="8wdk84"
source(
    file,
    local = FALSE,
    echo = verbose,
    ...
)
```

| Argument | Description |
|---|---|
| `file` | R script to execute |
| `local` | Environment in which expressions are evaluated |
| `echo` | Whether to print expressions as they execute |
| `...` | Additional options |

### 16.2 Important Consideration

The scripts use file paths relative to the current working directory.

The season preparation scripts are located in a subdirectory and may require a different working directory.

Therefore, they should be executed from the directory expected by their relative paths.

The commands above cover the analysis, feature engineering, modelling, and evaluation stages after the combined dataset has been created.

## 17. Reproducing the Pipeline Without Recollecting Data

When the complete JSON files are already available, the project can be reproduced without requesting the API again.

The workflow is:

```text
Existing JSON files
        |
        v
Prepare each season
        |
        v
Combine season datasets
        |
        v
Run EDA
        |
        v
Engineer historical features
        |
        v
Train models
        |
        v
Evaluate validation predictions
```

This approach reduces dependency on external API availability.

It also allows the same stored historical records to be reused.

## 18. Reproducing Only the Modelling Stage

If:

```text
data/model_data.RData
```

already exists, the modelling stage can be rerun without repeating data collection, preparation, or feature engineering.

Run:

```r id="50ypie"
source("03_models.R")
source("04_evaluation.R")
```

The first script regenerates the model objects and predictions.

The second script evaluates them.

## 19. Reproducing Only the Evaluation Stage

If:

```text
data/model_results.RData
```

already exists, evaluation can be rerun directly.

```r id="57akx5"
source("04_evaluation.R")
```

This is useful when modifying evaluation visualisations or statistical summaries without retraining the models.

## 20. Data Dependencies and Reproducibility

The project stores intermediate datasets using `.RData` files.

This allows later stages to reuse results from earlier stages.

However, these files also create dependencies.

For example:

- `03_models.R` requires `model_data.RData`.
- `04_evaluation.R` requires `model_results.RData`.
- `02_features.R` requires `f1_data.RData`.

If an input file is missing, the corresponding script cannot complete successfully.

If an earlier stage changes, its dependent outputs may need to be regenerated.

## 21. Common Execution Problems

### 21.1 File Not Found

Example:

```text
cannot open compressed file
```

Possible causes:

- Incorrect working directory.
- Missing input file.
- Incorrect relative path.
- File not yet generated by an earlier stage.

Check:

```r id="hbtvkr"
getwd()
```

and verify the required file exists.

### 21.2 Object Not Found

Example:

```text
object 'train_data' not found
```

Possible causes:

- The required `.RData` file was not loaded.
- The expected object was not saved.
- An earlier script failed.

Check the saved object names and execute the required earlier stage.

### 21.3 Package Not Installed

Example:

```text
there is no package called 'slider'
```

Install the missing package:

```r id="5ulqv8"
install.packages("slider")
```

Then rerun the script.

### 21.4 Missing Prediction Column

An evaluation expression may fail if the expected prediction column does not exist.

For example, a model's prediction may not have been added to the relevant dataset.

Verify that the modelling script generated the required column.

### 21.5 Unexpected Missing Values

Historical features depend on previous race observations.

The first observation for each driver-season group does not have previous performance data.

These missing values are expected and are handled during feature engineering.

## 22. Version Control Workflow

The project uses Git and GitHub.

### 22.1 Checking Changes

```bash id="z73y4p"
git status
```

Displays modified, staged, and untracked files.

### 22.2 Staging Changes

```bash id="5zdbab"
git add docs/09_project_workflow.md
```

Stages the workflow documentation.

### 22.3 Creating a Commit

```bash id="xd0vxy"
git commit -m "docs: document complete project workflow"
```

Records the staged changes.

### 22.4 Pushing Changes

```bash id="q0sbmc"
git push origin main
```

Uploads local commits to the remote `main` branch.

The appropriate branch should always be confirmed before pushing.

## 23. Documentation Structure

The project documentation is organised into nine files.

| Document | Main topic |
|---|---|
| `01_project_overview.md` | Research question, objectives, and project structure |
| `02_data_collection.md` | API access, pagination, and JSON storage |
| `03_data_preparation.md` | JSON parsing and structured datasets |
| `04_exploratory_analysis.md` | Correlations, summaries, and visualisations |
| `05_feature_engineering.md` | Historical features and chronological splitting |
| `06_predictive_models.md` | Model specifications, training, and prediction |
| `07_model_evaluation.md` | Error metrics and statistical diagnostics |
| `08_r_function_reference.md` | R functions, arguments, and examples |
| `09_project_workflow.md` | Execution order, dependencies, and reproducibility |

The documents can be read sequentially to understand the project from beginning to end.

The function reference can also be consulted independently while studying or modifying the R scripts.

## 24. Current Project Status

The following stages have been implemented:

| Stage | Status |
|---|---|
| Historical data collection | Completed |
| Data preparation | Completed |
| Exploratory Data Analysis | Completed |
| Historical feature engineering | Completed |
| Chronological dataset split | Completed |
| Predictive model training | Completed |
| 2024 validation evaluation | Completed |
| Regression diagnostics | Implemented |
| 2025 independent test comparison | Not yet completed |
| Technical documentation | Completed |

### 24.1 Current Best Validation Model

The Recent Points Linear Regression model achieved the best validation performance:

- MAE: 2.9058.
- RMSE: 3.8338.

This result is based on the 2024 validation dataset.

### 24.2 Remaining Evaluation Work

Before drawing a final conclusion about generalisation, the project should complete the independent 2025 test comparison.

This requires generating the necessary test predictions and evaluating the selected model or models without using the test results for further model selection.

## 25. Final Workflow Summary

The project follows a structured data science workflow:

1. Collect historical race results from the Jolpica-F1 API.
2. Store the original records in JSON format.
3. Extract structured driver-race observations.
4. Combine five seasons into a single dataset.
5. Explore the data through statistical summaries and visualisations.
6. Engineer historical features using previous race results.
7. Split observations chronologically into training, validation, and test datasets.
8. Train linear regression and decision tree models.
9. Generate predictions for later seasons.
10. Evaluate validation performance using MAE and RMSE.
11. Investigate prediction errors and regression diagnostics.
12. Preserve datasets, model objects, results, and documentation for reproducibility.

The completed workflow demonstrates how historical Formula 1 data can be transformed into a predictive modelling system.

The remaining independent test evaluation is necessary before making final claims about performance on unseen seasons.