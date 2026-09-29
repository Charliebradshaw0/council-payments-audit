# 04 - Duplicate payment test
# Paying the same invoice twice is one of the most common payment errors (must check for it)

library(tidyverse)
options(scipen = 999)

fy <- read_rds("fy2025_26.rds")

# Redacted payments are left out because loads of different people are grouped under one name,
# so two identical payments may easily be two different people
named <- fy |> filter(!str_detect(beneficiary, "REDACTED"))

# ---- Level 1: same payee, same amount, same date ----
level1 <- named |>
  count(beneficiary, amount, date, name = "copies") |>
  filter(copies > 1)

# If a payment appeared 3 times, I'm counting the first as genuine and the other 2 as potential overpayments
level1 |>
  summarise(groups         = n(),
            extra_payments = sum(copies - 1),
            extra_gbp      = sum((copies - 1) * amount))

# Level 1 summary: Result: 583 groups, Extra payments: 700, Extra gbp: 2,988,337 (before further checks)

# ---- Level 2: same as previous but also same department and cost centre ----
# Level 1 will catch some normal payments (e.g. two people's care at the same rate paid to one care home on the same day)
# Adding department and cost centre ensures more likely to be real duplicates
level2 <- named |>
  count(beneficiary, amount, date, directorate, summary, name = "copies") |>
  filter(copies > 1)

level2 |>
  summarise(groups         = n(),
            extra_payments = sum(copies - 1),
            extra_gbp      = sum((copies - 1) * amount))

# Level 2 summary: Result: 114 groups, Extra payments: 116, Extra gbp: 2,269,197 (before further checks)

# Level 2 possible overpayment as a % of total spend
round(sum((level2$copies - 1) * level2$amount) / sum(fy$amount) * 100, 1)   # Result: 0.1%

# Top 10 Level 2 matches by value
level2 |>
  mutate(extra_gbp = (copies - 1) * amount) |>
  arrange(desc(extra_gbp)) |>
  head(10)

# Looking at all Level 2 groups to see if pattern is consistent with top 10
level2 |> count(date, sort = TRUE) |> head(5)
level2 |> count(summary, sort = TRUE) |> head(5)
# Result: dates spread out, busiest date only 8 of 114 groups, and top 5 dates is 24 (other 90 spread across different dates)
# Result: 94 of 114 groups (82%) are Adult Care Packages

# Save the Level 2 list so I can look through it
write_csv(level2, "duplicate_payments_level2.csv")