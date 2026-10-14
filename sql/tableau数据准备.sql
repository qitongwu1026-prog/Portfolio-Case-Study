DuckDB Web Shell running...
DuckDB v1.5.2 (Variegata)
Enter ".help" for usage hints.
memory D .files add
Registered: Capital_Investment_Forecast_Dataset.csv (44412 bytes)
memory D SELECT *
         FROM read_csv_auto('Capital_Investment_Forecast_Dataset.csv')
         LIMIT 5;
┌──────────┬────────────┬────────────┬───────────────┬────────────────────┬───┬──────────────────────┬─────────────┬────────────┬────────────┬────────────────┬────────────────────┐
│ column00 │ Project_ID │   Month    │ Forecast_Cost │    Actual_Cost     │ … │     Project_Name     │ Department  │ Start_Date │  End_Date  │ Initial_Budget │ Depreciation_Years │
│  int64   │  varchar   │    date    │    double     │       double       │ … │       varchar        │   varchar   │    date    │    date    │     double     │       int64        │
├──────────┼────────────┼────────────┼───────────────┼────────────────────┼───┼──────────────────────┼─────────────┼────────────┼────────────┼────────────────┼────────────────────┤
│ 0        │ P001       │ 2024-09-01 │ 435301.75     │ 429283.08          │ … │ Radar System Upgrade │ Maintenance │ 2024-09-01 │ 2025-07-01 │ 4761000.0      │ 7                  │
│ 1        │ P001       │ 2024-10-01 │ 436056.62     │ 502469.35          │ … │ Radar System Upgrade │ Maintenance │ 2024-09-01 │ 2025-07-01 │ 4761000.0      │ 7                  │
│ 2        │ P001       │ 2024-11-01 │ 431647.41     │ 421540.94999999995 │ … │ Radar System Upgrade │ Maintenance │ 2024-09-01 │ 2025-07-01 │ 4761000.0      │ 7                  │
│ 3        │ P001       │ 2024-12-01 │ 440714.25     │ 474536.19          │ … │ Radar System Upgrade │ Maintenance │ 2024-09-01 │ 2025-07-01 │ 4761000.0      │ 7                  │
│ 4        │ P001       │ 2025-01-01 │ 430470.81     │ 453826.44          │ … │ Radar System Upgrade │ Maintenance │ 2024-09-01 │ 2025-07-01 │ 4761000.0      │ 7                  │
└──────────┴────────────┴────────────┴───────────────┴────────────────────┴───┴──────────────────────┴─────────────┴────────────┴────────────┴────────────────┴────────────────────┘
  5 rows                                                                                                                                                     13 columns (11 shown)
memory D 
memory D CREATE OR REPLACE TABLE dim_project AS --项目维度表提取--
         SELECT Project_ID AS project_id,
                MAX(Project_Name) AS project_name,
                MAX(Department) AS department,
                MAX(Initial_Budget) AS initial_budget,
                MIN(Start_Date) AS start_date,
                MAX(End_Date) AS end_date,
         FROM read_csv_auto('Capital_Investment_Forecast_Dataset.csv')
         GROUP BY Project_ID;
memory D SELECT *
         FROM dim_project
         LIMIT 5;
┌────────────┬─────────────────────────────────┬─────────────┬────────────────┬────────────┬────────────┐
│ project_id │          project_name           │ department  │ initial_budget │ start_date │  end_date  │
│  varchar   │             varchar             │   varchar   │     double     │    date    │    date    │
├────────────┼─────────────────────────────────┼─────────────┼────────────────┼────────────┼────────────┤
│ P001       │ Radar System Upgrade            │ Maintenance │ 4761000.0      │ 2024-09-01 │ 2025-07-01 │
│ P002       │ New Hangar Construction         │ Operations  │ 2488000.0      │ 2024-12-01 │ 2025-09-01 │
│ P003       │ IT Infrastructure Overhaul      │ Facilities  │ 2189000.0      │ 2024-07-01 │ 2026-01-01 │
│ P004       │ Flight Simulators               │ Engineering │ 1426000.0      │ 2024-11-01 │ 2025-09-01 │
│ P005       │ Manufacturing Equipment Upgrade │ Operations  │ 4752000.0      │ 2024-08-01 │ 2026-01-01 │
└────────────┴─────────────────────────────────┴─────────────┴────────────────┴────────────┴────────────┘
memory D SELECT COUNT(DISTINCT Project_ID) AS total_project_amount
         FROM read_csv_auto('Capital_Investment_Forecast_Dataset.csv');
