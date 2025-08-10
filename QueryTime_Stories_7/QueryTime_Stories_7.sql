--creating a table that represents the current state of the character dimension table with current_weapon, previous_weapon, and valid_from
CREATE OR REPLACE TABLE dim_characters AS
SELECT 1 AS character_id, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Enchanted Staff" AS current_weapon, DATE('2025-01-01') AS valid_from, CAST(null as STRING) AS previous_weapon
UNION ALL
SELECT 2, "Thorgar Ironfist", "Warrior", "Dwarf", "Great Warhammer", DATE('2025-01-01'), CAST(null as STRING) 
UNION ALL
SELECT 3, "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers",DATE('2025-01-01'), CAST(null as STRING) 
;

--creating a table which represents what's in the source system right now
CREATE OR REPLACE TABLE source_characters AS
SELECT 1 AS character_id, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Crystal Wand" AS weapon
UNION ALL
SELECT 2, "Dorg Stonebreaker", "Warrior", "Dwarf", "Great Warhammer"
UNION ALL
SELECT 3, "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers"
;

-- updating the weapon related fields
MERGE INTO dim_characters AS target
USING source_characters AS source
ON target.character_id = source.character_id
WHEN MATCHED AND target.current_weapon != source.weapon THEN
UPDATE SET
target.previous_weapon = target.current_weapon,
target.current_weapon = source.weapon,
target.valid_from = CURRENT_DATE()
;

--dim_characters after weapon chagne
SELECT
    * 
FROM dim_characters