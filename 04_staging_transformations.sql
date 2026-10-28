-- =======================================================================================
-- Transforms raw taxi data into a structured staging layer.
-- Adds derived fields and data quality flags while preserving records for traceability.
-- ======================================================================================

USE SCHEMA NYC_TAXI_DB.STAGING;
CREATE OR REPLACE TABLE STG_TAXI_TRIPS AS

SELECT
    T.VENDOR_ID,
    T.PICKUP_DATETIME,
    T.DROPOFF_DATETIME,
    T.PASSENGER_COUNT,
    T.TRIP_DISTANCE,
    T.RATE_CODE_ID,
    T.STORE_AND_FWD_FLAG,
    T.PU_LOCATION_ID,
    T.DO_LOCATION_ID,
    T.PAYMENT_TYPE,
    T.FARE_AMOUNT,
    T.EXTRA,
    T.MTA_TAX,
    T.TIP_AMOUNT,
    T.TOLLS_AMOUNT,
    T.IMPROVEMENT_SURCHARGE,
    T.TOTAL_AMOUNT,
    T.CONGESTION_SURCHARGE,

    T.SOURCE_FILE,
    T.LOAD_TIMESTAMP,

    REGEXP_SUBSTR(
        T.SOURCE_FILE,
        '[0-9]{4}-[0-9]{2}'
    ) AS SOURCE_MONTH,

    DATEDIFF(
        'minute',
        T.PICKUP_DATETIME,
        T.DROPOFF_DATETIME
    ) AS TRIP_DURATION_MINUTES,

    CASE
        WHEN T.PICKUP_DATETIME <
             TO_DATE(
                 REGEXP_SUBSTR(T.SOURCE_FILE, '[0-9]{4}-[0-9]{2}') || '-01'
             )

          OR T.PICKUP_DATETIME >=
             DATEADD(
                 'month',
                 1,
                 TO_DATE(
                     REGEXP_SUBSTR(T.SOURCE_FILE, '[0-9]{4}-[0-9]{2}') || '-01'
                 )
             )

        THEN TRUE
        ELSE FALSE
    END AS IS_OUT_OF_PERIOD,

    CASE
        WHEN T.TRIP_DISTANCE <= 0
        THEN TRUE
        ELSE FALSE
    END AS IS_INVALID_DISTANCE,

    CASE
        WHEN T.DROPOFF_DATETIME <= T.PICKUP_DATETIME
        THEN TRUE
        ELSE FALSE
    END AS IS_INVALID_DURATION,

    CASE
        WHEN T.FARE_AMOUNT < 0
          OR T.TOTAL_AMOUNT < 0
        THEN TRUE
        ELSE FALSE
    END AS IS_NEGATIVE_AMOUNT,

    CASE
        WHEN PU.LOCATION_ID IS NULL
        THEN TRUE
        ELSE FALSE
    END AS IS_INVALID_PICKUP_ZONE,

    CASE
        WHEN DO.LOCATION_ID IS NULL
        THEN TRUE
        ELSE FALSE
    END AS IS_INVALID_DROPOFF_ZONE,

    CASE
        WHEN
            T.PICKUP_DATETIME <
                TO_DATE(
                    REGEXP_SUBSTR(T.SOURCE_FILE, '[0-9]{4}-[0-9]{2}') || '-01'
                )

            OR T.PICKUP_DATETIME >=
                DATEADD(
                    'month',
                    1,
                    TO_DATE(
                        REGEXP_SUBSTR(T.SOURCE_FILE, '[0-9]{4}-[0-9]{2}') || '-01'
                    )
                )

            OR T.TRIP_DISTANCE <= 0
            OR T.DROPOFF_DATETIME <= T.PICKUP_DATETIME
            OR T.FARE_AMOUNT < 0
            OR T.TOTAL_AMOUNT < 0
            OR PU.LOCATION_ID IS NULL
            OR DO.LOCATION_ID IS NULL

        THEN 'REVIEW'
        ELSE 'VALID'
    END AS QUALITY_STATUS

FROM NYC_TAXI_DB.RAW.RAW_TAXI_TRIPS T

LEFT JOIN NYC_TAXI_DB.RAW.RAW_TAXI_ZONES PU
    ON T.PU_LOCATION_ID = PU.LOCATION_ID

LEFT JOIN NYC_TAXI_DB.RAW.RAW_TAXI_ZONES DO
    ON T.DO_LOCATION_ID = DO.LOCATION_ID;


SELECT COUNT(*)
FROM STG_TAXI_TRIPS;

SELECT
    QUALITY_STATUS,
    COUNT(*) AS ROW_COUNT
FROM STG_TAXI_TRIPS
GROUP BY QUALITY_STATUS
ORDER BY QUALITY_STATUS;

SELECT
    COUNT_IF(IS_OUT_OF_PERIOD) AS OUT_OF_PERIOD,
    COUNT_IF(IS_INVALID_DISTANCE) AS INVALID_DISTANCE,
    COUNT_IF(IS_INVALID_DURATION) AS INVALID_DURATION,
    COUNT_IF(IS_NEGATIVE_AMOUNT) AS NEGATIVE_AMOUNT,
    COUNT_IF(IS_INVALID_PICKUP_ZONE) AS INVALID_PICKUP_ZONE,
    COUNT_IF(IS_INVALID_DROPOFF_ZONE) AS INVALID_DROPOFF_ZONE
FROM STG_TAXI_TRIPS;