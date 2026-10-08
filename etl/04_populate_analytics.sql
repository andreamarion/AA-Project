select current_database();

-- Start by populating the dimension tables
-- date
INSERT INTO analytics.dim_date (
    date_key,
    year,
    month,
    service_month
)
SELECT DISTINCT
    (year * 100 + month) AS date_key,
    year,
    month,
    service_month
FROM staging.t100_segment_clean
ORDER BY year, month;

-- Review contents
select * from analytics.dim_date dd 

-- route
INSERT INTO analytics.dim_route (
    origin_airport_id,
    origin,
    origin_city_name,
    origin_state_abr,
    dest_airport_id,
    dest,
    dest_city_name,
    dest_state_abr,
    distance
)
SELECT
    origin_airport_id,
    MAX(origin) AS origin,
    MAX(origin_city_name) AS origin_city_name,
    MAX(origin_state_abr) AS origin_state_abr,
    dest_airport_id,
    MAX(dest) AS dest,
    MAX(dest_city_name) AS dest_city_name,
    MAX(dest_state_abr) AS dest_state_abr,
    MAX(distance) AS distance
FROM staging.t100_segment_clean
GROUP BY
    origin_airport_id,
    dest_airport_id;

-- Review contents
select * from analytics.dim_route dr  

-- aircraft
INSERT INTO analytics.dim_aircraft (
    aircraft_type
)
SELECT DISTINCT
    aircraft_type
FROM staging.t100_segment_clean
WHERE aircraft_type IS NOT NULL
ORDER BY aircraft_type;

-- Review contents
select * from analytics.dim_aircraft da   

-- carrier
INSERT INTO analytics.dim_carrier (
    unique_carrier,
    unique_carrier_name
)
SELECT
    unique_carrier,
    MAX(unique_carrier_name)
FROM staging.t100_segment_clean
GROUP BY unique_carrier;

-- Review contents
select * from analytics.dim_carrier dc 

-- Move to populate the fact table
INSERT INTO analytics.fact_route_performance (
    date_key,
    route_key,
    aircraft_key,
    carrier_key,
    departures_scheduled,
    departures_performed,
    seats,
    passengers
)
SELECT
    (s.year * 100 + s.month) AS date_key,
    r.route_key,
    a.aircraft_key,
    c.carrier_key,

    SUM(s.departures_scheduled),
    SUM(s.departures_performed),
    SUM(s.seats),
    SUM(s.passengers)

FROM staging.t100_segment_clean s

JOIN analytics.dim_route r
    ON s.origin_airport_id = r.origin_airport_id
   AND s.dest_airport_id = r.dest_airport_id

JOIN analytics.dim_carrier c
    ON s.unique_carrier = c.unique_carrier

LEFT JOIN analytics.dim_aircraft a
    ON s.aircraft_type = a.aircraft_type

GROUP BY
    s.year,
    s.month,
    r.route_key,
    a.aircraft_key,
    c.carrier_key;

-- Validate all
SELECT COUNT(*) FROM analytics.dim_date;
SELECT COUNT(*) FROM analytics.dim_route;
SELECT COUNT(*) FROM analytics.dim_aircraft;
SELECT COUNT(*) FROM analytics.dim_carrier;
SELECT COUNT(*) FROM analytics.fact_route_performance;
