-- slide 10
CREATE TABLE season (
	`id` int NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`season_settings` JSON,
	`start_date` DATE,
	`league_id` int NOT NULL,
	PRIMARY KEY (`id`)
);
-- end slide 10

-- slide 11
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
-- end slide 11

-- slide 12
SELECT JSON_KEYS(season_settings)
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
SELECT `id`, `name`
FROM season
WHERE JSON_CONTAINS(season_settings, "70", "$.Leaguefee");
-- end slide 15

-- slide 16
SELECT `id`, `name`
FROM season
WHERE JSON_CONTAINS(season_settings, "70", "$.Leaguefee");
-- end slide 16

-- slide 17
SELECT `id`, `name`
FROM season
WHERE JSON_CONTAINS(season_settings, "70", "$.Leaguefee");
-- end slide 17

-- slide 20
UPDATE season
SET season_settings = JSON_INSERT(season_settings, "$.aceInsurance", 10 );
-- end slide 20

-- slide 21
UPDATE season
SET season_settings = JSON_REPLACE(season_settings, "$.golfersPerTeam", 4 );
-- end slide 21

-- slide 22
UPDATE season
SET season_settings = JSON_SET(season_settings, "$.rules", JSON_ARRAY() );
-- end slide 22

-- slide 23
UPDATE season
SET season_settings = JSON_REMOVE(season_settings, "$.aceInsurance" );
-- ens slide 23

-- slide 25
SELECT JSON_PRETTY(
	   JSON_OBJECT( 'id', id,
	        'name', name,
	        'leagueId', league_id,
	        'startDate', start_date,
	        'seasonSettings', season_settings)
	)
from season where id = 24;
-- end slide 25

-- slide 26
SELECT JSON_PRETTY(
   JSON_ARRAY(
       JSON_OBJECT( 'id', id,
	        'name', name,
	        'leagueId', league_id, 'startDate', start_date)
   )
) seasons
FROM season
WHERE id in (23,24)
ORDER BY start_date DESC;
-- end slide 26

-- slide 27
SELECT name, start_date,
       season_settings->>"$.Course.Name" course_name,
       CAST(season_settings->>"$.Greensfees" AS DECIMAL(4,2)) greens_fees
FROM season
WHERE year(start_date) >2019
ORDER BY start_date DESC
-- end slide 27

-- slide 44
	with rounds as (
	select doc->> '$.firstName' as firstName,
	       doc->> '$.lastName' as lastName,
	       doc->> '$.score' * 1 as score,
	       doc->> '$.course.name' as courseName,
	       doc->> '$.date' as datePlayed
	from round ),
     roundsAgg as ( select courseName, min( score ) lowScore from rounds group by courseName )
select  JSON_PRETTY(JSON_OBJECT(
		'courseName', ra.courseName,
		'score', ra.lowScore,
		'golfers', ( select JSON_ARRAYAGG(JSON_OBJECT('golfer', concat(r.firstName, ' ', r.lastName), 'datePlayed', r.datePlayed ) )
		             from rounds r
		             where r.score = ra.lowScore and r.courseName = ra.courseName )
	) ) as data
from roundsAgg ra
group by ra.courseName
order by ra.courseName;
-- end slide 44
