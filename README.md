# Data Analytics Projects for Superstore

This repository contains two separate projects aimed at supporting Superstore’s business and marketing needs using different tools and methods.

---

## Project 1: RFM Analysis

**Tool:** Python (Pandas, Jupyter Notebooks)  
**Purpose:**  
Superstore is a global retail company with a large customer base. During the Christmas and New Year season, Marketing wants to run targeted campaigns to reward loyal customers and identify potential loyal customers.  
Due to large data volume, manual Excel-based segmentation is no longer feasible. This project implements RFM (Recency, Frequency, Monetary) customer segmentation using Python for scalable analysis.

**Contents:**  
- `notebooks/` — Jupyter notebooks for RFM calculation and segmentation  
- `scripts/` — Python scripts for processing data  
- `data/` — Sample or processed datasets (CSV)

**How to use:**  
1. Install required packages (`pip install -r requirements.txt` if available)  
2. Run the notebooks to perform segmentation  
3. Customize and extend based on business needs

---

## Project 2: Superstore Sales Dashboard

**Tool:** Power BI Desktop (.pbix)  
**Purpose:**  
Senior management requires a dashboard to monitor sales performance and support strategic decisions on market expansion and product portfolio optimization.

**Contents:**  
- `reports/` — Power BI dashboard files (`.pbix`)  
- `data/` — Sample sales datasets (CSV/Excel)

**How to use:**  
1. Open `.pbix` files in Power BI Desktop  
2. Refresh data and explore interactive visuals  
3. Utilize insights to guide business strategies

---
## Data Sources

- **RFM Analysis:** Customer transaction data exported from Superstore’s CRM database (CSV files provided in `rfm_analysis/data/`)  
- **Superstore Sales Dashboard:** Sales data from company’s ERP system, aggregated monthly (sample data included in `superstore_sales_dashboard/data/`)  

## Repository Structure
/
├── rfm_analysis/
│   ├── notebooks/
│   ├── scripts/
│   ├── data/
│   └── README.md
├── superstore_sales_dashboard/
│   ├── reports/
│   ├── data/
│   └── README.md
└── README.md

