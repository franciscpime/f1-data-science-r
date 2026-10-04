library(tidyverse)
library(rpart)
load("../data/model_results.RData")


test_data <- test_data |>
    mutate(
        error = position - predicted_position,
        absolute_error = abs(error)
    ) |>
    arrange(desc(absolute_error))

# Linear Regression Evaluation
mae <- mean(
    abs(test_data$position - test_data$predicted_position)
)

rmse <- sqrt(
    mean((test_data$position - test_data$predicted_position)^2)
)

baseline_mae <- mean(
    abs(test_data$position - test_data$baseline_prediction)
)

mae_improvement <- ((baseline_mae - mae) / baseline_mae) * 100

# Compare predicted and real positions
predict_vs_real_position <- test_data |>
    select(driver, position, predicted_position) |>
    arrange(position)


# Real position vs predicted position
real_position_vs_predicted_position <- ggplot(
    test_data,
    aes(x = position, y = predicted_position)
) +
    geom_abline(slope = 1, intercept = 0) +
    geom_point()

ggsave(
    "../plots/real_position_vs_predicted_position.png",
    real_position_vs_predicted_position
)


# Linear Regression error distribution
errors_distribution <- ggplot(test_data, aes(x = error)) +
    geom_histogram()

ggsave(
    "../plots/errors_distribution.png",
    errors_distribution
)



# Model comparison
models_comparison <- ggplot(test_data, aes(x = position)) +
    geom_col(aes(y = predicted_position)) +
    geom_col(aes(y = tree_prediction))

ggsave(
    "../plots/models_comparison.png",
    models_comparison
)


# Decision Tree error distribution
tree_errors_distribution <- ggplot(
    test_data,
    aes(x = position - tree_prediction)
) +
    geom_histogram()

ggsave(
    "../plots/tree_errors_distribution.png",
    tree_errors_distribution
)

print(test_data, width = Inf)