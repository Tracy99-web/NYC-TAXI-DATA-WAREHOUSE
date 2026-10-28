# NYC Taxi Data Pipeline in Snowflake

## Overview

This project demonstrates an end-to-end data pipeline built in Snowflake using NYC Yellow Taxi trip data.

The aim was to take raw monthly taxi data, load it into Snowflake, assess and flag data quality issues, transform it into a structured staging layer and build an analytics-ready dimensional model.

The final dataset supports analysis of trip behaviour, location patterns, airport journeys, monthly performance and data quality trends.

The project was designed to reflect a real-world data workflow.

---

## Project Architecture
The pipeline follows a layered approach:

**Source Files → Internal Stage → Raw Layer → Data Quality → Staging Layer → Analytics Layer → Analysis**

### Raw Layer
Monthly NYC taxi files are loaded into Snowflake while retaining source-file and load-timestamp metadata for traceability.

### Data Quality
The raw data is profiled for issues including:

- Invalid trip dates
- Zero or negative trip distance
- Invalid trip duration
- Negative financial values
- Invalid pickup and drop-off locations

The pipeline identifies and classifies problematic records so that data quality issues remain visible.

### Staging Layer
The staging layer transforms the raw data and adds:

- Derived trip fields
- Individual quality flags
- Source month
- Overall quality status
- Source lineage information

This allows downstream models to distinguish between valid and records that require review without repeating validation logic.

### Analytics Layer
Validated records are transformed into a dimensional model consisting of a central fact table and supporting dimensions.

The model includes:

- `FACT_TRIPS`
- `DIM_DATE`
- `DIM_ZONE`
- `DIM_PAYMENT_TYPE`

Only records classified as `VALID` in the staging layer are loaded into the analytical fact table.

---

