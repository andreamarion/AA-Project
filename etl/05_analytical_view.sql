select current_database();

-- Export a flattened analytical CSV for Tableau Public
CREATE OR REPLACE VIEW analytics.v_route_performance AS
SELECT
    d.service_month,
    d.year,
    d.month,

    r.origin,
    r.origin_city_name,
    r.origin_state_abr,
    r.dest,
    r.dest_city_name,
    r.dest_state_abr,
    r.distance,

    c.unique_carrier,
    c.unique_carrier_name,

    a.aircraft_type,

    f.departures_scheduled,
    f.departures_performed,
    f.seats,
    f.passengers

FROM analytics.fact_route_performance f
JOIN analytics.dim_date d
    ON f.date_key = d.date_key
JOIN analytics.dim_route r
    ON f.route_key = r.route_key
JOIN analytics.dim_carrier c
    ON f.carrier_key = c.carrier_key
LEFT JOIN analytics.dim_aircraft a
    ON f.aircraft_key = a.aircraft_key;

SELECT *
FROM analytics.v_route_performance;