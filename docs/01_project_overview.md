
# Formula 1 Finishing Position Prediction, Project Overview

## 1. Project Introduction

Formula 1 is a competitive motorsport in which race outcomes depend on several factors, including starting grid position, driver performance, team performance, race conditions, and unexpected incidents.

This project investigates whether historical Formula 1 race results can be used to predict a driver's finishing position in a future race.

The project is developed in **R** and follows a data science workflow involving data collection, preparation, exploratory data analysis, feature engineering, predictive modelling, and model evaluation.

The analysis focuses on information available before a race takes place. Historical performance indicators are calculated using previous race results to avoid using the outcome of the race being predicted.

## 2. Research Question

**How accurately can historical Formula 1 race data predict drivers' finishing positions, and which predictive model performs best?**

The project addresses this question by developing and comparing several predictive models using Formula 1 race data from 2021 to 2025.

## 3. Project Objectives

The main objectives are:

1. Collect historical Formula 1 race results from a publicly accessible API.
2. Transform the original JSON responses into structured datasets suitable for analysis.
3. Explore relationships between starting grid positions, driver performance, and finishing positions.
4. Engineer historical performance features using previous race results.
5. Train predictive models using historical observations.
6. Compare the models using consistent evaluation metrics.
7. Examine prediction errors, model assumptions, and influential observations.
8. Assess how effectively the selected models generalise to previously unseen race results.

## 4. Data Source

The project uses the **Jolpica-F1 API**, an API providing historical Formula 1 data through an Ergast-compatible interface.

API base URL:

`https://api.jolpi.ca/ergast/f1/`

Historical race results are retrieved using season-specific endpoints.

Example:

`https://api.jolpi.ca/ergast/f1/2021/results/?limit=100&offset=0`

The API returns JSON responses containing information about races, drivers, constructors, starting positions, finishing positions, points, completed laps, and race status.

The project covers five seasons:

- 2021
- 2022
- 2023
- 2024
- 2025

The data collection process uses pagination to retrieve results across multiple API responses.

## 5. Dataset Structure

Each observation represents a driver's participation in a particular Formula 1 race.

The prepared dataset contains variables such as:

| Variable | Description |
|---|---|
| `season` | Formula 1 championship season |
| `round` | Race round within the season |
| `raceName` | Name of the Grand Prix |
| `driver` | Driver's full name |
| `team` | Constructor or team name |
| `grid` | Driver's starting grid position |
| `position` | Driver's final classified position |
| `points` | Championship points awarded for the race |
| `laps` | Number of laps completed |
| `status` | Driver's race completion or retirement status |

The primary prediction target is `position`.

The other variables support exploratory analysis, feature engineering, or model evaluation.

Not every available variable is used as a model predictor.

## 6. Feature Engineering

To incorporate historical driver performance, the project creates additional features.

| Feature | Description |
|---|---|
| `prev_avg_position` | Average finishing position in previous races within the same season |
| `prev_avg_points` | Average points scored in previous races within the same season |
| `recent_avg_position` | Average finishing position over up to five previous races |
| `recent_avg_points` | Average points scored over up to five previous races |

These features are calculated separately for each driver and season.

The `lag()` function excludes the current race result from historical calculations.

This is important because a model intended to make pre-race predictions must not use the finishing position or points earned in the race being predicted.

Observations without the required historical averages are excluded during feature preparation.

## 7. Training, Validation, and Testing

The project uses a chronological data split.

| Dataset | Seasons | Purpose |
|---|---|---|
| Training | 2021–2023 | Train the predictive models |
| Validation | 2024 | Compare models and evaluate their performance |
| Testing | 2025 | Independent evaluation using a later season |

This approach preserves the chronological relationship between training and evaluation data.

The validation dataset is used to compare model performance and investigate prediction errors.

The 2025 dataset is reserved for independent testing. The final independent test evaluation is not yet included in the completed evaluation workflow.

## 8. Predictive Models

The project implements seven predictive models.

### 8.1 Original Linear Regression

Uses starting grid position, historical average finishing position, and historical average points.

### 8.2 Decision Tree

Uses the same three predictors as the original linear regression model, but applies a regression tree instead of a linear equation.

### 8.3 Improved Linear Regression

Extends the original linear regression model by adding recent average finishing position.

### 8.4 Recent Position Linear Regression

Uses starting grid position, historical average points, and recent average finishing position.

### 8.5 Recent Points Linear Regression

Uses starting grid position, historical average finishing position, and recent average points.

### 8.6 Both Recent Features Linear Regression

Uses starting grid position together with recent average finishing position and recent average points.

### 8.7 Log-Transformed Recent Points Linear Regression

Uses starting grid position, historical average finishing position, and a logarithmic transformation of recent average points.

All models are trained using the 2021 to 2023 training dataset.

## 9. Model Evaluation

Model performance is primarily assessed using two regression metrics.

### 9.1 Mean Absolute Error (MAE)

