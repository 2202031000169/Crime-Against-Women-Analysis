# Crime Against Women Analysis --- 2023

## Project Overview

This project analyzes **reported crimes against women in India for
2023** using **MySQL and Microsoft Excel**.

The project combines SQL-based data validation and analysis with an
interactive Excel dashboard to examine patterns across States/UTs, crime
categories, and crime heads.

## Objective

The objectives of this project are to:

1.  Validate and understand the structure of the crime dataset.
2.  Identify patterns across States/UTs, crime categories, and crime
    heads.
3.  Use SQL to answer structured analytical questions.
4.  Build an interactive Excel dashboard using PivotTables, PivotCharts,
    and Slicers.
5.  Identify major concentrations and patterns in reported cases.
6.  Present findings clearly while accounting for the limitations of raw
    reported-case counts.

## Dataset

**Source:** National Crime Records Bureau (NCRB), 2023 data\
**Source reference used in the workbook:** NCRB / data.gov.in

The dataset contains crime records organized at different hierarchical
levels, including aggregate totals, standalone crime heads, and
detailed/component records.

### Analytical Scope

Because the source contains hierarchical records, directly summing every
row would result in double counting.

To prevent this, the project classifies records using two fields:

-   `Record_Level`
-   `Analysis_Include`

The analytical dataset includes:

-   **Standalone** records
-   Selected **top-level Total** records

Detailed/component records are excluded from aggregate analysis.

The nested **`Kidnapping for Marriage (Total)`** record is also excluded
because it is a component of the broader
**`Kidnapping & Abduction (Total)`** figure.

This produces an analytical total of:

> **458,285 reported cases**

## Tools & Technologies

-   **MySQL** --- data validation, aggregation, ranking, comparative
    analysis, and advanced SQL
-   **Microsoft Excel** --- data preparation, PivotTables, PivotCharts,
    Slicers, KPIs, and dashboard
-   **Power Query** --- data normalization and preparation
-   **GitHub** --- project documentation and portfolio presentation

## Project Workflow

``` text
NCRB 2023 Dataset
       ↓
Data Cleaning & Normalization
       ↓
Hierarchical Record Classification
       ↓
Analysis_Include Flag
       ↓
      ┌───────────────┐
      │               │
      ↓               ↓
    MySQL           Excel
      │               │
      ↓               ↓
SQL Analysis     PivotTables /
Q1–Q42 + KPIs    PivotCharts / Slicers
      │               │
      └───────┬───────┘
              ↓
      Cross-checked Findings
              ↓
       Interactive Dashboard
```

## Data Preparation

The source dataset contains overlapping hierarchical records. Therefore,
the project does not treat every row as an independent figure for
aggregate analysis.

### Record Classification

  Record Level                 Treatment
  ---------------------------- -----------
  `Standalone`                 Included
  Selected top-level `Total`   Included
  `Detail`                     Excluded

The following fields were added to the SQL analysis table:

``` text
Record_Level
Analysis_Include
```

`Analysis_Include = 'Yes'` identifies records used for the main
aggregate analysis.

### Validation

  Measure                                 Result
  -------------------------------- -------------
  Total source records                     1,836
  Standalone records                         576
  Total records                              324
  Detail records                             936
  Records included in analysis               864
  Records excluded from analysis             972
  Analytical reported cases          **458,285**

## SQL Analysis

The SQL file contains **42 structured questions** followed by **7
dashboard KPI queries**.

### Analysis Areas

**Data Validation** - Record count - Missing values - Duplicate
records - Negative case values - Distinct States/UTs - Distinct crime
categories - Distinct crime heads - Analytical total - Blank-value
checks

**Exploratory Analysis** - Crime-category structure - Crime-head
distribution - Minimum, average, and maximum crime-head totals -
Percentage contribution by crime category

**State/UT Analysis** - Top and bottom reporting States/UTs - State
ranking - States above the average - Percentage contribution by
State/UT - Top-5 State/UT concentration

**Crime Category Analysis** - Highest and lowest categories - Category
ranking - Percentage contribution - Category-level classification

**Crime Head Analysis** - Top and bottom crime heads - Crime heads above
the average - Top-10 concentration - Crime heads contributing less than
1% of the analytical total

**Comparative & Advanced Analysis** - Category/state comparisons -
Ranking using window functions - Highest crime head within each
category - States above the average - Relative grouping of State/UT
totals - Top three standalone crime heads by State/UT

