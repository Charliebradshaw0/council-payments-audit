# 03 - Benford's Law first-digit test

library(tidyverse)
options(scipen = 999)

fy <- read_rds("fy2025_26.rds")

# The council only publishes payments over £500, so small amounts are missing.
# Starting at £1,000 reduces this problem, but most payments are still just above the cut-off,
# so the data isn't well suited to Benford's Law (as seen in result below).
benford <- fy |>
  filter(amount >= 1000) |>
  mutate(first_digit = floor(amount / 10^floor(log10(amount)))) |>
  count(first_digit) |>
  mutate(actual     = n / sum(n),
         expected   = log10(1 + 1 / first_digit),
         difference = actual - expected)

benford

# Overall fit: mean absolute deviation (MAD)
# From what I read: under 0.006 = close fit, 0.006-0.012 = acceptable, 0.012-0.015 = marginal, over 0.015 = poor fit
mean(abs(benford$difference))
# MAD Result: 0.043 = poor fit. May be down to £500 cut-off for publishing, so small numbers are missing, making the test less reliable

# Chart: bars = actual, red line = what Benford's Law expects
ggplot(benford, aes(x = factor(first_digit))) +
  geom_col(aes(y = actual), fill = "#1F3864") +
  geom_line(aes(y = expected, group = 1), colour = "red") +
  geom_point(aes(y = expected), colour = "red", size = 2) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Birmingham City Council payments, 2025/26: first digits vs Benford's Law",
       subtitle = "Payments of £1,000 and over. Bars = actual, red line = expected",
       x = "First digit", y = "Share of payments") +
  theme_minimal()

ggsave("benford_chart.png", width = 8, height = 5)