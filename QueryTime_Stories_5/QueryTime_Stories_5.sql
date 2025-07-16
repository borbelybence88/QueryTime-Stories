--creating a table which represents the current state of the character dimension table
CREATE OR REPLACE TABLE dim_characters AS
SELECT 1 AS character_id, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Enchanted Staff" AS weapon
UNION ALL
SELECT 2, "Thorgar Ironfist", "Warrior", "Dwarf", "Great Warhammer"
UNION ALL
SELECT 3, "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers"
;

--creating a table which represents what's in the source system right now
CREATE OR REPLACE TABLE source_characters AS
SELECT 1 AS character_id, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Enchanted Staff" AS weapon
UNION ALL
SELECT 2, "Dorg Stonebreaker", "Warrior", "Dwarf", "Great Warhammer"
UNION ALL
SELECT 3, "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers"
;

--SCD type 1 example: simply update the names when the source changes
MERGE INTO dim_characters
USING source_characters
ON source_characters.character_id = dim_characters.character_id
--when there's a match in the ids, but not in the names it updates the name
WHEN MATCHED AND dim_characters.name != source_characters.name
  THEN UPDATE SET dim_characters.name = source_characters.name
;

SELECT * from dim_characters
ORDER BY character_id