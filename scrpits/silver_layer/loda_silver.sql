/*************************************************************************
Script Name    : load_silver
Author         : Oybek Alikulov

Script Purpose :
	 This stored procedure is responsible for manipulating all source tables
    and inserting data into the Silver layer tables using a full load approach
    (truncate and insert). TABLOCK is also used to improve load performance.
*************************************************************************/

CREATE OR ALTER PROCEDURE load_silver AS
BEGIN
	PRINT'========================================================='
	PRINT'START CLEANSING AND TRANSFORMATION '
	PRINT'========================================================='
	
	DECLARE @start_time DATETIME, @end_time DATETIME,
			@start_transforming DATETIME, @end_transforming DATETIME;
		
	BEGIN TRY
		SET @start_transforming=GETDATE();
		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.cards_data;
		INSERT INTO silver.cards_data WITH(TABLOCK) (
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
		SET @end_time=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+' SECONDS'
		PRINT'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.fraud_labels;
		INSERT INTO silver.fraud_labels WITH(TABLOCK) (
			transcation_id,
			is_fraud)
		SELECT 
			transcation_id,
			TRIM(is_fraud) is_fraud
		FROM bronze.fraud_labels
		WHERE transcation_id IS NOT NULL;
		SET @end_time=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+' SECONDS'
		PRINT'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.mcc_code;
		INSERT INTO silver.mcc_code WITH(TABLOCK) (
			mcc_code,
			description)
		SELECT 
			mcc_code,
			TRIM(description) description
		FROM bronze.mcc_code
		WHERE mcc_code IS NOT NULL;
		SET @end_time=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+' SECONDS'
		PRINT'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.transactions_data;
		INSERT INTO silver.transactions_data WITH(TABLOCK) (
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
		FROM bronze.transactions_data;
		SET @end_time=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+' SECONDS'
		PRINT'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

		SET @start_time=GETDATE();
		TRUNCATE TABLE silver.users_data;
		INSERT INTO silver.users_data WITH(TABLOCK) (
			id,
			current_age,
			retirement_age,
			birth_year,
			birth_month,
			gender,
			address,
			latitude,
			longitude,
			per_capita_income,
			yearly_income,
			total_debt,
			credit_score,
			num_credit_cards)
		SELECT 
			id,
			current_age,
			retirement_age,
			birth_year,
			birth_month,
			TRIM(gender) gender,
			TRIM(address) address,
			latitude,
			longitude,
			CAST(REPLACE(per_capita_income,'$','') as DECIMAL(10,2)) per_capita_income,
			CAST(REPLACE(yearly_income,'$','') as DECIMAL(10,2)) yearly_income,
			CAST(REPLACE(total_debt,'$','') AS DECIMAL(10,2)) total_debt,
			credit_score,
			num_credit_cards
		FROM bronze.users_data;
		SET @end_time=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+' SECONDS'
		PRINT'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';

		PRINT'========================================================='
		SET @end_transforming=GETDATE();
		PRINT'CLEANING AND LOADING DURATION IS '+CAST(DATEDIFF(SECOND,@start_transforming,@end_transforming) as NVARCHAR)+' SECONDS'
		PRINT'========================================================='
		END TRY
		BEGIN CATCH
			PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
			PRINT 'ERROR MESSAGE'+ ERROR_MESSAGE()
			PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR)
			PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR)
		END CATCH;
END;

