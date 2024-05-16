
--sneak peek on the data
SELECT * FROM dbo.[Corona Virus Dataset]

--get the null values 
SELECT *
FROM dbo.[Corona Virus Dataset]
WHERE Province IS NULL
	OR [Country Region] IS NULL 
	OR Latitude IS NULL
	OR Longitude IS NULL
	OR [Date] IS NULL
	OR Confirmed IS NULL
	OR Deaths IS NULL
	OR Recovered IS NULL;

-- double check the nulls by counting
SELECT COUNT(*) AS NULLS
FROM dbo.[Corona Virus Dataset]
WHERE Province IS NULL
	OR [Country Region] IS NULL 
	OR Latitude IS NULL
	OR Longitude IS NULL
	OR [Date] IS NULL
	OR Confirmed IS NULL
	OR Deaths IS NULL
	OR Recovered IS NULL;

-- get the total number of rows
SELECT COUNT(*) AS ROWS
FROM dbo.[Corona Virus Dataset];


-- start and end dates
SELECT 
    MIN(TRY_CONVERT(DATE, date, 103)) AS start_date,
    MAX(TRY_CONVERT(DATE, date, 103)) AS end_date
FROM 
    dbo.[Corona Virus Dataset];


-- number of months 
SELECT SUM(months_in_year) AS total_months
FROM (
    SELECT COUNT(DISTINCT MONTH(TRY_CONVERT(DATE, date, 103))) AS months_in_year
    FROM dbo.[Corona Virus Dataset]
    GROUP BY YEAR(TRY_CONVERT(DATE, date, 103))
) AS yearly_months;



-- average for confirmed, deaths, recovered
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
    ROUND(AVG(CAST(Confirmed AS float)), 3) AS AvgConfirmed,
    ROUND(AVG(CAST(Deaths AS float)), 3) AS AvgDeaths,
    ROUND(AVG(CAST(Recovered AS float)), 3) AS AvgRecovered
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103)), MONTH(TRY_CONVERT(DATE, date, 103))
ORDER BY 
    YEAR(TRY_CONVERT(DATE, date, 103)), MONTH(TRY_CONVERT(DATE, date, 103));


-- cleaning a mistake done in the columns because it was loaded as a csv
SELECT *
    FROM 
        dbo.[Corona Virus Dataset]
	WHERE Col IS NOT NULL;

SELECT RIGHT(Col, 1) AS LastCharacter
FROM dbo.[Corona Virus Dataset]
WHERE Col IS NOT NULL;

ALTER TABLE dbo.[Corona Virus Dataset]
DROP COLUMN Col;


ALTER TABLE dbo.[Corona Virus Dataset]
ADD Col VARCHAR(50) 

UPDATE dbo.[Corona Virus Dataset]
SET   Recovered = RIGHT(Col, 1)
WHERE Col IS NOT NULL;


SELECT 
    CHARINDEX(',', Col) AS Comma1,
    CHARINDEX(',', Col, CHARINDEX(',', Col) + 1) AS Comma2,
    CHARINDEX(',', Col, CHARINDEX(',', Col, CHARINDEX(',', Col) + 1) + 1) AS Comma3
FROM 
    dbo.[Corona Virus Dataset]
WHERE 
    Col IS NOT NULL;
-------------------------------------------------------------------------------------



-- most frequent death cases (for the confirmed and recovered cases I was just replacing the column names and running the exact same code)
SELECT Year, Month, MostFrequent
FROM (
    SELECT 
        YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
        MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
        Deaths AS MostFrequent,
        RANK() OVER (PARTITION BY YEAR(TRY_CONVERT(DATE, date, 103)),
								  MONTH(TRY_CONVERT(DATE, date, 103)) 
								  ORDER BY COUNT(*) DESC) AS Rank
    FROM 
        dbo.[Corona Virus Dataset]
    GROUP BY 
        YEAR(TRY_CONVERT(DATE, date, 103)), 
		MONTH(TRY_CONVERT(DATE, date, 103)), 
		Deaths
) AS Data
WHERE 
    Rank = 1
ORDER BY 
    Year, Month;

-- trying the sub query from above
 SELECT 
        YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
        MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
        Confirmed AS MostFrequentConfirmed,
        RANK() OVER (PARTITION BY YEAR(TRY_CONVERT(DATE, date, 103)), MONTH(TRY_CONVERT(DATE, date, 103)) ORDER BY COUNT(*) DESC) AS RankConfirmed
    FROM 
        dbo.[Corona Virus Dataset]
    GROUP BY 
        YEAR(TRY_CONVERT(DATE, date, 103)), MONTH(TRY_CONVERT(DATE, date, 103)), Confirmed


