# Set the working directory to this script's location
args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("^--file=", "", args[grepl("^--file=", args)])

if (length(script_path) > 0) {
    setwd(dirname(normalizePath(script_path[1])))
}

library(tidyverse)
library(rpart)
library(car)
library(lmtest)
load("../../data/processed/model_results.RData")

source("01_metrics.R")

source("03_model_comparison.R")

source("02_error_analysis.R")

source("04_diagnostics.R")