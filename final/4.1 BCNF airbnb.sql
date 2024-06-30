
/*
    Arquivo para fazer a normalização das tabelas do airbnb
*/

/* Normalização da Listings */
/* <Normalização Listings 1NF> */
DROP VIEW IF EXISTS Listings_1NF CASCADE;
CREATE VIEW Listings_1NF AS
SELECT
    id AS listing_id,
    listing_url,
    scrape_id,
    last_scraped,
    source,
    CASE WHEN POSITION(' · ' IN name)>0 THEN
        SPLIT_PART(name,' · ',1)
    ELSE
        NULL
    END AS nome,
    
    CASE
        WHEN POSITION('★' IN name) > 0 THEN
            CAST(NULLIF(TRIM(
                CASE WHEN POSITION(' · ' IN SUBSTRING(name FROM POSITION('★' IN name)+1))>0 THEN
                    SUBSTRING(
                        SUBSTRING(name FROM POSITION('★' IN name)+1),
                        0,
                        POSITION(' · ' IN SUBSTRING(name FROM POSITION('★' IN name)))
                    )
                ELSE 
                    SUBSTRING(name FROM POSITION('★' IN name)+1)
                END
            ),'New') AS FLOAT)
        ELSE
            NULL
    END AS avaliacao,
    
    CASE
        WHEN POSITION('bedroom' IN name) > 0 THEN
            CAST(TRIM(
                CASE WHEN POSITION(' · ' IN SUBSTRING(name,0,POSITION('bedroom' IN name)))>0 THEN
                    SUBSTRING(
                        SUBSTRING(name,0,POSITION('bedroom' IN name)),
                        LENGTH(SUBSTRING(name,0,POSITION('bedroom' IN name))) - POSITION(' · ' IN REVERSE(SUBSTRING(name,0,POSITION('bedroom' IN name)))) + 1,
                        LENGTH(SUBSTRING(name,0,POSITION('bedroom' IN name))) - 7
                    )
                ELSE 
                    SUBSTRING(name,0,POSITION('bedroom' IN name))
                END
            ) AS SMALLINT)
        ELSE
            0
    END AS Nquartos,
    
    CASE
        WHEN POSITION('beds' IN name) > 0 THEN
            CAST(TRIM(
                CASE WHEN POSITION(' · ' IN SUBSTRING(name,0,POSITION('beds' IN name)))>0 THEN
                    SUBSTRING(
                        SUBSTRING(name,0,POSITION('beds' IN name)),
                        LENGTH(SUBSTRING(name,0,POSITION('beds' IN name))) - POSITION(' · ' IN REVERSE(SUBSTRING(name,0,POSITION('beds' IN name)))) + 1,
                        LENGTH(SUBSTRING(name,0,POSITION('beds' IN name))) - 4
                    )
                ELSE 
                    SUBSTRING(name,0,POSITION('beds' IN name))
                END
            ) AS SMALLINT)
        WHEN POSITION('1 bed ' IN name) > 0 THEN
            1
        ELSE
            0
    END AS Ncamas,
    
    CASE
        WHEN POSITION('bath' IN name) > 0 THEN
            CAST(NULLIF(
                REGEXP_REPLACE(
                    SUBSTRING(
                        name, 
                        LENGTH(SUBSTRING(name,0,POSITION('bath' IN name))) - POSITION(' · ' IN REVERSE(SUBSTRING(name,0,POSITION('bath' IN name)))) + 1,
                        POSITION('bath' IN name)),
                '[^0-9.]','','g'
                ), '')
             AS FLOAT)
        ELSE
            0
    END AS Nbanheiros,
    
    description,
    neighborhood_overview,
    picture_url,
    host_id,
    host_url,
    host_name,
    host_since,
    host_location,
    host_about,
    host_response_time,
    host_response_rate,
    host_acceptance_rate,
    host_is_superhost,
    host_thumbnail_url,
    host_picture_url,
    host_neighbourhood,
    host_listings_count, 
    host_total_listings_count, 
    host_verifications,
    host_has_profile_pic,
    host_identity_verified,
    neighbourhood,
    neighbourhood_cleansed,
    neighbourhood_group_cleansed,
    latitude,
    longitude,
    property_type,
    room_type,
    accommodates,
    bathrooms,
    bathrooms_text,
    bedrooms,
    beds,
    price,
    minimum_nights,
    maximum_nights,
    minimum_minimum_nights,
    maximum_minimum_nights,
    minimum_maximum_nights,
    maximum_maximum_nights,
    minimum_nights_avg_ntm,
    maximum_nights_avg_ntm,
    calendar_updated,
    has_availability,
    availability_30,
    availability_60,
    availability_90,
    availability_365,
    calendar_last_scraped,
    number_of_reviews,
    number_of_reviews_ltm,
    number_of_reviews_l30d,
    first_review,
    last_review,
    review_scores_rating,
    review_scores_accuracy,
    review_scores_cleanliness,
    review_scores_checkin,
    review_scores_communication,
    review_scores_location,
    review_scores_value,
    license,
    instant_bookable,
    calculated_host_listings_count,
    calculated_host_listings_count_entire_homes,
    calculated_host_listings_count_private_rooms,
    calculated_host_listings_count_shared_rooms,
    reviews_per_month
