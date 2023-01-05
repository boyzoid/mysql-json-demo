-- slide 9
CREATE TABLE `season` (
      `id` int NOT NULL AUTO_INCREMENT,
      `league_id` int NOT NULL,
      `name` varchar(100) NOT NULL,
      `start_date` date DEFAULT NULL,
      `season_settings` json DEFAULT NULL,
      CHECK(
        JSON_SCHEMA_VALID('
            {
                "type": "object",
                "properties":{
                    "leagueFees": {
                        "type":"number", "minimum":0
                    }
                }
            }
        ', season_settings)
      ),
      PRIMARY KEY (`id`)
);
-- end slide 9

-- slide 10
INSERT INTO season (name,
	start_date,
	league_id,
	season_settings
)
VALUES( 'My Test League',
    now(),
    1,
    '{}'
);
-- end slide 10

-- slide 12
SELECT JSON_PRETTY(
	JSON_KEYS(season_settings)
)
FROM season
WHERE id = 23;
-- end slide 12

-- slide 13
SELECT JSON_PRETTY(
   JSON_KEYS(season_settings, "$.scoring")
)
FROM season
WHERE id = 23;
-- end slide 13

-- slide 15
SELECT `id`,
	`name`,
	JSON_VALUE(
	    season_settings,
	    "$.leagueFee"
	) league_fee
FROM season
WHERE JSON_CONTAINS(
	season_settings,
	"70",
	"$.leagueFee"
);
-- end slide 15

-- slide 16
SELECT `id`,
       `name`,
       JSON_ARRAYAGG( jt1.role) sub_roles
FROM season,
     JSON_TABLE(
		     season_settings,
		     "$.subPool[*]" COLUMNS(
			     subType NVARCHAR(20) PATH '$.type',
			     role NVARCHAR(20) PATH '$.name'
			     )
	     ) as jt1
WHERE
	jt1.subType = 'role'
    AND
    JSON_CONTAINS(
		season_settings,
		'"Charles Town"',
		"$.course.city"
	)
GROUP BY season.id;

-- end slide 16

-- slide 17
SELECT `id`,
	`name`,
	JSON_VALUE(
		season_settings,
		"$.greensFees"
		RETURNING DECIMAL(4,2)
		) AS greens_fees
FROM season
WHERE JSON_VALUE(
	season_settings,
	"$.course.state"
) = 'WV';

-- end slide 17

-- slide 18
SELECT `id`,
	`name`,
	season_settings->"$.course.name"
	    AS course_name,
	season_settings->>"$.course.city"
	    AS course_city
FROM season
order by id desc limit 5;
-- end slide 18

-- slide 21
UPDATE season
SET
season_settings =
JSON_INSERT(
	season_settings,
	"$.leagueFee",
	25.50
);

-- end slide 21

-- slide 22
UPDATE season
SET
season_settings =
JSON_REPLACE(
	season_settings,
	"$.golfersPerTeam",
	4
);
-- end slide 22

-- slide 23
UPDATE season
SET
season_settings =
JSON_SET(
	season_settings,
	"$.golfersPerTeam",
	2
);

-- end slide 23

-- slide 24
UPDATE season
SET
season_settings =
JSON_REMOVE(
	season_settings,
	"$.golfersPerTeam"
);
-- end slide 24

-- slide 26
SELECT
	JSON_PRETTY(
	   JSON_OBJECT( 'id', id,
			'name', name,
			'leagueId', league_id,
			'startDate', start_date,
			'seasonSettings', season_settings
        )
	) AS season_info
from season where id = 24;
-- end slide 26

-- slide 27
SELECT JSON_PRETTY(
   JSON_ARRAYAGG(
       JSON_OBJECT( 'id', id,
	        'name', name,
	        'leagueId', league_id,
	        'startDate', start_date)
   )
) seasons
FROM season
WHERE id in (23,24)
ORDER BY start_date DESC;
-- end slide 27

-- slide 28
SELECT name,
    season_settings->>"$.course.name" course_name,
    CAST(
        season_settings->>"$.greensFees"
        AS DECIMAL(4,2)
    ) greens_fees,
    season_settings->>"$.scoring.handicapType" hcp_type
FROM season
WHERE year(start_date) >2019
ORDER BY start_date DESC;
-- end slide 28


-- Slide 30
explain select * from season where season_settings->>'$.course.name' = 'Locust Hill Golf Course'\G
-- end slide 30

-- Slide 32
ALTER TABLE season ADD INDEX course_name ((CAST(season_settings->>'$.course.name' as CHAR(255)) COLLATE utf8mb4_bin));
-- end slide 32

-- Slide 33
show indexes from season\G
-- end slide 33

-- Slide 35
explain select * from season where season_settings->>'$.course.name' = 'Locust Hill Golf Course'\G
-- end slide 35
