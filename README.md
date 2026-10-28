# Formula 1 Finishing Position Prediction

A data science project developed in **R** to investigate whether historical Formula 1 race results can be used to predict drivers' finishing positions and determine which predictive model performs best.

The project covers the complete data science workflow, including data collection, preparation, exploratory analysis, feature engineering, predictive modelling, and statistical evaluation.

## Research Question

**How accurately can historical Formula 1 race data predict drivers' finishing positions, and which predictive model performs best?**

## Project Objectives

- Collect and process historical Formula 1 race results.
- Explore relationships between starting grid positions, historical driver performance, and finishing positions.
- Engineer predictive features using previous race results.
- Train and compare linear regression and decision tree models.
- Evaluate prediction accuracy using MAE and RMSE.
- Investigate model limitations through statistical diagnostics.
- Document the methodology and results for reproducibility.

## Dataset

The project uses historical race results from the **2021–2025 Formula 1 seasons**, obtained through the [Jolpica-F1 API](https://api.jolpi.ca/ergast/f1/).

The original dataset contains **2,278 driver-race observations**, reduced to **2,168 observations** after feature engineering and filtering.

The dataset includes:

| Variable | Description |
|---|---|
| `season` | Formula 1 championship season |
| `round` | Race round |
| `raceName` | Grand Prix name |
| `driver` | Driver's full name |
| `team` | Constructor |
| `position` | Final classified finishing position |
| `points` | Championship points earned |
| `grid` | Starting grid position |
| `laps` | Number of completed laps |
| `status` | Race result status |

### Data Split

The data is divided chronologically to preserve the distinction between historical training observations and later evaluation seasons.

| Dataset | Seasons | Observations |
|---|---|---:|
| Training | 2021–2023 | 1,255 |
| Validation | 2024 | 455 |
| Testing | 2025 | 458 |

The 2025 dataset is reserved for independent testing.

## Methodology

### 1. Data Collection and Preparation

Historical race results are retrieved from the Jolpica-F1 API and stored as JSON files.

The nested JSON responses are converted into structured R datasets, which are then combined into a single historical dataset.

### 2. Exploratory Data Analysis

Exploratory analysis investigates:

- Starting grid position versus finishing position.
- Correlations between grid and finishing positions across seasons.
- Distribution of finishing positions.
- Average driver and constructor performance.

The results are exported as CSV tables and visualisations.

### 3. Feature Engineering

Four historical performance features are created:

| Feature | Description |
|---|---|
| `prev_avg_position` | Average finishing position across all previous races in the current season |
| `prev_avg_points` | Average points earned across all previous races in the current season |
| `recent_avg_position` | Average finishing position across up to five previous races |
| `recent_avg_points` | Average points earned across up to five previous races |

These features are calculated separately for each driver and season.

The `lag()` function ensures that the current race result is excluded from the historical calculations, reducing the risk of target leakage.

### 4. Predictive Modelling

The project compares seven predictive models and a baseline.

| Model | Method |
|---|---|
| Original Linear Regression | Multiple Linear Regression |
| Decision Tree | Regression Tree |
| Improved Linear Regression | Multiple Linear Regression |
| Recent Position Linear Regression | Multiple Linear Regression |
| Recent Points Linear Regression | Multiple Linear Regression |
| Both Recent Features Linear Regression | Multiple Linear Regression |
| Log-Transformed Recent Points Linear Regression | Multiple Linear Regression |
| Baseline | Training Mean |

The models use different combinations of starting grid position and historical driver performance features.

### 5. Model Evaluation

Model performance is evaluated using:

**Mean Absolute Error (MAE)**

Measures the average absolute difference between predicted and actual finishing positions.

**Root Mean Squared Error (RMSE)**

Measures prediction error while penalising larger errors more strongly.

Additional analyses include:

- Prediction errors by driver, race, starting grid position, and race status.
- Residual analysis and Q-Q plots.
- Variance Inflation Factors (VIF).
- Breusch–Pagan tests.
- Cook's distance.
- Component-plus-residual plots.

## Results

The following results were obtained using the **2024 validation dataset**.

| Model | MAE | RMSE |
|---|---:|---:|
| Baseline | 5.0100 | 5.7740 |
| Decision Tree | 3.0720 | 4.0340 |
| Original Linear Regression | 2.9459 | 3.8513 |
| Improved Linear Regression | 2.9448 | 3.8503 |
| Recent Position Linear Regression | 2.9576 | 3.8513 |
| **Recent Points Linear Regression** | **2.9058** | **3.8338** |
| Both Recent Features Linear Regression | 2.9433 | 3.8536 |
| Log-Transformed Recent Points Linear Regression | 2.9181 | 3.8428 |

### Main Findings

The **Recent Points Linear Regression** model achieved the lowest validation MAE and RMSE.

The results suggest that recent championship-point performance can provide useful predictive information when combined with starting grid position and historical average finishing position.

All evaluated predictive models outperformed the baseline on the 2024 validation dataset.

However, these findings are based on validation performance. Independent evaluation using the 2025 test dataset remains to be completed.

## Technologies

| Technology | Purpose |
|---|---|
| R | Data analysis and predictive modelling |
| tidyverse | Data manipulation and visualisation |
| jsonlite | JSON processing |
| slider | Rolling feature calculations |
| ggplot2 | Data visualisation |
| rpart | Decision tree modelling |
| car | Regression diagnostics |
| lmtest | Statistical hypothesis testing |
| Git and GitHub | Version control |

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── r-check.yml
├── data/
│   ├── 2021_results_full.json
│   ├── ...
│   ├── 2025_results_full.json
│   ├── data_2021.RData
│   ├── ...
│   ├── data_2025.RData
│   ├── f1_data.RData
│   ├── model_data.RData
│   └── model_results.RData
├── scripts/
│   ├── prepare_data/
│   │   ├── prepare_2021_data.R
│   │   ├── ...
│   │   └── prepare_2025_data.R
│   ├── 01_api_test.R
│   ├── 02_get_historical_data.R
│   ├── combine_data.R
│   ├── 01_eda.R
│   ├── 02_features.R
│   ├── 03_models.R
│   └── 04_evaluation.R
├── plots/
├── results/
├── docs/
│   ├── 01_project_overview.md
│   ├── 02_data_collection.md
│   ├── 03_data_preparation.md
│   ├── 04_exploratory_analysis.md
│   ├── 05_feature_engineering.md
│   ├── 06_predictive_models.md
│   ├── 07_model_evaluation.md
│   ├── 08_r_function_reference.md
│   └── 09_project_workflow.md
└── README.md
```

## Installation and Usage

### Prerequisites

Install R and the required packages:

```r
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

### Running the Project

Clone the repository and open an R session.

Ensure the required historical datasets are available in the `data/` directory.

Set the working directory to `scripts/`, then run:

```r
source("01_eda.R")
source("02_features.R")
source("03_models.R")
source("04_evaluation.R")
```

These commands reproduce the analysis and modelling stages from the combined dataset.

To reproduce the entire pipeline starting from the raw JSON files, consult the project workflow documentation.

## Documentation

Detailed technical documentation is available in the [`docs/`](docs/) directory.

| Document | Description |
|---|---|
| [Project Overview](docs/01_project_overview.md) | Research question, objectives, and architecture |
| [Data Collection](docs/02_data_collection.md) | API requests, pagination, and JSON storage |
| [Data Preparation](docs/03_data_preparation.md) | JSON parsing and dataset construction |
| [Exploratory Analysis](docs/04_exploratory_analysis.md) | Statistical exploration and visualisations |
| [Feature Engineering](docs/05_feature_engineering.md) | Historical features and data splitting |
| [Predictive Models](docs/06_predictive_models.md) | Model specifications and training |
| [Model Evaluation](docs/07_model_evaluation.md) | Performance metrics and diagnostics |
| [R Function Reference](docs/08_r_function_reference.md) | R functions, arguments, and examples |
| [Project Workflow](docs/09_project_workflow.md) | Execution order and reproducibility |

## Limitations

The current implementation has several limitations:

- Predictions depend on a limited set of historical performance features.
- Race-specific factors such as weather, strategy, and mechanical failures are not explicitly modelled.
- Historical driver averages reset at the beginning of each season.
- The decision tree uses default training parameters.
- Regression predictions are numerical and are not restricted to valid integer finishing positions.
- The 2025 independent test comparison has not yet been completed.

## Future Work

Potential improvements include:

- Complete the independent 2025 test evaluation.
- Investigate additional pre-race predictors.
- Explore alternative regression and machine learning models.
- Evaluate different rolling-window lengths.
- Tune decision tree hyperparameters.
- Improve model interpretability and diagnostic analysis.
- Investigate performance across multiple chronological validation periods.

## Project Status

**Current stage:** Validation evaluation completed; independent test evaluation pending.

The project includes historical data processing, exploratory analysis, feature engineering, seven predictive models, validation comparisons, regression diagnostics, and technical documentation.

## Author

Developed as an individual Computer Science data science project, using R to investigate predictive modelling with historical Formula 1 race data.