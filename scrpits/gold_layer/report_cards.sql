/*****************************************************************
Purpose: This report consolidates key cards metrics and behaviors

Highlights:
	1. Gathers essential fields(columns)
	2. Segments cards into categories (No transactins,Premium,Super Premium, Regular,New).
	3. Aggregates customer-level metrics:
		- total transaction
		- total transaction amount
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- average transaction value
		- average monthly transaction
*****************************************************************/
CREATE OR ALTER VIEW gold.report_cards AS 
WITH base_query AS (
	SELECT 
		c.card_key,
		c.card_brand,
		c.card_type,
		c.open_date,
		f.transaction_id,
		f.transaction_amount,
		f.transaction_date

	FROM gold.dim_cards c
	LEFT JOIN gold.fact_transactions f
	ON c.card_id=f.card_id
	WHERE f.transaction_id IS NOT NULL
	) 
SELECT 
	card_key,
	card_brand,
	card_type,
	open_date,
	active_year,
	last_transaction_date,
	total_transaction_amount,
	CASE WHEN total_transactions=0 THEN 0
		 ELSE total_transaction_amount/total_transactions
	END AS avg_transaction_amount,
	total_transactions,
	CASE WHEN lifespan=0 THEN 0
		 ELSE total_transactions/lifespan
	END AS avg_transactions_quantity,
	lifespan,
	CASE 
		 WHEN lifespan<12 THEN 'New'
		 WHEN lifespan BETWEEN 12 AND 70 THEN 'Regular'
		 WHEN lifespan BETWEEN 70 AND 120 THEN 'Premium'
		 ELSE 'Super premium'
	END AS lifespan_category

FROM(
		SELECT 
			card_key,
			card_brand,
			card_type,
			open_date,
			DATEDIFF(YEAR,open_date,GETDATE()) AS active_year,
			SUM(transaction_amount) AS total_transaction_amount,
			COUNT(DISTINCT transaction_id) AS total_transactions,
			MAX(transaction_date) AS last_transaction_date,
			DATEDIFF(MONTH,MIN(transaction_date),MAX(transaction_date)) AS lifespan

		FROM base_query
		GROUP BY	
			card_key,
			card_brand,
			card_type,
			open_date)q
