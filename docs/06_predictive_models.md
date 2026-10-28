
# Predictive Modelsl, Formula 1 Finishing Position Prediction

## 1. Introduction

This document describes the predictive models developed to estimate Formula 1 drivers' finishing positions using historical race results.

The modelling stage is implemented in:

`scripts/03_models.R`

The main research question is:

**How accurately can historical Formula 1 race data predict drivers' finishing positions, and which predictive model performs best?**

The project compares seven predictive models:

1. Original Linear Regression
2. Decision Tree
3. Improved Linear Regression
4. Recent Position Linear Regression
5. Recent Points Linear Regression
6. Both Recent Features Linear Regression
7. Log-Transformed Recent Points Linear Regression

A simple baseline prediction is also calculated to provide a reference for model performance.

All models use information intended to be available before the race result is known.

## 2. Required Libraries and Data

The modelling script begins with:

```r
library(tidyverse)
library(rpart)

load("../data/model_data.RData")
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

The project uses:

- `tidyverse` for data manipulation, particularly `mutate()`.
- `rpart` for regression tree modelling.

The `lm()` and `predict()` functions are available through R's standard statistical functionality.

### 2.2 `load()`

Restores objects saved in an `.RData` file.

**Syntax:**

```r
load(file)
```

| Argument | Description |
|---|---|
| `file` | Path to the saved R data file |

The loaded file contains:

- `f1_data`
- `train_data`
- `validation_data`
- `test_data`

These objects were created during feature engineering.

## 3. Prediction Target

The target variable is:

```r
position
```

It represents the driver's final classified finishing position.

For example:

| Actual position | Meaning |
|---|---|
| 1 | First place |
| 2 | Second place |
| 3 | Third place |
| 10 | Tenth place |
| 20 | Twentieth place |

The objective is to predict this numerical value as accurately as possible.

Although finishing positions represent rankings, the models treat the target as a numerical regression variable.

Consequently, predictions may contain decimal values.

For example, a predicted position of `4.7` is possible.

This represents the model's numerical estimate, not an actual finishing position that can occur in a race.

## 4. Available Predictors

The project uses five candidate predictors.

| Predictor | Description |
|---|---|
| `grid` | Starting grid position |
| `prev_avg_position` | Average finishing position across previous races in the season |
| `prev_avg_points` | Average championship points across previous races in the season |
| `recent_avg_position` | Average finishing position across up to five previous races |
| `recent_avg_points` | Average championship points across up to five previous races |

The historical features are calculated separately for each driver and season.

They use previous race results rather than the current race's finishing position or points.

### 4.1 Why Use Starting Grid Position?

Starting grid position provides information about a driver's position at the beginning of the race.

It is a relevant predictor because starting position and finishing position may be associated.

### 4.2 Why Use Historical Averages?

Historical averages provide information about a driver's previous performance.

They may capture patterns that are not fully represented by starting grid position alone.

### 4.3 Why Use Recent Averages?

Recent averages focus on a smaller number of previous races.

They may respond more quickly to changes in driver performance than season-long averages.

## 5. Training, Validation, and Testing

The project uses a chronological data split.

| Dataset | Seasons | Purpose |
|---|---|---|
| `train_data` | 2021–2023 | Model training |
| `validation_data` | 2024 | Model comparison and evaluation |
| `test_data` | 2025 | Independent testing |

### 5.1 Training

Training is the process of estimating model parameters from historical observations.

All seven predictive models are fitted using `train_data`.

### 5.2 Validation

Validation measures how well trained models predict observations from a later season.

The project uses the 2024 dataset to compare models and investigate prediction errors.

### 5.3 Testing

The 2025 dataset is reserved for independent evaluation.

The current modelling script generates 2025 predictions for five of the seven models.

The remaining two models are trained and evaluated on validation data, but their predictions are not currently added to `test_data`.

The completed evaluation workflow does not yet include a final independent comparison of the models using 2025 test results.

## 6. Linear Regression

Linear regression estimates a numerical target using a linear combination of predictors.

The general multiple linear regression equation is:

\[
\hat{y} = \beta_0 + \beta_1x_1 + \beta_2x_2 + \cdots + \beta_px_p
\]

Where:

| Symbol | Meaning |
|---|---|
| \(\hat{y}\) | Predicted finishing position |
| \(\beta_0\) | Intercept |
| \(\beta_i\) | Estimated regression coefficient |
| \(x_i\) | Predictor value |
| \(p\) | Number of predictors |

The coefficients are estimated using the training data.

The project's linear regression models use ordinary least squares.

This method estimates coefficients by minimising the sum of squared training residuals.

## 7. The `lm()` Function

The project trains linear regression models using:

```r
lm()
```

### 7.1 Purpose

The `lm()` function fits linear models.

### 7.2 Relevant Syntax

```r
lm(
    formula,
    data,
    subset,
    weights,
    na.action,
    method = "qr",
    model = TRUE,
    ...
)
```

| Argument | Description |
|---|---|
| `formula` | Specifies the response variable and predictors |
| `data` | Dataset containing the variables |
| `subset` | Optional expression selecting observations |
| `weights` | Optional observation weights |
| `na.action` | Controls the treatment of missing values |
| `method` | Method used to fit the model |
| `model` | Whether to retain the model frame |
| `...` | Additional arguments |

The project explicitly supplies `formula` and `data`.

The other arguments use their defaults.

### 7.3 Formula Syntax

A model formula uses:

```r
response ~ predictor_1 + predictor_2
```

The `~` operator separates the response variable from the predictors.

The `+` operator adds predictor terms.

For example:

```r
position ~ grid + prev_avg_position
```

means that `position` is predicted using `grid` and `prev_avg_position`.

By default, `lm()` includes an intercept.

The `+` operator in a formula does not directly mean that the raw predictor values are added together without coefficients.

Instead, R estimates a coefficient for each predictor.

## 8. Original Linear Regression Model

The original linear regression model is:

```r
model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)
```

### 8.1 Predictors

- `grid`
- `prev_avg_position`
- `prev_avg_points`

### 8.2 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{prev\_avg\_position})
+ \beta_3(\text{prev\_avg\_points})
\]

### 8.3 Purpose

This model combines starting position with two historical performance indicators.

It serves as the original regression model against which alternative linear regression specifications are compared.

### 8.4 Model Object

The fitted model is stored in:

```r
model
```

This object contains information such as estimated coefficients, residuals, fitted values, and model specifications.

## 9. Decision Tree Model

The project also trains a decision tree.

```r
tree_model <- rpart(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)
```

### 9.1 What Is a Decision Tree?

A decision tree divides observations into smaller groups using conditions based on predictor values.

For regression, the tree predicts a numerical value for each terminal group.

For example, a tree may divide observations according to starting grid position and then apply additional splits based on historical performance.

This is an illustrative explanation, not a description of the exact splits learned by the project's fitted tree.

### 9.2 The `rpart()` Function

The `rpart()` function fits recursive partitioning models.

**Relevant syntax:**

```r
rpart(
    formula,
    data,
    weights,
    subset,
    na.action = na.rpart,
    method,
    model = FALSE,
    x = FALSE,
    y = TRUE,
    control = rpart.control(),
    ...
)
```

| Argument | Description |
|---|---|
| `formula` | Response and predictor variables |
| `data` | Training dataset |
| `weights` | Optional observation weights |
| `subset` | Optional observation selection |
| `na.action` | Missing-value handling |
| `method` | Tree type, such as regression or classification |
| `model` | Whether to retain the model frame |
| `x` | Whether to retain the predictor matrix |
| `y` | Whether to retain the response |
| `control` | Tree-building control parameters |
| `...` | Additional arguments |

### 9.3 Regression Tree Selection

Because `position` is numeric, `rpart()` uses regression tree behaviour when the method is inferred from the response.

The project does not explicitly specify:

```r
method = "anova"
```

However, this is the relevant regression method for the numerical target.

### 9.4 Tree Control Parameters

The project uses the default `rpart.control()` settings.

It does not explicitly tune parameters such as:

- `cp` — complexity parameter.
- `minsplit` — minimum observations required before attempting a split.
- `minbucket` — minimum observations in a terminal node.
- `maxdepth` — maximum tree depth.

Therefore, the decision tree results reflect the default training configuration rather than a separately optimised hyperparameter search.

### 9.5 Model Object

The fitted tree is stored in:

```r
tree_model
```

## 10. Improved Linear Regression Model

The improved model adds recent average finishing position to the original regression specification.

```r
improved_model <- lm(
    position ~
        grid +
        prev_avg_position +
        prev_avg_points +
        recent_avg_position,
    data = train_data
)
```

### 10.1 Predictors

- `grid`
- `prev_avg_position`
- `prev_avg_points`
- `recent_avg_position`

### 10.2 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{prev\_avg\_position})
+ \beta_3(\text{prev\_avg\_points})
+ \beta_4(\text{recent\_avg\_position})
\]

### 10.3 Purpose

The model investigates whether recent finishing performance adds useful information beyond season-long historical averages.

An additional predictor does not necessarily improve performance on unseen data.

Its usefulness must be evaluated using validation results.

## 11. Recent Position Linear Regression

The recent position model uses:

```r
recent_model <- lm(
    position ~
        grid +
        prev_avg_points +
        recent_avg_position,
    data = train_data
)
```

### 11.1 Predictors

- `grid`
- `prev_avg_points`
- `recent_avg_position`

### 11.2 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{prev\_avg\_points})
+ \beta_3(\text{recent\_avg\_position})
\]

### 11.3 Purpose

This model replaces the season-long average finishing position with the recent average finishing position.

It tests whether recent finishing performance is more informative than the cumulative finishing-position average when combined with the other predictors.

## 12. Recent Points Linear Regression

The recent points model uses:

```r
recent_points_model <- lm(
    position ~
        grid +
        prev_avg_position +
        recent_avg_points,
    data = train_data
)
```

### 12.1 Predictors

- `grid`
- `prev_avg_position`
- `recent_avg_points`

### 12.2 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{prev\_avg\_position})
+ \beta_3(\text{recent\_avg\_points})
\]

### 12.3 Purpose

This model replaces cumulative average points with recent average points.

It investigates whether recent points-scoring performance provides a more useful signal.

### 12.4 Validation Performance

In the project's 2024 validation comparison, this model achieved:

| Metric | Value |
|---|---:|
| MAE | 2.9058 |
| RMSE | 3.8338 |

These were the lowest validation MAE and RMSE values among the compared models.

This makes the Recent Points Linear Regression model the best-performing model on the 2024 validation dataset.

It does not establish that the model will necessarily perform best on the independent 2025 test dataset.

## 13. Both Recent Features Linear Regression

The project trains:

```r
both_recent_model <- lm(
    position ~
        grid +
        recent_avg_points +
        recent_avg_position,
    data = train_data
)
```

### 13.1 Predictors

- `grid`
- `recent_avg_points`
- `recent_avg_position`

### 13.2 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{recent\_avg\_points})
+ \beta_3(\text{recent\_avg\_position})
\]

### 13.3 Purpose

This model uses recent historical performance indicators instead of the season-long cumulative averages.

It investigates whether a shorter performance window is sufficient for predicting finishing positions.

## 14. Log Transformed Recent Points Linear Regression

The project trains:

```r
log_recent_points_model <- lm(
    position ~
        grid +
        prev_avg_position +
        log1p(recent_avg_points),
    data = train_data
)
```

### 14.1 Predictors

- `grid`
- `prev_avg_position`
- `log1p(recent_avg_points)`

### 14.2 Why Apply a Logarithmic Transformation?

Championship points can have an uneven distribution.

A logarithmic transformation compresses larger values more strongly than smaller values.

This may help model a relationship that is not well represented by an untransformed linear predictor.

However, the transformation does not guarantee improved predictive performance.

### 14.3 The `log1p()` Function

The `log1p()` function calculates:

\[
\log(1+x)
\]

using the natural logarithm.

**Syntax:**

```r
log1p(x)
```

| Argument | Description |
|---|---|
| `x` | Numerical input vector |

Example:

```r
log1p(0)
```

returns `0`.

And:

```r
log1p(9)
```

returns approximately `2.3026`.

### 14.4 Why Use `log1p()` Instead of `log()`?

The ordinary natural logarithm of zero is negative infinity.

```r
log(0)
```

returns:

```text
-Inf
```

By contrast:

```r
log1p(0)
```

returns:

```text
0
```

This is useful because drivers may have a recent average points value of zero.

### 14.5 Mathematical Representation

\[
\widehat{\text{position}} =
\beta_0
+ \beta_1(\text{grid})
+ \beta_2(\text{prev\_avg\_position})
+ \beta_3\log(1+\text{recent\_avg\_points})
\]

## 15. Baseline Model

The project uses a simple baseline prediction:

```r
baseline_prediction = mean(train_data$position)
```

### 15.1 Purpose

The baseline predicts the same finishing position for every observation.

This constant is the mean finishing position in the training dataset.

### 15.2 The `mean()` Function

**Syntax:**

```r
mean(x, trim = 0, na.rm = FALSE, ...)
```

| Argument | Description |
|---|---|
| `x` | Numerical vector |
| `trim` | Fraction of extreme observations to remove from each end |
| `na.rm` | Whether to ignore missing values |
| `...` | Additional arguments |

### 15.3 Example

Suppose the training positions were:

```r
c(2, 4, 6, 8)
```

Then:

```r
mean(c(2, 4, 6, 8))
```

returns:

```text
5
```

The baseline would predict position 5 for every observation.

### 15.4 Why Use a Baseline?

A predictive model should be compared with a simple reference.

If a more complex model cannot outperform the baseline, its additional complexity may not be justified.

The baseline does not use grid position or historical driver performance.

## 16. Generating Predictions with `predict()`

The project generates predictions using:

```r
predict()
```

### 16.1 Purpose

`predict()` is a generic R function that generates predictions from fitted model objects.

The specific prediction method depends on the class of the model.

For example:

- An `lm` object uses the linear model prediction method.
- An `rpart` object uses the regression tree prediction method.

### 16.2 General Usage

```r
predict(object, newdata = NULL, ...)
```

| Argument | Description |
|---|---|
| `object` | Fitted model object |
| `newdata` | Dataset containing predictor values for new observations |
| `...` | Additional arguments interpreted by the model-specific prediction method |

The project explicitly supplies the fitted model and the dataset to predict.

### 16.3 Linear Regression Prediction

Example:

```r
predict(
    model,
    newdata = validation_data
)
```

The function uses the estimated coefficients from `model` and the predictor values in `validation_data`.

### 16.4 Decision Tree Prediction

Example:

```r
predict(
    tree_model,
    newdata = validation_data
)
```

The function assigns each observation to a terminal tree node and returns its numerical prediction.

### 16.5 Why `newdata` Matters

The model is fitted on:

```r
train_data
```

Predictions are then generated for:

```r
validation_data
```

or:

```r
test_data
```

This allows performance to be assessed on observations that were not used to estimate the model parameters.

## 17. Adding Predictions with `mutate()`

The project uses `mutate()` to add prediction columns to existing datasets.

### 17.1 `mutate()` Syntax

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
validation_data <- validation_data |>
    mutate(
        predicted_position = predict(
            model,
            newdata = validation_data
        )
    )
```

