select * from maindata;
desc maindata;
select count(*) from maindata;


-- 1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
ALTER TABLE maindata
ADD COLUMN Date_Column DATE;

UPDATE maindata
SET Date_Column = STR_TO_DATE(CONCAT(Year, '-', Month, '-', Day),'%Y-%m-%d'
);

ALTER TABLE maindata
ADD COLUMN week INT,
ADD COLUMN monthname VARCHAR(50),
ADD COLUMN weekday INT,
ADD COLUMN yearmonth VARCHAR(20),
ADD COLUMN dayname VARCHAR(50),
ADD COLUMN quarters VARCHAR(5),
ADD COLUMN financial_months VARCHAR(5),
ADD COLUMN financial_quarters VARCHAR(5);

UPDATE maindata
SET
  week = WEEK(Date_Column),
  monthname = MONTHNAME(Date_Column),
  weekday = DAYOFWEEK(Date_Column),
  yearmonth = CONCAT(YEAR(Date_Column), '-', MONTHNAME(Date_Column)),
  dayname = DAYNAME(Date_Column),

  -- Calendar Quarter
  quarters =
    CASE
      WHEN MONTH(Date_Column) IN (1,2,3) THEN 'Q1'
      WHEN MONTH(Date_Column) IN (4,5,6) THEN 'Q2'
      WHEN MONTH(Date_Column) IN (7,8,9) THEN 'Q3'
      ELSE 'Q4'
    END,

  -- Financial Months (April = FM1)
  financial_months =
    CASE
      WHEN MONTH(Date_Column) = 1 THEN 'FM10'
      WHEN MONTH(Date_Column) = 2 THEN 'FM11'
      WHEN MONTH(Date_Column) = 3 THEN 'FM12'
      WHEN MONTH(Date_Column) = 4 THEN 'FM1'
      WHEN MONTH(Date_Column) = 5 THEN 'FM2'
      WHEN MONTH(Date_Column) = 6 THEN 'FM3'
      WHEN MONTH(Date_Column) = 7 THEN 'FM4'
      WHEN MONTH(Date_Column) = 8 THEN 'FM5'
      WHEN MONTH(Date_Column) = 9 THEN 'FM6'
      WHEN MONTH(Date_Column) = 10 THEN 'FM7'
      WHEN MONTH(Date_Column) = 11 THEN 'FM8'
      ELSE 'FM9'
    END,

  -- Financial Quarters
  financial_quarters =
    CASE
      WHEN MONTH(Date_Column) IN (1,2,3) THEN 'FQ4'
      WHEN MONTH(Date_Column) IN (4,5,6) THEN 'FQ1'
      WHEN MONTH(Date_Column) IN (7,8,9) THEN 'FQ2'
      ELSE 'FQ3'
    END;

-- 2)Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

-- YEARLY LOAD FACTOR %
SELECT Year,
  ROUND(SUM(`# Transported Passengers`) /SUM(`# Available Seats`) * 100, 2)
  AS Load_Factor_Percentage
FROM maindata
GROUP BY Year
ORDER BY Year;

-- QUARTERLY LOAD FACTOR %
SELECT
  Year,
  quarters,
  ROUND(SUM(`# Transported Passengers`) /SUM(`# Available Seats`) * 100  , 2) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year, quarters
ORDER BY Year, quarters;

-- MONTHLY LOAD FACTOR %
SELECT
  Year,
  monthname,
  ROUND(
    SUM(`# Transported Passengers`) /SUM(`# Available Seats`) * 100, 2) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year, monthname, Month
ORDER BY Year, Month;

-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
SELECT
  `Carrier Name`,
  ROUND(SUM(`# Transported Passengers`) /SUM(`# Available Seats`) * 100, 2)
  AS Load_Factor_Percentage
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Load_Factor_Percentage DESC;

-- 4. Identify Top 10 Carrier Names based passengers preference 
SELECT
  `Carrier Name`,
  SUM(`# Transported Passengers`) AS Total_Passengers
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Total_Passengers DESC
LIMIT 10;

-- 5. Display top Routes ( from-to City) based on Number of Flights 
SELECT
  `From - To City`,
  SUM(`# Departures Performed`) AS Number_of_Flights
FROM maindata
GROUP BY `From - To City`
ORDER BY Number_of_Flights DESC;

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT
  CASE
    WHEN weekday IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS Day_Type,

  ROUND(
    SUM(`# Transported Passengers`) /
    SUM(`# Available Seats`) * 100
  , 2) AS Load_Factor_Percentage
FROM maindata
GROUP BY Day_Type;


-- 7. Identify number of flights based on Distance group
SELECT
  `%Distance Group ID`,
  SUM(`# Departures Performed`) AS Number_of_Flights
FROM maindata
GROUP BY `%Distance Group ID`
ORDER BY Number_of_Flights DESC;

