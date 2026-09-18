# 🚚 FleetMetrics: High-Performance Logistics & Telemetry Engine (PostgreSQL)

## 📌 Project Overview
FleetMetrics is a enterprise-grade PostgreSQL database system designed for managing fleet logistics, driver performance, and real-time vehicle IoT telemetry logs. 

## 🛠️ Key Technical Features
- **Table Partitioning:** Implemented range partitioning on trip dates for optimized time-series querying.
- **JSONB Telemetry Parsing:** Applied **B-Tree Expression Indexing** on extracted JSONB fields (speed, engine temp) for high-speed anomaly filtering and query optimization.
- **Automated Audit System:** Built custom PL/pgSQL triggers to log trip fare modifications into `fare_audit_logs`.
- **Advanced Analytics:** Used Window Functions (`DENSE_RANK()`, `LAG()`) and CTEs to detect driver fatigue and rank top performers.
- **Performance Optimization:** Evaluated query execution plans with `EXPLAIN ANALYZE` to replace sequential scans with Index Scans.

## 📁 Repository Structure
- `01_schema_and_partitions.sql` - Core database DDL & partitioning layout.
- `02_data_generator.sql` - Synthetic data generation scripts.
- `03_analytics_queries.sql` - CTEs, Window functions & JSON analytics.
- `04_triggers_and_audit.sql` - PL/pgSQL functions & database triggers.
- `05_performance_and_views.sql` - Indexes and Materialized Views.