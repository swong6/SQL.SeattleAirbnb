/* 
Seattle Airbnb Open Data Analysis 

Skills used: SQL (Window Functions, CTEs, Data Cleaning, Data Analysis)
*/

/* 1. Data Exploration */
/* Sample Data from Tables */
SELECT * FROM calendar LIMIT 10;
SELECT * FROM listings LIMIT 10;
SELECT * FROM reviews LIMIT 10;

/* Count of Records in Each Table */
SELECT COUNT(*) AS total_listings FROM listings;
SELECT COUNT(*) AS total_reviews FROM reviews;
SELECT COUNT(*) AS total_calendar_entries FROM calendar;

/* Data Types and Structure of Each Table */
DESCRIBE listings;
DESCRIBE calendar;
DESCRIBE reviews;

SELECT MIN(date) AS earliest_date, MAX(date) AS latest_date FROM calendar;

/* 2. Data Cleaning */
/* Remove $ from Calendar's Price Column */
UPDATE calendar SET price = REPLACE(REPLACE(price, '$', ''), ',', '') + 0 WHERE listing_id IS NOT NULL;

/* Identify Duplicate Values */
SELECT id, COUNT(*) FROM listings GROUP BY id HAVING COUNT(*) > 1;

/* Identify Listings with Missing Prices */
SELECT * FROM listings WHERE price = 0;

/* Update Listings with Missing Prices Using Calendar Table */
SET SQL_SAFE_UPDATES = 0;
UPDATE listings l 
JOIN (
    SELECT DISTINCT listing_id, MAX(price) as price
    FROM calendar 
    WHERE price > 0 
    GROUP BY listing_ID
) c
ON l.id = c.listing_id
SET l.price = c.price
WHERE l.price = 0;

/* Verify No Listings with Zero Price */
SELECT * FROM listings WHERE price = 0;

/* 3. Descriptive Statistics and Insights */
/* Number of Listings and Average Price by Neighborhood */
SELECT neighborhood_group, ROUND(AVG(price), 2) as avg_price, COUNT(id) as number_listings
FROM listings
GROUP BY neighborhood_group
ORDER BY avg_price;

/* Most Expensive Neighborhoods */
SELECT neighborhood_group, MAX(price) as max_price
FROM listings
GROUP BY neighborhood_group
ORDER BY max_price DESC
LIMIT 5;

/* Least Expensive Neighborhoods */
SELECT neighborhood_group, MIN(price) as min_price
FROM listings
GROUP BY neighborhood_group
ORDER BY min_price ASC
LIMIT 5;

/* Price Outliers */
SELECT id, name, price
FROM listings
WHERE price > (SELECT AVG(price) + 3 * STD(price) FROM listings)
ORDER BY price DESC;

/* Room Types Generating the Most Revenue */
SELECT room_type, SUM((365 - availability_365)*price) AS revenue
FROM listings
GROUP BY room_type
ORDER BY revenue DESC;

/* 4. Temporal Analysis */
/* Busiest Months for Airbnb Bookings */
SELECT DATE_FORMAT(date, '%m') AS month, COUNT(*) as booking_count
FROM calendar
WHERE available = 'f'
GROUP BY month
ORDER BY booking_count DESC;

/* Average Availability by Month */
SELECT DATE_FORMAT(date, '%Y-%m') AS month, COUNT(*) as booking_count
FROM calendar
WHERE available = 'f'
GROUP BY month
ORDER BY booking_count DESC;

/* 5. Advanced Analysis */
/* Top 10 Hosts with the Most Listings */
SELECT host_id, host_name, COUNT(*) as listing_count
FROM listings
GROUP BY host_id, host_name
ORDER BY listing_count DESC
LIMIT 10;

/* Price Distribution by Room Type */
SELECT room_type, COUNT(*) as total_listings, ROUND(AVG(price), 0) as avg_price, MIN(price) as min_price, MAX(price) as max_price, ROUND(STDDEV(price), 0) as stddev_price
FROM listings
GROUP BY room_type;

/* Top Neighborhoods with the Highest Average Price for Each Room Type */
WITH NeighborhoodRoomTypeAvg AS (
	SELECT 	neighborhood_group,
			room_type,
			ROUND(AVG(price), 0) as avg_price
	FROM listings
	GROUP BY neighborhood_group, room_type
),
RankedNeighborhoods AS (
	SELECT	neighborhood_group,
			room_type,
			avg_price,
			RANK() OVER (PARTITION BY room_type ORDER BY avg_price DESC) as price_rank
	FROM NeighborhoodRoomTypeAvg
)
SELECT	neighborhood_group,
		room_type,
		avg_price
FROM RankedNeighborhoods
WHERE price_rank <= 3
ORDER BY room_type, price_rank
;

/* Price Trend Over Time for Each Neighborhood */

SELECT 
    DATE_FORMAT(c.date, '%Y-%m') AS month,
    l.neighborhood_group,
    ROUND(AVG(c.price), 0) AS avg_price
FROM calendar c
JOIN listings l ON c.listing_id = l.id
GROUP BY month, l.neighborhood_group
ORDER BY l.neighborhood_group, month;



