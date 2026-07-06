select * from fifa_26

SELECT COUNT(*) AS total_rows
FROM fifa_26;

SELECT *
FROM fifa_26
LIMIT 5;

SELECT DISTINCT player_id
FROM fifa_26
LIMIT 5;


SELECT DISTINCT match_id
FROM fifa_26
LIMIT 5;



SELECT DISTINCT clean_sheet
FROM fifa_26;


ALTER TABLE fifa_26
ALTER COLUMN age TYPE INTEGER USING age::INTEGER,
ALTER COLUMN jersey_number TYPE INTEGER USING jersey_number::INTEGER,
ALTER COLUMN height_cm TYPE INTEGER USING height_cm::INTEGER,
ALTER COLUMN weight_kg TYPE INTEGER USING weight_kg::INTEGER,
ALTER COLUMN goals TYPE INTEGER USING goals::INTEGER,
ALTER COLUMN assists TYPE INTEGER USING assists::INTEGER,
ALTER COLUMN shots TYPE INTEGER USING shots::INTEGER,
ALTER COLUMN shots_on_target TYPE INTEGER USING shots_on_target::INTEGER,
ALTER COLUMN tackles TYPE INTEGER USING tackles::INTEGER,
ALTER COLUMN interceptions TYPE INTEGER USING interceptions::INTEGER,
ALTER COLUMN yellow_cards TYPE INTEGER USING yellow_cards::INTEGER,
ALTER COLUMN red_cards TYPE INTEGER USING red_cards::INTEGER;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'fifa_26'
ORDER BY ordinal_position;

ALTER TABLE fifa_26
ALTER COLUMN match_date
TYPE DATE
USING match_date::DATE;

--How many players, teams, clubs, stadiums, and matches are present in the dataset?
select 
count(distinct(player_name)) as players,
count(distinct(team)) as teams ,
count(distinct(stadium)) as stadiums,
count(distinct(match_id)) as matches
from fifa_26 


--. What are the different tournament stages, and how many matches were played in each stage?

select count(match_id) from fifa_26

select  tournament_stage as stages, count(match_id) as matches from fifa_26
group by  tournament_stage

--. What is the distribution of players by position?

select distinct(position) from fifa_26

select position , count(distinct(player_id)) as players_total from fifa_26
group by position

-- Which countries contributed the most players?

select * from fifa_26

select team as country ,count(player_name) as total_player from fifa_26
group by team
order by count(player_name) desc
limit 1



--Which clubs contributed the most players to the World Cup?

select * from fifa_26

select club_name as club ,count(player_name) as total_player from fifa_26
group by club_name
order by count(player_name) desc
limit 1








----------correcting the column data-------------------------------------------
CREATE TABLE fifa_backup AS
SELECT * FROM fifa_26
WITH NO DATA;

UPDATE fifa_26 f
SET player_of_match_awards = b.player_of_match_awards
FROM fifa_backup b
WHERE f.player_id = b.player_id
  AND f.match_id = b.match_id;

select * from fifa_26
----****************************************----------------------------------------------------


--9. Which players received the most Player of the Match awards?

select * from fifa_26



select player_name,team,sum(player_of_match_awards) as potm_awards
from fifa_26
group by player_name,team
order by potm_awards desc
limit 10




-----10. Which players played the most minutes?


select * from fifa_26


ALTER TABLE fifa_26
ALTER COLUMN minutes_played
TYPE integer
USING minutes_played::integer;


select player_name,sum(minutes_played) as total_min_played
from fifa_26
group by player_name
order by total_min_played
limit 1


--11. Which players have the highest tournament rating?

select * from fifa_26


ALTER TABLE fifa_26
ALTER COLUMN tournament_rating
TYPE numeric
USING tournament_rating::numeric;

select player_name,max(tournament_rating) as highest_rating_player
from fifa_26
group by player_name
order by highest_rating_player 
limit 1

--12. Which players have the best goal conversion rate?

select * from fifa_26

