# 02 - Pick the audit period and check the data

library(tidyverse)
library(janitor)
options(scipen = 999)   # show full numbers instead of things like 1.23e6

payments <- read_delim("payments-to-suppliers-over-gbp500.csv") |>
  clean_names() |>
  mutate(date = as.Date(date))

# councils get audited one financial year at a time, so I used one full year: 1 April 2025 to 31 March 2026
fy <- payments |>
  filter(date >= as.Date("2025-04-01"), date <= as.Date("2026-03-31"))

# Quick checks
nrow(fy)                          # how many payments
sum(fy$amount, na.rm = TRUE)      # total value (£)
sum(fy$amount < 0, na.rm = TRUE)  # how many negative amounts (credits/refunds)
sum(is.na(fy$amount))             # any missing amounts?
n_distinct(fy$beneficiary)        # how many different payee names
fy |> count(beneficiary, sort = TRUE) |> head(10)   # most frequently paid payees
summary(fy$amount)                # smallest, typical and largest payment

# Save the year's data for the next scripts
write_rds(fy, "fy2025_26.rds")

tibble(
  payments  = nrow(fy),
  total_gbp = sum(fy$amount),
  negatives = sum(fy$amount < 0),
  missing   = sum(is.na(fy$amount)),
  suppliers = n_distinct(fy$beneficiary),
  top_payee = names(sort(table(fy$beneficiary), decreasing = TRUE))[1]
)

# Where do the redacted (personal data) payments come from?
fy |>
  filter(str_detect(beneficiary, "REDACTED")) |>
  count(directorate, merchant_category, sort = TRUE) |>
  head(10)

# How many redacted payments, and how much money?
fy |>
  filter(str_detect(beneficiary, "REDACTED")) |>
  summarise(payments = n(), total_gbp = sum(amount))

# Extra Personnel Limited: payments, total and average
fy |>
  filter(beneficiary == "Extra Personnel Limited") |>
  summarise(payments = n(), total_gbp = sum(amount), average_gbp = mean(amount))

# ---- Redacted payments: share of the year ----
redacted <- fy |> filter(str_detect(beneficiary, "REDACTED"))
round(nrow(redacted) / nrow(fy) * 100, 1)              # Result: 2.8% of payments
round(sum(redacted$amount) / sum(fy$amount) * 100, 1)  # Result: 0.7% (1.d.p) of value

# ---- Extra Personnel: share of total value ----
extra <- fy |> filter(beneficiary == "Extra Personnel Limited")
round(sum(extra$amount) / sum(fy$amount) * 100, 1)     # Result: 0.7% (1.d.p) of value