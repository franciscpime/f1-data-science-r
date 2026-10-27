library(tidyverse)
library(rpart)
load("../data/model_data.RData")


# Predict finishing position using starting grid and
# historical driver performance
model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)


# Train a regression tree using the same predictors
# as the original linear regression model
tree_model <- rpart(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)


# Extend the original model with recent average position
improved_model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points + recent_avg_position,
    data = train_data
)

# Use recent average position instead of historical
# average position
recent_model <- lm(
    position ~ grid + prev_avg_points + recent_avg_position,
    data = train_data
)

# Use recent average points instead of historical
# average points
recent_points_model <- lm(
    position ~ grid + prev_avg_position + recent_avg_points,
    data = train_data
)

# Combine recent average position and recent average points
both_recent_model <- lm(
    position ~ grid + recent_avg_points + recent_avg_position,
    data = train_data
)

# Apply a log transformation to recent average points
# while retaining historical average position
log_recent_points_model <- lm(
    position ~ grid + prev_avg_position + log1p(recent_avg_points),
    data = train_data
)

# Generate predictions using the original models
# and the training set mean as a baseline
test_data <- test_data |>
    mutate(
        predicted_position = predict(model, newdata = test_data),
        tree_prediction = predict(tree_model, newdata = test_data),
        baseline_prediction = mean(train_data$position),
        improved_prediction = predict(improved_model, newdata = test_data),
        recent_prediction = predict(recent_model, newdata = test_data)
    )

# Generate predictions from all seven models
# and the baseline for model comparison
validation_data <- validation_data |>
    mutate(
        predicted_position = predict(model, newdata = validation_data),
        tree_prediction = predict(tree_model, newdata = validation_data),
        baseline_prediction = mean(train_data$position),
        improved_prediction = predict(improved_model, newdata = validation_data),
        recent_prediction = predict(recent_model, newdata = validation_data),
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