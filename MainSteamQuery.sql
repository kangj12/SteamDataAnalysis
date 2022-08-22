-- Data Exploration

-- Checking first 10 rows in Games relation
SELECT TOP 10 * 
FROM Games;

-- Checking for null values in Games table
SELECT * 
FROM Games 
WHERE COALESCE(appid, name, release_date, english, developer, publisher, platforms, required_age, categories, genres, steamspy_tags, achievements, positive_ratings, negative_ratings,
average_playtime, median_playtime, owners, price) IS NULL;

-- Checking data types of each column
SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Games';

-- Adding overall_ratings column
ALTER TABLE Games
ADD overall_ratings FLOAT;

UPDATE Games 
SET overall_ratings = positive_ratings / (positive_ratings+negative_ratings) * 100;

-- Looking at the genre, I decided to reduce the analysis of genres into 6 distinct categories as there were too many categories: Action, Sports, Adventure, RPG, Strategy, and Casual
ALTER TABLE Games 
ADD Action VARCHAR(3),
	Sports VARCHAR(3),
	Adventure VARCHAR(3), 
	RPG VARCHAR(3),
	Strategy VARCHAR(3),
	Casual VARCHAR(3);

-- Adding 'Yes' or 'No' based on if a game is within the genre for each genre
UPDATE Games 
SET Action = (CASE 
				WHEN CHARINDEX('Action', genres) <> 0 THEN 'Yes'
				ELSE 'No'
				END),

Sports = (CASE
			WHEN CHARINDEX('Sports', genres) <> 0 THEN 'Yes'
			ELSE 'No'
			END),

Adventure = (CASE 
				WHEN CHARINDEX('Adventure', genres) <> 0 THEN 'Yes'
				ELSE 'No'
				END),

RPG = (CASE 
			WHEN CHARINDEX('RPG', genres) <> 0 THEN 'Yes'
			ELSE 'No'
			END),

Strategy = (CASE
				WHEN CHARINDEX('Strategy', genres) <> 0 THEN 'Yes'
				ELSE 'No'
				END),

Casual = (CASE 
				WHEN CHARINDEX('Casual', genres) <> 0 THEN 'Yes'
				ELSE 'No'
				END);
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Data Preparation

-- At this step, I will be creating tables for each genre of games and remove games with less than 100 review_counts for larger sample size for overall_ratings

--Creating a relation for action games
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, Action  
INTO action_games 
FROM Games 
WHERE Action = 'Yes';

SELECT * FROM action_games
ORDER BY overall_ratings DESC;

DELETE FROM action_games 
WHERE review_count < 100;

-- Relation for sport games
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, Sports  
INTO sport_games 
FROM Games 
WHERE Sports = 'Yes';

SELECT * FROM sport_games
ORDER BY overall_ratings DESC;

DELETE FROM sport_games
WHERE review_count < 100;

-- Relation for adventure games 
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, Adventure  
INTO adventure_games 
FROM Games 
WHERE Adventure = 'Yes';

SELECT * FROM adventure_games
ORDER BY overall_ratings DESC;

DELETE FROM adventure_games 
WHERE review_count < 100;

-- Relation for RPGs 
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, RPG  
INTO rpg_games 
FROM Games 
WHERE RPG = 'Yes';

SELECT * FROM rpg_games 
ORDER BY overall_ratings DESC;

DELETE FROM rpg_games 
WHERE review_count < 100;

-- Relation for Strategy
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, Strategy  
INTO strategy_games  
FROM Games 
WHERE Strategy = 'Yes';

SELECT * FROM strategy_games
ORDER BY overall_ratings DESC;

DELETE FROM strategy_games 
WHERE review_count < 100;

-- Relation for Casual 
SELECT appid, name, release_date, genres, positive_ratings + negative_ratings AS review_count, overall_ratings, price, Casual 
INTO casual_games
FROM Games 
WHERE Casual = 'Yes';

SELECT * FROM casual_games 
ORDER BY overall_ratings DESC;

DELETE FROM casual_games 
WHERE review_count < 100;


-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Queries to use for Tableau Data Visualization

