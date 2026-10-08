select current_database();

-- raw layer

CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.t100_segment (
    departures_scheduled   NUMERIC(12,2),
    departures_performed   NUMERIC(12,2),
    seats                  NUMERIC(14,2),
    passengers             NUMERIC(14,2),
    distance               NUMERIC(10,2),

    unique_carrier         VARCHAR(10),
    unique_carrier_name    VARCHAR(150),

    origin_airport_id      INTEGER,
    origin                 CHAR(3),
    origin_city_name       VARCHAR(150),
    origin_state_abr       CHAR(2),

    dest_airport_id        INTEGER,
    dest                   CHAR(3),
    dest_city_name         VARCHAR(150),
    dest_state_abr         CHAR(2),

    aircraft_type          INTEGER,

    year                   SMALLINT,
    month                  SMALLINT,

    source_file            VARCHAR(255),
    loaded_at              TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- load data using SQL Shell (psql)
-- \copy raw.t100_segment (departures_scheduled, departures_performed, seats, passengers, distance, unique_carrier, unique_carrier_name, origin_airport_id, origin, origin_city_name, origin_state_abr, dest_airport_id, dest, dest_city_name, dest_state_abr, aircraft_type, year, month) FROM '/Users/AndreaLopera/Desktop/AA Project/data/T_T100D_SEGMENT_US_CARRIER_ONLY_2023/T_T100D_SEGMENT_US_CARRIER_ONLY.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')

-- Profile the raw data
SELECT
    year,
    month,
    COUNT(*) AS row_count
FROM raw.t100_segment
GROUP BY year, month
ORDER BY year, month;

SELECT
    COUNT(*) FILTER (WHERE year IS NULL) AS null_year,
    COUNT(*) FILTER (WHERE month IS NULL) AS null_month,
    COUNT(*) FILTER (WHERE origin IS NULL) AS null_origin,
    COUNT(*) FILTER (WHERE dest IS NULL) AS null_dest,
    COUNT(*) FILTER (WHERE passengers IS NULL) AS null_passengers,
    COUNT(*) FILTER (WHERE seats IS NULL) AS null_seats
FROM raw.t100_segment;

SELECT
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    MIN(month) AS min_month,
    MAX(month) AS max_month,
    MIN(passengers) AS min_passengers,
    MIN(seats) AS min_seats,
    MIN(distance) AS min_distance
FROM raw.t100_segment;