This creates a new column named `predicted_position`.

The original observations and their actual finishing positions remain available for evaluation.

## 18. Predictions for the Test Dataset

The current script adds five prediction columns to `test_data`.

```r
test_data <- test_data |>
    mutate(
        predicted_position = predict(
            model,
            newdata = test_data
        ),
        tree_prediction = predict(
            tree_model,
            newdata = test_data
        ),
        baseline_prediction = mean(train_data$position),
        improved_prediction = predict(
            improved_model,
            newdata = test_data
        ),
        recent_prediction = predict(
            recent_model,
            newdata = test_data
        )
    )
```

### 18.1 Test Prediction Columns

| Column | Model |
|---|---|
| `predicted_position` | Original Linear Regression |
| `tree_prediction` | Decision Tree |
| `baseline_prediction` | Baseline |
| `improved_prediction` | Improved Linear Regression |
| `recent_prediction` | Recent Position Linear Regression |

The script does not currently add predictions from the Recent Points, Both Recent Features, or Log-Transformed Recent Points models to `test_data`.

These models are nevertheless trained and saved.

## 19. Predictions for the Validation Dataset

The project adds prediction columns for all seven predictive models and the baseline.

```r
validation_data <- validation_data |>
    mutate(
        predicted_position = predict(
            model,
            newdata = validation_data
        ),
        tree_prediction = predict(
            tree_model,
            newdata = validation_data
        ),
        baseline_prediction = mean(train_data$position),
        improved_prediction = predict(
            improved_model,
            newdata = validation_data
        ),
        recent_prediction = predict(
            recent_model,
            newdata = validation_data
        ),
        recent_points_prediction = predict(
            recent_points_model,
            newdata = validation_data
        ),
        both_recent_prediction = predict(
            both_recent_model,
            newdata = validation_data
        ),
        log_recent_points_prediction = predict(
            log_recent_points_model,
            newdata = validation_data
        )
    )
```

