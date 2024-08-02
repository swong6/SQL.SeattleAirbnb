/* 
Script to Create and Populate Seattle Airbnb Database
This script creates a database for Seattle Airbnb data, defines tables, and loads data from CSV files.
*/
-- Create database
CREATE DATABASE airbnb;
USE airbnb;

-- Create listings table
CREATE TABLE IF NOT EXISTS listings (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighborhood_group VARCHAR(255),
    neighborhood VARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    room_type VARCHAR(255),
    price FLOAT,
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month FLOAT,
    calculated_host_listings_count INT,
    availability_365 INT
);

-- Create calendar table
CREATE TABLE calendar (
	listing_id INT,
	date DATE,
	available VARCHAR(5),
    price VARCHAR(50),
    PRIMARY KEY (listing_id, date)   
);

-- Create reviews table
CREATE TABLE reviews (
	listing_id INT,
    id INT PRIMARY KEY,
	date DATE,
	reviewer_id INT,
    reviewer_name VARCHAR(255),
    comments TEXT   
);

-- Load data into tables
LOAD DATA LOCAL INFILE 'C:/Users/sharm/Documents/Seattle Airbnb Open Data/calendar.csv'
INTO TABLE calendar
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/sharm/Documents/Seattle Airbnb Open Data/listings.csv'
INTO TABLE listings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/sharm/Documents/Seattle Airbnb Open Data/reviews.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Verify data
SELECT * FROM reviews LIMIT 50;
/* 
-----------------------------------Loading CSV Completed-------------------------------------------
*/