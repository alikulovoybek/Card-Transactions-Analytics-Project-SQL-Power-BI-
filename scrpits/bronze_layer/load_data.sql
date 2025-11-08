/*************************************************************************
Script Name    : batch_processing
Script schema  : Bronze
Author         : Oybek Alikulov

Script Purpose :
	This stored procedure is responsible for loading all row dataset into
	Bronze Layer. It Performs full refresh (truncate and reload) 
    for each source table and logs the duration of each table load 
    as well as the total batch duration
*************************************************************************/

CREATE OR ALTER PROCEDURE load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_loading_batch DATETIME, @end_loading_batch DATETIME;
	BEGIN TRY
		SET @start_loading_batch=GETDATE();

		PRINT'==========================================================='
		PRINT'BATCH PROCESSING IS BEGIN'
		PRINT'==========================================================='

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.cards_data;
		BULK INSERT bronze.cards_data
		FROM 'C:\Users\Oybek\Documents\projects\cards_data.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			 );
		SET @end_time=GETDATE();
		PRINT'->DURATION OF bronze.cards_data TABLE IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS'
		PRINT'-----------------------------------------------------------'

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.fraud_labels;
		BULK INSERT bronze.fraud_labels
		FROM 'C:\Users\Oybek\My_projects\fraud_labels.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			 );
		SET @end_time=GETDATE();
		PRINT'->DURATION OF bronze.fraud_labels TABLE IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS'
		PRINT'-----------------------------------------------------------'

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.mcc_code;
		BULK INSERT bronze.mcc_code
		FROM 'C:\Users\Oybek\My_projects\mcc_code.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			 );
		SET @end_time=GETDATE();
		PRINT'->DURATION OF bronze.mcc_code TABLE IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS'
		PRINT'-----------------------------------------------------------'

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.transactions_data;
		BULK INSERT bronze.transactions_data
		FROM 'C:\Users\Oybek\Documents\projects\transactions_data.csv'
		WITH (
			FORMAT='CSV',
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK,
			CODEPAGE = '65001'
			);
		SET @end_time=GETDATE();
		PRINT'->DURATION OF bronze.transactions_data TABLE IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS'
		PRINT'-----------------------------------------------------------'

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.users_data
		BULK INSERT bronze.users_data
		FROM 'C:\Users\Oybek\Documents\projects\users_data.csv'
		WITH (
			FORMAT='CSV',
			FIRSTROW = 2,  -- 1 yoki 2 ekanini tekshir
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK,
			CODEPAGE = '65001'
			);
		SET @end_time=GETDATE();
		PRINT'->DURATION OF bronze.users_data TABLE IS '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS'
		PRINT'-----------------------------------------------------------'

		SET @end_loading_batch=GETDATE();
		PRINT'==========================================================='
		PRINT'BATCH PROCESSING IS COMPLETED'
		PRINT'->TOTAL DURATION IS '+CAST(DATEDIFF(SECOND,@start_loading_batch,@end_loading_batch) AS NVARCHAR)+' SECONDS'
		PRINT'==========================================================='

	END TRY
	BEGIN CATCH
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE'+ ERROR_MESSAGE()
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR)
	END CATCH

END;