### 19.1 Validation Prediction Columns

| Column | Model |
|---|---|
| `predicted_position` | Original Linear Regression |
| `tree_prediction` | Decision Tree |
| `baseline_prediction` | Baseline |
| `improved_prediction` | Improved Linear Regression |
| `recent_prediction` | Recent Position Linear Regression |
| `recent_points_prediction` | Recent Points Linear Regression |
| `both_recent_prediction` | Both Recent Features Linear Regression |
| `log_recent_points_prediction` | Log-Transformed Recent Points Linear Regression |

These columns are used by the evaluation script to calculate prediction errors and compare model performance.

## 20. Comparing Model Specifications

The following table summarises the model formulas.

| Model | Formula |
|---|---|
| Original Linear Regression | `position ~ grid + prev_avg_position + prev_avg_points` |
| Decision Tree | `position ~ grid + prev_avg_position + prev_avg_points` |
| Improved Linear Regression | `position ~ grid + prev_avg_position + prev_avg_points + recent_avg_position` |
| Recent Position Linear Regression | `position ~ grid + prev_avg_points + recent_avg_position` |
| Recent Points Linear Regression | `position ~ grid + prev_avg_position + recent_avg_points` |
| Both Recent Features Linear Regression | `position ~ grid + recent_avg_points + recent_avg_position` |
| Log-Transformed Recent Points Linear Regression | `position ~ grid + prev_avg_position + log1p(recent_avg_points)` |

