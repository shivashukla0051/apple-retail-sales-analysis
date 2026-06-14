# apple-retail-sales-analysis
End-to-end SQL data analysis and query optimization for Apple retail store sales and warranty claims.
# 🍏 Apple Retail Sales & Warranty Analytics 

## 📌 Project Overview
This project involves an in-depth exploratory data analysis (EDA) and performance-tuned SQL querying of an Apple retail dataset. The objective is to extract actionable business metrics regarding global store performance, product sales trends, and warranty claim behaviors.

## 🛠️ Tech Stack & Skills Highlighted
* **Database Engine:** SQL (MySQL / PostgreSQL)
* **Advanced Querying:** Common Table Expressions (CTEs), Window Functions (Row_Number, Lag, Rank), Date-Time Math, and Complex Joins.
* **Performance Tuning:** Utilized `EXPLAIN ANALYZE` and created `INDEXES` to optimize query execution times, reducing retrieval latency significantly (e.g., from 64ms to 0.15ms).

## 📊 Key Business Problems Solved
This script systematically solves 21 complex business problems, including but not limited to:
1. **Year-over-Year (YoY) Growth:** Calculated the year-by-year growth ratio for individual retail stores using Window Functions (`LAG`).
2. **Warranty Lifecycle Analysis:** Determined the percentage chance of receiving warranty claims post-purchase across different countries and tracked claims filed within 180 days of sale.
3. **Product Lifecycle Sales Trends:** Segmented product sales into key periods (0-6 months, 6-12 months, 12-18 months) relative to their global launch dates.
4. **Running Totals & Rolling Metrics:** Computed monthly running totals of sales for each store over a four-year period to compare long-term trends.
5. **Cost-to-Serve Analysis:** Identified stores with the highest percentage of "Paid Repaired" warranty claims relative to total claims filed.

## 📂 Repository Contents
* `apple_retail_analysis.sql` - The master SQL script containing schema exploration, query optimization (indexes), and the solutions to all 21 business queries.