select player_name,
sum(goals) as total_goals,
sum(shots) as total_shots,
round((sum(goals)::NUMERIC/nullif(sum(shots),0))*100,2) as
conversion_rate
from fifa_26
group by player_name
having sum(shots)>=10
order by conversion_rate desc, total_goals desc
limit 10


 --13. Which teams scored the most goals?

ALTER TABLE fifa_26
ALTER COLUMN goals_team
TYPE integer
USING goals_team::integer;


select team, sum(goals_team) as total_goals 
from (select distinct match_id,team,goals_team from fifa_26) as matches
group by team
order by total_goals desc
limit 1





---14. Which teams conceded the fewest goals?

select * from fifa_26

ALTER TABLE fifa_26
ALTER COLUMN goals_opponent
TYPE integer
USING goals_opponent::integer;

select team,sum(goals_opponent) as conceded_goals 
from 
(select distinct match_id,team,goals_opponent from fifa_26) as matches
group by team 
order by conceded_goals
limit 1

--15. Which teams have the highest average player rating?


select team,round(avg(player_rating),2) as avg_player_rarting 
from fifa_26
group by team
order by avg_player_rarting desc
limit 1


--16.Which teams completed the most successful passes?


select * from fifa_26

alter table fifa_26
alter column successful_passes 
type integer
using successful_passes::integer


select team , sum(successful_passes) as total_successful_passes from fifa_26
group by team
order by total_successful_passes desc
limit 1

---17. Which teams created the most attacking chances?

select * from fifa_26

SELECT
    team,
    SUM(shots) AS total_shots,
    SUM(shots_on_target) AS total_shots_on_target,
    ROUND(SUM(expected_goals_xg), 2) AS total_xg,
    ROUND(
        SUM(shots) +
        SUM(shots_on_target) +
        SUM(expected_goals_xg),
        2
    ) AS attacking_chances
FROM fifa_26
GROUP BY team
ORDER BY attacking_chances DESC
LIMIT 10;

ALTER TABLE fifa_26
ALTER COLUMN expected_goals_xg
TYPE NUMERIC
USING expected_goals_xg::NUMERIC;


---18. Which teams committed the most fouls and received the most cards?

select * from fifa_26

ALTER TABLE fifa_26
ALTER COLUMN fouls_committed
TYPE integer
USING fouls_committed::integer;

select team , sum(fouls_committed) as fouls, sum(yellow_cards) as total_yellow_card,
sum(red_cards) as total_red_card,sum(red_cards)+sum(yellow_cards) as total_cards from fifa_26
group by team
order by fouls desc,total_cards desc
limit 1


---19. Which players outperformed their Expected Goals (xG)?

select * from fifa_26

select player_name,team,  sum(goals) as total_goal,
round(sum(expected_goals_xg),2) as total_xg ,
 sum(goals) - round(sum(expected_goals_xg),2) as goals_minus_gx
from fifa_26
group by player_name, team
HAVING SUM(goals) >= 5
order by  goals_minus_gx desc


---19.Which players are the best passers?

select * from fifa_26

select player_name, team , sum(successful_passes) as total_suc_pass, 
round(avg(pass_accuracy),2) as total_accuracy 
from fifa_26
group by player_name, team 
having sum(successful_passes) >=100
order by total_suc_pass desc, total_accuracy desc
limit 10

ALTER TABLE fifa_26
ALTER COLUMN pass_accuracy
TYPE NUMERIC
USING pass_accuracy ::NUMERIC;

--22. Which defenders contributed the most defensively?

select * from fifa_26

ALTER TABLE fifa_26
ALTER COLUMN blocks
TYPE integer
USING blocks ::integer


select player_name,team,position ,sum(tackles)as total_tackle
,sum(interceptions) as total_interception,sum(clearances) as total_clearances
,sum(blocks) as total_blocks
,sum(tackles) + sum(interceptions) + sum(clearances) + sum(blocks) as total_comtribution
from fifa_26
where position = 'Defender'
group by player_name,team,position
order by total_comtribution desc
limit 10


