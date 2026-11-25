# E-commerce Sales & Customer Intelligence

**Role simulation:** Business Intelligence Analyst  
**Company:** NovaCart Retail (fictional)  
**Stack:** SQL (SQLite-compatible), Python, pandas, Jupyter, Streamlit, Plotly, Power BI-ready CSV files.

> **Data disclosure:** This repository contains synthetic data generated for a portfolio demonstration. It does not represent actual customers, orders, sellers, or company performance.

## Business objective
Analyse sales, product contribution, customer repeat purchasing, regional performance, payment mix and delivery experience to support management decisions.

## Repository contents
- `data/` — relational CSV tables.
- `sql/ecommerce_analysis.sql` — documented business queries.
- `notebooks/ecommerce_analysis.ipynb` — reproducible Python analysis.
- `dashboard/app.py` — interactive Streamlit dashboard.
- `reports/management_insights.md` — KPI snapshot, definitions, limitations and recommendations.

## Quick start
1. Install Python 3.10+.
2. From this repository folder run `pip install -r requirements.txt`.
3. Launch the dashboard: `streamlit run dashboard/app.py`.
4. Open `notebooks/ecommerce_analysis.ipynb` in Jupyter and run all cells.
5. Import CSV files from `data/` into SQLite or Power BI. Table names should match filenames.

## SQL
The SQL script uses SQLite-compatible syntax. Create/import tables with the same names as the CSV files before running the queries.

## Power BI
Load the CSVs from `data/`. Suggested relationships:
- `orders[customer_id]` → `customers[customer_id]`
- `orders[seller_id]` → `sellers[seller_id]`
- `order_items[order_id]` → `orders[order_id]`
- `order_items[product_id]` → `products[product_id]`
- `payments[order_id]` → `orders[order_id]`
- `reviews[order_id]` → `orders[order_id]`

Use single-direction one-to-many relationships from dimension tables where appropriate. Avoid creating ambiguous bidirectional relationships. A Power BI `.pbix` is not included; the CSV model and dashboard specification are provided so the report can be recreated in Power BI Desktop.

## KPI definitions
See `reports/management_insights.md`. Gross profit is an indicative item contribution after product cost and freight, not audited net income.
