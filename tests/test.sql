--Check for nulls or duplicates in Primary key
--Expectation: No Result

SELECT 
	id,COUNT(*) 
FROM bronze.cards_data
GROUP BY id
HAVING COUNT(*)>1 OR id IS NULL

SELECT 
	transcation_id,COUNT(*)
FROM bronze.fraud_labels
GROUP BY transcation_id
HAVING COUNT(*)>1 OR transcation_id IS NULL

SELECT 
	mcc_code,
	COUNT(*)
FROM bronze.mcc_code
GROUP BY mcc_code
HAVING COUNT(*)>1 OR mcc_code IS  NULL

SELECT 
	id, COUNT(*)
FROM bronze.transactions_data
GROUP BY id
HAVING COUNT(*)>1 OR id IS NULL



--Check for unwanted spaces
--Expectation: No Result

SELECT * FROM bronze.cards_data
WHERE card_on_dark_web!=TRIM(card_on_dark_web)

--Data standardization and Consistency

SELECT DISTINCT card_brand FROM bronze.cards_data
SELECT DISTINCT card_type FROM bronze.cards_data
SELECT DISTINCT has_chip FROM bronze.cards_data
SELECT DISTINCT card_on_dark_web FROM bronze.cards_data

SELECT is_fraud, COUNT(*) FROM bronze.fraud_labels
GROUP BY is_fraud

SELECT 
	DISTINCT use_chip 
FROM bronze.transactions_data

SELECT DISTINCT errors from bronze.transactions_data


--Check for unexpected values
--Expectation: NO Result

SELECT 
	*
FROM bronze.cards_data
WHERE LEN(card_number) NOT IN(15,16) OR card_number NOT LIKE '%[0-9]%'


SELECT 
	*
FROM bronze.cards_data
WHERE LEN(cvv) NOT IN(4,3) or cvv NOT LIKE '%[0-9]%'

SELECT * FROM bronze.transactions_data
WHERE client_id<0 OR card_id<0 OR merchant_id <0 OR mcc<0

SELECT * FROM bronze.transactions_data
WHERE LEN(REPLACE(zip,'.0',''))<5

--Check for unexpected date
--Expectattion: No Result

SELECT 
*
FROM bronze.cards_data
WHERE expires NOT LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' OR expires IS NULL 

SELECT 
*
FROM bronze.cards_data
WHERE acct_open_date NOT LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' OR expires IS NULL 

SELECT 
	*
FROM bronze.cards_data
WHERE year_pin_last_changed>GETDATE()

SELECT  * FROM bronze.transactions_data
WHERE date>GETDATE()
