# E-Commerce-Project
Power BI analytics project on 113K+ e-commerce orders. Built a 3-tab interactive dashboard with 20+ DAX measures, customer loyalty tiering, and SQL validation queries.  Data cleaning (Power Query) DAX &amp; time intelligence Loyalty segmentation Return rate &amp; delivery insights SQL cohort analysis
# Amazon Customer Analytics & Loyalty Program Dashboard

##  Project Overview
An end-to-end business analytics project built to help identify strategies for rewarding customers and improving the overall shopping experience for a large-scale e-commerce platform. The project covers the complete BI lifecycle — from raw data cleaning to a fully interactive, multi-tab Power BI dashboard.

##  Problem Statement
Acting as a business analyst, the goal was to explore 6 years of order and customer data to identify actionable strategies for customer rewards, discounts, and Prime-style loyalty perks, ultimately improving customer retention and shopping experience.

##  Tools & Technologies
- **Power BI Desktop** — Data modeling, DAX, report design
- **Power Query (M Language)** — Data cleaning and transformation
- **DAX** — CALCULATE, SUMX, time-intelligence functions (SAMEPERIODLASTYEAR), RANKX, SWITCH
- **SQL / MySQL** — Data validation, window functions, cohort-style queries
- **Excel** — Source dataset

##  Key Steps
- Cleaned and validated a 113,000+ row dataset across Orders and Customers tables, identifying and resolving data corruption, null values, and formatting inconsistencies
- Built a relational data model (Customers 1 → Orders Many) with a dedicated Date dimension table
- Wrote 20+ DAX measures covering revenue analysis, return rate, delivery performance, time intelligence, and customer segmentation
- Validated key business logic using standalone SQL queries (month-over-month growth, rolling averages, customer value scoring)
- Designed a percentile-based, 4-tier customer loyalty program (Platinum/Gold/Silver/Bronze) grounded in actual spend distribution
- Built a 3-tab interactive Power BI dashboard (Main Overview, Product Performance, Individual Product Profile) with dynamic slicers and conditional formatting

##  Key Findings
- Identified a 27.01% return rate as the primary driver of customer ratings — not delivery speed or price, as initially assumed
- Found that delivery type (not product category) is the true driver of customer wait times
- Discovered that 18.6% of customers generate 67% of total revenue
- Uncovered significant regional variation in average order value across 26 locations

##  Repository Contents
- `/dashboard` — Power BI (.pbix) file
- `/data` — Cleaned datasets (Orders, Customers)
- `/sql` — Standalone SQL queries used for validation
- `/docs` — Project report and presentation
- `/ppt` — Overall project insights presentation

##  Outcome
Delivered a complete, presentation-ready analysis and dashboard translating raw transactional data into concrete, data-backed recommendations for customer loyalty, discount strategy, and regional marketing.
