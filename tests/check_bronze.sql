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

SELECT 
	id,COUNT(*)
FROM bronze.users_data
GROUP BY id
HAVING COUNT(*)>1 OR id IS NULL

--Check for unwanted spaces
--Expectation: No Result

SELECT * FROM bronze.cards_data
WHERE card_on_dark_web!=TRIM(card_on_dark_web)

SELECT * FROM bronze.users_data
WHERE gender!=TRIM(gender) or address!=TRIM(address)

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

SELECT DISTINCT gender FROM bronze.users_data


--Check for unexpected values
--Expectation: NO Result

SELECT 
	*
FROM bronze.cards_data
WHERE LEN(card_number) NOT IN(15,16) OR card_number NOT LIKE '%[0-9]%' OR
	  LEN(cvv) NOT IN(4,3) or cvv NOT LIKE '%[0-9]%'


SELECT 
	* 
FROM bronze.transactions_data
WHERE client_id<0 OR card_id<0 OR merchant_id <0 OR mcc<0 OR 
	  LEN(REPLACE(zip,'.0',''))<5


SELECT 
	* 
FROM bronze.users_data
WHERE current_age<0 OR 
	  retirement_age<0 OR
	  birth_year>GETDATE() OR 
	  birth_month NOT BETWEEN 1 AND 12 OR
	  latitude NOT BETWEEN -90 AND 90 OR
	  longitude NOT BETWEEN -180 AND 180 OR
	  credit_score<0 OR num_credit_cards<0


--Check for unexpected date
--Expectattion: No Result

SELECT 
*
FROM bronze.cards_data
WHERE expires NOT LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' OR expires IS NULL OR
	  acct_open_date NOT LIKE '[0-9][0-9]/[1-2][0-9][0-9][0-9]' OR expires IS NULL OR
	  year_pin_last_changed>GETDATE()


SELECT  * FROM bronze.transactions_data
WHERE date>GETDATE()