-- counting total number of deaths per month to make sure that the answer is correct 
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
    Deaths,
    COUNT(*) AS Count
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103)),
    MONTH(TRY_CONVERT(DATE, date, 103)),
    Deaths
ORDER BY 
    Year, Month, Deaths;


-- min values for confirmed, deaths, recovered per year
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MIN(CAST(Confirmed AS INT)) AS MinConfirmed,
    MIN(CAST(Deaths AS INT)) AS MinDeaths,
    MIN(CAST(Recovered AS INT)) AS MinRecovered
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103))
ORDER BY 
    Year;

-- max values for confirmed, deaths, recovered per year
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MAX(CAST(Confirmed AS INT)) AS MaxConfirmed,
    MAX(CAST(Deaths AS INT)) AS MaxDeaths,
    MAX(CAST(Recovered AS INT)) AS MaxRecovered
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103))
ORDER BY 
    Year;


-- total number of case of confirmed, deaths, recovered each month
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
    SUM(CAST(Confirmed AS INT)) AS TotalConfirmed,
    SUM(CAST(Deaths AS INT)) AS TotalDeaths,
    SUM(CAST(Recovered AS INT)) AS TotalRecovered
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103)),
	MONTH(TRY_CONVERT(DATE, date, 103))
ORDER BY 
    Year, Month;


-- cleaning some values
UPDATE dbo.[Corona Virus Dataset]
SET [Country Region] = 'Palestine'
WHERE [Country Region] = 'Israel';


-- Country having highest number of the Confirmed case
SELECT [Country Region]
FROM   dbo.[Corona Virus Dataset]
WHERE  Confirmed = 
		(
			SELECT MAX(Confirmed)
			FROM dbo.[Corona Virus Dataset]
		);

-- Country having lowest number of the Deaths case
SELECT TOP 1 [Country Region]
FROM dbo.[Corona Virus Dataset]
WHERE Deaths = (
    SELECT MIN(Deaths)
    FROM dbo.[Corona Virus Dataset]
)


-- top 5 countries having highest number of the recovered case
SELECT TOP 5 [Country Region],
	   SUM(CAST(Recovered AS INT)) AS TotalRecovered
FROM dbo.[Corona Virus Dataset]
GROUP BY [Country Region]
ORDER BY TotalRecovered DESC


-- total confirmed cases, their average, variance & STDEV
SELECT 
    SUM(CAST(Confirmed AS INT)) AS TotalConfirmedCases,
    AVG(CAST(Confirmed AS INT)) AS AverageConfirmedCases,
    VAR(CAST(Confirmed AS INT)) AS VarianceConfirmedCases,
    STDEV(CAST(Confirmed AS INT)) AS StdDevConfirmedCases

FROM 
    dbo.[Corona Virus Dataset]

-- total recovered cases, their average, variance & STDEV
SELECT 
    SUM(CAST(Recovered AS INT)) AS TotalRecoveredCases,
    AVG(CAST(Recovered AS INT)) AS AverageRecoveredCases,
    VAR(CAST(Recovered AS INT)) AS VarianceRecoveredCases,
    STDEV(CAST(Recovered AS INT)) AS StdDevRecoveredCases

FROM 
    dbo.[Corona Virus Dataset]


-- total deaths cases, their average, variance & STDEV (per month)
SELECT 
    YEAR(TRY_CONVERT(DATE, date, 103)) AS Year,
    MONTH(TRY_CONVERT(DATE, date, 103)) AS Month,
    ROUND(SUM(CAST(Deaths AS INT)), 3) AS TotalDeaths,
    ROUND(AVG(CAST(Deaths AS INT)), 3) AS AverageDeaths,
    ROUND(VAR(CAST(Deaths AS INT)), 3) AS VarianceDeaths,
    ROUND(STDEV(CAST(Deaths AS INT)), 3) AS StdDevDeaths
FROM 
    dbo.[Corona Virus Dataset]
GROUP BY 
    YEAR(TRY_CONVERT(DATE, date, 103)),
	MONTH(TRY_CONVERT(DATE, date, 103))
ORDER BY 
    Year, Month;






