# 📊 Financial Transactions Dashboard

This project demonstrates how I built a complete data analytics pipeline starting from raw data, creating a data warehouse in SQL, and visualizing insights using Power BI.

I worked on both **Data Engineering** and **Data Analytics** parts of the project.

---

## 🏗️ Data Warehouse (SQL)

First, I created a Data Warehouse in SQL using a layered approach:

- **Bronze Layer** – Raw data loaded as-is  
- **Silver Layer** – Cleaned and standardized data  
- **Gold Layer** – Final analytics-ready tables (fact and dimension tables)

![Overview Data Warehouse](Overview_DataWarehouse.png)

Tables created:
- Fact table: `fact_transactions`
- Dimension tables:
  - `dim_customers`
  - `dim_cards`
  - `dim_merchants`

I performed:
- Data cleaning
- Data validation
- Indexing
- Relationship design

---

## 📈 Power BI Dashboards

After building the data warehouse, I connected Power BI to it and created interactive dashboards.

I built these dashboards:

### 1. Global Transactions Dashboard
- Total transaction amount
- Total transactions
- Trends by date
- Transactions by city
- Card brand performance
- Transaction method analysis
- Age group analysis

![Page_1](Page_1.png)

### 2. Customer Behavior Dashboard
- Total customers
- Active customers
- Average transactions per customer
- Customer lifespan calculation
- Gender and age distribution
- Detailed customer table

![Page_2](Page_2.png)

### 3. Cards Performance Dashboard
- Card brand market share
- Trend by card brand
- Fraud transactions by card brand
- Card type usage
- Transaction method comparison

![Page_3](Page_3.png)
---

## 📌 Skills Demonstrated

This project shows my skills in:

- Data Engineering (SQL, Data Warehouse, ETL)
- Data Modeling (Fact & Dimension tables)
- DAX in Power BI
- Data Analysis & Visualization
- Dashboard Design & UX
- Business-oriented reporting

---

## 🛠️ Tools Used

- SQL Server
- Power BI Desktop
- DAX
- Power Query

---

## ✅ Conclusion

In this project, I designed a full data pipeline, built a structured data warehouse, and developed interactive dashboards to analyze financial transaction data.

This project reflects real-world tasks performed by both **Data Engineers** and **Data Analysts**.