┌──────────────────────┐
│ total_project_amount │
│        int64         │
├──────────────────────┤
│ 25                   │
└──────────────────────┘
memory D SELECT COUNT(*) AS count_dim_project
         FROM dim_project;
┌───────────────────┐
│ count_dim_project │
│       int64       │
├───────────────────┤
│ 25                │
└───────────────────┘
memory D CREATE OR REPLACE TABLE fact_project_monthly AS
         SELECT Project_ID AS project_id,
                CAST(Month AS DATE) AS month,
                Forecast_Cost AS forecast_cost,
                Actual_Cost AS actual_cost,
                Actual_Cost-Forecast_Cost AS cost_variance,
                Status AS status
         FROM read_csv_auto('Capital_Investment_Forecast_Dataset.csv');
memory D SELECT *
         FROM fact_project_monthly
         LIMIT 5;
┌────────────┬────────────┬───────────────┬────────────────────┬─────────────────────┬─────────────┐
│ project_id │   month    │ forecast_cost │    actual_cost     │    cost_variance    │   status    │
│  varchar   │    date    │    double     │       double       │       double        │   varchar   │
├────────────┼────────────┼───────────────┼────────────────────┼─────────────────────┼─────────────┤
│ P001       │ 2024-09-01 │ 435301.75     │ 429283.08          │ -6018.669999999984  │ Over Budget │
│ P001       │ 2024-10-01 │ 436056.62     │ 502469.35          │ 66412.72999999998   │ Over Budget │
│ P001       │ 2024-11-01 │ 431647.41     │ 421540.94999999995 │ -10106.460000000021 │ On Track    │
│ P001       │ 2024-12-01 │ 440714.25     │ 474536.19          │ 33821.94            │ Delayed     │
│ P001       │ 2025-01-01 │ 430470.81     │ 453826.44          │ 23355.630000000005  │ Delayed     │
└────────────┴────────────┴───────────────┴────────────────────┴─────────────────────┴─────────────┘
memory D CREATE OR REPLACE TABLE fact_project_monthly AS
         SELECT Project_ID AS project_id,
                CAST(Month AS DATE) AS month,
                ROUND(Forecast_Cost,2) AS forecast_cost,
                ROUND(Actual_Cost,2) AS actual_cost,
                ROUND(Actual_Cost-Forecast_Cost,2) AS cost_variance,
                Status AS status
         FROM read_csv_auto('Capital_Investment_Forecast_Dataset.csv');
memory D SELECT *
         FROM fact_project_monthly
         LIMIT 5;
┌────────────┬────────────┬───────────────┬─────────────┬───────────────┬─────────────┐
│ project_id │   month    │ forecast_cost │ actual_cost │ cost_variance │   status    │
│  varchar   │    date    │    double     │   double    │    double     │   varchar   │
├────────────┼────────────┼───────────────┼─────────────┼───────────────┼─────────────┤
│ P001       │ 2024-09-01 │ 435301.75     │ 429283.08   │ -6018.67      │ Over Budget │
│ P001       │ 2024-10-01 │ 436056.62     │ 502469.35   │ 66412.73      │ Over Budget │
│ P001       │ 2024-11-01 │ 431647.41     │ 421540.95   │ -10106.46     │ On Track    │
│ P001       │ 2024-12-01 │ 440714.25     │ 474536.19   │ 33821.94      │ Delayed     │
│ P001       │ 2025-01-01 │ 430470.81     │ 453826.44   │ 23355.63      │ Delayed     │
└────────────┴────────────┴───────────────┴─────────────┴───────────────┴─────────────┘
