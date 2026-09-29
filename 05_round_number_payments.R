# 05 - Round-number payments
# Real invoices aren't usually round. Some round payments can be normal (e.g. grants, fixed fees) but may also be an estimate or a manually typed amount, so must check where round payments come from.

library(tidyverse)
options(scipen = 999)

fy <- read_rds("fy2025_26.rds")

# ---- Main test: exact multiples of £1,000 ----
round_pay <- fy |>
  mutate(round_1000 = amount %% 1000 == 0)

sum(fy$amount)   # Result: £1,812,850,674 (total spend for the year)

# How many round payments, and what share of payments and value
round_pay |>
  summarise(payments     = sum(round_1000),
            pct_payments = round(mean(round_1000) * 100, 1),
            total_gbp    = sum(amount[round_1000]),
            pct_value    = round(sum(amount[round_1000]) / sum(amount) * 100, 1))
# Result: 1,245 payments (1.1%), £39.9m (2.2% total value)

# Which departments and categories make the most round payments
round_pay |>
  filter(round_1000) |>
  count(directorate, merchant_category, sort = TRUE) |>
  head(10)

# The most common round amounts
round_pay |>
  filter(round_1000) |>
  count(amount, sort = TRUE) |>
  head(10)

# ---- Another check: does using £500 instead change the findings ----
fy |>
  summarise(multiples_1000     = sum(amount %% 1000 == 0),
            pct_1000           = round(mean(amount %% 1000 == 0) * 100, 1),
            multiples_500      = sum(amount %% 500 == 0),
            pct_500            = round(mean(amount %% 500 == 0) * 100, 1))
# Result: £500 flags 2,757 (2.5%), still rare, conclusion won't be altered through change in threshold.