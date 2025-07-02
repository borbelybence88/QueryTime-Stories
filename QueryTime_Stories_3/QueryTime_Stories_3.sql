--creating some test data
WITH test_data AS(
  SELECT "Hardware store"	AS Store, "Hammer" AS Item
  UNION ALL
  SELECT "Hardware store", "Nails"
  UNION ALL
  SELECT "Hardware store", "Saw"
  UNION ALL
  SELECT "Building materials supplier", "Timber"
  UNION ALL
  SELECT "Paint shop", "Primer paint"
  UNION ALL
  SELECT "Paint shop", "Glaze"
),

--adding item number per store column
with_item_number AS(
  SELECT
  Store,
  Item,
  ROW_NUMBER() OVER(PARTITION BY Store ORDER BY Item) AS Item_Number_Per_Store
  FROM test_data
)

--pivoting the table
SELECT
  Store,
  1,
  2,
  3
FROM with_item_number
PIVOT (MAX(Item) FOR Item_Number_Per_Store IN (1, 2, 3 ))