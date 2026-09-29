# 06 - Top 10 suppliers by value
# Extra Personnel got paid more times than anyone but only ended up with approx. 0.7% of the money.
# So being paid often doesn't mean being paid the most, hence now looking at who actually gets the most money

library(tidyverse)
options(scipen = 999)

fy <- read_rds("fy2025_26.rds")

# Taking redacted payments out again. Otherwise "REDACTED" will look like one massive supplier when it's actually many different people
named <- fy |> filter(!str_detect(beneficiary, "REDACTED"))

# Add up what each supplier got over the year, work out their share of total spend
# and keep the biggest 10. (start with where most of the money is going)
top10 <- named |>
  group_by(beneficiary) |>
  summarise(payments = n(), total_gbp = sum(amount)) |>
  mutate(pct_of_spend = round(total_gbp / sum(fy$amount) * 100, 1)) |>
  arrange(desc(total_gbp)) |>
  head(10)

top10

# Result: Equans highest with £210.3m (11.6%). 9 out of 10 of the top 10 had fewer than 90 payments.

# How much of the council's total spend goes to just these top 10
round(sum(top10$total_gbp) / sum(fy$amount) * 100, 1)
# Result: 40.4% of spend (about £733m) went to these 10

# Chart of the top 10 (visual to help understanding)
ggplot(top10, aes(x = reorder(beneficiary, total_gbp), y = total_gbp / 1e6)) +
  geom_col(fill = "#1F3864") +
  coord_flip() +
  labs(title = "Birmingham City Council: top 10 suppliers by value, 2025/26",
       x = NULL, y = "Total paid (£m)") +
  theme_minimal()

ggsave("top10_suppliers_chart.png", width = 8, height = 5)