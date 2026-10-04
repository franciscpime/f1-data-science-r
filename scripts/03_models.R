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


test_data <- test_data |>
    mutate(
        predicted_position = predict(model, newdata = test_data),
        tree_prediction = predict(tree_model, newdata = test_data),
        baseline_prediction = mean(train_data$position)
    )


save(
    model,
    tree_model,
    train_data,
    test_data,
    file = "../data/model_results.RData"
)