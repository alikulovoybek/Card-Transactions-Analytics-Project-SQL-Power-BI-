/*********************************************************************************************************
Purpose: This report consolidates key merchants metrics and behaviors

Highlights:
	1. Gathers essential fields(columns)
	2. Segments merchants into categories (No transactins,Premium,Super Premium, Regular,New) and age group.
	3. Aggregates merchant-level metrics:
		- total transaction
		- total transaction amount
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- average transaction value
		- average monthly transaction
**********************************************************************************************************/

CREATE OR ALTER VIEW gold.report_merchants AS 
WITH base_query AS (
	SELECT 
		merchant_id,
		SUM(transaction_amount) AS total_amount,
		COUNT(transaction_id) AS total_transaction_number,
		MIN(transaction_date) AS first_transaction,
		MAX(transaction_date) AS last_transaction,
		DATEDIFF(MONTH,MIN(transaction_date),MAX(transaction_date)) AS  lifespan

	FROM gold.fact_transactions
	GROUP BY merchant_id
	)
SELECT 
	m.merchant_key,
	m.merchant_city,
	m.merchant_state,
	m.merchant_country,
	m.zip,
	b.total_amount,
	CASE WHEN b.total_transaction_number=0 THEN 0
		 ELSE CAST(b.total_amount/b.total_transaction_number AS DECIMAL(10,2))
	END AS avg_transaction_amount,
	b.total_transaction_number,
	CASE WHEN b.lifespan=0 THEN b.total_transaction_number
		 ELSE ROUND(CAST(b.total_transaction_number AS FLOAT) /b.lifespan,3)
	END AS avg_transaction_number,
	b.last_transaction,
	b.lifespan,
	CASE 
		 WHEN lifespan<12 THEN 'New'
		 WHEN lifespan BETWEEN 12 AND 70 THEN 'Regular'
		 WHEN lifespan BETWEEN 70 AND 120 THEN 'Premium'
		 ELSE 'Super premium'
	END AS lifespan_category
FROM gold.dim_merchants m
LEFT JOIN base_query b
ON b.merchant_id=m.merchant_id
