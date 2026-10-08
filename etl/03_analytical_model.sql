
-- Star Schema
SELECT
	current_database();


CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE analytics.dim_date (
    date_key        INTEGER PRIMARY KEY,     
    year            SMALLINT NOT NULL,
    month           SMALLINT NOT NULL,
    service_month   DATE NOT NULL
);

CREATE TABLE analytics.dim_route (
    route_key           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    origin_airport_id   INTEGER NOT NULL,
    origin              CHAR(3) NOT NULL,
    origin_city_name    VARCHAR(150),
    origin_state_abr    CHAR(2),
    dest_airport_id     INTEGER NOT NULL,
    dest                CHAR(3) NOT NULL,
    dest_city_name      VARCHAR(150),
    dest_state_abr      CHAR(2),
    distance            NUMERIC(10,2),

    UNIQUE (origin_airport_id, dest_airport_id)
);

CREATE TABLE analytics.dim_aircraft (
    aircraft_key    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aircraft_type   INTEGER UNIQUE
);

CREATE TABLE analytics.dim_carrier (
    carrier_key         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    unique_carrier      VARCHAR(10) NOT NULL UNIQUE,
    unique_carrier_name VARCHAR(150)
);

CREATE TABLE analytics.fact_route_performance (
    date_key                INTEGER NOT NULL,
    route_key               BIGINT NOT NULL,
    aircraft_key            BIGINT,
    carrier_key             BIGINT NOT NULL,

    departures_scheduled    INTEGER,
    departures_performed    INTEGER,
    seats                   INTEGER,
    passengers              INTEGER,

    FOREIGN KEY (date_key) REFERENCES analytics.dim_date(date_key),
    FOREIGN KEY (route_key) REFERENCES analytics.dim_route(route_key),
    FOREIGN KEY (aircraft_key) REFERENCES analytics.dim_aircraft(aircraft_key),
    FOREIGN KEY (carrier_key) REFERENCES analytics.dim_carrier(carrier_key)
);

