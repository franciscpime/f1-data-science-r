library(ranger)
library(tidyverse)

load("../../data/processed/model_data.RData")

set.seed(42)

random_forest_formula <- position ~ grid + prev_avg_position + recent_avg_points

# Random Forest parameters:
#
# num.trees: Number of decision trees in the forest.
#   Each tree makes a prediction, and the final result is their average.
#
# mtry: Number of features randomly considered at each split.
#   A smaller value makes trees consider fewer features per decision.
#
# min.node.size: Minimum terminal node size parameter.
#   Smaller values allow more detailed trees.
#   Larger values encourage simpler trees with fewer splits.
#
# Selected configuration (2024 validation):
# num.trees = 500, mtry = 1, min.node.size = 120
# Best Random Forest results: MAE = 2.9781, RMSE = 3.9096
random_forest_model <- ranger(
    formula=random_forest_formula,
    data=train_data,
    num.trees=500,
    mtry=1,
    min.node.size=120
)

random_forest_prediction <- predict(
    object=random_forest_model, 
    data=validation_data
)$predictions

random_forest_mae <- mean(
    abs(random_forest_prediction - validation_data$position)
)

random_forest_rmse <- sqrt(
    mean((random_forest_prediction - validation_data$position)^2)
)

random_forest_test_prediction <- predict(
    object=random_forest_model, 
    data=test_data
)$predictions

random_forest_test_mae <- mean(
    abs(random_forest_test_prediction - test_data$position)
)

random_forest_test_rmse <- sqrt(
    mean((random_forest_test_prediction - test_data$position)^2)
)

save(
    random_forest_model,
    random_forest_prediction,
    random_forest_mae,
    random_forest_rmse,
    random_forest_test_prediction,
    random_forest_test_mae,
    random_forest_test_rmse,
    file = "../../data/processed/random_forest_results.RData"
)