MAE measures the average absolute difference between actual and predicted finishing positions.

A lower MAE indicates more accurate predictions.

### 9.2 Root Mean Squared Error (RMSE)

RMSE measures prediction error while giving greater weight to larger deviations.

A lower RMSE indicates better predictive performance.

### 9.3 Baseline Comparison

A baseline model predicts the average finishing position observed in the training dataset.

This provides a reference against which the predictive models can be compared.

### 9.4 Additional Diagnostics

The evaluation workflow also includes:

- Prediction errors by driver, race, grid position, grid group, and race status.
- Actual versus predicted position plots.
- Prediction error distributions.
- Residuals versus fitted values.
- Q-Q plots.
- Feature correlation analysis.
- Variance Inflation Factor (VIF) analysis.
- Breusch–Pagan tests.
- Cook's distance and influential observation analysis.
- Component-plus-residual plots.

These analyses help explain model behaviour beyond overall prediction accuracy.

## 10. Project Workflow

The main workflow follows these stages:

1. Retrieve historical Formula 1 race data from the API.
2. Prepare individual season datasets.
3. Combine the seasons into one dataset.
4. Perform exploratory data analysis.
5. Engineer historical driver performance features.
6. Divide observations into training, validation, and testing datasets.
7. Train the predictive models.
8. Generate predictions.
9. Evaluate model performance and investigate prediction errors.
10. Export analysis results and visualisations.

## 11. Repository Structure

The repository is organised into the following main directories:

```text
.
├── .github/
│   └── workflows/
│       └── r-check.yml
├── data/
│   ├── 2021_results.json
│   ├── ...
│   ├── 2025_results_full.json
│   ├── data_2021.RData
│   ├── ...
│   ├── data_2025.RData
│   ├── f1_data.RData
│   ├── model_data.RData
│   └── model_results.RData
├── docs/
│   └── 01_project_overview.md
├── plots/
├── results/
├── scripts/
│   ├── prepare_data/
│   │   ├── prepare_2021_data.R
│   │   ├── prepare_2022_data.R
│   │   ├── prepare_2023_data.R
│   │   ├── prepare_2024_data.R
│   │   └── prepare_2025_data.R
│   ├── 01_api_test.R
│   ├── 02_get_historical_data.R
│   ├── combine_data.R
│   ├── 01_eda.R
│   ├── 02_features.R
│   ├── 03_models.R
│   └── 04_evaluation.R
└── README.md
```

### Directory Responsibilities

**`data/`**

Stores downloaded JSON responses, prepared season datasets, combined datasets, and saved model objects.

**`scripts/`**

Contains R scripts responsible for data collection, preparation, analysis, feature engineering, modelling, and evaluation.

**`plots/`**

Stores visualisations generated during exploratory analysis and model evaluation.

**`results/`**

Stores exported CSV files containing statistics, evaluation metrics, and diagnostic results.

**`docs/`**

Contains technical documentation explaining the project's methodology, implementation, functions, and workflow.

**`.github/workflows/`**

Contains the GitHub Actions workflow used to check R script syntax.

## 12. Technologies and Libraries

| Technology | Purpose |
|---|---|
| R | Main programming language |
| `jsonlite` | Reading and writing JSON data |
| `tidyverse` | Data manipulation, transformation, and visualisation |
| `slider` | Rolling calculations for recent performance features |
| `stats` | Linear regression and statistical calculations |
| `rpart` | Decision tree modelling |
| `car` | Variance Inflation Factors and regression diagnostics |
| `lmtest` | Breusch-Pagan heteroscedasticity testing |
| Git | Version control |
| GitHub | Repository hosting and collaboration |
| GitHub Actions | Automated syntax checking |

## 13. Scope and Limitations

The project focuses on predicting numerical finishing positions rather than reproducing the complete competitive dynamics of a Formula 1 race.

The models do not explicitly incorporate all possible influences on race results, such as weather conditions, race strategy, safety cars, mechanical reliability, or unexpected incidents.

Historical averages are calculated within each driver-season combination. Consequently, the earliest observations for each driver and season do not have all the historical information required for modelling.

The models predict finishing positions as numerical values. Regression predictions are not inherently restricted to whole numbers or valid finishing positions.

Finally, results obtained from the 2024 validation dataset should not be interpreted as independent 2025 test performance.

## 14. Documentation Guide

The remaining technical documents explain each stage in greater detail:

- `02_data_collection.md`: API requests, JSON structure, and pagination.
- `03_data_preparation.md`: Data extraction, transformation, and combination.
- `04_exploratory_analysis.md`: Exploratory statistics and visualisations.
- `05_feature_engineering.md`: Historical and rolling performance features.
- `06_predictive_models.md`: Model specifications, training, and predictions.
- `07_model_evaluation.md`: Performance metrics and diagnostics.
- `08_r_function_reference.md`: Detailed R function and argument reference.
- `09_project_workflow.md`: Script execution order and project dependencies.