FROM Listings;


/* <Normalização Listings 2NF> */
ALTER TABLE Listings_1NF RENAME TO Listings_2NF;




/* <Normalização Listings 3NF> */
DROP VIEW IF EXISTS Host_3NF CASCADE;
CREATE VIEW Host_3NF AS
    SELECT DISTINCT host_id, host_url, host_name, host_since, host_location, host_about, host_response_time,
        host_response_rate, host_acceptance_rate, host_is_superhost, host_thumbnail_url, host_picture_url,
        host_neighbourhood, host_listings_count, host_total_listings_count, host_has_profile_pic,
        host_identity_verified, calculated_host_listings_count, calculated_host_listings_count_entire_homes, 
        calculated_host_listings_count_private_rooms, calculated_host_listings_count_shared_rooms
        
    FROM Listings_2NF;

DROP VIEW IF EXISTS Listings_3NF CASCADE;
CREATE VIEW Listings_3NF AS
    SELECT DISTINCT listing_id, listing_url, scrape_id, last_scraped, source, nome, avaliacao, nquartos, ncamas, nbanheiros, description,
        neighborhood_overview, picture_url, host_id, neighbourhood, neighbourhood_cleansed, neighbourhood_group_cleansed, latitude, longitude, property_type, room_type, accommodates, bathrooms,
        bathrooms_text, bedrooms, beds, price, minimum_nights, maximum_nights, minimum_minimum_nights, 
        maximum_minimum_nights, minimum_maximum_nights, maximum_maximum_nights, minimum_nights_avg_ntm, 
        maximum_nights_avg_ntm, calendar_updated, has_availability, availability_30, availability_60, availability_90, 
        availability_365, calendar_last_scraped, number_of_reviews, number_of_reviews_ltm, number_of_reviews_l30d, 
        first_review, last_review, review_scores_rating, review_scores_accuracy, review_scores_cleanliness, 
        review_scores_checkin, review_scores_communication, review_scores_location, review_scores_value, license,instant_bookable,
        reviews_per_month
    FROM Listings_2NF;


/* <Normalização Listings BCNF> */
DROP TABLE IF EXISTS Listings_final CASCADE;
CREATE TABLE Listings_final (
  listing_id BIGINT PRIMARY KEY, 
  listing_url TEXT, 
  scrape_id BIGINT,
  last_scraped DATE,
  source TEXT, 
  nome TEXT, 
  avaliacao SMALLINT, 
  nquartos SMALLINT, 
  ncamas FLOAT, 
  nbanheiros FLOAT, 
  description TEXT, 
  neighborhood_overview TEXT, 
  picture_url TEXT, 
  host_id INTEGER,
  neighbourhood TEXT, 
  neighbourhood_cleansed TEXT, 
  neighbourhood_group_cleansed TEXT, 
  latitude NUMERIC, 
  longitude NUMERIC, 
  property_type TEXT, 
  room_type TEXT, 
  accommodates INTEGER, 
  bathrooms FLOAT, 
  bathrooms_text TEXT, 
  bedrooms SMALLINT, 
  beds SMALLINT,  
  price TEXT, 
  minimum_nights INTEGER,  
  maximum_nights INTEGER, 
  minimum_minimum_nights INTEGER, 
  maximum_minimum_nights INTEGER, 
  minimum_maximum_nights INTEGER, 
  maximum_maximum_nights INTEGER, 
  minimum_nights_avg_ntm NUMERIC, 
  maximum_nights_avg_ntm NUMERIC, 
  has_availability CHAR, 
  availability_30 INTEGER, 
  availability_60 INTEGER, 
  availability_90 INTEGER, 
  availability_365 INTEGER, 
  number_of_reviews INTEGER, 
  number_of_reviews_ltm INTEGER, 
  number_of_reviews_l30d INTEGER,  
  first_review DATE, 
  last_review DATE, 
  review_scores_rating NUMERIC, 
  review_scores_accuracy NUMERIC, 
  review_scores_cleanliness NUMERIC, 
  review_scores_checkin NUMERIC, 
  review_scores_communication NUMERIC, 
  review_scores_location NUMERIC, 
  review_scores_value NUMERIC, 
  license TEXT, 
  instant_bookable CHAR, 
  reviews_per_month NUMERIC
);