## Excel Dashboard

The Excel dashboard provides an interactive summary of the analysis.

### Key Performance Indicators

  KPI                           Result
  ---------------------- -------------
  Total Reported Cases     **458,285**
  States/UTs Analyzed           **36**
  Crime Categories              **17**
  Crime Heads Analyzed          **51**

### Highest-Reporting Measures

  Measure                      Result
  ---------------------------- ----------------------------------------------
  Highest-reporting State/UT   **Uttar Pradesh --- 66,392**
  Highest Crime Category       **Domestic Violence --- 134,308**
  Highest Crime Head           **Cruelty by Husband/Relatives --- 133,676**

### Dashboard Visualizations

The dashboard includes:

-   Top 10 States/UTs
-   Cases by Crime Category
-   Top 10 Crime Heads
-   State/UT slicer
-   Crime Category slicer
-   Crime Head slicer

## Key Findings

### State/UT Concentration

Uttar Pradesh recorded the highest number of reported cases among the 36
States/UTs included in the analysis, with **66,392 cases**.

The top five States/UTs together accounted for:

> **229,597 cases --- 50.10% of the analytical total**

### Crime Category

**Domestic Violence** was the largest crime category, with:

> **134,308 reported cases**

### Crime Head

**Cruelty by Husband/Relatives** was the largest individual crime head,
with:

> **133,676 reported cases**

### Crime-Head Concentration

The top 10 crime heads accounted for:

> **445,581 cases --- 97.23% of the analytical total**

These figures describe the distribution of **reported cases** within the
analytical dataset.

## Important Analytical Limitation

This project analyzes **reported case counts**. A higher number of
reported cases does not by itself indicate a higher population-adjusted
crime rate or prevalence.

Comparisons of raw counts can be affected by factors such as:

-   Population size
-   Reporting patterns
-   Registration practices
-   Differences in the underlying composition of States/UTs

Therefore, findings in this project should be interpreted as
**reported-case distributions**, not as population-adjusted crime rates
or measures of prevalence.

## Repository Structure

``` text
crime-against-women-analysis/
│
├── README.md
│
├── SQL/
│   └── Crime_Against_Women_Analysis.sql
│
├── Excel/
│   └── Crime_Against_Women_Analysis.xlsx
│
└── Screenshots/
    └── dashboard.png
```

## How to Use

### SQL

1.  Open `SQL/Crime_Against_Women_Analysis.sql`.
2.  Create/use the `Crime_DB` database.
3.  Create the `Crime_Data` table.
4.  Import the prepared dataset.
5.  Run the data-preparation section to populate `Record_Level` and
    `Analysis_Include`.
6.  Run the validation and analysis queries in sequence.

The SQL analysis uses `Analysis_Include = 'Yes'` for aggregate
calculations where the hierarchical dataset requires the analytical
filter.

### Excel

Open the workbook in Microsoft Excel and navigate to the **Dashboard**
sheet.

The dashboard contains interactive Slicers for:

-   State/UT
-   Crime Category
-   Crime Head

Supporting analysis is available through the workbook's analysis and
data sheets.

## Project Files

-   **SQL file:** Complete data preparation, validation, analytical
    queries, advanced SQL analysis, and KPI queries.
-   **Excel workbook:** Normalized data, analytical data, PivotTables,
    dashboard, and key insights.
-   **Dashboard screenshot:** Quick visual preview of the final
    dashboard.

## Skills Demonstrated

### SQL

-   `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`
-   Aggregate functions
-   Subqueries
-   Common Table Expressions (CTEs)
-   Window functions
-   `CASE` expressions
-   Ranking
-   Percentage calculations
-   Data validation
-   Hierarchical data handling

### Excel

-   Data cleaning and normalization
-   Power Query
-   PivotTables
-   PivotCharts
-   Slicers
-   KPI design
-   Dashboard development
-   Data-driven insights

### Analytical Skills

-   Data validation
-   Exploratory data analysis
-   Data aggregation
-   Comparative analysis
-   Concentration analysis
-   Translating analytical questions into SQL
-   Cross-checking results across SQL and Excel
-   Communicating findings with appropriate limitations

## Project Outcome

The project demonstrates an end-to-end analytics workflow:

**Raw dataset → Data preparation → SQL analysis → Excel analysis →
Interactive dashboard → Insights**

The emphasis is on **data correctness, reproducibility, clear analytical
reasoning, and responsible interpretation of reported crime data**.
