-- You can see the scipts for the QueryTime Stories #1

-- creating some test data
WITH test_data AS (
SELECT
  "Gipsz Jakab" AS name,
  "FB ad 1" AS campaign,
  1 AS campaign_priority,
  make_date(2025,01,01)  AS from_date,
  make_date(2025,01,20) AS to_date
UNION ALL
SELECT "Gipsz Jakab", "Google search 1", 2, make_date(2025,01,15), make_date(2025,02,04)
UNION ALL
SELECT "Gipsz Jakab", "YT ad", 1, make_date(2025,01,28), make_date(2025,02,17)
UNION ALL
SELECT "Gipsz Jakab", "Direct", 3, make_date(2025,02,08), make_date(2025,02,28)
UNION ALL
SELECT "Gipsz Jakab", "Google search 2", 2, make_date(2025,02,10), make_date(2025,03,02)
UNION ALL
SELECT "Gipsz Jakab", "FB ad 2", 1, make_date(2025,02,20), make_date(2025,03,10)
),

--generating the date table
date_table AS(
    SELECT EXPLODE(SEQUENCE(DATE'2025-01-01', DATE'2025-03-31', INTERVAL 1 DAY)) AS date
),

--joining the raw date with the date table to get campaing/user combinations on daily level
joined AS(
    SELECT
        date.date,
        camp.name,
        camp.campaign,
        camp.campaign_priority
    FROM date_table AS date
    INNER JOIN test_data AS camp
    ON date.date BETWEEN camp.from_date AND camp.to_date
),

--choosing the highest priority campaign per day
daily_winner AS(
    SELECT
        date,
        name,
        campaign    
    FROM joined
    QUALIFY ROW_NUMBER() OVER(PARTITION BY name, date ORDER BY campaign_priority) = 1
)

--recreating the from_date and to_date fileds
SELECT
    name,
    campaign,
    MIN(date) as from_date,
    MAX(date) as to_date
FROM daily_winner
GROUP BY name,campaign
ORDER BY from_date