--25. Rank players within each team based on total goals.
select player_name,team,sum(goals) as total_goals,
dense_rank () over(partition by team order by sum(goals)desc) as rank
from fifa_26
group by player_name,team
order by team,rank

---26. Find the highest-rated player from each country.



select player_name,team,total_rating
from
(select player_name,team,round(avg(tournament_rating),2) as total_rating,
rank() over( partition by team order by avg(tournament_rating) desc ) as rank
from fifa_26
group by player_name,team) as ranked_player
where rank =1
order by  team


--27. Rank teams by average performance score.

select * from fifa_26

alter table fifa_26
alter column performance_score
type numeric
using performance_score::numeric


select team , round(avg(performance_score),3) as avg_performance_rating,
dense_rank() over(order by avg(performance_score) desc) as ranking
from fifa_26 
group by team


--28. Find the Top 3 players from each position based on tournament rating


select * from fifa_26

select player_name,position,avg_tour_rating,rank from 
(select player_name,position,round(avg(tournament_rating),3) as avg_tour_rating ,
dense_rank() over(partition by position order by avg(tournament_rating) desc) as rank from fifa_26
group by player_name,position) as rank_table 
where rank <= 3




--29. Build a "World Cup Best XI"
----Choose the best:
--•	1 Goalkeeper 
--•	4 Defenders 
--•	3 Midfielders 
--•	3 Forwards 

with cte_1 as(
select player_name,position,round(avg(player_rating),3) as avg_tour_rating ,
dense_rank() over(partition by position order by avg(player_rating) desc) as rank 
from (select * from fifa_26 where position = 'Goalkeeper')
group by player_name,position
limit 1
)
,
cte_2 as (
select player_name,position,round(avg(player_rating),3) as avg_tour_rating ,
dense_rank() over(partition by position order by avg(player_rating) desc) as rank 
from (select * from fifa_26 where position = 'Defender')
group by player_name,position
limit 4
)
,
cte_3 as (
select player_name,position,round(avg(player_rating),3) as avg_tour_rating ,
dense_rank() over(partition by position order by avg(player_rating) desc) as rank 
from (select * from fifa_26 where position = 'Midfielder')
group by player_name,position
limit 3
)
,
cte_4 as(
select player_name,position,round(avg(player_rating),3) as avg_tour_rating ,
dense_rank() over(partition by position order by avg(player_rating) desc) as rank 
from (select * from fifa_26 where position = 'Forward')
group by player_name,position
limit 3
)

SELECT player_name,position
FROM cte_1

UNION ALL

SELECT player_name,position
FROM cte_2

UNION ALL

SELECT player_name,position
FROM cte_3

UNION ALL

SELECT player_name,position
FROM cte_4


--30. Create a custom Player Performance Index (PPI)
--Design your own KPI, for example:
--PPI =
--30% Player Rating
--+ 25% Performance Score
--+ 20% Goals
--+ 10% Assists
--+ 10% Pass Accuracy
--+ 5% Defensive Contribution

SELECT
    player_name,
    team,

    ROUND(AVG(player_rating),2) AS avg_player_rating,
    ROUND(AVG(performance_score),2) AS avg_performance_score,

    SUM(goals) AS total_goals,
    SUM(assists) AS total_assists,

    ROUND(AVG(pass_accuracy),2) AS avg_pass_accuracy,

    SUM(tackles + interceptions + clearances + blocks)
        AS defensive_contribution,

    ROUND(
        (AVG(player_rating) * 0.30) +
        (AVG(performance_score) * 0.25) +
        (SUM(goals) * 0.20) +
        (SUM(assists) * 0.10) +
        (AVG(pass_accuracy) * 0.10) +
        ((SUM(tackles + interceptions + clearances + blocks)) * 0.05)
    ,2) AS ppi

FROM fifa_26

GROUP BY player_name, team

ORDER BY ppi DESC
LIMIT 10;