INSERT INTO Listings_final
SELECT 
  listing_id, 
  listing_url, 
  scrape_id,
  last_scraped::DATE,
  source, 
  nome, 
  avaliacao, 
  nquartos, 
  ncamas, 
  nbanheiros, 
  description, 
  neighborhood_overview, 
  picture_url, 
  host_id,
  neighbourhood, 
  neighbourhood_cleansed, 
  neighbourhood_group_cleansed, 
  latitude, 
  longitude, 
  property_type, 
  room_type, 
  accommodates, 
  bathrooms, 
  bathrooms_text, 
  bedrooms, 
  beds, 
  price, 
  minimum_nights, 
  maximum_nights, 
  minimum_minimum_nights, 
  maximum_minimum_nights, 
  minimum_maximum_nights, 
  maximum_maximum_nights, 
  minimum_nights_avg_ntm, 
  maximum_nights_avg_ntm,
  has_availability, 
  availability_30, 
  availability_60, 
  availability_90, 
  availability_365::INTEGER,
  number_of_reviews, 
  number_of_reviews_ltm, 
  number_of_reviews_l30d::INTEGER, 
  first_review::DATE, 
  last_review::DATE, 
  review_scores_rating, 
  review_scores_accuracy, 
  review_scores_cleanliness, 
  review_scores_checkin, 
  review_scores_communication, 
  review_scores_location, 
  review_scores_value, 
  license, 
  instant_bookable, 
  reviews_per_month
FROM Listings_3NF;

/* <Normalização da Host BCNF>*/
DROP TABLE IF EXISTS Host_final CASCADE;
CREATE TABLE Host_final (
  host_id BIGINT PRIMARY KEY,  
  host_url TEXT, 
  host_name VARCHAR(255), 
  host_since DATE, 
  host_location TEXT, 
  host_about TEXT, 
  host_response_time TEXT, 
  host_response_rate FLOAT, 
  host_acceptance_rate FLOAT, 
  host_is_superhost BOOLEAN, 
  host_thumbnail_url TEXT, 
  host_picture_url TEXT, 
  host_neighbourhood TEXT, 
  host_listings_count INTEGER, 
  host_total_listings_count BIGINT, 
  host_has_profile_pic BOOLEAN, 
  host_identity_verified BOOLEAN, 
  calculated_host_listings_count BIGINT, 
  calculated_host_listings_count_entire_homes BIGINT, 
  calculated_host_listings_count_private_rooms BIGINT, 
  calculated_host_listings_count_shared_rooms BIGINT
);

INSERT INTO Host_final
SELECT 
  host_id, 
  host_url, 
  host_name, 
  host_since::DATE, 
  host_location, 
  host_about, 
  host_response_time::TEXT, 
  REPLACE(host_response_rate,'%','')::FLOAT /100.0, 
  REPLACE(host_acceptance_rate,'%','')::FLOAT /100.0, 
  host_is_superhost::BOOLEAN, 
  host_thumbnail_url, 
  host_picture_url, 
  host_neighbourhood, 
  host_listings_count, 
  host_total_listings_count, 
  host_has_profile_pic::BOOLEAN, 
  host_identity_verified::BOOLEAN, 
  calculated_host_listings_count, 
  calculated_host_listings_count_entire_homes, 
  calculated_host_listings_count_private_rooms, 
  calculated_host_listings_count_shared_rooms
