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

## SQL Workflow

### 01 — Environment Setup

`01_setup.sql`

Creates the Snowflake environment required for the project, including the database, schemas, warehouse, file format, internal stage and raw tables.

---

### 02 — Raw Data Ingestion

`02_raw_ingestion.sql`

Loads monthly NYC taxi data into the raw layer using Snowflake `COPY INTO`.

Source-file metadata and load timestamps are retained to provide visibility into where each record originated and when it entered the pipeline.

The monthly files are loaded in batches so that ingestion can be tracked at source level.

---

### 03 — Data Quality Assessment

`03_data_quality.sql`

Profiles the raw dataset before transformation and identifies records that violate expected temporal, geographic or financial rules.

Checks include invalid dates, distances, trip durations, location IDs and monetary values.

This stage provides visibility into the condition of the source data before it reaches downstream analytics.

---

### 04 — Staging Transformations

`04_staging_transformations.sql`

Transforms raw taxi records into a structured staging dataset.

The staging layer adds explicit quality flags and assigns each record an overall `QUALITY_STATUS`.

This preserves the original data for traceability while creating a controlled point from which validated records can move into the analytics layer.

---

### 05 — Dimensional Model

`05_dimensional_model.sql`

Builds an star schema that is ready for analytics.

The central `FACT_TRIPS` table contains validated trip records, while supporting dimensions provide descriptive context for dates, locations and payment methods.

Using a dimensional model simplifies downstream analysis and reduces repeated transformation logic.

---

### 06 — Analysis

`06_analysis.sql`

Uses the analytical model to answer business and operational questions around taxi activity.

The analysis focuses on:

- Trip volume by borough
- Airport versus non-airport journeys
- Monthly trip value and distance
- Data quality trends across source batches

---

## Analysis

### Borough Trip Volume

This analysis examines where taxi journeys originate and identifies differences in trip activity across NYC boroughs.

---

### Airport vs Non-Airport Trips

Airport journeys are compared with other trips to understand differences in trip value and travel behaviour.

---

### Monthly Trip Performance

Trip value and distance are analysed over time using the date dimension rather than relying on source filenames.

---

### Data Quality Trends

The staging layer is also used to monitor the proportion of records requiring review across different source months.

This separates business analysis from pipeline monitoring and provides visibility into whether source-data quality changes between ingestion batches.

---

## Key Design Decisions

One of the main design decisions in this project was to separate data validation from downstream analytics.

Rather than repeatedly applying quality conditions within analytical queries, records are evaluated once in the staging layer and assigned a quality status. The analytics layer can then consume only validated records.

Problematic records are retained rather than deleted, allowing issues to be reviewed later and preserving the lineage of the source data.

A dimensional model was also introduced so that common business concepts such as dates, locations and payment types are represented consistently across analytical queries.

---

## Technologies Used

- Snowflake
- SQL
- Snowflake Internal Stages
- Dimensional Modelling
- Data Quality Validation
- Data Transformation
- GitHub

---

## Skills Demonstrated

This project demonstrates experience in designing structured data pipelines, validating source data, transforming raw records and building analytical data models.

It also demonstrates practical consideration of data lineage, data quality and the separation of responsibilities across raw, staging and analytics layers.

---

## Data Source

NYC Yellow Taxi trip data and taxi zone reference data from the New York City Taxi and Limousine Commission.

---

## Future Improvements

Potential extensions to the project include automating monthly ingestion, introducing scheduled data quality monitoring and developing a dashboard directly from the analytics layer.
