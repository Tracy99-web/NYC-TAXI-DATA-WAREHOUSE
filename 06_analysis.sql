-- ==========================================================================================================
-- DATA ANALYTICS INSIGHTS
-- ============================================================================================================

-- BOROUGH TRIPS VOLUME:-- 
-- This analysis examines where taxi journeys originate and identifies differences in trip activity 
-- across NYC boroughs.

SELECT
    Z.BOROUGH,
    COUNT(*) AS TRIP_COUNT
FROM NYC_TAXI_DB.ANALYTICS.FACT_TRIPS F
JOIN NYC_TAXI_DB.ANALYTICS.DIM_ZONE Z
    ON F.PICKUP_LOCATION_ID = Z.LOCATION_ID
GROUP BY Z.BOROUGH
ORDER BY TRIP_COUNT DESC;


-- AIRPORT AND NON-AIRPORT TRIPS COMPARISON:-- 
-- Airport journeys are compared with other trips to understand differences in trip value 
-- and travel behaviour.

SELECT
    CASE
        WHEN Z.ZONE IN (
            'JFK Airport',
            'LaGuardia Airport',
            'Newark Airport'
        )
        THEN 'Airport'
        ELSE 'Non-Airport'
    END AS TRIP_TYPE,

    ROUND(AVG(F.TOTAL_AMOUNT), 2) AS AVG_TRIP_VALUE,
    ROUND(AVG(F.TRIP_DISTANCE), 2) AS AVG_TRIP_DISTANCE

FROM NYC_TAXI_DB.ANALYTICS.FACT_TRIPS F

JOIN NYC_TAXI_DB.ANALYTICS.DIM_ZONE Z
    ON F.PICKUP_LOCATION_ID = Z.LOCATION_ID

GROUP BY TRIP_TYPE
ORDER BY AVG_TRIP_VALUE DESC;

-- MONTHLY TRIP PERFORMANCE: --
-- Trip value and distance are analysed over time using the date dimension 
-- rather than relying on source filenames.
SELECT
    D.YEAR,
    D.MONTH_NUMBER,
    D.MONTH_NAME,

    ROUND(AVG(F.TOTAL_AMOUNT), 2) AS AVG_TRIP_VALUE,
    ROUND(AVG(F.TRIP_DISTANCE), 2) AS AVG_TRIP_DISTANCE

FROM NYC_TAXI_DB.ANALYTICS.FACT_TRIPS F

JOIN NYC_TAXI_DB.ANALYTICS.DIM_DATE D
    ON F.DATE_KEY = D.DATE_KEY

GROUP BY
    D.YEAR,
    D.MONTH_NUMBER,
    D.MONTH_NAME

ORDER BY
    D.YEAR,
    D.MONTH_NUMBER;


-- DATA QUALITY TREND --
SELECT
    SOURCE_MONTH,

    ROUND(
        100.0 * COUNT_IF(QUALITY_STATUS = 'REVIEW')
        / COUNT(*),
        2
    ) AS REVIEW_RATE_PERCENT,

    COUNT_IF(IS_INVALID_DISTANCE) AS INVALID_DISTANCE

FROM NYC_TAXI_DB.STAGING.STG_TAXI_TRIPS

GROUP BY SOURCE_MONTH
ORDER BY SOURCE_MONTH;