The models differ in either their modelling method or their choice of historical predictors.

These variations allow the project to investigate whether recent performance indicators improve predictive accuracy.

## 21. Validation Performance Summary

The completed validation comparison produced the following results for the 2024 season.

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

Lower values indicate better predictive performance.

The Recent Points Linear Regression model achieved the lowest validation MAE and RMSE.

The results suggest that replacing cumulative average points with recent average points was beneficial for this validation dataset.

However, these differences should be interpreted in the context of the selected validation season and the models compared.

## 22. Saving the Models and Predictions

The script saves the trained models and the modelling datasets.

```r
save(
    model,
    tree_model,
    train_data,
    validation_data,
    test_data,
    improved_model,
    recent_model,
    recent_points_model,
    both_recent_model,
    log_recent_points_model,
    file = "../data/model_results.RData"
)
```

### 22.1 The `save()` Function

**Relevant syntax:**

```r
save(..., file)
```

| Argument | Description |
|---|---|
| `...` | Named R objects to save |
| `file` | Destination file path |

The output file is:

`data/model_results.RData`

### 22.2 Why Save the Models?

Saving the model objects avoids the need to retrain them every time the evaluation script is executed.

The file also preserves the validation and test datasets containing generated predictions.

## 23. Model Interpretation Considerations

