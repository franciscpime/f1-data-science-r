library(tidyverse)
library(rpart)
load("../data/model_data.RData")


# Linear Regression
model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)


# Decision Tree
tree_model <- rpart(
    position ~ grid + prev_avg_position + prev_avg_points,
    data = train_data
)


# Improved model L.R.
improved_model <- lm(
    position ~ grid + prev_avg_position + prev_avg_points + recent_avg_position,
    data = train_data
)


recent_model <- lm(
    position ~ grid + prev_avg_points + recent_avg_position,
    data = train_data
)


test_data <- test_data |>
    mutate(
        predicted_position = predict(model, newdata = test_data),
        tree_prediction = predict(tree_model, newdata = test_data),
        baseline_prediction = mean(train_data$position),
        improved_prediction = predict(improved_model, newdata = test_data),
        recent_prediction = predict(recent_model, newdata = test_data)
    )


save(
    model,
    tree_model,
    train_data,
    test_data,
    improved_model,
    recent_model,
    file = "../data/model_results.RData"
)