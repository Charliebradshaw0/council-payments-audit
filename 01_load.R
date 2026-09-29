# 01 - Loading and inspecting the data

# install.packages(c("tidyverse", "janitor", "benford.analysis"))
library(tidyverse)
library(janitor)

list.files()

payments <- read_delim("payments-to-suppliers-over-gbp500.csv") |> clean_names()
glimpse(payments)
head(payments, 10)

nrow(payments)
range(payments$date, na.rm = TRUE)