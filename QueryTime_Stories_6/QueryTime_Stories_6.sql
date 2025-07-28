/* creating a table which represents the current state of the character dimension table with valid from and to intervals
   and adding a surrogate key with hashing the character_id and weapon columns. in real life scenarios we possible
   want to hash with more columns, but now the only thing we want to change is the weapon */
CREATE OR REPLACE TABLE dim_characters AS
SELECT 1 AS character_id, HASH(1, "Enchanted Staff") AS character_key, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Enchanted Staff" AS weapon, DATE('2025-01-01') AS valid_from, DATE('9999-12-31') AS valid_to
UNION ALL
SELECT 2, HASH(2, "Great Warhammer"), "Thorgar Ironfist", "Warrior", "Dwarf", "Great Warhammer", DATE('2025-01-01'), DATE('9999-12-31')
UNION ALL
SELECT 3, HASH(3, "Dual Daggers"),  "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers", DATE('2025-01-01'), DATE('9999-12-31')
;

--creating a table which represents what's in the source system right now
CREATE OR REPLACE TABLE source_characters AS
SELECT 1 AS character_id, "Elowen Starfire" AS name, "Wizard" AS class, "Elf" AS race, "Crystal Wand" AS weapon
UNION ALL
SELECT 2, "Thorgar Ironfist", "Warrior", "Dwarf", "Great Warhammer"
UNION ALL
SELECT 3, "Kaelen Shadowstep", "Rogue", "Human", "Dual Daggers"
;

--creating a staging table which will gather all the changes first with the current state of records
CREATE OR REPLACE TABLE dim_characters_staging AS
SELECT
  character_id,
  character_key,
  -- using a temporary id to be able to insert to the dimension table later
  CAST(null AS INT) AS staging_id,
  name,
  class,
  race,
  weapon,
  valid_from,
  valid_to,
  CAST(null AS STRING) AS change_type
FROM dim_characters
WHERE valid_to = DATE('9999-12-31')
;

-- merging the source data with the staging table
MERGE INTO dim_characters_staging AS target
USING source_characters AS source
ON target.character_id = source.character_id
-- updating to the newest weapon
WHEN MATCHED AND target.weapon != source.weapon THEN
UPDATE SET
target.weapon=source.weapon,
target.change_type='Modified'
-- deleting the rows where the weapon is the same
WHEN MATCHED AND target.weapon = source.weapon THEN
DELETE
;

/* duplicating the modified rows in order to have one record with the original id also
   to be able to update the valid to date in the dimension table */
INSERT INTO dim_characters_staging
SELECT
  character_id,
  character_key,
  character_id AS staging_id,
  name,
  class,
  race,
  weapon,
  valid_from,
  valid_to,
  change_type
FROM dim_characters_staging
WHERE change_type='Modified'
;

-- merging the dimension table with the staging table
MERGE INTO dim_characters AS target
USING dim_characters_staging AS source
ON target.character_id = source.staging_id
-- if there's a match with a modified flag than update the valid to field
WHEN MATCHED AND source.change_type = 'Modified' THEN
UPDATE SET
target.valid_to = CURRENT_DATE()-1
-- if there's no match insert a new row with the new weapon
WHEN NOT MATCHED THEN
INSERT (character_id, character_key, name, class, race, weapon, valid_from, valid_to)
VALUES
(source.character_id, HASH(source.character_id, source.weapon), source.name, source.class, source.race, source.weapon, CURRENT_DATE(), DATE('9999-12-31'))
;

SELECT
  *
FROM dim_characters