-- 1. Most populated genres
SELECT (
	SELECT SUM(review_count)
	FROM action_games 
) AS total_action_games,
(
	SELECT SUM(review_count)
	FROM sport_games
) AS total_sport_games,
(
	SELECT SUM(review_count)
	FROM adventure_games 
) AS total_adventure_games,
(
	SELECT SUM(review_count)
	FROM rpg_games 
) AS total_rpg_games,
(
	SELECT SUM(review_count)
	FROM strategy_games 
) AS total_strategy_games,
(
	SELECT SUM(review_count)
	FROM casual_games 
) AS total_casual_games

-- 2. Top 10 developers
SELECT TOP 10 developer, COUNT(*) AS total_games_developed
FROM Games 
GROUP BY developer 
ORDER BY 2 DESC;

-- 3. Top 10 publishers
SELECT TOP 10 publisher, COUNT(*) AS total_games_published
FROM Games 
GROUP BY publisher
ORDER BY 2 DESC;

-- 4. English vs No English Games
SELECT english, COUNT(*) AS total_games
FROM Games
GROUP BY english;

-- 5. Most highly rated genres
SELECT (
	SELECT AVG(overall_ratings)
	FROM action_games 
) AS action_rating,
(
	SELECT AVG(overall_ratings)
	FROM sport_games
) AS sport_rating,
(
	SELECT AVG(overall_ratings)
	FROM adventure_games 
) AS adventure_rating,
(
	SELECT AVG(overall_ratings)
	FROM rpg_games 
) AS rpg_rating,
(
	SELECT AVG(overall_ratings)
	FROM strategy_games 
) AS strategy_rating,
(
	SELECT AVG(overall_ratings)
	FROM casual_games 
) AS casual_rating;

-- 6. Free vs Non-free Games 
SELECT (
	SELECT COUNT(*) 
	FROM Games 
	WHERE price = 0
) AS free_games_count,
(
	SELECT COUNT(*)
	FROM Games 
	WHERE price <> 0
) AS non_free_games_count;

-- Average playtime for each genre of games
SELECT (
	SELECT AVG(average_playtime)
	FROM Games
	WHERE Action = 'Yes'
) AS action_avg_gametime,
(
	SELECT AVG(average_playtime)
	FROM Games
	WHERE Sports = 'Yes'
) AS sport_avg_gametime,
(
	SELECT AVG(average_playtime)
	FROM Games
	WHERE Adventure = 'Yes'
) AS adventure_avg_gametime,
(
	SELECT AVG(average_playtime)
	FROM Games
	WHERE RPG = 'Yes'
) AS rpg_avg_gametime,
(
	SELECT AVG(average_playtime)
	FROM Games
	WHERE Strategy = 'Yes'
) AS strategy_avg_gametime,
(
	SELECT AVG(average_playtime)
	FROM Games
	WHERE Casual = 'Yes'
) AS casual_avg_gametime;

-- 8. Top 30 games with review count of over 100,000
SELECT TOP 30 name, (positive_ratings + negative_ratings) AS total_ratings, overall_ratings, price, genres
FROM Games 
WHERE (positive_ratings + negative_ratings) > 100000
ORDER BY overall_ratings DESC;


-- 9. Worst 10 games with review count of over 100,000
SELECT TOP 10 name, (positive_ratings + negative_ratings) AS total_ratings, overall_ratings, price, genres
FROM Games 
WHERE (positive_ratings + negative_ratings) > 100000
ORDER BY overall_ratings;

-- 10. Game with ratings vs no ratings
SELECT (
	SELECT COUNT(*)
	FROM Games 
	WHERE required_age = 0
) AS no_age_requirement,
(	SELECT COUNT(*)
	FROM Games 
	WHERE required_age <> 0
) AS age_requirement;

-- 11. Separating the age_requirements into categories: '18+', '16+', '12+', '7+', '3+'
SELECT (
	SELECT COUNT(*)
	FROM Games 
	WHERE required_age = '3'
) AS '3+',
(	SELECT COUNT(*)
	FROM Games 
	WHERE required_age = '7'
) AS '7+',
(	SELECT COUNT(*)
	FROM Games 
	WHERE required_age = '12'
) AS '12+',
(	SELECT COUNT(*) 
	FROM Games 
	WHERE required_age = '16'
) AS '16+',
(	SELECT COUNT(*)
	FROM Games 
	WHERE required_age = '18'
) AS '18+';