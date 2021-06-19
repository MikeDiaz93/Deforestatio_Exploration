--APPENDIX : SQL queries used

/*Create View deforestation */
CREATE VIEW deforestation  AS
SELECT f.country_code, f.country_name, r.region, 
	f.forest_area_sqkm,(l.total_area_sq_mi * 2.59) AS total_area_sqkm, 		
	(100.0* f.forest_area_sqkm / 
    (l.total_area_sq_mi * 2.59)) AS land_percentage,
    r.income_group, f.year
FROM forest_area f
JOIN land_area l
	ON f.country_code = l.country_code
	    AND f.year = l.year 
JOIN regions r
	ON r.country_code = f.country_code;


--PART 1: Global Situation 

--a 
SELECT *
FROM forest_area
WHERE country_name = 'World'
AND (year = 1990);

--b
SELECT *
FROM forest_area
WHERE country_name = 'World'
AND (year = 2016);

--c 
SELECT c.forest_area_sqkm - p.forest_area_sqkm
	AS change_area
FROM forest_area AS p
JOIN forest_area AS c
	ON (p.year = '1990' and c.year = '2016'
        AND p.country_name = 'World'
        AND c.country_name = 'World');

--d
SELECT 100.0*((c.forest_area_sqkm -p.forest_area_sqkm) /
        p.forest_area_sqkm) AS change_area
FROM forest_area AS p
JOIN forest_area AS c
	ON (p.year = '1990' and c.year = '2016'
        AND p.country_name = 'World'
        AND c.country_name = 'World');

--e
SELECT country_name, total_area_sqkm
FROM deforestation
WHERE year = 2016 
ORDER BY total_area_sqkm DESC;


--Part 2: Regional Outlook

--a 
SELECT land_percentage
FROM deforestation 
WHERE country_name = 'World'
AND year = '2016';

--b 
SELECT land_percentage
FROM deforestation 
WHERE country_name = 'World'
AND year = '1990';

--c
SELECT 
	ROUND(CAST((forest_area_1990/ total_area_1990) * 100 
	AS NUMERIC),2) AS forest_perc_1990,
    ROUND(CAST((forest_area_2016 / total_area_2016) * 100 
    AS NUMERIC), 2) AS forest_perc_2016, region  
FROM 
   (SELECT SUM(x.forest_area_sqkm) forest_area_1990,
    SUM(x.total_area_sqkm) total_area_1990, x.region, 
    SUM(y.forest_area_sqkm) forest_area_2016,
    SUM(y.total_area_sqkm) total_area_2016
FROM deforestation x, deforestation y
WHERE x.year = '1990'
	AND x.country_name != 'World'
	AND y.year = '2016'
	AND y.country_name!= 'World'
	AND x.region = y.region
GROUP BY x.region) world_regions
ORDER BY forest_perc_1990 DESC;


--Country-Level Detail 

--a 
SELECT new.country_name AS top_counties_with_largest_amount_decrease,  
    (new.forest_area_sqkm - bef.forest_area_sqkm) AS forest_difference
FROM forest_area AS new
JOIN forest_area AS bef
    ON  (bef.year = '1990' AND new.year = '2016')
  	    AND new.country_name = bef.country_name
        WHERE new.forest_area_sqkm IS NOT NULL 
            AND bef.forest_area_sqkm IS NOT NULL 
            AND new.country_name != 'World' 
            AND bef.country_name != 'World'
ORDER BY forest_difference LIMIT 5;

--b 
SELECT new.country_name AS top_countires_with_largest_percent_decrease, 
    (100*(new.forest_area_sqkm - bef.forest_area_sqkm) /
        bef.forest_area_sqkm) AS forest_difference_percentage
FROM forest_area AS now
JOIN forest_area AS bef
    ON  (bef.year = '1990' AND now.year = '2016')
  	    AND new.country_name = bef.country_name
        WHERE new.forest_area_sqkm IS NOT NULL 
            AND bef.forest_area_sqkm IS NOT NULL 
            AND new.country_name != 'World' 
            AND bef.country_name != 'World'
ORDER BY forest_difference_percentage LIMIT 5;

--c
SELECT distinct(quartiles), COUNT(country_name) 
    OVER (PARTITION BY quartiles) AS countries
    FROM (SELECT country_name,
        CASE WHEN land_percentage <= 25 THEN '0-25%'
        WHEN land_percentage <= 75 AND land_percentage > 50 THEN '50-75%'
        WHEN land_percentage <= 50 AND land_percentage > 25 THEN '25-50%'
        ELSE '75-100%' END AS quartiles 
FROM deforestation
WHERE (land_percentage IS NOT NULL AND year = 2016)) quart;

--d
SELECT country_name, region, land_percentage
FROM deforestation
WHERE (year = 2016 AND land_percentage > 75)
ORDER BY land_percentage DESC;

--e

SELECT new.country_name, 
    (new.forest_area_sqkm - bef.forest_area_sqkm) AS forest_difference
FROM forest_area AS new
JOIN forest_area AS bef
  	ON  (bef.year = '1990' AND new.year = '2016')
  	    AND new.country_name = bef.country_name
    WHERE new.forest_area_sqkm IS NOT NULL 
        AND bef.forest_area_sqkm IS NOT NULL
ORDER BY forest_difference DESC LIMIT 3;

SELECT new.country_name, 
  (100*(new.forest_area_sqkm - bef.forest_area_sqkm) /
    bef.forest_area_sqkm) AS forest_proportion_change
FROM forest_area AS now
JOIN forest_area AS bef
  	ON (bef.year = '1990' AND now.year = '2016')
  	    AND new.country_name = bef.country_name
        WHERE new.forest_area_sqkm IS NOT NULL 
            AND bef.forest_area_sqkm IS NOT NULL
ORDER BY forest_proportion_change DESC LIMIT 3;
