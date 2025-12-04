# sql-project
# 🌍 Global Energy Consumption & Sustainability Analysis

![SQL](https://img.shields.io/badge/Language-SQL-orange) ![Database](https://img.shields.io/badge/Database-MySQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-green)

## 📖 Project Overview
This project analyzes the complex relationship between economic growth (GDP), population dynamics, and environmental impact (CO2 emissions & energy consumption). By designing a relational database schema and executing advanced SQL queries, we uncover global trends in sustainability, identifying which nations are becoming more energy-efficient and which remain dependent on carbon-intensive fuels.

## 🎯 Objectives
* **Model Reality:** Integrate 5 critical dimensions (Consumption, Production, Emissions, GDP, Population) into a structured Relational Database.
* **Analyze Efficiency:** Calculate the emission-to-GDP ratio to measure "green growth" vs. "dirty growth."
* **Global Context:** Identify the top contributors to global warming and the energy deficit/surplus status of major economies.

## 🗂️ Database Schema (ER Model)
The analysis is built on a Star/Snowflake schema interconnecting the following tables:
* **`COUNTRY`**: Master table for country metadata.
* **`GDP`**: Economic performance indicators over time.
* **`POPULATION`**: Demographic trends.
* **`EMISSION_3`**: Detailed breakdown of CO2 emissions by source.
* **`PRODUCTION` & `CONSUMPTION`**: Energy metrics (Coal, Oil, Gas, Renewables).

## 📊 Key Findings & Insights
Based on the SQL analysis, the following trends were identified:

1.  **The "Big Three" Dominance:**
    * China, USA, and India collectively account for **53% of global CO2 emissions**. Targeted policies in these three nations alone would outweigh net-zero efforts in dozens of smaller nations combined.

2.  **The Energy Deficit Trap:**
    * Despite being top producers, major economies like **China and India** face significant energy deficits (Consumption > Production), necessitating heavy reliance on imports. In contrast, **Russia** remains a dominant Net Exporter.

3.  **Coal Dependence:**
    * Coal remains the single largest driver of emissions (**~64k MM tonnes**), proving that heavy industry has not yet decoupled from carbon-intensive fuel sources.

4.  **The Efficiency Paradox:**
    * China emits **~4x more** than India (24k vs 5.6k) despite having a similar population size (~1.4B). This highlights that industrial intensity, not just population size, is the primary driver of environmental footprint.

## 🛠️ Technical Skills Demonstrated
* **Database Design:** Normalization and ER Modeling to structure raw CSV data.
* **Advanced SQL:**
    * **Joins:** Inner/Left joins to merge GDP, Pop, and Energy tables.
    * **Aggregations:** `GROUP BY` and `HAVING` clauses for regional summaries.
    * **Calculations:** Derived metrics like *Emission Per Capita* and *Energy Intensity*.
    * **Window Functions:** Used for year-over-year trend analysis (if applicable).

## 📂 Repository Structure
```text
├── data/               # Raw CSV files used for import
├── sql_scripts/        #
│   ├── 01_schema_creation.sql   # CREATE TABLE statements
│   ├── 02_data_import.sql       # LOAD DATA / INSERT statements
│   └── 03_analysis_queries.sql  # Complex queries answering business questions
├── presentation/       # Project PPT and visuals
└── README.md           # Project documentation
