#Basic Insights
SELECT COUNT(DISTINCT Keyword), COUNT(DISTINCT Headline), COUNT(DISTINCT Line_1), COUNT(DISTINCT Line_2)
FROM ringtones;

#What keywords should be dropped?
SELECT Keyword, Line_1, COUNT(*), SUM(Profit), AVG(Profit)
FROM ringtones
GROUP BY 1,2
HAVING avg_profit > (
	SELECT avg(Profit)
	FROM ringtones)
ORDER BY 3;

#metrics though out the week (on day of week)
SELECT AVG(Impressions),AVG(Clicks),AVG(actioncount),AVG(Revenue), AVG(Profit), AVG(Revenue)/AVG(Clicks) as revenue_per_click
,CAST(dayofweek(CONCAT(CONCAT(CONCAT(CONCAT('20',right(Date,2)),'/')),LEFT(Date, (LENGTH(Date)-3)))) AS CHAR) AS DayofWeek
FROM ringtones
GROUP BY DayofWeek
ORDER BY DayofWeek;

#Assign ranks on profitability, then group data into 4 quartiels based on ranknig.
WITH cte AS(
	WITH cte1 AS (
	SELECT Keyword, COUNT(*), SUM(Profit) AS total_profit, AVG(Profit) AS avg_profit, RANK() OVER (ORDER BY AVG(Profit) DESC) AS Ranking
	FROM ringtones
	GROUP BY 1
	ORDER BY 3 DESC) #Assign ranking
    
	SELECT Keyword, total_profit, avg_profit, Ranking,
	CASE
		WHEN Ranking between 1 and 10 THEN 'Quartile1'
		WHEN Ranking between 11 and 20 THEN 'Quartile2'
		WHEN Ranking between 21 and 30 THEN 'Quartile3'
		ELSE 'Quartile4'
	END AS Profit_Performance #Assign Quartiles
	FROM cte1
	GROUP BY 1
	ORDER BY 3 DESC)
    
SELECT Profit_Performance, Keyword,avg(Position),avg(Cost), avg(Impressions), avg(Competition), avg(Volume), sum(if_line1_phone),sum(if_line2_phone)
FROM ringtones AS r
INNER JOIN cte AS c
USING (Keyword)
GROUP BY 1,2;

#Assign rank and see position difference
WITH cte AS (
	SELECT Keyword, COUNT(*), sum(Profit) AS total_profit, AVG(Profit) AS avg_profit, RANK() OVER (ORDER BY AVG(Profit) DESC) AS Ranking
	FROM ringtones
	GROUP BY 1
	ORDER BY 3 DESC)
    
SELECT Ranking, AVG(Position), AVG(Cost), AVG(Impressions)
FROM ringtones as r
INNER JOIN cte as c
USING (Keyword)
GROUP BY Ranking;

#conversion rate (efficiency) rank where clicks greater than median
SELECT Headline, Line_1, AVG(actioncount/Clicks) AS avg_efficiency, sum(Clicks), Sum(actioncount), count(*)
FROM ringtones
GROUP BY 1,2
HAVING sum(Clicks) > 18.5 #median
ORDER BY avg_efficiency DESC;

#conversion rate approach 2
SELECT Headline, Line_1, Sum(actioncount)/sum(Clicks) as avg_efficiency, count(*)
FROM ringtones
GROUP BY 1,2
HAVING sum(Clicks) > 18.5 #median
ORDER BY avg_efficiency DESC;






