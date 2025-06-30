--creating some test data
WITH RECURSIVE table_hierarchy AS(
SELECT 'silver_1' AS destination_table, 'bronze_1' AS source_table
UNION ALL
SELECT 'silver_1', 'bronze_2'
UNION ALL
SELECT 'silver_2', 'bronze_2'
UNION ALL
SELECT 'silver_2', 'bronze_3'
UNION ALL
SELECT 'silver_3', 'silver_1'
UNION ALL
SELECT 'silver_3', 'silver_2'
UNION ALL
SELECT 'gold_1', 'silver_1'
UNION ALL
SELECT 'gold_1', 'silver_2'
UNION ALL
SELECT 'gold_1', 'silver_3'
),

--making a recursive query with execution levels
anchestor AS(
    SELECT 'gold_1' AS table_to_create, 1 AS level

    UNION ALL

    SELECT table_hierarchy.source_table AS table_to_create, level + 1 AS level
    FROM anchestor
    INNER JOIN table_hierarchy
        ON anchestor.table_to_create=table_hierarchy.destination_table
)

--getting the final execution order from levels
SELECT
	table_to_create,
	MAX(level) execution_order
FROM anchestor
GROUP BY table_to_create
ORDER BY MAX(level) DESC