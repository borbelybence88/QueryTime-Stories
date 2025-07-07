--generating some test data
WITH kings_and_years AS(
  SELECT 'Branoc' as name, 526 as year
  UNION ALL
  SELECT 'Branoc', 527
  UNION ALL
  SELECT 'Branoc', 528
  UNION ALL
  SELECT 'Dunmail', 529
  UNION ALL
  SELECT 'Dunmail', 530
  UNION ALL
  SELECT 'Dunmail', 531
  UNION ALL
  SELECT 'Dunmail', 532
  UNION ALL
  SELECT 'Branoc', 533
  UNION ALL
  SELECT 'Branoc', 534
  UNION ALL
  SELECT 'Lughvarn', 535
  UNION ALL
  SELECT 'Lughvarn', 536
  UNION ALL
  SELECT 'Lughvarn', 537
  UNION ALL
  SELECT 'Branoc', 538
  UNION ALL
  SELECT 'Branoc', 539
  UNION ALL
  SELECT 'Branoc', 540
  UNION ALL
  SELECT 'Branoc', 541
  UNION ALL
  SELECT 'Dunmail', 542
  UNION ALL
  SELECT 'Dunmail', 543
  UNION ALL
  SELECT 'Dunmail', 544
  UNION ALL
  SELECT 'Dunmail', 545
  UNION ALL
  SELECT 'Lughvarn', 546
  UNION ALL
  SELECT 'Lughvarn', 547
  UNION ALL
  SELECT 'Branoc', 548
  UNION ALL
  SELECT 'Branoc', 549
  UNION ALL
  SELECT 'Branoc', 550
),

--adding change flag to identify when a new king is crowned
with_change_flag AS(
  SELECT
    name,
    year,
    CASE WHEN LAG(Name) OVER(ORDER BY Year)=Name THEN 0 ELSE 1 END AS change_flag
  FROM kings_and_years
),

--summing change flags to identify regin sessions
with_regin_sessions AS(
  SELECT
    name,
    year,
    SUM(change_flag) OVER(ORDER BY Year) AS regin_session
  FROM with_change_flag
)

--calculating the from and to year of each regin session
SELECT
  name,
  MIN(year) AS from_year,
  MAX(year) AS to_year
FROM with_regin_sessions
GROUP BY name, regin_session
ORDER BY from_year