# My findings

## Data
- Source: Birmingham City Council, Payments to Suppliers over £500
- Period tested: 1 April 2025 to 31 March 2026
- 110,426 payments, total £1,812,850,674
- 0 missing amounts, 0 negative amounts
- Smallest payment £500 (matches the threshold for publishing)
- Median £1,562, mean £16,417, largest £18,412,152
- 3,959 payee names

## Data quality notes
- Redacted payees appear under two labels ("REDACTED - PERSONAL DATA" and "REDACTED-PERSONAL DATA")
- Adult social care appears under two directorate names

## Limitation of scope
- 3,134 redacted payments (£11.9m, which is 2.8% of payments and 0.7% of value), mostly adult social care
- Left these out of duplicate and supplier checks as they are only 0.7% of the money so have limited impact.

## Other observations
- Most frequent payee: Extra Personnel Limited (temporary staffing agency)
- 12,665 payments, £12.1m total (about £957 each), but just 0.7% of total value

## Test 1: Benford's Law (first digit)
- Ran it on the 75,287 payments of £1,000 or more
- Didn't fit. MAD came out at 0.043 and anything over 0.015 counts as a poor fit
- Payments starting with 1 made up 47.4% when Benford expects 30.1%. Every digit from 3 to 9 came in lower than expected
- I think this is down to the data, not anything wrong with the payments. The council only publishes payments over £500 and most are near the bottom end (median £1,562), so a lot of them fall between £1,000 and £1,999
- Benford's Law needs data spread across lots of different sizes with nothing cut off, and this data doesn't have that
- So I'm not treating this as a red flag. It just means Benford isn't a good test for this dataset, and the duplicate and round-number tests are more useful here

## Test 2: Duplicate payments
- Excluded redacted payments (107,292 payments tested)
- Level 1 (same payee, amount, date): 700 extra payments, £2.99m
- Level 2 (also same department and cost centre): 116 extra payments, £2.27m, about 0.1% of spend. Possible duplicates, not confirmed
- 94 of the 114 Level 2 groups (82%) are from Adult Care Packages cost centre. Biggest ones (top 10) fall on three dates, but overall the dates are spread out. Looks tied to how care package payments are made, rather than one-off errors. May be normal or paid twice; the invoices would reveal which.

## Test 3: Round-number payments
- Kept redacted payments in for this one as it only looks at amounts
- 1,245 payments were exact multiples of £1,000. That's 1.1% of payments and £39.9m, or 2.2% of the money
- £3,000 and £6,000 came up most, then £1,000, £10,000 and £5,000
- Almost half (at least 601) were coded to the GRNI account, which is goods received but not invoiced yet. If those payments are round, they might be based on the purchase order rather than the actual invoice. I'd look at these first since accruals are estimates
- Legal fees had the next most (285). Likely fixed fees or settlements
- I also tried £500 instead of £1,000. It picked up 2,757 payments (2.5%), so still not many and it doesn't change anything

## Top 10 suppliers by value
- 40.4% of the year's spend (approx. £733m) went to just 10 suppliers out of 3,959 payee names
- Equans Regeneration got the most by a long way, £210.3m (11.6%) from only 73 payments
- Most of the top 10 were paid in a few big amounts. West Mercia Energy is the odd one out with 7,484 payments, probably regular energy bills
- Extra Personnel isn't in the top 10 even though it was paid the most times. Hays, another recruitment agency, is second with £117.3m from just 82 payments
- May be good to begin with these top 10. Excluding West Mercia Energy there were only 401 payments across the 9 which covered around 39% of all spending.