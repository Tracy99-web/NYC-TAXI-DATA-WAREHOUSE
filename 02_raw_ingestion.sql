COPY INTO NYC_TAXI_DB.RAW.RAW_TAXI_TRIPS
FROM(
    SELECT
    $1::INTEGER,
    $2::TIMESTAMP_NTZ,
    $3::TIMESTAMP_NTZ,
    $4::INTEGER,
    $5::FLOAT,
    $6::INTEGER,
    $7::VARCHAR,
    $8::INTEGER,
    $9::INTEGER,
    $10::INTEGER,
    $11::FLOAT,
    $12::FLOAT,
    $13::FLOAT,
    $14::FLOAT,
    $15::FLOAT,
    $16::FLOAT,
    $17::FLOAT,
    $18::FLOAT,
    METADATA$FILENAME,
    CURRENT_TIMESTAMP()
FROM @NYC_TAXI_DB.RAW.NYC_TAXI_STAGE
    
)
FILE_FORMAT =(
    FORMAT_NAME = NYC_TAXI_DB.RAW.NYC_TAXI_CSV_FORMAT
)
-- Each monthly source file is loaded separately to preserve batch leel lineage
-- The YYYY-MM value is updated for each ingestion batch
PATTERN='.*2019-01.*' 
ON_ERROR ='CONTINUE';