FROM Host_3NF;












/* Normalização da Calendar */
/* <Normalização Calendar 1NF> */
DROP TABLE IF EXISTS Calendar_1NF CASCADE;
ALTER TABLE Calendar RENAME TO Calendar_1NF;
/* <Normalização Calendar 2NF> */
DROP TABLE IF EXISTS Calendar_2NF CASCADE;
ALTER TABLE Calendar_1NF RENAME TO Calendar_2NF;
/* <Normalização Calendar 3NF> */
DROP TABLE IF EXISTS Calendar_3NF CASCADE;
ALTER TABLE Calendar_2NF RENAME TO Calendar_3NF;

/* <Normalização Calendar BCNF> */
DROP TABLE IF EXISTS Calendar_final CASCADE;
CREATE TABLE Calendar_final (
    calendar_id BIGINT PRIMARY KEY,
    listing_id BIGINT,
    date DATE,
    available CHAR,
    price FLOAT,
    adjusted_price FLOAT,
    minimum_nights FLOAT,
    maximum_nights FLOAT
);

INSERT INTO Calendar_final
SELECT 
    calendar_id,
    listing_id,
    date,
    available,
    CAST(NULLIF(REGEXP_REPLACE(price,'[^0-9.]','','g'),'') AS FLOAT),
    CAST(NULLIF(REGEXP_REPLACE(adjusted_price,'[^0-9.]','','g'),'') AS FLOAT),
    minimum_nights,
    maximum_nights
FROM Calendar_3NF;









/* Normalização da Reviews */
/* <Normalização Reviews 1NF> */
DROP TABLE IF EXISTS Reviews_1NF CASCADE;
ALTER TABLE Reviews RENAME TO Reviews_1NF;
ALTER TABLE Reviews_1NF RENAME COLUMN id TO id_review;
/* <Normalização Reviews 2NF> */
DROP TABLE IF EXISTS Reviews_2NF CASCADE;
ALTER TABLE Reviews_1NF RENAME TO Reviews_2NF;

/* <Normalização Reviews 3NF> */
DROP TABLE IF EXISTS Reviews_3NF CASCADE;
CREATE TABLE Reviews_3NF AS
    SELECT listing_id, id_review, date, reviewer_id, comments
    FROM Reviews_2NF;
    
DROP TABLE IF EXISTS Reviewers_3NF CASCADE;
CREATE TABLE Reviewers_3NF AS
    SELECT reviewer_id, reviewer_name
    FROM Reviews_2NF;
    
/* <Normalização da Reviews BCNF> */
DROP TABLE IF EXISTS Reviews_final CASCADE;
CREATE TABLE Reviews_final (
    id_review BIGINT PRIMARY KEY,
    listing_id BIGINT,
    date DATE,
    reviewer_id BIGINT,
    comments TEXT
);

INSERT INTO Reviews_final
SELECT 
    id_review,
    listing_id,
    date,
    reviewer_id,
    comments 
FROM Reviews_3NF;

/* <Normalização da Reviewers BCNF> */
DROP TABLE IF EXISTS Reviewers_final CASCADE;
CREATE TABLE Reviewers_final (
    reviewer_id BIGINT PRIMARY KEY,
    reviewer_name TEXT
);

INSERT INTO Reviewers_final (reviewer_id, reviewer_name)
    SELECT reviewer_id, MIN(reviewer_name) as reviewer_name
    FROM Reviewers_3NF
    GROUP BY reviewer_id;




/* ---------------------------------------- */
/* Ligando as Foreign Keys */
ALTER TABLE Listings_final
    ADD CONSTRAINT fk_host
    FOREIGN KEY (host_id ) REFERENCES Host_final (host_id);
ALTER TABLE Reviews_Final
    ADD CONSTRAINT fk_reviewers
    FOREIGN KEY (reviewer_id) REFERENCES Reviewers_Final (reviewer_id);
ALTER TABLE Calendar_final
    ADD CONSTRAINT fk_listing
    FOREIGN KEY (listing_id ) REFERENCES Listings_final (listing_id);
ALTER TABLE Reviews_final
    ADD CONSTRAINT fk_listing
    FOREIGN KEY (listing_id ) REFERENCES Listings_final (listing_id);