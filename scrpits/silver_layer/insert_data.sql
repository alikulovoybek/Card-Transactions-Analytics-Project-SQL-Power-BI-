TRUNCATE TABLE silver.cards_data;
INSERT INTO silver.cards_data(
	id,
	client_id,
	card_brand,
	card_type,
	card_number,
	expires,
	cvv,
	has_chip,
	num_cards_issued,
	credit_limit,
	acct_open_date,
	year_pin_last_changed,
	card_on_dark_web)
SELECT 
	id,
	client_id,
	TRIM(card_brand) card_brand,
	TRIM(card_type) card_type,
	TRIM(card_number) card_number,
	CASE 
		WHEN TRIM(expires) LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' 
		THEN EOMONTH(TRY_CONVERT(DATE,'01/'+expires,103))
		ELSE NULL
	END expires,
	CASE WHEN LEN(cvv) NOT IN (3,4) THEN NULL
		 ELSE cvv
	END AS cvv,
	has_chip,
	num_cards_issued,
	CAST(TRIM(REPLACE(credit_limit,'$','')) AS FLOAT) credit_limit,
	CASE 
		WHEN TRIM(acct_open_date) LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' 
		THEN (DATEFROMPARTS(RIGHT(acct_open_date,4),LEFT(acct_open_date,2),1))
		ELSE NULL
	END acct_open_date,
	year_pin_last_changed,
	card_on_dark_web
FROM bronze.cards_data
WHERE id IS NOT NULL;


TRUNCATE TABLE silver.fraud_labels;
INSERT INTO silver.fraud_labels(
	transcation_id,
	is_fraud)
SELECT 
	transcation_id,
	TRIM(is_fraud) is_fraud
FROM bronze.fraud_labels
WHERE transcation_id IS NOT NULL


TRUNCATE TABLE silver.mcc_code;
INSERT INTO silver.mcc_code(
	mcc_code,
	description)
SELECT 
	mcc_code,
	TRIM(description) description
FROM bronze.mcc_code
WHERE mcc_code IS NOT NULL

TRUNCATE TABLE silver.transactions_data;
INSERT INTO silver.transactions_data(
	id,
	date,
	client_id,
	card_id,
	amount,
	use_chip,
	merchant_id,
	merchant_city,
	merchant_state,
	zip,
	mcc,
	errors)
SELECT 
	id,
	date,
	client_id,
	card_id,
	CAST(REPLACE(amount,'$','') AS FLOAT) amount,
	TRIM(use_chip) use_chip,
	merchant_id,
	merchant_city,
	ISNULL(merchant_state,'N/A') merchant_state,
	ISNULL(RIGHT('00000'+REPLACE(zip,'.0',''),5),'N/A') as zip,
	mcc,
	ISNULL(errors,'N/A') errors
FROM bronze.transactions_data