### 23.1 Linear Regression Assumptions

Linear regression relies on assumptions relevant to statistical inference and model diagnostics, including:

- Appropriate specification of the conditional mean relationship.
- Independence of errors.
- Constant error variance for conventional inference.
- Limited harmful multicollinearity.
- Approximately normal errors when relying on certain small-sample inferential procedures.

These assumptions are investigated further in the model evaluation stage.

Violations do not automatically make every prediction unusable, but they may affect inference, stability, or predictive performance.

### 23.2 Multicollinearity

Historical average finishing position, historical points, and recent performance features may be correlated.

Strong correlations between predictors can make regression coefficients unstable or difficult to interpret.

The evaluation script uses Variance Inflation Factors to investigate this issue.

### 23.3 Decision Tree Characteristics

Decision trees can represent nonlinear relationships and interactions without explicitly specifying them in a regression formula.

However, they can also be sensitive to training data and tree complexity.

The current project does not include a separate tree hyperparameter optimisation procedure.

### 23.4 Numerical Predictions

Neither ordinary linear regression nor a standard regression tree guarantees valid integer finishing positions.

Predictions may be fractional, and linear regression can produce values outside the possible finishing-position range.

The evaluation uses the numerical predictions directly.

## 24. Important Modelling Limitations

### 24.1 Limited Predictors

