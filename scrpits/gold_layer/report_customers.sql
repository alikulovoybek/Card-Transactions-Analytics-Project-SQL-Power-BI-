/*****************************************************************
Purpose: This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields(columns)
	2. Segments customers into categories (No transactins,Premium,Super Premium, Regular,New) and age group.
	3. Aggregates customer-level metrics:
		- total transaction
		- total transaction amount
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- average transaction value
		- average monthly transaction
*****************************************************************/
CREATE OR ALTER VIEW gold.report_customers AS 

WITH base_query AS (
SELECT
	c.customer_key,
	c.customer_id,
	c.birth_year,
	c.average_income_per_person,
	c.yearly_income,
	c.total_debt,
	f.transaction_id,
	f.transaction_amount,
	f.transaction_date
FROM gold.dim_customer c
LEFT JOIN  gold.fact_transactions f
ON c.customer_id=f.customer_id

)


SELECT 
	customer_key,
	customer_id,
	yearly_income,
	total_debt,
	total_transaction_amount,
	CASE WHEN total_transactions=0 THEN 0
		 ELSE total_transaction_amount/total_transactions 
	END AS avg_transaction_amount,
	CASE WHEN total_transactions=1 THEN 'No Transactions'
		 ELSE total_transactions
	END AS total_transactions,
	CASE WHEN lifespan=0 OR lifespan IS NULL THEN 0
		 ELSE total_transactions/lifespan 
	END AS avg_transaction_number,
	age,
	CASE WHEN age<20 THEN 'Bellow 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN age BETWEEN 40 AND 49 THEN '40-49'
		 WHEN age BETWEEN 50 AND 59 THEN '50-59'
		 ELSE 'Above 60'
	END AS age_group,
	ISNULL(lifespan,0) AS lifespan,
	CASE 
		 WHEN total_transaction_amount =0 THEN 'No transactions'
		 WHEN lifespan<12 THEN 'New'
		 WHEN lifespan BETWEEN 12 AND 70 THEN 'Regular'
		 WHEN lifespan BETWEEN 70 AND 120 THEN 'Premium'
		 ELSE 'Super premium'
	END AS lifespan_category
FROM (
SELECT 
	customer_key,
	customer_id,
	yearly_income,
	total_debt,
	YEAR(GETDATE())-birth_year AS age,
	SUM(ISNULL(transaction_amount,0)) AS total_transaction_amount,
	COUNT(DISTINCT transaction_id) AS total_transactions,
	DATEDIFF(MONTH,MIN(transaction_date),MAX(transaction_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_id,
	yearly_income,
	total_debt,
	YEAR(GETDATE())-birth_year) q
