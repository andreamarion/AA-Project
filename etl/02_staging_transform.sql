select current_database();

-- Create staging
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.t100_segment_clean (
    departures_scheduled   INTEGER,
    departures_performed   INTEGER,
    seats                  INTEGER,
    passengers             INTEGER,
    distance               NUMERIC(10,2),

    unique_carrier         VARCHAR(10) NOT NULL,
    unique_carrier_name    VARCHAR(150),

    origin_airport_id      INTEGER NOT NULL,
    origin                 CHAR(3) NOT NULL,
    origin_city_name       VARCHAR(150),
    origin_state_abr       CHAR(2),

    dest_airport_id        INTEGER NOT NULL,
    dest                   CHAR(3) NOT NULL,
    dest_city_name         VARCHAR(150),
    dest_state_abr         CHAR(2),

    aircraft_type          INTEGER,

    year                   SMALLINT NOT NULL,
    month                  SMALLINT NOT NULL,
    service_month          DATE,

    loaded_at              TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_month
        CHECK (month BETWEEN 1 AND 12),

    CONSTRAINT chk_departures_scheduled
        CHECK (departures_scheduled >= 0),

    CONSTRAINT chk_departures_performed
        CHECK (departures_performed >= 0),

    CONSTRAINT chk_seats
        CHECK (seats >= 0),

    CONSTRAINT chk_passengers
        CHECK (passengers >= 0),

    CONSTRAINT chk_distance
        CHECK (distance >= 0)
);

-- transform raw to staging
INSERT INTO staging.t100_segment_clean (
    departures_scheduled,
    departures_performed,
    seats,
    passengers,
    distance,
    unique_carrier,
    unique_carrier_name,
    origin_airport_id,
    origin,
    origin_city_name,
    origin_state_abr,
    dest_airport_id,
    dest,
    dest_city_name,
    dest_state_abr,
    aircraft_type,
    year,
    month,
    service_month
)
SELECT
    departures_scheduled::INTEGER,
    departures_performed::INTEGER,
    seats::INTEGER,
    passengers::INTEGER,
    distance,

    UPPER(TRIM(unique_carrier)),
    TRIM(unique_carrier_name),

    origin_airport_id,
    UPPER(TRIM(origin)),
    TRIM(origin_city_name),
    UPPER(TRIM(origin_state_abr)),

    dest_airport_id,
    UPPER(TRIM(dest)),
    TRIM(dest_city_name),
    UPPER(TRIM(dest_state_abr)),

    aircraft_type,
    year,
    month,

    MAKE_DATE(year, month, 1)

FROM raw.t100_segment;

-- validate the transformation did not lose or disort data
-- 1. ROW COUNT: staging should equal raw
SELECT
    (SELECT COUNT(*) FROM raw.t100_segment) AS raw_rows,
    (SELECT COUNT(*) FROM staging.t100_segment_clean) AS staging_rows;

-- 2. CHECK COUNTS BY YEAR
SELECT year, COUNT(*) AS row_count
FROM staging.t100_segment_clean
GROUP BY year
ORDER BY year;

-- 3. CHECK REQUIRED FIELDS FOR NULLS
SELECT
    COUNT(*) FILTER (WHERE unique_carrier IS NULL) AS null_carrier,
    COUNT(*) FILTER (WHERE origin IS NULL) AS null_origin,
    COUNT(*) FILTER (WHERE dest IS NULL) AS null_dest,
    COUNT(*) FILTER (WHERE year IS NULL) AS null_year,
    COUNT(*) FILTER (WHERE month IS NULL) AS null_month
FROM staging.t100_segment_clean;

-- 4. CHECK RANGES
SELECT
    MIN(month) AS min_month,
    MAX(month) AS max_month,
    MIN(seats) AS min_seats,
    MIN(passengers) AS min_passengers,
    MIN(distance) AS min_distance
FROM staging.t100_segment_clean;

-- 5. RECONCILE IMPORTANT TOTALS
SELECT
    SUM(seats) AS total_seats,
    SUM(passengers) AS total_passengers,
    SUM(departures_scheduled) AS scheduled_departures,
    SUM(departures_performed) AS performed_departures
FROM raw.t100_segment;

SELECT
    SUM(seats) AS total_seats,
    SUM(passengers) AS total_passengers,
    SUM(departures_scheduled) AS scheduled_departures,
    SUM(departures_performed) AS performed_departures
FROM staging.t100_segment_clean;