The models use starting grid position and historical driver performance.

They do not explicitly include weather, strategy, safety cars, reliability, or other race-specific factors.

### 24.2 Historical Performance Reset

Historical performance features are calculated separately within each season.

Previous-season performance is not carried into the new season's engineered averages.

### 24.3 No Hyperparameter Search

The decision tree uses its default training controls.

The project does not currently document a systematic hyperparameter tuning process.

### 24.4 Validation-Based Model Selection

The models are compared using the 2024 validation dataset.

Selecting the best-performing model based on these results can introduce selection effects.

An independent test dataset is therefore important for assessing generalisation.

### 24.5 Incomplete Independent Test Comparison

The modelling script currently generates 2025 predictions for five models and the baseline.

It does not yet generate test predictions for every model included in the validation comparison.

The final independent test evaluation has not been completed.

## 25. Modelling Workflow

```text
model_data.RData
        |
        v
Load training, validation, and test datasets
        |
        v
Train seven predictive models
        |
        v
Calculate training-mean baseline
        |
        v
Generate 2024 validation predictions
        |
        v
Generate available 2025 test predictions
        |
        v
Save models and prediction datasets
        |
        v
model_results.RData
        |
        v
Model evaluation
```

## 26. Connection to Model Evaluation

The next stage is implemented in:

`scripts/04_evaluation.R`

It loads:

```r
load("../data/model_results.RData")
```

The evaluation script calculates prediction errors, compares MAE and RMSE, examines performance across different race conditions, and performs regression diagnostics.

The next document, `07_model_evaluation.md`, explains these calculations and diagnostics in detail, including their mathematical definitions, R functions, arguments, and interpretation.